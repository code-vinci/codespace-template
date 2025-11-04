# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Metadata
LABEL org.opencontainers.image.title="CodeVinci GitHub Codespace Template"
LABEL org.opencontainers.image.description="CodeVinci development environment with security and CTF tools"
LABEL maintainer="code-vinci"

# Environment configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV TOOLS_DIR=/home/vscode/tools
ENV PATH="${TOOLS_DIR}/john/run:${PATH}"

# Switch to root for installation
USER root

# Copy setup scripts (context: .devcontainer)
COPY --chown=root:root setup.sh setup-advanced.sh setup-fallback.sh /tmp/

# Ensure scripts are executable
RUN chmod +x /tmp/setup*.sh

# Execute main setup script; fallback on warning if partial failure
RUN bash /tmp/setup-advanced.sh || echo "[WARN] setup-advanced.sh completed with warnings"

# Remove temporary installation scripts after setup
RUN rm -f /tmp/setup*.sh

# Retain setup scripts for later manual use/reference
COPY --chown=vscode:vscode setup.sh setup-advanced.sh setup-fallback.sh /home/vscode/.devcontainer/

# Ensure ownership and prepare workspace directory
RUN mkdir -p /workspaces && chown -R vscode:vscode /home/vscode /workspaces

# Expose useful ports
EXPOSE 8080 3000 5000

# Default to non-root user for dev session
USER vscode

# Default shell
WORKDIR /workspaces
CMD ["/bin/bash"]
