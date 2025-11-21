---
name: scheduling-work-items
description: Unified sprint planning with both bugs and features - schedule approved features and triaged bugs together
---

# Scheduling Work Items

## Overview

Unified sprint planning that shows both approved features and triaged bugs. Schedule work items together based on priority, capacity, and sprint goals. Creates sprints with mixed bugs and features, updates ROADMAP.md with unified view.

**Announce at start:** "I'm using the scheduling-work-items skill for unified sprint planning."

## When to Use

- Planning a new sprint with both bugs and features
- Want to prioritize across bugs vs features (e.g., "P0 bug vs Must-Have feature?")
- Need unified view of all schedulable work
- Capacity planning for sprint ("We can do 10 items total")
- After triaging bugs and features separately

## Dual-Mode Operation

**Interactive Mode (Default):**
- User says "schedule work items"
- Prompts for sprint details, item selection, execution decisions
- Full human control over sprint composition
- Estimated time: 5-10 minutes per sprint

**Autonomous Mode:**
- User says "auto-schedule work items"
- Auto-calculates velocity from completed sprints
- Auto-selects items based on priority (P0→P1→Must-Have→Nice-to-Have)
- Auto-generates sprint theme from item titles
- Creates sprint without prompting for execution
- Estimated time: 2-3 minutes per sprint

**Mode Selection:**
Mode is determined by invocation phrase:
- Contains "auto-": Use autonomous mode
- Otherwise: Use interactive mode

## Process

### Phase 1: Display All Schedulable Work

**Read both bugs.yaml and features.yaml:**

```typescript
// Read approved features (status="approved")
const approvedFeatures = features.filter(f => f.status === 'approved');

// Read triaged bugs (status="triaged") - bugs not yet assigned to sprint
const triagedBugs = bugs.filter(b => b.status === 'triaged');

const totalWork = approvedFeatures.length + triagedBugs.length;
```

**Display unified work items:**

```
📋 Work Items Ready for Scheduling

BUGS (${triagedBugs.length}):

P0 (Critical) - ${p0Bugs.length} bugs:
  • BUG-001: Timeline crashes on scroll
  • BUG-005: Data loss on app backgrounding

P1 (High) - ${p1Bugs.length} bugs:
  • BUG-003: Document upload fails on large PDFs

P2 (Low) - ${p2Bugs.length} bugs:
  • BUG-007: UI alignment issue on iPad

FEATURES (${approvedFeatures.length}):

Must-Have - ${mustHaveFeatures.length} features:
  • FEAT-001: Add medication tracking
  • FEAT-003: Improve document upload flow

Nice-to-Have - ${niceToHaveFeatures.length} features:
  • FEAT-005: Export health summary as PDF

Future - ${futureFeatures.length} features:
  • FEAT-004: Add dark mode support

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total work items: ${totalWork}
  • Bugs: ${triagedBugs.length}
  • Features: ${approvedFeatures.length}
```

**If no work items:**
- Exit with message: "No work items to schedule. Use /triage-bugs and /triage-features to prepare work items."

### Phase 2: Apply Filters (Optional)

**Ask about filtering:**

```
Use AskUserQuestion:
Question: "How would you like to filter work items?"
Header: "Filter Options"
multiSelect: false
Options:
  - Label: "All Work Items"
    Description: "Show all bugs and features"
  - Label: "Bugs Only"
    Description: "Show only triaged bugs"
  - Label: "Features Only"
    Description: "Show only approved features"
  - Label: "High Priority Only"
    Description: "P0/P1 bugs + Must-Have features"
  - Label: "By Category"
    Description: "Filter features by category"
```

**Apply filters and re-display**

### Phase 3: Sprint Selection

**Ask about sprint action:**

