FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Metadata labels
LABEL org.opencontainers.image.title="Cybersecurity and CTF Tools Codespace"
LABEL org.opencontainers.image.description="Pre-built cybersecurity lab environment with pentesting and CTF tools"
LABEL maintainer="code-vinci"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TOOLS_DIR=/home/vscode/tools
ENV PATH="${TOOLS_DIR}/john/run:${PATH}"

# Switch to root for installation
USER root

# Copy setup scripts into the container
COPY --chown=root:root setup.sh setup-advanced.sh setup-fallback.sh /tmp/

# Make scripts executable
RUN chmod +x /tmp/setup*.sh

# Run the advanced setup script (it handles all installations)
RUN bash /tmp/setup-advanced.sh || echo "Advanced setup completed with warnings"

# Clean up temporary scripts
RUN rm -f /tmp/setup*.sh

# Copy setup scripts to home directory for reference
COPY --chown=vscode:vscode setup.sh setup-advanced.sh setup-fallback.sh /home/vscode/.devcontainer/

# Set working directory
WORKDIR /workspaces

# Expose common ports for web apps and services
EXPOSE 8080 3000 5000

# Switch to vscode user
USER vscode

CMD ["/bin/bash"]
