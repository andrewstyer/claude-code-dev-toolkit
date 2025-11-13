# Session Handoff - {{PROJECT_NAME}}

**Template Version:** 2.0 (November 2025)
**Based on:** Health Narrative 2 documentation consolidation (Nov 7-13, 2025)

---

## Quick Start (READ THIS FIRST) - MAX 10 lines

**Next task:** [One sentence - what should next dev work on?]

**Why:** [One sentence - why is this the priority?]

**Estimated time:** [X hours]

**What just completed:** [One sentence summary of this session's work]

## State Check - MAX 5 lines

- [ ] All tests passing? Run `{{TEST_COMMAND}}`
- [ ] TypeScript clean? Run `{{TYPE_CHECK_COMMAND}}`
- [ ] Git clean? Run `git status`

## Active Blockers - MAX 10 lines

[If none: "None - green light!"]

[If any: Brief 1-2 sentence summary + link to BLOCKERS.md section]
Example: "E2E tests failing due to build configuration. See BLOCKERS.md#build-config"

## Recent Session Summary - MAX 40 lines (KEEP CURRENT + 1 PREVIOUS SESSION ONLY)

### [Today's Date] - Session N
**Accomplished:**
- [Bullet point - max 5 items]
- [Keep concise]

**Files changed:** [Count] files ([list key files only])
**Commits:** [Hashes with one-line descriptions]
**Issues encountered:** [Link to investigation OR 1 sentence + link]

### [Previous Date] - Session N-1
[Same format - keep ONE previous session for continuity]
[DELETE older sessions - they go to archive]

## Context You Might Need - MAX 15 lines

- [Link + one sentence description]
- [Link + one sentence description]
- [MAX 5 links total]

**Deep dive history:** See `archive/handoff/` directory

## If Something's Wrong - MAX 10 lines

1. Check `BLOCKERS.md` first (known project-specific issues)
2. Check `../RECOVERY.md` scenarios (general troubleshooting)
3. Check `docs/investigations/INDEX.md` (deep investigation history)
4. If new issue: Follow systematic debugging, document in investigations/

---
TOTAL BUDGET: 90 lines (10 line buffer for flexibility)
**Full history:** `archive/handoff/` directory

---

## Instructions for Using This Template

**When setting up a new project:**

1. Replace {{PROJECT_NAME}} with your project name
2. Update State Check commands with your actual commands
3. Initialize with first session information
4. Create `archive/handoff/` directory for old versions

**During development:**

**Mid-session updates (lightweight):**
- Update only Quick Start section (Next task, Why, Estimated time)
- No validation needed
- Takes 30 seconds

**End-of-session updates (full):**
- Use END-SESSION.md checklist
- Follow structured template with line budgets
- Run validation script: `./scripts/validate-docs.sh`
- Archive when > 80 lines: `./scripts/archive-handoff.sh`

**See also:**
- END-SESSION.md - Complete handoff checklist
- CONTINUE-SESSION.md - How to start a new session
- RECOVERY.md - Troubleshooting guide
- Documentation constraints design: case-studies/healthnarrative2-documentation-system.md
