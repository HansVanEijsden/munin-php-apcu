# Munin PHP APCu Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Monitor APCu memory statistics per PHP Docker container.

This Munin plugin reads APCu stats from a per-container FastCGI socket (exposed by a
[custom PHP Docker image](https://github.com/HansVanEijsden/php-wordpress-base)) and renders
separate memory graphs for every running container whose name ends in `php`.

## Features

- Separate memory graph per container (Munin multigraph)
- `used` / `free` / `total` memory fields with a stacked layout
- Automatic container detection (containers whose names end in `php`)
- No manual thresholds — APCu manages its own cache and evicts entries automatically, so no warning/critical levels are configured (v1.0.3+)
- Pure Bash: `jq` is used when available, with a `grep`/`sed` fallback otherwise

## Requirements

- A Munin node (server) running on Linux
- `docker` CLI available to the user running the Munin plugins (usually `munin`)
- `cgi-fcgi` — install with `apt-get install libfcgi0ldbl`
- The [custom PHP Docker image](https://github.com/HansVanEijsden/php-wordpress-base) that exposes APCu stats via a FastCGI endpoint

## Installation

Clone the repository and run the installer on the Munin node:

```bash
cd /usr/local/src
sudo git clone https://github.com/hansvaneijsden/munin-php-apcu.git
cd munin-php-apcu
sudo bash install.sh
```

The installer:

1. Copies `plugin/php_apcu_` to `/usr/share/munin/plugins/`.
2. Creates a symlink `/etc/munin/plugins/php_apcu_<container>` for every running container whose name ends in `php`.
3. Restarts `munin-node`.

> **Note:** the `munin` user must be able to run `docker`. Add it to the `docker` group if needed:

```bash
sudo usermod -aG docker munin
```

## Usage

After installation, verify the plugin works for a container:

```bash
sudo munin-run php_apcu_<container> config
sudo munin-run php_apcu_<container>
```

Or test every running container at once:

```bash
make test
```

## Uninstall

```bash
sudo bash uninstall.sh
```

## How it works

- The plugin is symlinked once per container. It derives the container name from its own
  filename (`php_apcu_<container>` → container name).
- Stats are fetched with `cgi-fcgi` from the per-container socket `/run/php/<container>.sock`.
- Output is emitted as the Munin multigraph `php_apcu_memory_<container>` in category `php-apcu`.

## License

[MIT](LICENSE) © Hans van Eijsden
