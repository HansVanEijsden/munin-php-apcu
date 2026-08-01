# AGENTS.md

## Project overview

`munin-php-apcu` is a Munin plugin that monitors APCu memory statistics per PHP Docker container. The core is a single Bash script (`plugin/php_apcu_`) installed on a Munin node. It reads APCu stats from a per-container FastCGI socket exposed by a custom PHP Docker image.

Full install instructions live in [README.md](README.md) — link there for deployment details instead of duplicating them here.

## Key commands

```bash
make test          # run plugin against all running php-* containers (config + values)
make install       # sudo bash install.sh
make uninstall     # sudo bash uninstall.sh
make update        # git pull origin main && sudo bash install.sh
make clean         # git clean -fdX
```

- `install.sh` copies `plugin/php_apcu_` to `/usr/share/munin/plugins/`, then symlinks it as `/etc/munin/plugins/php_apcu_<container>` for each running container whose name ends in `php`.
- Test with: `sudo munin-run php_apcu_<container> config` / `sudo munin-run php_apcu_<container>`.

## How the plugin works

- The plugin is symlinked once per container; it derives the container name from its own basename: `${0##*/}` → strip `php_apcu_` prefix → replace `_` with `-` (matches real container names).
- Container names with dashes are converted back to underscores (`SAFE_NAME`) for the multigraph name.
- Stats are fetched via `cgi-fcgi` from socket `/run/php/${CONTAINER}.sock`, using `jq` when available and a `grep`/`sed` fallback otherwise.
- Emits Munin multigraph `php_apcu_memory_${SAFE_NAME}` with `used`/`free`/`total` fields in graph category `php-apcu`.

## Conventions & pitfalls

- All scripts are `#!/bin/bash`; install/uninstall/update use `set -e` (do not remove it).
- `jq` is optional — the plugin must keep working without it via the grep/sed fallback. If you touch JSON parsing, update both paths.
- The plugin assumes the munin user can run `docker` (typically via the `docker` group). It also requires `cgi-fcgi` (`apt-get install libfcgi0ldbl`).
- **No warning/critical thresholds by design** (v1.0.3): APCu manages its own cache and evicts entries automatically, so memory warnings were deliberately removed. Do not re-add them.
- Version comments in the plugin header should be bumped on behavior changes.
- Keep comments and user-facing strings in English — the project was fully translated from Dutch so it is accessible to a global audience.
- Do not rename `plugin/php_apcu_` (the trailing underscore is part of the symlink convention).
