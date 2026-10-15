# Repository agents

This file provides example agent definitions and usage notes for the homelab-config repository. These are suggestions for custom agents (document-only); actual agents can be created under `.github/agents/` using the agent manifest format.

## reporting-runner

- Use when: you want an interactive agent that can run the periodic reporting flow and explain results.
- What it does: invokes the repository scripts in order: `collect_inventory.sh`, `collect_health.sh`, then `publish_docs.sh`.
- Restrictions: the agent should not implement collection logic; it should only call the repository scripts.

Example invocation (human): "Run the nightly reporting collection and publish docs; show me the top 3 fragments created."

## artifact-creator (utility)

- Use when: an agent or human wants to create a timestamped evidence artifact under `/srv/artifacts/hc/` describing a change or run.
- What it does: calls a small script `scripts/reporting/create_artifact.sh "Message text"` which writes a timestamped `.txt` file under `/srv/artifacts/hc/`.

## repo-health-curator

- Use when: a `repo-health/*` checkpoint branch or draft PR contains accumulated
  server-side tracked, untracked, generated, or documentation changes.
- What it does: follows `skills/repo-health-curator/SKILL.md` to classify the
  backlog, preserve secret safety, treat ordinary validation failures as
  advisory, split changes into reviewable commits where evidence supports it,
  and leave the branch ready for human review.
- Restrictions: never expose detected secret values, force-push, auto-merge,
  discard ambiguous files, or push directly to a protected branch.
