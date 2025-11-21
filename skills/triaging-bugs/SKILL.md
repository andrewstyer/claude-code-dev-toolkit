---
name: triaging-bugs
description: Batch review and prioritization of reported bugs - assign to sprint, fix immediately, or mark triaged
---

# Triaging Bugs

## Overview

Review all reported bugs, prioritize by severity, select bugs in batch. Three options: (1) Assign to sprint for sprint planning, (2) Fix immediately with worktree, or (3) Mark triaged for later scheduling.

**Announce at start:** "I'm using the triaging-bugs skill to review reported bugs."

## When to Use

- User says: "/triage-bugs" or "triage bugs"
- During planning/sprint planning phase
- When reviewing backlog before starting work

## Dual-Mode Operation

**Interactive Mode (Default):**
- User says "triage bugs"
- Prompts for each decision with AskUserQuestion
- Full human control over severity, status, and disposition
- Estimated time: 1-2 minutes per bug

**Autonomous Mode:**
- User says "auto-triage bugs"
- Auto-detects severity from bug title/description keywords
- Auto-detects if bug already fixed from git commits
- Applies aggressive auto-triage rules
- Displays summary without confirmation prompts
- Estimated time: 5-10 seconds per bug

**Mode Selection:**
Mode is determined by invocation phrase:
- Contains "auto-": Use autonomous mode
- Otherwise: Use interactive mode

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

### Phase 3: Sprint Assignment (Optional)

**3a. Ask about sprint assignment**

```
Use AskUserQuestion:
Question: "How should we handle these bugs?"
Header: "Bug Assignment"
multiSelect: false
Options:
  - Label: "Assign to Sprint"
    Description: "Schedule bugs into a sprint for sprint planning"
  - Label: "Fix Immediately"
    Description: "Create worktree and fix now (traditional workflow)"
  - Label: "Mark Triaged Only"
    Description: "Just mark as triaged, schedule later"
```

**If "Assign to Sprint" selected:**

**3b. List existing sprints or create new**

```
Read docs/plans/sprints/ directory
List all sprints with status != "completed"

Use AskUserQuestion:
Question: "Which sprint should these bugs go into?"
Header: "Sprint Selection"
Options:
  - Label: "Create New Sprint"
    Description: "Start a new sprint for these bugs"
  - Label: "SPRINT-001: Core Features"
    Description: "5 features, 2 bugs already assigned"
  - Label: "SPRINT-002: UX Polish"
    Description: "3 features, 0 bugs"
  [... for each active sprint]
```

**If "Create New Sprint":**
```
Prompt: "Sprint name?" (e.g., "Sprint 5: Bug Fixes")
Prompt: "Sprint duration?" (default: 2 weeks)
Prompt: "Sprint goal?" (default: "Fix ${selectedBugs.length} bugs")

Generate sprint ID: SPRINT-{nextId:03d}
```

**If existing sprint selected:**
```
Use selected sprint ID
```

**3c. Update bugs.yaml with sprint assignment**

```typescript
for (const bug of selectedBugs) {
  bug.status = 'scheduled';  // Update from 'reported' to 'scheduled'
  bug.sprint_id = selectedSprintId;
  bug.scheduled_at = new Date().toISOString();
  bug.updated_at = new Date().toISOString();
}
```

**3d. Update/create sprint document**

Add bugs to sprint document in `docs/plans/sprints/SPRINT-XXX-[name].md`:

```markdown
## Bugs

### P0 (Critical)
- [ ] BUG-001: Timeline crashes on scroll
  - Severity: P0
  - Status: scheduled
  - E2E Test: .maestro/flows/bugs/BUG-001-timeline-crash.yaml
  - Reported: 2025-01-14

### P1 (High)
- [ ] BUG-003: Document upload fails on large PDFs
  - Severity: P1
  - Status: scheduled
  - Reported: 2025-01-15
```

**3e. Update ROADMAP.md**

Add bugs to ROADMAP.md under the sprint:

