#!/bin/bash
# Uninstall script for Munin PHP APCu plugin

set -e

echo "Removing Munin PHP APCu plugin..."

# Remove plugin symlinks (multi + any legacy per-container ones)
rm -f /etc/munin/plugins/php_apcu_*

# Remove plugins (multi + legacy wildcard)
rm -f /usr/share/munin/plugins/php_apcu_multi
rm -f /usr/share/munin/plugins/php_apcu_

# Restart munin-node
systemctl restart munin-node

echo "Uninstall complete!"