# Advanced Usage Guide

This guide covers advanced features and customizations for power users of the Idris2 Pack Docker image.

## Table of Contents

- [Helper Script Features](#helper-script-features)
- [Building Custom Images](#building-custom-images)
- [Performance Optimization](#performance-optimization)
- [Development Workflows](#development-workflows)
- [CI/CD Integration](#cicd-integration)
- [Multi-Architecture Support](#multi-architecture-support)
- [Security Considerations](#security-considerations)

## Helper Script Features

The included `idris2` helper script provides convenient shortcuts for common operations.

### Installation

```bash
# Download to your project
curl -O https://raw.githubusercontent.com/Oichkatzelesfrettschen/idris2-pack-docker/master/idris2
chmod +x idris2

# Or install system-wide
sudo curl -o /usr/local/bin/idris2-docker https://raw.githubusercontent.com/Oichkatzelesfrettschen/idris2-pack-docker/master/idris2
sudo chmod +x /usr/local/bin/idris2-docker
```

### Advanced Commands

```bash
# Build image locally from Dockerfile
./idris2 build-local

# Pull latest image updates
./idris2 pull

# Run with custom image
IMAGE=my-custom-idris:latest ./idris2 shell

# Pass environment variables
docker run --rm -it -e MY_VAR=value -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

## Building Custom Images

### Extending the Base Image

Create a `Dockerfile` for your project with additional tools:

```dockerfile
FROM ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Install additional development tools
RUN apt-get update && apt-get install -y \
    vim \
    tmux \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install project-specific Pack packages
RUN pack install effects \
    && pack install linear \
    && pack install papers

# Set custom environment variables
ENV EDITOR=vim
ENV IDRIS2_PREFIX=/root/.pack

# Copy project files (optional)
COPY . /workspace

# Set working directory
WORKDIR /workspace

# Build project on image creation (optional)
RUN pack build myproject.ipkg || true
```

Build and use:

```bash
docker build -t my-idris-dev .
docker run --rm -it -v $(pwd):/workspace my-idris-dev
```

### Multi-Stage Builds for Production

Create minimal production images:

```dockerfile
# Build stage
FROM ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest as builder

WORKDIR /build
COPY . .

RUN pack build myapp.ipkg --cg chez
RUN pack exec myapp --dump-ipkg > deps.txt

# Runtime stage
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    chezscheme \
    libgmp10 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/build/exec/myapp /usr/local/bin/
COPY --from=builder /root/.pack/lib /root/.pack/lib

CMD ["myapp"]
```

## Performance Optimization

### Docker Resource Limits

Configure resource limits for better performance:

```bash
# Limit memory and CPU
docker run --rm -it \
    --memory="4g" \
    --cpus="2" \
    -v $(pwd):/workspace \
    ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Use host networking for better performance
docker run --rm -it \
    --network=host \
    -v $(pwd):/workspace \
    ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

### Build Caching

Optimize Pack builds with proper caching:

```bash
# Mount Pack cache as volume for persistence
docker run --rm -it \
    -v $(pwd):/workspace \
    -v idris-pack-cache:/root/.pack \
    ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# List Docker volumes
docker volume ls

# Clean cache if needed
docker volume rm idris-pack-cache
```

### Parallel Builds

Enable parallel compilation:

```bash
# Inside container
export IDRIS2_THREADS=4
pack build myproject.ipkg

# Or set in your .ipkg file
-- myproject.ipkg
opts = "--threads=4"
```

## Development Workflows

### VS Code Integration

Use VS Code with Docker development containers:

1. Install the "Remote - Containers" extension
2. Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "Idris2 Development",
  "image": "ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
  "workspaceFolder": "/workspace",
  "customizations": {
    "vscode": {
      "extensions": [
        "zjhmale.idris",
        "meraymond.idris-vscode"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },
  "postCreateCommand": "pack install-deps myproject.ipkg",
  "remoteUser": "root"
}
```

### Docker Compose for Complex Projects

Create `docker-compose.yml` for multi-container setups:

```yaml
version: '3.8'

services:
  idris:
    image: ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
    volumes:
      - .:/workspace
      - pack-cache:/root/.pack
    working_dir: /workspace
    command: tail -f /dev/null  # Keep container running

  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  pack-cache:
  db-data:
```

Use with:

```bash
# Start services
docker-compose up -d

# Execute commands in Idris container
docker-compose exec idris pack build myproject.ipkg
docker-compose exec idris bash

# Stop services
docker-compose down
```

### Continuous Development with File Watching

Create a watch script for automatic rebuilds:

```bash
#!/bin/bash
# watch.sh
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest bash -c '
apt-get update && apt-get install -y inotify-tools
while true; do
  inotifywait -e modify,create,delete -r /workspace/src
  clear
  pack build myproject.ipkg
done
'
```

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/build.yml`:

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: pack install-deps myproject.ipkg

      - name: Build project
        run: pack build myproject.ipkg

      - name: Run tests
        run: pack test myproject.ipkg

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-output
          path: build/exec/
```

### GitLab CI

Create `.gitlab-ci.yml`:

```yaml
image: ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - pack install-deps myproject.ipkg
    - pack build myproject.ipkg
  artifacts:
    paths:
      - build/

test:
  stage: test
  script:
    - pack test myproject.ipkg

deploy:
  stage: deploy
  script:
    - pack exec myproject --version
  only:
    - main
```

## Multi-Architecture Support

### Building for Multiple Platforms

While the current image supports `linux/amd64`, you can build for other architectures:

```bash
# Enable experimental features
export DOCKER_CLI_EXPERIMENTAL=enabled

# Create builder
docker buildx create --name mybuilder --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t my-idris:multi \
  --push \
  .
```

### Running on ARM (Apple Silicon, Raspberry Pi)

```bash
# Docker will use emulation automatically
docker run --rm -it \
  --platform linux/amd64 \
  -v $(pwd):/workspace \
  ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

## Security Considerations

### Running as Non-Root User

Create a more secure image:

```dockerfile
FROM ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Create non-root user
RUN useradd -m -s /bin/bash idris && \
    chown -R idris:idris /workspace

USER idris
WORKDIR /workspace

# Pack will now install to user directory
ENV PACK_DIR="/home/idris/.pack"
ENV PATH="$PACK_DIR/bin:$PATH"
```

### Scanning for Vulnerabilities

```bash
# Scan image with Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Scan with Docker Scout
docker scout cves ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

### Network Isolation

```bash
# Run without network access
docker run --rm -it \
  --network=none \
  -v $(pwd):/workspace \
  ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Use custom network
docker network create idris-net
docker run --rm -it \
  --network=idris-net \
  -v $(pwd):/workspace \
  ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

## Custom Pack Databases

The custom fork includes `--db-repo` support for alternative package databases:

```bash
# Use custom package database
pack --db-repo https://github.com/myorg/idris2-packages list

# Install from custom database
pack --db-repo https://github.com/myorg/idris2-packages install mypackage

# Set default database in environment
export PACK_DB_REPO="https://github.com/myorg/idris2-packages"
pack list
```

## Environment Variables

Useful environment variables for customization:

```bash
# Run with custom environment
docker run --rm -it \
  -e IDRIS2_PREFIX=/custom/path \
  -e IDRIS2_PACKAGE_PATH=/custom/packages \
  -e IDRIS2_THREADS=4 \
  -e EDITOR=vim \
  -e PACK_DB_REPO=https://github.com/custom/db \
  -v $(pwd):/workspace \
  ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

## Debugging and Profiling

### Enable Debug Output

```bash
# Verbose Pack output
pack --log-level=debug build myproject.ipkg

# Idris2 debugging
export IDRIS2_LOG=5
idris2 --debug-elab-check Main.idr
```

### Performance Profiling

```bash
# Time builds
time pack build myproject.ipkg

# Profile with Linux tools (inside container)
apt-get update && apt-get install -y linux-tools-generic
perf record pack build myproject.ipkg
perf report
```

## Advanced Pack Features

### Custom Build Commands

In your `.ipkg` file:

```idris
-- Custom pre/post build commands
prebuild = "echo Starting build"
postbuild = "echo Build complete"
postinstall = "chmod +x build/exec/myapp"

-- Custom code generators
opts = "--cg node"
```

### Library Development

```bash
# Create a library package
pack new mylib --lib

# Install locally for testing
cd mylib
pack install

# Use in another project
pack --local-install /path/to/mylib install mylib
```

## Tips and Tricks

### Aliases for Common Operations

Add to your shell configuration:

```bash
# Quick REPL
alias idris-repl='docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2'

# Build function
idris-build() {
  docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack build "$@"
}

# Install function
idris-install() {
  docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack install "$@"
}
```

### Quick Testing

```bash
# One-liner to test code
echo 'main : IO (); main = putStrLn "Hello"' | docker run --rm -i ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2 --exec main

# Run a file directly
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2 --exec main Main.idr
```

## Further Resources

- [Pack Documentation](https://github.com/stefan-hoeck/idris2-pack)
- [Idris2 Documentation](https://idris2.readthedocs.io/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Container Security](https://docs.docker.com/engine/security/)