```markdown
## Current Sprint

**SPRINT-001: Core Features** (active)
- Goal: Implement medication tracking and fix critical bugs
- Duration: 2 weeks
- Progress: 30%

### Features (3)
- [ ] FEAT-001: Add medication tracking
- [ ] FEAT-003: Improve document upload flow

### Bugs (2)
- [ ] BUG-001: Timeline crashes on scroll (P0)
- [ ] BUG-003: Document upload fails on large PDFs (P1)
```

**3f. Commit sprint assignment**

```bash
git add bugs.yaml docs/bugs/index.yaml docs/plans/sprints/ ROADMAP.md

git commit -m "triage: schedule ${selectedBugs.length} bugs into ${sprintName}

Bugs scheduled:
${selectedBugs.map(b => `- ${b.id} (${b.severity}): ${b.title}`).join('\n')}

Sprint: ${sprintId} - ${sprintName}
Status: reported → scheduled"
```

**3g. Display sprint assignment summary**

```
✅ Bugs Scheduled into Sprint

Sprint: ${sprintId} - ${sprintName}
Bugs scheduled: ${selectedBugs.length}

${selectedBugs.map(b => `- ${b.id} (${b.severity}): ${b.title}`).join('\n')}

Sprint document: docs/plans/sprints/${sprintId}-[slug].md
ROADMAP.md updated

Next steps:
1. Review sprint document for bug details
2. Use scheduling-work-items to add more bugs/features to sprint
3. Start working on bugs when sprint begins
```

**Skip to Phase 5 (Handoff) - no worktree needed for sprint assignment**

---

**If "Fix Immediately" selected:**

Continue to Phase 4 (Worktree Setup) below.

**If "Mark Triaged Only" selected:**

```typescript
for (const bug of selectedBugs) {
  bug.status = 'triaged';
  bug.updated_at = new Date().toISOString();
}

git add bugs.yaml docs/bugs/index.yaml
git commit -m "triage: mark ${selectedBugs.length} bugs as triaged"
```

Skip to Phase 5 (Handoff).

---

### Phase 4: Worktree Setup (for "Fix Immediately" workflow)

**NOTE:** This phase only runs if user selected "Fix Immediately" in Phase 3.

**4a. Ask about worktree creation**

```
Use AskUserQuestion:
Question: "Create feature worktree for selected bugs?"
Options:
  - Yes: Create isolated workspace for bug fixes
  - No: Fix bugs on current branch (not recommended for multiple bugs)
```

If Yes:

**4b. Announce worktree skill usage**

```
I'm using the using-git-worktrees skill to set up an isolated workspace.
```

**4c. Use superpowers:using-git-worktrees**

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

**4d. Update bug status to 'triaged'**

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

### Phase 5: Implementation Planning (for "Fix Immediately" workflow)

**NOTE:** This phase only runs if user selected "Fix Immediately" in Phase 3.

**5a. Ask about creating implementation plan**

```
Use AskUserQuestion:
Question: "Create implementation plan now?"
Options:
  - Yes: Generate detailed plan for fixing selected bugs
  - No: Start fixing bugs without written plan (developer will create as needed)
```

If Yes:

**5b. Announce planning skill usage**

```
I'm using the writing-plans skill to create the implementation plan.
```

**5c. Use superpowers:writing-plans**

```typescript
// The writing-plans skill will create a plan document with:
// - Overview of all selected bugs
// - Grouped fixes (e.g., all timeline bugs together)
// - TDD workflow for each fix (RED → implement → GREEN → refactor)
// - Verification steps (E2E tests should pass)
// - Commit strategy

// Plan saved to: docs/plans/YYYY-MM-DD-bugfix-batch.md
```

### Phase 6: Handoff

**6. Display triage summary**

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

## Autonomous Mode - Auto-Detection Logic

### 1. Severity Detection

Uses shared function from `scripts/autonomous-helpers.sh`:

```bash
# Source shared helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/autonomous-helpers.sh"

# Auto-detect severity
severity=$(detect_bug_severity "$bug_title" "$bug_description")
```

**Detection rules:**

