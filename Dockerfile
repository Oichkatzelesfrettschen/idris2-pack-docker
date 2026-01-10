#checkov:skip=CKV_DOCKER_3: we intend to use `root` user

# Production Dockerfile for idris2-pack
# Based on Debian 13 (Trixie) - stable as of August 2025
# Provides Idris2 0.8.0 + pack package manager with Chez Scheme 10.0.0

FROM debian:trixie

LABEL org.opencontainers.image.title="idris2-pack"
LABEL org.opencontainers.image.description="Idris2 Package Manager with curated package collections (Debian Trixie)"
LABEL org.opencontainers.image.source="https://github.com/Oichkatzelesfrettschen/idris2-pack"
LABEL org.opencontainers.image.version="0.8.0-custom"
LABEL org.opencontainers.image.authors="Idris2 Community"

SHELL ["/bin/bash", "-c"]

# Install dependencies for Idris2 and pack
# - build-essential: gcc, make, and other build tools
# - chezscheme: Scheme backend for Idris2 (v10.0.0 in Trixie)
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

# Verify installed versions
RUN git --version && chezscheme --version

ENV HOME="/root"
ENV PACK_DIR="$HOME/.pack"
ENV PATH="$PACK_DIR/bin:$PATH"

# Set working directory
WORKDIR /workspace

# Install pack using the installation script from our fork
# This bootstraps Idris2 and builds pack from source with custom db-repo feature
RUN bash -c 'curl -fsSL https://raw.githubusercontent.com/Oichkatzelesfrettschen/idris2-pack/main/install.bash > /tmp/install.bash && \
    chmod +x /tmp/install.bash && \
    echo "chezscheme" | bash /tmp/install.bash && \
    rm /tmp/install.bash'

# Verify installations
RUN pack help > /dev/null 2>&1 && echo "Pack installed successfully"
RUN idris2 --version

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pack help || exit 1

CMD ["/bin/bash"]
