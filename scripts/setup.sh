#!/bin/bash
#
# Set up the local development environment for building and previewing the site.
# Run from the repository root: ./scripts/setup.sh
#

set -e

VENV_DIR="venv"

# Ensure we're in the repo root
if [ ! -f "mkdocs.yml" ]; then
    echo "Error: Run this script from the repository root."
    exit 1
fi

# Create virtualenv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate and install
echo "Installing dependencies..."
source "$VENV_DIR/bin/activate"
export PIP_REQUIRE_VIRTUALENV=true
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt

echo
echo "Setup complete. Activate the environment with:"
echo "  source venv/bin/activate"
echo
echo "Then run:"
echo "  mkdocs serve          # local preview at http://127.0.0.1:8000"
echo "  ./scripts/validate-pr.sh  # full PR validation"
