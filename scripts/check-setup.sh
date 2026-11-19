#!/usr/bin/env bash
# Checks that this machine or Codespace is ready for the workshop.
#   scripts/check-setup.sh          check tools and settings (no network calls)
#   scripts/check-setup.sh --ping   also send one tiny request to your own model endpoint, if you set one
set -uo pipefail
cd "$(dirname "$0")/.."

ping_endpoint=false
[[ "${1:-}" == "--ping" ]] && ping_endpoint=true

failures=0
ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✘\033[0m %s\n' "$1"; failures=$((failures + 1)); }

echo "Tools"
if command -v node >/dev/null 2>&1; then
  node_version=$(node -p 'process.versions.node')
  if node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>22||(a===22&&b>=15)?0:1)'; then
    ok "Node.js $node_version"
  else
    fail "Node.js $node_version is too old: Vally needs 22.15 or later (24 recommended)"
  fi
else
  fail "Node.js not found: install Node.js 24 (https://nodejs.org)"
fi

if command -v vally >/dev/null 2>&1; then
  vally_version=$(vally --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  if [[ "$vally_version" == "0.21.0" ]]; then
    ok "Vally CLI $vally_version"
  else
    warn "Vally CLI ${vally_version:-unknown}: the labs were tested with 0.21.0 (npm install -g @microsoft/vally-cli@0.21.0)"
  fi
else
  fail "Vally CLI not found: npm install -g @microsoft/vally-cli@0.21.0"
fi

if command -v copilot >/dev/null 2>&1; then
  ok "GitHub Copilot CLI $(copilot --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]*[0-9A-Za-z])?' | head -1)"
else
  fail "GitHub Copilot CLI not found: npm install -g @github/copilot"
fi

if command -v jq >/dev/null 2>&1; then
  ok "jq $(jq --version 2>/dev/null)"
else
  fail "jq not found: install it (macOS: brew install jq, Debian/Ubuntu: sudo apt-get install jq)"
fi

if command -v git >/dev/null 2>&1; then
  ok "$(git --version)"
else
  fail "Git not found"
fi

if command -v gh >/dev/null 2>&1; then
  ok "GitHub CLI $(gh --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
else
  warn "GitHub CLI not found: on your computer, you need it to sign in, and in Lab 7 (https://cli.github.com)"
fi

echo
echo "GitHub Copilot sign-in (for the agent under test and the LLM judge)"
in_codespace=false
[[ "${CODESPACES:-}" == "true" ]] && in_codespace=true
clean="Vally runs the agent in a clean, isolated Copilot home"
if [[ -n "${COPILOT_GITHUB_TOKEN:-}" ]]; then
  if [[ "$COPILOT_GITHUB_TOKEN" =~ [[:space:]] ]]; then
    fail "COPILOT_GITHUB_TOKEN contains spaces or line breaks: paste the token again"
  elif [[ "$COPILOT_GITHUB_TOKEN" == ghp_* ]]; then
    fail "COPILOT_GITHUB_TOKEN is a classic token (ghp_), which Copilot doesn't accept: create a fine-grained token"
  else
    case "$COPILOT_GITHUB_TOKEN" in
      gho_*) source_name="COPILOT_GITHUB_TOKEN, from your GitHub CLI sign-in" ;;
      github_pat_*) source_name="COPILOT_GITHUB_TOKEN, a fine-grained personal access token" ;;
      *) source_name="COPILOT_GITHUB_TOKEN" ;;
    esac
    if [[ "${EVALUATE_USE_HOST_COPILOT_HOME:-}" == "1" ]]; then
      ok "$source_name"
      warn "EVALUATE_USE_HOST_COPILOT_HOME=1 is also set, so runs still see your own skills and plugins."
      echo "      Run: unset EVALUATE_USE_HOST_COPILOT_HOME, then remove it from ~/.bashrc (Codespace)"
      echo "      or comment it out again in .env (your computer)."
    else
      ok "$source_name: $clean"
    fi
  fi
elif $in_codespace && [[ -n "${GITHUB_TOKEN:-}" ]]; then
  ok "Your Codespace's own token (GITHUB_TOKEN): $clean"
elif [[ "${EVALUATE_USE_HOST_COPILOT_HOME:-}" == "1" ]]; then
  ok "EVALUATE_USE_HOST_COPILOT_HOME=1: Vally reuses your Copilot CLI sign-in (copilot login)"
  warn "Runs see your Copilot home, including your own skills and plugins. A token keeps runs clean."
elif [[ -n "${GH_TOKEN:-}${GITHUB_TOKEN:-}" ]]; then
  ok "GH_TOKEN or GITHUB_TOKEN: Vally signs in with it. $clean"
