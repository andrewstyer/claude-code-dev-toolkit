---
name: completing-sprints
description: Systematic sprint completion with flexible handling of incomplete work and optional retrospectives
---

# Completing Sprints

## Overview

Systematic process for ending sprints, reviewing completion, handling incomplete work, and maintaining data consistency. Supports both interactive (human-led) and autonomous (Claude-led) modes for completing sprints.

**Announce at start:** "I'm using the completing-sprints skill to systematically complete your sprint."

**Key Capabilities:**
- Complete active or planned sprints with review of all work items
- Mark bugs as resolved/unresolved (binary completion)
- Mark features as completed/partial/incomplete (with percentage for partial)
- Handle incomplete work flexibly (return to backlog, move to next sprint, or keep in current sprint)
- Auto-detect completion status from project state (yaml files, git commits, implementation plans)
- Generate optional sprint retrospectives with statistics and notes
- Maintain data consistency across bugs.yaml, features.yaml, sprint documents, and ROADMAP.md
- Create structured git commits with detailed changelogs

## When to Use

**Interactive Mode (Default):**
- User says "complete sprint" or similar
- Want human review and approval at each decision point
- Need flexibility to override auto-detected statuses
- Prefer manual input for retrospective notes
- Estimated time: 5-10 minutes per sprint

**Autonomous Mode:**
- User says "auto-complete sprint" or invokes in autonomous context
- Want fast, automated completion based on current project state
- Trust auto-detection from yaml files and implementation plans
- Accept conservative defaults for ambiguous cases
- Estimated time: 2-3 minutes per sprint

**Use this skill when:**
- Sprint timeline has ended and you want to formally close it
- Need to review what was accomplished during a sprint
- Have incomplete work that needs disposition (backlog vs next sprint)
- Want to generate a retrospective for learning and planning
- Need to ensure data consistency across project files

**Don't use this skill if:**
- Sprint is still in progress and you just want a status update
- You want to cancel/abandon a sprint (not the same as completing)
- You're looking for sprint metrics across multiple sprints (use analytics tools)

## Process - Interactive Mode

### Phase 1: Select Sprint & Review Completion

**Step 1: List Active Sprints**

Read `docs/plans/sprints/` directory and filter for sprints with status != "completed":

```bash
# Find all sprint documents
for file in docs/plans/sprints/SPRINT-*.md; do
  # Extract status field
  status=$(grep "^**Status:**" "$file" | sed 's/\*\*Status:\*\* //')

  if [ "$status" != "completed" ]; then
    # Extract sprint metadata
    sprint_id=$(basename "$file" | cut -d'-' -f1-2)  # SPRINT-001
    # Display sprint info
  fi
done
```

Display format:

```
Active Sprints:

SPRINT-001: Core Features (active)
  Goal: Fix critical bugs and implement medication tracking
  Items: 5 features, 2 bugs (7 total)
  Started: 2025-11-07 (14 days ago)
  Current progress: 60%

SPRINT-002: UX Polish (planned)
  Goal: Polish user experience
  Items: 2 features, 0 bugs (2 total)
  Starts: 2025-11-21
```

**Step 2: Sprint Selection**

Use AskUserQuestion to select sprint:

```
Question: "Which sprint would you like to complete?"
Header: "Sprint Selection"
multiSelect: false
Options:
  - Label: "SPRINT-001: Core Features"
    Description: "7 items, 14 days old, 60% progress"
  - Label: "SPRINT-002: UX Polish"
    Description: "2 items, planned"
```

**Step 3: Load Sprint Work Items**

Read sprint document and extract all work item IDs:

```bash
# Extract FEAT-XXX and BUG-XXX from sprint document
grep -oE '(FEAT|BUG)-[0-9]{3}' docs/plans/sprints/SPRINT-001-*.md | sort -u
```

**Step 4: Display Work Items**

Read bugs.yaml and features.yaml to get current status:

```yaml
# For each FEAT-XXX, read from features.yaml
# For each BUG-XXX, read from bugs.yaml
# Group by type and priority
```

Display format:

