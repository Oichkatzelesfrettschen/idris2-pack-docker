#checkov:skip=CKV_DOCKER_3: we intend to use `root` user

# Production Dockerfile for idris2-pack
# Based on Debian 13 (Trixie) - stable as of August 2025
# Provides Idris2 + pack package manager with Chez Scheme
# Version is automatically detected from the installed Idris2

FROM debian:trixie

# Build argument for version tagging (passed via CI from GitHub releases API)
# Note: This only sets the image label/tag. The actual Idris2 version installed
# is determined by the pack installation script, which installs the latest
# compatible version. The CI workflow verifies that these versions match.
ARG IDRIS2_VERSION=latest

LABEL org.opencontainers.image.title="idris2-pack"
LABEL org.opencontainers.image.description="Idris2 Package Manager with curated package collections (Debian Trixie)"
LABEL org.opencontainers.image.source="https://github.com/Oichkatzelesfrettschen/idris2-pack"
LABEL org.opencontainers.image.version="${IDRIS2_VERSION}"
LABEL org.opencontainers.image.authors="Idris2 Community"

SHELL ["/bin/bash", "-c"]

# Install dependencies for Idris2 and pack
# - build-essential: gcc, make, and other build tools
# - chezscheme: Scheme backend for Idris2
# - libgmp-dev: GMP library for arbitrary precision arithmetic
# - git: for fetching package repositories (>= 2.35.1 required)
# - ca-certificates/curl: for HTTPS downloads
RUN apt-get update && apt-get install --yes --no-install-recommends \
    build-essential \
    chezscheme \
    libgmp-dev \
    git \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for scheme executable (Debian installs it as 'chezscheme' but pack expects 'scheme')
RUN ln -sf /usr/bin/chezscheme /usr/bin/scheme

# Verify installed versions
RUN git --version && chezscheme --version && scheme --version

ENV HOME="/root"
# XDG directories used by pack (these are the defaults, set explicitly for clarity)
ENV XDG_CONFIG_HOME="$HOME/.config"
ENV XDG_STATE_HOME="$HOME/.local/state"
ENV XDG_CACHE_HOME="$HOME/.cache"
# Pack installs binaries to ~/.local/bin
ENV PATH="$HOME/.local/bin:$PATH"

# Set working directory
WORKDIR /workspace

# Install pack using the upstream installation script
# This bootstraps Idris2 and builds pack from source
# The installation script uses XDG directories: binaries go to ~/.local/bin
RUN bash -c 'curl -fsSL https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash > /tmp/install.bash && \
    chmod +x /tmp/install.bash && \
    echo "scheme" | bash /tmp/install.bash && \
    rm /tmp/install.bash'

# Debug: Show pack installation structure
RUN echo "Pack bin directory contents:" && ls -la $HOME/.local/bin/ && \
    echo "Pack state directory:" && ls -la $XDG_STATE_HOME/pack/ 2>/dev/null || echo "State directory not found" && \
    echo "Pack bin/idris2 content:" && cat $HOME/.local/bin/idris2 || true

# Verify installations and capture version info
RUN pack help > /dev/null 2>&1 && echo "Pack installed successfully"
RUN bash -c 'idris2 --version'

# Store version information for runtime queries
RUN echo "IDRIS2_VERSION=$(idris2 --version | head -1 | sed 's/Idris 2, version //')" > /etc/idris2-version && \
    echo "CHEZ_VERSION=$(chezscheme --version 2>&1)" >> /etc/idris2-version && \
    cat /etc/idris2-version

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pack help || exit 1

CMD ["/bin/bash"]
