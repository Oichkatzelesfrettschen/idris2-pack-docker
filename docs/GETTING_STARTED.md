# Getting Started with Idris2 Pack Docker

This guide provides detailed instructions for setting up and using the Idris2 Pack Docker image, designed for users who may be new to Docker or Idris2.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installing Docker](#installing-docker)
- [First Run](#first-run)
- [Understanding the Container](#understanding-the-container)
- [Working with Projects](#working-with-projects)
- [Package Management](#package-management)
- [Troubleshooting](#troubleshooting)
- [FAQ](#frequently-asked-questions)

## Prerequisites

Before you begin, you'll need:

- A computer running Linux, macOS, or Windows
- Administrative privileges to install software
- At least 2GB of free disk space for the Docker image
- An internet connection for downloading the image

## Installing Docker

### Linux (Ubuntu/Debian)

The easiest method for Debian-based systems:

```bash
# Update package list
sudo apt update

# Install Docker from your distribution's repository
sudo apt install docker.io -y

# Add your user to the docker group (avoids needing sudo)
sudo usermod -aG docker $USER

# IMPORTANT: Log out and log back in for group changes to take effect
```

After logging back in, verify the installation:

```bash
docker --version
# Should output: Docker version 24.x.x, build...

# Test Docker is working
docker run hello-world
```

#### Alternative: Docker CE (Community Edition)

For the latest Docker features, install Docker CE:

```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install prerequisites
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add yourself to docker group
sudo usermod -aG docker $USER
```

### macOS and Windows

Download and install Docker Desktop from the official website:

1. Visit [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Download the installer for your operating system
3. Run the installer and follow the instructions
4. Start Docker Desktop from your Applications folder (macOS) or Start Menu (Windows)
5. Wait for Docker to start (the whale icon in your system tray should be steady)

## First Run

### Understanding the Docker Command

The complete Docker command to run Idris2 Pack is:

```bash
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

Let's break down each part:

- `docker run` - Creates and starts a new container
- `--rm` - Removes the container after you exit (keeps your system clean)
- `-it` - Enables interactive terminal (you can type commands)
- `-v $(pwd):/workspace` - **Critical**: Mounts your current directory
  - `$(pwd)` - Your current directory path
  - `:/workspace` - Where it appears inside the container
- `ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest` - The image to use

### Your First Session

1. **Create a workspace directory:**
   ```bash
   mkdir ~/idris-projects
   cd ~/idris-projects
   ```

2. **Start the container:**
   ```bash
   docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
   ```

3. **First time behavior:**
   - Docker will download the image (~1.8GB)
   - This only happens once; future runs use the cached image
   - You'll see progress bars during the download

4. **Inside the container:**
   You'll see a prompt like `root@abc123:/workspace#`

   Try these commands:
   ```bash
   # Check Idris2 version
   idris2 --version

   # Check Pack help
   pack help

   # List files (should show your host directory contents)
   ls

   # Exit the container
   exit
   ```

## Understanding the Container

### File Persistence

The volume mount `-v $(pwd):/workspace` is crucial:

**With volume mount:**
- Files in `/workspace` persist on your host machine
- You can edit files with your favorite editor outside Docker
- Changes are immediately visible inside the container

**Without volume mount:**
- Container is isolated from your files
- Nothing you create will be saved
- Useful only for testing, not development

### Working Directory

Always work in `/workspace` inside the container:

```bash
# Good - files are saved
cd /workspace
echo "module Main" > Test.idr

# Bad - files are lost when container exits
cd /root
echo "module Main" > Test.idr  # This file will disappear!
```

## Working with Projects

### Creating a New Project

1. **On your host machine:**
   ```bash
   mkdir ~/idris-projects/my-game
   cd ~/idris-projects/my-game
   ```

2. **Start the container:**
   ```bash
   docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
   ```

3. **Inside the container:**
   ```bash
   # Create a new Pack project
   pack new my-game
   cd my-game

   # Build the project
   pack build my-game.ipkg

   # Run the executable
   pack exec my-game
   ```

### Working with Existing Projects

1. **Navigate to your project:**
   ```bash
   cd ~/existing-idris-project
   ```

2. **Start the container:**
   ```bash
   docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
   ```

3. **Build and run:**
   ```bash
   pack build project.ipkg
   pack exec project
   ```

## Package Management

Pack is the package manager that comes with Idris2. It manages dependencies and builds.

### Installing Packages

```bash
# Search for packages
pack search json

# Install a specific package
pack install hedgehog

# Install from a custom database
pack --db-repo https://github.com/your-repo/database install custom-package
```

### Creating a Package File

Create a `.ipkg` file for your project:

```idris
-- my-project.ipkg
package my-project
version = 0.1.0

authors = "Your Name"
maintainers = "Your Name"

depends = base >= 0.6.0,
          contrib >= 0.6.0,
          hedgehog

modules = Main,
          MyProject.Utils

main = Main

executable = my-project
```

## Troubleshooting

### Docker Issues

#### "permission denied" Error

**Problem:** Cannot run Docker commands without sudo

**Solution:**
```bash
# Add yourself to docker group
sudo usermod -aG docker $USER

# You MUST log out and back in
# Or restart your system
```

#### "Cannot connect to Docker daemon"

**Problem:** Docker service is not running

**Solution:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

### Container Issues

#### Files Not Persisting

**Problem:** Your work disappears after exiting the container

**Causes and Solutions:**

1. **Missing volume mount:**
   ```bash
   # Wrong - no volume mount
   docker run --rm -it ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

   # Correct - with volume mount
   docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
   ```

2. **Working in wrong directory:**
   ```bash
   # Inside container
   pwd  # Should show /workspace
   # If not, cd /workspace
   ```

3. **Running from wrong host directory:**
   ```bash
   # On host, before starting container
   pwd  # Should be your project directory
   ```

#### "No such file or directory" Errors

**Problem:** Container can't find your files

**Solution:** Ensure you're mounting the correct directory:
```bash
# Check where you are on the host
pwd
ls  # Should show your project files

# Then start container
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Inside container
cd /workspace
ls  # Should show the same files
```

### Idris2/Pack Issues

#### Package Installation Fails

**Problem:** `pack install` fails with network errors

**Solutions:**

1. **Check internet connection:**
   ```bash
   # Inside container
   ping github.com
   ```

2. **Try updating pack's database:**
   ```bash
   pack update
   ```

3. **Clear pack's cache:**
   ```bash
   rm -rf ~/.pack/cache
   pack update
   ```

#### Build Errors

**Problem:** Project won't build

**Common solutions:**

1. **Check dependencies in .ipkg file**
2. **Ensure all source files are in the correct location**
3. **Try a clean build:**
   ```bash
   pack clean
   pack build project.ipkg
   ```

## Frequently Asked Questions

### Q: Why do I need Docker instead of installing Idris2 directly?

**A:** Docker provides:
- Consistent environment across all platforms
- No dependency conflicts with your system
- Easy updates and version management
- Isolation from your system packages
- Identical behavior for all team members

### Q: How much disk space does this use?

**A:** The Docker image is approximately 1.8GB. Your project files use additional space as normal.

### Q: Can I use my favorite text editor?

**A:** Yes! Edit files on your host machine as usual. The container sees changes immediately through the volume mount.

### Q: How do I update to a newer version?

**A:** Pull the latest image:
```bash
docker pull ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

### Q: Can I install additional tools in the container?

**A:** Yes, but they won't persist. For permanent tools, create a custom Dockerfile:
```dockerfile
FROM ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
RUN apt-get update && apt-get install -y vim emacs
```

### Q: Is this suitable for production?

**A:** This image is great for development. For production deployments, consider:
- Creating a minimal image with just your compiled application
- Using multi-stage builds to reduce image size
- Implementing proper security practices

### Q: How do I share my environment with teammates?

**A:** Share this Docker image! Everyone gets the exact same environment:
```bash
# They just need to run:
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
```

## Next Steps

Now that you're comfortable with the basics:

1. Explore the [Pack documentation](https://github.com/stefan-hoeck/idris2-pack)
2. Try the [Idris2 tutorial](https://idris2.readthedocs.io/)
3. Check out [Advanced Usage](ADVANCED_USAGE.md) for power user features
4. Join the [Idris community](https://www.idris-lang.org/community.html)

## Getting Help

- **Docker issues:** Check Docker's [official documentation](https://docs.docker.com/)
- **Idris2 questions:** Visit the [Idris2 Discord](https://discord.gg/idris2)
- **Pack problems:** See the [Pack repository](https://github.com/stefan-hoeck/idris2-pack)
- **This image:** Open an issue on [GitHub](https://github.com/Oichkatzelesfrettschen/idris2-pack-docker)