```
📋 SPRINT-001 Work Items

FEATURES (5):
Must-Have:
  • FEAT-001: Add medication tracking (status: in-progress)
    Plan: docs/plans/features/FEAT-001-implementation-plan.md
  • FEAT-003: Improve document upload (status: completed) ✓

Nice-to-Have:
  • FEAT-005: Export health summary (status: scheduled)

BUGS (2):
P0:
  • BUG-001: Timeline crashes on scroll (status: resolved) ✓
    Test: .maestro/flows/bugs/BUG-001-timeline-crash.yaml

P1:
  • BUG-003: Document upload fails (status: in-progress)
```

**Step 5: Mark Bug Completion**

Use AskUserQuestion (multiSelect=true) to mark resolved bugs:

```
Question: "Which bugs have been resolved?"
Header: "Bug Completion"
multiSelect: true
Options:
  - Label: "BUG-001: Timeline crashes on scroll"
    Description: "P0 - Currently: resolved ✓"
  - Label: "BUG-003: Document upload fails"
    Description: "P1 - Currently: in-progress"
```

Pre-select bugs with status="resolved".

**Step 6: Mark Feature Completion**

For each feature, use AskUserQuestion:

```
Question: "What's the completion status of FEAT-001: Add medication tracking?"
Header: "Feature Status"
multiSelect: false
Options:
  - Label: "Completed"
    Description: "Feature fully implemented and tested"
  - Label: "Partially complete - 50%"
    Description: "About half done, significant work remaining"
  - Label: "Partially complete - 75%"
    Description: "Mostly done, minor work remaining"
  - Label: "Incomplete/Not started"
    Description: "Little or no work completed"
```

Repeat for each feature in sprint.

**Step 7: Show Completion Summary**

Calculate and display stats:

```
Sprint Completion Summary:

Features: 2/5 completed (40%)
  • Completed: FEAT-003, FEAT-007
  • Partial: FEAT-001 (75%)
  • Incomplete: FEAT-005, FEAT-008

Bugs: 1/2 resolved (50%)
  • Resolved: BUG-001
  • Unresolved: BUG-003

Overall: 3/7 items completed (43%)
```

Store completion data in variables for later use.

### Phase 1: Select Sprint & Review Completion (Autonomous Mode)

**Auto-Detection Logic:**

**Sprint Selection:**
- If only one active sprint: Auto-select it
- If multiple active sprints: Select oldest active sprint (by created_at date)
- If no active sprints: Exit with message "No active sprints to complete"

**Bug Completion Detection:**

For each bug in sprint:

1. Check bugs.yaml status field:
   - `status="resolved"` → Bug is resolved ✓

2. If status="in-progress", check git commits:
   ```bash
   # Look for commit messages with "fix BUG-XXX" patterns
   git log --all --grep="fix.*BUG-XXX" --grep="resolve.*BUG-XXX" --grep="BUG-XXX.*fix" -i
   ```
   If found recent commits: Consider resolved

3. Conservative default: If unclear, treat as incomplete

**Feature Completion Detection:**

For each feature in sprint:

1. Check features.yaml status field:
   - `status="completed"` → Feature completed ✓

2. If status="in-progress", calculate partial completion:

   a. If implementation plan exists (`implementation_plan` field):
      ```bash
      # Count checked vs unchecked tasks in plan
      total_tasks=$(grep -c "^- \[ \]" docs/plans/features/FEAT-001-*.md)
      checked_tasks=$(grep -c "^- \[x\]" docs/plans/features/FEAT-001-*.md)
      percentage=$((checked_tasks * 100 / total_tasks))
      ```

   b. Check ROADMAP.md for `[x]` next to feature ID:
      ```bash
      grep "FEAT-001" ROADMAP.md | grep -q "\[x\]"
      ```

   c. Check sprint document for `[x]` next to feature:
      ```bash
      grep "FEAT-001" docs/plans/sprints/SPRINT-001-*.md | grep -q "\[x\]"
      ```

   d. If multiple sources conflict: Use features.yaml status as source of truth

3. Default: If status != "completed" and no clear %, treat as incomplete (0%)

**Display Auto-Detected Summary:**

Show same format as interactive mode summary, then proceed automatically without confirmation.

### Phase 2: Handle Incomplete Items

**Step 1: Identify Incomplete Items**

From Phase 1 completion data:

