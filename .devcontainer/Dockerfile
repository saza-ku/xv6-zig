# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG ZIG_VERSION="0.16.0-dev.1859+212968c57"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git nasm build-essential qemu qemu-system qemu-system-common qemu-utils qemu-system-gui xorriso gdb grub-common

RUN curl -L https://ziglang.org/builds/zig-x86_64-linux-${ZIG_VERSION}.tar.xz -o zig.tar.xz \
    && mkdir -p /usr/src \
    && tar xf zig.tar.xz -C /usr/src \
    && mv /usr/src/zig-x86_64-linux-${ZIG_VERSION} /usr/src/zig

ENV PATH /usr/src/zig:$PATH
