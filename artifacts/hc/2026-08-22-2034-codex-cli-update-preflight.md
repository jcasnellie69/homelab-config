# Codex CLI Update Preflight

D082226 | CHG-CODEX-CLI-UPDATE-20260822 | pre-update evidence for Codex CLI upgrade | JC | ct409

- Timestamp: 2026-08-22T20:34:03Z
- Change ID: `CHG-CODEX-CLI-UPDATE-20260822`
- Host/context: `ct409` / `/root`
- Requested action: upgrade Codex CLI after confirming update availability
- Status: `PREFLIGHT_COMPLETE_UPDATE_NOT_YET_EXECUTED`

## Starting State

- Current Codex CLI: `codex-cli 0.142.5`
- Latest npm package: `@openai/codex 0.149.0`
- npm prefix: `/usr/local`
- npm global root: `/usr/local/lib/node_modules`
- Active package root: `/usr/local/lib/node_modules/@openai/codex`
- Startup update check: `false`
- Doctor status before update: install/update target consistent; only expected `TERM=dumb` failure in non-interactive context

## Evidence Artifacts

- Live evidence artifact: `/srv/artifacts/hc/2026-08-22T203403Z-artifact.txt`
- Rollback package snapshot: `/root/artifacts/codex-update-backups/codex-cli-0.142.5-20260822T203242Z.tgz`
- Rollback config snapshot: `/root/artifacts/codex-update-backups/config.toml-20260822T203242Z`
- Rollback npm config snapshot: `/root/artifacts/codex-update-backups/npmrc-20260822T203242Z`
- Rollback package size: `103M`
- Rollback package SHA256: `58bbabf1666753905319e0895780054da30471d40bcbaa3690ed1295d42a4384`

## Commands Run

```bash
codex --version
codex doctor
npm config get prefix
npm root -g
npm view @openai/codex version
du -sh /usr/local/lib/node_modules/@openai/codex
bash scripts/reporting/create_artifact.sh "CHG-CODEX-CLI-UPDATE-20260822: pre-update evidence for Codex CLI 0.142.5 to 0.149.0; update not yet executed"
tar -czf /root/artifacts/codex-update-backups/codex-cli-0.142.5-20260822T203242Z.tgz -C /usr/local/lib/node_modules/@openai codex
cp -a /root/.codex/config.toml /root/artifacts/codex-update-backups/config.toml-20260822T203242Z
cp -a /root/.npmrc /root/artifacts/codex-update-backups/npmrc-20260822T203242Z
sha256sum /root/artifacts/codex-update-backups/codex-cli-0.142.5-20260822T203242Z.tgz
```

## Rollback Note

If the upgrade breaks the active CLI, restore the package root from the tarball and preserve the failed upgraded tree for inspection before removing it.
