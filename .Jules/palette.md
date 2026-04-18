## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.
## 2026-04-18 - Adaptive Color Schemes for MkDocs
**Learning:** Hardcoding a static color scheme (e.g., `slate`) in MkDocs Material theme reduces accessibility for users who prefer light themes or rely on system settings. Material provides an excellent out-of-the-box palette configuration that responds to media queries (like `(prefers-color-scheme)`) and offers manual toggles.
**Action:** Always replace static `scheme` definitions in `mkdocs.yml` with a responsive palette configuration that includes user toggles, ensuring the documentation interface is accessible to all users.
