# Idris2 + Pack in Docker

**One-command Idris2 setup. Works on any machine.**

## Quick Start

```bash
curl -O https://raw.githubusercontent.com/eirikr/idris2-pack-docker/main/idris2
chmod +x idris2
./idris2 shell
```

## What You Get

- ✅ Idris2 0.7.0
- ✅ Pack package manager
- ✅ Chez Scheme 10.0.0
- ✅ Debian 13 Trixie
- ✅ Works on Windows/Mac/Linux

## Usage

```bash
./idris2 shell              # Interactive shell
./idris2 repl               # Idris2 REPL
./idris2 pack install hedgehog
./idris2 build project.ipkg
```

## Or Raw Docker

```bash
docker pull ghcr.io/eirikr/idris2-pack-docker:latest
docker run --rm -it -v $(pwd):/workspace ghcr.io/eirikr/idris2-pack-docker:latest
```

## Requirements

Just Docker Desktop: https://www.docker.com/products/docker-desktop/
