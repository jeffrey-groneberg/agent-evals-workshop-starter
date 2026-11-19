#!/usr/bin/env bash
# Shows what happened in a Vally run: each trial's answer, its check results and, with --tools,
# the tool calls from its transcript, with their arguments.
#   scripts/answers.sh                     newest run in vally-results/ or vally-experiment-results/
#   scripts/answers.sh <run-folder>        a specific run (an eval or an experiment run)
#   scripts/answers.sh --tools [folder]    also list each trial's tool calls
set -euo pipefail

show_tools=false
if [[ "${1:-}" == "--tools" ]]; then
  show_tools=true
  shift
fi

run_dir="${1:-}"
if [[ -z "$run_dir" ]]; then
  run_dir=$(ls -1dt vally-results/*/ vally-experiment-results/*/ 2>/dev/null | head -1 || true)
fi
run_dir="${run_dir%/}"
if [[ -z "$run_dir" || ! -d "$run_dir" ]]; then
  echo "No run found. Run an eval first, or pass a run folder: scripts/answers.sh vally-results/<timestamp>" >&2
  exit 1
fi

files=$(find "$run_dir" -maxdepth 2 -name results.jsonl | sort)
if [[ -z "$files" ]]; then
  echo "No results.jsonl in $run_dir" >&2
  exit 1
fi

echo "Run: $run_dir"
for file in $files; do
  jq -r --argjson tools "$show_tools" '
    select(.type == "trial-result")
    | (.itemId // "" | capture("trial-(?<n>[0-9]+)$").n // "0" | tonumber + 1) as $trial
    | (if .variant and .variant != "main" then " · variant \(.variant)" else "" end) as $variant
    | (.status == "error") as $error
    | (if $error then "ERROR"
       elif .gradeResult.passed then "PASS (score \((.gradeResult.score // 0) * 100 | round)%)"
       else "FAIL (score \((.gradeResult.score // 0) * 100 | round)%)" end) as $verdict
    | "",
      "════ \(.evalName) › \(.stimulus)\($variant) · trial \($trial) · \(.trajectory.metadata.model // .model // "?") · \($verdict)",
      (if $error then
        "── error ──",
        (.error // "unknown error" | tostring),
        "The trial did not finish, so it has no answer and no check results. Vally counts it as an error,",
        "not as a pass or a fail. Errors are often temporary: run the eval again."
      else
        "── answer ──",
        ((.trajectory.output // "") | if . == "" then "(no answer)" else . end),
        (if $tools then
          "── tool calls ──",
          ([.trajectory.events[]? | select(.type == "tool_call")
            | "\(.data.toolName // "?"): \((.data.arguments // {}) | tostring | .[0:120])"]
            | if length == 0 then "(none)" else to_entries | map("\(.key + 1). \(.value)") | join("\n") end)
         else empty end),
        "── checks ──",
        (.gradeResult.details[]? |
          "\(if .passed then "✔" else "✘" end) \(.name) [\(.graderType // .kind)]"
          + (if (.graderType == "prompt") or (.passed | not) then
               "\n    " + ((.evidence // "") | tostring | gsub("\\s+"; " ") | .[0:400])
             else "" end))
      end)
  ' "$file"
done
