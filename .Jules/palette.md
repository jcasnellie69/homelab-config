## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.
## 2025-02-23 - MkDocs Theme Toggle
**Learning:** Hardcoding a static theme (like 'slate') in MkDocs ignores user system preferences (`prefers-color-scheme`), which impacts accessibility and comfort. Providing a manual toggle with media queries is a much better approach.
**Action:** Always configure MkDocs with an interactive palette toggle that defaults to the user's system preferences using the `media` attribute.
