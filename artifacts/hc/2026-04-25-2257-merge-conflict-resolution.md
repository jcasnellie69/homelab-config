# Merge Conflict Resolution — 2026-04-25T22:57Z

## Branch
`palette-ux-theme-toggle-6897184762714602614` ← `origin/main`

## Conflicts Encountered

| File | Type | Resolution |
|------|------|------------|
| `.Jules/palette.md` | modify/delete | Accepted deletion (main removed `.Jules/` directory) |
| `mkdocs.yml` | content merge | Auto-resolved cleanly — PR's light/dark palette preserved |

## Outcome
- `mkdocs.yml` retains the dual-palette (light + dark) toggle introduced by this PR.
- `.Jules/palette.md` removed to align with `main` which cleaned up the `.Jules/` directory.
- Merge commit finalised with both parents: PR HEAD and `origin/main`.
