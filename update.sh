#!/bin/bash
# Update script - pull latest from git and reinstall

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Updating Munin PHP APCu plugin..."

cd "$SCRIPT_DIR"
git pull origin main
sudo bash install.sh

echo "Update complete!"