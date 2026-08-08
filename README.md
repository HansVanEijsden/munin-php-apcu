# Munin PHP APCu Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Monitor APCu memory statistics for PHP Docker containers.

This Munin plugin reads APCu stats from per-container FastCGI sockets (exposed by a
[custom PHP Docker image](https://github.com/HansVanEijsden/php-wordpress-base)) and renders
a separate memory graph for every running container that exposes a FastCGI socket.

A single plugin process auto-discovers all containers on every poll, so there are no
per-container symlinks and Munin's CPU/process/IO load stays minimal even with many
containers.

## Features

- Separate memory graph per container (Munin multigraph)
- `used` / `free` / `total` memory fields with a stacked layout
- Automatic container detection (any container exposing `/run/php/<name>.sock`)
- Single process for all containers (v2.0.0) — one `docker ps`, one FastCGI query per container
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

1. Copies `plugin/php_apcu_multi` to `/usr/share/munin/plugins/`.
2. Creates a single symlink `/etc/munin/plugins/php_apcu_multi` (containers are auto-discovered at every poll).
3. Removes any legacy per-container `php_apcu_*` symlinks from v1.x.
4. Restarts `munin-node`.

> **Note:** the `munin` user must be able to run `docker`. Add it to the `docker` group if needed:

```bash
sudo usermod -aG docker munin
```

## Usage

After installation, verify the plugin discovers every container with a FastCGI socket:

```bash
sudo munin-run php_apcu_multi config
sudo munin-run php_apcu_multi
```

`make test` runs the same checks automatically.

## Uninstall

```bash
sudo bash uninstall.sh
```

## How it works

- On every poll the plugin lists running containers once (`docker ps`) and keeps those that
  expose a FastCGI socket at `/run/php/<container>.sock`.
- Stats are fetched with `cgi-fcgi` from each socket (one query per container).
- Output is emitted as one Munin multigraph per container, `php_apcu_memory_<container>`, in
  category `php-apcu`. Graph names are identical to v1.x, so existing RRD data is preserved
  when upgrading.

## Upgrading from v1.x

v2.0.0 replaced the per-container symlinks (`php_apcu_<container>`) with a single
auto-discovering plugin (`php_apcu_multi`). Graph names are unchanged, so existing RRD
data is preserved when you run `install.sh`. If you still have v1.x symlinks, `install.sh`
removes them automatically.

## License

[MIT](LICENSE) © Hans van Eijsden
