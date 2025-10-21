#!/bin/bash

# APT Cache Proxy Configurator - Interactive Installation Script
# This script downloads and configures the apt-cache configuration tool

set -e

echo "=========================================="
echo "APT Cache Proxy Configurator - Installer"
echo "=========================================="
echo ""

# Prompt for configuration
read -p "Enter APT-Cacher-NG server IP (default: 10.1.50.183): " PROXY_IP
PROXY_IP=${PROXY_IP:-10.1.50.183}

read -p "Enter APT-Cacher-NG server port (default: 3142): " PROXY_PORT
PROXY_PORT=${PROXY_PORT:-3142}

read -p "Enter SSH user for VM access (default: root): " SSH_USER
SSH_USER=${SSH_USER:-root}

read -p "Enter SSH key path (default: \$HOME/.ssh/id_rsa): " SSH_KEY
SSH_KEY=${SSH_KEY:-\$HOME/.ssh/id_rsa}

read -p "Do you have an existing SSH public key to use? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Paste your SSH public key (ssh-rsa AAAA...): "
    read CUSTOM_KEY
else
    CUSTOM_KEY=""
fi

echo ""
echo "Configuration:"
echo "  APT Proxy: http://${PROXY_IP}:${PROXY_PORT}"
echo "  SSH User: ${SSH_USER}"
echo "  SSH Key: ${SSH_KEY}"
if [ -n "$CUSTOM_KEY" ]; then
    echo "  Custom SSH Key: Provided"
else
    echo "  Custom SSH Key: None (will generate if needed)"
fi
echo ""

read -p "Proceed with installation? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "[INFO] Downloading script..."

# Download the script
curl -sS -o /usr/local/bin/connect-to-apt-cache.sh https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/src/connect-to-apt-cache.sh

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to download script"
    exit 1
fi

echo "[INFO] Configuring script..."

# Update configuration in the script
sed -i "s|APT_PROXY_SERVER=\"http://.*\"|APT_PROXY_SERVER=\"http://${PROXY_IP}:${PROXY_PORT}\"|" /usr/local/bin/connect-to-apt-cache.sh
sed -i "s|SSH_USER=\".*\"|SSH_USER=\"${SSH_USER}\"|" /usr/local/bin/connect-to-apt-cache.sh
sed -i "s|SSH_KEY_PATH=\".*\"|SSH_KEY_PATH=\"${SSH_KEY}\"|" /usr/local/bin/connect-to-apt-cache.sh

# Update SSH public key if provided
if [ -n "$CUSTOM_KEY" ]; then
    sed -i "s|CUSTOM_SSH_PUBLIC_KEY=\"\"|CUSTOM_SSH_PUBLIC_KEY=\"${CUSTOM_KEY}\"|" /usr/local/bin/connect-to-apt-cache.sh
fi

# Make executable
chmod +x /usr/local/bin/connect-to-apt-cache.sh

echo "[SUCCESS] Installation completed!"
echo ""
echo "You can now use the tool with:"
echo "  connect-to-apt-cache.sh local           # Configure this host"
echo "  connect-to-apt-cache.sh lxc-all         # Configure all LXC containers"
echo "  connect-to-apt-cache.sh vm 10.1.50.10   # Configure a VM"
echo ""
echo "For help, run: connect-to-apt-cache.sh"
