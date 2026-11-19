#!/usr/bin/env bash
# Runs once when the Codespace (or dev container) is created.
set -Eeuo pipefail
trap 'status=$?; printf >&2 "\nWorkshop setup failed (exit %s, line %s). Rerun: bash .devcontainer/post-create.sh\n" "$status" "$LINENO"; exit "$status"' ERR

printf '\nInstalling the Vally CLI (pinned to the tested version) and the GitHub Copilot CLI...\n'
npm install -g --no-audit --no-fund @microsoft/vally-cli@0.21.0 @github/copilot

if ! command -v jq >/dev/null 2>&1; then
  printf '\nInstalling jq...\n'
  sudo apt-get update -y && sudo apt-get install -y --no-install-recommends jq
fi

chmod +x scripts/*.sh
printf '\nWorkshop setup complete. Next: ./scripts/check-setup.sh\n'
