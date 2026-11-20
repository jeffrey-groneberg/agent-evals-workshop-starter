# Agent Evals Workshop: starter

The project you work in during the **[Agent Evals Workshop](https://jeffrey-groneberg.github.io/agent-evals-workshop/)** ([简体中文](https://jeffrey-groneberg.github.io/agent-evals-workshop/zh-cn/)). The workshop site explains every step; this repository has the files the labs use.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/jeffrey-groneberg/agent-evals-workshop-starter)

## Get started

1. Select **Use this template** > **Create a new repository** to make your own copy. You need your own copy for Lab 7, where GitHub Actions runs your evals on pull requests.
2. Open your copy in a GitHub Codespace (**Code** > **Codespaces** > **Create codespace on main**), or clone it and open it in VS Code on your computer. A Codespace signs you in to GitHub Copilot by itself. On your computer, sign in with the GitHub CLI (`gh auth login`), create your settings file (`cp .env.example .env`) and load it into the terminal: `set -a; source .env; set +a`.
3. In the terminal, run `./scripts/check-setup.sh`.
4. Continue with [Lab 0](https://jeffrey-groneberg.github.io/agent-evals-workshop/labs/lab-0-setup/) on the workshop site.

The site's [Set up in a Codespace](https://jeffrey-groneberg.github.io/agent-evals-workshop/start/codespaces/) and [Set up on your computer](https://jeffrey-groneberg.github.io/agent-evals-workshop/start/local/) pages walk you through each step, including how the labs sign in to GitHub Copilot.

## What's in here

| Path | What it is |
| --- | --- |
| `.github/skills/release-notes/` | The skill under test. It starts with a bug. |
| `backlog.json` | The data the skill reads |
| `evals/` | Your evals. Lab 2 starts here. |
| `experiments/` | Experiment files for Labs 4 and 8 |
| `lab-files/` | Starter files for each lab |
| `solutions/` | Finished files for Labs 2, 4, 5 and 7, and a reference draft for Lab 6. The site shows each one in the lab's **Solution** section. |
| `skill-versions/before/` | A frozen copy of the original skill, for the experiment in Lab 4 |
| `scripts/check-setup.sh` | Checks your tools, your sign-in and, if you use one, your own model endpoint |
| `scripts/answers.sh` | Shows each trial's answer, tool calls and checks |
| `scripts/catch-up.sh` | Brings your files to the end of a lab, if you fall behind |
| `scripts/use-model.sh` | Switches the agent's model in every eval, if `claude-sonnet-5.5` isn't on your plan |
| `.devcontainer/` | The Codespace: Node.js 24, Vally 0.21.0, GitHub Copilot CLI, GitHub CLI, jq |

## About the tools

Vally is Microsoft's platform for AI evals, published on npm as `@microsoft/vally-cli`. GitHub Copilot Evals is in preview and runs evals with Vally. Both change quickly; the labs were tested with Vally 0.21.0 in November 2026.

## Author

Created by **Jeffrey Groneberg**, Senior Solution Engineer at Microsoft Germany. Connect on [LinkedIn](https://www.linkedin.com/in/jeffrey-groneberg-84b47412). Questions and fixes are welcome as issues in the [workshop repository](https://github.com/jeffrey-groneberg/agent-evals-workshop/issues).

## License

[MIT](LICENSE)
