# Idris2 + Pack in Docker

**Idris2 0.7.0 + Pack in a container. Works on any machine.**

## Quick Start (Docker)

```bash
# Interactive shell with your current directory mounted
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Or run commands directly
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2 --version
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack help
```

## What You Get

- ✅ Idris2 0.7.0 (with custom --db-repo feature)
- ✅ Pack package manager
- ✅ Chez Scheme 10.0.0
- ✅ Debian 13 Trixie
- ✅ Works on Windows/Mac/Linux

## Common Commands

```bash
# Start Idris2 REPL
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2

# Install a package
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack install hedgehog

# Build a project
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack build myproject.ipkg
```

## Optional: Convenience Wrapper

For easier usage, download the helper script:

```bash
curl -O https://raw.githubusercontent.com/Oichkatzelesfrettschen/idris2-pack-docker/master/idris2
chmod +x idris2
./idris2 shell              # Interactive shell
./idris2 repl               # Idris2 REPL
./idris2 pack install hedgehog
```

## Requirements

Just Docker Desktop: https://www.docker.com/products/docker-desktop/