- Bugs: Any bug NOT marked as "resolved"
- Features: Any feature NOT marked as "completed" (includes partial 50%/75% and not-started)

Display list:

```
Incomplete Items (4):

Features (3):
  • FEAT-001: Add medication tracking (75% complete)
  • FEAT-005: Export health summary (not started)
  • FEAT-008: Improve navigation (not started)

Bugs (1):
  • BUG-003: Document upload fails (in-progress)
```

**Step 2: Set Default Action (Interactive Mode)**

Use AskUserQuestion:

```
Question: "How should incomplete items be handled by default?"
Header: "Incomplete Items"
multiSelect: false
Options:
  - Label: "Return to backlog"
    Description: "Remove sprint_id, reset to triaged (bugs) or approved (features)"
  - Label: "Move to next sprint"
    Description: "Update sprint_id to SPRINT-002 (if exists)"
  - Label: "Keep in current sprint"
    Description: "Leave sprint_id for historical reference"
  - Label: "Review each individually"
    Description: "Prompt for each item separately"
```

**Step 3: Apply Default or Review Individually**

If "Review each individually" selected:

For each incomplete item, use AskUserQuestion:

```
Question: "What should we do with FEAT-001: Add medication tracking (75% complete)?"
Header: "Item Action"
multiSelect: false
Options:
  - Label: "Return to backlog"
  - Label: "Move to next sprint"
  - Label: "Keep in current sprint"
```

If default action selected:
- Apply to all incomplete items
- Display summary: "4 items will be [action]"

**Step 4: Handle "Move to Next Sprint" Logic**

Check if next sprint exists:

```bash
# Current sprint: SPRINT-001
# Next sprint: SPRINT-002
next_sprint_id="SPRINT-002"

# Check if next sprint document exists
if [ -f docs/plans/sprints/SPRINT-002-*.md ]; then
  # Next sprint exists
  echo "Moving items to SPRINT-002"
else
  # Next sprint doesn't exist
  echo "SPRINT-002 not found"
fi
```

**If next sprint doesn't exist (Interactive):**

Use AskUserQuestion:

```
Question: "Next sprint (SPRINT-002) doesn't exist. What should we do?"
Header: "Next Sprint"
multiSelect: false
Options:
  - Label: "Create SPRINT-002 now"
    Description: "Invoke scheduling-work-items to create next sprint"
  - Label: "Return to backlog instead"
    Description: "Change action for these items"
  - Label: "Keep in current sprint"
    Description: "Leave for reference"
```

**If next sprint doesn't exist (Autonomous):**
- Default: Return all items to backlog (conservative)
- Don't auto-create sprints

**Step 5: Autonomous Mode Default Behavior**

Default action: Return to backlog (conservative)

Exception - Auto-move high-priority items to next sprint if it exists:
- P0/P1 bugs → Move to next sprint
- Must-Have features → Move to next sprint
- P2 bugs, Nice-to-Have/Future features → Return to backlog

**Step 6: Track Disposition**

For each incomplete item, store disposition:

```
incomplete_items = {
  "FEAT-001": {action: "move_to_next_sprint", next_sprint: "SPRINT-002"},
  "FEAT-005": {action: "return_to_backlog"},
  "FEAT-008": {action: "return_to_backlog"},
  "BUG-003": {action: "move_to_next_sprint", next_sprint: "SPRINT-002"}
}
```

This data will be used in Phase 4 to update files.

### Phase 3: Sprint Completion Details

**Step 1: Set Completion Type (Interactive)**

Use AskUserQuestion:

```
Question: "How would you characterize this sprint completion?"
Header: "Completion Type"
multiSelect: false
Options:
  - Label: "Successful"
    Description: "Goals met, most items completed (≥80%)"
  - Label: "Partial"
    Description: "Some goals met, significant items incomplete (50-79%)"
  - Label: "Pivoted"
    Description: "Sprint redirected, different outcomes than planned (<50%)"
```

**Step 1: Set Completion Type (Autonomous)**

Auto-determine based on completion rate:

```
if completion_rate >= 80:
  completion_type = "successful"
elif completion_rate >= 50:
  completion_type = "partial"
else:
  completion_type = "pivoted"
```

**Step 2: Calculate Sprint Stats**

