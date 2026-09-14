# Codex CLI Update Session

D082226 | CHG-CODEX-CLI-UPDATE-20260822 | log Codex CLI controlled update | JC | ct409

## Summary

Codex CLI was updated on CT 409 from `0.142.5` to `0.149.0` after confirming the npm update target was consistent with the active `/usr/local` install.

## Timeline

- 2026-08-22T20:21Z: Codex update prompt/cache indicated `0.149.0` was available.
- 2026-08-22T20:27Z: Root npm prefix was aligned to `/usr/local` with `/root/.npmrc`.
- 2026-08-22T20:31Z: Startup update checks were disabled in `/root/.codex/config.toml`.
- 2026-08-22T20:34Z: Preflight evidence and rollback package snapshot were created.
- 2026-08-22T20:35Z: `TERM=xterm-256color codex update` completed successfully.
- 2026-08-22T20:35Z: Verification confirmed `codex-cli 0.149.0`.

## Preflight

- `codex doctor` before update reported update availability and confirmed:
  - running package root: `/usr/local/lib/node_modules/@openai/codex`
  - npm update target: `/usr/local/lib/node_modules/@openai/codex`
  - startup update check: `false`
- A rollback package snapshot was captured before the update:
  - path: `/root/artifacts/codex-update-backups/codex-cli-0.142.5-20260822T203242Z.tgz`
  - size: `103M`
  - SHA256: `58bbabf1666753905319e0895780054da30471d40bcbaa3690ed1295d42a4384`

## Outcome

- `codex --version`: `codex-cli 0.149.0`
- `npm list -g --depth=0`: `@openai/codex@0.149.0`
- `codex doctor`: install/update/connectivity healthy; only `TERM=dumb` remains due to non-interactive execution
- Update tool output requested a Codex restart.

## Evidence

- `artifacts/hc/2026-08-22-2034-codex-cli-update-preflight.md`
- `artifacts/hc/2026-08-22-2035-codex-cli-update-outcome.md`
- `/srv/artifacts/hc/2026-08-22T203403Z-artifact.txt`
- `/srv/artifacts/hc/2026-08-22-2034-codex-cli-update-preflight.md`
- `/srv/artifacts/hc/2026-08-22T203550Z-artifact.txt`
