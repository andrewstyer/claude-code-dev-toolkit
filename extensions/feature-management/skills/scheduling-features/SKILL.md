---
name: scheduling-features
description: Schedule approved features into sprints with optional implementation planning and execution
---

# Scheduling Features

## Overview

Schedule approved features into sprints, generate sprint documents, and optionally create implementation plans or execute features using superpowers workflow. Integrates with superpowers skills for comprehensive feature development lifecycle.

**Announce at start:** "I'm using the scheduling-features skill to schedule features into sprints."

## When to Use

- User says: "schedule features" or "plan sprint"
- After features have been approved via triaging-features
- At start of new sprint cycle
- When planning implementation work
- When ready to execute approved features

## Process

### Phase 1: Display Approved Features

**Read features.yaml and show all features with status="approved"**

**Display format:**
```
📋 Approved Features Ready for Scheduling

[If none found]
No approved features found. Use /triage-features to approve features first.

[If found, group by priority]

Must-Have Features:
  • FEAT-001: Add medication tracking [New Functionality]
  • FEAT-003: Improve document upload flow [UX Improvement]

Nice-to-Have Features:
  • FEAT-005: Export health summary as PDF [New Functionality]

[If any have epic assigned]
By Epic:
  Epic 1: Core Features
    • FEAT-001: Add medication tracking
    • FEAT-003: Improve document upload flow

[Count] approved features ready for scheduling.
```

**If no approved features:**
- Exit with message: "No approved features to schedule. Use /triage-features to approve features first."

### Phase 2: Apply Filters (Optional)

**Before batch selection, ask about filtering:**
```
Use AskUserQuestion:
Question: "How would you like to filter the features?"
Header: "Filter Options"
multiSelect: false
Options:
  - Label: "All Approved"
    Description: "Show all approved features"
  - Label: "By Priority"
    Description: "Filter by priority level"
  - Label: "By Epic"
    Description: "Filter by specific epic"
  - Label: "By Category"
    Description: "Filter by category type"
```

**If "By Priority" selected:**
```
Use AskUserQuestion:
Question: "Which priority?"
Options: Must-Have | Nice-to-Have | Future
```

**If "By Epic" selected:**
```
List all unique epic values from approved features
Use AskUserQuestion with epic options
```

**If "By Category" selected:**
```
Use AskUserQuestion:
Question: "Which category?"
Options: New Functionality | UX Improvement | Performance | Platform-Specific
```

**Apply filter and re-display matching features**

### Phase 3: Select Sprint Action

**Ask what to do:**
```
Use AskUserQuestion:
Question: "What would you like to do?"
Header: "Sprint Action"
multiSelect: false
Options:
  - Label: "Create New Sprint"
    Description: "Start a new sprint with selected features"
  - Label: "Add to Existing Sprint"
    Description: "Add features to an already-created sprint"
  - Label: "View Sprint Status"
    Description: "Review current sprints and their features"
```

### Phase 4a: Create New Sprint

**If "Create New Sprint" selected:**

**1. Ask for sprint details:**
```
Prompt: "Sprint name?" (e.g., "Sprint 5: Medication Management")
Prompt: "Sprint goal?" (1-2 sentences describing sprint objective)
Prompt: "Sprint duration?" (default: 2 weeks)
```

**2. Generate sprint ID:**
- Read highest sprint ID from features.yaml or docs/plans/sprints/
- Format as SPRINT-{nextId:03d} (e.g., SPRINT-001, SPRINT-002)

**3. Select features for this sprint:**
```
Use AskUserQuestion:
Question: "Select features for this sprint"
Header: "Feature Selection"
multiSelect: true  # IMPORTANT: Allow multiple selection
Options:
  - Label: "FEAT-001: Add medication tracking"
    Description: "Must-Have | New Functionality"
  - Label: "FEAT-003: Improve document upload flow"
    Description: "Must-Have | UX Improvement"
  [... for each approved feature in filtered list]
```

