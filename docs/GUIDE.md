# APT Cache Proxy Configurator - User Guide

## Overview

The APT Cache Proxy Configurator is a tool designed to help users configure their Debian/Ubuntu systems (including Proxmox hosts, LXC containers, and VMs) to utilize an APT-Cacher-NG proxy server. This setup aims to enhance package download speeds and minimize bandwidth usage.

## Table of Contents

- [APT Cache Proxy Configurator - User Guide](#apt-cache-proxy-configurator---user-guide)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Option 1: Interactive Installation (Recommended)](#option-1-interactive-installation-recommended)
    - [Option 2: Manual Installation](#option-2-manual-installation)
  - [Configuration](#configuration)
  - [Usage](#usage)
  - [Examples](#examples)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
      - [1. Script Validation Errors](#1-script-validation-errors)
      - [2. APT Update Failures](#2-apt-update-failures)
      - [3. HTTPS Repository Issues](#3-https-repository-issues)
      - [4. SSH Connection Problems](#4-ssh-connection-problems)
      - [5. LXC Container Issues](#5-lxc-container-issues)
      - [6. Configuration File Location](#6-configuration-file-location)
    - [Getting Help](#getting-help)
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

### Common Issues

#### 1. Script Validation Errors

**Error:** `Invalid proxy server format: <your-input>`

**Solution:** Ensure your proxy URL matches the format `http://IP:PORT` (e.g., `http://10.1.50.183:3142`)

**Error:** `Invalid IP address format: <your-input>`

**Solution:** IP addresses must be in dotted decimal notation (e.g., `192.168.1.100`)

#### 2. APT Update Failures

**Error:** `APT update failed - proxy may not be reachable`

**Troubleshooting Steps:**

1. **Test proxy connectivity:**

   ```bash
   curl -I http://YOUR_PROXY_IP:3142
   # Should return HTTP 200 or 406
   ```

2. **Verify apt-cacher-ng is running:**

   ```bash
   # On the cache server
   systemctl status apt-cacher-ng
   ```

3. **Check firewall rules:**

   ```bash
   # Ensure port 3142 is open
   sudo ufw status | grep 3142
   ```

4. **Test manual package download:**

   ```bash
   # From the client system
   http_proxy="http://YOUR_PROXY_IP:3142" apt-get update
   ```

#### 3. HTTPS Repository Issues

**Error:** Packages from HTTPS sources fail to download

**Solution:** Configure apt-cacher-ng to pass through HTTPS traffic:

On your apt-cacher-ng server, edit `/etc/apt-cacher-ng/acng.conf`:

```bash
# Add these lines (or uncomment if present)
PassThroughPattern: .*
```

Then restart apt-cacher-ng:

```bash
sudo systemctl restart apt-cacher-ng
```

#### 4. SSH Connection Problems

**Error:** `Cannot establish SSH connection to <target>`

**Troubleshooting Steps:**

1. **Test SSH manually:**

   ```bash
   ssh -i ~/.ssh/id_rsa root@TARGET_IP
   ```

2. **Verify SSH key permissions:**

   ```bash
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   ```

3. **Check SSH service on target:**

   ```bash
   # On the target system
   systemctl status sshd
   ```

4. **Re-run key copy:**

   ```bash
   ssh-copy-id -i ~/.ssh/id_rsa.pub root@TARGET_IP
   ```

#### 5. LXC Container Issues

**Error:** `Container <CTID> does not exist` or `Container <CTID> is not running`

**Solution:**

1. **Verify container status:**

   ```bash
   pct list
   pct status <CTID>
   ```

2. **Start the container if stopped:**

   ```bash
   pct start <CTID>
   ```

#### 6. Configuration File Location

The script creates a single configuration file:

- **Path:** `/etc/apt/apt.conf.d/00aptproxy`
- **Content:** `Acquire::http::Proxy "http://YOUR_PROXY:3142";`

**To verify configuration:**

```bash
# On configured system
cat /etc/apt/apt.conf.d/00aptproxy
apt-config dump | grep Proxy
```

**To manually remove:**

```bash
sudo rm /etc/apt/apt.conf.d/00aptproxy
```

### Getting Help

If you continue experiencing issues:

1. **Check script output:** The script provides color-coded feedback for each operation
2. **Review logs:** Use `--verbose` or check system logs for detailed error messages  
3. **Report issues:** Visit <https://github.com/GrandDay/apt-cache-config/issues>
4. **Contact:** Open an issue on GitHub with:
   - Your configuration (redact IPs if sensitive)
   - Full error output
   - Output of `apt-config dump | grep Proxy`

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
