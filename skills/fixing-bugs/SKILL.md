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

## Autonomous Mode - Auto-Selection Logic

### 1. Bug Priority Hierarchy

Selection priority order:

```
1. P0 bugs in current sprint (sprint_id matches active sprint)
2. P0 bugs triaged/scheduled (not in sprint)
3. P1 bugs in current sprint
4. P1 bugs triaged/scheduled
5. P2 bugs (any status except resolved)
```

### 2. Current Sprint Detection

```bash
# Find current active sprint
current_sprint=$(grep -A 5 "Current Sprint" ROADMAP.md | grep -oE 'SPRINT-[0-9]{3}' | head -1)

if [ -z "$current_sprint" ]; then
  echo "No active sprint found, selecting from all unresolved bugs"
fi
```

### 3. Bug Selection Algorithm

```bash
# Priority 1: P0 bugs in current sprint
p0_in_sprint=$(yq eval ".bugs[] | select(.status != \"resolved\" and .severity == \"P0\" and .sprint_id == \"$current_sprint\") | .id" bugs.yaml)

if [ -n "$p0_in_sprint" ]; then
  bug_count=$(echo "$p0_in_sprint" | wc -l | tr -d ' ')

  if [ $bug_count -eq 1 ]; then
    # Single P0 bug, auto-select
    selected_bug="$p0_in_sprint"
  else
    # Multiple P0 bugs, ask user (too critical to guess)
    echo "Found $bug_count P0 bugs in current sprint:"
    echo "$p0_in_sprint"
    # Use AskUserQuestion to select
    exit 0
  fi
fi

# Priority 2: P0 bugs not in sprint
if [ -z "$selected_bug" ]; then
  p0_triaged=$(yq eval ".bugs[] | select(.status == \"triaged\" and .severity == \"P0\") | .id" bugs.yaml | head -1)
  selected_bug="$p0_triaged"
fi

# Priority 3: P1 bugs in current sprint
if [ -z "$selected_bug" ]; then
  p1_in_sprint=$(yq eval ".bugs[] | select(.status != \"resolved\" and .severity == \"P1\" and .sprint_id == \"$current_sprint\") | .id" bugs.yaml | head -1)
  selected_bug="$p1_in_sprint"
fi

# Priority 4: P1 bugs not in sprint
if [ -z "$selected_bug" ]; then
  p1_triaged=$(yq eval ".bugs[] | select(.status == \"triaged\" and .severity == \"P1\") | .id" bugs.yaml | head -1)
  selected_bug="$p1_triaged"
fi

# Priority 5: P2 bugs
if [ -z "$selected_bug" ]; then
  p2_any=$(yq eval ".bugs[] | select(.status != \"resolved\" and .severity == \"P2\") | .id" bugs.yaml | head -1)
  selected_bug="$p2_any"
fi

if [ -z "$selected_bug" ]; then
  echo "No unresolved bugs found"
  exit 0
fi
```

### 4. E2E Test Preference

```bash
# Check if bug has E2E test
test_file=".maestro/flows/bugs/${selected_bug}-*.yaml"

if ls $test_file 1> /dev/null 2>&1; then
  echo "✓ Bug has E2E test: $test_file"
  has_test=true
else
  echo "• Bug has no E2E test (will need manual verification)"
  has_test=false
fi
```

**Conservative behavior:**
- Ask user if multiple P0 bugs (too critical to pick wrong one)
- Default to first bug in priority order
- Prefer bugs with E2E tests when multiple at same priority

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

## Autonomous Mode - Post-Fix Updates

After fix is complete and tests pass:

### 1. Update bugs.yaml

```bash
# Update bug status to resolved
update_item_status "$bug_id" "resolved"

# Add resolved_at timestamp
yq eval "(.bugs[] | select(.id == \"$bug_id\") | .resolved_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i bugs.yaml

# Keep sprint_id for historical reference (don't remove)
```

### 2. Run E2E Test (If Exists)

