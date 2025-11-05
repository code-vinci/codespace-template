# GitHub Codespace Template

## Quick start
Click on "Use this template" > "Open in a codespace"

## Installed Tools & Usage

This development environment includes a comprehensive suite of security, CTF, and reverse engineering tools pre-installed and configured.

### System Tools

#### Analysis & Debugging
- **gdb/pwndbg** - GNU Debugger with pwndbg extension
  - Usage: `gdb ./binary`
  - pwndbg auto-loads with enhanced features
- **ltrace** - Library call tracer
  - Usage: `ltrace ./binary`
- **strace** - System call tracer
  - Usage: `strace ./binary`
- **patchelf** - ELF binary patcher
  - Usage: `patchelf --set-interpreter /path/to/ld.so binary`

#### Network Tools
- **wireshark** / **tshark** - Network protocol analyzers
  - CLI: `tshark -i eth0`
- **nmap** - Network scanner
  - Usage: `nmap -sV target.com`
- **netcat** - Network utility (`nc` command)
  - Usage: `nc -lvnp 4444`
- **socat** - Advanced socket utility
  - Usage: `socat TCP-LISTEN:8080,fork TCP:target:80`
- **ngrok** - Secure tunnels to localhost
  - Usage: `ngrok http 8080`

#### Binary Analysis
- **binwalk** - Firmware analysis tool
  - Usage: `binwalk -e firmware.bin`
- **elfutils** - ELF file utilities
  - Usage: `eu-readelf -a binary`
- **ht** - Hex editor
  - Usage: `ht binary`

#### Development
- **build-essential** - GCC, g++, make, etc.
- **cmake** - Build system generator
- **php** - PHP interpreter
- **curl** / **wget** / **aria2** - Download utilities
- **git** - Version control
- **jq** - JSON processor

### Python Tools (in virtualenv)

All Python tools are installed in `~/tools/venv` and auto-activated in bash.

- **pwntools** - CTF framework
  ```python
  from pwn import *
  ```
- **ropper** - ROP gadget finder
  - Usage: `ropper --file binary`
- **pycryptodome** - Cryptography library
- **scapy** / **pyshark** - Packet manipulation
- **capstone** - Disassembly framework

### Ruby Tools

- **one_gadget** - Find one-gadget RCE in libc
  - Usage: `one_gadget /lib/x86_64-linux-gnu/libc.so.6`
- **seccomp-tools** - Seccomp analyzer
  - Usage: `seccomp-tools dump ./binary`

### Specialized Tools

#### John the Ripper
Password cracker installed in `~/tools/john`
- Usage: `john hashfile.txt` (alias configured)
- Or: `~/tools/john/run/john hashfile.txt`
- Available in PATH automatically

#### Stegsolve
Java-based steganography tool
- Location: `~/tools/stegsolve.jar`
- Usage: `java -jar ~/tools/stegsolve.jar image.png`
- Requires X11 forwarding for GUI

#### pwndbg
GDB enhancement for exploit development
- Location: `~/tools/pwndbg`
- Auto-loads when using `gdb`
- Provides commands like `checksec`, `vmmap`, `telescope`

### Tools Directory Structure

```
~/tools/
├── venv/                    # Python virtual environment
│   ├── bin/
│   │   ├── python3         # Python interpreter
│   │   ├── pip             # Package manager
│   │   ├── pwn             # Pwntools
│   │   └── ropper          # Ropper
│   └── lib/                # Python packages
├── john/                    # John the Ripper
│   ├── run/
│   │   └── john            # John executable
│   └── src/                # Source files
├── pwndbg/                  # pwndbg for GDB
│   └── gdbinit.py          # Auto-loaded by GDB
└── stegsolve.jar           # Stegsolve tool
```

### Environment Setup

- **Python virtualenv**: Automatically activated in bash sessions
- **PATH additions**: 
  - `~/tools/venv/bin` - Python tools
  - `~/tools/john/run` - John the Ripper
- **Aliases**:
  - `john` → `~/tools/john/run/john`

### Exposed Ports

The following ports are exposed for your applications:
- **3000** - Common for Node.js/React apps
- **5000** - Common for Flask/Python apps  
- **8080** - Alternative HTTP server port

If some package is missing you can run find .sh scripts in the .devcontainer dir
