# APT Cache Proxy Configurator

## Overview

The APT Cache Proxy Configurator is a tool designed to simplify the configuration of Debian/Ubuntu systems to use an APT-Cacher-NG proxy server. This tool helps in speeding up package downloads and reducing bandwidth usage by caching packages.

## Features

- **SSH Key Management**: Automatically checks for existing SSH keys and generates new ones if necessary.
- **Flexible Configuration**: Supports configuration for local systems, LXC containers, and virtual machines (VMs).
- **Interactive Prompts**: Provides user-friendly prompts for reconfiguration and SSH key generation.
- **Detailed Logging**: Outputs color-coded messages for easy identification of operation statuses.

## Installation

To install the APT Cache Proxy Configurator, you can use the provided `install.sh` script. This script will copy the main script to a system path and set the necessary permissions.

### Installation Steps

1. Clone the repository or download the files.
2. Navigate to the project directory.
3. Run the installation script:

   ```bash
   ./install.sh
   ```

Alternatively, you can download the main script directly using `curl`:

```bash
curl -o /usr/local/bin/connect-to-apt-cache.sh https://raw.githubusercontent.com/GrandDay/apt-cache-proxy-configurator/main/src/connect-to-apt-cache.sh
chmod +x /usr/local/bin/connect-to-apt-cache.sh
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

For any questions or feedback, please reach out to grandday@cue-verse.quest .
