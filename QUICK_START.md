# Idris2 + Pack - Quick Start

**One command to get Idris2 working on any Ubuntu/Debian machine.**

---

## Setup (One Time)

```bash
# Install Docker
sudo apt update && sudo apt install docker.io -y

# Add yourself to docker group (no more sudo needed)
sudo usermod -aG docker $USER

# IMPORTANT: Log out and log back in for this to take effect!
```

---

## Usage (Every Time)

```bash
# Go to your project folder
cd ~/my-idris-project

# Start Idris2 + Pack
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

**You're now inside the container!** Use these commands:

```bash
pack install hedgehog      # Install packages
pack build myproject.ipkg  # Build project
idris2                     # Start REPL
idris2 --version           # Check version
exit                       # Leave (or Ctrl+D)
```

---

## What This Does

- **Downloads** Idris2 + Pack in a Docker container (first time only, ~1.8GB)
- **Mounts** your current folder at `/workspace` inside the container
- **Saves** any files you create to your real computer (in your project folder)
- **Works** exactly the same on any machine with Docker

**No local installation. No conflicts. Just works.**

---

## Full Guide

Need more help? Read the [Complete Beginner Guide](BEGINNER_GUIDE.md)

Repository: https://github.com/Oichkatzelesfrettschen/idris2-pack-docker
