# Munin PHP APCu Monitor

Monitor APCu memory statistics per PHP Docker container.

## Features
- Separate graphs per container
- Memory usage (used/free/total) with stacked layout
- Automatic container detection (containers ending with `php`)
- Warning thresholds (free memory <10MB warning, <5MB critical)
- Graphs in category `php-apcu`

## Installation on Munin server

```bash
cd /usr/local/src
sudo git clone https://github.com/hansvaneijsden/munin-php-apcu.git
cd munin-php-apcu
sudo bash install.sh
```

## Note

This package relies on the `docker` command being available to the user running the Munin plugins (usually `munin`). Ensure that the `munin` user has permission to execute Docker commands, which may involve adding it to the `docker` group:

```bash
sudo usermod -aG docker munin
```

Must be used with my custom PHP Docker image that exposes APCu stats via a simple FastCGI endpoint. Only for custom installations. See https://github.com/HansVanEijsden/php-wordpress-base