**4. Ask about implementation planning:**
```
Use AskUserQuestion:
Question: "Do you want to create implementation plans now?"
Header: "Planning"
multiSelect: false
Options:
  - Label: "Yes, create plans"
    Description: "Use superpowers:brainstorming + superpowers:writing-plans"
  - Label: "No, schedule only"
    Description: "Just schedule features, plan later"
```

**If "Yes, create plans" → Go to Phase 5**
**If "No, schedule only" → Skip to Phase 6**

### Phase 4b: Add to Existing Sprint

**If "Add to Existing Sprint" selected:**

**1. List existing sprints:**
```
Read docs/plans/sprints/ directory
List all sprints with status != "completed"

Display:
Active Sprints:
  • SPRINT-001: Sprint 5: Medication Management (5 features, 3 in-progress)
  • SPRINT-002: Sprint 6: UX Polish (3 features, 0 in-progress)
```

**2. Select sprint:**
```
Use AskUserQuestion with sprint options
```

**3. Select features to add:**
```
Use AskUserQuestion (multiSelect: true) with approved features
```

**4. Ask about implementation planning (same as Phase 4a step 4)**

### Phase 4c: View Sprint Status

**If "View Sprint Status" selected:**

**Display all sprints with summary:**
```
📊 Sprint Status Overview

Active Sprints:
  SPRINT-001: Sprint 5: Medication Management
    Goal: Implement core medication tracking and management
    Duration: 2 weeks (started 2025-01-14)
    Features: 5 total (2 completed, 3 in-progress, 0 pending)
    Progress: ████████░░░░░░░░ 40%

  SPRINT-002: Sprint 6: UX Polish
    Goal: Improve user experience across key flows
    Duration: 2 weeks (started 2025-01-28)
    Features: 3 total (0 completed, 1 in-progress, 2 pending)
    Progress: ████░░░░░░░░░░░░ 10%

Completed Sprints: 4 (view in docs/plans/sprints/)

Next Steps:
1. Use /schedule-features again to add more features
2. Start implementing features (superpowers workflow)
3. Update feature status as work progresses
```

**Exit after displaying status**

### Phase 5: Implementation Planning (Optional)

**Only if user chose "Yes, create plans" in Phase 4**

**For each selected feature, IN ORDER:**

**Display feature:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Planning: FEAT-XXX

Title: [title]
Description: [description]
User Value: [user_value]
Category: [category]
Priority: [priority]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Run brainstorming:**
```
Invoke superpowers:brainstorming skill with feature details:
- Pass title, description, user_value as context
- Run Socratic refinement process
- Output: Refined design ready for planning
```

**Create implementation plan:**
```
Invoke superpowers:writing-plans skill with brainstorming output:
- Generate detailed implementation tasks
- Output: docs/plans/features/FEAT-XXX-implementation-plan.md
```

**Ask about execution:**
```
Use AskUserQuestion:
Question: "Execute FEAT-XXX implementation now?"
Header: "Execute Feature"
multiSelect: false
Options:
  - Label: "Yes, execute now"
    Description: "Use superpowers:executing-plans or subagent-driven-development"
  - Label: "No, plan only"
    Description: "Save plan for later execution"
```

**If "Yes, execute now":**
```
Ask which execution method:
Use AskUserQuestion:
Question: "How should we execute?"
Options:
  - Label: "Batched Execution"
    Description: "superpowers:executing-plans (review checkpoints)"
  - Label: "Subagent-Driven"
    Description: "superpowers:subagent-driven-development (fast iteration)"
```

**Run selected execution skill**

**Update feature status:**
- If executed: `status: in-progress`
- If planned only: `status: scheduled`
- Add: `implementation_plan: docs/plans/features/FEAT-XXX-implementation-plan.md`
- Add: `sprint_id: SPRINT-XXX`

**Continue to next feature**

### Phase 6: Update Files

**After all features processed:**

