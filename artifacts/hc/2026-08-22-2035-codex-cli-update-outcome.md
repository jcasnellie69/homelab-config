# Codex CLI Update Outcome

D082226 | CHG-CODEX-CLI-UPDATE-20260822 | post-update evidence for Codex CLI upgrade | JC | ct409

- Timestamp: 2026-08-22T20:35:50Z
- Change ID: `CHG-CODEX-CLI-UPDATE-20260822`
- Host/context: `ct409` / `/root`
- Status: `COMPLETED`
- Update command: `TERM=xterm-256color codex update`
- Update action reported by Codex: `npm install -g @openai/codex`
- Previous version: `codex-cli 0.142.5`
- Installed version: `codex-cli 0.149.0`
- npm package verification: `@openai/codex@0.149.0`

## Verification

- `codex --version`: `codex-cli 0.149.0`
- `npm list -g --depth=0`: `/usr/local/lib` contains `@openai/codex@0.149.0`
- `/usr/local/bin/codex`: symlink to `../lib/node_modules/@openai/codex/bin/codex.js`
- `codex doctor`: `18 ok`, `0 warn`, update configuration current and install target consistent
- Remaining doctor failure: `TERM=dumb`; expected for non-interactive command execution context
- Connectivity checks in doctor: websocket connected; ChatGPT inference endpoint reachable

## Evidence Artifacts

- Preflight repo artifact: `artifacts/hc/2026-08-22-2034-codex-cli-update-preflight.md`
- Preflight live artifact: `/srv/artifacts/hc/2026-08-22T203403Z-artifact.txt`
- Mirrored preflight live artifact: `/srv/artifacts/hc/2026-08-22-2034-codex-cli-update-preflight.md`
- Outcome live artifact: `/srv/artifacts/hc/2026-08-22T203550Z-artifact.txt`
- Rollback package snapshot: `/root/artifacts/codex-update-backups/codex-cli-0.142.5-20260822T203242Z.tgz`
- Rollback package SHA256: `58bbabf1666753905319e0895780054da30471d40bcbaa3690ed1295d42a4384`
- Rollback config snapshot: `/root/artifacts/codex-update-backups/config.toml-20260822T203242Z`
- Rollback npm config snapshot: `/root/artifacts/codex-update-backups/npmrc-20260822T203242Z`

## Commands Run

```bash
TERM=xterm-256color codex update
codex --version
codex doctor
sed -n '1,120p' /usr/local/lib/node_modules/@openai/codex/package.json
npm list -g --depth=0
ls -l /usr/local/bin/codex
bash scripts/reporting/create_artifact.sh "CHG-CODEX-CLI-UPDATE-20260822: Codex CLI update completed successfully; 0.142.5 upgraded to 0.149.0; doctor healthy except expected TERM=dumb in non-interactive context"
```

## Operator Note

The updater reported: `Update ran successfully! Please restart Codex.` Start a new Codex session when convenient so the interactive host process is fully refreshed.
