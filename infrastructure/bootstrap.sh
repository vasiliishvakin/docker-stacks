#!/usr/bin/env bash
#
# Docker Infrastructure Bootstrap Script
#
# This script:
# - Installs Task (if not already installed)
# - Downloads infrastructure configuration files
# - Sets up the environment
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/vasiliishvakin/docker-stacks/main/bootstrap.sh | bash
#
# Or download and run locally:
#   wget https://raw.githubusercontent.com/vasiliishvakin/docker-stacks/main/bootstrap.sh
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository configuration
REPO_URL="https://raw.githubusercontent.com/vasiliishvakin/docker-stacks/main"
TASKFILE_URL="${REPO_URL}/infrastructure/Taskfile.yml"
ENV_DIST_URL="${REPO_URL}/infrastructure/.env.dist"

# Target directory
TARGET_DIR="infrastructure"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Docker Infrastructure Bootstrap${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Function to install Task
install_task() {
    echo -e "${YELLOW}Installing Task...${NC}"

    # Detect OS
    OS="$(uname -s)"

    case "$OS" in
        Linux*)
            DISTRO=$(detect_distro)
            echo -e "${GREEN}Linux detected: $DISTRO${NC}"

            # Check if curl is available
            if ! command_exists curl; then
                echo -e "${RED}curl is not installed${NC}"
                echo -e "${YELLOW}Please install curl first:${NC}"
                case "$DISTRO" in
                    ubuntu|debian|linuxmint)
                        echo -e "  ${YELLOW}apt-get install curl${NC}"
                        ;;
                    fedora|centos|rhel)
                        echo -e "  ${YELLOW}dnf install curl${NC}"
                        ;;
                esac
                exit 1
            fi

            case "$DISTRO" in
                ubuntu|debian|linuxmint)
                    echo -e "${BLUE}Setting up Task repository for Debian/Ubuntu...${NC}"
                    curl -1sLf 'https://dl.cloudsmith.io/public/task/task/setup.deb.sh' | bash || {
                        echo -e "${RED}Failed to set up Task repository${NC}"
                        exit 1
                    }
                    echo -e "${BLUE}Installing Task via apt...${NC}"
                    apt-get update && apt-get install -y task || {
                        echo -e "${RED}Failed to install Task${NC}"
                        exit 1
                    }
                    ;;
                fedora|centos|rhel)
                    echo -e "${BLUE}Setting up Task repository for Fedora/CentOS...${NC}"
                    curl -1sLf 'https://dl.cloudsmith.io/public/task/task/setup.rpm.sh' | bash || {
                        echo -e "${RED}Failed to set up Task repository${NC}"
                        exit 1
                    }
                    echo -e "${BLUE}Installing Task via dnf...${NC}"
                    dnf install -y task || {
                        echo -e "${RED}Failed to install Task${NC}"
                        exit 1
                    }
                    ;;
                *)
                    echo -e "${RED}Unsupported Linux distribution: $DISTRO${NC}"
                    echo -e "${YELLOW}Supported distributions:${NC}"
                    echo -e "  - Ubuntu, Debian, Linux Mint (apt)"
                    echo -e "  - Fedora, CentOS, RHEL (dnf)"
                    echo ""
                    echo -e "${YELLOW}Please install Task manually: https://taskfile.dev/installation${NC}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            echo -e "${YELLOW}Supported platforms:${NC}"
            echo -e "  - Ubuntu, Debian, Linux Mint"
            echo -e "  - Fedora, CentOS, RHEL"
            echo ""
            echo -e "${YELLOW}Please install Task manually: https://taskfile.dev/installation${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}✓ Task installed successfully${NC}"
    task --version
    echo ""
}

# Check and install Task
echo -e "${BLUE}[1/4] Checking Task installation...${NC}"
if command_exists task; then
    echo -e "${GREEN}✓ Task is already installed${NC}"
    task --version
else
    install_task
fi
echo ""

# Create target directory
echo -e "${BLUE}[2/4] Creating directory structure...${NC}"
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠ Directory '$TARGET_DIR' already exists${NC}"
    read -p "Continue and overwrite files? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted${NC}"
        exit 1
    fi
else
    mkdir -p "$TARGET_DIR"
    echo -e "${GREEN}✓ Created directory: $TARGET_DIR${NC}"
fi
echo ""

# Download configuration files
echo -e "${BLUE}[3/4] Downloading configuration files...${NC}"

# Check if curl or wget is available
if command_exists curl; then
    DOWNLOAD_CMD="curl -sL -o"
elif command_exists wget; then
    DOWNLOAD_CMD="wget -q -O"
else
    echo -e "${RED}Neither curl nor wget is installed${NC}"
    echo -e "${YELLOW}Please install curl or wget first${NC}"
    exit 1
fi

# Download Taskfile.yml
echo -n "Downloading Taskfile.yml... "
if command_exists curl; then
    curl -sL "$TASKFILE_URL" -o "$TARGET_DIR/Taskfile.yml" && echo -e "${GREEN}✓${NC}" || {
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Failed to download Taskfile.yml${NC}"
        exit 1
    }
else
    wget -q "$TASKFILE_URL" -O "$TARGET_DIR/Taskfile.yml" && echo -e "${GREEN}✓${NC}" || {
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Failed to download Taskfile.yml${NC}"
        exit 1
    }
fi

# Download .env.dist
echo -n "Downloading .env.dist... "
if command_exists curl; then
    curl -sL "$ENV_DIST_URL" -o "$TARGET_DIR/.env.dist" && echo -e "${GREEN}✓${NC}" || {
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Failed to download .env.dist${NC}"
        exit 1
    }
else
    wget -q "$ENV_DIST_URL" -O "$TARGET_DIR/.env.dist" && echo -e "${GREEN}✓${NC}" || {
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Failed to download .env.dist${NC}"
        exit 1
    }
fi
echo ""

# Setup .env file
echo -e "${BLUE}[4/4] Setting up environment...${NC}"
if [ -f "$TARGET_DIR/.env" ]; then
    echo -e "${YELLOW}⚠ .env file already exists, skipping${NC}"
else
    cp "$TARGET_DIR/.env.dist" "$TARGET_DIR/.env"
    echo -e "${GREEN}✓ Created .env from .env.dist${NC}"
fi
echo ""

# Success message
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Bootstrap Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "  1. Edit your configuration:"
echo -e "     ${YELLOW}nano $TARGET_DIR/.env${NC}"
echo ""
echo -e "  2. Preview what will be created:"
echo -e "     ${YELLOW}cd $TARGET_DIR && task dry-run${NC}"
echo ""
echo -e "  3. Apply configuration:"
echo -e "     ${YELLOW}cd $TARGET_DIR && task init${NC}"
echo ""
echo -e "  4. Check status:"
echo -e "     ${YELLOW}cd $TARGET_DIR && task check${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ${YELLOW}cd $TARGET_DIR && task --list${NC}  # Show all available tasks"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo -e "  Edit ${YELLOW}$TARGET_DIR/.env${NC} to configure:"
echo -e "    - NETWORK_NAME: Docker network name (default: services)"
echo -e "    - NETWORK_SUBNET: Subnet prefix (default: 172.24.0)"
echo -e "    - VOLUMES: Uncomment volumes to create, comment to remove"
echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"
echo ""
