#!/bin/bash

# APT Cache Proxy Configurator Installation Script

# Define the source script and destination path
SRC_SCRIPT="src/connect-to-apt-cache.sh"
DEST_SCRIPT="/usr/local/bin/connect-to-apt-cache.sh"

# Check if the script exists
if [ ! -f "$SRC_SCRIPT" ]; then
    echo "[ERROR] Source script not found: $SRC_SCRIPT"
    exit 1
fi

# Copy the script to the destination
echo "[INFO] Installing connect-to-apt-cache.sh to $DEST_SCRIPT..."
sudo cp "$SRC_SCRIPT" "$DEST_SCRIPT"

# Set executable permissions
echo "[INFO] Setting executable permissions..."
sudo chmod +x "$DEST_SCRIPT"

# Verify installation
if [ -f "$DEST_SCRIPT" ]; then
    echo "[SUCCESS] Installation completed successfully."
    echo "[INFO] You can now run the script using: connect-to-apt-cache.sh"
else
    echo "[ERROR] Installation failed."
    exit 1
fi