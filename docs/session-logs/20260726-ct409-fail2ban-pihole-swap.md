D072626 | CHG-CT409-F2B-PIHOLE-CAP-001 | fail2ban self-ban recovery on CT409,
Pi-hole (LXC 115/Charlie) app-layer hang diagnosis+fix, CT409 capacity bump | JC | ct409+charlie

Session log. All actions below were performed live against production hosts;
each is listed with before/after state, backups taken, and verification.

---

## 1. CT 409 (`pve-ansible`, 192.168.4.52) — fail2ban self-ban from failed jail.local edit

**Symptom:** `ssh root@192.168.4.52` from operator laptop (192.168.4.143) timed out.
Root cause: fail2ban banned the laptop IP after a prior session's SSH-key delivery
attempt fell back to password auth and tripped the jail. A subsequent fix attempt
appended a second `[DEFAULT]` block to `/etc/fail2ban/jail.local` to widen
`ignoreip`; configparser rejected the duplicate key and the reload aborted
(nothing applied) — full detail preserved in the turnover doc this session opened
with (`D072626-F2B-IGNORE`, see prior message in session transcript).

**Fix applied:**
- Verified `/etc/fail2ban/jail.local.D072626T1125` was a clean pre-incident backup
  (diffed byte-for-byte against the broken file — confirmed).
- Took a second backup of the broken state: `jail.local.D072626T1143`.
- Removed the duplicate `[DEFAULT]` block; merged `192.168.4.0/24` into the
  original `ignoreip` line instead of a second section.
- `fail2ban-client reload` → `OK`, no errors.
- `fail2ban-client get sshd ignoreip` → confirmed `127.0.0.0/8`, `192.168.4.0/24`, `::1`.
- `iptables -S f2b-SSH` → only `-A f2b-SSH -j RETURN`, ban already clear, no
  `unbanip` needed.
- Operator confirmed SSH restored.

**Backups on CT409:** `/etc/fail2ban/jail.local.D072626T1125`,
`/etc/fail2ban/jail.local.D072626T1143` (both retained, not deleted per standing orders).

**Still open (not done this session):** Track B — deliver ed25519 key to CT409
and VM109 so SSH stops falling back to password (the actual root cause of the
ban trigger). Laptop's disconnected Ethernet 4 NIC holding a colliding static
`192.168.4.20` was handed off to Claude CLI on the laptop side, not tracked here.

---

## 2. Pi-hole (LXC 115 on Charlie, `192.168.4.208`) — app-layer hang, CPU pin, dead IPv6 upstream

**Symptom:** Pi-hole web UI/API (80/443) fully unresponsive — TCP handshake
completed and requests were ACKed, but zero response bytes ever returned (15s+
hangs, one connection stuck in FIN-WAIT-2). DNS (UDP 53) kept answering
individual queries in ~20ms throughout. SSH and the Netdata agent (port 19999,
co-located in the same LXC) were both unaffected — ruled out a whole-container
outage.

**Diagnosis (no SSH access to Charlie/115 initially — all via network probing,
then via alpha → Charlie → `pct exec 115` once access was arranged):**
- Netdata `systemd-services` function showed `pihole-FTL` pinned at ~99% CPU,
  on an LXC with only `cores: 1` (`pct config 115` on Charlie).
- `system.load` ~1.5 on a 1-core box; `system.cpu` breakdown was ~75% system +
  ~25% nice + ~0% user/iowait — busy-loop/thrashing signature, not legitimate
  query load. Disk was not the cause (`/` at 6.3% used).
- `/etc/pihole/pihole.toml` `dns.upstreams` included Cloudflare's IPv6
  addresses (`2606:4700:4700::1111`, `2606:4700:4700::1001`), but LXC 115's
  `net0` IPv6 address (`fd00:d300:35ea:1::208/64`) is a ULA with **no IPv6
  gateway configured** — those upstreams were permanently unreachable.
  `FTL.log` showed continuous `WARNING: Connection error
  (2606:4700:4700::1111#53): failed to send UDP request (Network unreachable)`
  every 1–15 minutes for hours. FTL's own embedded webserver (Pi-hole v6 has no
  separate lighttpd process — confirmed `lighttpd.service` inactive/disabled)
  appears to have starved on the same event loop.

