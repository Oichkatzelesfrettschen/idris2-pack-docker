# Setup Instructions for Publishing

## 1. Create GitHub Repo

```bash
cd /home/eirikr/GitHub/idris2-pack-docker
git init
git add .
git commit -m "Initial commit: Idris2 + Pack Docker image"

# Create repo on GitHub, then:
git remote add origin https://github.com/eirikr/idris2-pack-docker.git
git branch -M main
git push -u origin main
```

## 2. Enable GitHub Actions

1. Go to: https://github.com/eirikr/idris2-pack-docker/settings/actions
2. Enable "Read and write permissions"
3. Click "Save"

## 3. Auto-Build Starts

- Push triggers build automatically
- Image publishes to: `ghcr.io/eirikr/idris2-pack-docker:latest`
- Takes ~20 mins first time

## 4. Make Public

1. Go to: https://github.com/users/eirikr/packages/container/idris2-pack-docker/settings
2. Change visibility to "Public"

## 5. Share With Friends

Send them this:

```bash
curl -O https://raw.githubusercontent.com/eirikr/idris2-pack-docker/main/idris2
chmod +x idris2
./idris2 shell
```

Done!
