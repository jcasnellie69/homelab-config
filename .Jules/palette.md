## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.

## 2025-06-25 - Light/Dark Mode Toggles in Documentation
**Learning:** Hardcoding a dark (or light) theme in generated documentation sites reduces accessibility. Users have varying visual preferences and needs, and some experience eye strain reading light text on dark backgrounds (or vice-versa).
**Action:** Configure Material for MkDocs to respect the user's system color preference via `media` queries and provide a manual toggle switch between light and dark modes to ensure optimal readability.