```python
# Extract sprint created date from sprint document
created_date = "2025-11-07"  # From **Created:** field

# Current date
completed_date = "2025-11-21"

# Calculate duration
from datetime import datetime
created = datetime.fromisoformat(created_date)
completed = datetime.fromisoformat(completed_date)
duration_days = (completed - created).days

# Calculate completion rates
total_items = len(features) + len(bugs)
completed_items = len(completed_features) + len(resolved_bugs)
completion_rate = (completed_items / total_items * 100) if total_items > 0 else 0

feature_completion_rate = (len(completed_features) / len(features) * 100) if features else 0
bug_resolution_rate = (len(resolved_bugs) / len(bugs) * 100) if bugs else 0

# Calculate velocity
velocity = completed_items / duration_days if duration_days > 0 else 0
```

Display:

```
Sprint Statistics:

Duration: 14 days (2025-11-07 to 2025-11-21)
Completion Rate: 43% (3/7 items completed)

Features:
  • Completed: 2/5 (40%)
  • Partial: 1 (FEAT-001 at 75%)
  • Incomplete: 2

Bugs:
  • Resolved: 1/2 (50%)
  • Unresolved: 1

Velocity: 3 items completed in 14 days (0.21 items/day)
```

**Step 3: Ask About Retrospective (Interactive)**

Use AskUserQuestion:

```
Question: "Create sprint retrospective document?"
Header: "Retrospective"
multiSelect: false
Options:
  - Label: "Yes, with notes"
    Description: "Generate stats + prompt for what went well, didn't go well, action items"
  - Label: "Yes, stats only"
    Description: "Generate stats without manual notes"
  - Label: "No"
    Description: "Skip retrospective creation"
```

**Step 3: Retrospective (Autonomous)**

Always create retrospective with stats only (no manual notes in autonomous mode).

**Step 4: Generate Retrospective (If Requested)**

**If "Yes, with notes" (Interactive only):**

Prompt for:
1. "What went well during this sprint?"
2. "What didn't go well or could be improved?"
3. "Action items for next sprint?"

Use simple text prompts (not AskUserQuestion) to collect freeform input.

**Create retrospective file:**

File: `docs/plans/sprints/retrospectives/SPRINT-XXX-retrospective.md`

Template:

````markdown
# Sprint Retrospective: SPRINT-001 - Core Features

**Sprint ID:** SPRINT-001
**Sprint Name:** Core Features
**Goal:** Fix critical bugs and implement medication tracking
**Completion Type:** partial
**Duration:** 14 days (2025-11-07 to 2025-11-21)

## Statistics

### Completion Summary
- **Total Items:** 7 (43% completed)
- **Features:** 2/5 completed (40%)
  - Partial: 1 feature (FEAT-001 at 75%)
- **Bugs:** 1/2 resolved (50%)

### Velocity
- Items completed: 3 in 14 days
- Average: 0.21 items per day

### Incomplete Items Disposition
- Moved to next sprint: 2 items (BUG-003, FEAT-001)
- Returned to backlog: 2 items (FEAT-005, FEAT-008)
- Kept in sprint: 0 items

## Completed Work

### Features
- [x] FEAT-003: Improve document upload
- [x] FEAT-007: Add onboarding flow

### Bugs
- [x] BUG-001: Timeline crashes on scroll

## Incomplete Work

### Features
- [ ] FEAT-001: Add medication tracking (75% complete) → Moved to SPRINT-002
- [ ] FEAT-005: Export health summary → Returned to backlog
- [ ] FEAT-008: Improve navigation → Returned to backlog

### Bugs
- [ ] BUG-003: Document upload fails → Moved to SPRINT-002

## Retrospective Notes

### What Went Well ✅
${user_input_well || "N/A"}

### What Didn't Go Well ⚠️
${user_input_not_well || "N/A"}

### Action Items for Next Sprint 🎯
${user_input_actions || "N/A"}

---

**Created:** 2025-11-21T14:30:00Z
**Sprint Document:** [docs/plans/sprints/SPRINT-001-core-features.md](../SPRINT-001-core-features.md)
````

### Phase 4: Update Files and Commit

**Step 1: Update bugs.yaml**

For each bug in sprint, update based on completion status and disposition:

