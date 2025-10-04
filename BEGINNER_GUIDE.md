# Complete Beginner Guide: Idris2 + Pack in Docker

**For someone with a fresh Ubuntu/Debian machine who just wants Idris2 to work.**

---

## Step 1: Install Docker

On your Ubuntu or Debian machine, open a terminal and run:

```bash
# Update package list
sudo apt update

# Install Docker (this is the easy way - uses your distro's version)
sudo apt install docker.io -y

# Add yourself to the docker group so you don't need sudo
sudo usermod -aG docker $USER

# Log out and log back in (or reboot) for the group change to take effect
# This is IMPORTANT - Docker won't work until you do this!
```

After logging back in, verify Docker works:

```bash
docker --version
```

You should see something like: `Docker version 24.0.7, build...`

---

## Step 2: Get Idris2 + Pack Running

### The One Command That Does Everything:

```bash
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

**Let me explain what each part does:**

- `docker run` - Start a new container
- `--rm` - Delete the container when you exit (keeps things clean)
- `-it` - Interactive terminal (lets you type commands inside)
- `-v $(pwd):/workspace` - **IMPORTANT:** Mount your current directory
  - `$(pwd)` means "print working directory" - your current folder
  - `:/workspace` mounts it inside the container at `/workspace`
  - **Why?** So your Idris files on your computer are accessible inside the container
- `ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest` - The image to run

### What Happens:

1. First time: Docker downloads the image (~1.8GB - takes a few minutes)
2. You get a bash prompt inside the container
3. Your current directory is mounted at `/workspace`
4. You can now use `pack` and `idris2` commands

---

## Step 3: Using It

### Starting the Container:

```bash
# Make a directory for your Idris projects
mkdir ~/idris-projects
cd ~/idris-projects

# Start the Docker container
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

You'll see a prompt like: `root@abc123:/workspace#`

### Inside the Container:

```bash
# Check versions
pack help
idris2 --version

# Install a package (e.g., hedgehog for property testing)
pack install hedgehog

# Start Idris2 REPL
idris2

# Build a project (if you have a .ipkg file)
pack build myproject.ipkg
```

### Important Notes:

1. **Files you create in `/workspace` are saved to your real computer**
   - They persist after you exit the container

2. **Files you create elsewhere in the container are LOST when you exit**
   - Only work in `/workspace` if you want to keep your files!

3. **Pack already includes Idris2** - you don't install them separately

---

## Quick Reference

### Every Time You Want to Use Idris2:

```bash
# 1. Go to your project directory
cd ~/idris-projects

# 2. Start the container
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# 3. Use pack and idris2 commands
# 4. Exit when done (type 'exit' or press Ctrl+D)
```

### Run a Single Command Without Entering the Container:

```bash
# Check version
docker run --rm ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2 --version

# Install a package in your current directory
docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack install hedgehog
```

**Notice:** We removed `-it` because we're not interacting, just running one command.

---

## Common Questions

### Q: Do I need $(pwd)?

**Yes, if you want to access files on your computer!**

- **Without `-v $(pwd):/workspace`:** Container can't see your files
- **With `-v $(pwd):/workspace`:** Your current folder appears inside the container

### Q: Can I skip typing that long command every time?

**Yes! Add this to your `~/.bashrc`:**

```bash
alias idris2-docker='docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest'
```

Then reload: `source ~/.bashrc`

Now just type: `idris2-docker`

### Q: What if I don't have sudo access?

Ask your system admin to:
1. Install Docker
2. Add you to the `docker` group: `sudo usermod -aG docker YOUR_USERNAME`

### Q: This downloads 1.8GB every time?

**No!** Only the first time. Docker caches it locally. Future runs start instantly.

---

## Troubleshooting

### "permission denied" when running docker

**Problem:** You're not in the docker group yet.

**Solution:**
```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

### "Cannot connect to Docker daemon"

**Problem:** Docker service isn't running.

**Solution:**
```bash
sudo systemctl start docker
sudo systemctl enable docker  # Start on boot
```

### My files disappeared!

**Problem:** You created files outside `/workspace` in the container.

**Solution:** Always work in `/workspace` - that's your mounted directory that saves to your real computer.

---

## What You Get

- ✅ Idris2 0.7.0 (latest)
- ✅ Pack package manager (with custom --db-repo feature)
- ✅ Chez Scheme 10.0.0 (Idris backend)
- ✅ All dependencies pre-installed
- ✅ Works the same on any Linux/Mac/Windows with Docker

**No installation conflicts. No dependency hell. Just works.**