```
Use AskUserQuestion:
Question: "What would you like to do?"
Header: "Sprint Action"
multiSelect: false
Options:
  - Label: "Create New Sprint"
    Description: "Start a new sprint with selected work items"
  - Label: "Add to Existing Sprint"
    Description: "Add work items to an active sprint"
  - Label: "View Sprint Status"
    Description: "Review current sprints with bugs and features"
```

### Phase 4a: Create New Sprint

**If "Create New Sprint" selected:**

**1. Ask for sprint details:**
```
Prompt: "Sprint name?" (e.g., "Sprint 5: Bugs and Core Features")
Prompt: "Sprint duration?" (default: 2 weeks)
Prompt: "Sprint goal?" (e.g., "Fix critical bugs and add medication tracking")
```

**2. Generate sprint ID:**
```
Read highest sprint ID from docs/plans/sprints/
Format as SPRINT-{nextId:03d}
```

**3. Select work items for sprint:**

```
Use AskUserQuestion:
Question: "Select work items for this sprint"
Header: "Work Item Selection"
multiSelect: true  # IMPORTANT: Allow multiple selection
Options:
  - Label: "BUG-001: Timeline crashes on scroll"
    Description: "P0 (Critical) - 2 days old"
  - Label: "BUG-003: Document upload fails"
    Description: "P1 (High) - 4 days old"
  - Label: "FEAT-001: Add medication tracking"
    Description: "Must-Have | New Functionality"
  - Label: "FEAT-003: Improve document upload flow"
    Description: "Must-Have | UX Improvement"
  [... for each work item]
```

**4. Display capacity check:**

```
Selected work items: ${selectedItems.length}
  • Bugs: ${selectedBugs.length}
  • Features: ${selectedFeatures.length}

Estimated complexity:
  • ${selectedBugs.filter(b => b.severity === 'P0').length} P0 bugs (high urgency)
  • ${selectedBugs.filter(b => b.severity === 'P1').length} P1 bugs (medium urgency)
  • ${selectedFeatures.filter(f => f.priority === 'must-have').length} must-have features

Use AskUserQuestion:
Question: "Does this capacity look reasonable for ${sprintDuration}?"
Options:
  - Label: "Yes, continue"
  - Label: "No, let me adjust selection"
```

**If "No, let me adjust" → repeat selection**

**5. Ask about implementation planning:**

```
Use AskUserQuestion:
Question: "Create implementation plans for features now?"
Header: "Planning"
multiSelect: false
Options:
  - Label: "Yes, create plans"
    Description: "Use superpowers:brainstorming + superpowers:writing-plans for features"
  - Label: "No, schedule only"
    Description: "Just schedule items, plan later"
```

**If "Yes, create plans" → Run superpowers workflow for each feature (like scheduling-features does)**

**Skip to Phase 5**

### Phase 4b: Add to Existing Sprint

**If "Add to Existing Sprint" selected:**

**1. List existing sprints:**

```
Read docs/plans/sprints/ directory
List all sprints with status != "completed"

Display:
Active Sprints:
  • SPRINT-001: Core Features (3 features, 2 bugs, 5 items total)
  • SPRINT-002: UX Polish (2 features, 0 bugs, 2 items total)
```

**2. Select sprint:**
```
Use AskUserQuestion with sprint options
```

**3. Select work items to add:**
```
Use AskUserQuestion (multiSelect: true) with all work items
```

**4. Ask about implementation planning (same as 4a step 5)**

### Phase 4c: View Sprint Status

**If "View Sprint Status" selected:**

**Display all sprints with bugs and features:**

