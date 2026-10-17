#!/bin/bash
set -e

# Generates changelog entries from merged PRs that carry a changelog type label:
# `changelog:new`, `changelog:changed`, `changelog:correction`, or
# `changelog:removed`. The label is authoritative: it confirms the PR belongs in
# the changelog and sets the change type. The checkbox in the PR body is only
# the author's suggestion. If it disagrees with the label, the label wins and the
# script warns on stderr.
#
# The script only prints to stdout. It never edits content/changelog.md and
# never commits. A maintainer reviews the output and pastes it into the page.
# Problems (a missing or malformed "Changelog entry" section, a label/checkbox
# mismatch, or more than one type label) are reported as warnings on stderr.
#
# Usage:
#   ./scripts/generate-changelog.sh [--since YYYY-MM-DD] [--label-prefix PREFIX] [--input FILE]
#
# Offline test mode: --input FILE (or the CHANGELOG_PR_JSON environment variable)
# reads the PR JSON from a file instead of calling the GitHub CLI. The file uses
# the same shape as `gh pr list --json number,title,body,mergedAt,url,labels`.

REPO="aws/aws-networking-best-practices"
SINCE=""
LABEL_PREFIX="changelog:"
# Suffixes of the type labels (PREFIX + suffix). Keep in sync with TYPES in the Python block.
LABEL_SUFFIXES="new changed correction removed"
INPUT="${CHANGELOG_PR_JSON:-}"

