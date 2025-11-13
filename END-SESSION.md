# End Session - Health Narrative Development

**Use this checklist before ending ANY development session**

---

## 🛑 MANDATORY SESSION HANDOFF PROCESS

**DO NOT skip these steps.** The next developer depends on this handoff being complete and accurate.

---

## Step 1: Run Quality Checks (5 minutes)

Run these commands and verify all pass:

```bash
# 1. Verify all tests pass
npm test -- --coverage
# ✅ Must show: >80% coverage, all tests passing
# ❌ If failing: Fix tests before ending session

# 2. Verify E2E tests pass (if any exist)
maestro test .maestro/
# ✅ Must show: all tests passing
# ❌ If failing: Fix tests before ending session

# 3. Verify no TypeScript errors
npx tsc --noEmit
# ✅ Must show: "Found 0 errors"
# ❌ If errors: Fix TypeScript errors before ending session

# 4. Check git status
git status
# ✅ Should be clean or have only intentional uncommitted changes
# ❌ If unexpected changes: Review and commit or discard
```

**If ANY check fails, fix it before continuing. Do not proceed with uncommitted broken code.**

**⚠️ If quality checks are failing and you can't fix them:** See `RECOVERY.md` for troubleshooting steps.

---

## Step 2: Update SESSION-STATUS.md (5 minutes)

Open `SESSION-STATUS.md` and update:

### At the top:
- [ ] **"Last Updated"** - Today's date (YYYY-MM-DD format)
- [ ] **"Current Phase"** - Which phase are you in? (Phase 1, Phase 2, etc.)
- [ ] **"Last Developer"** - Your name or "Claude Code"
- [ ] **"Current status"** - One sentence summary of where things stand
- [ ] **"Next task"** - Specific next task number (e.g., "Task 2.1.3")

### In "Completed Work" section:
- [ ] **Check off completed tasks** - Mark [x] for all tasks you finished this session
- [ ] **Add git commit hashes** - List your commits with short descriptions
- [ ] **Update test counts** - Update "Test status" with actual numbers

### In "Current Work" section:
- [ ] **Update "Last commit"** - Paste your most recent commit hash and message
- [ ] **Update "Next immediate steps"** - List 3-5 specific next steps for continuation
- [ ] **Update "Working directory status"** - Note if there are intentional uncommitted changes

### In "Known Issues / Blockers" section:
- [ ] **Add any blockers** - Document anything that's stuck or needs attention
- [ ] **Add warnings** - Note anything the next developer should be aware of

### In "Test Status" section:
- [ ] **Update unit test numbers** - Exact pass/fail counts and coverage %
- [ ] **Update E2E test status** - List which E2E tests exist and their status

### In "Notes for Next Developer" section:
- [ ] **Add important context** - Anything non-obvious about what you did
- [ ] **Explain decisions** - Why you made certain technical choices
- [ ] **Document gotchas** - Anything tricky or confusing

---

## Step 2.5: Create/Update HANDOFF.md (MANDATORY - 5 minutes)

**Before ending your session, you MUST update HANDOFF.md for the next developer.**

### Before Writing

1. Check current size: `wc -l healthnarrative/HANDOFF.md`
2. If > 80 lines, archive current version first:
   ```bash
   cd healthnarrative
   ./scripts/archive-handoff.sh
   ```
   This will preserve the current HANDOFF.md to `archive/handoff/YYYY-MM-DD-session.md`

### Update Using Structured Template

**IMPORTANT:** Follow section line budgets strictly to prevent bloat.

