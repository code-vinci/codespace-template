ARG BASE_IMAGE=mcr.microsoft.com/devcontainers/base:ubuntu
FROM ${BASE_IMAGE}

LABEL maintainer="franciuto"

# Keep non-interactive during any incidental package operations (we do not install here).
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV HOME=/home/vscode

# Ensure workspace and devcontainer folder exist, copy setup script but do not execute it.
# Do not run apt installs or the setup script in this Dockerfile.
COPY --chown=1000:1000 .devcontainer/setup.sh /workspaces/.devcontainer/setup.sh
RUN chmod +x /workspaces/.devcontainer/setup.sh || true
RUN mkdir -p /workspaces && chown -R 1000:1000 /workspaces

# Use the standard DevContainer non-root user
USER vscode
WORKDIR /workspaces

# Default command: open a shell. No setup actions performed here.
CMD ["/bin/bash"]