**Bug resolved:**

```yaml
- id: BUG-001
  title: "Timeline crashes on scroll"
  # ... existing fields ...
  status: resolved  # Update from in-progress
  resolved_at: "2025-11-21T14:30:00Z"  # Add timestamp
  updated_at: "2025-11-21T14:30:00Z"
  sprint_id: SPRINT-001  # Keep for historical reference
```

**Bug incomplete - returning to backlog:**

```yaml
- id: BUG-003
  title: "Document upload fails"
  # ... existing fields ...
  status: triaged  # Reset from in-progress
  # sprint_id: SPRINT-001  ← REMOVE this field
  # scheduled_at: ...      ← REMOVE this field
  updated_at: "2025-11-21T14:30:00Z"
```

**Bug incomplete - moving to next sprint:**

```yaml
- id: BUG-003
  title: "Document upload fails"
  # ... existing fields ...
  status: scheduled  # Or keep current status (in-progress)
  sprint_id: SPRINT-002  # Update from SPRINT-001
  moved_from: SPRINT-001  # Add for tracking
  updated_at: "2025-11-21T14:30:00Z"
```

**Bug incomplete - staying in current sprint:**

```yaml
- id: BUG-003
  # ... no changes ...
  # sprint_id remains SPRINT-001
  updated_at: "2025-11-21T14:30:00Z"
```

**Implementation:**

Read bugs.yaml, parse YAML, update matching bugs, write back to file.

**Step 2: Update features.yaml**

Similar logic to bugs, with additional partial completion handling:

**Feature completed:**

```yaml
- id: FEAT-003
  title: "Improve document upload"
  # ... existing fields ...
  status: completed  # Update from in-progress
  completed_at: "2025-11-21T14:30:00Z"  # Add timestamp
  updated_at: "2025-11-21T14:30:00Z"
  sprint_id: SPRINT-001  # Keep for historical reference
```

**Feature partial completion (moving to next sprint):**

```yaml
- id: FEAT-001
  title: "Add medication tracking"
  # ... existing fields ...
  status: in-progress  # Keep or update
  completion_percentage: 75  # Add field (0-100)
  sprint_id: SPRINT-002  # Update from SPRINT-001
  moved_from: SPRINT-001  # Add for tracking
  updated_at: "2025-11-21T14:30:00Z"
```

**Feature incomplete - returning to backlog:**

```yaml
- id: FEAT-005
  title: "Export health summary"
  # ... existing fields ...
  status: approved  # Reset from scheduled
  # sprint_id: SPRINT-001  ← REMOVE this field
  # scheduled_at: ...      ← REMOVE this field
  updated_at: "2025-11-21T14:30:00Z"
```

**Feature incomplete - staying in current sprint:**

```yaml
- id: FEAT-008
  # ... no changes ...
  # sprint_id remains SPRINT-001
  updated_at: "2025-11-21T14:30:00Z"
```

**Implementation:**

Read features.yaml, parse YAML, update matching features, write back to file.

**Step 3: Update Sprint Document**

File: `docs/plans/sprints/SPRINT-XXX-[slug].md`

**Updates to make:**

1. Change status from "active" to "completed"
2. Add completion metadata
3. Update progress stats
4. Check off completed items
5. Add notes for incomplete items
6. Link to retrospective

**Example updates:**

Before:
```markdown
**Status:** active
**Created:** 2025-11-07
**Goal:** Fix critical bugs and implement medication tracking
```

After:
```markdown
**Status:** completed
**Created:** 2025-11-07
**Completed:** 2025-11-21
**Duration:** 14 days
**Completion Type:** partial
**Goal:** Fix critical bugs and implement medication tracking
```

**Update Features section:**

```markdown
## Features

### Must-Have
- [x] FEAT-003: Improve document upload
  - Status: completed
  - Completed: 2025-11-21

- [ ] FEAT-001: Add medication tracking
  - Status: in-progress (75% complete)
  - Moved to: SPRINT-002

- [ ] FEAT-005: Export health summary
  - Status: approved
  - Returned to backlog
```

**Update Bugs section:**

