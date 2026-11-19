#!/usr/bin/env bash
# Fell behind? Brings your files to the end state of a lab, so you can start the next one.
#   scripts/catch-up.sh 2    end of Lab 2: the finished control eval
#   scripts/catch-up.sh 3    end of Lab 3: plus the real eval in evals/
#   scripts/catch-up.sh 4    end of Lab 4: plus the fixed skill
#   scripts/catch-up.sh 5    end of Lab 5: plus the judge controls and the judged eval
#   scripts/catch-up.sh 7    end of Lab 7: plus the CI-tagged eval and the workflow
# Files that would change are first copied to .catch-up-backup/<time>/.
set -euo pipefail
cd "$(dirname "$0")/.."

lab="${1:-}"
case "$lab" in 2|3|4|5|7) ;; *) echo "Usage: scripts/catch-up.sh 2|3|4|5|7" >&2; exit 1;; esac

backup=".catch-up-backup/$(date +%Y%m%d-%H%M%S)"
place() {
  local src="$1" dest="$2"
  if [[ -f "$dest" ]] && ! cmp -s "$src" "$dest" && [[ ! -e "$backup/$dest" ]]; then
    mkdir -p "$backup/$(dirname "$dest")"
    cp "$dest" "$backup/$dest"
    echo "  backed up $dest"
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  ✔ $dest"
}

echo "Catching up to the end of Lab $lab"
place solutions/lab-2/release-notes-control.eval.yaml evals/release-notes-control.eval.yaml
(( lab >= 3 && lab < 7 )) && place lab-files/lab-3/release-notes.eval.yaml evals/release-notes.eval.yaml
(( lab >= 4 )) && place solutions/lab-4/SKILL.md .github/skills/release-notes/SKILL.md
if (( lab >= 5 )); then
  place solutions/lab-5/judge-controls.eval.yaml evals/judge-controls.eval.yaml
  place solutions/lab-5/release-notes-judged.eval.yaml evals/release-notes-judged.eval.yaml
fi
if (( lab >= 7 )); then
  place solutions/lab-7/release-notes.eval.yaml evals/release-notes.eval.yaml
  place lab-files/lab-7/evals.yml .github/workflows/evals.yml
fi
[[ -d "$backup" ]] && echo "Your previous versions are in $backup/"
echo "Done."
