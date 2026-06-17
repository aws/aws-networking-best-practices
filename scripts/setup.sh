#!/bin/bash
#
# Set up the local development environment for building and previewing the site.
# Source this script from the repository root:
#
#   source ./scripts/setup.sh
#
# Sourcing (instead of executing) keeps the virtual environment active in your
# current shell so you can immediately run mkdocs or the validation script.
#

VENV_DIR="venv"

# Ensure we're in the repo root
if [ ! -f "mkdocs.yml" ]; then
    echo "Error: Run this script from the repository root."
    return 1 2>/dev/null || exit 1
fi

# Create virtualenv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate and install
source "$VENV_DIR/bin/activate"
export PIP_REQUIRE_VIRTUALENV=true
echo "Installing dependencies..."
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt

echo
echo "Setup complete. Virtual environment is active."
echo
echo "Run:"
echo "  mkdocs serve              # local preview at http://127.0.0.1:8000"
echo "  ./scripts/validate-pr.sh  # full PR validation"