```markdown
## Bugs

### P0 (Critical)
- [x] BUG-001: Timeline crashes on scroll
  - Severity: P0
  - Status: resolved
  - Resolved: 2025-11-21

### P1 (High)
- [ ] BUG-003: Document upload fails
  - Severity: P1
  - Status: in-progress
  - Moved to: SPRINT-002
```

**Update Progress section:**

```markdown
## Progress

- Total Items: 7
- Completed: 3 (43%)
- In Progress: 0
- Pending: 4

Features: 2/5 complete (40%)
Bugs: 1/2 resolved (50%)

## Sprint Retrospective

📊 [Retrospective: docs/plans/sprints/retrospectives/SPRINT-001-retrospective.md](retrospectives/SPRINT-001-retrospective.md)
```

**Update Last Updated timestamp:**

```markdown
---

**Last Updated:** 2025-11-21T14:30:00Z
```

**Step 4: Update ROADMAP.md**

Move sprint from "Current Sprint" or "Active Sprints" to "Completed Sprints" section.

**Before:**

```markdown
## Current Sprint

**SPRINT-001: Core Features** (active)
- Goal: Fix critical bugs and implement medication tracking
- Duration: 2 weeks
- Progress: 60% complete (5/7 items)

### Features (5)
- [x] FEAT-003: Improve document upload (Must-Have)
- [ ] FEAT-001: Add medication tracking (Must-Have)
- [ ] FEAT-005: Export health summary (Nice-to-Have)
...
```

**After:**

```markdown
## Current Sprint

**SPRINT-002: UX Polish** (active)
- Goal: Polish user experience
- Items: 4 features, 1 bug (includes 2 moved from SPRINT-001)
...

## Completed Sprints

**SPRINT-001: Core Features** (completed - partial)
- Completed: 2025-11-21
- Duration: 14 days
- Completion: 43% (3/7 items)
- Retrospective: [docs/plans/sprints/retrospectives/SPRINT-001-retrospective.md](sprints/retrospectives/SPRINT-001-retrospective.md)
- Sprint Document: [docs/plans/sprints/SPRINT-001-core-features.md](sprints/SPRINT-001-core-features.md)
```

**If next sprint exists and items moved to it:**

Also update next sprint document (SPRINT-002-*.md) to include moved items:

```markdown
# SPRINT-002: UX Polish

...

## Features

### Must-Have
- [ ] FEAT-001: Add medication tracking
  - Status: in-progress (75% complete)
  - Moved from: SPRINT-001
  - Priority: must-have
  - Category: new-functionality
  - Implementation Plan: docs/plans/features/FEAT-001-implementation-plan.md

...

## Bugs

### P1 (High)
- [ ] BUG-003: Document upload fails
  - Severity: P1
  - Status: in-progress
  - Moved from: SPRINT-001
```

**Step 5: Update Index Files**

Update `docs/bugs/index.yaml` and `docs/features/index.yaml` with new statuses and sprint_ids.

Read each file, update matching entries, write back.

**Step 6: Run Validation Script**

Before committing, run validation to catch any errors:

```bash
./scripts/validate-sprint-data.sh
```

**If validation fails:**

Interactive mode:
- Display errors
- Ask: "Validation failed. Fix errors and retry? (yes/no)"
- If yes: Attempt to fix, re-run validation
- If no: Abort sprint completion (files updated but not committed)

Autonomous mode:
- Log errors
- Abort sprint completion (files updated but not committed)

**If validation passes:**

Proceed to git commit.

**Step 7: Git Commit**

Create structured commit with detailed changelog:

