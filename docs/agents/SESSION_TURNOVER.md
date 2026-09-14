# Agent Session Turnover Protocol

## Trigger

When Joe says **`TURNOVER`**, execute this protocol immediately. Do not ask for confirmation. Do not continue implementation work after the trigger.

## Purpose

Create a durable, repository-backed handoff so the next agent/session resumes from verified state instead of reconstructing completed work.

## Required behavior

1. Inspect the actual current workspace and repository state. Do not rely only on conversational memory.
2. Capture the current session state in `turnover/latest.md` using the required format below.
3. Never include secrets. Refer to credentials only by stored key/environment/template name.
4. Do not delete, reorganize, deduplicate, or clean `.recycle` during turnover.
5. Do not create new credentials during turnover.
6. Do not make additional infrastructure changes after turnover is triggered.
7. Commit `turnover/latest.md` and push it to the current tracked branch.
8. Verify the push succeeded. The GitHub Action `Session Turnover Archive` will validate and archive the turnover automatically.
9. Report only: pushed commit SHA, branch, turnover path, current gate/status, and exact next-session resume instruction.

## Required turnover format

```markdown
# Session Turnover

- Date/time:
- Agent/session:
- Branch:
- Commit before turnover:
- Current gate/status:

## Objective and Scope

## Work Completed

## Decisions Made

## Current Implementation State

## Files Created / Modified / Discovered

## IaC / Automation Involved

## Infrastructure Changes Applied

## Planned But Not Applied

## Validation and Evidence

## Errors / Failed Attempts / Partial Work

## Blockers

## Outstanding Work

## Credentials / Integrations Referenced

## Documentation / IaC / Live-State Discrepancies

## Critical `.recycle` Findings

## Logs / Artifacts / Evidence Locations

## Git State

## DO NOT REDO

## NEXT SESSION START HERE

1. Exact first executable step.
2. Next ordered step.
3. Verification gate before proceeding.
```

## Completion criteria

Turnover is not complete until:

- `turnover/latest.md` exists and contains all required sections.
- the file is committed;
- the commit is pushed successfully;
- the action can archive it from GitHub;
- the next session has a deterministic starting point.

## Next-session startup rule

A new agent/session must read, in this order, before changing anything:

1. repository standing agent instructions;
2. this turnover protocol;
3. `turnover/latest.md`;
4. any source files explicitly referenced by `NEXT SESSION START HERE`.

Resume from the turnover. Do not recreate completed work unless evidence proves it is invalid or absent.
