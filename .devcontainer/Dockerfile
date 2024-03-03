# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG ZIG_VERSION="0.12.0-dev.3142+9d500bda2"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git nasm build-essential qemu qemu-system qemu-system-common qemu-utils qemu-system-gui xorriso grub2 gdb

RUN curl -L https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -o zig.tar.xz \
    && mkdir -p /usr/src \
    && tar xf zig.tar.xz -C /usr/src \
    && mv /usr/src/zig-linux-x86_64-${ZIG_VERSION} /usr/src/zig

ENV PATH /usr/src/zig:$PATH