```bash
git add bugs.yaml features.yaml docs/plans/sprints/ docs/bugs/index.yaml docs/features/index.yaml ROADMAP.md

# If retrospective created
git add docs/plans/sprints/retrospectives/

git commit -m "$(cat <<'EOF'
feat: complete SPRINT-001 - Core Features (partial)

Sprint: SPRINT-001 - Core Features
Completion Type: partial
Duration: 14 days (2025-11-07 to 2025-11-21)

Completion Stats:
- Total Items: 7 (43% complete)
- Features: 2/5 completed (40%)
  - Completed: FEAT-003, FEAT-007
  - Partial: FEAT-001 (75%)
  - Incomplete: FEAT-005, FEAT-008
- Bugs: 1/2 resolved (50%)
  - Resolved: BUG-001
  - Unresolved: BUG-003

Incomplete Items (4):
- Moved to SPRINT-002: 2 items (BUG-003, FEAT-001)
- Returned to backlog: 2 items (FEAT-005, FEAT-008)

Retrospective: docs/plans/sprints/retrospectives/SPRINT-001-retrospective.md

Files updated:
- bugs.yaml (1 resolved, 1 moved to SPRINT-002)
- features.yaml (2 completed, 1 partial moved to SPRINT-002, 2 returned to backlog)
- docs/plans/sprints/SPRINT-001-core-features.md (status: completed)
- docs/plans/sprints/SPRINT-002-ux-polish.md (added 2 items from SPRINT-001)
- ROADMAP.md (moved SPRINT-001 to completed, updated SPRINT-002)
- Index files updated

Velocity: 3 items completed in 14 days (0.21 items/day)
EOF
)"
```

**If git commit fails:**

