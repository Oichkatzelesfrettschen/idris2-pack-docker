# Idris2 + Pack in Docker

**Idris2 0.7.0 + Pack in a container. Works on any machine.**

📘 **New to Docker?** Read the [Complete Beginner Guide](BEGINNER_GUIDE.md) for step-by-step instructions.

## Quick Start

```bash
# Start interactive shell (your current directory is mounted at /workspace inside)
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Inside the container, you can use:
#   pack install <package>
#   pack build myproject.ipkg
#   idris2 (starts REPL)
#   idris2 --version
```

## What You Get

- ✅ **Pack package manager** (includes Idris2 0.7.0 + custom --db-repo feature)
- ✅ **Chez Scheme 10.0.0** (Idris backend)
- ✅ **Debian 13 Trixie** (latest stable, August 2025)
- ✅ **All dependencies pre-installed** - no setup needed
- ✅ **Works on any OS** with Docker (Windows/Mac/Linux)

**Note:** Pack is the package manager that includes Idris2. You don't install them separately.

## Typical Workflow

```bash
# 1. Create a project directory on your computer
mkdir ~/my-idris-project
cd ~/my-idris-project

# 2. Start the Docker container (mounts your current directory)
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# 3. Inside the container:
pack install hedgehog      # Install packages
idris2                     # Start REPL
pack build myproject.ipkg  # Build your project

# 4. Exit when done (Ctrl+D or type 'exit')
# Your files are saved on your computer in ~/my-idris-project
```

## Why `$(pwd)` Matters

**`-v $(pwd):/workspace`** mounts your current directory inside the container.

- **With this:** Files you create persist on your computer ✅
- **Without this:** Container can't see your files, nothing is saved ❌

**Always run the command from your project directory!**

## Convenience: Make a Short Alias

Add to `~/.bashrc`:

```bash
alias idris2-docker='docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest'
```

Then: `idris2-docker` instead of typing the whole command.

## Requirements

Just Docker Desktop: https://www.docker.com/products/docker-desktop/
