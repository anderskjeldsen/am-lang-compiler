# Based on https://github.com/sebastianbergmann/container-amiga-gcc
# Multi-stage Dockerfile with complete Amiga GCC toolchain including AmiSSL

# Base stage with dependencies
FROM ubuntu:24.04 AS base

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
    autoconf \
    bison \
    flex \
    g++ \
    gcc \
    gettext \
    git \
    lhasa \
    libgmpxx4ldbl \
    libgmp-dev \
    libmpfr6 \
    libmpfr-dev \
    libmpc3 \
    libmpc-dev \
    libncurses-dev \
    make \
    rsync \
    texinfo \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Build stage - Core toolchain with AHI/CGX SDK support
FROM base AS toolchain

# Clone the amiga-gcc repository from GitHub
RUN git config --global pull.rebase false && \
    cd /root && \
    git clone --depth 1 https://github.com/anderskjeldsen/m68k-amigaos-gcc amiga-gcc --branch master

# Build core toolchain and install SDKs
RUN cd /root/amiga-gcc && \
    mkdir -p /opt/amiga && \
    make update && \
    make binutils && \
    make gcc && \
    make sfdc && \
    make fd2sfd && \
    ./sdk/install install ahi /opt/amiga && \
    ./sdk/install install cgx /opt/amiga

# Complete toolchain build
RUN cd /root/amiga-gcc && \
    make -j4 all

# Final stage - Add additional libraries (zlib, libpng, amissl)
FROM toolchain AS final

# Build additional libraries
RUN cd /root/amiga-gcc && \
    make zlib && \
    make libpng && \
    make amissl

# Cleanup build directory to reduce image size
RUN cd / && \
    rm -rf /root/amiga-gcc && \
    apt-get purge -y \
    autoconf \
    bison \
    flex \
    g++ \
    gcc \
    gettext \
    git \
    lhasa \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    libncurses-dev \
    rsync \
    texinfo \
    wget \
    && apt-get -y autoremove \
    && apt-get clean

ENV PATH=/opt/amiga/bin:$PATH

WORKDIR /workspace

CMD ["/bin/bash"]