**1. Update features.yaml:**
- Change selected features: `status: scheduled` (or `in-progress` if executed)
- Add: `sprint_id: SPRINT-XXX`
- Add: `scheduled_at: [ISO 8601 timestamp]`
- Add: `updated_at: [ISO 8601 timestamp]`
- If implementation plan created: `implementation_plan: [path]`

**2. Create/update sprint document:**

**File:** `docs/plans/sprints/SPRINT-XXX-[sprint-name-slug].md`

**Format:**
```markdown
# SPRINT-XXX: [Sprint Name]

**Status:** active
**Created:** [date]
**Duration:** [duration]
**Goal:** [sprint goal]

## Features

### Must-Have
- [ ] FEAT-001: Add medication tracking
  - Status: scheduled
  - Implementation Plan: docs/plans/features/FEAT-001-implementation-plan.md
  - Owner: [if assigned]

### Nice-to-Have
- [ ] FEAT-005: Export health summary as PDF
  - Status: scheduled
  - Implementation Plan: Not yet created

## Progress

- Total Features: [count]
- Completed: [count] ([percentage]%)
- In Progress: [count]
- Pending: [count]

## Notes

[Any sprint-specific notes or blockers]

---

**Last Updated:** [timestamp]
```

**3. Update docs/features/index.yaml:**
- Update status for scheduled features
- Add sprint_id references

**4. Update/create ROADMAP.md:**

**File:** `ROADMAP.md` (in project root)

**Format:**
```markdown
# Project Roadmap

**Last Updated:** [date]

## Current Sprint

**SPRINT-XXX: [Sprint Name]** (active)
- Goal: [sprint goal]
- Duration: [duration]
- Progress: [X]% complete

Features:
- FEAT-001: Add medication tracking (scheduled)
- FEAT-003: Improve document upload flow (scheduled)

## Upcoming Sprints

**SPRINT-YYY: [Next Sprint Name]** (planned)
- [count] features planned
- Tentative start: [date]

## Backlog by Priority

### Must-Have (Not Yet Scheduled)
- FEAT-XXX: [title]

### Nice-to-Have (Not Yet Scheduled)
- FEAT-YYY: [title]

### Future
- FEAT-ZZZ: [title]

## Completed Sprints

- SPRINT-001: Sprint 4: Core Features ([count] features, completed [date])
- SPRINT-002: Sprint 3: Authentication ([count] features, completed [date])

---

Generated from features.yaml - do not edit manually
Use /schedule-features to update roadmap
```

### Phase 7: Git Commit

**Create descriptive commit:**
```bash
git add features.yaml docs/features/index.yaml docs/plans/sprints/ ROADMAP.md

[If implementation plans created]
git add docs/plans/features/

git commit -m "feat: schedule features for SPRINT-XXX - [sprint name]

Sprint: SPRINT-XXX - [sprint name]
Goal: [sprint goal]
Duration: [duration]

Features scheduled ([count]):
- FEAT-XXX: [title] ([priority])
- FEAT-YYY: [title] ([priority])

[If implementation plans created]
Implementation plans created:
- FEAT-XXX: docs/plans/features/FEAT-XXX-implementation-plan.md

[If any features executed]
Features started:
- FEAT-XXX: [title] (in-progress)

Roadmap updated."
```

### Phase 8: Display Summary

**Show user:**
```
✅ Sprint Scheduling Complete

Sprint: SPRINT-XXX - [Sprint Name]
Goal: [sprint goal]
Duration: [duration]
Status: active

Features Scheduled ([count]):
  • FEAT-001: Add medication tracking (Must-Have)
  • FEAT-003: Improve document upload flow (Must-Have)
  • FEAT-005: Export health summary as PDF (Nice-to-Have)

[If implementation plans created]
Implementation Plans Created:
  • FEAT-001: docs/plans/features/FEAT-001-implementation-plan.md
  • FEAT-003: docs/plans/features/FEAT-003-implementation-plan.md

[If any features executed]
Features In Progress:
  • FEAT-001: Add medication tracking (execution started)

Files Updated:
  • features.yaml (feature statuses updated)
  • docs/features/index.yaml (index updated)
  • docs/plans/sprints/SPRINT-XXX-[slug].md (sprint document created)
  • ROADMAP.md (roadmap regenerated)

Next Steps:
1. Review sprint document: docs/plans/sprints/SPRINT-XXX-[slug].md
2. Execute remaining features when ready
3. Update feature status as work progresses (manual or via skills)
4. Use /schedule-features again to add more features or create new sprints

Changes committed to git.
```

