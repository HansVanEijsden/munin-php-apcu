#!/bin/bash
# Installatie script voor Munin PHP APCu plugin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SOURCE="${SCRIPT_DIR}/plugin/php_apcu_"
MUNIN_PLUGIN_DIR="/usr/share/munin/plugins"

echo "Installing Munin PHP APCu plugin from ${SCRIPT_DIR}..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)" 
   exit 1
fi

# Check dependencies
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker command not found"
    exit 1
fi

if ! command -v cgi-fcgi >/dev/null 2>&1; then
    echo "Error: cgi-fcgi not found. Install with: apt-get install libfcgi0ldbl"
    exit 1
fi

# Optional: check jq (not required, but nice to have)
if ! command -v jq >/dev/null 2>&1; then
    echo "Warning: jq not found. Will use grep/sed fallback for JSON parsing."
    echo "Install jq for better performance: apt-get install jq"
fi

# Copy plugin to Munin directory
cp "$PLUGIN_SOURCE" "$MUNIN_PLUGIN_DIR/"
chmod +x "${MUNIN_PLUGIN_DIR}/php_apcu_"

# Remove old symlinks
rm -f /etc/munin/plugins/php_apcu_*

# Create symlinks for each PHP container
if docker ps --format "{{.Names}}" | grep -q -E 'php$'; then
    for container in $(docker ps --format "{{.Names}}" | grep -E 'php$'); do
        echo "Creating symlink for container: $container"
        ln -sf "${MUNIN_PLUGIN_DIR}/php_apcu_" "/etc/munin/plugins/php_apcu_${container}"
    done
else
    echo "Warning: No PHP containers found running"
fi

# Restart munin-node
systemctl restart munin-node

echo ""
echo "Installation complete!"
echo ""
echo "Test with:"
for container in $(docker ps --format "{{.Names}}" | grep -E 'php$'); do
    echo "  munin-run php_apcu_${container} config"
done