- Files are already updated (don't rollback)
- Display error message
- Provide manual commit command

**Step 8: Display Summary**

Show user final summary:

```
✅ Sprint Completed: SPRINT-001 - Core Features

Completion Type: partial
Duration: 14 days
Completion Rate: 43%

Work Completed:
  Features (2): FEAT-003, FEAT-007
  Bugs (1): BUG-001

Partial Work:
  FEAT-001: 75% complete → Moved to SPRINT-002

Incomplete Work:
  Moved to SPRINT-002: BUG-003, FEAT-001
  Returned to backlog: FEAT-005, FEAT-008

Files Updated:
  ✓ bugs.yaml
  ✓ features.yaml
  ✓ docs/plans/sprints/SPRINT-001-core-features.md
  ✓ docs/plans/sprints/SPRINT-002-ux-polish.md (updated)
  ✓ ROADMAP.md
  ✓ Index files

Retrospective: docs/plans/sprints/retrospectives/SPRINT-001-retrospective.md

Changes committed to git.

Next Steps:
1. Review retrospective for insights
2. Continue work on SPRINT-002 (now has 4 items)
3. Re-triage backlog items (FEAT-005, FEAT-008) if needed
```

## Error Handling

### Error 1: No Active Sprints Found

**Scenario:** User invokes skill but all sprints are completed

**Handling:**

```
No active sprints to complete.

Active sprints: 0
Completed sprints: 5

All sprints are already completed. Use scheduling-work-items to create new sprints.
```

Exit gracefully without error.

### Error 2: Sprint Document Missing

**Scenario:** bugs.yaml/features.yaml reference sprint but sprint doc doesn't exist

**Interactive mode:**

Use AskUserQuestion:

```
Question: "Sprint document SPRINT-003-*.md not found but referenced by 5 work items. What should we do?"
Header: "Missing Sprint Doc"
multiSelect: false
Options:
  - Label: "Create sprint document from YAML data"
    Description: "Generate sprint doc based on work items with sprint_id"
  - Label: "Skip completing this sprint"
    Description: "Leave this sprint for manual review"
  - Label: "Remove sprint references from YAML"
    Description: "Reset items to triaged/approved status"
```

**Autonomous mode:**
- Warn in output
- Skip completing that sprint
- Suggest running validation script

### Error 3: Work Item Not Found in YAML

**Scenario:** Sprint doc references FEAT-999 but FEAT-999 not in features.yaml

**Interactive mode:**

Use AskUserQuestion:

```
Question: "FEAT-999 listed in sprint document but not found in features.yaml. What should we do?"
Header: "Orphaned Reference"
multiSelect: false
Options:
  - Label: "Remove from sprint document"
    Description: "Clean up orphaned reference"
  - Label: "Keep for historical record"
    Description: "Leave in sprint doc, note in retrospective"
```

**Autonomous mode:**
- Warn in output
- Keep in sprint doc (don't delete data)
- Mark in validation report

### Error 4: Next Sprint Doesn't Exist

**Scenario:** User wants to move items to next sprint but it doesn't exist

**Interactive mode:**

Use AskUserQuestion:

```
Question: "Next sprint (SPRINT-004) doesn't exist. How should incomplete items be handled?"
Header: "Next Sprint Missing"
multiSelect: false
Options:
  - Label: "Create SPRINT-004 now"
    Description: "Invoke scheduling-work-items to create next sprint"
  - Label: "Return to backlog instead"
    Description: "Change action for these items"
  - Label: "Keep in current sprint"
    Description: "Leave for reference"
```

**Autonomous mode:**
- Default: Return all items to backlog
- Don't auto-create sprints (too presumptuous)

### Error 5: Git Commit Fails

**Scenario:** Git commit fails (merge conflicts, hooks, permissions, etc.)

**Handling:**

```
⚠️  Git commit failed. Files have been updated but not committed.

To commit manually:
git add bugs.yaml features.yaml docs/plans/sprints/ ROADMAP.md
git commit -m "feat: complete SPRINT-001 - Core Features (partial)"

Error: [git error message]
```

Files remain updated, user can commit manually.

### Error 6: Conflicting Status

**Scenario:** YAML says status="completed" but user says "incomplete" in interactive mode

**Handling:**

Use AskUserQuestion:

```
Question: "FEAT-007 has status='completed' in features.yaml but you marked it as incomplete. Which is correct?"
Header: "Status Conflict"
multiSelect: false
Options:
  - Label: "Trust YAML status"
    Description: "Keep as completed"
  - Label: "Trust my input"
    Description: "Update YAML to incomplete"
```

**Autonomous mode:**
- Always trust YAML status (source of truth)
- Ignore sprint document checkboxes if they conflict

### Error 7: Validation Script Fails

**Scenario:** Validation script finds errors before commit

**Handling:**

```
❌ Sprint data validation failed. Cannot proceed with commit.

Errors found:
- SPRINT-003: Missing completion_type field
- FEAT-007: Invalid status transition

Fix these errors before completing the sprint.
Run: ./scripts/validate-sprint-data.sh --verbose

Abort sprint completion? (files not committed)
```

**Interactive mode:** Ask to abort or attempt fix
**Autonomous mode:** Abort automatically, log errors

## Integration with Other Skills

**Upstream Skills (Create Sprints):**
- `scheduling-work-items` - Creates sprints with bugs + features
- `scheduling-features` - Creates feature-only sprints
- Both create sprint documents that this skill reads and completes

**Downstream Skills (After Completion):**
- `scheduling-work-items` / `scheduling-features` - Re-schedule items returned to backlog
- Items appear in "approved features" or "triaged bugs" lists

**Parallel Skills (During Sprint):**
- `fixing-bugs` - Updates bug status to "resolved" (auto-detected by this skill)
- `superpowers:executing-plans` - Updates feature status (auto-detected)
- Manual yaml updates - Respected by this skill

## Files Modified by This Skill

- `bugs.yaml` - Update bug statuses, sprint_ids, add resolved_at/moved_from
- `features.yaml` - Update feature statuses, sprint_ids, add completed_at/completion_percentage/moved_from
- `docs/plans/sprints/SPRINT-XXX-[slug].md` - Update status, add completion metadata, check off items
- `docs/plans/sprints/SPRINT-YYY-[slug].md` - Add moved items (if next sprint)
- `ROADMAP.md` - Move sprint to completed section, update next sprint
- `docs/bugs/index.yaml` - Update bug statuses and sprint_ids
- `docs/features/index.yaml` - Update feature statuses and sprint_ids
- `docs/plans/sprints/retrospectives/SPRINT-XXX-retrospective.md` - Create retrospective (optional)

## Success Criteria

✅ Support both interactive and autonomous modes
✅ Complete sprints by marking work items as done/partial/incomplete
✅ Handle incomplete items with configurable actions (backlog/next sprint/keep)
✅ Support bug binary completion (resolved/not) and feature partial completion (0-100%)
✅ Set completion type (successful/partial/pivoted)
✅ Generate optional retrospectives with stats and manual notes
✅ Update all project files consistently
✅ Move incomplete items to next sprint if it exists
✅ Auto-detect completion from project state
✅ Run validation before commit
✅ Create structured git commits with detailed changelogs
✅ Graceful error handling for all edge cases

---

**Version:** 1.0
**Last Updated:** 2025-11-21
**Integrates:** bugs.yaml + features.yaml + sprint documents + ROADMAP.md → systematic sprint completion
