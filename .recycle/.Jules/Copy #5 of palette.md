## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-04-08 - Code Copy & Scroll Tracking in Docs
**Learning:** Infrastructure and script documentation contains many code blocks and long configuration matrices. Users frequently copy/paste commands or share links to specific sections. The default MkDocs experience lacks one-click copying and dynamic URL hashing.
**Action:** Enabled `content.code.copy` and `navigation.tracking` in Material for MkDocs. Always enable these features by default for technical, code-heavy documentation sites to reduce manual selection errors and improve shareability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.