## File Structure Created

**On first use, creates:**
```
project-root/
├── features.yaml                           # Updated with sprint_id
├── ROADMAP.md                              # Auto-generated roadmap
└── docs/
    ├── features/
    │   └── index.yaml                      # Updated with sprint references
    └── plans/
        ├── sprints/
        │   └── SPRINT-XXX-[name].md       # Sprint documents
        └── features/
            └── FEAT-XXX-implementation-plan.md  # Optional implementation plans
```

## Integration with Superpowers

**This skill integrates with:**

1. **superpowers:brainstorming**
   - Used before creating implementation plans
   - Refines feature requirements into detailed design
   - Ensures clarity before planning

2. **superpowers:writing-plans**
   - Creates detailed implementation plans
   - Generates bite-sized tasks with verification steps
   - Output stored in docs/plans/features/

3. **superpowers:executing-plans**
   - Executes implementation plans in batches
   - Review checkpoints between batches
   - Updates feature status to in-progress

4. **superpowers:subagent-driven-development**
   - Fast iteration with code review between tasks
   - Parallel task execution where possible
   - Updates feature status to in-progress

**Workflow examples:**

**Quick scheduling (no planning):**
1. Use scheduling-features skill
2. Select features
3. Choose "No, schedule only"
4. Features marked as "scheduled", sprint document created

**Full lifecycle (planning + execution):**
1. Use scheduling-features skill
2. Select features
3. Choose "Yes, create plans"
4. For each feature: brainstorm → write plan → execute
5. Features marked as "in-progress", implementation plans created

**Sprint planning (defer execution):**
1. Use scheduling-features skill
2. Select features
3. Choose "Yes, create plans" then "No, plan only"
4. Features marked as "scheduled" with implementation plans ready
5. Execute later using superpowers:executing-plans directly

## Data Format

### features.yaml (updated by this skill)

```yaml
nextId: 5
features:
  - id: FEAT-001
    title: "Add medication tracking"
    description: "Allow users to track medications with dosage and schedule"
    category: new-functionality
    user_value: "Helps users manage complex medication regimens"
    priority: must-have
    status: scheduled  # or in-progress if executed
    sprint_id: SPRINT-001
    implementation_plan: docs/plans/features/FEAT-001-implementation-plan.md  # optional
    created_at: "2025-01-14T10:30:00Z"
    scheduled_at: "2025-01-20T14:15:00Z"
    updated_at: "2025-01-20T14:15:00Z"
```

### docs/plans/sprints/SPRINT-001-medication-management.md

See Phase 6 Step 2 for complete format.

### ROADMAP.md

See Phase 6 Step 4 for complete format.

## Error Handling

**If no approved features:**
- Show message
- Suggest using /triage-features first

**If sprint document already exists:**
- Ask: "SPRINT-XXX already exists. Add to existing sprint or create new one?"
- Allow user to choose

**If feature already scheduled:**
- Warn: "FEAT-XXX already scheduled in SPRINT-YYY. Reschedule?"
- Allow override or skip

**If superpowers skills not available:**
- Skip integration steps
- Warn user that implementation planning requires superpowers
- Continue with basic scheduling only

**If git commit fails:**
- Warn user
- Files are still updated
- User can commit manually

## Success Criteria

