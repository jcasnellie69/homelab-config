## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.

## 2026-04-10 - Light/Dark Mode Toggle in Documentation
**Learning:** Users often prefer different color schemes based on their environment or visual needs. Static themes (like forcing dark mode with `slate`) can be harsh or difficult to read for some users. Providing a dynamic theme toggle greatly improves accessibility and user comfort.
**Action:** Always include a light/dark mode toggle configuration when setting up or modifying documentation themes (like Material for MkDocs) to accommodate user preferences.
