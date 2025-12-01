# Self-Hosted Stacks

Docker Compose YAML files for self-hosted applications managed through Portainer.

## Purpose

This repository contains stack definitions for deploying and managing self-hosted services via Portainer's stack feature.

## Usage

1. Browse the available stack files in this repository
2. In Portainer, navigate to **Stacks** → **Add stack**
3. Choose **Repository** as the build method
4. Point to the desired stack file in this repository
5. Configure environment variables as needed
6. Deploy the stack

## Structure

Each stack file should be a standalone `docker-compose.yml` or `stack-name.yml` file containing the complete service definition.

## Contributing

When adding new stacks:
- Use clear, descriptive filenames
- Include necessary environment variable placeholders
- Add comments for configuration options
- Test the stack before committing