```
📊 Sprint Status Overview

Active Sprints:

SPRINT-001: Core Features
  Goal: Fix critical bugs and implement medication tracking
  Duration: 2 weeks (started 2025-01-14)
  Progress: ████████░░░░░░░░ 40%

  Features: 3 total (1 completed, 1 in-progress, 1 pending)
    ✅ FEAT-002: Export health summary
    ⏳ FEAT-001: Add medication tracking
    ⏹ FEAT-003: Improve document upload

  Bugs: 2 total (1 resolved, 1 in-progress)
    ✅ BUG-005: Data loss on backgrounding
    ⏳ BUG-001: Timeline crashes on scroll

SPRINT-002: UX Polish
  Goal: Polish user experience
  Duration: 2 weeks (starts 2025-01-28)
  Progress: ░░░░░░░░░░░░░░░░ 0%

  Features: 2 total (0 completed, 0 in-progress, 2 pending)
    ⏹ FEAT-007: Add onboarding flow
    ⏹ FEAT-008: Improve navigation

  Bugs: 0 total

Completed Sprints: 4 (view in docs/plans/sprints/)

Next Steps:
1. Use scheduling-work-items to add more items to sprints
2. Start working on pending items
3. Update item status as work progresses
```

**Exit after displaying status**

### Phase 5: Update Files

**After work items selected:**

**1. Update bugs.yaml:**

```yaml
# For each selected bug
- id: BUG-001
  # ... existing fields ...
  status: scheduled  # Update from 'triaged' to 'scheduled'
  sprint_id: SPRINT-001
  scheduled_at: "2025-01-20T14:15:00Z"
  updated_at: "2025-01-20T14:15:00Z"
```

**2. Update features.yaml:**

```yaml
# For each selected feature
- id: FEAT-001
  # ... existing fields ...
  status: scheduled  # Update from 'approved' to 'scheduled'
  sprint_id: SPRINT-001
  scheduled_at: "2025-01-20T14:15:00Z"
  updated_at: "2025-01-20T14:15:00Z"
```

**3. Create/update sprint document:**

**File:** `docs/plans/sprints/SPRINT-XXX-[sprint-name-slug].md`

**Format:**

```markdown
# SPRINT-XXX: [Sprint Name]

**Status:** active
**Created:** [date]
**Duration:** [duration]
**Goal:** [sprint goal]

## Work Items Summary

- Total Items: ${totalItems}
- Features: ${featureCount}
- Bugs: ${bugCount}

## Features

### Must-Have
- [ ] FEAT-001: Add medication tracking
  - Status: scheduled
  - Priority: must-have
  - Category: new-functionality
  - Implementation Plan: docs/plans/features/FEAT-001-implementation-plan.md

### Nice-to-Have
- [ ] FEAT-005: Export health summary as PDF
  - Status: scheduled
  - Priority: nice-to-have
  - Category: new-functionality

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

## Progress

- Total Items: ${totalItems}
- Completed: 0 (0%)
- In Progress: 0
- Pending: ${totalItems}

Features: 0/${featureCount} complete
Bugs: 0/${bugCount} resolved

## Sprint Goals

1. Fix all P0 bugs
2. Implement medication tracking MVP
3. Improve document upload reliability

## Notes

[Any sprint-specific notes]

---

**Last Updated:** [timestamp]
```

**4. Update ROADMAP.md:**

**Format:**

```markdown
# Project Roadmap

**Last Updated:** [date]

## Current Sprint

**SPRINT-001: Core Features** (active)
- Goal: Fix critical bugs and implement medication tracking
- Duration: 2 weeks
- Progress: 0% complete (0/${totalItems} items)

### Features (${featureCount})
- [ ] FEAT-001: Add medication tracking (Must-Have)
- [ ] FEAT-005: Export health summary as PDF (Nice-to-Have)

### Bugs (${bugCount})
- [ ] BUG-001: Timeline crashes on scroll (P0)
- [ ] BUG-003: Document upload fails on large PDFs (P1)

## Upcoming Sprints

**SPRINT-002: UX Polish** (planned)
- 2 features planned
- Tentative start: [date]

## Backlog

### Features (Approved, Not Scheduled)
- FEAT-007: Add onboarding flow (Must-Have)

### Bugs (Triaged, Not Scheduled)
- BUG-007: UI alignment issue on iPad (P2)

---

Generated from bugs.yaml and features.yaml
Use /schedule-work-items to update roadmap
```

