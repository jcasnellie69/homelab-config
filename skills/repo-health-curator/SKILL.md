---
name: repo-health-curator
description: Curate accumulated tracked and untracked repository changes into secret-safe checkpoint branches and reviewable pull requests. Use for scheduled repository health automation, dirty worktree backlogs, generated documentation drift, advisory validation failures, secret remediation, checkpoint commits, cloud-agent handoff, or cleanup of local server repository copies without discarding work.
---

# Repository Health Curator

Convert local repository drift into recoverable checkpoint commits and cloud
review work without silently discarding files or pushing directly to protected
branches.

## Invariants

- Never run `reset --hard`, `clean`, automatic stash, force-push, or direct push
  to `main`, `master`, production, release, or deployment branches.
- Treat unresolved merges, rebases, cherry-picks, and high-confidence secrets as
  hard stops.
- Treat lint, formatting, documentation, test, and environment-dependent
  validation failures as advisory. Preserve their output and continue to a
  draft checkpoint PR unless repository policy makes a check mandatory.
- Keep the working files unchanged. A checkpoint records existing content; it
  does not rewrite or delete it.
- Redact secret values from logs, artifacts, commit messages, and PR bodies.

## Workflow

1. Read the repository policy. See
   [references/policy.md](references/policy.md) for required gates and defaults.
2. Capture branch, upstream, status, staged state, in-progress Git operations,
   filesystem capacity, and recent commit convention.
3. Classify changes by intent: documentation, generated artifacts,
   infrastructure, automation, source, tests, dependency metadata, or unknown.
4. Scan changed content and paths for high-confidence credentials. If found,
   stop before staging or pushing. Record only file path, detector name, and a
   content fingerprint. Use the repository's established vault integration to
   replace the credential reference and require rotation of exposed values.
5. Run configured validations. Separate hard gate failures from advisory
   warnings. Do not suppress hooks or fabricate success.
6. Create atomic commits when intent is clear. If backlog cannot be separated
   reliably, create one explicitly labeled checkpoint commit rather than
   inventing ownership or purpose.
7. Push only to `repo-health/<host>/<UTC timestamp>` or the policy-defined
   prefix. Never update the protected source branch ref on the remote.
8. Create or update a draft PR containing change groups, secret-scan outcome,
   validation warnings, source host, artifact links, and recommended cloud-agent
   follow-up.
9. Let CI, Jules, and other configured repository agents refine the pushed
   branch. Route CI failures to the CI-fix workflow and review feedback to the
   review-comment workflow.
10. Record commit SHA, pushed ref, PR URL, warnings, and recovery instructions
    in the repository-health artifact.

## Decision Rules

- **Clean repository:** report healthy; do not create an empty commit or PR.
- **Documentation or generated output only:** checkpoint and push; validation
  warnings remain advisory unless the content cannot be parsed.
- **Mixed backlog:** group obvious independent intents. Use one checkpoint for
  ambiguous residue and ask cloud agents to split it in the PR.
- **Conflict or interrupted Git operation:** stop and request targeted conflict
  resolution. Do not auto-select ours/theirs.
- **Likely secret:** do not push. Remediate locally through the established
  secret manager, rotate if exposed, then rescan.
- **Push authentication failure:** retain the local checkpoint commit and report
  the exact recovery ref. Never rewrite or delete the commit.

## Repository Integration

Use `scripts/reporting/scan_repositories.py` for discovery and evidence. Use the
scheduled curator only for policy-allowlisted repositories. Cloud-side PR
creation and repair should use the connected GitHub workflows rather than
embedding credentials in server scripts.
