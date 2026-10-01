# Repository Scan Agent

The repository scan agent performs a read-only inventory of Git repositories
under `/home`, `/mnt/repos`, and `/srv`. It records branch, upstream,
ahead/behind counts, dirty state, bounded porcelain status, last commit, and
filesystem utilization.

Discovery is bounded to five directory levels below each root and stops walking
when it reaches a repository boundary. This keeps hourly runtime predictable
while covering the server's standard repository locations.

`/root` is intentionally excluded from the scheduled default because it holds
large agent caches and private control data rather than managed server repos.
An operator can include it for a one-off scan with `--root /root`.

It never runs `fetch`, `pull`, `clean`, `commit`, `push`, or other commands that
modify a repository or contact a remote.

## Schedule

`repository-scan-agent.timer` runs hourly with up to ten minutes of randomized
delay. Persistent timer mode runs one missed scan after the server returns.

## Artifacts

The agent atomically replaces these bounded artifacts on each run:

- `/srv/artifacts/hc/repository-scan-latest.json`
- `/srv/artifacts/hc/repository-scan-latest.md`

Only the latest snapshot is retained, preventing scheduled scans from consuming
unbounded disk space.

## Operations

```bash
systemctl status repository-scan-agent.timer
systemctl start repository-scan-agent.service
journalctl -u repository-scan-agent.service
```

Deploy or reconcile the timer from the repository:

```bash
cd /mnt/repos/homelab-config/deploy/ansible
ansible-playbook playbooks/repository-scan-agent.yml
```
