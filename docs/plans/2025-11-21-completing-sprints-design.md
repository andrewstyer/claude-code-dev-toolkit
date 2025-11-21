# Sprint Completion System Design

**Created:** 2025-11-21
**Status:** Approved
**Purpose:** Create a systematic process for ending sprints, reviewing completion, handling incomplete work, and maintaining data consistency

## Overview

This design establishes a skill for completing sprints in the feature management system. The skill provides both interactive (human-led) and autonomous (Claude-led) modes for systematically ending sprints, updating work item statuses, and maintaining consistency across all project files.

## Goals

1. Provide structured workflow for ending sprints (both active and planned)
2. Support review of work completion with flexible handling of partial/incomplete items
3. Enable both human-interactive and autonomous operation modes
4. Auto-detect completion status from existing project state (git, yaml, plans, roadmap)
5. Handle incomplete work items with configurable disposition (backlog, next sprint, keep)
6. Generate optional sprint retrospectives with statistics and notes
7. Maintain data consistency across bugs.yaml, features.yaml, sprint documents, and ROADMAP.md
8. Provide validation tooling to ensure ongoing data integrity

## System Architecture

### Dual-Mode Operation

```
Interactive Mode (Human-Led)              Autonomous Mode (Claude-Led)
─────────────────────────                ─────────────────────────────
User: "complete sprint"                   User: "auto-complete sprint"
         ↓                                         ↓
AskUserQuestion prompts at                 Auto-detect from project state:
each decision point:                       - bugs.yaml/features.yaml status
- Which sprint to complete?                - ROADMAP.md checkboxes
- Which items completed?                   - Sprint document checkboxes
- How to handle incomplete?                - Implementation plan tasks
- Completion type?                         - Git commit history
- Create retrospective?                    - E2E test results (optional)
         ↓                                         ↓
Human makes all decisions                  Claude makes decisions based on
                                           detection logic + defaults
         ↓                                         ↓
             Update files and commit (same for both modes)
```

### Four-Phase Workflow

```
Phase 1: Select Sprint & Review Completion
    ↓
  Read sprint document, bugs.yaml, features.yaml
  Display all work items
  Mark completed items (bugs: resolved/not, features: completed/partial %)
    ↓
Phase 2: Handle Incomplete Items
    ↓
  Identify incomplete items
  Set default action or review individually
  Update sprint_id and status for each item
    ↓
Phase 3: Sprint Completion Details
    ↓
  Set completion type (successful/partial/pivoted)
  Calculate sprint stats (duration, velocity, completion rate)
  Optionally generate retrospective
    ↓
Phase 4: Update Files and Commit
    ↓
  Update bugs.yaml, features.yaml
  Update sprint document (status, completion metadata)
  Update ROADMAP.md (move to completed section)
  Update index files
  Run validation script
  Git commit with detailed changelog
```

## Skill Design: completing-sprints

### Invocation Modes

**Interactive Mode (Default):**
- Trigger: User says "complete sprint" or similar
- Uses AskUserQuestion for all decisions
- Human reviews and approves each step
- ~5-10 minutes per sprint

**Autonomous Mode:**
- Trigger: User says "auto-complete sprint" or invokes in autonomous context
- Auto-detects completion from project state
- Uses conservative defaults for ambiguous cases
- ~2-3 minutes per sprint

### Phase 1: Select Sprint & Review Completion

#### Interactive Mode

**Step 1: List Active Sprints**
- Read `docs/plans/sprints/` directory
- Filter for sprints with status != "completed"
- Display with summary:
  ```
  Active Sprints:

  SPRINT-001: Core Features (active)
    Goal: Fix critical bugs and implement medication tracking
    Items: 5 features, 2 bugs (7 total)
    Started: 2025-11-07 (14 days ago)
    Progress: 60% (based on current statuses)

  SPRINT-002: UX Polish (planned)
    Goal: Polish user experience
    Items: 2 features, 0 bugs (2 total)
    Starts: 2025-11-21
  ```

**Step 2: Sprint Selection**
- Use AskUserQuestion to select which sprint to complete
- Load sprint document and extract all work item IDs

**Step 3: Display Work Items**
- Read bugs.yaml and features.yaml
- Group and display:
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

**Step 4: Mark Bug Completion**
- Use AskUserQuestion (multiSelect) to mark which bugs are resolved
- Options: List all bugs in sprint, pre-select those with status="resolved"
- User can adjust selections

