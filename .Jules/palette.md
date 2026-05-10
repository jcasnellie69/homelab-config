## 2025-04-25 - Dynamic Color Scheme Toggle
**Learning:** Hardcoding a static color theme (like `slate`) limits accessibility for users preferring a light mode or those who rely on system preferences. Using `prefers-color-scheme` in `mkdocs.yml` allows the documentation to automatically adapt to user OS settings. Adding a manual toggle control lets users easily override this preference on a per-session basis, providing maximum accessibility.
**Action:** When configuring documentation themes (e.g., Material for MkDocs), avoid static single-theme choices and implement responsive palettes with explicit toggles as a standard practice for better usability.
## 2025-04-04 - UX in Documentation-as-Code
**Learning:** In repositories without a traditional web UI (like homelab scripts), UX enhancements can still be applied to generated documentation interfaces (e.g., MkDocs). Material for MkDocs provides excellent built-in UX features that improve navigation and accessibility, such as back-to-top buttons and search highlighting.
**Action:** Always check `mkdocs.yml` or similar documentation configuration files in infrastructure or script-heavy repositories for quick wins in accessibility and searchability.

## 2025-05-18 - Copy-to-clipboard for Code Blocks
**Learning:** In technical documentation, code blocks are heavily utilized. Users often need to copy the configuration or commands from these blocks to their terminal.
**Action:** Always enable `content.code.copy` feature in `mkdocs.yml` when using Material for MkDocs to significantly improve user experience when consuming technical documentation.

## 2026-04-24 - Dynamic Theme Toggle
**Learning:** Hardcoded dark mode (`slate`) reduces accessibility for users who prefer or require light mode.
**Action:** Implementing `prefers-color-scheme` with manual toggles empowers users and respects system settings.
## 2026-04-23 - Color Scheme Toggle for Material for MkDocs
**Learning:** Hardcoding a documentation site's color scheme (like forcing `slate` for dark mode) is poor UX and accessibility. Users have varying visual preferences and system settings. The `mkdocs-material` theme supports an automatic color palette that syncs with `(prefers-color-scheme)` media queries and allows for a manual toggle.
**Action:** When configuring Material for MkDocs, always use the array format for `palette` with `media` queries to respect user system preferences (light/dark mode) by default, while providing a manual toggle.
## 2025-05-18 - Responsive Color Palettes in MkDocs
**Learning:** Hardcoding a single theme (e.g., `scheme: slate`) in MkDocs documentation limits accessibility and ignores user system preferences. Material for MkDocs supports media queries like `(prefers-color-scheme)` to detect the user's OS preference, and toggles can be added for manual control.
**Action:** Always implement a responsive color palette array instead of a single hardcoded scheme in `mkdocs.yml` to improve visual accessibility and respect user settings.
## 2025-02-23 - MkDocs Theme Toggle
**Learning:** Hardcoding a static theme (like 'slate') in MkDocs ignores user system preferences (`prefers-color-scheme`), which impacts accessibility and comfort. Providing a manual toggle with media queries is a much better approach.
**Action:** Always configure MkDocs with an interactive palette toggle that defaults to the user's system preferences using the `media` attribute.

## 2025-10-24 - Dynamic Theme Selection for Accessibility
**Learning:** Hardcoding a static dark theme ('slate') in MkDocs ignores user system preferences. This can cause discomfort or accessibility issues for users who prefer or require a light interface, as they are forced into dark mode with no built-in way to change it.
**Action:** Always configure MkDocs themes to respond to system media queries (`prefers-color-scheme`) and provide a manual toggle switch to let users choose their preferred visual experience.
## 2026-04-18 - Adaptive Color Schemes for MkDocs
**Learning:** Hardcoding a static color scheme (e.g., `slate`) in MkDocs Material theme reduces accessibility for users who prefer light themes or rely on system settings. Material provides an excellent out-of-the-box palette configuration that responds to media queries (like `(prefers-color-scheme)`) and offers manual toggles.
**Action:** Always replace static `scheme` definitions in `mkdocs.yml` with a responsive palette configuration that includes user toggles, ensuring the documentation interface is accessible to all users.

## 2025-05-19 - Dynamic Color Scheme Preferences
**Learning:** Hardcoding a single theme (like `scheme: slate`) forces users into a viewing experience that may ignore their system-level accessibility settings (e.g., `prefers-color-scheme`). Allowing user choice is a key accessibility principle.
**Action:** When configuring documentation themes like Material for MkDocs, implement dynamic palettes that respect system preferences while providing manual toggles to switch between light and dark modes.
## 2026-04-15 - Dynamic Color Schemes in Documentation
**Learning:** Hardcoded color schemes (like `slate`) in documentation themes ignore user system preferences, creating accessibility issues for users who require specific contrast levels.
**Action:** Always configure documentation color schemes to use media queries (`prefers-color-scheme`) with a manual toggle switch to respect user preference and maximize accessibility.
## 2025-04-14 - Accessibility via Media Queries in MkDocs
**Learning:** Hardcoding a static documentation theme (e.g., exclusively dark mode) creates accessibility barriers for users who rely on different contrast levels or have specific systemic color preferences.
**Action:** Implement dynamic color palettes utilizing `prefers-color-scheme` media queries alongside descriptive, manual toggles in `mkdocs.yml` to maximize readability and conform to user OS-level accessibility settings.
## 2026-04-13 - Accessible Documentation Themes
**Learning:** Hardcoded dark or light themes in documentation sites (like MkDocs) reduce accessibility and ignore user system preferences (`prefers-color-scheme`). Providing manual toggles and respecting system settings is an important UX pattern.
**Action:** Always configure the `theme.palette` section in `mkdocs.yml` with a media-query-based approach and include manual toggles (light/dark/auto) to maximize accessibility.
## 2026-04-12 - Respecting System Color Preferences in Documentation Sites
**Learning:** Hardcoding a static color theme (like `slate`) for documentation sites forces users into a specific visual experience, which may ignore their system-level accessibility or visual preferences.
**Action:** Use media queries (e.g., `prefers-color-scheme`) combined with manual toggles in MkDocs and similar frameworks to ensure users receive their preferred color scheme automatically while retaining the ability to override it.

## 2025-06-25 - Light/Dark Mode Toggles in Documentation
**Learning:** Hardcoding a dark (or light) theme in generated documentation sites reduces accessibility. Users have varying visual preferences and needs, and some experience eye strain reading light text on dark backgrounds (or vice-versa).
**Action:** Configure Material for MkDocs to respect the user's system color preference via `media` queries and provide a manual toggle switch between light and dark modes to ensure optimal readability.

## 2026-04-26 - Navigation Breadcrumbs
**Learning:** In deeply nested documentation structures (like MkDocs sites), users can easily lose track of their current location within the hierarchy. Adding breadcrumbs improves orientation and provides a quick way to navigate back up the tree.
**Action:** Always enable `navigation.path` in `mkdocs.yml` when configuring the Material for MkDocs theme to enhance usability and navigational context.
## 2025-05-18 - Navigation Breadcrumbs
**Learning:** In deeply nested documentation structures (like MkDocs sites), users can easily lose track of their current location within the hierarchy. Adding breadcrumbs improves orientation and provides a quick way to navigate back up the tree.
**Action:** Always enable `navigation.path` in `mkdocs.yml` when configuring the Material for MkDocs theme to enhance usability and navigational context.
