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

# System update and installation of dependencies
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    apt-get install -y --no-install-recommends \
    curl php binwalk gimp wireshark tshark nmap ht ltrace gdb patchelf elfutils \
    unzip wget build-essential aria2 jq python3-venv python3-full git ruby ruby-dev \
    libpcap-dev pkg-config libcapstone-dev && \
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
RUN python3 -m pip install --user --upgrade pip wheel && \
    python3 -m pip install --user --upgrade \
    pyshark pwntools ropper pycryptodome mtp capstone==5.0.3 scapy

# Install user-specific tools
RUN aria2c -q -d ${TOOLS_DIR} -o stegsolve.jar http://www.caesum.com/handbook/Stegsolve.jar || \
    wget -O ${TOOLS_DIR}/stegsolve.jar http://www.caesum.com/handbook/Stegsolve.jar && \
    chmod +x ${TOOLS_DIR}/stegsolve.jar

RUN git clone --depth=1 https://github.com/openwall/john -b bleeding-jumbo ${TOOLS_DIR}/john && \
    cd ${TOOLS_DIR}/john/src && ./configure && make -s clean && make -sj"$(nproc)"

RUN (aria2c -q -o ${TOOLS_DIR}/postman.tar.gz https://dl.pstmn.io/download/latest/linux_64 || \
    wget -O ${TOOLS_DIR}/postman.tar.gz https://dl.pstmn.io/download/latest/linux_64) && \
    cd ${TOOLS_DIR} && tar -xf postman.tar.gz && rm -f postman.tar.gz

RUN git clone --depth=1 https://github.com/pwndbg/pwndbg ${TOOLS_DIR}/pwndbg && \
    cd ${TOOLS_DIR}/pwndbg && ./setup.sh

RUN (aria2c -q -o ${TOOLS_DIR}/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip || \
    wget -O ${TOOLS_DIR}/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip) && \
    cd ${TOOLS_DIR} && unzip -q ghidra.zip && rm -f ghidra.zip

# Final setup
USER root
RUN rm -f /tmp/setup*.sh
COPY --chown=vscode:vscode setup.sh setup-advanced.sh setup-fallback.sh /home/vscode/.devcontainer/
RUN mkdir -p /workspaces && chown -R vscode:vscode /workspaces

# Expose useful ports
EXPOSE 8080 3000 5000

# Default to non-root user for dev session
USER vscode

# Default shell
WORKDIR /workspaces
CMD ["/bin/bash"]
