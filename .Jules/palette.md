## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.

## 2025-04-14 - Accessibility via Media Queries in MkDocs
**Learning:** Hardcoding a static documentation theme (e.g., exclusively dark mode) creates accessibility barriers for users who rely on different contrast levels or have specific systemic color preferences.
**Action:** Implement dynamic color palettes utilizing `prefers-color-scheme` media queries alongside descriptive, manual toggles in `mkdocs.yml` to maximize readability and conform to user OS-level accessibility settings.
