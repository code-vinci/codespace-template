#!/usr/bin/env bash
set -euo pipefail

# Advanced setup script for the cybersecurity Codespace.
# Provides section toggles, richer logging, and automatic fallback compatibility.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${HOME}/tools"
LOG_DIR="${HOME}/.cache/cyberlab"
SKIP_SECTIONS="${SKIP_SECTIONS:-}"

mkdir -p "${TOOLS_DIR}" "${LOG_DIR}"

log()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error(){ printf "\033[1;31m[ERR ]\033[0m %s\n" "$*"; }

section_enabled() {
  local section="$1"
  if [[ -z "${SKIP_SECTIONS}" ]]; then
    return 0
  fi
  if grep -qw "${section}" <<<"${SKIP_SECTIONS}"; then
    warn "Skipping section '${section}' (requested via SKIP_SECTIONS)."
    return 1
  fi
  return 0
}

require_command() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    error "Required command '${cmd}' not found. Aborting advanced setup."
    return 1
  fi
}

sudo_noninteractive() {
  sudo DEBIAN_FRONTEND=noninteractive "$@"
}

update_system() {
  section_enabled "apt-update" || return 0
  log "Updating system package metadata..."
  sudo_noninteractive apt-get update
  sudo_noninteractive apt-get dist-upgrade -y
  sudo_noninteractive apt-get autoremove -y
}

ensure_system_helpers() {
  section_enabled "system-helpers" || return 0
  log "Ensuring auxiliary system helpers (dbus, polkit)..."

  if [[ ! -e /usr/libexec/polkitd && -x /usr/lib/polkit-1/polkitd ]]; then
    sudo mkdir -p /usr/libexec
    sudo ln -sf /usr/lib/polkit-1/polkitd /usr/libexec/polkitd
  fi

  sudo mkdir -p /run/dbus
  if ! pgrep -f "dbus-daemon --system" >/dev/null 2>&1; then
    if ! sudo dbus-daemon --system --fork; then
      warn "Unable to launch system dbus daemon; continuing without it."
    fi
  fi
}

install_apt_packages() {
  section_enabled "apt-packages" || return 0
  log "Installing base packages via apt..."
  echo "wireshark-common wireshark-common/install-setuid boolean true" \
    | sudo debconf-set-selections

  local packages=(
    curl php binwalk gimp wireshark tshark nmap ht ltrace gdb patchelf elfutils
    unzip wget build-essential aria2 jq python3-venv python3-full git
  )

  sudo_noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
}

install_python_packages() {
  section_enabled "python" || return 0
  require_command python3 || return 1
  log "Installing Python tooling into user environment..."
  python3 -m pip install --user --upgrade pip wheel >/dev/null
  python3 -m pip install --user --upgrade \
    pyshark pwntools ropper pycryptodome mtp capstone==5.0.3 scapy
}

install_ruby_gems() {
  section_enabled "ruby" || return 0
  require_command gem || return 1
  log "Installing Ruby gems..."
  sudo gem install --no-document one_gadget seccomp-tools
}

install_ngrok() {
  section_enabled "ngrok" || return 0
  log "Installing ngrok agent..."
  if ! command -v ngrok >/dev/null 2>&1; then
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
      | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
      | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null
    sudo_noninteractive apt-get update
    sudo_noninteractive apt-get install -y ngrok
  else
    log "ngrok already present, skipping."
  fi
}

install_stegsolve() {
  section_enabled "stegsolve" || return 0
  local target="${TOOLS_DIR}/stegsolve.jar"
  if [[ -f "${target}" ]]; then
    log "Stegsolve already downloaded."
    return 0
  fi
  log "Fetching Stegsolve..."
  aria2c -q -o "${target}" http://www.caesum.com/handbook/Stegsolve.jar \
    || wget -O "${target}" http://www.caesum.com/handbook/Stegsolve.jar
  chmod +x "${target}"
}

build_john() {
  section_enabled "john" || return 0
  local target="${TOOLS_DIR}/john"
  if [[ -d "${target}" ]]; then
    log "John The Ripper already built."
    return 0
  fi
  log "Cloning and compiling John The Ripper..."
  git clone --depth=1 https://github.com/openwall/john -b bleeding-jumbo "${target}"
  (cd "${target}/src" && ./configure && make -s clean && make -sj"$(nproc)")
}

install_postman() {
  section_enabled "postman" || return 0
  local target="${TOOLS_DIR}/Postman"
  if [[ -d "${target}" ]]; then
    log "Postman already installed."
    return 0
  fi
  log "Downloading Postman..."
  aria2c -q -o "${TOOLS_DIR}/postman.tar.gz" https://dl.pstmn.io/download/latest/linux_64 \
    || wget -O "${TOOLS_DIR}/postman.tar.gz" https://dl.pstmn.io/download/latest/linux_64
  (cd "${TOOLS_DIR}" && tar -xf postman.tar.gz && rm -f postman.tar.gz)
}

install_pwndbg() {
  section_enabled "pwndbg" || return 0
  local target="${TOOLS_DIR}/pwndbg"
  if [[ -d "${target}" ]]; then
    log "pwndbg already installed."
    return 0
  fi
  log "Installing pwndbg..."
  git clone --depth=1 https://github.com/pwndbg/pwndbg "${target}"
  (cd "${target}" && ./setup.sh)
}

install_ghidra() {
  section_enabled "ghidra" || return 0
  local target="${TOOLS_DIR}/ghidra_11.2.1_PUBLIC"
  if [[ -d "${target}" ]]; then
    log "Ghidra already present."
    return 0
  fi
  log "Downloading Ghidra..."
  local zip="${TOOLS_DIR}/ghidra.zip"
  aria2c -q -o "${zip}" \
    https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip \
    || wget -O "${zip}" \
      https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip
  (cd "${TOOLS_DIR}" && unzip -q ghidra.zip && rm -f ghidra.zip)
}

post_summary() {
  log "Advanced setup completed."
  cat <<EOF

Installed tools directory: ${TOOLS_DIR}

Quick verification:
  - python3 --version
  - john --list=build-info (add ${TOOLS_DIR}/john/run to PATH)
  - ${TOOLS_DIR}/pwndbg/gdbinit.py ensures pwndbg integration

Use 'SKIP_SECTIONS' (space-separated list) to skip heavy installs,
e.g. 'SKIP_SECTIONS=\"john ghidra\" bash setup-advanced.sh'.

EOF
}

main() {
  log "Starting advanced cybersecurity tooling setup..."
  update_system
  install_apt_packages
  ensure_system_helpers
  install_python_packages
  install_ruby_gems
  install_ngrok
  install_stegsolve
  build_john
  install_postman
  install_pwndbg
  install_ghidra
  post_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
