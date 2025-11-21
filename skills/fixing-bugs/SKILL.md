---
name: fixing-bugs
description: Fix specific bug by ID - uses systematic-debugging and TDD to implement fix and verify
---

# Fixing Bugs

## Overview

Fix individual bug by ID using systematic debugging and TDD workflow. Updates bug status throughout fix, verifies with E2E test, archives when complete.

**Announce at start:** "I'm using the fixing-bugs skill to fix BUG-XXX."

## When to Use

- User says: "fix BUG-004" or "fix bug 004"
- After triage when ready to start fixing
- Anytime user wants to fix specific bug

## Dual-Mode Operation

**Interactive Mode (Default):**
- User says "fix bug BUG-123" (specifies bug ID)
- User selects specific bug to fix
- Full human control over bug selection
- Estimated time: 30-60 minutes (same as autonomous, just selection differs)

**Autonomous Mode:**
- User says "auto-fix bug" (no bug ID specified)
- Auto-selects highest priority unresolved bug
- Priority: P0 in sprint → P0 triaged → P1 in sprint → P1 triaged → P2
- Prefers bugs with E2E tests (easier to verify fix)
- Asks for confirmation if multiple P0 bugs (too critical to guess)
- Estimated time: 30-60 minutes (same debugging process)

**Mode Selection:**
Mode is determined by invocation phrase:
- Contains "auto-": Use autonomous mode
- Specifies bug ID: Use that specific bug
- Otherwise: Prompt user to select bug

## Process

### Phase 1: Load Bug Details

**1. Parse bug ID from user input**

```typescript
// Extract bug ID from user message
// Patterns: "fix BUG-004", "fix bug 004", "fix 004"
const match = userMessage.match(/bug[-\s]*(\d+)/i);
if (!match) {
  Display: "Please specify a bug ID (e.g., 'fix BUG-004')"
  Exit skill
}

const bugNumber = match[1].padStart(3, '0');
const bugId = `BUG-${bugNumber}`;
```

**2. Read bug from bugs.yaml**

```typescript
const bug = getBugById(bugId);

if (!bug) {
  Display: "Bug ${bugId} not found in bugs.yaml"
  Display: "Run /triage-bugs to see active bugs"
  Exit skill
}

if (bug.status === 'fixed' || bug.status === 'archived') {
  Display: "Bug ${bugId} is already ${bug.status}"
  Use AskUserQuestion:
  Question: "This bug is already ${bug.status}. Re-open and fix anyway?"
  Options:
    - Yes: Reset to in_progress and continue
    - No: Cancel

  If No: Exit skill
  If Yes: Continue
}
```

**3. Display bug summary**

```
🐛 Fixing ${bug.id}: ${bug.title}

Severity: ${bug.severity} (${severityLabel})
Status: ${bug.status}

Observed: ${bug.observed}

Expected: ${bug.expected}

Steps to reproduce:
${bug.steps.map((s, i) => `${i+1}. ${s}`).join('\n')}

${bug.device ? 'Device: ' + bug.device : ''}
${bug.e2e_test ? 'E2E Test: ' + bug.e2e_test : 'No E2E test'}
${bug.suggested_fix ? 'Suggested fix: ' + bug.suggested_fix : ''}
```

### Phase 2: Workspace Setup

**4. Ask about worktree creation**

```
Use AskUserQuestion:
Question: "Create worktree for this fix?"
Options:
  - Yes: Isolated workspace (recommended for complex bugs)
  - No: Fix on current branch (faster for simple bugs)
```

If Yes:

**5. Announce worktree skill usage**

```
I'm using the using-git-worktrees skill to set up an isolated workspace.
```

**6. Use superpowers:using-git-worktrees**

```typescript
const worktreeName = `bugfix-${bug.id.toLowerCase()}`;
const branchName = `feature/bugfix-${bug.id.toLowerCase()}`;

// Call using-git-worktrees skill
// Skill will create .worktrees/bugfix-bug-004 with branch feature/bugfix-bug-004
```

**7. Update bug status to 'in_progress'**

```typescript
updateBugStatus(bug.id, 'in_progress');

git add bugs.yaml docs/bugs/index.yaml
git commit -m "bug(${bug.id}): mark as in_progress

Starting fix for: ${bug.title}"
```

### Phase 3: Investigation

**8. Announce debugging skill usage**

```
I'm using the systematic-debugging skill to investigate root cause.
```

**9. Use superpowers:systematic-debugging**

The systematic-debugging skill will:
- Phase 1: Root cause investigation (trace bug to source)
- Phase 2: Pattern analysis (understand why bug exists)
- Phase 3: Hypothesis testing (verify root cause)
- Phase 4: Solution design (plan the fix)

After debugging complete, skill returns with:
- Root cause explanation
- Recommended fix approach
- Files to modify

**10. Document root cause**

```
Update bug comment or create INVESTIGATION.md:

# ${bug.id} Root Cause Investigation

**Root Cause:** ${rootCauseExplanation}

**Affected Files:**
${affectedFiles.map(f => `- ${f}`).join('\n')}

**Fix Approach:** ${fixApproach}
```

### Phase 4: TDD Implementation

**11. Check for E2E test**

