# SESSION AUTOMATION FRAMEWORK — PERMANENT REFERENCE

## 1. Purpose
This framework provides z/OS-style session journaling for homelab development.  
It automatically creates properly structured session logs (Markdown + machine logs) with timestamps, operator headers, and persistent recordkeeping suitable for Git.

---

## 2. Entry Script
`/root/homelab-config/scripts/session/new-session.sh`

This script creates:

### Markdown session document:
`docs/session-logs/YYYYMMDD-HHMMSS-<SESSION>.md`

### Machine log:
`logs/sessions/YYYYMMDD-HHMMSS-<SESSION>.log`

Each session includes:
- ISO timestamp
- Sortable session ID
- z/OS-style header (DATE, CHGID, REASON, USER, SYSTEM)
- Operator notes section
- Commands section
- Results section

---

## 3. Directory Layout


