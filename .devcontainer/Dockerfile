# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG ZIG_VERSION="0.16.0-dev.1859+212968c57"
ARG TARGETARCH

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends git nasm build-essential qemu qemu-system qemu-system-common qemu-utils qemu-system-gui xorriso gdb grub-common binutils-i686-linux-gnu

RUN if [ "$TARGETARCH" = "amd64" ]; then \
      ZIG_ARCH=x86_64; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      ZIG_ARCH=aarch64; \
    else \
      echo "Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    echo "ZIG_ARCH=$ZIG_ARCH" > /tmp/zig_arch.sh

RUN . /tmp/zig_arch.sh && \
    curl -L https://ziglang.org/builds/zig-${ZIG_ARCH}-linux-${ZIG_VERSION}.tar.xz -o zig.tar.xz && \
    mkdir -p /usr/src && \
    tar xf zig.tar.xz -C /usr/src && \
    mv /usr/src/zig-${ZIG_ARCH}-linux-${ZIG_VERSION} /usr/src/zig && \
    rm -f zig.tar.xz /tmp/zig_arch.sh

ENV PATH /usr/src/zig:$PATH
