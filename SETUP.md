# Setup Instructions for Publishing

## 1. Create GitHub Repo

```bash
cd /home/eirikr/GitHub/idris2-pack-docker
git init
git add .
git commit -m "Initial commit: Idris2 + Pack Docker image"

# Create repo on GitHub, then:
git remote add origin https://github.com/Oichkatzelesfrettschen/idris2-pack-docker.git
git branch -M master
git push -u origin master
```

## 2. Enable GitHub Actions

1. Go to: https://github.com/Oichkatzelesfrettschen/idris2-pack-docker/settings/actions
2. Enable "Read and write permissions"
3. Click "Save"

## 3. Auto-Build Starts

- Push triggers build automatically
- Image publishes to: `ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest`
- Takes ~20 mins first time

## 4. Make Public

1. Go to: https://github.com/users/Oichkatzelesfrettschen/packages/container/idris2-pack-docker/settings
2. Change visibility to "Public"

## 5. Share With Friends

Send them the GitHub repo: https://github.com/Oichkatzelesfrettschen/idris2-pack-docker

Or this quick start:

```bash
# Run directly
docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest

# Or add aliases to ~/.bashrc
alias idris2='docker run --rm -it -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest idris2'
alias pack='docker run --rm -v $(pwd):/workspace ghcr.io/oichkatzelesfrettschen/idris2-pack-docker:latest pack'
```

Done!
