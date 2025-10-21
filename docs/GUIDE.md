# APT Cache Proxy Configurator - User Guide

## Overview

The APT Cache Proxy Configurator is a tool designed to help users configure their Debian/Ubuntu systems (including Proxmox hosts, LXC containers, and VMs) to utilize an APT-Cacher-NG proxy server. This setup aims to enhance package download speeds and minimize bandwidth usage.

## Table of Contents

- [APT Cache Proxy Configurator - User Guide](#apt-cache-proxy-configurator---user-guide)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Usage](#usage)
  - [Examples](#examples)
  - [Troubleshooting](#troubleshooting)
  - [License](#license)

## Installation

You have two options for installing the APT Cache Proxy Configurator:

### Option 1: Interactive Installation (Recommended)

Run this one-liner for a guided setup:

```bash
curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/install-interactive.sh | bash
```

The interactive installer will:

- Prompt you for your APT-Cacher-NG server IP and port
- Ask for your SSH configuration preferences
- Optionally accept an existing SSH public key
- Download and configure the script automatically
- Confirm all settings before installation

**Example Session:**

```text
==========================================
APT Cache Proxy Configurator - Installer
==========================================

Enter APT-Cacher-NG server IP (default: 10.1.50.183): 192.168.1.100
Enter APT-Cacher-NG server port (default: 3142): 3142
Enter SSH user for VM access (default: root): root
Enter SSH key path (default: $HOME/.ssh/id_rsa): /root/.ssh/id_rsa
Do you have an existing SSH public key to use? (y/n): n

Configuration:
  APT Proxy: http://192.168.1.100:3142
  SSH User: root
  SSH Key: /root/.ssh/id_rsa
  Custom SSH Key: None (will generate if needed)

Proceed with installation? (y/n): y
```

### Option 2: Manual Installation

If you prefer to configure manually:

```bash
# 1. Download the script
curl -o /usr/local/bin/connect-to-apt-cache.sh https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/src/connect-to-apt-cache.sh
chmod +x /usr/local/bin/connect-to-apt-cache.sh

# 2. Edit configuration
nano /usr/local/bin/connect-to-apt-cache.sh

# 3. Verify installation
connect-to-apt-cache.sh
```

## Configuration

Before running the script, you need to customize the configuration variables at the top of the script. Open the script in a text editor and modify the following variables:

```bash
APT_PROXY_SERVER="http://YOUR_SERVER_IP:3142"    # Your apt-cacher-ng server address
SSH_USER="root"                                   # SSH user for VM access
SSH_KEY_PATH="$HOME/.ssh/id_rsa"                 # Path to SSH private key
SSH_PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"      # Path to SSH public key
CUSTOM_SSH_PUBLIC_KEY=""                          # Optional: Paste existing SSH public key
```

## Usage

The script provides several commands to configure the APT proxy for different environments:

- **Configure Local System:**

  ```bash
  connect-to-apt-cache.sh local
  ```

- **Configure a Single LXC Container:**

  ```bash
  connect-to-apt-cache.sh lxc-single <CTID>
  ```

- **Configure All LXC Containers:**

  ```bash
  connect-to-apt-cache.sh lxc-all
  ```

- **Configure a VM via SSH:**

  ```bash
  connect-to-apt-cache.sh vm <IP_ADDRESS> [username]
  ```

- **Remove APT Proxy Configuration:**

  ```bash
  connect-to-apt-cache.sh remove <type> <target>
  ```

## Examples

1. **Configure the local system:**

   ```bash
   connect-to-apt-cache.sh local
   ```

2. **Configure a specific LXC container:**

   ```bash
   connect-to-apt-cache.sh lxc-single 100
   ```

3. **Configure a VM:**

   ```bash
   connect-to-apt-cache.sh vm 10.1.50.10
   ```

## Troubleshooting

If you encounter issues while using the script, consider the following:

- Ensure that the APT-Cacher-NG server is running and accessible.
- Verify that the SSH keys are correctly set up and that you can connect to the target systems.
- Check the configuration file for any syntax errors.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
