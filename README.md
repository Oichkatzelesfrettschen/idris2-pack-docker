# Idris2 Pack Docker

[![Docker Image Version](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/Oichkatzelesfrettschen/idris2-pack-docker/pkgs/container/idris2-pack-docker)
[![Idris2 Version](https://img.shields.io/badge/idris2-latest-green)](https://www.idris-lang.org/)
[![Chez Scheme](https://img.shields.io/badge/chez-10.0.0-orange)](https://cisco.github.io/ChezScheme/)
[![Debian Version](https://img.shields.io/badge/debian-13%20trixie-red)](https://www.debian.org/)

A production-ready Docker image for **Idris2** with the **Pack package manager**, built on Debian 13 (Trixie). The image automatically tracks the latest stable Idris2 release. Get a fully-configured Idris2 development environment running in seconds on any platform with Docker.

## Features

- **Idris2** - Automatically updated to the latest stable release with full standard library
- **Pack Package Manager** - Curated package collections with dependency management
  - Custom fork with `--db-repo` feature for alternative package databases
- **Chez Scheme** - High-performance backend for compiled Idris2 code
- **Zero Configuration** - All dependencies pre-installed and configured
- **Cross-Platform** - Works identically on Linux, macOS, and Windows
- **Production Ready** - Built on stable Debian 13 with security updates
- **Auto-Updates** - Weekly checks for new Idris2 releases via GitHub Actions

## Quick Start

```bash
# Run Idris2 + Pack in an interactive container
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Now you can use:
pack install hedgehog      # Install packages
pack build myproject.ipkg  # Build projects
idris2                     # Start REPL
```

**Important:** The `-v $(pwd):/workspace` flag mounts your current directory inside the container. This is **required** for your files to persist after the container exits.

## Installation

### Prerequisites

Install Docker for your platform:
- **Linux**: `sudo apt install docker.io` (Debian/Ubuntu) or use [Docker CE](https://docs.docker.com/engine/install/)
- **macOS/Windows**: [Docker Desktop](https://www.docker.com/products/docker-desktop/)

On Linux, add yourself to the docker group:
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Using the Image

The image is automatically pulled from GitHub Container Registry on first use:

```bash
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

## Usage Examples

### Interactive Development

```bash
# Navigate to your project directory
cd ~/my-idris-project

# Start interactive container
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Inside the container:
pack new test
cd test
pack build test.ipkg
pack exec test
```

### Running Commands Directly

```bash
# Check versions
docker run --rm ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2 --version

# Install packages in current directory
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack install hedgehog

# Build a project
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack build myproject.ipkg
```

### Using the Helper Script

For convenience, this repository includes an optional helper script:

```bash
# Download the helper script
curl -O https://raw.githubusercontent.com/Oichkatzelesfrettschen/idris2-pack-docker/master/idris2
chmod +x idris2

# Use it for easier commands
./idris2 shell                    # Interactive shell
./idris2 repl                     # Start REPL
./idris2 pack install hedgehog    # Install package
./idris2 build myproject.ipkg     # Build project
```

### Creating Aliases

Add to your shell configuration (`~/.bashrc` or `~/.zshrc`):

```bash
alias idris2-docker='docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest'
alias idris2='docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2'
alias pack='docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack'
```

## Documentation

- [Getting Started Guide](docs/GETTING_STARTED.md) - Detailed walkthrough for beginners
- [Advanced Usage](docs/ADVANCED_USAGE.md) - Power user features and customization
- [Maintainer Guide](docs/MAINTAINER.md) - Repository maintenance and release process

## Volume Mounting Explained

The `-v $(pwd):/workspace` flag is **critical** for working with files:

- `$(pwd)` - Your current directory on the host machine
- `/workspace` - Where it appears inside the container
- Files created/modified in `/workspace` persist on your host
- Without this flag, the container cannot access your project files

**Always run Docker commands from your project directory** to ensure the correct files are mounted.

## Troubleshooting

### Common Issues

**"permission denied" when running docker**
- You need to be in the docker group: `sudo usermod -aG docker $USER`
- Log out and back in for changes to take effect

**"Cannot connect to Docker daemon"**
- Start the Docker service: `sudo systemctl start docker`
- Enable on boot: `sudo systemctl enable docker`

**Files not persisting after container exits**
- Ensure you're using `-v $(pwd):/workspace` in your docker run command
- Work inside `/workspace` directory in the container

For more detailed troubleshooting, see the [Getting Started Guide](docs/GETTING_STARTED.md).

## Building Locally

To build the image from source:

```bash
git clone https://github.com/Oichkatzelesfrettschen/idris2-pack-docker.git
cd idris2-pack-docker
docker build -t idris2-pack:local .
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

The Docker image is automatically built and published via GitHub Actions when changes are pushed to the master branch.

## Technical Details

- **Base Image**: Debian 13 (Trixie)
- **Idris2 Version**: Automatically updated (latest stable from [idris-lang/Idris2](https://github.com/idris-lang/Idris2/releases))
- **Pack Source**: [Custom fork](https://github.com/Oichkatzelesfrettschen/idris2-pack) with `--db-repo` feature
- **Backend**: Chez Scheme (Debian Trixie package)
- **Image Size**: ~1.8GB
- **Architecture**: linux/amd64
- **Version Tags**: `latest`, `trixie`, `idris2-X.Y.Z` (specific version)

## License

This Docker distribution follows the licensing of its components:
- Idris2: [BSD 3-Clause License](https://github.com/idris-lang/Idris2/blob/main/LICENSE)
- Pack: [BSD 3-Clause License](https://github.com/stefan-hoeck/idris2-pack/blob/main/LICENSE)
- Debian: [Various Open Source Licenses](https://www.debian.org/legal/licenses/)

## Acknowledgments

- The [Idris2 Community](https://www.idris-lang.org/) for the amazing language
- [Stefan Hoeck](https://github.com/stefan-hoeck) for the Pack package manager
- All contributors to the Idris2 ecosystem