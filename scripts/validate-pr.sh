#!/bin/bash

set -e

echo "🔍 Running PR validation checks locally..."
echo

# Check if we're in the right directory
if [ ! -f "mkdocs.yml" ]; then
    echo "❌ Error: Run this script from the repository root"
    exit 1
fi

ERRORS=0

# Markdown lint
echo "📝 Checking markdown lint..."
if command -v markdownlint-cli2 &> /dev/null; then
    markdownlint-cli2 --config .github/.markdownlint-cli2.yaml "content/**/*.md" || ERRORS=$((ERRORS+1))
else
    echo "⚠️  markdownlint-cli2 not installed. Install with: npm install -g markdownlint-cli2"
fi

# MkDocs build
echo "🏗️  Testing MkDocs build..."
if command -v mkdocs &> /dev/null; then
    mkdocs build --quiet || ERRORS=$((ERRORS+1))
else
    echo "⚠️  mkdocs not installed. Install with: pip install mkdocs-material"
fi

# Link check
echo "🔗 Checking links..."
if command -v markdown-link-check &> /dev/null; then
    find content -name "*.md" -exec markdown-link-check --config .github/mlc_config.json {} \; || ERRORS=$((ERRORS+1))
else
    echo "⚠️  markdown-link-check not installed. Install with: npm install -g markdown-link-check"
fi

# Spell check
echo "📖 Checking spelling..."
if command -v cspell &> /dev/null; then
    cspell --config .github/cspell.json "content/**/*.md" || ERRORS=$((ERRORS+1))
else
    echo "⚠️  cspell not installed. Install with: npm install -g cspell"
fi

# YAML lint
echo "📄 Checking YAML..."
if command -v yamllint &> /dev/null; then
    yamllint -c .github/yamllint.yml mkdocs.yml || ERRORS=$((ERRORS+1))
else
    echo "⚠️  yamllint not installed. Install with: pip install yamllint"
fi

# File naming
echo "📁 Checking file naming..."
if find content -name "* *" -type f | grep -q .; then
    echo "❌ Files with spaces found:"
    find content -name "* *" -type f
    ERRORS=$((ERRORS+1))
fi

if find content -name "*.md" | grep -E '[A-Z]' | grep -q .; then
    echo "⚠️  Uppercase letters in markdown filenames:"
    find content -name "*.md" | grep -E '[A-Z]'
fi

# Image check
echo "🖼️  Checking images..."
find content -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -size +500k -exec ls -lh {} \; > /tmp/large_images.txt 2>/dev/null || true
if [ -s /tmp/large_images.txt ]; then
    echo "⚠️  Large images found (>500KB):"
    cat /tmp/large_images.txt
fi

if grep -r "!\[\](" content/ --include="*.md" | grep -q .; then
    echo "❌ Images without alt text found:"
    grep -r "!\[\](" content/ --include="*.md"
    ERRORS=$((ERRORS+1))
fi

# Navigation structure
echo "🗺️  Checking navigation structure..."
python3 << 'EOF'
import re
import glob
import sys

try:
    with open('mkdocs.yml', 'r') as f:
        content = f.read()
    
    nav_match = re.search(r'^nav:\s*\n((?:[ \t]+.*\n)*)', content, re.MULTILINE)
    if not nav_match:
        print("❌ No nav section found in mkdocs.yml")
        sys.exit(1)
    
    nav_content = nav_match.group(1)
    nav_files = set()
    for line in nav_content.split('\n'):
        md_matches = re.findall(r'([\w/-]+\.md)', line)
        nav_files.update(md_matches)
    
    md_files = set()
    for file in glob.glob('content/**/*.md', recursive=True):
        md_files.add(file.replace('content/', ''))
    
    orphaned = md_files - nav_files
    if orphaned:
        print("⚠️  Files not in navigation:")
        for file in sorted(orphaned):
            print(f"  - {file}")
    
    missing = nav_files - md_files
    if missing:
        print("❌ Navigation references missing files:")
        for file in sorted(missing):
            print(f"  - {file}")
        sys.exit(1)
    
    print("✅ Navigation structure OK")
except Exception as e:
    print(f"❌ Navigation check failed: {e}")
    sys.exit(1)
EOF
[ $? -ne 0 ] && ERRORS=$((ERRORS+1))

# IP validation
echo "🌐 Validating IP addresses..."
python3 << 'EOF'
import re
import ipaddress
import glob
import sys

doc_ranges = [
    '192.0.2.0/24', '198.51.100.0/24', '203.0.113.0/24', '233.252.0.0/24',
    '2001:db8::/32', '3fff::/20',
    '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16',
    '169.254.0.0/16', '127.0.0.0/8', '224.0.0.0/4', '240.0.0.0/4', '100.64.0.0/10',
    'fe80::/10', 'fc00::/7', '::1/128', 'ff00::/8', '::/128', '::ffff:0:0/96'
]
doc_networks = [ipaddress.ip_network(r) for r in doc_ranges]

def validate_ipv4(ip):
    try:
        addr = ipaddress.IPv4Address(ip)
        return str(addr) == ip
    except:
        return False

def validate_ipv6(ip):
    try:
        addr = ipaddress.IPv6Address(ip)
        return str(addr) == ip.lower() and '::' not in ip.replace('::', ':::')
    except:
        return False

def is_doc_ip(ip):
    try:
        addr = ipaddress.ip_address(ip)
        return any(addr in net for net in doc_networks)
    except:
        return False

errors = []
ipv4_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?:/[0-9]{1,2})?\b'
ipv6_pattern = r'\b(?:[0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}(?:/[0-9]{1,3})?\b'

for file in glob.glob('content/**/*.md', recursive=True):
    if 'community/conventions.md' in file:
        continue
    
    with open(file, 'r') as f:
        content = f.read()
    
    for match in re.finditer(ipv4_pattern, content):
        ip_cidr = match.group()
        ip = ip_cidr.split('/')[0]
        if not validate_ipv4(ip):
            errors.append(f"{file}: Invalid IPv4 '{ip}'")
        elif not is_doc_ip(ip):
            errors.append(f"{file}: Non-documentation IPv4 '{ip_cidr}' - use approved ranges")
    
    for match in re.finditer(ipv6_pattern, content):
        ip_cidr = match.group()
        ip = ip_cidr.split('/')[0]
        if ':' in ip and not validate_ipv6(ip):
            errors.append(f"{file}: Invalid IPv6 '{ip}' (use lowercase, compressed format)")
        elif ':' in ip and not is_doc_ip(ip):
            errors.append(f"{file}: Non-documentation IPv6 '{ip_cidr}' - use approved ranges")

if errors:
    for error in errors:
        print(f"❌ {error}")
    sys.exit(1)
print("✅ IP address validation passed")
EOF
[ $? -ne 0 ] && ERRORS=$((ERRORS+1))

echo
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Ready to create PR."
else
    echo "❌ $ERRORS check(s) failed. Please fix issues before creating PR."
    exit 1
fi