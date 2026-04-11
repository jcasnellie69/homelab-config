---
goal: Autonomous workspace hardening and metadata-driven homelab pipeline
version: 1
date_created: 2026-04-10
last_updated: 2026-04-10
owner: GitHub Copilot
status: In progress
tags: [process, architecture, infrastructure, devcontainer, mcp, ansible, terraform, github-actions, gitops, extensions]
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In_progress-yellow)

This plan defines a staged, auditable path to turn the repository into a more autonomous, metadata-driven homelab workspace. The focus is safe workspace hardening first, then secret hygiene, then pipeline automation for future systems such as OPNsense, NetBox-backed IPAM, Ansible execution, GitHub Actions orchestration, and Terraform-based VM builds.

## 1. Requirements & Constraints

- **REQ-001**: Every repo change must keep an evidence artifact under `artifacts/hc/`.
- **REQ-002**: Workspace tooling must avoid hardcoded secrets in repository-tracked files.
- **REQ-003**: Devcontainer and VS Code setup must support repo maintenance, docs, automation, and MCP workflows.
- **REQ-004**: The plan must support future OPNsense onboarding and metadata-driven infra generation.
- **SEC-001**: Move credential-bearing MCP settings to prompted inputs or environment variables.
- **CON-001**: Avoid destructive host or infrastructure changes without explicit confirmation.
- **CON-002**: Prefer small, reversible fixes over broad rewrites.
- **GUD-001**: Treat `/srv/homelab-config` as canonical and `z:\` as the active workspace mirror.
- **PAT-001**: Use function-scoped or stage-scoped custom agents for repeatable maintenance tasks.

## 2. Implementation Steps

### Implementation Phase 1

- **GOAL-001**: Stabilize the current workspace and reinforce evidence-first maintenance.

- **TASK-001** *(done 2026-04-10)*: Create a workspace instruction file under `.github/instructions/` for artifact/evidence enforcement.
- **TASK-002** *(done 2026-04-10)*: Audit `docs/` and `WIKI/` for broken local links and record evidence.
- **TASK-003** *(done 2026-04-10)*: Refine `.vscode/settings.json` and `.vscode/extensions.json` for repo hygiene, docs, YAML, Ansible, Terraform, and GitHub workflows.
- **TASK-004** *(done 2026-04-10)*: Improve `.vscode/mcp.json` and root `mcp.json` to remove hardcoded credentials and prefer prompted or environment-sourced secrets.
- **TASK-005** *(done 2026-04-10)*: Improve `.devcontainer/devcontainer.json` and `Dockerfile` for lighter, more repeatable workspace setup.

### Implementation Phase 2

- **GOAL-002**: Establish stage-based agent roles and metadata-driven pipeline structure.

- **TASK-006** *(done 2026-04-10)*: Create focused custom agents for docs audit, devcontainer triage, and infra pipeline planning.
- **TASK-007** *(done 2026-04-10)*: Define metadata flow from homelab inventory into GitHub Actions, Ansible, and Terraform artifacts.
- **TASK-008** *(done 2026-04-10)*: Add validation tasks or scripts to check docs health, workspace config health, and MCP config safety.

### Implementation Phase 3

- **GOAL-003**: Prepare for OPNsense, IPAM integration, and autonomous build execution.

- **TASK-009** *(done 2026-04-10)*: Add NetBox MCP integration design with secret-safe token handling and IPAM data contracts.
- **TASK-010** *(done 2026-04-10)*: Define OPNsense onboarding workflow driven by metadata, Terraform build outputs, and Ansible provisioning.
- **TASK-011** *(done 2026-04-10)*: Introduce non-user-dependent secret management patterns for automation runners and build agents.

### Implementation Phase 4

- **GOAL-004**: Add autonomous workspace governance for MCP inventory, extensions, and GitOps reporting.

- **TASK-012** *(done 2026-04-10)*: Create an `MCP Inventory Governor` agent to keep workspace MCP definitions and CLI-facing MCP usage aligned.
- **TASK-013** *(done 2026-04-10)*: Create an `Extensions and MCP Governor` agent to maintain recommended extensions and MCP-supportive tooling guidance.
- **TASK-014** *(done 2026-04-10)*: Create a `Workspace GitOps Monitor` agent for workspace drift review, safe commit/push action, and audit reporting.
- **TASK-015** *(done 2026-04-10)*: Add a machine-readable GitOps monitor report and safe branch-aware sync helper for autonomous workspace updates.

## 3. Alternatives

- **ALT-001**: Keep all logic in one large generic agent. Rejected because stage-specific agents are easier to audit and maintain.
- **ALT-002**: Store tokens directly in tracked config files. Rejected because this increases secret exposure risk.
- **ALT-003**: Solve the devcontainer issue only by rebuilding. Rejected because the current root cause is WSL disk exhaustion and needs direct remediation.

## 4. Dependencies

- **DEP-001**: Docker Desktop and WSL availability on the host.
- **DEP-002**: VS Code project-level MCP support via `.vscode/mcp.json`.
- **DEP-003**: Existing homelab metadata and inventory sources in this repository.
- **DEP-004**: Future NetBox and OPNsense endpoints plus automation credentials.

## 5. Files

- **FILE-001**: `.github/instructions/evidence-first.instructions.md`
- **FILE-002**: `.github/agents/space-maintainer.agent.md`
- **FILE-003**: `.vscode/settings.json`
- **FILE-004**: `.vscode/extensions.json`
- **FILE-005**: `.vscode/mcp.json`
- **FILE-006**: `mcp.json`
- **FILE-007**: `.devcontainer/devcontainer.json`
- **FILE-008**: `.devcontainer/Dockerfile`
- **FILE-009**: `artifacts/hc/2026-04-10-02-20-workspace-hardening.txt`
- **FILE-010**: `artifacts/hc/2026-04-10-03-05-metadata-pipeline-bootstrap.txt`
- **FILE-011**: `scripts/session/workspace_health.py`
- **FILE-012**: `scripts/session/build_pipeline_metadata.py`
- **FILE-013**: `scripts/session/bootstrap-root-automation.sh`
- **FILE-014**: `configs/automation-metadata.json`
- **FILE-015**: `.vscode/tasks.json`
- **FILE-016**: `.github/workflows/lint.yml`
- **FILE-017**: `scripts/session/generate_infra_artifacts.py`
- **FILE-018**: `scripts/session/tooling_currency.py`
- **FILE-019**: `scripts/session/gitops_sync.sh`
- **FILE-020**: `deploy/ansible/collections/requirements.yml`
- **FILE-021**: `deploy/ansible/bootstrap-control-node.sh`
- **FILE-022**: `reports/automation/ansible-inventory.json`
- **FILE-023**: `reports/automation/terraform.auto.tfvars.json`
- **FILE-024**: `reports/automation/opnsense-hosts.json`
- **FILE-025**: `reports/automation/netbox-sync.json`
- **FILE-026**: `artifacts/automation/tooling-currency-report.json`
- **FILE-027**: `artifacts/hc/2026-04-10-03-40-infra-pipeline-ansible-terraform.txt`
- **FILE-028**: `.github/agents/mcp-inventory-governor.agent.md`
- **FILE-029**: `.github/agents/extensions-mcp-governor.agent.md`
- **FILE-030**: `.github/agents/workspace-gitops-monitor.agent.md`
- **FILE-031**: `scripts/session/workspace_gitops_monitor.py`
- **FILE-032**: `artifacts/automation/workspace-gitops-monitor-report.json`
- **FILE-033**: `artifacts/hc/2026-04-10-05-10-gitops-monitor-agent.txt`
- **FILE-034**: `scripts/session/gitops_sync.ps1`
## 6. Testing

- **TEST-001**: Verify markdown link audit returns zero missing links in `docs/` and `WIKI/`.
- **TEST-002**: Verify updated JSON files remain valid and error-free in VS Code.
- **TEST-003**: Verify Docker Desktop WSL free space improves after targeted cache cleanup.
- **TEST-004**: Verify the devcontainer build or setup path proceeds past the previous "No space left on device" point.

## 7. Risks & Assumptions

- **RISK-001**: Unknown third-party MCP servers may require package names or auth flows not yet verified.
- **RISK-002**: Broad Docker pruning could remove useful cached assets if done without care.
- **ASSUMPTION-001**: This repo remains the metadata source for future infra automation.
- **ASSUMPTION-002**: Ansible, GitHub Actions, and Terraform remain the desired automation backbone.

## 8. Related Specifications / Further Reading

- `.github/copilot-instructions.md`
- `.github/agents/space-maintainer.agent.md`
- `.devcontainer/devcontainer.json`
- `.vscode/mcp.json`