```bash
if [ -f ".maestro/flows/bugs/${bug_id}-*.yaml" ]; then
  echo "Running E2E test for $bug_id..."

  # Run Maestro test
  maestro test ".maestro/flows/bugs/${bug_id}-*.yaml"

  if [ $? -eq 0 ]; then
    echo "✓ E2E test passed"
    test_passed=true
  else
    echo "✗ E2E test failed - fix may be incomplete"
    test_passed=false
  fi
fi
```

### 3. Update Index Files

```bash
# Sync bugs.yaml to docs/bugs/index.yaml
cp bugs.yaml docs/bugs/index.yaml
```

### 4. Create Git Commit

```bash
git add bugs.yaml docs/bugs/index.yaml src/ tests/

git commit -m "$(cat <<'EOF'
fix: resolve $bug_id - $bug_title

Bug: $bug_id
Severity: $severity
Sprint: $sprint_id

Root Cause: [from systematic-debugging]
Solution: [from implementation]

Tests: All passing (XX/XX)
E2E Test: $test_status

Files Updated:
- bugs.yaml ($bug_id: in-progress → resolved)
- [source files modified]
- [test files modified]

🤖 Generated with Claude Code (autonomous mode)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Autonomous Mode - Output Format

```
✅ Auto-Fix Complete

Bug Selected: BUG-023 - Timeline crashes on scroll (P0)
Reason: Highest priority unresolved bug in current sprint (SPRINT-007)

Fix Applied:
  Root Cause: Null pointer in ScrollView handler
  Solution: Add null check before accessing timeline data
  Files Modified:
    - src/components/Timeline.tsx
    - tests/Timeline.test.tsx

Testing:
  Unit Tests: All passing (47/47)
  E2E Test: BUG-023 now passing ✓

Files Updated:
  - bugs.yaml (BUG-023: in-progress → resolved)
  - src/components/Timeline.tsx (fix applied)
  - tests/Timeline.test.tsx (test updated)

Changes committed to git.

Next: Continue with next highest priority bug (BUG-025: Data loss on save)
```

**Time Comparison:**
- Interactive: 30-60 minutes (debugging and fixing)
- Autonomous: 30-60 minutes (same time, just auto-selects bug)
- **Difference:** Selection only, not debugging process

## Implementation Workflow - Autonomous Mode

**Step 1: Auto-select bug**

```bash
selected_bug=$(auto_select_highest_priority_bug)

if [ -z "$selected_bug" ]; then
  echo "No unresolved bugs found. All bugs are resolved!"
  exit 0
fi

bug_title=$(get_item_title "$selected_bug")
bug_severity=$(yq eval ".bugs[] | select(.id == \"$selected_bug\") | .severity" bugs.yaml)

echo "Selected: $selected_bug - $bug_title ($bug_severity)"
echo "Reason: Highest priority unresolved bug"
```

**Step 2: Update bug status to in-progress**

```bash
update_item_status "$selected_bug" "in-progress"
```

**Step 3: Follow systematic-debugging workflow**

```bash
# Use existing systematic-debugging skill
# This is already autonomous:
# - Phase 1: Root cause investigation
# - Phase 2: Pattern analysis
# - Phase 3: Hypothesis testing
# - Phase 4: Implementation and verification

# No changes needed to debugging process
```

**Step 4: After fix complete, update bug to resolved**

```bash
update_item_status "$selected_bug" "resolved"
yq eval "(.bugs[] | select(.id == \"$selected_bug\") | .resolved_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i bugs.yaml
```

**Step 5: Run E2E test if exists**

```bash
run_e2e_test_if_exists "$selected_bug"
```

**Step 6: Create git commit**

```bash
create_fix_commit "$selected_bug"
```

**Step 7: Display summary**

Display output format from previous section.

**Step 8: Suggest next bug (Optional)**

```bash
next_bug=$(auto_select_highest_priority_bug)

if [ -n "$next_bug" ]; then
  next_title=$(get_item_title "$next_bug")
  echo ""
  echo "Next: Continue with $next_bug - $next_title"
fi
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