usage() {
    cat << 'EOF'
Usage: ./scripts/generate-changelog.sh [options]

Prints changelog entries for merged PRs that carry exactly one changelog type
label, grouped by merge month, newest first. Does not edit or commit anything.

The label decides the change type: PREFIX followed by new, changed, correction,
or removed. The checkbox in the PR body is only a hint; on a mismatch the label
wins and a warning goes to stderr.

Options:
  --since DATE   Only include PRs merged on or after DATE (YYYY-MM-DD).
                 Default: 30 days ago.
  --label-prefix PREFIX
                 Prefix of the type labels. Default: changelog:
                 (changelog:new, changelog:changed, changelog:correction,
                 changelog:removed)
  --input FILE   Offline test mode: read PR JSON from FILE instead of calling gh.
                 Same as setting the CHANGELOG_PR_JSON environment variable.
  -h, --help     Show this help.

Entries go to stdout. Warnings (missing or malformed "Changelog entry" section,
label/checkbox mismatch, more than one type label) go to stderr.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --since)
            [ $# -ge 2 ] || { echo "❌ --since requires a date (YYYY-MM-DD)" >&2; exit 1; }
            SINCE="$2"; shift 2 ;;
        --label-prefix)
            [ $# -ge 2 ] || { echo "❌ --label-prefix requires a value" >&2; exit 1; }
            LABEL_PREFIX="$2"; shift 2 ;;
        --input)
            [ $# -ge 2 ] || { echo "❌ --input requires a file path" >&2; exit 1; }
            INPUT="$2"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            echo "❌ Unknown option: $1" >&2
            usage >&2
            exit 1 ;;
    esac
done

if ! command -v python3 &> /dev/null; then
    echo "❌ python3 not found. Install Python 3 to run this script." >&2
    exit 1
fi

# Default to the last 30 days (GNU date first, BSD/macOS date as fallback)
if [ -z "$SINCE" ]; then
    SINCE=$(date -d '30 days ago' +%Y-%m-%d 2>/dev/null || date -v-30d +%Y-%m-%d)
fi
if ! [[ "$SINCE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "❌ --since must be a date in YYYY-MM-DD format, got: $SINCE" >&2
    exit 1
fi

JSON_DIR=$(mktemp -d)
trap 'rm -rf "$JSON_DIR"' EXIT

if [ -n "$INPUT" ]; then
    if [ ! -f "$INPUT" ]; then
        echo "❌ Input file not found: $INPUT" >&2
        exit 1
    fi
    echo "ℹ️  Offline mode: reading PR JSON from $INPUT" >&2
    cp "$INPUT" "$JSON_DIR/input.json"
else
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI (gh) not found. Install it from https://cli.github.com/" >&2
        exit 1
    fi
    # GitHub search filters by one label at a time, so query each type label
    # separately. The Python block merges the results by PR number.
    for suffix in $LABEL_SUFFIXES; do
        gh pr list --repo "$REPO" --state merged --label "${LABEL_PREFIX}${suffix}" \
            --search "merged:>=$SINCE" \
            --json number,title,body,mergedAt,url,labels --limit 200 > "$JSON_DIR/$suffix.json"
    done
fi

python3 - "$JSON_DIR" "$SINCE" "$REPO" "$LABEL_PREFIX" << 'EOF'
import glob
import json
import os
import re
import sys
from datetime import datetime

json_dir, since, repo, label_prefix = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

# Fixed icons and names. The label suffix maps to the type. The checkbox hint is
# matched by keyword so that icon variants (for example 🗑 with or without a
# variation selector) do not matter.
TYPES = [
    ("new", "new guidance", "🆕", "New guidance"),
    ("changed", "changed recommendation", "🔄", "Changed recommendation"),
    ("correction", "correction", "🔧", "Correction"),
    ("removed", "removed", "🗑️", "Removed"),
]
SUFFIX_TO_TYPE = {suffix: name for suffix, _k, _i, name in TYPES}
NEEDS_BEFORE_AFTER = {"Changed recommendation", "Removed"}
MONTHS = ["January", "February", "March", "April", "May", "June", "July",
          "August", "September", "October", "November", "December"]


def warn(pr, reason):
    print(f"⚠️  WARNING: PR #{pr['number']} ({pr.get('title', '')}): {reason}", file=sys.stderr)


def extract_section(body):
    """Return the text under the 'Changelog entry' heading, or None."""
    body = re.sub(r"<!--.*?-->", "", body or "", flags=re.DOTALL)
    lines = body.replace("\r\n", "\n").split("\n")
    start = None
    for i, line in enumerate(lines):
        if re.match(r"^#{1,6}\s+.*changelog entry", line, re.IGNORECASE):
            start = i + 1
            break
    if start is None:
        return None
    section = []
    for line in lines[start:]:
        if re.match(r"^#{1,6}\s", line):
            break
        section.append(line)
    return "\n".join(section)


def type_labels(pr):
    """Return the change types named by the PR's type labels (label suffix -> type)."""
    found = []
    for item in pr.get("labels") or []:
        name = item.get("name", "") if isinstance(item, dict) else str(item)
        if name.startswith(label_prefix) and name[len(label_prefix):] in SUFFIX_TO_TYPE:
            found.append(SUFFIX_TO_TYPE[name[len(label_prefix):]])
    return found


def parse_entry(pr, label):
    """Return the entry line for a PR whose label-determined type is `label`.

    Raises ValueError with the reason if the entry cannot be built. The checkbox
    in the body is only a hint: a mismatch prints a warning and the label wins.
    """
    section = extract_section(pr.get("body"))
    if section is None:
        raise ValueError('no "Changelog entry" section in the PR body')

    checked = []
    for line in section.split("\n"):
        m = re.match(r"^\s*[-*]\s*\[([ xX])\]\s*(.+)$", line)
        if m and m.group(1).lower() == "x":
            text = m.group(2).lower()
            for _suffix, key, _icon, name in TYPES:
                if key in text:
                    checked.append(name)
    if checked and checked != [label]:
        warn(pr, f"label type is {label} but the checkbox suggests {', '.join(checked)}; using the label")
    icon = next(i for _s, _k, i, name in TYPES if name == label)

    page_m = re.search(r"\*\*Page\(s\) affected:?\*\*:?(.*?)(?=\*\*Summary|\Z)", section, re.DOTALL)
    if not page_m or not page_m.group(1).strip():
        raise ValueError('"Page(s) affected" is missing or empty')
    links = re.findall(r"\[([^\]]+)\]\(([^)\s]+)\)", page_m.group(1))
    if not links:
        raise ValueError('"Page(s) affected" has no [Page title](path.md#anchor) link')
    rendered = []
    for title, target in links:
        target = re.sub(r"^/?(content/)?", "", target)
        if re.match(r"^[a-z]+://", target) or not re.search(r"\.md(#[\w.-]+)?$", target):
            raise ValueError(f'page link "{target}" must be a path relative to content/ ending in .md')
        rendered.append(f"[{title.strip()}]({target})")

    summary_m = re.search(r"\*\*Summary[^*\n]*\*\*:?(.*)", section, re.DOTALL)
    summary = re.sub(r"\s+", " ", summary_m.group(1)).strip() if summary_m else ""
    if not summary:
        raise ValueError('"Summary" is missing or empty')

    if label in NEEDS_BEFORE_AFTER:
        if "→" in summary and not re.search(r"\bPreviously\b", summary):
            before, after = summary.split("→", 1)
            before, after = before.strip().rstrip("."), after.strip().rstrip(".")
            if not before or not after:
                raise ValueError("summary needs text on both sides of the → arrow")
            # Lowercase a leading capital so the clause reads after "Previously"/"Now",
            # but keep acronyms such as "NAT" and "AWS" intact.
            before, after = (re.sub(r"^([A-Z])([a-z])", lambda m: m.group(1).lower() + m.group(2), t)
                             for t in (before, after))
            summary = f"Previously {before}. Now {after}."
        elif not (re.search(r"\bPreviously\b", summary) and re.search(r"\bNow\b", summary)):
            raise ValueError(f'summary for "{label}" must state "Previously X. Now Y." (or "previous → new")')

    number = pr["number"]
    entry = (f"* {icon} **{label}** — {', '.join(rendered)}: {summary} "
             f"([#{number}](https://github.com/{repo}/pull/{number}))")
    return entry


# One file offline, one file per type label live. De-duplicate by PR number and
# combine the labels, so a PR with two type labels shows up with both.
by_number = {}
for path in sorted(glob.glob(os.path.join(json_dir, "*.json"))):
    with open(path) as f:
        for pr in json.load(f):
            known = by_number.setdefault(pr["number"], pr)
            if known is not pr:
                names = {l["name"] for l in known.get("labels") or []}
                known.setdefault("labels", []).extend(
                    l for l in pr.get("labels") or [] if l["name"] not in names)

selected = []
for pr in by_number.values():
    merged = pr.get("mergedAt") or ""
    if merged[:10] < since:
        continue
    if not type_labels(pr):
        continue  # no type label: not published, no warning
    selected.append(pr)

# Newest first by merge timestamp; PR number breaks ties
selected.sort(key=lambda p: (p.get("mergedAt") or "", p["number"]), reverse=True)

if not selected:
    print(f"ℹ️  No merged PRs with a {label_prefix}* type label found since {since}.", file=sys.stderr)
    sys.exit(0)

current_month = None
printed = 0
warned = 0
for pr in selected:
    labels = type_labels(pr)
    if len(set(labels)) > 1:
        warn(pr, "more than one type label (" + ", ".join(sorted(set(labels)))
             + "); keep exactly one, then run the script again. Skipping")
        warned += 1
        continue
    try:
        entry = parse_entry(pr, labels[0])
    except ValueError as e:
        warn(pr, str(e))
        warned += 1
        continue
    merged = datetime.strptime(pr["mergedAt"][:10], "%Y-%m-%d")
    month = f"{MONTHS[merged.month - 1]} {merged.year}"
    if month != current_month:
        if current_month is not None:
            print()
        print(f"## {month}")
        print()
        current_month = month
    print(entry)
    printed += 1

print(f"ℹ️  {printed} entries printed, {warned} PR(s) skipped with warnings.", file=sys.stderr)
EOF