**Step 5: Mark Feature Completion**
- For each feature, use AskUserQuestion:
  ```
  Question: "What's the completion status of FEAT-001: Add medication tracking?"
  Options:
    - "Completed" (status → completed)
    - "Partially complete - 50%" (status → in-progress, completion_percentage: 50)
    - "Partially complete - 75%" (status → in-progress, completion_percentage: 75)
    - "Incomplete/Not started" (status unchanged)
  ```

**Step 6: Show Completion Summary**
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

#### Autonomous Mode

**Auto-Detection Logic:**

**For Bugs:**
1. Check bugs.yaml status field
   - status="resolved" → Bug is resolved
   - status="in-progress" → Check git commits for "fix BUG-XXX" patterns
   - Otherwise → Incomplete
2. Optional: Run E2E test if exists (expensive, skip by default)
3. Conservative default: If unclear, treat as incomplete

**For Features:**
1. Check features.yaml status field
   - status="completed" → Feature completed
   - status="in-progress" → Calculate partial completion
2. If implementation plan exists:
   - Parse plan for tasks
   - Count checked `[x]` vs unchecked `[ ]` tasks
   - Calculate completion percentage
3. Check ROADMAP.md for `[x]` next to feature ID
4. Check sprint document for `[x]` next to feature
5. If multiple sources conflict: Use features.yaml status as source of truth

**Sprint Selection (Autonomous):**
- If only one active sprint: Auto-select it
- If multiple active sprints: Select oldest active sprint (by created_at)
- If no active sprints: Exit with message

**Display Summary:**
- Show auto-detected completion (same format as interactive summary)
- Proceed automatically (no confirmation in autonomous mode)

### Phase 2: Handle Incomplete Items

#### Interactive Mode

**Step 1: List Incomplete Items**
```
Incomplete Items (4):

Features (3):
  • FEAT-001: Add medication tracking (75% complete)
  • FEAT-005: Export health summary (not started)
  • FEAT-008: Improve navigation (not started)

Bugs (1):
  • BUG-003: Document upload fails (in-progress)
```

**Step 2: Set Default Action**
- Use AskUserQuestion:
  ```
  Question: "How should incomplete items be handled by default?"
  Options:
    - "Return to backlog" (remove sprint_id, reset to triaged/approved)
    - "Move to next sprint" (update sprint_id to SPRINT-002)
    - "Keep in current sprint" (leave sprint_id for historical reference)
    - "Review each individually" (no default, prompt for each)
  ```

**Step 3: Apply Default or Review Individually**

If "Review each individually":
- For each incomplete item, use AskUserQuestion with same 3 options
- Allow different actions for different items

If default action selected:
- Apply to all incomplete items
- Show summary: "4 items will be returned to backlog"

**Step 4: Handle "Move to Next Sprint" Logic**
- Check if next sprint exists (read docs/plans/sprints/, find sprint with ID = current + 1)
- If exists: Update sprint_id, append items to next sprint document
- If not exists:
  ```
  Use AskUserQuestion:
  Question: "Next sprint (SPRINT-002) doesn't exist. What should we do?"
  Options:
    - "Create next sprint now" (invoke scheduling-work-items)
    - "Return to backlog instead" (change action)
    - "Keep in current sprint" (leave as-is)
  ```

#### Autonomous Mode

**Default Action:** Return to backlog (conservative)

**Exception:** High-priority items auto-move to next sprint if it exists
- P0/P1 bugs → Move to next sprint
- Must-Have features → Move to next sprint
- P2 bugs, Nice-to-Have features → Return to backlog

