D101626 | CHG-137 | evidence for codex CLI health check | JC | PVE

Change: added scripts/hc/hc-codex-cli.sh and wired it into scripts/hc/hc-master.sh.
Checks `command -v codex`, `codex --version`, and that `check_for_update_on_startup = false`
is set in ~/.codex/config.toml (see issue #137 / docs/session-logs/20260822-codex-cli-update.md).
Verification: `bash -n scripts/hc/hc-master.sh`; ran the script in a host without codex -> [FAIL], exit 1.