**5. Update index files:**

- `docs/bugs/index.yaml` - Update bug statuses and sprint_id
- `docs/features/index.yaml` - Update feature statuses and sprint_id

### Phase 6: Git Commit

**Create descriptive commit:**

```bash
git add bugs.yaml features.yaml docs/bugs/index.yaml docs/features/index.yaml docs/plans/sprints/ ROADMAP.md

[If implementation plans created]
git add docs/plans/features/

git commit -m "feat: schedule work items into ${sprintName}

Sprint: ${sprintId} - ${sprintName}
Goal: ${sprintGoal}
Duration: ${sprintDuration}

Work items scheduled (${totalItems}):

Features (${featureCount}):
${selectedFeatures.map(f => `- ${f.id}: ${f.title} (${f.priority})`).join('\n')}

Bugs (${bugCount}):
${selectedBugs.map(b => `- ${b.id}: ${b.title} (${b.severity})`).join('\n')}

[If implementation plans created]
Implementation plans created:
${plansCreated.map(p => `- ${p}`).join('\n')}

Roadmap and sprint document updated with unified work items."
```

### Phase 7: Display Summary

**Show user:**

```
✅ Work Items Scheduled

Sprint: ${sprintId} - ${sprintName}
Goal: ${sprintGoal}
Duration: ${sprintDuration}
Status: active

Work Items (${totalItems}):

Features (${featureCount}):
  • FEAT-001: Add medication tracking (Must-Have)
  • FEAT-005: Export health summary (Nice-to-Have)

Bugs (${bugCount}):
  • BUG-001: Timeline crashes on scroll (P0)
  • BUG-003: Document upload fails (P1)

[If implementation plans created]
Implementation Plans Created:
  • FEAT-001: docs/plans/features/FEAT-001-implementation-plan.md

Files Updated:
  • bugs.yaml (${bugCount} bugs: triaged → scheduled)
  • features.yaml (${featureCount} features: approved → scheduled)
  • docs/plans/sprints/${sprintId}-[slug].md (sprint document created)
  • ROADMAP.md (unified bugs + features view)
  • Index files updated

Progress Tracking:
  • Sprint document shows bugs and features together
  • ROADMAP.md shows unified view with progress
  • Update item status as work progresses

Next Steps:
1. Review sprint document: docs/plans/sprints/${sprintId}-[slug].md
2. Review ROADMAP.md for unified view
3. Start working on highest priority items (P0 bugs, Must-Have features)
4. Update status as items complete (use fixing-bugs skill for bugs)

Changes committed to git.
```

## Autonomous Mode - Auto-Detection Logic

### 1. Velocity Calculation

Uses shared function from `scripts/autonomous-helpers.sh`:

```bash
# Calculate average items per sprint from completed sprints
velocity=$(calculate_sprint_velocity)

if [ "$velocity" = "0" ]; then
  # No completed sprints, use default capacity
  velocity=5
  echo "No velocity data available, using default capacity: 5 items"
else
  echo "Calculated velocity: $velocity items per sprint (from completed sprints)"
fi
```

**Fallback:** If no completed sprints exist, default to 5 items per sprint

**Cap:** Maximum 10 items per sprint (regardless of velocity)

**Formula:**
```
sprint_capacity = min(velocity, available_items, 10)
```

### 2. Available Work Items

```bash
# Count triaged bugs
triaged_bugs=$(yq eval '.bugs[] | select(.status == "triaged") | .id' bugs.yaml)
bug_count=$(echo "$triaged_bugs" | wc -l | tr -d ' ')

# Count approved features
approved_features=$(yq eval '.features[] | select(.status == "approved") | .id' features.yaml)
feature_count=$(echo "$approved_features" | wc -l | tr -d ' ')

total_available=$((bug_count + feature_count))

echo "Available work items: $total_available ($bug_count bugs, $feature_count features)"
```

