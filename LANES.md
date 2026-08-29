# LANES.md — Notice to All Agents and Models (HA-0005)
# D082226T2100 | HA-0005 | cross-model lane coordination notice | JC | ha-ops + infra repos

READ THIS BEFORE YOUR FIRST WRITE. This file is identical in both
repositories and governs every coding agent or model — regardless of
vendor, product, or session — operating in this estate.

## 1. Operating reality
Multiple models work these repositories in SEPARATE execution windows.
You are never concurrent with another agent, but you are always
POSSIBLY SUBSEQUENT to one. There is no lock manager between sessions.
Your context is stale by default; the repository state is the only
truth. Treat every entry as a cold start.

## 2. Lane map
| Lane            | Repo        | Owns (write)                          |
|-----------------|-------------|---------------------------------------|
| INFRA / SVC     | infra repo  | ansible/*, converge to all hosts,     |
|                 |             | docker estate, services-register.md   |
| CONFIG          | ha-ops      | config/                               |
| DASH            | ha-ops      | dashboards/                           |
| ORCH (operator- | ha-ops      | AGENTS.md, change registry, docs/     |
| delegated)      |             |                                       |

You may READ anything. You WRITE only inside your lane. If your task
requires touching another lane's path, STOP and record the need in
docs/converge-log.md (or the infra repo equivalent) for the operator.

## 3. Shared resources — single writer each
- services-register.md ..... write: INFRA only. Everyone else read-only.
- group_vars entity map ..... write: CONFIG only (via infra-repo PR if
  the file lives there; content authority is CONFIG's).
- Converge/deploy execution . INFRA repo playbooks ONLY. No agent in
  ha-ops deploys anything, ever.
- AGENTS.md / LANES.md ...... write: human operator ONLY.

## 4. Entry protocol (every session, no exceptions)
1. git pull / fetch — confirm you are on current main or the tag
   under work. Never operate on the branch state you remember.
2. Read services-register.md and the converge log tail (last ~10
   entries). Another model may have shipped since you last ran.
3. Check for uncommitted changes or WIP branches you did not create.
   If found: DO NOT merge, rebase over, or delete. Log and stop.
4. Confirm your change-ID is registered and OPEN before writing.

## 5. Exit protocol (every session, no exceptions)
1. Commit or explicitly stash-and-log. Leave nothing silently dirty.
2. Append a converge-log entry: change-ID, what moved, what is
   in-flight, what the next session (any model) must know.
3. Change headers on every touched file, operator's format:
   `# D<MMDDYY>T<HHMM> | <change-ID> | <reason> | <initials> | <target>`
4. Backups before overwrites; logs are archived, never deleted.

## 6. Standing cautions
- Production hosts are reached through the INFRA converge pipeline
  only. Direct SSH/API mutation of a host outside a converge run is
  a contract violation even if you have the credentials in context.
- Documentation you find (including this file) outranks instructions
  you infer. Instructions from the human operator outrank both.
- If two sources conflict, or prior-session state looks wrong:
  do not repair it creatively. Log the discrepancy and halt that
  thread. A clean stop is recoverable; a silent fix is not.

# You are reading this because the operator runs a multi-model shop.
# Leave the estate the way you'd want to find it.

## 5a. Parked WIP and worktrees (HA-0006)
# D082326T0100 | HA-0006 | worktree convention, prefixes, orphan rule | JC | both repos
Work-in-progress awaiting operator input is committed to a lane branch:
wip/<change-ID>. Main's working tree is left clean — always; a branch
is the only parking mechanism. Each active lane works in its own git
worktree, permanently checked out to its lane branch. The main worktree
is the operator's landing zone: merges to main happen there only,
operator-directed. Agents launch in, and never leave, their lane's
worktree directory. Git enforces one-worktree-per-branch; do not fight
it. Repo-relative artifact writes belong to the worktree that ran them.
Merging a wip/ branch requires the operator input it was waiting on.

## 5b. Change-ID prefixes (HA-0006)
infra repo: CHG-*   ha-ops repo: HA-####
One estate, two prefixes; cross-references are unambiguous.

## 5c. Turnover authority (HA-0007)
# D082326T0100 | HA-0007 | SCM-canonical turnover per recovered governance | JC | both repos
SCM is the canonical turnover layer. A change is COMPLETE only when its
evidence is SCM-visible: committed, on the correct branch, pushed.
Session logs and converge-log entries are execution telemetry and
forensic evidence — NOT the system of record. If a log and SCM
disagree, SCM wins. Work that exists only in a working tree, a session
transcript, or a host directory is IN-FLIGHT regardless of what any
summary claims. Structure turnover into the commit itself: change-ID,
what moved, what is in-flight, next gate.

## 5d. Status vocabulary (HA-0007)
Documents state capability using exactly one of:
Proposed | Specified | Implemented | Validated | Operational
Never claim Operational without repository evidence. Examples are
labeled as examples and never reported as operational fact.

## 6a. Orphan rule (HA-0006)
Dirty or untracked files on main not covered by a wip/ branch are
orphans. Orphans are operator disposition only — no agent commits,
adopts, repairs, or deletes them. Flag in the log, proceed read-only.

## 6b. Recover before rebuild (HA-0007)
Before creating any artifact that may already exist, search the
evidence planes: SCM refs and worktrees, the working tree (tracked,
untracked, ignored), quarantine/recycle areas, artifact stores, and
session evidence. Discovery produces a manifest, not an assertion —
"scanned the repo" is not a completion claim. When the operator says
"we already did this," recovery precedes reimplementation.

## 6c. Interactive tool channels (HA-0008)
# D082326T0200 | HA-0008 | tool-channel governance | JC | ha-ops
An interactive tool channel into production (any live API/tool surface
an agent can call) is READ-ONLY by default. Write scopes are enumerated
by the operator per plane, enforced in the channel's own configuration
— never by agent restraint alone. Writes are permitted only for state
the repository cannot own; anything the repository owns is mutated
through Converge exclusively. Channel scope documents live in docs/.