```markdown
# Session Handoff - [Today's Date]

## Quick Start (READ THIS FIRST) - MAX 10 lines

**Next task:** [One sentence - what should next dev work on?]

**Why:** [One sentence - why is this the priority?]

**Estimated time:** [X hours]

**What just completed:** [One sentence summary of this session's work]

## State Check - MAX 5 lines

- [ ] All tests passing? Run `npm test`
- [ ] TypeScript clean? Run `npx tsc --noEmit`
- [ ] Git clean? Run `git status`

## Active Blockers - MAX 10 lines

[If none: "None - green light!"]

[If any: Brief 1-2 sentence summary + link to BLOCKERS.md section]
Example: "E2E tests failing due to iOS SDK issue. See BLOCKERS.md#ios-26-sdk-missing"

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

**Deep dive history:** See `archive/handoff/[dates].md`

## If Something's Wrong - MAX 10 lines

1. Check `BLOCKERS.md` first (known HN2-specific issues)
2. Check `../RECOVERY.md` scenarios (general troubleshooting)
3. Check `docs/investigations/INDEX.md` (deep investigation history)
4. If new issue: Follow systematic debugging, document in investigations/

---
TOTAL BUDGET: 90 lines (10 line buffer for flexibility)
**Full history:** `archive/handoff/` directory
```

### Verification Checklist

- [ ] Quick Start section < 10 lines
- [ ] Recent Session Summary has MAX 2 sessions (current + previous only)
- [ ] Context section has MAX 5 links
- [ ] Total HANDOFF.md < 100 lines: `wc -l healthnarrative/HANDOFF.md`
- [ ] Run validation: `cd healthnarrative && ./scripts/validate-docs.sh`
- [ ] "Next task" is clear and actionable (not vague)
- [ ] If you added/resolved blockers, BLOCKERS.md is updated
- [ ] If you created new investigation, it's added to docs/investigations/INDEX.md

### Common Fixes if Over Budget

- Move detailed investigations to `docs/investigations/` and link instead of embedding
- Keep only CURRENT session details in full, summarize previous session in 5 lines
- Replace long paragraphs with "See [doc]" links
- Remove redundant state checks that are already in git log
- Archive sessions older than 1 session back

**Why this matters:** The next developer will read HANDOFF.md first. If it's unclear or missing, they'll waste time figuring out what to do. If it's too long, they won't read it at all.

---

## Step 2.6: Update Knowledge Base (If Applicable - 2-5 minutes)

**Did you encounter a new failure pattern or find a better solution this session?**

### Decision Tree: Where to Document

```
Encountered an issue during development
    ↓
Is this the FIRST time seeing this issue?
├─ YES → Use RECOVERY.md if applicable, move on
│         (Only document if it required significant investigation)
└─ NO (seen 2+ times across sessions) → Update knowledge base
    ↓
    Is this specific to Health Narrative project?
    ├─ YES → Update healthnarrative/BLOCKERS.md
    │         • Add to ACTIVE section using template
    │         • Document failed approaches
    │         • Link to investigation doc if created
    └─ NO (applies to any Expo/RN/TS project) → Update RECOVERY.md
              • Add new scenario using template
              • Include diagnosis commands
              • Document recovery steps
```

### Updating BLOCKERS.md (Project-Specific Issues)

**When to update:**
- Issue is specific to Health Narrative codebase, architecture, or dependencies
- You tried 2+ approaches and want to document what NOT to try
- Issue is blocking or has wasted significant time (>30 minutes)

**How to update:**
1. Add to "ACTIVE" section using the template in BLOCKERS.md
2. Document symptoms, failed approaches, approved solution (or TBD if still investigating)
3. Link to investigation doc if you created one in `docs/investigations/`
4. Update "Last Updated" date at top of file

**Example:**
```markdown
## ⚠️ ACTIVE: Navigation Drawer Not Rendering

**Symptom:** Drawer button invisible in Release builds, E2E tests fail

**Failed Approaches:**
- ❌ Changing accessibility labels - Labels were correct
- ❌ Adjusting timing/waits - Not a timing issue

**Current Status:** P0 - Blocking E2E tests
**Investigation:** docs/investigations/2025-11-12-drawer-rendering-issue.md
**Next Step:** Check for blank screen errors in simulator logs
```

### Updating RECOVERY.md (General Issues)

**When to update:**
- Issue applies to ANY Expo/React Native/TypeScript project (not HN2-specific)
- Recovery steps are well-tested and reproducible
- Issue doesn't fit into existing RECOVERY.md scenarios

