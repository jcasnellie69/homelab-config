# UX Improvement: Accessible Documentation Theme

## Description
Updated the MkDocs configuration (`mkdocs.yml`) to improve accessibility and user experience by replacing the hardcoded `slate` color scheme with a media query based approach.

## Changes
- Configured MkDocs to respect `prefers-color-scheme` by default.
- Added manual toggles to allow users to switch between light mode, dark mode, and system preference.
- Documented this accessibility pattern as a learning in `.Jules/palette.md`.

## Verification
- Ran `mkdocs build` to ensure the configuration is valid and builds without errors.
- Verified all python and bash tests pass with no regressions.
