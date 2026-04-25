# Jules Handoff

## Safe areas for refactor

- `docs/*.md` structure and navigation
- `deploy/ansible/README.md`
- `deploy/ansible/roles/*` where behavior remains read-only
- `scripts/session/*` only when evidence generation and existing outputs stay stable
- generated reporting helpers that do not alter live infrastructure

## Areas not to change without operator review

- `artifacts/**` historical evidence
- live IP addresses, VMIDs, and hostnames unless new evidence proves a change
- `mcp.json` and `.vscode/mcp.json` secret-handling patterns
- any task or workflow that would make destructive Proxmox, VLAN, or switch changes

## Validation expectations

Any refactor should still pass or preserve:

- `workspace: health`
- `workspace: infra artifacts`
- inventory generation into `deploy/ansible/inventory/generated.yml`
- Markdown docs readability and link integrity
- evidence creation under `artifacts/hc/`

## Notes for async work

- Prefer modular changes with one domain per commit.
- Keep read-only discovery separate from execution playbooks.
- Document any new source-of-truth decision in `docs/source-of-truth.md`.