**P0 (Critical):**
- Keywords: crash, data loss, corruption, unusable, breaks app, critical, fatal
- Action: Auto-triage immediately, status="triaged"
- Note: "Auto-triaged as P0 (critical)"

**P1 (High):**
- Keywords: broken, fails, error, doesn't work, blocks, regression
- Action: Auto-triage, status="triaged"
- Note: "Auto-triaged as P1 (high priority)"

**P2 (Low):**
- Keywords: alignment, styling, minor, cosmetic, polish, typo, ui issue
- Action: Auto-triage, status="triaged"
- Note: "Auto-triaged as P2 (low priority)"

**Fallback:** If no keywords match, default to P1 (moderate)

### 2. Fix Detection

Check git commits for fix patterns:

```bash
# Check if bug already fixed
fix_commit=$(check_item_in_commits "$bug_id" "fix" "$bug_reported_date")

if [ -n "$fix_commit" ]; then
  # Bug appears to be fixed
  status="resolved"
  resolved_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  note="Auto-detected as fixed from git commit $fix_commit"
fi
```

**Detection patterns:**
- "fix BUG-XXX"
- "BUG-XXX fix"
- "resolve BUG-XXX"
- "BUG-XXX resolved"

**Conservative:** Only mark as resolved if clear fix commit found

### 3. Duplicate Detection

Compare bug title against existing bugs using fuzzy matching:

```bash
# Simple substring matching (production would use Levenshtein distance)
existing_bugs=$(yq eval '.bugs[].title' bugs.yaml)

for existing_title in $existing_bugs; do
  # Calculate similarity (simplified)
  # If >80% similar, flag as potential duplicate
done
```

**Action:** Display warning but don't auto-reject (too risky)

## Integration Points

- **reporting-bugs skill:** Reads bugs from bugs.yaml
- **using-git-worktrees skill:** REQUIRED for isolated workspace
- **writing-plans skill:** REQUIRED for implementation planning
- **fixing-bugs skill:** Will read triaged bugs and update status

## Bug Status Lifecycle

**Status values in bugs.yaml:**
- `reported` - Bug captured, not yet triaged
- `triaged` - Bug reviewed, marked for later fixing (no sprint assigned)
- `scheduled` - Bug assigned to sprint, not yet started
- `in_progress` - Bug being actively fixed
- `resolved` - Bug fixed and verified

**Status transitions:**
1. **Sprint assignment workflow:** reported → scheduled (via triaging-bugs "Assign to Sprint")
2. **Immediate fix workflow:** reported → triaged → in_progress (via triaging-bugs "Fix Immediately" + fixing-bugs)
3. **Mark triaged only:** reported → triaged (for later scheduling via scheduling-work-items)

**New fields in bugs.yaml for sprint assignment:**
- `sprint_id` - Sprint identifier (e.g., "SPRINT-001")
- `scheduled_at` - ISO 8601 timestamp when assigned to sprint

## Files Modified

**Sprint assignment workflow:**
- `bugs.yaml` - Updated bug status (reported → scheduled) + sprint_id
- `docs/bugs/index.yaml` - Updated bug status in index
- `docs/plans/sprints/SPRINT-XXX-[name].md` - Sprint document with bugs
- `ROADMAP.md` - Updated with bugs in sprint

**Fix immediately workflow:**
- `bugs.yaml` - Updated bug status (reported → triaged)
- `docs/bugs/index.yaml` - Updated bug status in index
- `.worktrees/bugfix-batch-YYYY-MM-DD/` - New worktree (if created)
- `docs/plans/YYYY-MM-DD-bugfix-batch.md` - Implementation plan (if created)

## Success Criteria

✅ All active bugs displayed by severity
✅ User can multi-select bugs to fix
✅ Three workflow options: sprint assignment, fix immediately, or mark triaged
✅ Sprint assignment updates bugs.yaml, sprint documents, and ROADMAP.md
✅ Worktree created with clean baseline (fix immediately workflow)
✅ Bug status updated appropriately (triaged or scheduled)
✅ Implementation plan generated (if requested in fix immediately workflow)
✅ Clear handoff to next phase (sprint planning or fixing)
