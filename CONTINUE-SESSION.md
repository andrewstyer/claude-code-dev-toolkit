# Continue {{PROJECT_NAME}} Development

**Read this first, then read HANDOFF.md**

**💡 NEW: Session Start Prompts** - See `docs/SESSION-START-PROMPTS.md` for effective prompts (if available)

---

## 🚨 MANDATORY PRE-FLIGHT CHECKLIST (READ THIS FIRST)

**STOP:** Before reading anything else, complete this checklist.

### Step 1: Check for Urgent Override (10 seconds)

**Did the user give you a specific task that's different from what's in HANDOFF.md?**

- **YES** → Ask user: "Should I work on [user's task] instead of [HANDOFF.md task]?"
  - Wait for confirmation before proceeding
  - After task complete, update HANDOFF.md for next session

- **NO** → Continue to Step 2

### Step 2: Read Handoff (1 minute)

Open `HANDOFF.md` and read the "Quick Start" section.

**What you should now know:**
- [ ] What is the next task?
- [ ] Why is it the priority?
- [ ] Estimated time?
- [ ] Any active blockers?

**If anything is unclear:** Ask the user before proceeding.

### Step 3: Check Blockers (if applicable - 2 minutes)

**Does your task relate to any topic in `BLOCKERS.md`?**

Examples: Build issues, test failures, known bugs, configuration problems

- **YES** → Read that BLOCKERS.md section BEFORE attempting work
  - Pay attention to "Failed Approaches" (DON'T repeat these!)
  - Note the "Approved Solution"
  - Read linked investigation if you need deep context

- **NO** → Skip to Step 4

### Step 4: Start Work

Now that you have context, proceed with your task.

**During work:**
- If you hit an error, check `../RECOVERY.md` scenarios first
- If you need deep investigation history, check `docs/investigations/INDEX.md` (if exists)
- If you discover a new "don't try this" lesson, add it to `BLOCKERS.md` immediately

## 💡 Keeping HANDOFF.md Current (During Long Sessions)

**After completing each major task or milestone:**
- Update "Next task" line in Quick Start section to reflect new priority
- Takes 30 seconds
- Ensures handoff is accurate if session ends unexpectedly

**Lightweight mid-session update (no validation needed):**
1. Open `HANDOFF.md`
2. Update ONLY these lines in Quick Start section:
   - "Next task:" - What should next dev work on now?
   - "Why:" - Why is this the new priority?
   - "Estimated time:" - Adjust if needed
3. Optionally add one line to "Context You Might Need" if you discovered something critical
4. Save and continue working

**You don't need to:**
- Rewrite the whole file
- Run validation script
- Archive anything
- Follow full END-SESSION.md process (that's for session end only)

**When to do lightweight updates:**
- After completing the current task listed in HANDOFF.md
- When priorities shift mid-session
- When user requests "update handoff"

**Full update happens at end of session** via END-SESSION.md checklist.

---

## What You Need to Know (2-minute version)

**Project:** {{PROJECT_NAME}} - {{PROJECT_DESCRIPTION}}
**Stack:** {{TECH_STACK_SUMMARY}}
**Methodology:** {{TDD_APPROACH}}

**Your job:** Continue implementing from where the last session left off

---

## Session Start Checklist

### 1. Get Context (5 minutes)
```bash
# See what's been done
git log -20 --oneline

# Check current state
git status

# Read handoff doc
cat HANDOFF.md
```

### 2. Verify Environment (2 minutes)
```bash
# Tests still passing?
{{TEST_COMMAND}}

# App still builds?
{{DEV_SERVER_COMMAND}}
```

### 3. Find Your Next Task (1 minute)

Look at `HANDOFF.md` → "Quick Start" section for "Next task"

OR look at `{{TASK_BREAKDOWN_DOC}}`

---

## Critical Rules (Never Break These)

1. **TDD is mandatory:** Write test first (RED) → Implement (GREEN) → Refactor
2. **Quality gates must pass:** Tests >{{COVERAGE_THRESHOLD}}% coverage, all tests passing
3. **Update HANDOFF.md:** After each session with progress (use END-SESSION.md template)
4. **Follow component specs:** Use `{{COMPONENT_SPEC_DOC}}`
5. **Handle errors properly:** Use error handling patterns from `{{ERROR_HANDLING_DOC}}`
6. **Don't assume; validate:** Always check for full logs and thoroughly investigate issues
7. **Use your resources!:** When you encounter an error more than once, check `../RECOVERY.md`

---

## Quick Reference

**Key docs:**
- Architecture: `{{ARCHITECTURE_DOC}}`
- Tasks: `{{TASK_BREAKDOWN_DOC}}`
- Components: `{{COMPONENT_SPEC_DOC}}`
- Status: `HANDOFF.md` ← **Check this every session**
- **Troubleshooting:** `../RECOVERY.md` ← **Use this if something's broken**

**TDD workflow:**
```
Write test ({{TEST_FILE_PATTERN}})
    ↓
Run test → FAILS (RED) ✅
    ↓
Write unit tests (if applicable)
    ↓
Implement code
    ↓
Run tests → PASS (GREEN) ✅
    ↓
Refactor + commit
```

**Quality gate:**
```bash
{{TEST_COMMAND}}              # All tests pass?
{{COVERAGE_COMMAND}}          # Coverage >{{COVERAGE_THRESHOLD}}%?
{{TYPE_CHECK_COMMAND}}        # No type errors?
{{BUILD_COMMAND}}             # Build succeeds?
```

---

## Now What?

1. ✅ Read `HANDOFF.md` (see what's complete, what's next)
2. ✅ Run verification commands above
3. ✅ Continue from "Next task"
4. ✅ **BEFORE ENDING**: Read `END-SESSION.md` and follow the checklist

**GO!**

---

## 🛑 Before You End This Session

**MANDATORY:** When you're done working, read `END-SESSION.md` and complete the session handoff checklist. This ensures:
- All quality checks pass
- HANDOFF.md is updated with structured template
- All work is committed
- Next developer can continue smoothly

**DO NOT skip this step!**
