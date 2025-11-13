---
name: triaging-bugs
description: Batch review and prioritization of reported bugs - select bugs to fix, create worktree, generate plan
---

# Triaging Bugs

## Overview

Review all reported bugs, prioritize by severity, select bugs to fix in batch, create worktree for isolation, generate implementation plan.

**Announce at start:** "I'm using the triaging-bugs skill to review reported bugs."

## When to Use

- User says: "/triage-bugs" or "triage bugs"
- During planning/sprint planning phase
- When reviewing backlog before starting work

## Process

### Phase 1: Read and Summarize Bugs

**1. Read bugs.yaml**

```typescript
const {bugs} = readBugs();

// Filter for active bugs (reported or triaged status)
const activeBugs = bugs.filter(b =>
  b.status === 'reported' || b.status === 'triaged'
);

// Group by severity
const p0Bugs = activeBugs.filter(b => b.severity === 'P0');
const p1Bugs = activeBugs.filter(b => b.severity === 'P1');
const p2Bugs = activeBugs.filter(b => b.severity === 'P2');
```

**2. Display triage summary**

```
📊 Bug Triage Report

P0 (Critical): ${p0Bugs.length} bugs
${p0Bugs.map(b => `- ${b.id}: ${b.title} (${daysAgo(b.created_at)} days old)`).join('\n')}

P1 (High): ${p1Bugs.length} bugs
${p1Bugs.map(b => `- ${b.id}: ${b.title} (${daysAgo(b.created_at)} days old)`).join('\n')}

P2 (Low): ${p2Bugs.length} bugs
${p2Bugs.map(b => `- ${b.id}: ${b.title} (${daysAgo(b.created_at)} days old)`).join('\n')}

Total active bugs: ${activeBugs.length}
```

### Phase 2: Bug Selection

**3. Use AskUserQuestion for multi-select**

```
Use AskUserQuestion tool with multiSelect: true

Question: "Which bugs should we fix in this batch?"

Options: (one for each active bug, sorted P0 → P1 → P2)
  - "${b.id}: ${b.title}" (description: "${b.severity} - ${b.observed.slice(0, 80)}...")

For each bug selected by user, add to selectedBugs array.
```

If no bugs selected:
```
No bugs selected. Triage cancelled.
```
Exit skill.

If bugs selected, continue to Phase 3.

### Phase 3: Worktree Setup

**4. Ask about worktree creation**

```
Use AskUserQuestion:
Question: "Create feature worktree for selected bugs?"
Options:
  - Yes: Create isolated workspace for bug fixes
  - No: Fix bugs on current branch (not recommended for multiple bugs)
```

If Yes:

**5. Announce worktree skill usage**

```
I'm using the using-git-worktrees skill to set up an isolated workspace.
```

**6. Use superpowers:using-git-worktrees**

```typescript
// Generate worktree name
const date = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
const bugIds = selectedBugs.map(b => b.id).join('-');
const worktreeName = `bugfix-batch-${date}`;  // Or: `bugfix-${bugIds}` if few bugs

// Call using-git-worktrees skill with:
// - Branch name: feature/bugfix-batch-${date}
// - Directory: .worktrees/bugfix-batch-${date}
```

The using-git-worktrees skill will:
- Verify .gitignore
- Create worktree
- Run npm install / cargo build / etc.
- Verify tests pass (baseline)
- Report ready

**7. Update bug status to 'triaged'**

```typescript
for (const bug of selectedBugs) {
  updateBugStatus(bug.id, 'triaged');
}

// Commit status update
git add bugs.yaml docs/bugs/index.yaml
git commit -m "triage: mark ${selectedBugs.length} bugs as triaged

Selected for fixing:
${selectedBugs.map(b => `- ${b.id}: ${b.title}`).join('\n')}"
```

### Phase 4: Implementation Planning

**8. Ask about creating implementation plan**

```
Use AskUserQuestion:
Question: "Create implementation plan now?"
Options:
  - Yes: Generate detailed plan for fixing selected bugs
  - No: Start fixing bugs without written plan (developer will create as needed)
```

If Yes:

**9. Announce planning skill usage**

```
I'm using the writing-plans skill to create the implementation plan.
```

**10. Use superpowers:writing-plans**

```typescript
// The writing-plans skill will create a plan document with:
// - Overview of all selected bugs
// - Grouped fixes (e.g., all timeline bugs together)
// - TDD workflow for each fix (RED → implement → GREEN → refactor)
// - Verification steps (E2E tests should pass)
// - Commit strategy

// Plan saved to: docs/plans/YYYY-MM-DD-bugfix-batch.md
```

### Phase 5: Handoff

**11. Display triage summary**

```
✅ Triage complete

Selected bugs: ${selectedBugs.length}
${selectedBugs.map(b => `- ${b.id} (${b.severity}): ${b.title}`).join('\n')}

${worktreeCreated ? `Worktree: .worktrees/${worktreeName}` : 'Working on current branch'}

${planCreated ? `Plan: docs/plans/${planFilename}` : 'No plan created'}

Next steps:
${planCreated ?
  '- Review plan: cat docs/plans/' + planFilename :
  '- Start fixing: say "fix BUG-XXX" for specific bug'
}
${worktreeCreated ?
  '- Work in worktree: cd .worktrees/' + worktreeName :
  ''
}
```

## Error Handling

### No Active Bugs

If `activeBugs.length === 0`:
```
✅ No active bugs to triage!

All bugs are either in_progress, fixed, or archived.

Run /report-bug to report a new issue.
```
Exit skill.

### Worktree Creation Failure

If using-git-worktrees skill fails:
```
❌ Worktree creation failed: ${error.message}

Options:
1. Fix the issue (e.g., clean git state) and retry
2. Continue on current branch (not recommended for multiple bugs)
3. Cancel triage and fix bugs individually

What would you like to do?
```

### Planning Failure

If writing-plans skill fails:
```
⚠️  Plan generation failed: ${error.message}

Bugs are marked as triaged. You can:
1. Fix bugs without written plan (say "fix BUG-XXX")
2. Manually create plan later
3. Re-run triage to regenerate plan
```

## Integration Points

- **reporting-bugs skill:** Reads bugs from bugs.yaml
- **using-git-worktrees skill:** REQUIRED for isolated workspace
- **writing-plans skill:** REQUIRED for implementation planning
- **fixing-bugs skill:** Will read triaged bugs and update status

## Files Modified

- `bugs.yaml` - Updated bug status (reported → triaged)
- `docs/bugs/index.yaml` - Updated bug status in index
- `.worktrees/bugfix-batch-YYYY-MM-DD/` - New worktree (if created)
- `docs/plans/YYYY-MM-DD-bugfix-batch.md` - Implementation plan (if created)

## Success Criteria

✅ All active bugs displayed by severity
✅ User can multi-select bugs to fix
✅ Worktree created with clean baseline
✅ Bug status updated to 'triaged'
✅ Implementation plan generated (if requested)
✅ Clear handoff to fixing phase
