## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.

## 2026-04-13 - Accessible Documentation Themes
**Learning:** Hardcoded dark or light themes in documentation sites (like MkDocs) reduce accessibility and ignore user system preferences (`prefers-color-scheme`). Providing manual toggles and respecting system settings is an important UX pattern.
**Action:** Always configure the `theme.palette` section in `mkdocs.yml` with a media-query-based approach and include manual toggles (light/dark/auto) to maximize accessibility.
