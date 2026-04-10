Agent Instructios

You are working in /srv/homelab-config (source of truth). Follow these rules:

1) Evidence-first: any change must create an artifact under /srv/artifacts/hc/<domain>/<timestamp>/ and/or a markdown note under /srv/homelab-config/docs.
2) No destructive actions: do not delete logs, do not wipe disks, do not remove packages, do not change firewall/DHCP/DNS unless explicitly requested.
3) Before overwriting any file, create a timestamped backup (short format like D121225T0333) using cp.
4) Prefer scripts over manual edits. Scripts must be idempotent and support a --dry-run where practical.
5) Group everything by tech domain (baseOS, network, storage, observability, automation, iot).
6) Output must include: what changed, how to run it, rollback notes.

When in doubt: generate the plan + the script, but do not execute it.