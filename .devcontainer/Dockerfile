# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git nasm build-essential qemu qemu-system qemu-system-common qemu-utils qemu-system-gui xorriso grub2 gdb \
    && curl -L https://ziglang.org/builds/zig-linux-x86_64-0.11.0-dev.524+8796da028.tar.xz -o zig.tar.xz \
    && mkdir -p /usr/src \
    && tar xf zig.tar.xz -C /usr/src \
    && mv /usr/src/zig-linux-x86_64-0.11.0-dev.524+8796da028 /usr/src/zig

ENV PATH /usr/src/zig:$PATH
