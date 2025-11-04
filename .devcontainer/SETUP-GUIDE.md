# CyberSecurity Codespace Setup Guide

## 1. Repository Structure
```
your-repo/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── setup.sh              # orchestrator (advanced + fallback + CyberSecNatLab)
│   ├── setup-advanced.sh     # main workflow
│   └── setup-fallback.sh     # legacy script
├── README.md
└── SETUP-GUIDE.md
```

## 2. Deployment Steps
1. Crea un repository GitHub (pubblico o privato) e attivalo come template se ti serve riutilizzarlo.
2. Clona il repository in locale, copia la struttura sopra, quindi `git add`, `git commit`, `git push`.
3. (Facoltativo) Aggiungi `tools/` al `.gitignore` se scarichi gli artifact localmente.
4. Apri **Code → Codespaces → Create codespace on main** per validare la configurazione.

## 3. Dettagli `devcontainer.json`
- Immagine base: `mcr.microsoft.com/devcontainers/base:ubuntu`.
- Features: Docker-in-Docker, Git, Python 3.11, Node LTS, Java 23, Ruby latest, Common Utils.
- Estensioni VS Code: Python, Pylance, Docker, Hex Editor, GitLens, Copilot.
- Capabilities extra: `SYS_PTRACE`, `seccomp=unconfined`.
- Porte inoltrate di default: 8080, 3000, 5000.
- `postCreateCommand`: esegue `.devcontainer/setup.sh` (advanced con fallback).

## 4. Script di Setup
- `setup.sh`: orchestratore; prova il workflow avanzato, poi il fallback legacy e, in caso di ulteriore errore, esegue lo script originale **CyberSecNatLab - VM Setup.sh**.
- `setup-advanced.sh`: installa pacchetti apt (curl, nmap, binwalk, gdb, patchelf, aria2, ecc.), pip user packages (`pwntools`, `ropper`, `pycryptodome`, `capstone`, `scapy`, ...), gem Ruby (`one_gadget`, `seccomp-tools`) e tool scaricati (ngrok, Stegsolve, John The Ripper bleeding-jumbo, Postman, pwndbg, Ghidra). Supporta `SKIP_SECTIONS="john ghidra"` per saltare installazioni pesanti.
- `setup-fallback.sh`: equivalente allo script originale lineare, usato se l'advanced fallisce o se invocato manualmente.
- `CyberSecNatLab - VM Setup.sh`: script completo legacy (installazione di tool molto pesanti come SageMath, Burp Suite, Docker Desktop); viene richiamato automaticamente solo come terza e ultima opzione.
- Tutti i tool custom sono salvati in `$HOME/tools`.

## 5. Personalizzazioni
- Aggiungi o rimuovi sezioni nello script avanzato creando funzioni dedicate e registrandole nel `main`.
- Aggiungi nuove estensioni/porte modificando `devcontainer.json`.
- Usa variabili env Codespaces (Settings → Secrets and variables → Codespaces) e legale con `remoteEnv` nel devcontainer.
- Per tempi di bootstrap ridotti valuta un `.devcontainer/Dockerfile` personalizzato o la funzionalità di prebuilds.

## 6. Prebuilds (GitHub Team/Enterprise)
1. Repository → Settings → Codespaces → Prebuilds.
2. Abilita il branch desiderato, scegli eventi (push/Pull Request) e regioni.
3. Ricostruisci il prebuild dopo aggiornamenti importanti di `setup-advanced.sh`.
Risultato: bootstrap da ~20 minuti a ~2-3 minuti.

## 7. Troubleshooting
- Script bloccato su `apt`: ricostruisci il Codespace (`F1 → Codespaces: Rebuild Container`).
- `SKIP_SECTIONS`: esporta la variabile prima di ricostruire o esegui manualmente `bash .devcontainer/setup-advanced.sh`.
- Wireshark GUI: usa `tshark` oppure configura X11 forwarding.
- Docker non parte: controlla `sudo journalctl -u docker` e verifica la feature DinD.
- Ripeti l'installazione: `bash .devcontainer/setup.sh` per pipeline completa, oppure esegui direttamente advanced/fallback/CyberSecNatLab.

## 8. Verifica Rapida
Esegui questi comandi nel Codespace dopo il bootstrap:
```bash
python3 --version
john --list=build-info || echo "Aggiungi ${HOME}/tools/john/run al PATH"
ngrok version
gdb -q --ex "pi import pwndbg" --ex quit
ls ${HOME}/tools/ghidra_11.2.1_PUBLIC >/dev/null
```

## 9. Limitazioni Note
- Nessuna GUI nativa per tool pesanti (Burp Suite, Nessus); usa versioni CLI o servizi esterni.
- Tool molto grandi (es. SageMath) non inclusi per ridurre il tempo di bootstrap.
- Storage persistente limitato al workspace; distruggere il Codespace elimina `~/tools`.

## 10. Riferimenti Utili
- https://docs.github.com/en/codespaces
- https://containers.dev/implementors/features/
- https://github.com/devcontainers/spec
