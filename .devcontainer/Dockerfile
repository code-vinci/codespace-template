# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Metadata
LABEL org.opencontainers.image.title="CodeVinci GitHub Codespace Template"
LABEL org.opencontainers.image.description="CodeVinci development environment with security and CTF tools"
LABEL maintainer="code-vinci"

# Environment configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV TOOLS_DIR=/home/vscode/tools
ENV PATH="${TOOLS_DIR}/venv/bin:${TOOLS_DIR}/john/run:${PATH}"

# Switch to root for installation
USER root

# System update and installation of dependencies
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    apt-get install -y --no-install-recommends \
    curl php binwalk tshark nmap ht ltrace strace gdb patchelf elfutils \
    unzip zip wget build-essential cmake default-jdk tcpdump netcat-openbsd socat aria2 jq python3-venv python3-full git ruby ruby-dev \
    libpcap-dev pkg-config libcapstone-dev python3-dev libffi-dev libssl-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install global tools (Ruby gems, ngrok)
RUN gem install --no-document one_gadget seccomp-tools && \
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list >/dev/null && \
    apt-get update && \
    apt-get install -y ngrok && \
    rm -rf /var/lib/apt/lists/*

# Create tools directory and switch to vscode user
RUN mkdir -p ${TOOLS_DIR} && chown -R vscode:vscode /home/vscode
USER vscode
WORKDIR /home/vscode

# Install Python packages
RUN python3 -m venv ${TOOLS_DIR}/venv && \
    ${TOOLS_DIR}/venv/bin/pip install --no-cache-dir --upgrade pip wheel setuptools && \
    ${TOOLS_DIR}/venv/bin/pip install --no-cache-dir pycryptodome ropper && \
    ${TOOLS_DIR}/venv/bin/pip install --no-cache-dir pyshark scapy && \
    ${TOOLS_DIR}/venv/bin/pip install --no-cache-dir pwntools && \
    ${TOOLS_DIR}/venv/bin/pip install --no-cache-dir capstone mtp


RUN git clone --depth=1 https://github.com/openwall/john -b bleeding-jumbo ${TOOLS_DIR}/john && \
    cd ${TOOLS_DIR}/john/src && ./configure && make -s clean && make -sj"$(nproc)"

RUN git clone --depth=1 https://github.com/pwndbg/pwndbg ${TOOLS_DIR}/pwndbg && \
    cd ${TOOLS_DIR}/pwndbg && ./setup.sh

    
# Final setup
USER root
RUN rm -f /tmp/setup*.sh
COPY --chown=vscode:vscode setup.sh setup-advanced.sh setup-fallback.sh /home/vscode/.devcontainer/
RUN mkdir -p /workspaces && chown -R vscode:vscode /workspaces

# Activate venv by default for vscode user and create john alias
RUN echo 'source ${TOOLS_DIR}/venv/bin/activate' >> /home/vscode/.bashrc && \
    echo 'alias john="${TOOLS_DIR}/john/run/john"' >> /home/vscode/.bashrc

# Expose useful ports
EXPOSE 8080 3000 5000

# Default to non-root user for dev session
USER vscode

# Default shell
WORKDIR /workspaces
CMD ["/bin/bash"]
