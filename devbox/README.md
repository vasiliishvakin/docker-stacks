# Devbox - PHP Development Environment

A comprehensive PHP development environment container with SSH access, multiple language runtimes, and development tools.

## Features

### Languages & Runtimes
- **PHP 8.x** with 30+ extensions including:
  - Database: mysqli, pdo_mysql, pdo_pgsql, mongodb
  - Performance: opcache, apcu, igbinary, zstd, lz4
  - Development: xdebug
  - Processing: imagick, gd, simdjson, yaml
  - Networking: redis, amqp, sockets
- **Node.js 25.x** with npm
- **Python 3** with pip
- **Go** (golang)
- **Java** (default-jdk)

### PHP Tools
- **Composer** with global packages:
  - deployer/deployer
  - rector/rector
  - phpstan/phpstan
  - friendsofphp/php-cs-fixer
  - laravel/installer
  - jbzoo/composer-diff
  - jbzoo/composer-graph

### Node.js Tools
- nodemon
- TypeScript (typescript, ts-node)
- ESLint
- Prettier
- SVGO

### Development Tools
- **Version Control**: git, tig
- **Editors**: vim, nano
- **Terminal**: tmux, bash-completion
- **Monitoring**: htop, strace
- **Utilities**: jq, yq, tree, rsync, pv
- **Network**: bind9-dnsutils, fping, telnet, net-tools
- **File Processing**: zip, unzip, patch
- **Documentation**: man, most

### Image Optimization
- ImageMagick
- jpegoptim
- optipng
- pngquant
- gifsicle
- webp
- libavif-bin

### Database Clients
- MariaDB client

### Other Tools
- ffmpeg (video processing)
- graphviz (diagram generation)
- mhsendmail (MailHog integration)

## Prerequisites

1. **Tailscale stack** (if using `NETWORK_MODE=container:tailscale`):
   ```bash
   docker ps | grep tailscale
   ```

2. **Workspace volume** must be created:
   ```bash
   # Add 'workspace' to infrastructure/.env VOLUMES line, then:
   cd infrastructure
   task init
   ```

3. **SSH Public Key** for authentication

## Configuration

1. Copy the environment template:
   ```bash
   cp .env.dist .env
   ```

2. Configure required settings in `.env`:
   ```bash
   # REQUIRED: Your SSH public key for authentication
   SSH_PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2E...

   # OPTIONAL: Choose PHP version (default: php8.3)
   PHP_VERSION=php8.3

   # OPTIONAL: Network mode
   NETWORK_MODE=container:tailscale
   ```

## Deployment

### Via Portainer

1. **Create volumes**:
   ```bash
   cd infrastructure
   # Add 'workspace' to VOLUMES in .env if not already there
   task init
   ```

2. **Deploy stack in Portainer**:
   - Use "Repository" build method
   - Point to: `devbox/compose.yaml`
   - Add environment variables from `.env`
   - Deploy

### Via Docker Compose

```bash
cd devbox
docker compose up -d
```

## SSH Access

### With Tailscale (Recommended)

1. **Configure SSH port in Tailscale**:

   Edit `tailscale/compose.override.yaml`:
   ```yaml
   services:
     tailscale:
       ports:
         - "2222:22"  # SSH access
   ```

2. **Restart Tailscale stack** to apply port mapping

3. **Connect via SSH**:
   ```bash
   ssh root@<tailscale-hostname> -p 2222
   ```

### With Bridge Network

1. **Change network mode** in `.env`:
   ```bash
   NETWORK_MODE=bridge
   ```

2. **Add ports to compose.yaml**:
   ```yaml
   services:
     devbox:
       ports:
         - "2222:22"
   ```

3. **Connect via SSH**:
   ```bash
   ssh root@localhost -p 2222
   ```

## Usage

### Working with PHP

```bash
# SSH into container
ssh root@<hostname> -p 2222

# Navigate to workspace
cd /workspace

# Create a new Laravel project
laravel new myproject

# Run Composer
composer install

# Run PHPStan analysis
phpstan analyse src/

# Fix code style
php-cs-fixer fix

# Use Xdebug
export XDEBUG_MODE=debug
php script.php
```

### Working with Node.js

```bash
# Install packages
npm install

# Run TypeScript
npx tsc --init
npx ts-node script.ts

# Run ESLint
npx eslint .

# Format with Prettier
npx prettier --write .
```

### Working with Python

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install packages
pip install package-name
```

### Image Optimization

```bash
# Optimize JPEG
jpegoptim image.jpg

# Optimize PNG
optipng image.png
pngquant image.png

# Convert to WebP
cwebp image.jpg -o image.webp

# Convert to AVIF
avifenc image.jpg image.avif
```

## Persistent Storage

- **`/workspace`**: Project files (persisted in external `workspace` volume)
- **`/root`**: Root home directory (persisted in `root` volume)
  - Composer cache: `/root/.composer/cache`
  - SSH config: `/root/.ssh`
  - Shell history: `/root/.bash_history`

## Troubleshooting

### Cannot connect via SSH

1. Check SSH public key is set:
   ```bash
   docker exec devbox cat /root/.ssh/authorized_keys
   ```

2. Check SSH is running:
   ```bash
   docker exec devbox ps aux | grep sshd
   ```

3. Check port mapping (if using Tailscale):
   ```bash
   docker ps | grep tailscale
   ```

### PHP extensions not available

Check installed extensions:
```bash
docker exec devbox php -m
```

### Composer global packages not found

Check PATH includes Composer bin:
```bash
docker exec devbox echo $PATH
# Should include: /root/.config/composer/vendor/bin
```

### Permission issues with workspace

The container runs as root. If you need different permissions:
```bash
docker exec devbox chown -R www-data:www-data /workspace/project
```

## Network Configuration

The devbox uses `container:tailscale` network mode by default, meaning:
- It shares the Tailscale container's network namespace
- No direct port exposure needed
- Access only via Tailscale network (more secure)
- Port mapping configured in `tailscale/compose.override.yaml`

## Security Notes

- Container runs as root (required for SSH daemon)
- SSH access only via public key authentication (no password)
- When using Tailscale network mode, access is restricted to your Tailscale network
- Workspace volume is shared between containers for collaboration

## Related Stacks

- **Tailscale**: Required for `container:tailscale` network mode
- **MailHog**: Can be used with mhsendmail for email testing
- **MariaDB/PostgreSQL**: Database services accessible from devbox

## Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `SSH_PUBLIC_KEY` | - | Your SSH public key (required) |
| `SSH_PORT` | 22 | SSH port inside container |
| `PHP_VERSION` | php8.3 | PHP version (php8.1, php8.2, php8.3, php8.4) |
| `CADDY_IMAGE` | vasiliishvakin/devbox:${PHP_VERSION}-latest | Docker image |
| `NETWORK_MODE` | container:tailscale | Network mode |
| `WORKSPACE` | workspace | Workspace volume name |
| `RESTART_POLICY` | unless-stopped | Container restart policy |

## Support

For issues or questions:
- Check Docker logs: `docker logs devbox`
- Inspect container: `docker exec -it devbox bash`
- Check this repository's issues
