# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains Docker Compose stack definitions for self-hosted applications managed through Portainer. It includes infrastructure management tooling for creating and managing Docker networks and volumes declaratively.

## Common Commands

### Quick Start with Bootstrap Script

The easiest way to get started is using the bootstrap script:

```bash
# Download and run bootstrap script
curl -sL https://raw.githubusercontent.com/vasiliishvakin/docker-stacks/refs/heads/main/infrastructure/bootstrap.sh | bash

# Or download first, then run
wget https://raw.githubusercontent.com/vasiliishvakin/docker-stacks/refs/heads/main/infrastructure/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

The bootstrap script will:
1. Install Task (if not already installed)
2. Create an `infrastructure/` directory
3. Download `Taskfile.yml` and `.env.dist` from the repository
4. Copy `.env.dist` to `.env`
5. Display next steps

### Infrastructure Management

All commands are run from the `infrastructure/` directory:

```bash
cd infrastructure

# List volumes that will be created
task list-volumes

# Create network and volumes
task init

# Check infrastructure status
task check

# Show current configuration from .env
task show-config

# Remove network (with confirmation)
task remove-network

# Detailed network inspection
task inspect-network

# Inspect specific volume
task inspect-volume -- volume_name

# Remove all unused Docker networks and volumes (with confirmation)
task prune

# List all available Task commands
task --list
```

## Architecture

### Infrastructure Management System

The repository uses a **declarative volume and network management** system controlled via `.env` configuration:

**Key Concept**: Volumes are managed in the `VOLUMES` variable in `infrastructure/.env`:
- Space-separated list on a single line
- All volumes in the list are **created** when running `task init`
- Volumes are **never automatically deleted** - must be removed manually

**Format Example**:
```bash
VOLUMES=portainer_data traefik_certs prometheus_data grafana_data
```

**To remove a volume manually**:
```bash
docker volume rm <volume_name>
```

**Network Management**: Creates a Docker bridge network with split IP allocation:
- Static IP range (`.1-.127`): for manual assignment in docker-compose files
- DHCP IP range (`.128-.254`): for automatic assignment by Docker
- Configured via `NETWORK_NAME` and `NETWORK_SUBNET` in `.env`

### File Structure

```
infrastructure/        # Network and volume management tooling
├── Taskfile.yml      # Task runner definitions (core automation logic)
├── bootstrap.sh      # Setup script for new deployments
├── .env.dist         # Template environment file with volume catalog
└── .env              # Local configuration (created from .env.dist, not in git)

blocky/               # Example: Blocky DNS service stack
├── compose.yaml      # Docker Compose definition
└── (config files)    # Optional: stack-specific configuration

(other stacks...)     # Additional service stacks at root level
```

**Note**: Stack files are organized as directories at the repository root (e.g., `blocky/`, `portainer/`, `tailscale/`). Each stack directory contains its `compose.yaml` and any related configuration files.

### Infrastructure Workflow

1. **Configuration**: Edit `infrastructure/.env`
   - Set `NETWORK_NAME` and `NETWORK_SUBNET` to avoid network conflicts
   - Add volumes to the `VOLUMES` list (space-separated)

2. **Preview**: Run `task list-volumes`
   - Shows which volumes will be created
   - Shows which volumes already exist

3. **Apply**: Run `task init`
   - Creates Docker network if it doesn't exist
   - Creates all volumes in the VOLUMES list (skips existing ones)

4. **Verification**: Run `task check`
   - Shows network status and connected containers
   - Shows which volumes exist and their sizes
   - **Note**: `task check` verifies infrastructure (networks/volumes) only, not stacks

### Task System Details

The Taskfile uses shell variable expansion to parse the `VOLUMES` space-separated variable:
- Uses `tr ' ' '\n'` to convert space-separated list to line-by-line format
- `VOLUMES_LIST`: All volumes from the VOLUMES variable

Each task uses Docker CLI to check existence before create operations to provide idempotent behavior (won't recreate existing volumes).

## Portainer Stack Deployment

Stack files should be standalone YAML files containing complete service definitions. When deploying via Portainer:
1. Use the "Repository" build method in Portainer
2. Point to the specific stack YAML file in this repository (e.g., `blocky/compose.yaml`)
3. Configure environment variables as needed for the stack
4. Ensure required external volumes are in `infrastructure/.env` and created via `task init`
5. Ensure services connect to the correct network (default: `shared`, or as configured in `NETWORK_NAME`)

### Stack Patterns

**External Network**: Stacks reference the shared network as external:
```yaml
networks:
  shared:
    external: true
    name: ${NETWORK_NAME:-shared}