**How to update:**
1. Add new scenario to RECOVERY.md using the template at end of file
2. Include clear symptom description and diagnosis commands
3. Document step-by-step recovery process
4. Add prevention guidance

**Example:** See "Scenario 10" template in RECOVERY.md

### Validation

```bash
cd healthnarrative
./scripts/validate-docs.sh
```

Must pass before committing.

### Skip This Step If:

- [ ] No new issues encountered this session
- [ ] Issue was one-off and unlikely to recur
- [ ] Issue already documented in BLOCKERS.md or RECOVERY.md
- [ ] Issue resolved quickly (<10 minutes) and doesn't need documentation

---

## Step 3: Commit Everything (2 minutes)

```bash
# If you have uncommitted code changes, commit them first
git add .
git commit -m "feat(scope): descriptive message

- Detail what you implemented
- Note any important decisions
- Reference tests added

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Now commit the SESSION-STATUS.md file
git add SESSION-STATUS.md
git commit -m "docs: update session status after [brief work description]"

# Verify commits
git log -3 --oneline
```

**Verification:**
- [ ] All code changes committed?
- [ ] SESSION-STATUS.md committed?
- [ ] Commit messages descriptive?
- [ ] No uncommitted changes remaining? (run `git status` to verify)

---

## Step 4: Provide Session Summary

**Answer these questions to complete the handoff:**

### What was accomplished this session?
```
Example:
- Completed Task 2.1.1: Created sample-data-loading.yaml E2E test (RED phase)
- Completed Task 2.1.2: Implemented SampleDataService with JSON parsing
- Completed Task 2.1.3: Created useSampleData React Query hook
- All tests passing, coverage at 83%
```

### What's the next immediate task?
```
Example:
Next: Task 2.1.4 - Create HomeScreen component with sample data load button
Location: src/features/home/screens/HomeScreen.tsx
Reference: docs/plans/2025-10-31-detailed-task-breakdown.md (Phase 2, Section 2.1)
```

### Are there any blockers or warnings?
```
Example:
⚠️ Warning: Sample data JSON structure differs slightly from schema in one field
(event.metadata is sometimes null). Added null check in SampleDataService.

✅ No blockers - ready to continue
```

**📘 If you have blockers:** Document them in SESSION-STATUS.md and see `RECOVERY.md` for troubleshooting steps.

### Test status summary?
```
Example:
Unit tests: 34 passing, 0 failing (coverage: 83.2%)
E2E tests: 2 passing (app-launches.yaml, sample-data-loading.yaml)
TypeScript: 0 errors
Build: Successful
```

---

## ✅ Handoff Complete Checklist

Before closing this session, verify:

- [ ] All quality checks passed (tests, TypeScript, build)
- [ ] SESSION-STATUS.md fully updated with all sections
- [ ] All code changes committed with descriptive messages
- [ ] SESSION-STATUS.md committed
- [ ] Session summary provided (what done, what's next, blockers, test status)
- [ ] No uncommitted changes (`git status` shows clean)

**If all checked, session handoff is complete!** 🎉

---

## 🚨 What Happens If You Skip This?

**Bad handoff = wasted time:**
- Next developer spends 30+ minutes figuring out what you did
- Next developer might duplicate work or break working code
- Next developer might not know about blockers or important decisions
- Project momentum is lost

**Good handoff = smooth continuation:**
- Next developer reads SESSION-STATUS.md (5 minutes)
- Next developer knows exactly what to do next
- Next developer has context for all decisions
- Project maintains momentum

---

## Quick Reference Commands

```bash
# Quality checks (run all)
npm test -- --coverage && maestro test .maestro/ && npx tsc --noEmit && git status

# Update and commit session status
git add SESSION-STATUS.md
git commit -m "docs: update session status after [work description]"

# View recent work
git log -10 --oneline
```

---

**Session handoff is not optional. It's how we maintain quality across sessions.**

**Now complete the checklist above before ending this session!** 🚀