**Minimum threshold:** Need at least 3 items to create a sprint

### 3. Sprint Theme Generation

Uses shared function:

```bash
# Generate theme from selected item IDs
selected_ids="$bug_ids $feature_ids"
theme=$(extract_sprint_themes $selected_ids)

sprint_name="Sprint $next_id: $theme"
```

**Example themes:**
- "Bug Fixes and Core Features"
- "Timeline and Document Management"
- "Performance and UX Polish"

## Autonomous Mode - Item Selection Rules

**Priority order for filling sprint capacity:**

```
1. All P0 bugs (critical) - must fix immediately
2. All P1 bugs (high priority)
3. Must-Have features (by priority order in yaml)
4. Nice-to-Have features (if space remains)
5. P2 bugs (if space remains)

Stop when: capacity reached OR no more items
```

**Selection algorithm:**

```bash
capacity=$velocity  # From velocity calculation
selected=()

# Step 1: Add all P0 bugs (no limit)
p0_bugs=$(yq eval '.bugs[] | select(.status == "triaged" and .severity == "P0") | .id' bugs.yaml)
for bug_id in $p0_bugs; do
  selected+=("$bug_id")
done

# Step 2: Add P1 bugs up to capacity
remaining=$((capacity - ${#selected[@]}))
if [ $remaining -gt 0 ]; then
  p1_bugs=$(yq eval '.bugs[] | select(.status == "triaged" and .severity == "P1") | .id' bugs.yaml | head -$remaining)
  for bug_id in $p1_bugs; do
    selected+=("$bug_id")
  done
fi

# Step 3: Add Must-Have features
remaining=$((capacity - ${#selected[@]}))
if [ $remaining -gt 0 ]; then
  must_have=$(yq eval '.features[] | select(.status == "approved" and .priority == "must-have") | .id' features.yaml | head -$remaining)
  for feat_id in $must_have; do
    selected+=("$feat_id")
  done
fi

# Step 4: Add Nice-to-Have features
remaining=$((capacity - ${#selected[@]}))
if [ $remaining -gt 0 ]; then
  nice_to_have=$(yq eval '.features[] | select(.status == "approved" and .priority == "nice-to-have") | .id' features.yaml | head -$remaining)
  for feat_id in $nice_to_have; do
    selected+=("$feat_id")
  done
fi

# Step 5: Add P2 bugs if space
remaining=$((capacity - ${#selected[@]}))
if [ $remaining -gt 0 ]; then
  p2_bugs=$(yq eval '.bugs[] | select(.status == "triaged" and .severity == "P2") | .id' bugs.yaml | head -$remaining)
  for bug_id in $p2_bugs; do
    selected+=("$bug_id")
  done
fi
```

**Conservative decisions:**
- Don't create implementation plans (too time-consuming)
- Don't execute features automatically (too presumptuous)
- Just create sprint and schedule items

## Autonomous Mode - Sprint Creation

**Sprint metadata generation:**

```bash
# Get next sprint ID
next_id=$(yq eval '.nextId' ROADMAP.md 2>/dev/null || echo "1")
sprint_id=$(printf "SPRINT-%03d" $next_id)

# Generate sprint name
theme=$(extract_sprint_themes ${selected[@]})
sprint_name="Sprint $next_id: $theme"

# Generate sprint slug
slug=$(echo "$theme" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

# Sprint goal
p0_count=$(echo "${selected[@]}" | tr ' ' '\n' | grep -c '^BUG-' || echo 0)
must_have_count=$(count_must_have_features "${selected[@]}")

sprint_goal="Address $p0_count critical bugs and $must_have_count must-have features"

# Sprint duration
sprint_duration="2 weeks"  # Default

# Sprint dates
start_date=$(date -u +%Y-%m-%d)
end_date=$(date -u -v+14d +%Y-%m-%d 2>/dev/null || date -u -d '+14 days' +%Y-%m-%d)
```

