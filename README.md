# Docker Stacks

Docker Compose stack definitions for self-hosted applications with declarative infrastructure management.

## Quick Start

### Option 1: Bootstrap Script (Recommended)

Run the bootstrap script to automatically set up infrastructure:

```bash
curl -sL https://raw.githubusercontent.com/vasiliishvakin/docker-stacks/refs/heads/main/infrastructure/bootstrap.sh | bash
```

Then configure and apply:

```bash
cd infrastructure
nano .env              # Configure network and volumes
task list-volumes      # Preview what will be created
task init              # Create network and volumes
```

### Option 2: Manual Setup

Clone the repository and set up manually:

```bash
git clone https://github.com/vasiliishvakin/docker-stacks.git
cd docker-stacks/infrastructure
cp .env.dist .env      # Create configuration from template
nano .env              # Configure network and volumes
task list-volumes      # Preview what will be created
task init              # Create network and volumes
```

## Infrastructure Management

The system creates Docker networks and volumes from `.env` configuration:

- Volumes in the `VOLUMES` list are created
- Existing volumes are never modified or deleted automatically
- Use `task list-volumes` to preview changes before applying

### Common Commands

```bash
cd infrastructure

task list-volumes     # Preview what will be created
task init             # Create network and volumes
task check            # Verify infrastructure status
task --list           # Show all available commands
```

## Deploying Stacks

Use Portainer's **Repository** deployment method:

1. Navigate to **Stacks** → **Add stack** in Portainer
2. Select **Repository** as the build method
3. Point to the desired stack file from this repository
4. Configure environment variables
5. Deploy

Ensure required volumes are created via `task init` before deployment.

## Repository Structure

```
infrastructure/        # Network and volume management
├── Taskfile.yml      # Task automation
├── .env.dist         # Configuration template
├── .env              # Local configuration (not in git)
└── bootstrap.sh      # Setup script

blocky/               # Example: Blocky DNS stack
└── compose.yml

(other stacks...)     # Additional Docker Compose stacks
```

## Contributing

- Use environment variables for all secrets
- Never commit `.env` files (they are gitignored)
- Add required volumes to `infrastructure/.env.dist` when introducing new stacks
- Test stacks before committing to ensure they deploy correctly
- Ensure stack files are self-contained and include all necessary service definitions
