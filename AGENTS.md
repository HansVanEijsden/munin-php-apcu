# AGENTS.md

## Project overview

`munin-php-apcu` is a Munin plugin that monitors APCu memory statistics per PHP Docker container. The core is a single Bash script (`plugin/php_apcu_multi`) installed on a Munin node. It reads APCu stats from per-container FastCGI sockets exposed by a custom PHP Docker image, auto-discovering all containers on every poll.

Full install instructions live in [README.md](README.md) — link there for deployment details instead of duplicating them here.

## Key commands

```bash
make test          # run plugin against all running php-* containers (config + values)
make install       # sudo bash install.sh
make uninstall     # sudo bash uninstall.sh
make update        # git pull origin main && sudo bash install.sh
make clean         # git clean -fdX
```

- `install.sh` copies `plugin/php_apcu_multi` to `/usr/share/munin/plugins/` and symlinks it as `/etc/munin/plugins/php_apcu_multi` (removing any legacy per-container `php_apcu_*` symlinks). Containers are auto-discovered at every poll.
- Test with: `sudo munin-run php_apcu_multi config` / `sudo munin-run php_apcu_multi`.

## How the plugin works

- On every poll the plugin lists running containers once (`docker ps`) and keeps those exposing a FastCGI socket at `/run/php/<container>.sock`.
- Container names with dashes are converted to underscores (`SAFE_NAME`) for the multigraph name.
- Stats are fetched via `cgi-fcgi` from each socket, using `jq` when available and a `grep`/`sed` fallback otherwise.
- Emits one Munin multigraph per container, `php_apcu_memory_${SAFE_NAME}` with `used`/`free`/`total` fields in graph category `php-apcu`.
- Graph names are byte-for-byte identical to v1.x, so existing RRDs survive an upgrade.

## Conventions & pitfalls

- All scripts are `#!/bin/bash`; install/uninstall/update use `set -e` (do not remove it).
- `jq` is optional — the plugin must keep working without it via the grep/sed fallback. If you touch JSON parsing, update both paths.
- The plugin assumes the munin user can run `docker` (typically via the `docker` group). It also requires `cgi-fcgi` (`apt-get install libfcgi0ldbl`).
- **No warning/critical thresholds by design** (v1.0.3): APCu manages its own cache and evicts entries automatically, so memory warnings were deliberately removed. Do not re-add them.
- Version comments in the plugin header should be bumped on behavior changes.
- Keep comments and user-facing strings in English — the project was fully translated from Dutch so it is accessible to a global audience.
- Do not rename `plugin/php_apcu_multi` — `install.sh` and the README reference it.
- The multi plugin silently skips containers that are stopped or lack a socket. If no containers match, it outputs nothing — only install it on hosts that run the custom PHP image.
