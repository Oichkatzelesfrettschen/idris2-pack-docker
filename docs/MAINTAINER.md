# Maintainer Guide

This guide is for repository maintainers and covers the setup, release process, and maintenance of the Idris2 Pack Docker image.

## Table of Contents

- [Repository Setup](#repository-setup)
- [GitHub Actions Configuration](#github-actions-configuration)
- [Release Process](#release-process)
- [Updating Dependencies](#updating-dependencies)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting Builds](#troubleshooting-builds)

## Repository Setup

### Initial Repository Creation

1. **Create GitHub Repository:**
   ```bash
   cd /home/eirikr/GitHub/idris2-pack-docker
   git init
   git add .
   git commit -m "Initial commit: Idris2 + Pack Docker image"

   # Create repository on GitHub through web interface
   # Then add remote:
   git remote add origin https://github.com/Oichkatzelesfrettschen/idris2-pack-docker.git
   git branch -M master
   git push -u origin master
   ```

2. **Repository Settings:**
   - Go to Settings → General
   - Set default branch to `master`
   - Enable Issues and Discussions (optional)

## GitHub Actions Configuration

### Enable GitHub Actions

1. Navigate to: `https://github.com/Oichkatzelesfrettschen/idris2-pack-docker/settings/actions`
2. Under "Actions permissions", select "Allow all actions and reusable workflows"
3. Under "Workflow permissions", select "Read and write permissions"
4. Check "Allow GitHub Actions to create and approve pull requests" (optional)
5. Click "Save"

### Configure Package Registry

1. Go to: `https://github.com/users/Oichkatzelesfrettschen/packages/container/idris2-pack-docker/settings`
2. Set visibility to "Public" for open source distribution
3. Add repository link if not automatically linked
4. Configure retention policies if needed

### Workflow File Structure

The `.github/workflows/docker-publish.yml` handles:
- Automatic builds on push to master
- Tag-based versioning
- Multi-platform support (currently linux/amd64)
- Automatic testing after build
- Publishing to GitHub Container Registry

## Release Process

### Automated Versioning

The Docker image version is **automatically detected** from the official Idris2 GitHub releases. The CI/CD workflow:

1. Fetches the latest Idris2 version from `https://api.github.com/repos/idris-lang/Idris2/releases/latest`
2. Passes this version as a build argument to Docker
3. Tags the image with version-specific tags (e.g., `idris2-0.8.0`, `idris2-0.8`)
4. Verifies the installed version matches the expected version

**Weekly scheduled builds** (Sunday at midnight UTC) automatically check for new Idris2 releases and rebuild the image if needed.

### Versioning Strategy

The image version aligns with Idris2 releases:

```bash
# Available tags after each build:
latest              # Most recent successful build
trixie              # Debian base reference
idris2-X.Y.Z        # Specific Idris2 version (e.g., idris2-0.8.0)
idris2-X.Y          # Minor version series (e.g., idris2-0.8)
```

### Manual Release (Optional)

For custom releases or hotfixes, you can still create manual tags:

1. **Commit and Tag:**
   ```bash
   git add .
   git commit -m "Release v0.8.0-hotfix: Description"
   git tag -a v0.8.0-hotfix -m "Release v0.8.0-hotfix: Description"
   git push origin master
   git push origin v0.8.0-hotfix
   ```

2. **Create GitHub Release:**
   - Go to Releases → "Create a new release"
   - Choose the tag
   - Title: "v0.8.0-hotfix: Description"
   - Generate release notes
   - Publish release

3. **Monitor Build:**
   - Check Actions tab for build progress
   - Verify image is published to registry
   - Test the new image:
     ```bash
     docker pull ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:v0.8.0-hotfix
     docker run --rm ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:v0.8.0-hotfix idris2 --version
     ```

## Updating Dependencies

### Updating Idris2/Pack Version

1. **Check for New Releases:**
   ```bash
   # Check Idris2 releases
   curl -s https://api.github.com/repos/idris-lang/Idris2/releases/latest | jq .tag_name

   # Check Pack fork updates
   curl -s https://api.github.com/repos/Oichkatzelesfrettschen/idris2-pack/releases/latest | jq .tag_name
   ```

2. **Update Installation Script:**
   The Dockerfile pulls Pack's installation script from the fork:
   ```dockerfile
   RUN bash -c 'curl -fsSL https://raw.githubusercontent.com/Oichkatzelesfrettschen/idris2-pack/main/install.bash > /tmp/install.bash && \
       chmod +x /tmp/install.bash && \
       echo "chezscheme" | bash /tmp/install.bash && \
       rm /tmp/install.bash'
   ```

3. **Test Locally:**
   ```bash
   docker build -t idris2-pack:test .
   docker run --rm idris2-pack:test idris2 --version
   docker run --rm idris2-pack:test pack help
   ```

### Updating Base Image

1. **Check Debian Updates:**
   ```bash
   docker pull debian:trixie
   docker run --rm debian:trixie cat /etc/debian_version
   ```

2. **Update Dockerfile if needed:**
   ```dockerfile
   FROM debian:trixie  # or specific version like debian:13.1
   ```

3. **Security Scanning:**
   ```bash
   # Scan for vulnerabilities
   docker scout cves idris2-pack:test
   trivy image idris2-pack:test
   ```

## Monitoring and Maintenance

### Regular Tasks

**Weekly:**
- Check for security advisories
- Monitor GitHub Issues
- Review dependency updates

**Monthly:**
- Update base image if patches available
- Review and merge PRs
- Update documentation as needed

**Per Release:**
- Full testing suite
- Update changelog
- Announce in relevant communities

### Monitoring Build Status

1. **GitHub Actions Dashboard:**
   - Check: `https://github.com/Oichkatzelesfrettschen/idris2-pack-docker/actions`
   - Monitor build times and failures
   - Review logs for warnings

2. **Container Registry Metrics:**
   - View package statistics at GitHub Packages
   - Monitor download counts
   - Check image sizes

### Health Checks

Test the published image regularly:

```bash
#!/bin/bash
# health-check.sh

IMAGE="ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest"

echo "Pulling latest image..."
docker pull $IMAGE

echo "Testing Idris2..."
docker run --rm $IMAGE idris2 --version || exit 1

echo "Testing Pack..."
docker run --rm $IMAGE pack help || exit 1

echo "Testing compilation..."
docker run --rm $IMAGE bash -c 'echo "main : IO (); main = putStrLn \"OK\"" > test.idr && idris2 test.idr -o test && ./build/exec/test' || exit 1

echo "All tests passed!"
```

## Troubleshooting Builds

### Common Build Issues

#### Network Timeouts

**Problem:** Installation script fails to download

**Solution:** Add retry logic:
```dockerfile
RUN for i in {1..3}; do \
      curl -fsSL https://raw.githubusercontent.com/... && break || sleep 10; \
    done
```

#### Package Conflicts

**Problem:** Debian package conflicts during update

**Solution:** Use specific versions:
```dockerfile
RUN apt-get update && apt-get install -y \
    package=version \
    another-package=version
```

#### Build Cache Issues

**Problem:** Old layers causing problems

**Solution:** Clear cache:
```bash
docker builder prune -af
docker build --no-cache -t idris2-pack:test .
```

### Debugging Failed Builds

1. **Interactive Debugging:**
   ```bash
   # Build up to failing step
   docker build -t debug --target=builder .

   # Run interactively
   docker run --rm -it debug bash

   # Manually run failing commands
   ```

2. **Build Logs:**
   ```bash
   # Verbose output
   docker build --progress=plain -t test .

   # Save logs
   docker build -t test . 2>&1 | tee build.log
   ```

3. **Layer Inspection:**
   ```bash
   docker history idris2-pack:test
   docker inspect idris2-pack:test
   ```

## Advanced Maintenance

### Multi-Architecture Support

To add ARM64 support:

1. **Update Workflow:**
   ```yaml
   # In .github/workflows/docker-publish.yml
   platforms: linux/amd64,linux/arm64
   ```

2. **Test Locally:**
   ```bash
   docker buildx create --name multiarch --use
   docker buildx build --platform linux/amd64,linux/arm64 -t test .
   ```

### Custom Pack Fork Maintenance

If maintaining the Pack fork:

1. **Sync with Upstream:**
   ```bash
   git remote add upstream https://github.com/stefan-hoeck/idris2-pack.git
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Apply Custom Patches:**
   ```bash
   git cherry-pick <commit-hash>  # For --db-repo feature
   ```

3. **Test Integration:**
   ```bash
   # Test installation script
   bash install.bash
   ```

### Security Policies

1. **Dependency Updates:**
   - Enable Dependabot for automatic updates
   - Review and test all updates before merging

2. **Vulnerability Response:**
   - Address critical vulnerabilities within 24 hours
   - Document fixes in release notes
   - Consider backporting to older versions if needed

3. **Access Control:**
   - Limit write access to trusted maintainers
   - Use branch protection rules
   - Require PR reviews for master branch

## Documentation Maintenance

### Keeping Docs Current

1. **Version Updates:**
   - Update version numbers in all documentation
   - Update feature lists when adding capabilities
   - Keep examples working with latest version

2. **User Feedback:**
   - Monitor issues for documentation problems
   - Add FAQ entries for common questions
   - Improve troubleshooting based on user reports

3. **Testing Documentation:**
   ```bash
   # Test all command examples
   grep -h '```bash' docs/*.md | grep -v '```' | bash -x
   ```

## Communication

### Release Announcements

Post updates to:
- GitHub Releases page
- Idris2 Discord server
- Relevant forums and communities
- Project README.md

### Template for Release Notes

```markdown
## v0.8.0: Idris2 0.8.0 with Pack

### What's New
- Updated to Idris2 0.8.0
- Pack includes latest package database
- Debian 13 base for improved security
- Custom --db-repo feature for alternative package sources

### Docker Images
- `ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest`
- `ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:v0.8.0`
- `ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:trixie`

### Quick Start
\```bash
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest
\```

### Changes
- Updated Idris2 from 0.7.0 to 0.8.0
- Updated Pack to latest commit
- Fixed issue with...
- Improved documentation for...

### Contributors
Thanks to everyone who contributed to this release!
```

## Useful Commands Reference

```bash
# Force rebuild without cache
docker build --no-cache -t test .

# Build with specific platform
docker build --platform linux/amd64 -t test .

# Export image for offline use
docker save ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest | gzip > idris2-pack-docker.tar.gz

# Import saved image
docker load < idris2-pack-docker.tar.gz

# Clean up everything
docker system prune -af

# Check image details
docker inspect ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest | jq '.[0].Config'
```