**Sprint document structure:**

Create `docs/plans/sprints/${sprint_id}-${slug}.md`:

```markdown
# ${sprint_name}

**Status:** active
**Created:** ${start_date}
**Goal:** ${sprint_goal}
**Duration:** ${sprint_duration}
**End Date:** ${end_date}

## Work Items Summary

- Total Items: ${item_count}
- Bugs: ${bug_count}
- Features: ${feature_count}

## Bugs

### P0 (Critical)
[List P0 bugs]

### P1 (High)
[List P1 bugs]

### P2 (Low)
[List P2 bugs]

## Features

### Must-Have
[List must-have features]

### Nice-to-Have
[List nice-to-have features]

## Progress

- Total Items: ${item_count}
- Completed: 0 (0%)
- In Progress: 0
- Pending: ${item_count}

---

**Last Updated:** ${timestamp}
```

## Autonomous Mode - File Updates

**Update bugs.yaml:**

```bash
for bug_id in $selected_bug_ids; do
  # Update status to scheduled
  update_item_status "$bug_id" "scheduled"

  # Add sprint_id
  yq eval "(.bugs[] | select(.id == \"$bug_id\") | .sprint_id) = \"$sprint_id\"" -i bugs.yaml

  # Add scheduled_at timestamp
  yq eval "(.bugs[] | select(.id == \"$bug_id\") | .scheduled_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i bugs.yaml
done
```

**Update features.yaml:**

```bash
for feature_id in $selected_feature_ids; do
  # Update status to scheduled
  update_item_status "$feature_id" "scheduled"

  # Add sprint_id
  yq eval "(.features[] | select(.id == \"$feature_id\") | .sprint_id) = \"$sprint_id\"" -i features.yaml

  # Add scheduled_at timestamp
  yq eval "(.features[] | select(.id == \"$feature_id\") | .scheduled_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i features.yaml
done
```

**Update ROADMAP.md:**

Add sprint to "Current Sprint" or "Active Sprints" section:

```markdown
## Current Sprint

**${sprint_name}** (active)
- Goal: ${sprint_goal}
- Duration: ${sprint_duration}
- Items: ${item_count} (${bug_count} bugs, ${feature_count} features)
- Started: ${start_date}
- Expected end: ${end_date}

### Bugs (${bug_count})
[List bugs]

### Features (${feature_count})
[List features]
```

**Increment next sprint ID:**

```bash
yq eval '.nextId += 1' -i ROADMAP.md
```

## Autonomous Mode - Output Format

```
✅ Auto-Schedule Complete

Sprint Created: SPRINT-007 - Bug Fixes and Core Features
Capacity: 7 items (based on velocity: 7.2 items/sprint)
Duration: 2 weeks
Start: 2025-11-21
End: 2025-12-05

Work Items Scheduled:
  Bugs (3):
    • BUG-023: Timeline crashes (P0)
    • BUG-025: Data loss on save (P0)
    • BUG-027: Upload fails (P1)

  Features (4):
    • FEAT-042: Medication tracking (Must-Have)
    • FEAT-043: Export PDF (Must-Have)
    • FEAT-045: Dark mode (Nice-to-Have)
    • FEAT-046: Offline sync (Nice-to-Have)

Files Updated:
  - bugs.yaml (3 bugs: triaged → scheduled)
  - features.yaml (4 features: approved → scheduled)
  - docs/plans/sprints/SPRINT-007-bug-fixes-and-core-features.md
  - ROADMAP.md

Changes committed to git.

Next Steps:
  1. Start working on SPRINT-007 items
  2. Use fixing-bugs or executing-plans for implementation

Note: Run "schedule work items" (interactive) for custom sprint planning.
```

## Error Handling - Autonomous Mode

**Error 1: Not enough items**

