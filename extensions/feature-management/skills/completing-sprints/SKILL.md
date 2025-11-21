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