✅ Approved features scheduled into sprints efficiently
✅ Sprint documents auto-generated with clear structure
✅ ROADMAP.md stays current (auto-updated)
✅ Optional integration with superpowers for full lifecycle
✅ Flexible workflow (schedule now, plan later OR plan + execute immediately)
✅ Clear progress tracking in sprint documents
✅ Git commits with detailed changelog

## Testing

**Test cases:**
1. Schedule features with no planning (quick mode)
2. Schedule features with planning but defer execution
3. Schedule features with planning and immediate execution
4. Add features to existing sprint
5. View sprint status
6. Filter by priority/epic/category before scheduling
7. Handle features already scheduled (reschedule workflow)
8. Verify ROADMAP.md updates correctly
9. Verify index stays in sync

## Notes

- This skill works with status="approved" features
- Scheduling changes status to "scheduled" or "in-progress" (if executed)
- Implementation planning is OPTIONAL - you can schedule without planning
- Execution is OPTIONAL - you can plan without executing
- ROADMAP.md is auto-generated, don't edit manually
- Sprint documents are the source of truth for sprint progress
- Features can be rescheduled if priorities change
- Multiple sprints can be active simultaneously

## Dual-Mode Operation

**Interactive Mode (Default):**
- User says "schedule features"
- Prompts for sprint details, feature selection, epic grouping
- Full human control over sprint composition
- Estimated time: 5-10 minutes per sprint

**Autonomous Mode:**
- User says "auto-schedule features"
- Auto-calculates feature-only velocity from completed sprints
- Auto-groups features by epic (if assigned)
- Auto-selects features by priority (Must-Have → Nice-to-Have)
- Creates feature-only sprint without prompting
- Estimated time: 2-3 minutes per sprint

**Mode Selection:**
Mode is determined by invocation phrase:
- Contains "auto-": Use autonomous mode
- Otherwise: Use interactive mode

## Autonomous Mode - Auto-Detection Logic

### 1. Feature-Only Velocity Calculation

Calculate velocity from feature-only completed sprints:

```bash
# Modified velocity calculation that excludes bugs
calculate_feature_velocity() {
  local roadmap_file="${1:-ROADMAP.md}"

  if [ ! -f "$roadmap_file" ]; then
    echo "0"
    return 1
  fi

  local total_features=0
  local completed_features=0
  local feature_sprint_count=0

  # Find feature-only sprints (0 bugs)
  while IFS= read -r sprint_line; do
    if echo "$sprint_line" | grep -q "completed -"; then
      # Check if sprint has features and 0 bugs
      bug_count=$(echo "$sprint_line" | grep -oE '[0-9]+ bugs' | cut -d' ' -f1)
      feature_count=$(echo "$sprint_line" | grep -oE '[0-9]+ features' | cut -d' ' -f1)

      if [ "$bug_count" = "0" ] && [ -n "$feature_count" ]; then
        ((feature_sprint_count++))
        completed_features=$((completed_features + feature_count))
      fi
    fi
  done < "$roadmap_file"

  if [ $feature_sprint_count -eq 0 ]; then
    # Fall back to general velocity
    echo $(calculate_sprint_velocity)
  else
    local avg_velocity=$((completed_features / feature_sprint_count))
    echo "$avg_velocity"
  fi
}

velocity=$(calculate_feature_velocity)
```

**Fallback hierarchy:**
1. Feature-only velocity (if feature sprints exist)
2. General sprint velocity (if any sprints exist)
3. Default to 5 features per sprint

**Cap:** Maximum 8 features per sprint (features take longer than bugs)

### 2. Epic Grouping Detection

Check if features have epic assignments:

```bash
# Check for epic field in approved features
features_with_epics=$(yq eval '.features[] | select(.status == "approved" and .epic != null) | .id' features.yaml)
epic_count=$(echo "$features_with_epics" | wc -l | tr -d ' ')

if [ $epic_count -gt 0 ]; then
  echo "Found $epic_count features with epic assignments"
  use_epic_grouping=true
else
  echo "No epic assignments, creating single sprint"
  use_epic_grouping=false
fi
```

**Epic grouping strategy:**