```
If available_items < 3:
  → Display: "Not enough items for sprint (need ≥3, have ${available_items})"
  → Display: "Run 'triage bugs' or 'triage features' to add more items"
  → Exit without creating sprint
```

**Error 2: No velocity data**

```
If velocity = 0:
  → Use default capacity: 5 items
  → Add note: "No velocity data, using default capacity"
  → Continue with sprint creation
```

**Error 3: ROADMAP.md missing**

```
If ROADMAP.md not found:
  → Create ROADMAP.md with default structure
  → Set nextId to 1
  → Continue with sprint creation
```

**Conservative fallbacks:**
- Always use minimum 3 items, maximum 10 items
- Default to 5 items if velocity unavailable
- Default to 2-week duration

## Integration with Other Skills

**Upstream skills:**
- **triaging-bugs** - Creates triaged bugs (status="triaged")
- **triaging-features** - Creates approved features (status="approved")

**This skill (scheduling-work-items):**
- Reads both bugs.yaml and features.yaml
- Shows unified view of schedulable work
- Creates sprints with both bugs and features
- Updates ROADMAP.md with unified progress

**Downstream skills:**
- **fixing-bugs** - Reads bugs with status="scheduled" or "triaged", updates to "in-progress" → "resolved"
- **superpowers:executing-plans** - Reads ROADMAP.md for task execution

## Comparison with Other Scheduling Skills

**scheduling-features:**
- Works ONLY with features.yaml
- Creates sprints with features only
- Optional: Create implementation plans for features

**scheduling-work-items (this skill):**
- Works with BOTH bugs.yaml AND features.yaml
- Creates sprints with bugs AND features
- Unified prioritization (P0 bug vs Must-Have feature)
- Better for capacity planning
- Optional: Create implementation plans for features only (bugs use fixing-bugs workflow)

**When to use which:**
- Use **scheduling-features** if you only have features to schedule
- Use **scheduling-work-items** if you have both bugs and features
- Use **triaging-bugs** with "Assign to Sprint" if you only have bugs and existing sprint

## Error Handling

**If no work items available:**
- Show message: "No work items to schedule"
- Suggest using triaging-bugs and triaging-features first

**If sprint document already exists:**
- Ask: "SPRINT-XXX exists. Add to existing or create new?"

**If work item already scheduled:**
- Warn: "FEAT-XXX/BUG-XXX already in SPRINT-YYY. Reschedule?"
- Allow override or skip

**If git commit fails:**
- Warn user
- Files are still updated
- User can commit manually

## Success Criteria

✅ Display unified view of bugs and features
✅ Filter by priority, type, or category
✅ Create sprints with mixed bugs and features
✅ Update both bugs.yaml and features.yaml with sprint_id
✅ Generate sprint documents with bugs and features sections
✅ Update ROADMAP.md with unified view
✅ Support capacity planning (show totals before committing)
✅ Clear progress tracking in sprint documents
✅ Git commit with detailed changelog

## Testing

**Test cases:**
1. Schedule sprint with 2 bugs + 3 features
2. Add 1 bug to existing sprint
3. Filter by "High Priority Only" (P0/P1 bugs + Must-Have features)
4. View sprint status with unified bugs + features
5. Create implementation plans for features (not bugs)
6. Verify ROADMAP.md shows both bugs and features
7. Verify sprint document has both sections
8. Handle case where all bugs already scheduled

## Notes

- This skill provides unified sprint planning across bugs and features
- Use triaging-bugs "Assign to Sprint" for quick bug-only sprint assignment
- Use scheduling-features for feature-only sprint planning
- Use this skill when you want to prioritize across both bugs and features
- Implementation plans are only created for features (bugs use fixing-bugs workflow)
- ROADMAP.md shows unified view of all work in sprints

---

**Version:** 1.0
**Last Updated:** 2025-11-14
**Integrates:** bugs.yaml + features.yaml → unified sprint planning
