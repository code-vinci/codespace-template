#!/bin/bash
set -e

echo "================================================"
echo "CodeVinci Codespace - Setup Script"
echo "================================================"

# Create tools directory
mkdir -p $HOME/tools

echo ""
echo "[1/10] Updating system packages..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo ""
echo "[2/10] Installing base system packages..."
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    php \
    binwalk \
    gimp \
    wireshark \
    tshark \
    ht \
    ltrace \
    gdb \
    patchelf \
    elfutils \
    unzip \
    wget \
    build-essential

echo ""
echo "[3/10] Installing Python packages..."
python3 -m pip install --user \
    pyshark \
    pwntools \
    ropper \
    pycryptodome \
    mtp \
    capstone==5.0.3

echo ""
echo "[4/10] Installing Ruby gems..."
sudo gem install one_gadget seccomp-tools

echo ""
echo "[5/10] Installing Ngrok..."
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && sudo apt install -y ngrok

echo ""
echo "[6/10] Installing Stegsolve..."
wget -O $HOME/tools/stegsolve.jar http://www.caesum.com/handbook/Stegsolve.jar
chmod +x $HOME/tools/stegsolve.jar

echo ""
echo "[7/10] Installing John The Ripper..."
if [ ! -d "$HOME/tools/john" ]; then
    git clone https://github.com/openwall/john -b bleeding-jumbo $HOME/tools/john
    (cd $HOME/tools/john/src && ./configure && make -s clean && make -sj$(nproc))
fi

echo ""
echo "[8/10] Installing Postman..."
if [ ! -d "$HOME/tools/Postman" ]; then
    wget -O $HOME/tools/postman.tar.gz https://dl.pstmn.io/download/latest/linux_64
    (cd $HOME/tools && tar -xf postman.tar.gz)
    rm $HOME/tools/postman.tar.gz
fi

echo ""
echo "[9/10] Installing pwndbg (GDB enhancement)..."
if [ ! -d "$HOME/tools/pwndbg" ]; then
    git clone https://github.com/pwndbg/pwndbg $HOME/tools/pwndbg
    (cd $HOME/tools/pwndbg && ./setup.sh)
fi

echo ""
echo "[10/10] Installing Ghidra..."
if [ ! -d "$HOME/tools/ghidra_11.2.1_PUBLIC" ]; then
    wget -O $HOME/tools/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip
    (cd $HOME/tools && unzip -q ghidra.zip)
    rm $HOME/tools/ghidra.zip
fi

echo ""
echo "================================================"
echo "Setup completed successfully!"
echo "================================================"
echo ""
echo "Installed tools location: $HOME/tools"
echo ""
echo "Available tools:"
echo "  - Wireshark/Tshark"
echo "  - Stegsolve"
echo "  - John The Ripper"
echo "  - Postman"
echo "  - pwndbg (GDB)"
echo "  - Ghidra"
echo "  - Python packages (pwntools, ropper, etc.)"
echo "  - Ngrok"
echo ""
echo "Note: Some GUI tools may require X11 forwarding."
echo "================================================"
