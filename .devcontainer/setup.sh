#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADVANCED="${SCRIPT_DIR}/setup-advanced.sh"
FALLBACK="${SCRIPT_DIR}/setup-fallback.sh"
CYBER_FALLBACK="${SCRIPT_DIR}/../CyberSecNatLab - VM Setup.sh"

echo "=============================================="
echo "Executing advanced setup (.devcontainer/setup-advanced.sh)"
echo "=============================================="
if bash "${ADVANCED}"; then
  echo "Advanced setup completed successfully."
  exit 0
fi

STATUS=$?
echo "----------------------------------------------"
echo "Advanced setup exited with status ${STATUS}."
echo "Falling back to legacy setup script."
echo "----------------------------------------------"

if [[ -x "${FALLBACK}" ]]; then
  echo "Running fallback script: ${FALLBACK}"
  if bash "${FALLBACK}"; then
    echo "Fallback script completed successfully."
    exit 0
  fi
  STATUS=$?
  echo "Fallback script exited with status ${STATUS}."
else
  echo "Fallback script ${FALLBACK} not found or not executable."
fi

echo "----------------------------------------------"
echo "Attempting CyberSecNatLab fallback: ${CYBER_FALLBACK}"
echo "----------------------------------------------"

if [[ -f "${CYBER_FALLBACK}" ]]; then
  if bash "${CYBER_FALLBACK}"; then
    echo "CyberSecNatLab fallback completed successfully."
    exit 0
  fi
  STATUS=$?
  echo "CyberSecNatLab fallback exited with status ${STATUS}."
else
  echo "CyberSecNatLab fallback script ${CYBER_FALLBACK} not found."
fi

exit ${STATUS}
