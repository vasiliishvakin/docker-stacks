# Tailscale Docker Stack

Tailscale container for secure networking and VPN access to your Docker environment.

## Quick Start

1. **Copy environment file**:
   ```bash
   cp .env.dist .env
   ```

2. **Generate Tailscale auth key**:
   - Visit: https://login.tailscale.com/admin/settings/keys
   - Create a reusable, ephemeral key with appropriate tags

3. **Configure `.env`**:
   - Set `TS_AUTHKEY` with your generated key
   - Configure other options as needed

4. **Set execute permissions on entrypoint script**:
   ```bash
   chmod 755 entrypoint.sh
   ```

5. **Deploy**:
   ```bash
   docker compose up -d
   ```

## Configuration

All configuration is done via environment variables in `.env`:

### Required Settings

- `TS_AUTHKEY`: Tailscale authentication key (required)

### Node Configuration

- `HOSTNAME`: Hostname shown in Tailscale admin (default: `tailscale`)
- `TS_ACCEPT_DNS`: Accept DNS from Tailscale (default: `true`)
- `TS_AUTH_ONCE`: Authenticate only once (default: `true`)

### Advanced Options

All configured via simple true/false or value settings:

- `TS_ADVERTISE_EXIT_NODE`: Route all traffic through this node (default: `false`)
- `TS_ADVERTISE_ROUTES`: Subnet routes to advertise (e.g., `172.24.0.0/24`)
- `TS_TAGS`: Tags for ACL management (e.g., `tag:container,tag:server`)
- `TS_SSH`: Enable SSH via Tailscale (default: `false`)
- `TS_ACCEPT_ROUTES`: Accept routes from other nodes (default: `false`)

### Network & DNS

- `NETWORK_NAME`: External Docker network (default: `shared`)
- `DNS_PRIMARY`: Primary DNS server (default: `1.1.1.1`)
- `DNS_SECONDARY`: Secondary DNS server (default: `8.8.8.8`)

### Port Exposure

To expose ports for services using the Tailscale network (via `network_mode: service:tailscale`):

1. Copy the override template:
   ```bash
   cp compose.override.yaml.example compose.override.yaml
   ```

2. Edit `compose.override.yaml` to add/remove ports:
   ```yaml
   services:
     tailscale:
       ports:
         - "9000:9000"   # Portainer HTTP
         - "9443:9443"   # Portainer HTTPS
         - "8080:80"     # Additional service
   ```

3. Docker Compose automatically merges `compose.yaml` + `compose.override.yaml`

## Usage Examples

### Basic Node

```bash
TS_AUTHKEY=tskey-auth-xxxxx
HOSTNAME=docker-server
TS_TAGS=tag:server
```

### Exit Node

```bash
TS_AUTHKEY=tskey-auth-xxxxx
TS_ADVERTISE_EXIT_NODE=true
TS_TAGS=tag:exit-node
```

### Subnet Router

Make your Docker network accessible via Tailscale:

```bash
TS_AUTHKEY=tskey-auth-xxxxx
TS_ADVERTISE_ROUTES=172.24.0.0/24
TS_TAGS=tag:router
```

### Full-Featured Setup

```bash
TS_AUTHKEY=tskey-auth-xxxxx
HOSTNAME=docker-server
TS_ADVERTISE_ROUTES=172.24.0.0/24
TS_TAGS=tag:container
TS_ACCEPT_ROUTES=true
```

## How It Works

The stack uses a custom entrypoint script ([entrypoint.sh](entrypoint.sh)) that:
1. Reads individual environment variables
2. Builds the `TS_EXTRA_ARGS` string dynamically
3. Passes control to the original Tailscale containerboot

This approach provides:
- Clean, simple environment variable configuration
- No need to manually construct argument strings
- Easy to understand and modify

## Volume Management

The `data` volume stores:
- Tailscale node state
- Authentication credentials
- Network configuration

The volume is managed by Docker Compose and persists data across container restarts.

**Important**: Don't delete this volume unless you want to re-authenticate the node.

## Troubleshooting

### Container won't start
- Check `TS_AUTHKEY` is valid and not expired
- Verify `/dev/net/tun` device is available on host
- Check logs: `docker logs tailscale`

### Can't access other nodes
- Verify node appears in Tailscale admin console
- Check ACLs allow communication between nodes
- Ensure `TS_ACCEPT_ROUTES=true` if using subnet routes

### Subnet routes not working
- Verify `TS_ADVERTISE_ROUTES` is set correctly
- Approve routes in Tailscale admin console
- Check host IP forwarding is enabled

## Security Best Practices

- Use ephemeral auth keys for temporary nodes
- Use reusable auth keys with tags for permanent infrastructure
- Never commit `.env` file with real auth keys to git
- Rotate auth keys periodically
- Use ACLs to restrict access between nodes
- Keep SSH disabled unless specifically needed

## Links

- [Tailscale Documentation](https://tailscale.com/kb)
- [Docker Integration Guide](https://tailscale.com/kb/1282/docker)
- [Auth Keys](https://login.tailscale.com/admin/settings/keys)
- [Admin Console](https://login.tailscale.com/admin/machines)
