## 2026-04-17 - Added System Preference Dark Mode to Docs

The site previously hard-coded a `scheme: slate` palette.

I updated it to allow auto-detection from system level preferences `prefers-color-scheme`, while still including the option to toggle themes dynamically with buttons explicitly defined with screenreader friendly `name` attributes for the visually impaired.

This adds a subtle layer of user delight by avoiding sudden bright white flashes if the user prefers dark mode, and vice-versa, making the documentation consumption immediately comfortable.