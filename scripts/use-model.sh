#!/usr/bin/env bash
# Switches the agent's model in every eval of the workshop. Use it when the pinned model,
# claude-sonnet-5.5, isn't available on your Copilot plan.
#   scripts/use-model.sh              show the agent's model in each eval file
#   scripts/use-model.sh <model-id>   use <model-id> instead; see /model in Copilot CLI for your models
# It changes only the agent's `model:` line under `defaults`, in evals/, lab-files/ and solutions/,
# so Lab 4's experiment, Lab 7's CI and scripts/catch-up.sh all use the new model. Judges and
# models on your own endpoint (written as ${...}) stay as they are.
set -euo pipefail
cd "$(dirname "$0")/.."

files=$(find evals lab-files solutions -name '*.eval.yaml' -type f 2>/dev/null | sort)
pattern='^(  model: )([A-Za-z0-9._-]+)(.*)$'

if [[ $# -eq 0 ]]; then
  for f in $files; do
    current=$(sed -nE "s/${pattern}/\2/p" "$f" | head -1)
    [[ -n "$current" ]] && printf '%-55s %s\n' "$f" "$current"
  done
  exit 0
fi

model="$1"
if [[ ! "$model" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Not a model ID: $model. Start copilot and type /model to see your models." >&2
  exit 1
fi

changed=0
for f in $files; do
  if grep -qE "$pattern" "$f"; then
    sed -E -i.bak "s/${pattern}/\1${model}\3/" "$f" && rm -f "$f.bak"
    echo "  ✔ $f"
    changed=$((changed + 1))
  fi
done
echo "The agent now uses ${model} in ${changed} eval file(s)."