**Next Sprint Logic:**
- If next sprint exists: Move high-priority items
- If not exists: Return all incomplete items to backlog (don't auto-create sprints)

### Phase 3: Sprint Completion Details

#### Interactive Mode

**Step 1: Set Completion Type**
- Use AskUserQuestion:
  ```
  Question: "How would you characterize this sprint completion?"
  Options:
    - "Successful" (goals met, most items completed)
    - "Partial" (some goals met, significant items incomplete)
    - "Pivoted" (sprint redirected, different outcomes than planned)
  ```

**Step 2: Calculate Stats**
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

**Step 3: Ask About Retrospective**
- Use AskUserQuestion:
  ```
  Question: "Create sprint retrospective document?"
  Options:
    - "Yes, with notes" (prompt for what went well, what didn't, action items)
    - "Yes, stats only" (just stats, no manual notes)
    - "No" (skip retrospective)
  ```

**Step 4: Generate Retrospective (if requested)**

If "Yes, with notes":
- Prompt for:
  - "What went well during this sprint?"
  - "What didn't go well or could be improved?"
  - "Action items for next sprint?"

Create file: `docs/plans/sprints/retrospectives/SPRINT-XXX-retrospective.md`

**Template:**
```markdown
# Sprint Retrospective: SPRINT-XXX - [Sprint Name]

**Sprint ID:** SPRINT-XXX
**Sprint Name:** [name]
**Goal:** [goal]
**Completion Type:** [successful/partial/pivoted]
**Duration:** [days] days ([start date] to [end date])

## Statistics

### Completion Summary
- **Total Items:** [total] ([completion rate]% completed)
- **Features:** [completed]/[total] completed ([percentage]%)
  - Partial: [count] features ([list with percentages])
- **Bugs:** [resolved]/[total] resolved ([percentage]%)

### Velocity
- Items completed: [count] in [days] days
- Average: [items/day] items per day

### Incomplete Items Disposition
- Moved to next sprint: [count] items
- Returned to backlog: [count] items
- Kept in sprint: [count] items

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
[User input or "N/A" if stats-only]

### What Didn't Go Well ⚠️
[User input or "N/A" if stats-only]

### Action Items for Next Sprint 🎯
[User input or "N/A" if stats-only]

---

**Created:** [timestamp]
**Sprint Document:** [link to sprint doc]
```

#### Autonomous Mode

**Completion Type (Auto-Determined):**
- Successful: ≥80% items completed
- Partial: 50-79% items completed
- Pivoted: <50% items completed

**Stats:** Calculate same statistics as interactive mode

**Retrospective:**
- Auto-generate with stats only (no manual notes)
- Always create retrospective in autonomous mode (for record-keeping)

### Phase 4: Update Files and Commit

**Step 1: Update bugs.yaml**

For each bug in sprint:

**If resolved:**
```yaml
- id: BUG-001
  # ... existing fields ...
  status: resolved
  resolved_at: "2025-11-21T14:30:00Z"
  updated_at: "2025-11-21T14:30:00Z"
  sprint_id: SPRINT-001  # Keep for historical reference
```

**If incomplete and returning to backlog:**
```yaml
- id: BUG-003
  # ... existing fields ...
  status: triaged  # Reset from in-progress
  # sprint_id: SPRINT-001  ← REMOVE
  # scheduled_at: ...      ← REMOVE
  updated_at: "2025-11-21T14:30:00Z"
```

**If incomplete and moving to next sprint:**
```yaml
- id: BUG-003
  # ... existing fields ...
  status: scheduled  # Or keep current status
  sprint_id: SPRINT-002  # Update from SPRINT-001
  moved_from: SPRINT-001  # Add for tracking
  updated_at: "2025-11-21T14:30:00Z"
```

**If incomplete and staying in current sprint:**
```yaml
- id: BUG-003
  # ... existing fields ...
  # No changes - sprint_id remains SPRINT-001
  updated_at: "2025-11-21T14:30:00Z"
```

**Step 2: Update features.yaml**

Similar logic as bugs, with additional handling for partial completion:

**If completed:**
```yaml
- id: FEAT-003
  # ... existing fields ...
  status: completed
  completed_at: "2025-11-21T14:30:00Z"
  updated_at: "2025-11-21T14:30:00Z"
  sprint_id: SPRINT-001  # Keep for historical reference
```

**If partial completion:**
```yaml
- id: FEAT-001
  # ... existing fields ...
  status: in-progress
  completion_percentage: 75  # Add field
  sprint_id: SPRINT-002  # If moving to next sprint
  moved_from: SPRINT-001
  updated_at: "2025-11-21T14:30:00Z"
```

**Step 3: Update Sprint Document**

File: `docs/plans/sprints/SPRINT-XXX-[slug].md`

**Changes:**
```markdown
# SPRINT-XXX: [Sprint Name]

**Status:** completed  ← Update from "active"
**Created:** [date]
**Completed:** 2025-11-21  ← Add
**Duration:** 14 days  ← Add
**Completion Type:** partial  ← Add
**Goal:** [sprint goal]

## Work Items Summary

- Total Items: 7 (43% completed)  ← Update
- Features: 5 (2 completed, 1 partial, 2 incomplete)  ← Update
- Bugs: 2 (1 resolved, 1 unresolved)  ← Update

## Features

### Must-Have
- [x] FEAT-003: Improve document upload  ← Check completed
  - Status: completed
  - Completed: 2025-11-21

- [ ] FEAT-001: Add medication tracking  ← Add note
  - Status: in-progress (75% complete)
  - Moved to: SPRINT-002

- [ ] FEAT-005: Export health summary  ← Add note
  - Status: approved
  - Returned to backlog

## Bugs

### P0 (Critical)
- [x] BUG-001: Timeline crashes on scroll  ← Check resolved
  - Severity: P0
  - Status: resolved
  - Resolved: 2025-11-21

### P1 (High)
- [ ] BUG-003: Document upload fails  ← Add note
  - Severity: P1
  - Status: in-progress
  - Moved to: SPRINT-002

## Progress

- Total Items: 7
- Completed: 3 (43%)  ← Update
- In Progress: 0  ← Update
- Pending: 4  ← Update

Features: 2/5 complete (40%)  ← Update
Bugs: 1/2 resolved (50%)  ← Update

## Sprint Retrospective

[Link to retrospective if created]
📊 [Retrospective: docs/plans/sprints/retrospectives/SPRINT-001-retrospective.md](retrospectives/SPRINT-001-retrospective.md)

---

**Last Updated:** 2025-11-21T14:30:00Z  ← Update
```

**Step 4: Update ROADMAP.md**

Move sprint from "Current Sprint" or "Active Sprints" to "Completed Sprints":

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
...
```

**After:**
```markdown
## Current Sprint

**SPRINT-002: UX Polish** (active)  ← Promote next sprint
- Goal: Polish user experience
- Items: 4 features, 1 bug (includes 2 moved from SPRINT-001)
...

## Completed Sprints

**SPRINT-001: Core Features** (completed - partial)  ← Move here
- Completed: 2025-11-21
- Duration: 14 days
- Completion: 43% (3/7 items)
- Retrospective: [docs/plans/sprints/retrospectives/SPRINT-001-retrospective.md](sprints/retrospectives/SPRINT-001-retrospective.md)
- Sprint Document: [docs/plans/sprints/SPRINT-001-core-features.md](sprints/SPRINT-001-core-features.md)
```

**Step 5: Update Next Sprint Document (if items moved)**

If items were moved to SPRINT-002, append them to that sprint document:

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

...

## Bugs

### P1 (High)
- [ ] BUG-003: Document upload fails
  - Severity: P1
  - Status: in-progress
  - Moved from: SPRINT-001
```

**Step 6: Update Index Files**

Update `docs/bugs/index.yaml` and `docs/features/index.yaml` with new statuses and sprint_ids

**Step 7: Run Validation Script**

Execute `scripts/validate-sprint-data.sh` before committing:
- Validates consistency across all files
- Catches any errors introduced during update
- If validation fails: Fix errors before committing

**Step 8: Git Commit**

Create structured commit with detailed changelog:

```bash
git add bugs.yaml features.yaml docs/plans/sprints/ docs/bugs/index.yaml docs/features/index.yaml ROADMAP.md

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

**Step 9: Display Summary**

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

## Validation Script Design

### Purpose

Ensure ongoing data consistency across bugs.yaml, features.yaml, sprint documents, and ROADMAP.md

### Script: `scripts/validate-sprint-data.sh`

**Location:** `scripts/validate-sprint-data.sh`

**Validation Checks:**

#### 1. Sprint Document ↔ YAML Consistency

**Check:**
- Every work item (FEAT-XXX, BUG-XXX) in sprint document exists in bugs.yaml or features.yaml
- Every work item with sprint_id field in yaml files exists in that sprint document
- Checkbox state `[x]`/`[ ]` matches status (completed/resolved vs other statuses)

**Errors:**
- Sprint doc references FEAT-999 but FEAT-999 not found in features.yaml
- BUG-005 has sprint_id="SPRINT-003" but not listed in SPRINT-003 document
- FEAT-010 marked `[x]` in sprint doc but status="in-progress" in features.yaml

#### 2. ROADMAP.md ↔ Sprint Documents

**Check:**
- Every sprint listed in ROADMAP.md has corresponding sprint document in docs/plans/sprints/
- Sprint status in ROADMAP matches sprint document status field
- Item counts in ROADMAP match actual counts in sprint documents

**Errors:**
- ROADMAP shows SPRINT-005 but no SPRINT-005-*.md file found
- ROADMAP shows SPRINT-002 as "active" but sprint doc says "completed"
- ROADMAP says "5 features" but sprint doc has 4 features

#### 3. Status Lifecycle Validation

**Check:**
- Bug statuses follow valid transitions:
  - Valid: reported → triaged → scheduled → in-progress → resolved
  - Invalid: reported → completed, scheduled → resolved (skipping in-progress)
- Feature statuses follow valid transitions:
  - Valid: proposed → approved → scheduled → in-progress → completed
  - Invalid: proposed → completed, approved → in-progress (skipping scheduled)

**Warnings (not errors):**
- Feature went from approved → completed (likely manual, but valid)
- Bug went from triaged → resolved (fixed without being scheduled)

#### 4. Orphaned References

**Check:**
- Work items with sprint_id pointing to non-existent sprints
- Sprint documents referencing deleted/archived work items
- Retrospectives without corresponding sprint documents

**Errors:**
- FEAT-020 has sprint_id="SPRINT-099" but SPRINT-099 doesn't exist
- SPRINT-004-*.md references BUG-050 but BUG-050 not in bugs.yaml
- retrospectives/SPRINT-012-retrospective.md exists but no SPRINT-012-*.md

#### 5. Completion Integrity

**Check:**
- Completed sprints have completion_type field
- Completed sprints have completed_at timestamp
- Completed sprints have duration_days field
- Items in completed sprint are either completed/resolved OR have clear disposition (moved/returned)

**Errors:**
- SPRINT-003 status="completed" but missing completion_type
- SPRINT-004 status="completed" but missing completed_at timestamp
- SPRINT-005 completed, has BUG-010 with status="in-progress" and no "moved to" note

### Script Usage

**Basic validation:**
```bash
./scripts/validate-sprint-data.sh
```

**Output:**
```
Sprint Data Validation Report
=============================
Timestamp: 2025-11-21 14:30:00

Checking 5 sprints...

✅ Sprint Document Consistency
   - All work items found in YAML files
   - All sprint_id references valid
   - Checkbox states match statuses

⚠️  ROADMAP.md Consistency (1 warning)
   - SPRINT-003 shows 5 features, actual count is 4

❌ Status Lifecycle (2 errors)
   - FEAT-007: Invalid transition approved → completed (missing scheduled status)
   - BUG-012: Status "resolved" but sprint SPRINT-002 still active

✅ Orphaned References
   - No orphaned work items found
   - No orphaned retrospectives found

❌ Completion Integrity (1 error)
   - SPRINT-001: Missing completion_type field

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: 3 errors, 1 warning

Errors must be fixed before proceeding.
Run with --fix to auto-correct some issues.
Run with --verbose for detailed explanations.

Exit code: 1
```

**Auto-fix mode:**
```bash
./scripts/validate-sprint-data.sh --fix
```

**Fixes applied:**
- Add missing fields (completion_type, completed_at, duration_days) with reasonable defaults
- Update checkboxes to match yaml statuses
- Update item counts in ROADMAP.md
- Cannot fix: Invalid status transitions, orphaned references (requires manual review)

**Verbose mode:**
```bash
./scripts/validate-sprint-data.sh --verbose
```

Shows detailed explanations and suggested fixes for each error.

### Integration Points

**1. In completing-sprints skill:**
- Run validation BEFORE git commit (Phase 4, Step 7)
- If validation fails: Display errors, abort commit
- If validation passes: Proceed with commit

**2. Pre-commit hook (optional):**
- Add to `.git/hooks/pre-commit`
- Runs on any commit touching sprint-related files
- May be slow for large projects, make optional

**3. Slash command:**
```bash
# Add to .claude/commands/validate-sprints.md
/validate-sprints - Run sprint data validation check
```

**4. Weekly maintenance:**
- Run manually as part of USER-GUIDE.md weekly checklist
- Catch drift before it accumulates

### Script Implementation Notes

**Language:** Bash (consistent with other scripts in toolkit)

**Dependencies:**
- `yq` or `jq` for YAML/JSON parsing
- Standard Unix tools: grep, sed, awk
- Optional: Node.js for complex parsing if needed

**Exit codes:**
- 0: All checks passed
- 1: Errors found (must fix)
- 2: Warnings only (can proceed)

**Validation order:**
1. File existence checks (fail fast if missing critical files)
2. YAML parsing (ensure files are valid YAML)
3. Cross-reference checks (sprint docs ↔ yaml ↔ roadmap)
4. Status integrity checks
5. Completion integrity checks (only for completed sprints)

## Integration with Existing Skills

### Upstream Skills (Create Sprints)

**scheduling-work-items:**
- Creates sprints with bugs + features
- Sets status="scheduled" and sprint_id
- This skill reads those sprints and completes them

**scheduling-features:**
- Creates feature-only sprints
- Sets status="scheduled" and sprint_id
- This skill completes those sprints

**Compatibility:**
- Works with sprints created by either skill
- Handles both unified (bugs + features) and feature-only sprints

### Downstream Skills (After Completion)

**scheduling-work-items / scheduling-features:**
- Items returned to backlog can be re-scheduled
- Appear in "approved features" or "triaged bugs" lists
- Can be scheduled into new sprints

**fixing-bugs:**
- Continues to work with bugs in backlog
- Not affected by sprint completion

**Parallel Skills (During Sprint)

**fixing-bugs:**
- Updates bug status to "resolved"
- This skill auto-detects resolved status in autonomous mode
- Interactive mode allows overriding if needed

**superpowers:executing-plans:**
- Updates feature status to "completed" or "in-progress"
- This skill auto-detects from features.yaml and implementation plans
- Can detect partial completion from plan task checkboxes

**Manual updates:**
- Users can manually update bugs.yaml or features.yaml
- This skill respects manual status changes
- Validation script catches inconsistencies

## File Structure Created/Modified

### Created Files

```
docs/plans/sprints/retrospectives/
├── SPRINT-001-retrospective.md
├── SPRINT-002-retrospective.md
└── [future retrospectives]
```

### Modified Files

```
bugs.yaml                                    # Update statuses, sprint_ids
features.yaml                                # Update statuses, sprint_ids, completion %
docs/plans/sprints/SPRINT-XXX-[slug].md     # Update status, add completion metadata
docs/plans/sprints/SPRINT-YYY-[slug].md     # Add moved items (if next sprint)
ROADMAP.md                                   # Move sprint to completed section
docs/bugs/index.yaml                         # Update bug statuses
docs/features/index.yaml                     # Update feature statuses
```

### New Script

```
scripts/validate-sprint-data.sh              # Validation script
```

## Data Schemas

### Sprint Document Completion Metadata

**Added fields when completing:**
```markdown
**Status:** completed
**Completed:** 2025-11-21
**Duration:** 14 days
**Completion Type:** successful | partial | pivoted
```

### Feature Partial Completion

**New field in features.yaml:**
```yaml
- id: FEAT-001
  # ... existing fields ...
  status: in-progress
  completion_percentage: 75  # NEW: 0-100
  updated_at: "2025-11-21T14:30:00Z"
```

### Work Item Move Tracking

**New field when moving items:**
```yaml
- id: BUG-003
  # ... existing fields ...
  sprint_id: SPRINT-002
  moved_from: SPRINT-001  # NEW: Track origin
  updated_at: "2025-11-21T14:30:00Z"
```

## Error Handling

### 1. No Active Sprints Found

**Scenario:** User invokes skill but all sprints are completed

**Handling:**
```
No active sprints to complete.

Active sprints: 0
Completed sprints: 5

All sprints are already completed. Use scheduling-work-items to create new sprints.
```

**Exit:** Gracefully without error

### 2. Sprint Document Missing

**Scenario:** bugs.yaml/features.yaml reference sprint but sprint doc doesn't exist

**Interactive mode:**
```
Use AskUserQuestion:
Question: "Sprint document SPRINT-003-*.md not found but referenced by 5 work items. What should we do?"
Options:
  - "Create sprint document from YAML data"
  - "Skip completing this sprint"
  - "Remove sprint references from YAML"
```

**Autonomous mode:**
- Warn in output
- Skip completing that sprint
- Suggest running validation script

### 3. Work Item Not Found in YAML

**Scenario:** Sprint doc references FEAT-999 but FEAT-999 not in features.yaml

**Interactive mode:**
```
Use AskUserQuestion:
Question: "FEAT-999 listed in sprint document but not found in features.yaml. What should we do?"
Options:
  - "Remove from sprint document" (clean up orphaned reference)
  - "Keep for historical record" (leave in sprint doc)
```

**Autonomous mode:**
- Warn in output
- Keep in sprint doc (don't delete data)
- Mark in validation report

### 4. Next Sprint Doesn't Exist

**Scenario:** User wants to move items to next sprint but it doesn't exist

**Interactive mode:**
```
Use AskUserQuestion:
Question: "Next sprint (SPRINT-004) doesn't exist. How should incomplete items be handled?"
Options:
  - "Create SPRINT-004 now" (invoke scheduling-work-items)
  - "Return to backlog instead" (change action)
  - "Keep in current sprint" (leave for reference)
```

**Autonomous mode:**
- Default: Return all items to backlog
- Don't auto-create sprints (too presumptuous)

### 5. Git Commit Fails

**Scenario:** Git commit fails (merge conflicts, hooks, permissions, etc.)

**Handling:**
- Files are already updated (don't rollback)
- Display error message
- Provide manual commit command:
  ```
  ⚠️  Git commit failed. Files have been updated but not committed.

  To commit manually:
  git add bugs.yaml features.yaml docs/plans/sprints/ ROADMAP.md
  git commit -m "feat: complete SPRINT-001 - Core Features (partial)"

  Error: [git error message]
  ```

### 6. Conflicting Status

**Scenario:** YAML says status="completed" but user says "incomplete" in interactive mode

**Handling:**
```
Use AskUserQuestion:
Question: "FEAT-007 has status='completed' in features.yaml but you marked it as incomplete. Which is correct?"
Options:
  - "Trust YAML status" (keep as completed)
  - "Trust my input" (update YAML to incomplete)
```

**Autonomous mode:**
- Always trust YAML status (source of truth)
- Ignore sprint document checkboxes if they conflict

### 7. Validation Script Fails

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

**Interactive mode:** Ask to abort or fix
**Autonomous mode:** Abort, log errors

## Success Criteria

### Functional Requirements

✅ Support both interactive and autonomous modes
✅ Complete sprints by marking work items as done/partial/incomplete
✅ Handle incomplete items with configurable actions (backlog/next sprint/keep)
✅ Support bug binary completion (resolved/not) and feature partial completion (0-100%)
✅ Set completion type (successful/partial/pivoted)
✅ Generate optional retrospectives with stats and manual notes
✅ Update all project files (bugs.yaml, features.yaml, sprint docs, ROADMAP.md)
✅ Move incomplete items to next sprint if it exists
✅ Auto-detect completion from project state (git, yaml, plans, roadmap)
✅ Provide validation script for ongoing data integrity
✅ Create structured git commits with detailed changelogs

### Non-Functional Requirements

✅ Interactive mode: ~5-10 minutes per sprint
✅ Autonomous mode: ~2-3 minutes per sprint
✅ Clear, structured output at each phase
✅ Graceful error handling for all edge cases
✅ No data loss (files updated before commit, manual recovery possible)
✅ Validation catches inconsistencies before they accumulate

### Integration Requirements

✅ Compatible with scheduling-work-items and scheduling-features
✅ Respects status updates from fixing-bugs and executing-plans
✅ Maintains ROADMAP.md format and structure
✅ Follows existing YAML schema and conventions
✅ Works with both unified (bugs + features) and feature-only sprints

## Testing Strategy

### Unit Testing (Manual Validation)

**Test Case 1: Complete sprint with all items done**
- Create test sprint with 3 features, 2 bugs
- Mark all as completed/resolved
- Verify: All statuses updated, sprint marked completed, ROADMAP updated

**Test Case 2: Complete sprint with partial work**
- Create test sprint with 5 features, 3 bugs
- Mark 2 features completed, 1 feature 75%, 2 features incomplete
- Mark 1 bug resolved, 2 bugs incomplete
- Verify: Partial completion tracked, incomplete items handled correctly

**Test Case 3: Move incomplete items to next sprint**
- Complete sprint with incomplete items
- Choose "move to next sprint"
- Verify: Items appear in next sprint document, sprint_id updated, moved_from tracked

**Test Case 4: Return incomplete items to backlog**
- Complete sprint with incomplete items
- Choose "return to backlog"
- Verify: sprint_id removed, status reset to triaged/approved

**Test Case 5: Autonomous mode completion**
- Set feature status to "completed" in features.yaml
- Set bug status to "resolved" in bugs.yaml
- Run autonomous completion
- Verify: Auto-detection works, sprint completed without prompts

**Test Case 6: Generate retrospective**
- Complete sprint
- Choose "Yes, with notes"
- Provide retrospective notes
- Verify: Retrospective file created with stats and notes

**Test Case 7: Validation script catches errors**
- Manually create inconsistency (sprint_id pointing to non-existent sprint)
- Run validation script
- Verify: Error detected and reported

**Test Case 8: Handle missing next sprint**
- Complete sprint with items to move
- Next sprint doesn't exist
- Verify: Prompted to create or return to backlog (interactive), auto-return (autonomous)

### Integration Testing

**Test Case 9: End-to-end workflow**
1. Create sprint with scheduling-work-items
2. Work on items (update statuses via fixing-bugs, executing-plans)
3. Complete sprint with completing-sprints
4. Verify: All files consistent, validation passes

**Test Case 10: Multiple sprint completion**
- Complete SPRINT-001
- Complete SPRINT-002
- Complete SPRINT-003
- Verify: ROADMAP shows all in correct order, no data corruption

**Test Case 11: Concurrent sprint workflow**
- Have SPRINT-001 active, SPRINT-002 planned
- Complete SPRINT-001, move items to SPRINT-002
- Start SPRINT-003
- Verify: No conflicts, ROADMAP accurate

### Validation Testing

**Test Case 12: Validation catches all error types**
- Create each type of error (orphaned refs, invalid transitions, missing fields)
- Run validation script
- Verify: All errors detected and reported

**Test Case 13: Auto-fix mode**
- Create fixable errors (missing completion_type, wrong checkboxes)
- Run validation with --fix
- Verify: Errors corrected, validation passes

## Future Enhancements (Out of Scope)

**Not included in v1.0 but could be added later:**

1. **Sprint metrics dashboard**
   - Aggregate stats across multiple sprints
   - Velocity trends, completion rate over time
   - Burndown charts

2. **Sprint template system**
   - Create sprint templates for recurring workflows
   - Pre-populate sprints with standard tasks

3. **Sprint cancellation**
   - Separate workflow for cancelling sprints (vs completing)
   - Handle emergencies, pivots, abandoned work

4. **Integration with external tools**
   - Export retrospectives to Notion, Confluence
   - Sync sprint status with GitHub Projects, Jira

5. **Advanced auto-detection**
   - Run E2E tests automatically to verify bug resolution
   - Parse test coverage changes to detect feature completion
   - Use AI to summarize git commits for retrospective notes

6. **Sprint archival**
   - Archive old completed sprints (>6 months) to separate directory
   - Keep ROADMAP.md manageable for large projects

## Implementation Notes

### Skill Creation

**File:** `extensions/feature-management/skills/completing-sprints/SKILL.md`

**Structure:** Follow same pattern as scheduling-work-items, scheduling-features

**Sections:**
1. Metadata (name, description)
2. Overview and when to use
3. Process (Phases 1-4 detailed workflows)
4. Auto-detection logic (for autonomous mode)
5. Integration with other skills
6. Error handling
7. Success criteria
8. Testing

### Script Creation

**File:** `scripts/validate-sprint-data.sh`

**Implementation:**
1. Parse YAML files (use yq or jq)
2. Parse markdown sprint documents (grep, sed, awk)
3. Cross-reference and validate
4. Report errors with clear messages
5. Support --fix flag for auto-correction

### Documentation Updates

**Files to update:**
1. `extensions/feature-management/README.md` - Add completing-sprints skill
2. `EXTENSIONS.md` - Add to skills table
3. `CHANGELOG.md` - Add v2.1.3 entry
4. `README.md` - Update "What's New" section

### Testing Approach

1. Create test project with sample sprints
2. Run through all test cases manually
3. Verify validation script catches all error types
4. Test both interactive and autonomous modes
5. Ensure backward compatibility (doesn't break existing sprints)

## Acceptance Criteria

This design is complete and ready for implementation when:

✅ All four phases clearly defined with step-by-step workflows
✅ Both interactive and autonomous modes specified
✅ Auto-detection logic defined for all work item types
✅ File update logic specified for all YAML and markdown files
✅ Validation script requirements documented
✅ Error handling covers all identified edge cases
✅ Integration points with existing skills mapped
✅ Test cases defined for functional and integration testing
✅ Git commit message format specified
✅ Success criteria measurable and clear

## Summary

This design provides a complete sprint completion system that:
- Works in both human-led (interactive) and autonomous modes
- Auto-detects work completion from existing project state
- Handles partial completion for features (0-100%)
- Provides flexible handling of incomplete items
- Maintains data consistency via validation script
- Generates optional retrospectives for learning
- Integrates seamlessly with existing feature management skills
- Follows established patterns and conventions

The system closes the loop on sprint management: create → work → complete → retrospect → repeat.