**Fix applied:**
1. `pct set 115 -cores 2` on Charlie (was 1) — applied live, kept as headroom
   since this LXC serves DNS for the whole LAN. (This alone did **not** clear
   the hang — CPU usage after the bump was still ~100%, confirming the issue
   wasn't pure quota starvation.)
2. Backed up `/etc/pihole/pihole.toml` → `pihole.toml.D072626T0806` on LXC 115
   before any config write.
3. `pihole-FTL --config dns.upstreams '["1.1.1.1","1.0.0.1"]'` — dropped the
   two dead IPv6 entries, kept the working IPv4 pair. Applied live via FTL's
   own config mechanism; **no service restart was needed or performed.**

**Verification:**
- Web UI: HTTP 200 in 2.5ms (was: total hang). HTTPS: 200 in 11ms.
- `pihole-FTL` CPU: 99–100% → 0.47%. Worker tasks: 21 → 10.
- `system.load` (1-min): ~1.5 → ~0.83.
- DNS: still answering, ~21ms.

**Backups on LXC 115 (Charlie):** `/etc/pihole/pihole.toml.D072626T0806` (retained).

**Still open / flagged, not actioned:** IPv6 upstream resolution won't work
again until LXC 115's `net0` gets a real IPv6 gateway — don't just re-add those
two entries without that. Exact reason `pihole-FTL` looped into 99% CPU in the
first place (vs. a one-off trigger) wasn't root-caused beyond the dead-upstream
correlation — worth watching for recurrence.

---

## 3. CT 409 (`pve-ansible`) — memory/swap capacity bump

**Trigger:** Netdata Cloud alert — `used_swap` raised to Warning on `pve-ansible`,
91.3% swap utilization, raised at 2026-07-26 13:03:29 UTC (operator forwarded
the alert email/screenshot).

**Findings before change:** `pct config 409` on alpha showed `memory: 512`,
`swap: 512`, `cores: 1`. Live `free -h` showed only 4.3MiB RAM free, swap at
~74.5% (already draining down from the alerted peak). Largest single RAM
consumer on the box was this Claude Code session itself (~240MB RSS, 45.8% of
total RAM) — ahead of fail2ban, netdata-agent, mariadb (Semaphore's DB), the
Semaphore server, webmin, and filebrowser combined. `net0` on CT409 also has
`firewall=1` (PVE container-firewall layer) — separately explains an earlier
unrelated symptom (port scans timing out instead of RSTing) from this same
session's fail2ban investigation.

**Fix applied:** `pct set 409 -memory 1024 -swap 1024` on alpha (was 512/512).
Live, unprivileged LXC — no restart. Confirmed via `pct config 409`
before/after and `free -h`/`swapon --show` inside the container
(1.0Gi/1.0Gi, swap usage immediately relieved to ~36% of the new ceiling).

**Capacity note (flagged to operator, not actioned):** CT409's `cores: 1` was
sustaining a load average of ~1.65–1.70 even before this bump — that's CPU
contention, not memory. If Claude Code sessions run here regularly alongside
Semaphore/mariadb/netdata, a core bump (same move already made on Charlie's
LXC 115) is worth considering too. Operator asked to be kept an eye on this
going forward rather than act further right now.

---

## Cross-reference

This log was written from CT409 as instructed by standing orders (every
modified/touched system gets a compact change header; nothing here was
deleted, only backed up). Not committed to git as part of this session — the
checkout already carries pre-existing untracked/dirty content from the
separate OPNsense backlog (see `CLAUDE.md`); this file was added alongside it
without touching that state.
