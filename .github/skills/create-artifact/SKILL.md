---
name: create-artifact
user-invocable: true
description: "Create a timestamped evidence artifact under /srv/artifacts/hc. Use when you need to document a change or run before making edits."
---

# Create artifact skill

Use this skill to create a small, timestamped artifact file under `/srv/artifacts/hc/` documenting a change, run, or reasoning. It calls the repository helper script `scripts/reporting/create_artifact.sh`.

Usage examples:

- `/create-artifact "Change: updated reporting scripts"`
- `/create-artifact "Run: collected inventory for host x"`

Behavior:

- The skill runs `scripts/reporting/create_artifact.sh <message>` from the repository root.
- It returns the path of the created artifact so humans and other agents can reference it.
