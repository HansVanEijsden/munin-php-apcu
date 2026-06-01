#!/bin/bash
# Uninstall script voor Munin PHP APCu plugin

set -e

echo "Removing Munin PHP APCu plugin..."

# Remove symlinks
rm -f /etc/munin/plugins/php_apcu_*

# Remove plugin
rm -f /usr/share/munin/plugins/php_apcu_

# Restart munin-node
systemctl restart munin-node

echo "Uninstall complete!"