elif $in_codespace; then
  fail "No sign-in found. A Codespace terminal normally has GITHUB_TOKEN: open a new terminal and run this"
  echo "      check again. Still missing? Set COPILOT_GITHUB_TOKEN as described on the workshop site,"
  echo "      under Set up in a Codespace > If Lab 0 can't sign in."
else
  fail "No sign-in found. Run: gh auth login   then load your settings again: set -a; source .env; set +a"
  echo "      (.env reads your GitHub CLI sign-in into COPILOT_GITHUB_TOKEN; no .env yet? cp .env.example .env)"
fi
agent_model=$(sed -nE 's/^  model: ([A-Za-z0-9._-]+).*/\1/p' lab-files/lab-0/setup-check.eval.yaml 2>/dev/null | head -1)
ok "Agent model in the eval files: ${agent_model:-unknown} (not on your plan? scripts/use-model.sh <model>)"
judge_default=$(sed -nE 's/^  judge_model: \$\{JUDGE_MODEL=([A-Za-z0-9._-]+)\}.*/\1/p' lab-files/lab-5/judge-controls.eval.yaml 2>/dev/null | head -1)
ok "LLM judge in Lab 5: ${judge_default:-unknown}, on your Copilot plan (another model: --param JUDGE_MODEL=<model>)"
echo "      The real test: vally eval -e lab-files/lab-0/setup-check.eval.yaml (one Copilot request)"

echo
echo "Your own model endpoint (optional: without one, the judge runs on your Copilot plan)"
base_url="${LLM_BASE_URL:-}"
endpoint_model="${LLM_MODEL:-}"
if [[ -z "$base_url$endpoint_model${LLM_API_KEY:-}" ]]; then
  ok "Not set, and not needed"
else
  if [[ -z "$base_url" ]]; then
    fail "LLM_BASE_URL is not set: the endpoint's base URL, for example https://<resource>.openai.azure.com/openai/v1/"
  elif [[ "$base_url" == *example.com* || "$base_url" == *.invalid* || "$base_url" == *"<"* ]]; then
    fail "LLM_BASE_URL still holds an example value: put in your real endpoint"
  elif [[ "$base_url" != https://* && "$base_url" != http://localhost* && "$base_url" != http://127.0.0.1* ]]; then
    fail "LLM_BASE_URL must start with https://"
  elif [[ "$base_url" != */openai/v1 && "$base_url" != */openai/v1/ ]]; then
    warn "LLM_BASE_URL usually ends with /openai/v1/ for Azure OpenAI and Microsoft Foundry: check it"
  else
    ok "LLM_BASE_URL is set (ends with /openai/v1/)"
  fi
  if [[ -z "${LLM_API_KEY:-}" ]]; then
    fail "LLM_API_KEY is not set: the endpoint's API key"
  else
    ok "LLM_API_KEY is set (${#LLM_API_KEY} characters, not shown)"
  fi
  if [[ -z "$endpoint_model" ]]; then
    fail "LLM_MODEL is not set: the model's deployment name on your endpoint"
  else
    ok "LLM_MODEL (deployment name): $endpoint_model"
  fi
fi

if $ping_endpoint; then
  echo
  echo "Endpoint test: one small request"
  if [[ -z "$base_url" || -z "${LLM_API_KEY:-}" || -z "$endpoint_model" ]]; then
    fail "Set LLM_BASE_URL, LLM_API_KEY and LLM_MODEL first. Without your own endpoint, there's nothing to test."
  else
    body=$(jq -n --arg model "$endpoint_model" '{model: $model, input: "Reply with the single word OK.", store: false}')
    response=$(curl -sS --max-time 120 -w '\n%{http_code}' -X POST "${base_url%/}/responses" \
      -H "api-key: ${LLM_API_KEY}" -H "content-type: application/json" -d "$body" 2>&1)
    status=$(tail -n1 <<<"$response")
    payload=$(sed '$d' <<<"$response")
    case "$status" in
      200) ok "HTTP 200 from $endpoint_model: $(jq -r '[.output[]? | select(.type=="message") | .content[]? | .text? // empty] | join(" ") | .[0:80]' <<<"$payload" 2>/dev/null)";;
      401|403) fail "HTTP $status: the key was rejected. Check LLM_API_KEY; keys can expire.";;
      404) fail "HTTP 404: check LLM_BASE_URL (…/openai/v1/) and LLM_MODEL (the deployment name).";;
      429) fail "HTTP 429: the endpoint is busy or over its quota. Wait a minute and try again.";;
      *) fail "HTTP ${status:-?}: $(head -c 300 <<<"$payload")";;
    esac
  fi
fi

echo
if (( failures > 0 )); then
  echo "$failures problem(s) found. See Reference > Troubleshooting on the workshop site."
  exit 1
fi
echo "Ready."
