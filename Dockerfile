# Dockerfile - Physics & Scientific Computing Development Environment
# Description: Multistage build for C and Python physics/math/stats work.
#              Designed for use with VS Code Dev Containers on Mac and Linux.
# Base: Debian Trixie (testing) - ships GCC 14, up-to-date physics libs.

##########################################################################
#                           Stage 1: Build Stage
##########################################################################
# Base: Debian Trixie Slim
# - Installs Miniforge3 and builds the Conda environment.
# - Only the /opt/conda tree is carried into the runtime stage.
#
# Build variants:
#   lean (default) : core physics/math stack  - ~2.5 GB
#   full           : complete package list     - ~4.5 GB
#
# Usage:
#   docker compose build                          # lean (default)
#   docker compose build --build-arg BUILD=full   # full

FROM debian:trixie-slim AS build

# Build variant - lean or full
ARG BUILD=lean

# Minimal tools needed to bootstrap conda
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        git \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniforge3 (replaces the deprecated Mambaforge)
ENV MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
RUN wget "${MINIFORGE_URL}/Miniforge3-Linux-$(uname -m).sh" -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh

ENV PATH=/opt/conda/bin:$PATH
ENV CONDA_PREFIX=/opt/conda

# Bootstrap: update conda/mamba and pin solver
RUN conda config --set always_yes yes && \
    conda update -n base conda && \
    conda install -n base -c conda-forge mamba

# Copy environment files
COPY environment.lean.yml /tmp/environment.lean.yml
COPY environment.full.yml /tmp/environment.full.yml

# Create the physicsbox conda environment from selected variant
RUN mamba env create -f /tmp/environment.${BUILD}.yml && \
    mamba clean -a -y && \
    rm -rf ${CONDA_PREFIX}/pkgs/*

# Group-writable so the runtime user can use it
RUN chmod -R g+rwx ${CONDA_PREFIX}

##########################################################################
#                          Stage 2: Runtime Stage
##########################################################################
# Base: Debian Trixie Slim
# - Adds C toolchain and physics system libraries.
# - Copies the conda tree from the build stage.
# - Runs as root at container start (entrypoint drops to 'dev').

FROM debian:trixie-slim AS runtime

# System packages - grouped by purpose for readability
# (no inline comments inside the apt block - they break the shell command)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        pkg-config \
        git \
        libgsl-dev \
        libfftw3-dev \
        libhdf5-dev \
        libssl-dev \
        liblapack-dev \
        libblas-dev \
        libbz2-1.0 \
        libncurses6 \
        libpng16-16 \
        libzstd1 \
        zlib1g \
        sqlite3 \
        openssl \
        ca-certificates \
        readline-common \
        bash \
        zsh \
        vim \
        sudo \
        curl \
        wget \
        rsync \
        tar \
        bzip2 \
        htop \
        stow \
        eza \
        bat \
        gnuplot \
        gnuplot-x11 \
        texlive-font-utils \
        ghostscript \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxt6 \
        libgl1 \
        locales \
        perl \
        ncurses-bin \
        trash-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en   
ENV LC_ALL en_US.UTF-8

# Create wheel group and dev user
# USER stays root so the entrypoint can handle dynamic UID remapping.
RUN groupadd wheel && \
    useradd -ms /bin/bash dev && \
    usermod -aG sudo dev && \
    usermod -aG wheel dev && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Copy conda from build stage
COPY --from=build --chown=root:wheel /opt/conda /opt/conda

# Copy entrypoint, bashrc and vimrc
COPY entrypoint.sh /opt/entrypoint.sh
COPY .bashrc /etc/physicsbox/bashrc
COPY .vimrc /etc/physicsbox/vimrc
RUN chmod +x /opt/entrypoint.sh

# Create shared directories (ownership set at runtime by entrypoint)
RUN mkdir -p /shared /workspace

ENV PATH=/opt/conda/bin:$PATH
ENV CONDA_PREFIX=/opt/conda

# Expose Jupyter and code-server ports
EXPOSE 8888 8080

WORKDIR /home/dev

# Root at startup - entrypoint handles UID fix then drops to dev
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]
