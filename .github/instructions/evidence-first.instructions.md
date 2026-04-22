---
name: Evidence-First Workspace Maintenance
description: "Use when changing docs, automation, devcontainer files, MCP settings, scripts, or workspace configuration in this homelab-config repo. Reinforces evidence artifacts, secret hygiene, and verification-before-completion."
applyTo:
  - ".github/**"
  - ".devcontainer/**"
  - ".vscode/**"
  - "docs/**"
  - "scripts/**"
  - "deploy/**"
  - "configs/**"
  - "mcp.json"
---
# Evidence-First Workspace Rules

- Create or update a timestamped artifact under `artifacts/hc/` before or during every repo change.
- Record the reason for the change, the commands used, and the verification output.
- Never claim a fix is complete without fresh evidence from the relevant command, test, build, or audit.
- Never hardcode secrets, tokens, or credentials in tracked files. Prefer prompt inputs, environment variables, or a secret manager.
- Prefer minimal root-cause fixes over unrelated cleanup.
- Consult `artifacts/`, `reports/`, and generated inventories as the record of truth for IPs, CTIDs, hostnames, and prior evidence before making assumptions.
- For docs changes, run a local link or build check when practical.
- For devcontainer, automation, or workflow changes, keep the path reproducible and easy to audit.