```typescript
if (bug.e2e_test) {
  Display: "E2E test exists: ${bug.e2e_test}"
  Display: "This test should currently FAIL (RED phase)"

  Ask: "Run E2E test to verify it fails?"
  If Yes:
    Run: maestro test ${bug.e2e_test}
    Display results
    If test passes:
      Display: "⚠️  Test passes but bug reported - test may not reproduce issue"
      Ask: "Continue with fix anyway?"
} else {
  Display: "No E2E test. Creating one now..."

  // Generate E2E test
  const {filename, content} = generateE2ETest(bug);

  // Write test file
  // Add to git

  bug.e2e_test = filename;
  updateBug(bug);

  Display: "E2E test created: ${filename}"
  Display: "Running test to verify it fails (RED phase)..."

  Run: maestro test ${filename}
  Display results
}
```

**12. Announce TDD skill usage**

```
I'm using the test-driven-development skill to implement the fix.
```

**13. Use superpowers:test-driven-development**

The TDD skill will guide:
1. Write unit tests (if needed)
2. Verify tests fail (RED)
3. Implement minimal fix
4. Verify tests pass (GREEN)
5. Refactor for quality
6. Commit with clear message

**14. Run E2E test to verify fix (GREEN phase)**

```typescript
Display: "Running E2E test to verify bug is fixed..."

Run: maestro test ${bug.e2e_test}

if (testPasses) {
  Display: "✅ E2E test passes - bug is fixed!"
} else {
  Display: "❌ E2E test still fails"
  Display: test output

  Use AskUserQuestion:
  Question: "E2E test still fails. What should we do?"
  Options:
    - Continue debugging: Go back to systematic-debugging
    - Mark fix incomplete: Update status and notes
    - Test is incorrect: Fix test, re-run

  Handle user choice
}
```

### Phase 5: Verification and Archiving

**15. Update bug status to 'fixed'**

```typescript
updateBugStatus(bug.id, 'fixed');

git add bugs.yaml docs/bugs/index.yaml
git commit -m "bug(${bug.id}): mark as fixed

${bug.title}

Root cause: ${rootCause}
Fix: ${fixSummary}

E2E test passes: ${bug.e2e_test}"
```

**16. Ask about archiving**

```
Use AskUserQuestion:
Question: "Archive ${bug.id} to docs/bugs/resolved/?"
Options:
  - Yes: Move to archive (recommended - keeps bugs.yaml clean)
  - No: Leave in bugs.yaml as 'fixed' (review later)
```

If Yes:

**17. Gather resolution details**

```typescript
// Get current commit hash
const commitHash = git rev-parse HEAD

const resolution = {
  commit: commitHash,
  summary: "${fixSummary}",  // Brief explanation of fix
  test_verification: "${bug.e2e_test} passes",
  developer: "Claude Code"
};
```

**18. Archive bug**

```typescript
archiveBug(bug.id, resolution);

// This:
// - Creates docs/bugs/resolved/YYYY-MM/BUG-XXX-<slug>.yaml
// - Removes bug from bugs.yaml
// - Updates index.yaml with resolved_at timestamp
// - Commits change

git add bugs.yaml docs/bugs/index.yaml docs/bugs/resolved/
git commit -m "bug(${bug.id}): archive as fixed

Moved to: docs/bugs/resolved/${month}/${bug.id}-${slug}.yaml
Resolution: ${resolution.summary}"
```

### Phase 6: Handoff

**19. Display fix summary**

```
✅ Bug fix complete: ${bug.id}

Title: ${bug.title}
Status: ${bug.status === 'fixed' ? 'fixed' : 'archived'}

Fix summary: ${resolution.summary}
E2E test: ${bug.e2e_test} ✅ passing
Commit: ${commitHash}

${archived ?
  `Archived to: docs/bugs/resolved/${month}/${bug.id}-${slug}.yaml` :
  'Bug still in bugs.yaml - run /triage-bugs to archive later'
}

Next steps:
${worktreeCreated ?
  '- Merge worktree: Use finishing-a-development-branch skill' :
  '- Push to remote: git push origin master'
}
- Continue with more bugs or move to next task
```

## Error Handling

### Bug Not Found

```
❌ Bug ${bugId} not found

Active bugs:
${activeBugs.map(b => `- ${b.id}: ${b.title}`).join('\n')}

Run /triage-bugs to see all bugs and select ones to fix.
```

### E2E Test Failure After Fix

If E2E test still fails after implementation:
```
⚠️  Bug marked as fixed but E2E test still fails

This could mean:
1. Fix is incomplete
2. Test is incorrect
3. Different bug exposed

Recommend using systematic-debugging to re-investigate.
```

### Archiving Failure

If bug.status !== 'fixed' when trying to archive:
```
❌ Cannot archive ${bug.id} - status is '${bug.status}'

Bug must be fixed before archiving.
```

## Integration Points

- **systematic-debugging skill:** REQUIRED for root cause investigation
- **test-driven-development skill:** REQUIRED for guided implementation
- **using-git-worktrees skill:** OPTIONAL for isolated workspace
- **finishing-a-development-branch skill:** Recommended for merging worktree after fix
- **verification-before-completion skill:** Verifies E2E test passes before marking fixed

## Files Modified

- `bugs.yaml` - Updated bug status (triaged → in_progress → fixed)
- `docs/bugs/index.yaml` - Updated bug status in index
- `docs/bugs/resolved/YYYY-MM/BUG-XXX-*.yaml` - Archived bug (if archived)
- `.maestro/flows/bugs/BUG-XXX-*.yaml` - E2E test (if generated)
- Various source files - The actual bug fix

## Success Criteria

✅ Bug investigated with systematic-debugging
✅ E2E test created (if missing) and fails (RED)
✅ Fix implemented using TDD
✅ E2E test passes (GREEN)
✅ Bug status updated: in_progress → fixed
✅ Bug archived with resolution details (if requested)
✅ Clear handoff for merging or continuing work
