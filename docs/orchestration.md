# Orchestration Source of Truth

This document is the repo-level source of truth for **how this workspace brings on new technology, new automation, and new MCP-backed capabilities**.

It captures the practices used in the April 10, 2026 session and turns them into a repeatable operating model.

---

## 🎯 Purpose

Use this document when you need to:

- add a new MCP server
- onboard a new platform or capability
- introduce new VS Code or CLI automation
- wire new services into Alpha / Proxmox / NetBox / OPNsense workflows
- decide which instruction, agent, task, script, or workflow to create

---

## ✅ Core operating rules

1. **Evidence first**
   - Create or update a timestamped artifact in `artifacts/hc/`.
   - Record the reason, commands used, and verification results.

2. **Artifacts and reports are the record of truth**
   - Check `artifacts/`, `reports/`, and generated inventories before assuming IPs, hostnames, ports, CTIDs, or roles.

3. **Secrets never go in tracked files**
   - Use prompt inputs, environment variables, or a secret manager.
   - Track config shape, not raw credentials.

4. **Workspace before user drift**
   - Put shared definitions in workspace files first.
   - Use user-level configuration only for personal secrets or local overrides.

5. **Verification before completion**
   - No claim is complete until the relevant command, connection test, or report has been run and checked.

6. **Branch-safe GitOps**
   - Commit on a dedicated branch unless direct `main` work is explicitly approved.

---

## 🧭 Standard onboarding flow

### Phase 1 — Discover and frame

- Read the current instructions and evidence files.
- Confirm the target capability, expected scope, and dependencies.
- Identify whether the capability is:
  - documentation,
  - workspace instruction,
  - custom agent,
  - MCP definition,
  - local task/script,
  - infra automation.

### Phase 2 — Create evidence

- Add a timestamped file under `artifacts/hc/`.
- Include:
  - goal,
  - affected systems,
  - planned commands,
  - final verification output.

### Phase 3 — Wire the capability

Choose the right primitive:

| Need | Preferred primitive |
| --- | --- |
| Always-on repo behavior | `.github/instructions/*.instructions.md` |
| Focused multi-step operator behavior | `.github/agents/*.agent.md` |
| Shared MCP access | `mcp.json` + `.vscode/mcp.json` |
| Repeatable local execution | `.vscode/tasks.json` + `scripts/session/*` |
| Infra or service rollout | `deploy/ansible/**`, generated reports, and docs |
| Human guidance / runbook | `docs/*.md` |

### Phase 4 — Validate

Use live checks when possible:

- `python scripts/session/workspace_health.py --strict --report artifacts/automation/workspace-health-report.json`
- `python scripts/session/tooling_currency.py --report artifacts/automation/tooling-currency-report.json`
- targeted `Test-NetConnection`, `Invoke-WebRequest`, `git status`, or service startup tests

### Phase 5 — Report and push

- Update the evidence artifact with final results.
- Commit and push using the GitOps monitor workflow.
- Keep the branch auditable and reversible.

---

## 🔌 MCP onboarding method

When bringing in a new MCP server:

1. Confirm the upstream startup method.
2. Add the workspace definition to `.vscode/mcp.json`.
3. Add the automation-friendly definition to `mcp.json`.
4. Use prompt inputs or env variables for secrets.
5. Add or update a doc/runbook.
6. Run a startup-path or connectivity validation.

### Definition of done for MCP onboarding

- workspace config present
- root automation config present
- secrets are prompt/env based
- startup command validated
- endpoint reachability checked
- evidence artifact updated

---

## 🖥️ Infra onboarding method for Alpha / Proxmox

When bringing a new appliance or service into Alpha:

1. Confirm the host and inventory facts from artifacts.
2. Check management reachability first.
3. Add inventory, vars, and playbooks before attempting live changes.
4. Use `community.proxmox` for Proxmox lifecycle tasks.
5. Use service-specific collections such as `ansibleguy.opnsense` only after credentials are available.
6. Validate with syntax checks, connectivity tests, and generated reports.

### Definition of done for infra onboarding

- target host documented
- inventory and vars created
- automation path created
- credentials handled safely
- reachability verified
- final status recorded in artifacts and docs

---

## Worked example A — NetBox MCP

### NetBox inputs

- `docs/netbox mcp instructions.md`
- `reports/automation/netbox-sync.json`
- `artifacts/network-inventory.json`

### Workspace standard

- NetBox host hint: `192.168.4.140`
- MCP server launch path validated with:

```powershell
uvx --from git+https://github.com/netboxlabs/netbox-mcp-server netbox-mcp-server --help
```

### NetBox session result

- `uvx` launch path works on this workstation.
- The NetBox host responds to ICMP.
- Application ports tested from this workstation were refusing connections during this session, so authenticated live queries depend on CT 100 service availability.
- The workspace MCP configs should therefore be wired with prompt/env-based inputs and treated as the canonical integration point.

---

## Worked example B — OPNsense on PVE Alpha

### Alpha / OPNsense inputs

- `reports/automation/opnsense-hosts.json`
- `reports/automation/terraform.auto.tfvars.json`
- `deploy/ansible/inventory/generated.yml`
- `artifacts/network-inventory.json`

### Alpha target

- Proxmox host: `alpha`
- Management IP: `192.168.4.10`

### OPNsense session result

- Alpha management ports `22` and `8006` are reachable.
- OPNsense onboarding is scaffolded in Ansible for Alpha-based rollout.
- Live execution still depends on valid Proxmox API credentials and, once the VM is live, OPNsense API credentials.

---

## 🔒 Secret handling standard

Use these patterns only:

- prompt-backed inputs in `.vscode/mcp.json`
- environment-backed placeholders in `mcp.json`
- local runtime files outside git for real secret values

Never commit:

- bearer tokens
- API keys
- passwords
- private SSH material

---

## 📌 Ongoing maintenance expectations

Every new capability should leave behind:

- a doc or runbook
- a machine-readable output or validation report
- an artifact trail
- a safe commit on a non-main branch

If a future onboarding effort does not satisfy those four items, it is not complete.
