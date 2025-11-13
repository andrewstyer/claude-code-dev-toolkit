# ⚠️ DEPRECATED: Use HANDOFF.md Instead

**This file is deprecated as of November 2025 (v2.0)**

**Use instead:** `HANDOFF.md` (< 100 lines, prevents documentation drift)

**Why the change:** SESSION-STATUS.md tended to grow to 1000+ lines, defeating its purpose. HANDOFF.md uses structured templates with line budgets and automated validation.

**Migration guide:** See UPDATE-NOTES.md

---

# {{PROJECT_NAME}} - Current Session Status (DEPRECATED)

**Last Updated:** [DATE]
**Current Phase:** [Phase X - Name]
**Last Developer:** [Your name or "Claude Code"]

---

## 🎯 Quick Context for New Session

**What we're building:** {{PROJECT_DESCRIPTION}}

**Current status:** [BRIEF SUMMARY - e.g., "Foundation complete, starting core features"]

**Next task:** Task [X.X.X] from `{{TASK_BREAKDOWN_DOC}}`

---

## ✅ Completed Work

### Phase 1: {{PHASE_1_NAME}} [STATUS]
- [ ] Task 1.1.1: [Task description]
- [ ] Task 1.1.2: [Task description]
- [ ] Task 1.1.3: [Task description]

**Git commits:**
- `abc123` - [commit message]
- `def456` - [commit message]

**Test status:**
- Tests: [X] passing, [X] failing (coverage: [X]%)

### Phase 2: {{PHASE_2_NAME}} [STATUS]
- [ ] Task 2.1.1: [Task description]
- [ ] Task 2.1.2: [Task description]

---

## 🚧 Current Work

**Active branch:** `main` (or feature branch name)

**Last commit:**
```
[commit-hash] - [commit message]

- [Detail 1]
- [Detail 2]
```

**Working directory status:**
```bash
# Run this to see current state:
git status
```

**Next immediate steps:**
1. [Specific next action]
2. [Specific next action]
3. [Specific next action]

---

## 🔴 Known Issues / Blockers

**None currently** (update this if you encounter blockers)

---

## 📊 Test Status

**Tests:**
```bash
{{TEST_COMMAND}}

# Current results:
Tests:       [X] passed, [X] total
Coverage:    [X]% (threshold: {{COVERAGE_THRESHOLD}}%)
```

**Type Checking:**
```bash
{{TYPE_CHECK_COMMAND}}

# Current results:
[No errors / X errors]
```

**Build:**
```bash
{{BUILD_COMMAND}}

# Current results:
[Build successful / Build failed]
```

---

## 🎨 Architecture Decisions Made

**Tech stack confirmed:**
- {{LANGUAGE}} ({{LANGUAGE_VERSION}})
- {{FRAMEWORK}}
- {{DATABASE}}
- {{TEST_TOOL}}

**Key patterns established:**
- [e.g., "Error handling pattern decided: Result<T> for all async operations"]
- [e.g., "State management: Using X library"]
- [e.g., "File structure: Feature-based organization"]

---

## 📝 Notes for Next Developer

**Important context:**
- [Any context about what's been done]
- [Any decisions that were made and why]
- [Any gotchas or tricky parts]

**Don't forget:**
- Run `{{DEV_SERVER_COMMAND}}` to start dev environment
- Run `{{TEST_COMMAND}}` to verify tests
- Update this file after each session with progress

**Reference docs:**
- Implementation plan: `{{ARCHITECTURE_DOC}}`
- Task breakdown: `{{TASK_BREAKDOWN_DOC}}`
- Component specs: `{{COMPONENT_SPEC_DOC}}`

---

## 🚀 Commands Reference

**Development:**
```bash
{{DEV_SERVER_COMMAND}}         # Start dev server
{{TEST_COMMAND}}               # Run tests
{{COVERAGE_COMMAND}}           # Run with coverage
```

**Quality Gates:**
```bash
{{TEST_COMMAND}}               # All tests must pass
{{COVERAGE_COMMAND}}           # Must be >{{COVERAGE_THRESHOLD}}%
{{TYPE_CHECK_COMMAND}}         # No errors
{{BUILD_COMMAND}}              # Must build successfully
```

---

## 📋 Session Handoff Checklist

### 🛑 BEFORE ENDING YOUR SESSION (MANDATORY)

**Run this checklist - DO NOT SKIP:**

```bash
# 1. Verify all tests pass
{{TEST_COMMAND}}
# Must show: all passing

# 2. Verify coverage meets threshold
{{COVERAGE_COMMAND}}
# Must show: >{{COVERAGE_THRESHOLD}}%

# 3. Verify no type errors
{{TYPE_CHECK_COMMAND}}
# Must show: no errors

# 4. Verify build succeeds
{{BUILD_COMMAND}}
# Must show: successful

# 5. Check git status
git status
# Should be clean or intentional changes only
```

**Then update this file:**
- [ ] Update "Last Updated" date at top
- [ ] Update "Current Phase" and "Last Developer" at top
- [ ] Check/uncheck completed tasks in "Completed Work"
- [ ] Update "Current Work" → "Last commit" with your latest commit
- [ ] Update "Current Work" → "Next immediate steps"
- [ ] Update "Test Status" with actual numbers
- [ ] Add any new issues to "Known Issues / Blockers"
- [ ] Update "Notes for Next Developer"

**Finally, commit this file:**
```bash
git add SESSION-STATUS.md
git commit -m "docs: update session status after [brief description]"
```

**⚠️ CRITICAL:** If you don't update this file, the next developer will waste time!

---

### ✅ WHEN STARTING A NEW SESSION

**Quick start routine (10 minutes max):**

```bash
# 1. Read this file completely
cat SESSION-STATUS.md
# Focus on: Completed Work, Current Work, Next immediate steps

# 2. Check recent git history
git log -10 --oneline
# See what was done recently

# 3. Verify working state
git status
# Should be clean to start fresh

# 4. Verify tests still pass
{{TEST_COMMAND}}
# Ensure starting from working state

# 5. Start dev server (if needed)
{{DEV_SERVER_COMMAND}}
# Keep running in separate terminal
```

**Then:**
- [ ] Continue from "Next immediate steps" listed in "Current Work"
- [ ] Follow TDD workflow (RED → GREEN → REFACTOR)
- [ ] Update this file before ending your session (see checklist above)

---

**Last updated:** [DATE] by [NAME]
**Next session starts at:** Task [X.X.X]

**Session handoff quality check:**
- [ ] This file updated before ending previous session?
- [ ] All tests passing before ending previous session?
- [ ] Clear "next steps" provided above?
- [ ] No uncommitted changes from previous session?

If any checkboxes are ❌, review git log carefully to understand what happened.
