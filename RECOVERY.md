# Recovery Guide - When Things Go Wrong

**Use this document when you're stuck, blocked, or things have gone off track**

---

## 🗺️ Recovery Navigation

**Before using this guide:**
1. ✅ Check `healthnarrative/BLOCKERS.md` first - Is this a known HN2-specific issue with documented solution?
2. ✅ Check `healthnarrative/HANDOFF.md` - Are there active blockers mentioned for the current session?

**If you find a new failure pattern:**
1. Follow the appropriate scenario below to recover
2. If issue occurs 2+ times across sessions, update the knowledge base:
   - **Project-specific issue?** → Add to `healthnarrative/BLOCKERS.md`
   - **General Expo/RN/TS issue?** → Add scenario to this file (see template at end)
3. If requires deep investigation, create doc in `healthnarrative/docs/investigations/`

**Scope of this document:**
- ✅ General troubleshooting for Expo/React Native/TypeScript projects
- ✅ Common development environment issues
- ✅ Build, test, and git recovery procedures

**For project-specific issues, see:**
- `healthnarrative/BLOCKERS.md` - Known HN2-specific issues and failed approaches
- `healthnarrative/docs/investigations/INDEX.md` - Deep investigation history
- `healthnarrative/HANDOFF.md` - Current session status and active blockers

---

## 📑 Table of Contents

