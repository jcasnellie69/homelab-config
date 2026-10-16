# Scanning for Independent Writable Checkouts (Drift From CT409)

## Background

On 2026-07-12 (CR-0414/CR-0415), a routine Netdata-alert triage on `alpha`
turned up two separate problems:

1. The `hc` health-check pipeline (`scripts/hc/*` in this repo, deployed to
   `/srv/homelab-share/homelab-config` on `alpha`) had real bugs — a
   bullet-column parsing bug that silently made `pve-lxc-systemd-scan.sh`
   miss every failed unit it was meant to catch, and neither host-level nor
   guest disk/failed-unit detail was checked by `hc-master.sh` at all.
2. `alpha` turned out to have its **own independent, writable git checkout**
   of this repo at that deploy path — tracking `origin/master` directly, with
   real uncommitted work (password-redaction hardening in
   `hc-pve-guests.sh`, a local path patch to the `hc` wrapper) that existed
   nowhere else. CT409's CLAUDE.md documented CT409 as "the only writable
   checkout of homelab-config" — that was no longer true, and nobody had
   noticed.

That second finding is the one worth generalizing: any host in the fleet
could have quietly grown its own writable clone of a repo whose source of
truth is supposed to be CT409 + Ansible. This runbook documents how that one
was found and how to check the rest of the fleet the same way.

## How this instance was found

No tooling turned this up automatically — it was manual SSH reconnaissance,
in this order:

```bash
# 1. Find the script actually being run (`hc` on alpha turned out to be a
#    wrapper, not a standalone script)
ssh root@<host> 'type hc; cat "$(command -v hc)"'

# 2. Follow it to its real location and check whether that location is a
#    git working tree at all
ssh root@<host> 'cd <resolved-dir> && git status && git remote -v'

# 3. If it is, diff it against the CT409 checkout of the same repo to see
#    whether it has drifted (either side may be ahead)
ssh root@<host> 'cd <resolved-dir> && git diff -- <path>' # working-tree diff
diff <(ssh root@<host> 'cat <resolved-dir>/<path>') /mnt/repos/homelab-config/<path>
git -C /mnt/repos/homelab-config log --oneline -5 -- <path>  # CT409's history for the same file
```

The tell was step 2: `git status` succeeding at all on a host that was only
ever supposed to be a deploy *target*. A pure deploy target has no `.git`
directory; if `git status` returns something instead of "not a git
repository," that host has become a second source of truth by accident.

## Repeatable fleet-wide check

There's no scheduled job for this (per the standing order that nothing runs
on a schedule unless the code it executes is committed) — run it as a manual
audit, e.g. before trusting a host's copy of anything as current, or
periodically as a hygiene pass. From `deploy/ansible/`:

```bash
# Ad hoc, read-only: look for a .git directory under the paths each host is
# actually deployed to. Adjust the path list to match what's deployed where
# (see host_vars/*.yml and the playbooks under deploy/ansible/playbooks/).
ansible all -m ansible.builtin.find -a \
  "paths=/srv,/opt,/home patterns=.git file_type=directory recurse=yes depth=4" \
  2>&1 | grep -B2 '"path":'
```

Anywhere this finds a `.git` directory under a path that a playbook in this
repo deploys *to* (not a path that's supposed to be a real, intentional
checkout, e.g. an operator's own `/home/<user>/homelab-config` clone) is the
same class of drift found on `alpha`. Triage it the same way:

1. `git status` / `git diff` in place first — never delete before reading.
   There may be real, un-landed work (as there was here).
2. Diff against CT409's copy of the same paths; port anything genuinely new
   into `/mnt/repos/homelab-config` and commit it there.
3. Back up the full working tree (tracked + modified + untracked) both
   on-host and back to the CT409 controller before touching anything -
   see `hc-checkout-decommission.yml` for the pattern
   (`community.general.archive` + `ansible.builtin.fetch`, timestamp
   computed once via `set_fact` since `lookup('pipe', 'date ...')` is not
   memoized and will drift between references if used directly in `vars`).
4. Remove only `.git`. Leave every other file in place - a directory
   growing an accidental checkout is not evidence that its other contents
   are unwanted.
5. Redeploy via the appropriate playbook so the host goes back to receiving
   content instead of originating it.

## Related fixes from this pass

- `scripts/hc/pve-lxc-systemd-scan.sh` (CR-0410/CR-0417): failed-unit
  detection was silently broken; `systemctl` prefixes a bullet glyph on
  units needing attention, shifting every awk field by one.
- `scripts/hc/hc-guest-disk-and-units.sh` (CR-0412/CR-0417/CR-0418): new
  host+guest disk/memory/failed-unit scan, wired into `hc-master.sh`
  (CR-0413). Two secondary bugs found while building it, both fixed:
  `bash -lc` (login shell) was pulling container MOTD banners into every
  captured artifact; `LC_ALL=C` around `systemctl` avoids a UTF-8
  double-encoding bug in the `qm guest exec` JSON channel that corrupted the
  same bullet glyph.
- `deploy/ansible/playbooks/hc-pipeline-deploy.yml` (CR-0414): the only way
  `scripts/hc/*` should reach `alpha` going forward.
- `deploy/ansible/playbooks/hc-checkout-decommission.yml` (CR-0415): the
  backup-then-remove-`.git` playbook described above.

## Known gap surfaced but not fixed here

`deploy/ansible/group_vars/` is not actually on `ansible-playbook`'s
auto-load path in this repo's current layout (it's a sibling of both
`inventory/` and `playbooks/`, not of either individually - confirmed by
reproducing with a minimal single-task playbook). Both new playbooks above
set their vars explicitly rather than relying on it. Existing playbooks that
reference `group_vars/proxmox.yml` values (e.g. `proxmox_read_only`) may have
the same gap; worth checking before trusting group_vars-sourced values in
any playbook run from this layout.
