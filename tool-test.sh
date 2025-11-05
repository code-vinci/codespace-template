#!/usr/bin/env bash

# test-devcontainer-tools.sh

# Lightweight verification for tools installed by .devcontainer/Dockerfile.

# Run as the vscode user inside the container. Exits non-zero on any failure.

set -uo pipefail

TOOLS_DIR="${TOOLS_DIR:-/home/vscode/tools}"
JOHN_BIN="${TOOLS_DIR}/john/run/john"
failures=0
report() { printf "%-45s : %s\n" "$1" "$2"; }
ok()     { report "$1" "OK"; }
err()    { report "$1" "FAIL ($2)"; failures=$((failures+1)); }

# Check presence (prefer filesystem executable check to avoid false negatives from --version)

check_present() {
local label="$1"; local cmd="$2"
if command -v "$cmd" >/dev/null 2>&1; then ok "$label"; return 0; fi
if [ -x "$cmd" ]; then ok "$label"; return 0; fi
err "$label" "not found or not executable"
}

# Check optional run (non-fatal if runs but returns non-zero). Use for --version where available.

check_run_nonfatal() {
local label="$1"; shift
"$@" >/dev/null 2>&1 && ok "$label (run)" || ok "$label (present, run check non-fatal)"
}

printf "\nRunning environment checks (TOOLS_DIR=%s)\n\n" "$TOOLS_DIR"

# Core system binaries

check_present "bash" bash
check_present "git" git
check_present "curl" curl
check_present "wget" wget
check_present "jq" jq
check_present "make" make
check_present "gcc" gcc
check_present "cmake" cmake
check_present "java" java
check_present "javac" javac

# Network / capture / pentest tools

check_present "nmap" nmap
check_present "tshark" tshark
check_present "binwalk" binwalk
check_present "socat" socat

# netcat variants

if command -v nc >/dev/null 2>&1; then ok "netcat (nc)"; elif command -v netcat >/dev/null 2>&1; then ok "netcat"; else err "netcat" "missing"; fi

# Debug / analysis tools

check_present "gdb" gdb
check_present "strace" strace
check_present "ltrace" ltrace || ok "ltrace (present check tolerated)"
check_present "patchelf" patchelf

# readelf from elfutils/binutils

if command -v readelf >/dev/null 2>&1; then ok "readelf"; else err "readelf" "missing"; fi

# Ruby gems / CLI

if command -v gem >/dev/null 2>&1; then
gem list -i one_gadget >/dev/null 2>&1 && ok "gem: one_gadget" || err "gem: one_gadget" "missing"
gem list -i seccomp-tools >/dev/null 2>&1 && ok "gem: seccomp-tools" || err "gem: seccomp-tools" "missing"
else
err "gem" "gem command missing"
fi

check_present "ngrok" ngrok

# john: prefer local build path, fallback to PATH

if [ -x "${JOHN_BIN}" ]; then
ok "john (local build)"
else
if command -v john >/dev/null 2>&1; then ok "john (in PATH)"; else err "john" "missing at ${JOHN_BIN} and not in PATH"; fi
fi

# ropper CLI

if command -v ropper >/dev/null 2>&1; then ok "ropper CLI"; else err "ropper CLI" "missing"; fi

# pwndbg repo presence

[ -d "${TOOLS_DIR}/pwndbg" ] && ok "pwndbg repo present" || err "pwndbg" "missing ${TOOLS_DIR}/pwndbg"

# one_gadget / seccomp-tools executables (gem installed)

command -v one_gadget >/dev/null 2>&1 && ok "one_gadget CLI" || err "one_gadget CLI" "missing"
command -v seccomp-tools >/dev/null 2>&1 && ok "seccomp-tools CLI" || err "seccomp-tools CLI" "missing"

# Filesystem and permissions

[ -d "${TOOLS_DIR}" ] && ok "TOOLS_DIR exists" || err "TOOLS_DIR" "missing"
[ -d "/workspaces" ] && ok "/workspaces mount" || err "/workspaces" "missing"

# Python tools - dedicated section: test python3 importability of specific modules used by the environment.

printf "\nPython tools checks (using python3 from PATH)\n\n"
PY="python3"
if ! command -v "${PY}" >/dev/null 2>&1; then err "python3" "missing"; else ok "python3"; fi

check_py_import() {
local mod="$1"
"${PY}" -c "import ${mod}" >/dev/null 2>&1 && ok "python module: ${mod}" || err "python module: ${mod}" "import failed"
}

check_py_import Crypto
check_py_import pwn
check_py_import capstone
check_py_import scapy

# pyshark depends on tshark; test import but tolerate predictable failures

"${PY}" -c "import pyshark" >/dev/null 2>&1 && ok "python module: pyshark" || err "python module: pyshark" "import failed"

# Optional run/version checks (non-fatal)

check_run_nonfatal "nmap --version" nmap --version
check_run_nonfatal "tshark -v" tshark -v
check_run_nonfatal "binwalk --version" binwalk --version 2>/dev/null || true

# Summary

printf "\nSummary: "
if [ "$failures" -eq 0 ]; then
printf "All checks passed.\n"
exit 0
else
printf "%d check(s) failed.\n" "$failures"
exit 2
fi