**Quick Navigation:**
- [Quick Diagnosis](#-quick-diagnosis)
- [Recovery Scenarios](#-recovery-scenarios)
  - [Scenario 1: Tests Are Failing](#scenario-1-tests-are-failing)
  - [Scenario 2: TypeScript Errors Everywhere](#scenario-2-typescript-errors-everywhere)
  - [Scenario 3: App Won't Build or Start](#scenario-3-app-wont-build-or-start)
  - [Scenario 4: E2E Tests Won't Run or Are Failing](#scenario-4-e2e-tests-wont-run-or-are-failing)
  - [Scenario 5: Coverage Dropped Below 80%](#scenario-5-coverage-dropped-below-80)
  - [Scenario 6: Git Is In a Messy State](#scenario-6-git-is-in-a-messy-state)
  - [Scenario 7: Lost Track of What to Do Next](#scenario-7-lost-track-of-what-to-do-next)
  - [Scenario 8: Stuck on a Task for Too Long](#scenario-8-stuck-on-a-task-for-too-long)
  - [Scenario 9: HANDOFF.md Is Out of Date](#scenario-9-handoffmd-is-out-of-date)
- [Emergency Procedures](#-emergency-procedures)
- [Prevention Checklist](#-prevention-how-to-stay-on-track)
- [Quick Reference Commands](#-quick-reference-recovery-commands)
- [TL;DR - Most Common Issues](#-tldr---most-common-issues)
- [Adding New Scenarios](#-adding-new-scenarios-to-recoverymd)

---

## 🚨 Quick Diagnosis

**Start here to figure out what's wrong:**

```bash
# Run all checks to see what's broken
npm test -- --coverage       # Tests failing? Coverage low?
maestro test .maestro/       # E2E tests failing?
npx tsc --noEmit            # TypeScript errors?
npm start                    # App won't build?
git status                   # Git in weird state?
```

**Now find your scenario below and follow the recovery steps.**

---

## 📋 Recovery Scenarios

### Scenario 1: Tests Are Failing

**Symptom:** `npm test` shows failing tests

**Diagnosis:**
```bash
npm test -- --verbose
# Read the error messages carefully
```

**Recovery steps:**

1. **Identify the failure type:**
   - Import errors → Missing dependencies or wrong paths
   - Assertion failures → Code doesn't match test expectations
   - Timeout errors → Async operations not completing
   - Mock errors → Test setup issues

2. **For import/dependency errors:**
   ```bash
   # Reinstall dependencies
   rm -rf node_modules
   npm install

   # Verify imports in failing test files
   # Check that paths are correct
   ```

3. **For assertion failures:**
   - Read the test carefully - what's it expecting?
   - Read your code - what's it actually doing?
   - Add console.log() or debugger to understand behavior
   - Fix code OR fix test (if test is wrong)

4. **For timeout errors:**
   - Look for missing await keywords
   - Check if async operations are completing
   - Increase timeout in test if legitimately slow

5. **For mock errors:**
   - Check `tests/setup.ts` - are mocks configured correctly?
   - Verify mock paths match real module paths

**Prevention:**
- Run tests after EVERY code change (not at the end)
- Follow TDD: Write test first, watch it fail, then implement

---

### Scenario 2: TypeScript Errors Everywhere

**Symptom:** `npx tsc --noEmit` shows many errors

**Diagnosis:**
```bash
npx tsc --noEmit | head -20
# Look at first few errors - often cascading from one root cause
```

**Recovery steps:**

1. **Fix from top to bottom:**
   - TypeScript errors often cascade
   - Fix the FIRST error, then re-run
   - Many subsequent errors may disappear

2. **Common TypeScript issues:**

   **Missing type definitions:**
   ```bash
   npm install --save-dev @types/[package-name]
   ```

   **"Cannot find module" errors:**
   - Check import paths (relative vs absolute)
   - Verify file actually exists
   - Check file extension (.ts vs .tsx)

   **Type mismatch errors:**
   - Read error message carefully
   - Look at expected type vs actual type
   - Add explicit type annotations
   - Use type assertions if necessary (sparingly!)

   **"any" type errors:**
   - Never use implicit any
   - Add explicit types to function parameters
   - Add return types to functions

3. **Nuclear option (if truly stuck):**
   ```bash
   # Check what changed recently
   git diff HEAD~3

   # Consider reverting recent changes
   git revert <commit-hash>
   ```

**Prevention:**
- Run `npx tsc --noEmit` frequently during development
- Enable TypeScript in your editor for real-time errors
- Use explicit types, avoid `any`

---

### Scenario 3: App Won't Build or Start

**Symptom:** `npm start` or `npm run ios` fails

**Diagnosis:**
```bash
npm start 2>&1 | tee build-error.log
# Save full error output for analysis
```

**Recovery steps:**

1. **Clear all caches:**
   ```bash
   # Clear Metro bundler cache
   rm -rf node_modules/.cache

   # Clear Expo cache
   npx expo start -c

   # Clear watchman cache (if installed)
   watchman watch-del-all

   # Clear iOS build cache
   cd ios && rm -rf build && cd ..
   ```

2. **Reinstall dependencies:**
   ```bash
   rm -rf node_modules
   rm package-lock.json
   npm install
   ```

3. **Check for common issues:**

   **Metro bundler errors:**
   - Check for syntax errors in recently changed files
   - Look for circular dependencies
   - Verify all imports are correct

   **Native module errors:**
   - May need to rebuild iOS app: `cd ios && pod install && cd ..`
   - Restart Expo dev server

   **Port already in use:**
   ```bash
   # Kill process on port 8081
   lsof -ti:8081 | xargs kill -9
   ```

4. **Start from clean state:**
   ```bash
   # Stop all running processes
   killall node

   # Clear everything
   rm -rf node_modules
   npm install

   # Start fresh
   npm start
   ```

**Prevention:**
- Commit working code frequently
- Test build after significant changes
- Keep dependencies up to date

---

### Scenario 4: E2E Tests Won't Run or Are Failing

**Symptom:** `maestro test .maestro/` fails

**Diagnosis:**
```bash
# Check Maestro is working
maestro test --version

# Try running one test
maestro test .maestro/app-launches.yaml

# Check if app is running
npm start
```

**Recovery steps:**

1. **Verify Maestro installation:**
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   maestro test --version
   ```

2. **Ensure app is running:**
   ```bash
   # Start Expo dev server in separate terminal
   npm start

   # Wait for app to load in simulator
   # Then run Maestro tests
   ```

3. **Check test file syntax:**
   - YAML syntax errors will cause failures
   - Verify indentation (spaces, not tabs)
   - Check testID values match actual components

4. **Debug failing tests:**
   ```bash
   # Run test with verbose output
   maestro test .maestro/flows/features/X.yaml --debug-output

   # Use Maestro Studio to inspect app
   maestro studio
   ```

5. **Common E2E test issues:**
   - Test looks for element that doesn't exist → Check testID props
   - Timing issues → Add explicit waits in test
   - Test passes locally but fails in CI → Environment differences

6. **⚠️ IMPORTANT: Verify test expectations match actual UI**

   **Before assuming code is broken, read the component source code to see what it actually renders.**

   ```bash
   # Example: Test fails looking for "Timeline" text
   # Step 1: Read the screen component
   cat src/features/timeline/screens/TimelineScreen.tsx

   # Step 2: Check what text it ACTUALLY shows:
   # - Loading state: "Loading timeline..."
   # - Error state: "Failed to load timeline"
   # - Empty state: "No events yet"
   # - Success state: Headers "Health Events", "Life Events"

   # Step 3: Does test expectation match actual UI?
   # - If test looks for "Timeline" but UI shows "No events yet" → Test might be wrong
   # - If UI shows empty state, data isn't loading → Code might be wrong
   ```

   **Key insight from November 2025 debugging:**
   - All 5 E2E tests were failing with "Timeline not found"
   - Manual testing worked fine
   - **Root cause:** Tests expected text that only appears when data is loaded
   - Timeline was showing empty state: "No events yet" (correct behavior with no data)
   - **Fix:** Needed to fix data loading timing, not the tests

   **When tests fail consistently:**
   1. Read the actual component code (don't guess what it shows)
   2. Check all render states: loading, error, empty, success
   3. Verify test looks for text that actually exists
   4. If test expectations are correct, fix the data loading
   5. See `docs/troubleshooting/TEST-FAILURE-DEBUGGING.md` for detailed guide

**Prevention:**
- Write E2E tests incrementally (don't batch them)
- Run E2E tests immediately after writing them
- Use Maestro Studio to verify element accessibility
- Always read component source code when tests fail unexpectedly

---

### Scenario 5: Coverage Dropped Below 80%

**Symptom:** `npm test -- --coverage` shows coverage < 80%

**Diagnosis:**
```bash
npm test -- --coverage --verbose
# Look at coverage report to see which files are undertested
```

**Recovery steps:**

1. **Identify undertested files:**
   ```bash
   npm test -- --coverage
   # Look at "Uncovered Lines" column
   ```

2. **Focus on important files first:**
   - Services (database, data loading) → Must be >90% covered
   - Components with logic → Should be >80% covered
   - Utils/helpers → Should be ~100% covered
   - Simple presentational components → Can be lower

3. **Write missing tests:**
   - Follow TDD pattern (even retroactively)
   - Test happy paths first, then edge cases
   - Test error handling paths

4. **Check coverage thresholds:**
   ```javascript
   // jest.config.js
   coverageThreshold: {
     global: {
       statements: 80,
       branches: 80,
       functions: 80,
       lines: 80,
     },
   }
   ```

**Prevention:**
- Follow TDD religiously (tests first, always)
- Check coverage after each feature
- Don't move to next task until coverage passes

---

### Scenario 6: Git Is In a Messy State

**Symptom:** `git status` shows concerning state

**Diagnosis:**
```bash
git status
git log -10 --oneline
git diff
```

**Recovery steps:**

**Problem: Uncommitted changes everywhere**
```bash
# See what changed
git status
git diff

# Option A: Commit the changes
git add .
git commit -m "wip: saving current work state"

# Option B: Stash the changes (save for later)
git stash save "description of changes"

# Option C: Discard the changes (DESTRUCTIVE!)
git checkout -- .
```

**Problem: Committed broken code**
```bash
# If last commit is broken, amend it
git add .
git commit --amend --no-edit

# If earlier commit is broken, revert it
git revert <commit-hash>

# If you haven't pushed, you can reset (DESTRUCTIVE!)
git reset --soft HEAD~1  # Keep changes, undo commit
git reset --hard HEAD~1  # Discard everything (DANGEROUS!)
```

**Problem: Merge conflict**
```bash
# See conflicted files
git status

# Open each conflicted file and resolve manually
# Look for <<<<<<< and >>>>>>> markers
# Choose which version to keep

# After resolving
git add <resolved-files>
git commit -m "fix: resolve merge conflict"
```

**Problem: Detached HEAD**
```bash
# Create branch from current state
git checkout -b recovery-branch

# Or return to main
git checkout main
```

**Prevention:**
- Commit frequently (every task completion)
- Always check `git status` before committing
- Never use `--force` unless you're absolutely sure

---

### Scenario 7: Lost Track of What to Do Next

**Symptom:** Don't know what task to work on

**Recovery steps:**

1. **Check HANDOFF.md:**
   ```bash
   cat healthnarrative/HANDOFF.md
   # Look at "Quick Start" section for "Next task"
   ```

2. **If HANDOFF.md is unclear:**
   ```bash
   # Check recent git history
   git log -10 --oneline

   # What was last commit about?
   git show HEAD
   ```

3. **If still unclear, check the master plan:**
   ```bash
   cat docs/plans/2025-10-31-detailed-task-breakdown.md
   # Find current phase, identify next uncompleted task
   ```

4. **Run tests to see what's working:**
   ```bash
   npm test -- --coverage
   maestro test .maestro/
   # What tests exist? What's passing?
   ```

5. **Check project structure:**
   ```bash
   find src -type f -name "*.tsx" -o -name "*.ts"
   # What files exist? What features are implemented?
   ```

**Prevention:**
- Update HANDOFF.md with clear "next task" before ending session
- Follow END-SESSION.md checklist to ensure handoff is complete

---

### Scenario 8: Stuck on a Task for Too Long

**Symptom:** Working on same task for >2 hours without progress

**Recovery steps:**

1. **Step back and assess:**
   - What exactly am I trying to do?
   - Why is it hard?
   - What have I tried?
   - What error messages am I seeing?

2. **Break it down smaller:**
   - Can I split this task into 3-4 smaller tasks?
   - Can I implement a simpler version first?
   - Can I stub out complex parts and come back later?

3. **Check the reference docs:**
   - Implementation architecture: `docs/plans/2025-10-31-implementation-architecture.md`
   - Component specs: `docs/plans/2025-10-31-component-library-spec.md`
   - Error handling: `docs/plans/2025-10-31-error-handling-guide.md`
   - Is there an example or pattern I can follow?

4. **Try a different approach:**
   - Am I overcomplicating this?
   - Is there a simpler solution?
   - Should I use a different library or pattern?

5. **Document the blocker:**
   ```bash
   # Update HANDOFF.md "Active Blockers" section
   # Or create investigation doc in docs/investigations/
   # Include:
   # - What you're trying to do
   # - What you've tried
   # - What error messages you're seeing
   # - What you need help with
   ```

6. **Move to a different task:**
   - Sometimes you need fresh eyes
   - Work on something else, come back later
   - Update HANDOFF.md with blocker before switching

**Prevention:**
- Follow the planning docs closely (don't improvise)
- Ask for clarification early (update HANDOFF.md "Active Blockers" with questions)
- Break tasks into <30 minute chunks

---

### Scenario 9: HANDOFF.md Is Out of Date

**Symptom:** HANDOFF.md doesn't match current state or is bloated (> 100 lines)

**Recovery steps:**

1. **Reconstruct what happened:**
   ```bash
   # Check git history
   git log -20 --oneline

   # What commits were made?
   # What features were added?

   # Check test status
   npm test -- --coverage
   cd ios && fastlane test

   # What tests exist and pass?
   ```

2. **Update HANDOFF.md using template:**

   **If HANDOFF.md is too large (> 80 lines):**
   ```bash
   cd healthnarrative
   ./scripts/archive-handoff.sh
   ```

   **Rewrite using END-SESSION.md template:**
   - Quick Start: Next task, why, estimated time (MAX 10 lines)
   - State Check: Test/TypeScript/Git status (MAX 5 lines)
   - Active Blockers: Current blockers or "None" (MAX 10 lines)
   - Recent Session Summary: Current + 1 previous session only (MAX 40 lines)
   - Context You Might Need: Links only, no embedded content (MAX 15 lines)

3. **Validate and commit:**
   ```bash
   cd healthnarrative
   ./scripts/validate-docs.sh

   git add HANDOFF.md
   git commit -m "docs: reconstruct HANDOFF.md from git history"
   ```

**Prevention:**
- Use git pre-commit hook (validates automatically)
- Read END-SESSION.md before ending each session
- Update HANDOFF.md immediately after major milestones (lightweight mid-session updates)
- Archive when > 80 lines instead of letting it grow

---

## 🔧 Emergency Procedures

### When to Start Fresh (Nuclear Option)

**Only do this if:**
- Everything is broken beyond repair
- You've tried multiple recovery steps
- It would take longer to fix than to restart

**Steps:**

1. **Save your work (just in case):**
   ```bash
   # Create backup branch
   git checkout -b backup-before-reset
   git add .
   git commit -m "backup: saving all work before reset"

   # Return to main
   git checkout main
   ```

2. **Check when things were last working:**
   ```bash
   git log -20 --oneline
   # Find last commit where tests passed
   ```

3. **Reset to last known good state:**
   ```bash
   # Soft reset (keeps changes)
   git reset --soft <last-good-commit>

   # Hard reset (DESTRUCTIVE - discards everything)
   git reset --hard <last-good-commit>
   ```

4. **Clean rebuild:**
   ```bash
   rm -rf node_modules
   npm install
   npm start
   npm test
   ```

5. **Verify everything works:**
   ```bash
   npm test -- --coverage    # Tests pass?
   npx tsc --noEmit         # No TypeScript errors?
   npm start                 # App builds?
   ```

6. **Update HANDOFF.md:**
   - Note that you reset to earlier state in "Recent Session Summary"
   - Explain what went wrong in "Active Blockers" if still relevant
   - Update "Next task" to reflect current priority

---

### When to Ask for Help

**You should update SESSION-STATUS.md and ask for human help if:**

1. **Stuck on a task for >4 hours** with no progress
2. **Architecture decision needed** that's not covered in docs
3. **Tests failing in unexpected ways** that make no sense
4. **Multiple recovery attempts failed**
5. **Unclear requirements** - acceptance criteria ambiguous
6. **Technical limitation** - something seems impossible with current stack

**How to ask for help effectively:**

1. **Update HANDOFF.md "Active Blockers" section with:**
   - Clear description of the problem
   - What you've tried
   - Link to investigation doc if you created one
   - Why you're stuck

2. **Optionally create investigation doc:**
   ```bash
   # For complex issues requiring detailed analysis
   # Create: healthnarrative/docs/investigations/YYYY-MM-DD-issue-name.md
   # Use VALIDATION-TEMPLATE.md as guide
   ```

3. **Commit everything:**
   ```bash
   git add .
   git commit -m "wip: blocked on [problem description]"
   git add HANDOFF.md
   git commit -m "docs: document blocker in handoff"
   ```

3. **Provide context in your request:**
   - "I'm working on Task X.X.X"
   - "I've tried A, B, and C"
   - "The error message says: [full error]"
   - "I need help deciding: [options]"

---

## 🎯 Prevention: How to Stay on Track

### Daily Workflow Checklist

**At start of session:**
- [ ] Read CONTINUE-SESSION.md
- [ ] Read healthnarrative/HANDOFF.md
- [ ] Run `npm test` to verify working state
- [ ] Check `git status` (should be clean)

**During session:**
- [ ] Follow TDD: Test first, implement second
- [ ] Run tests after every small change
- [ ] Commit after completing each task
- [ ] Update TodoWrite as you go

**At end of session:**
- [ ] Read END-SESSION.md
- [ ] Run all quality checks
- [ ] Update HANDOFF.md using structured template
- [ ] Run validation script
- [ ] Commit everything

### Red Flags to Watch For

**If you notice any of these, STOP and check what's wrong:**

1. **Haven't committed in >2 hours** → You're working on too much at once
2. **Tests haven't been run in >30 minutes** → You've drifted from TDD
3. **Implementing without a test** → You're not following TDD
4. **TypeScript showing errors** → Fix them immediately, don't accumulate
5. **App won't start** → Stop feature work, fix the build
6. **Don't know what task you're on** → Check HANDOFF.md Quick Start section
7. **Task taking >2 hours** → Break it down or ask for help
8. **Copying code without understanding** → Read the docs, understand first

---

## 📚 Quick Reference: Recovery Commands

```bash
# DIAGNOSIS
npm test -- --coverage       # Check test status
maestro test .maestro/       # Check E2E tests
npx tsc --noEmit            # Check TypeScript
npm start                    # Check build
git status                   # Check git state
git log -10 --oneline        # Check recent work

# CLEANING
rm -rf node_modules && npm install          # Reinstall dependencies
rm -rf node_modules/.cache                  # Clear Metro cache
npx expo start -c                           # Clear Expo cache
watchman watch-del-all                      # Clear watchman
killall node                                # Kill all node processes

# GIT RECOVERY
git stash                                   # Save changes temporarily
git stash pop                               # Restore stashed changes
git reset --soft HEAD~1                     # Undo last commit (keep changes)
git reset --hard HEAD~1                     # Undo last commit (DESTRUCTIVE)
git checkout -- .                           # Discard all changes (DESTRUCTIVE)
git revert <commit>                         # Undo commit (safe)

# INFORMATION
cat healthnarrative/HANDOFF.md              # Check current status
cat healthnarrative/docs/plans/2025-10-31-detailed-task-breakdown.md  # Check task list
git diff                                    # See uncommitted changes
git show HEAD                               # See last commit details
```

---

## 🆘 TL;DR - Most Common Issues

1. **Tests failing?** → Read error messages, fix from top down, check imports
2. **TypeScript errors?** → Fix first error, re-run (cascading errors)
3. **App won't build?** → Clear caches, reinstall dependencies
4. **Lost track?** → Read HANDOFF.md Quick Start → Check task breakdown doc
5. **Git messy?** → `git status`, commit or stash changes
6. **Stuck >2 hours?** → Break task smaller or document blocker
7. **HANDOFF.md wrong?** → Archive with `./scripts/archive-handoff.sh`, rewrite from template

**Remember: Quality over speed. Fix problems immediately, don't accumulate them.**

---

## 📝 Adding New Scenarios to RECOVERY.md

**When to add a new scenario:**
- ✅ Issue affects ANY Expo/React Native/TypeScript project (not HN2-specific)
- ✅ Issue occurred 2+ times across different sessions
- ✅ Recovery steps are well-tested and reproducible
- ✅ Scenario doesn't fit into existing sections above

**When to use BLOCKERS.md instead:**
- ❌ Issue is specific to Health Narrative project (architecture, HN2 dependencies, HN2 data model)
- ❌ Issue is about project-specific design decisions (use investigations/)
- ❌ Issue is still being investigated (document in investigations/ first, add here after solution confirmed)

**Template for new scenario:**

```markdown
### Scenario X: [Brief Descriptive Name]

**Symptom:** [What you'll see - specific error messages, unexpected behavior]

**Diagnosis:**
```bash
# Commands to confirm this is the issue
# Example: npm test -- --verbose
```

**Recovery steps:**

1. **[Step category - e.g., "Clear caches"]:**
   ```bash
   # Specific commands with comments
   rm -rf node_modules
   npm install
   ```
   - Explanation of what this does and why
   - When to use this approach vs alternatives

2. **[Next step category]:**
   - Step-by-step instructions
   - Expected results after each step
   - How to verify fix worked

3. **[Additional steps if needed]:**
   - Continue with numbered steps
   - Include code examples where helpful

**Prevention:**
- How to avoid this issue in the future
- Warning signs to watch for
- Best practices to follow

**Related:**
- Link to BLOCKERS.md if there's a project-specific variant
- Link to investigation doc if deep dive exists
- Link to relevant external docs (Expo, RN, etc.)

---
```

**After adding a new scenario:**
1. Update the scenario number (Scenario 10, 11, etc.)
2. Add entry to table of contents if this file grows large
3. Run validation: `cd healthnarrative && ./scripts/validate-docs.sh`
4. Test recovery steps on clean environment to verify they work
5. Commit with message: `docs: add RECOVERY.md scenario for [issue name]`

---

**Stay calm. Follow the steps. You can recover from almost anything.** 🚀
