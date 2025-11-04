#!/bin/bash
set -e

echo "================================================"
echo "CyberSecurity Lab - Advanced Setup Script"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Create tools directory
mkdir -p $HOME/tools

echo ""
print_status "Starting installation of cybersecurity tools..."
echo ""

# Update system
echo "[1/12] Updating system packages..."
sudo apt update -qq
sudo apt upgrade -y -qq
sudo apt autoremove -y -qq
print_status "System updated"

# Install base packages
echo ""
echo "[2/12] Installing base system packages..."
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq \
    curl \
    wget \
    php \
    binwalk \
    gimp \
    wireshark \
    tshark \
    ht \
    ltrace \
    strace \
    gdb \
    patchelf \
    elfutils \
    unzip \
    zip \
    build-essential \
    cmake \
    nmap \
    netcat \
    socat \
    sqlmap \
    hashcat \
    aircrack-ng \
    hydra \
    metasploit-framework 2>/dev/null || print_warning "Some packages may not be available"

print_status "Base packages installed"

# Install Python packages
echo ""
echo "[3/12] Installing Python packages..."
python3 -m pip install --user --quiet \
    pyshark \
    pwntools \
    ropper \
    pycryptodome \
    mtp \
    capstone==5.0.3 \
    requests \
    beautifulsoup4 \
    scapy \
    colorama

print_status "Python packages installed"

# Install Ruby gems
echo ""
echo "[4/12] Installing Ruby gems..."
sudo gem install one_gadget seccomp-tools --quiet --no-document
print_status "Ruby gems installed"

# Install Ngrok
echo ""
echo "[5/12] Installing Ngrok..."
if ! command -v ngrok &> /dev/null; then
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
      | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
      && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
      | sudo tee /etc/apt/sources.list.d/ngrok.list \
      && sudo apt update -qq \
      && sudo apt install -y ngrok
    print_status "Ngrok installed"
else
    print_warning "Ngrok already installed"
fi

# Install Stegsolve
echo ""
echo "[6/12] Installing Stegsolve..."
if [ ! -f "$HOME/tools/stegsolve.jar" ]; then
    wget -q -O $HOME/tools/stegsolve.jar http://www.caesum.com/handbook/Stegsolve.jar
    chmod +x $HOME/tools/stegsolve.jar
    print_status "Stegsolve installed"
else
    print_warning "Stegsolve already installed"
fi

# Install John The Ripper
echo ""
echo "[7/12] Installing John The Ripper (this may take a while)..."
if [ ! -d "$HOME/tools/john" ]; then
    git clone -q https://github.com/openwall/john -b bleeding-jumbo $HOME/tools/john
    (cd $HOME/tools/john/src && ./configure --quiet && make -s clean && make -sj$(nproc)) > /dev/null 2>&1
    print_status "John The Ripper compiled and installed"
else
    print_warning "John The Ripper already installed"
fi

# Install Postman
echo ""
echo "[8/12] Installing Postman..."
if [ ! -d "$HOME/tools/Postman" ]; then
    wget -q -O $HOME/tools/postman.tar.gz https://dl.pstmn.io/download/latest/linux_64
    (cd $HOME/tools && tar -xzf postman.tar.gz)
    rm $HOME/tools/postman.tar.gz
    print_status "Postman installed"
else
    print_warning "Postman already installed"
fi

# Install pwndbg
echo ""
echo "[9/12] Installing pwndbg (GDB enhancement)..."
if [ ! -d "$HOME/tools/pwndbg" ]; then
    git clone -q https://github.com/pwndbg/pwndbg $HOME/tools/pwndbg
    (cd $HOME/tools/pwndbg && ./setup.sh) > /dev/null 2>&1
    print_status "pwndbg installed"
else
    print_warning "pwndbg already installed"
fi

# Install Ghidra
echo ""
echo "[10/12] Installing Ghidra..."
if [ ! -d "$HOME/tools/ghidra_11.2.1_PUBLIC" ]; then
    wget -q -O $HOME/tools/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip
    (cd $HOME/tools && unzip -q ghidra.zip)
    rm $HOME/tools/ghidra.zip
    print_status "Ghidra installed"
else
    print_warning "Ghidra already installed"
fi

# Install Binary Ninja Free
echo ""
echo "[11/12] Installing Binary Ninja (Free Version)..."
if [ ! -d "$HOME/tools/binaryninja" ]; then
    wget -q -O $HOME/tools/binaryninja.zip https://cdn.binary.ninja/installers/binaryninja_free_linux.zip
    (cd $HOME/tools && unzip -q binaryninja.zip)
    rm $HOME/tools/binaryninja.zip
    print_status "Binary Ninja installed"
else
    print_warning "Binary Ninja already installed"
fi

# Setup PATH and aliases
echo ""
echo "[12/12] Setting up environment..."
cat >> $HOME/.bashrc << 'EOF'

# CyberSecurity Lab - Custom aliases and PATH
export PATH="$HOME/tools/john/run:$PATH"
export PATH="$HOME/tools/ghidra_11.2.1_PUBLIC:$PATH"
export PATH="$HOME/tools/binaryninja:$PATH"

# Aliases
alias ghidra='$HOME/tools/ghidra_11.2.1_PUBLIC/ghidraRun'
alias binja='$HOME/tools/binaryninja/binaryninja'
alias john='$HOME/tools/john/run/john'
alias stegsolve='java -jar $HOME/tools/stegsolve.jar'
alias postman='$HOME/tools/Postman/Postman'

# Useful shortcuts
alias ll='ls -alh'
alias ports='netstat -tulanp'
alias myip='curl ifconfig.me'

EOF

print_status "Environment configured"

echo ""
echo "================================================"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "================================================"
echo ""
echo "📁 Installed tools location: $HOME/tools"
echo ""
echo "🛠️  Available tools:"
echo "   Network Analysis:"
echo "     - tshark, wireshark (CLI mode)"
echo "     - nmap, netcat, socat"
echo "   Password Cracking:"
echo "     - john (John The Ripper)"
echo "     - hashcat, hydra"
echo "   Reverse Engineering:"
echo "     - ghidra"
echo "     - binja (Binary Ninja)"
echo "   Debugging:"
echo "     - gdb with pwndbg"
echo "   Steganography:"
echo "     - stegsolve"
echo "     - binwalk"
echo "   Web Security:"
echo "     - sqlmap"
echo "     - postman"
echo "   Python Packages:"
echo "     - pwntools, ropper, scapy"
echo "   Others:"
echo "     - ngrok"
echo ""
echo "💡 Quick commands:"
echo "   ghidra      - Launch Ghidra"
echo "   john        - John The Ripper"
echo "   stegsolve   - Stegsolve jar"
echo "   postman     - Launch Postman"
echo ""
echo "⚠️  Note: GUI tools may require additional configuration"
echo "   Reload shell: source ~/.bashrc"
echo "================================================"