```

**Volume Types**:
- **External volumes**: Created via `task init` (e.g., `portainer_data` in `.env`)
- **Inline volumes**: Defined directly in compose.yaml (e.g., `data:` without external reference)

**Network Modes**:
- Standard: `networks: shared:` with optional static IP (`ipv4_address: ${IP}`)
- Container networking: `network_mode: container:<name>` shares another container's network namespace

## Development Notes

### Modifying Infrastructure Configuration

When changing `infrastructure/.env`:
1. Run `task list-volumes` to see what will be created
2. Volumes are only created, never automatically deleted
3. To remove a volume: `docker volume rm <volume_name>`
4. To remove network: `task remove-network` (requires confirmation)
5. Format: Keep all volumes on one line, space-separated: `VOLUMES=vol1 vol2 vol3`

### Adding New Volumes

1. Add the volume name to the `VOLUMES` variable in `infrastructure/.env` (space-separated)
   - Example: `VOLUMES=existing_volume new_volume_name another_volume`
2. Run `task list-volumes` to verify it will be created
3. Run `task init` to create it
4. The volume will now be available for use in stack files

### Removing Volumes

Volumes must be removed manually (never automatically deleted):

1. **Remove from .env**: Delete the volume name from the `VOLUMES` variable
2. **Remove the volume**: `docker volume rm <volume_name>`
3. **Warning**: This permanently deletes all data in the volume

### Bootstrap Script Details

The bootstrap script (`infrastructure/bootstrap.sh`) is included in the repository and handles setup for new deployments:
- Detects OS and Linux distribution
- Installs Task via package manager for supported platforms:
  - **Ubuntu, Debian, Linux Mint**: Sets up cloudsmith repository and installs via `apt`
  - **Fedora, CentOS, RHEL**: Sets up cloudsmith repository and installs via `dnf`
  - **Other platforms** (macOS, etc.): Shows error message that OS is not supported
- Downloads `Taskfile.yml` and `.env.dist` from repository
- Creates local `.env` from `.env.dist` template
- Prompts before overwriting existing files
- Displays next steps for infrastructure configuration

## Creating New Stacks

When adding a new stack to the repository:

1. **Create stack directory** at repository root:
   ```bash
   mkdir my-service
   cd my-service
   ```

2. **Create `compose.yaml`** with standard patterns:
   - Use external `shared` network
   - Add environment variable defaults with `${VAR:-default}`
   - Document required environment variables
   - Use `restart: ${RESTART_POLICY:-unless-stopped}` for restart policy

3. **Add required volumes** to `infrastructure/.env.dist`:
   - If the stack needs persistent external volumes, add them to the `VOLUMES` line
   - Format: space-separated list
   - Example: `VOLUMES=existing_vol1 existing_vol2 new_service_data`

4. **Test deployment**:
   ```bash
   cd infrastructure
   task list-volumes   # Verify new volumes appear
   task init           # Create volumes
   cd ../my-service
   docker compose up -d  # Test locally before pushing
   ```

5. **Document** in stack directory (optional):
   - Add README.md if configuration is complex
   - Include example environment variables
   - Note any special requirements or dependencies

## Local Stack Testing

Test stacks locally before deploying to Portainer:

```bash
# From stack directory (e.g., blocky/)
docker compose config              # Validate and view final compose file
docker compose up -d               # Start stack
docker compose logs -f             # View logs
docker compose ps                  # Check container status
docker compose down                # Stop and remove stack
docker compose down -v             # Stop and remove stack including volumes
```

**Environment Variables**: Create a `.env` file in the stack directory for local testing (already gitignored):
```bash
cd blocky/
cat > .env << EOF
IP=172.24.0.10
DNS=1.1.1.1
CONFIG_PATH=/path/to/config.yml
NETWORK_NAME=shared
EOF
docker compose up -d
```
