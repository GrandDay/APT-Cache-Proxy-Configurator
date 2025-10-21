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

To install the APT Cache Proxy Configurator, you can use the following command to download the script directly to your system:

```bash
curl -o /usr/local/bin/connect-to-apt-cache.sh https://raw.githubusercontent.com/yourusername/apt-cache-proxy-configurator/main/src/connect-to-apt-cache.sh
chmod +x /usr/local/bin/connect-to-apt-cache.sh
```

Make sure to replace `yourusername` with your actual GitHub username or the appropriate path to the raw script.

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
