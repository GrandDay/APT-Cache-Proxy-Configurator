# APT Cache Proxy Configurator

Automate APT-Cacher-NG proxy configuration across Proxmox hosts, LXC containers, and VMs.

## Quick Start

### Option 1: Interactive Installation (Recommended)

One-liner that prompts for your configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/install-interactive.sh | bash
```

**Note:** If you encounter errors due to CDN caching, use one of these alternatives:

```bash
# Method 1: Process substitution
bash <(curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/install-interactive.sh)

# Method 2: Download first, then run
curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/install-interactive.sh -o /tmp/install.sh && bash /tmp/install.sh
```

This will:

- Prompt for your APT-Cacher-NG server IP and port
- Ask for SSH configuration preferences
- Optionally accept an existing SSH public key
- Download and configure the script automatically

### Option 2: Manual Installation

```bash
# 1. Download the script
curl -o /usr/local/bin/connect-to-apt-cache.sh https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/src/connect-to-apt-cache.sh
chmod +x /usr/local/bin/connect-to-apt-cache.sh

# 2. Edit configuration (REQUIRED - set your proxy server IP)
nano /usr/local/bin/connect-to-apt-cache.sh
# Change: APT_PROXY_SERVER="http://YOUR_SERVER_IP:3142"

# 3. Configure your system
connect-to-apt-cache.sh local           # Configure current host
connect-to-apt-cache.sh lxc-all         # Configure all LXC containers
connect-to-apt-cache.sh vm 10.1.50.10   # Configure a VM
```

## Overview

The APT Cache Proxy Configurator is a tool designed to simplify the configuration of Debian/Ubuntu systems to use an APT-Cacher-NG proxy server. This tool helps in speeding up package downloads and reducing bandwidth usage by caching packages.

## Features

- **SSH Key Management**: Automatically checks for existing SSH keys and generates new ones if necessary.
- **Flexible Configuration**: Supports configuration for local systems, LXC containers, and virtual machines (VMs).
- **Interactive Prompts**: Provides user-friendly prompts for reconfiguration and SSH key generation.
- **Detailed Logging**: Outputs color-coded messages for easy identification of operation statuses.

## Installation

### Quick Install (Interactive - Recommended)

One-liner that prompts for your configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/install-interactive.sh | bash
```

This interactive installer will ask for your APT-Cacher-NG server details and SSH preferences.

### Manual Install

For manual configuration:

```bash
curl -o /usr/local/bin/connect-to-apt-cache.sh https://raw.githubusercontent.com/GrandDay/apt-cache-config/main/src/connect-to-apt-cache.sh
chmod +x /usr/local/bin/connect-to-apt-cache.sh
nano /usr/local/bin/connect-to-apt-cache.sh  # Edit configuration
```

### Repository Install

Clone and install from source:

```bash
git clone https://github.com/GrandDay/apt-cache-config.git
cd apt-cache-config
./install.sh
```

**Note:** Manual and repository installs require editing the configuration. See the [Configuration](#configuration) section below.

## Configuration

**IMPORTANT:** Before using the script, you must edit `/usr/local/bin/connect-to-apt-cache.sh` and customize the configuration variables at the top:

```bash
APT_PROXY_SERVER="http://10.1.50.183:3142"    # Change to your apt-cacher-ng server
SSH_USER="root"                                # Change if using different user
SSH_KEY_PATH="$HOME/.ssh/id_rsa"              # Path to SSH private key
SSH_PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"   # Path to SSH public key
CUSTOM_SSH_PUBLIC_KEY=""                       # Optional: paste existing SSH public key
```

### Quick Configuration

```bash
# Edit the script
nano /usr/local/bin/connect-to-apt-cache.sh

# Or use sed to update the proxy server
sed -i 's|http://10.1.50.183:3142|http://YOUR_SERVER_IP:3142|' /usr/local/bin/connect-to-apt-cache.sh
```

## Usage

After installation, you can use the script to configure your system to use the APT-Cacher-NG proxy. Here are some common commands:

### Configure Local System

```bash
connect-to-apt-cache.sh local
```

### Configure a Single LXC Container

```bash
connect-to-apt-cache.sh lxc-single <CTID>
```

### Configure All LXC Containers

```bash
connect-to-apt-cache.sh lxc-all
```

### Configure a VM via SSH

```bash
connect-to-apt-cache.sh vm <IP_ADDRESS> [username]
```

### Remove APT Proxy Configuration

```bash
connect-to-apt-cache.sh remove <lxc|vm|local> <target>
```

## Documentation

For detailed usage instructions, configuration options, and examples, please refer to the [GUIDE.md](docs/GUIDE.md).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## Contact

For any questions or feedback, please reach out to <grandday@cue-verse.quest>.t> .
