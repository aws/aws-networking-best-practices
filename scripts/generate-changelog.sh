#!/bin/bash
set -e

# Generates changelog entries from merged PRs that carry the `changelog` label.
#
# The script only prints to stdout. It never edits content/changelog.md and
# never commits. A maintainer reviews the output and pastes it into the page.
# Problems (a labeled PR with a missing or malformed "Changelog entry" section)
# are reported as warnings on stderr.
#
# Usage:
#   ./scripts/generate-changelog.sh [--since YYYY-MM-DD] [--label NAME] [--input FILE]
#
# Offline test mode: --input FILE (or the CHANGELOG_PR_JSON environment variable)
# reads the PR JSON from a file instead of calling the GitHub CLI. The file uses
# the same shape as `gh pr list --json number,title,body,mergedAt,url`.

REPO="aws/aws-networking-best-practices"
SINCE=""
LABEL="changelog"
INPUT="${CHANGELOG_PR_JSON:-}"

usage() {
    cat << 'EOF'
Usage: ./scripts/generate-changelog.sh [options]

Prints changelog entries for merged PRs that carry the changelog label,
grouped by merge month, newest first. Does not edit or commit anything.

Options:
  --since DATE   Only include PRs merged on or after DATE (YYYY-MM-DD).
                 Default: 30 days ago.
  --label NAME   Label that marks PRs for the changelog. Default: changelog
  --input FILE   Offline test mode: read PR JSON from FILE instead of calling gh.
                 Same as setting the CHANGELOG_PR_JSON environment variable.
  -h, --help     Show this help.

Entries go to stdout. Warnings about labeled PRs with a missing or malformed
"Changelog entry" section go to stderr.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --since)
            [ $# -ge 2 ] || { echo "❌ --since requires a date (YYYY-MM-DD)" >&2; exit 1; }
            SINCE="$2"; shift 2 ;;
        --label)
            [ $# -ge 2 ] || { echo "❌ --label requires a name" >&2; exit 1; }
            LABEL="$2"; shift 2 ;;
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

JSON_FILE=$(mktemp)
trap 'rm -f "$JSON_FILE"' EXIT

if [ -n "$INPUT" ]; then
    if [ ! -f "$INPUT" ]; then
        echo "❌ Input file not found: $INPUT" >&2
        exit 1
    fi
    echo "ℹ️  Offline mode: reading PR JSON from $INPUT" >&2
    cp "$INPUT" "$JSON_FILE"
else
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI (gh) not found. Install it from https://cli.github.com/" >&2
        exit 1
    fi
    gh pr list --repo "$REPO" --state merged --label "$LABEL" \
        --search "merged:>=$SINCE" \
        --json number,title,body,mergedAt,url --limit 200 > "$JSON_FILE"
fi

python3 - "$JSON_FILE" "$SINCE" "$REPO" << 'EOF'
import json
import re
import sys
from datetime import datetime

json_file, since, repo = sys.argv[1], sys.argv[2], sys.argv[3]

# Fixed icons and labels. The type is matched by keyword so that icon variants
# (for example 🗑 with or without a variation selector) do not matter.
TYPES = [
    ("new guidance", "🆕", "New guidance"),
    ("changed recommendation", "🔄", "Changed recommendation"),
    ("correction", "🔧", "Correction"),
    ("removed", "🗑️", "Removed"),
]
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


def parse_entry(pr):
    """Return (entry_line, merged_date) or raise ValueError with the reason."""
    section = extract_section(pr.get("body"))
    if section is None:
        raise ValueError('no "Changelog entry" section in the PR body')

    checked = []
    for line in section.split("\n"):
        m = re.match(r"^\s*[-*]\s*\[([ xX])\]\s*(.+)$", line)
        if m and m.group(1).lower() == "x":
            text = m.group(2).lower()
            for key, _icon, label in TYPES:
                if key in text:
                    checked.append(label)
    if not checked:
        raise ValueError("no change type is ticked")
    if len(checked) > 1:
        raise ValueError("more than one change type is ticked (" + ", ".join(checked)
                         + "); tick one, or split the entry by hand")
    label = checked[0]
    icon = next(i for _k, i, lbl in TYPES if lbl == label)

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


with open(json_file) as f:
    prs = json.load(f)

selected = []
for pr in prs:
    merged = pr.get("mergedAt") or ""
    if merged[:10] < since:
        continue
    selected.append(pr)

# Newest first by merge timestamp; PR number breaks ties
selected.sort(key=lambda p: (p.get("mergedAt") or "", p["number"]), reverse=True)

if not selected:
    print(f"ℹ️  No merged PRs with the label found since {since}.", file=sys.stderr)
    sys.exit(0)

current_month = None
printed = 0
warned = 0
for pr in selected:
    try:
        entry = parse_entry(pr)
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
