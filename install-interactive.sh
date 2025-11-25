#!/bin/bash
set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# APT Cache Proxy Configurator - Interactive Installation Script
# This script downloads and configures the apt-cache configuration tool

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "[INFO] $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "=========================================="
echo "APT Cache Proxy Configurator - Installer"
echo "=========================================="
echo ""

# Validate IP address format
validate_ip() {
    local ip="$1"
    if [[ ! "${ip}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    return 0
}

# Validate port number
validate_port() {
    local port="$1"
    if [[ ! "${port}" =~ ^[0-9]+$ ]] || [ "${port}" -lt 1 ] || [ "${port}" -gt 65535 ]; then
        return 1
    fi
    return 0
}

# Prompt for configuration
read -p "Enter APT-Cacher-NG server IP (default: 10.1.50.183): " PROXY_IP
PROXY_IP="${PROXY_IP:-10.1.50.183}"

if ! validate_ip "${PROXY_IP}"; then
    log_error "Invalid IP address format: ${PROXY_IP}"
    exit 1
fi

read -p "Enter APT-Cacher-NG server port (default: 3142): " PROXY_PORT
PROXY_PORT="${PROXY_PORT:-3142}"

if ! validate_port "${PROXY_PORT}"; then
    log_error "Invalid port number: ${PROXY_PORT} (must be 1-65535)"
    exit 1
fi

read -p "Enter SSH user for VM access (default: root): " SSH_USER
SSH_USER="${SSH_USER:-root}"

read -p "Enter SSH key path (default: \$HOME/.ssh/id_rsa): " SSH_KEY
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"

read -p "Do you have an existing SSH public key to use? (y/n): " -n 1 -r
echo
if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    echo "Paste your SSH public key (ssh-rsa AAAA...): "
    read -r CUSTOM_KEY
else
    CUSTOM_KEY=""
fi

echo ""
echo "Configuration:"
echo "  APT Proxy: http://${PROXY_IP}:${PROXY_PORT}"
echo "  SSH User: ${SSH_USER}"
echo "  SSH Key: ${SSH_KEY}"
if [ -n "${CUSTOM_KEY}" ]; then
    echo "  Custom SSH Key: Provided"
else
    echo "  Custom SSH Key: None (will generate if needed)"
fi
echo ""

read -p "Proceed with installation? (y/n): " -n 1 -r
echo
if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
log_info "Downloading script..."

# Download the script
readonly SCRIPT_URL="https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/src/connect-to-apt-cache.sh"
readonly INSTALL_PATH="/usr/local/bin/connect-to-apt-cache.sh"

if ! curl -fsSL -o "${INSTALL_PATH}" "${SCRIPT_URL}"; then
    log_error "Failed to download script from ${SCRIPT_URL}"
    exit 1
fi

log_info "Configuring script..."

# Update configuration in the script using environment variable style
sed -i "s|^APT_PROXY_SERVER=.*|APT_PROXY_SERVER=\"\${APT_PROXY_SERVER:-http://${PROXY_IP}:${PROXY_PORT}}\"|" "${INSTALL_PATH}"
sed -i "s|^SSH_USER=.*|SSH_USER=\"\${SSH_USER:-${SSH_USER}}\"|" "${INSTALL_PATH}"
sed -i "s|^SSH_KEY_PATH=.*|SSH_KEY_PATH=\"\${SSH_KEY_PATH:-${SSH_KEY}}\"|" "${INSTALL_PATH}"

# Update SSH public key if provided
if [ -n "${CUSTOM_KEY}" ]; then
    # Escape special characters in the custom key for sed
    ESCAPED_KEY=$(printf '%s\n' "${CUSTOM_KEY}" | sed 's/[\/&]/\\&/g')
    sed -i "s|^CUSTOM_SSH_PUBLIC_KEY=.*|CUSTOM_SSH_PUBLIC_KEY=\"\${CUSTOM_SSH_PUBLIC_KEY:-${ESCAPED_KEY}}\"|" "${INSTALL_PATH}"
fi

# Make executable
chmod +x "${INSTALL_PATH}"

log_success "Installation completed!"
echo ""
echo "You can now use the tool with:"
echo "  connect-to-apt-cache.sh local           # Configure this host"
echo "  connect-to-apt-cache.sh lxc-all         # Configure all LXC containers"
echo "  connect-to-apt-cache.sh vm 10.1.50.10   # Configure a VM"
echo ""
echo "For help, run: connect-to-apt-cache.sh"