```
IF features have epic assignments:
  → Group features by epic
  → Create separate sprint per epic
  → Sprint name: "Sprint XX: [Epic Name]"

ELSE:
  → Create single sprint with highest priority features
  → Sprint name: "Sprint XX: [Theme from titles]"
```

**Example epic grouping:**

```
Approved features:
- FEAT-001: Add login (epic: authentication)
- FEAT-002: Add logout (epic: authentication)
- FEAT-005: Add dashboard (epic: core-ui)
- FEAT-006: Add sidebar (epic: core-ui)

Result:
- SPRINT-001: Authentication (FEAT-001, FEAT-002)
- SPRINT-002: Core UI (FEAT-005, FEAT-006)
```

### 3. Feature Selection (No Epic Grouping)

Priority order:

```
1. Must-Have features (by order in yaml)
2. Nice-to-Have features (if space remains)
3. Future features (if space remains)

Stop when: capacity reached OR no more features
```

## Autonomous Mode - Sprint Creation

**Single Sprint (No Epics):**

```bash
# Similar to scheduling-work-items but features-only
next_id=$(yq eval '.nextId' ROADMAP.md)
sprint_id=$(printf "SPRINT-%03d" $next_id)

theme=$(extract_sprint_themes $selected_feature_ids)
sprint_name="Sprint $next_id: $theme"

sprint_goal="Implement $must_have_count must-have features"
```

**Multiple Sprints (Epic Grouping):**

```bash
# Group features by epic
declare -A epic_features
for feature_id in $approved_features; do
  epic=$(yq eval ".features[] | select(.id == \"$feature_id\") | .epic" features.yaml)
  if [ -n "$epic" ] && [ "$epic" != "null" ]; then
    epic_features[$epic]="${epic_features[$epic]} $feature_id"
  fi
done

# Create sprint per epic
for epic in "${!epic_features[@]}"; do
  sprint_id=$(printf "SPRINT-%03d" $next_id)
  sprint_name="Sprint $next_id: $epic"

  # Create sprint document
  # Add features from epic_features[$epic]

  ((next_id++))
done
```

**Conservative decisions:**
- Don't create implementation plans (user can do that)
- Don't execute features (too presumptuous)
- Maximum 8 features per sprint

## Autonomous Mode - Output Format

**Single Sprint:**

```
✅ Auto-Schedule Complete

Sprint Created: SPRINT-005 - Core Features
Capacity: 6 features (based on velocity: 6.1 features/sprint)
Duration: 2 weeks
Start: 2025-11-21
End: 2025-12-05

Features Scheduled:
  Must-Have (4):
    • FEAT-042: Medication tracking
    • FEAT-043: Export PDF
    • FEAT-044: Document upload
    • FEAT-045: Timeline view

  Nice-to-Have (2):
    • FEAT-046: Dark mode
    • FEAT-047: Offline sync

Files Updated:
  - features.yaml (6 features: approved → scheduled)
  - docs/plans/sprints/SPRINT-005-core-features.md
  - ROADMAP.md

Changes committed to git.

Next: Use executing-plans or superpowers:writing-plans for features
```

**Multiple Sprints (Epic Grouping):**

```
✅ Auto-Schedule Complete

Sprints Created: 2 (grouped by epic)

SPRINT-005: Authentication
  - Duration: 2 weeks
  - Features: 2 (FEAT-001, FEAT-002)

SPRINT-006: Core UI
  - Duration: 2 weeks
  - Features: 2 (FEAT-005, FEAT-006)

Files Updated:
  - features.yaml (4 features: approved → scheduled)
  - docs/plans/sprints/SPRINT-005-authentication.md
  - docs/plans/sprints/SPRINT-006-core-ui.md
  - ROADMAP.md

Changes committed to git.

Next: Work on SPRINT-005 first, then SPRINT-006
```

---

**Version:** 1.0
**Last Updated:** 2025-11-14
**Based on:** Health Narrative 2 feature request system design
