# Repository Curator Policy

## Default Safety Model

Every discovered repository defaults to `report`. Mutation requires an exact
path allowlist entry.

Supported modes:

- `report`: inventory only.
- `checkpoint`: create local commits but do not push.
- `checkpoint-push`: create local commits and push a dedicated health branch.

Required policy fields:

```json
{
  "path": "/mnt/repos/example",
  "mode": "checkpoint-push",
  "remote": "origin",
  "branch_prefix": "repo-health",
  "protected_branches": ["main", "master", "production", "release/*"],
  "hard_validations": [],
  "advisory_validations": ["configured repository checks"],
  "include_untracked": true,
  "max_file_bytes": 10485760
}
```

## Hard Stops

- Unmerged index entries or interrupted merge/rebase/cherry-pick/revert.
- Private-key material, provider tokens, passwords in credential files, or
  another high-confidence credential signature.
- Changed files exceeding the configured size limit unless explicitly allowed.
- Detached or unborn `HEAD` when policy does not explicitly allow it.
- Missing push remote or a remote outside the policy allowlist.

## Advisory Results

Lint, docs builds, tests, formatting, unavailable dependencies, and
environment-specific checks are advisory by default. Capture command, exit
code, and bounded output in the checkpoint manifest and draft PR. A repository
may promote a specific command to `hard_validations`.

## Push Contract

Push the checkpoint commit with an explicit refspec:

```text
HEAD:refs/heads/repo-health/<host>/<UTC timestamp>
```

Never use `--force`, never push the protected source ref, and never embed a
credential in the remote URL. If push fails, retain the local commit and report
the refspec needed for recovery.

## Secret Evidence

Never store matching secret text. Record only:

- repository and relative path;
- detector identifier;
- SHA-256 fingerprint of the matched value;
- remediation state and rotation requirement.
