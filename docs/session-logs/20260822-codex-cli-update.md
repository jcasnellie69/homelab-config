# Codex CLI Update Session

D082226 | CHG-CODEX-CLI-UPDATE-20260822 | log Codex CLI controlled update | JC | ct409
D091426 | CHG-DOCKER-HC-REVIEW-FIX-20260914 | record npm prefix side effects and rollback path (review follow-up) | JC | ct409

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

## Side Effects of the npm Prefix Change

`/root/.npmrc` now pins `prefix=/usr/local`, so as root every `npm install -g` / `npm update -g` / `npm list -g` targets `/usr/local/lib/node_modules` rather than the Debian-packaged tree at `/usr/lib/node_modules` (which holds only `npm` and `corepack`). This follows the Debian convention (`/usr` distro-managed, `/usr/local` admin-managed) and is harmless while Codex is the only admin-installed global package, but note:

- `npm list -g` no longer shows anything installed under `/usr/lib`; use `npm list -g --prefix /usr` to see that tree.
- `/usr/local/bin` precedes `/usr/bin` in root's `PATH`, so a package later installed into both trees resolves to the `/usr/local` copy.
- The setting is root-only (`/root/.npmrc`); the `ansible` user and systemd units are unaffected (verified 2026-09-14: no `.npmrc` for `ansible`, no unit invokes node/npm).
- Claude Code CLI is the native installer at `/root/.local/share/claude/`, not an npm global, so it is unaffected. `/usr/lib/node_modules/@anthropic-ai/` is an empty leftover directory.

Rollback: restore `/root/artifacts/codex-update-backups/npmrc-20260822T203242Z` to `/root/.npmrc` (or delete `/root/.npmrc` to return to the distro default prefix). Note the snapshot was taken after the 20:27Z alignment, so it also contains `prefix=/usr/local`; the pre-alignment value was not captured.

## Evidence

- `artifacts/hc/2026-08-22-2034-codex-cli-update-preflight.md`
- `artifacts/hc/2026-08-22-2035-codex-cli-update-outcome.md`
- `/srv/artifacts/hc/2026-08-22T203403Z-artifact.txt`
- `/srv/artifacts/hc/2026-08-22-2034-codex-cli-update-preflight.md`
- `/srv/artifacts/hc/2026-08-22T203550Z-artifact.txt`
