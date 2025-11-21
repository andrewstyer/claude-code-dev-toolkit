# Autonomous Modes for All Skills - Design Document

**Created:** 2025-11-21
**Status:** Approved
**Purpose:** Add autonomous modes to all 6 remaining skills following the completing-sprints pattern

## Overview

This design adds autonomous operation modes to all skills in the dev-toolkit, enabling Claude to execute common workflows without human prompting at each decision point. Each skill will support dual-mode operation: interactive (human-controlled) and autonomous (auto-detected).

## Goals

1. Add autonomous modes to 6 skills: triaging-bugs, triaging-features, scheduling-work-items, scheduling-features, scheduling-implementation-plan, fixing-bugs
2. Follow completing-sprints pattern for consistency
3. Use parallel agent execution for faster implementation (3 waves)
4. Create shared utilities to reduce code duplication
5. Maintain backward compatibility (interactive mode unchanged)
6. Enable fully autonomous workflows: auto-triage → auto-schedule → auto-complete

## Execution Strategy

### Three-Wave Parallel Implementation

**Wave 1: High-Value Triage Skills** (2 parallel agents, ~30-45 min)
- Agent 1: triaging-bugs autonomous mode (aggressive)
- Agent 2: triaging-features autonomous mode (aggressive)
- **Review checkpoint:** Validate both implementations before Wave 2

**Wave 2: Scheduling Skills** (2 parallel agents, ~45-60 min)
- Agent 3: scheduling-work-items autonomous mode (moderate)
- Agent 4: scheduling-features autonomous mode (moderate)
- **Review checkpoint:** Validate both implementations before Wave 3

**Wave 3: Polish Skills** (2 parallel agents, ~30-45 min)
- Agent 5: scheduling-implementation-plan autonomous mode (conservative)
- Agent 6: fixing-bugs autonomous enhancements (conservative)
- **Final review:** Integration testing and documentation

**Why waves vs all at once:**
- Review checkpoints ensure quality
- Wave 1 establishes pattern for Waves 2-3
- Can course-correct between waves if needed
- Less overwhelming to review 2 implementations vs 6

**Total time:** ~3-4 hours including reviews

## System Architecture

### Dual-Mode Pattern (All Skills)

```
User Invocation
      ↓
Mode Detection ("auto-" prefix?)
      ↓
   ┌──────┴──────┐
   │             │
Interactive  Autonomous
   │             │
   │         Auto-detect from:
   │         - YAML files
   │         - Git commits
   │         - ROADMAP.md
   │         - Implementation plans
   │         - Project context
   │             │
   │         Apply decision rules
   │         (per-skill aggressiveness)
   │             │
   └─────┬───────┘
         │
    Update files
         │
    Git commit
         │
    Display summary
```

### Aggressiveness Levels by Skill

| Skill | Level | Rationale |
|-------|-------|-----------|
| triaging-bugs | Aggressive | Easy to undo (just retriage), high value |
| triaging-features | Aggressive | Easy to undo (just retriage), high value |
| scheduling-work-items | Moderate | Medium risk (creating sprints), needs velocity data |
| scheduling-features | Moderate | Medium risk (creating sprints), needs velocity data |
| scheduling-implementation-plan | Conservative | Low frequency use, complex decisions |
| fixing-bugs | Conservative | Code changes, need confidence in bug selection |

## Skill-Specific Designs

### Wave 1: Triage Skills

#### triaging-bugs Autonomous Mode

**Invocation:** "auto-triage bugs"

**Auto-Detection Logic:**

**1. Severity Detection:**
```
Read bug title and description
Scan for keywords:
  - P0 keywords: "crash", "data loss", "corruption", "breaks app", "unusable"
  - P1 keywords: "broken", "fails", "error", "doesn't work", "blocks", "regression"
  - P2 keywords: "alignment", "styling", "minor", "cosmetic", "polish", "typo"

Priority match order: P0 first, then P1, then P2
If multiple matches: Use highest severity
If no matches: Default to P1 (moderate)
```

**2. Fix Detection:**
```bash
# Check git commits for fix patterns
git log --all --grep="fix.*BUG-XXX" --grep="resolve.*BUG-XXX" --grep="BUG-XXX.*fix" -i --since="$bug_reported_date"

If commits found: Bug likely already fixed
```

**3. Duplicate Detection:**
```
Compare bug title against existing bugs using fuzzy matching
Similarity threshold: 80%
If match found: Mark as potential duplicate
```

**Auto-Decisions:**

```
For each bug with status="reported":

  If fix detected in git commits:
    → status="resolved"
    → Add resolved_at timestamp
    → Add note: "Auto-detected as fixed from git commits"

  Else if severity=P0:
    → status="triaged"
    → Offer immediate fix (ask user)
    → Add note: "Auto-triaged as P0 (critical)"

  Else if severity=P1:
    → status="triaged"
    → Add note: "Auto-triaged as P1 (high priority)"

  Else if severity=P2:
    → status="triaged"
    → Add note: "Auto-triaged as P2 (low priority)"

  If duplicate detected:
    → Display warning
    → Ask: "Possible duplicate of BUG-XXX. Reject? (yes/no)"
    → Only reject if user confirms

Conservative fallback: When severity unclear, default to P1
```

**Output:**
```
✅ Auto-Triage Complete

Bugs Processed: 12

Auto-Detected:
  - 2 bugs resolved (found fix commits)
  - 3 bugs triaged as P0 (critical keywords)
  - 5 bugs triaged as P1 (error keywords)
  - 2 bugs triaged as P2 (minor keywords)

Files Updated:
  - bugs.yaml (12 bugs updated)
  - docs/bugs/index.yaml

Changes committed to git.

Note: Run "triage bugs" (interactive) for manual review and overrides.
```

**Time:** ~5-10 seconds per bug (vs 1-2 min interactive)

---

#### triaging-features Autonomous Mode

**Invocation:** "auto-triage features"

**Auto-Detection Logic:**

**1. Scope Detection:**
```
Read existing approved features
Extract categories and themes
Compare new feature against existing:
  - Same category as approved features → In scope
  - Category never used before → Potentially out of scope
```

**2. Priority Validation:**
```
Check if priority aligns with category:
  - new-functionality + must-have → Common, likely valid
  - performance + future → Unusual, might need review
  - ux-improvement + nice-to-have → Common pattern
```

**3. Duplicate Detection:**
```
Use enhanced fuzzy matching from reporting-features
Threshold: 85% similarity
Check title and description
```

**Auto-Decisions:**

```
For each feature with status="proposed":

  If clear duplicate (>90% similarity):
    → status="rejected"
    → rejection_reason="Duplicate of FEAT-XXX"
    → Add duplicate_of field

  Else if priority=must-have AND category in existing approved:
    → status="approved"
    → Add note: "Auto-approved (must-have, in-scope)"

  Else if priority=nice-to-have AND category in existing approved:
    → status="approved"
    → Add note: "Auto-approved (nice-to-have, in-scope)"

  Else if priority=future:
    → Keep status="proposed"
    → Add note: "Kept as proposed (future priority, defer decision)"

  Else if category NOT in existing approved:
    → Keep status="proposed"
    → Add note: "Kept as proposed (new category, needs review)"

Conservative fallback: When unsure, keep as proposed
```

**Output:**
```
✅ Auto-Triage Complete

Features Processed: 8

Auto-Detected:
  - 4 features approved (must-have, in-scope)
  - 2 features approved (nice-to-have, in-scope)
  - 1 feature kept as proposed (future priority)
  - 1 feature rejected (duplicate of FEAT-015)

Files Updated:
  - features.yaml (8 features updated)
  - docs/features/index.yaml

Changes committed to git.

Note: Run "triage features" (interactive) for manual review.
```

**Time:** ~5-10 seconds per feature (vs 1-2 min interactive)

---

### Wave 2: Scheduling Skills

#### scheduling-work-items Autonomous Mode

**Invocation:** "auto-schedule work items"

**Auto-Detection Logic:**

**1. Velocity Calculation:**
```bash
# Source from autonomous-helpers.sh
velocity=$(calculate_sprint_velocity)

# Reads completed sprints from ROADMAP.md:
completed_sprints=$(grep "completed -" ROADMAP.md | wc -l)
total_items_completed=$(sum of items from completed sprint stats)
avg_velocity=$((total_items_completed / completed_sprints))

# Fallback if no completed sprints: default to 5 items
```

**2. Available Work Items:**
```
Count triaged bugs (status="triaged")
Count approved features (status="approved")
Total available = bugs + features
```

**3. Sprint Theme Generation:**
```bash
# Source from autonomous-helpers.sh
theme=$(extract_sprint_themes $selected_item_ids)

# Analyzes item titles for common keywords
# Example: "Timeline", "Document", "Upload" → "Timeline and Document Management"
```

**Auto-Decisions:**

```
If available_items < 3:
  → Exit with message: "Not enough items for sprint (need ≥3, have ${available_items})"

If available_items ≥ 3:
  → Create new sprint

Sprint capacity = min(velocity, available_items, 10)  # Cap at 10 items

Select items (up to capacity):
  1. All P0 bugs (critical)
  2. All P1 bugs (high priority)
  3. Must-Have features (priority order)
  4. Nice-to-Have features if space remains
  5. P2 bugs if space remains

Sprint name = "Sprint ${nextId}: ${theme}"
Sprint duration = 2 weeks (default)
Sprint goal = "Address ${p0_count} critical bugs and ${must_have_count} must-have features"

Don't create implementation plans (too time-consuming)
Don't execute features (too presumptuous)

Conservative fallback: If velocity = 0 or unavailable, use capacity = 5 items
```

**Output:**
```
✅ Auto-Schedule Complete

Sprint Created: SPRINT-007 - Bug Fixes and Core Features
Capacity: 7 items (based on velocity: 7.2 items/sprint)
Duration: 2 weeks

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

Next: Start working on SPRINT-007 items
Note: Run "schedule work items" (interactive) for custom sprint planning
```

**Time:** ~2-3 min (vs 5-10 min interactive)

---

#### scheduling-features Autonomous Mode

**Invocation:** "auto-schedule features"

**Similar to scheduling-work-items but features-only:**

**Auto-Detection:**
- Velocity from feature-only completed sprints (if available)
- Epic groupings (schedule features from same epic together)
- Available approved features

**Auto-Decisions:**
```
If available_features < 3:
  → Exit with message

If features have epic assignments:
  → Group by epic, create sprint per epic
Else:
  → Create single sprint with highest priority features

Capacity = min(feature_velocity, available_features, 8)

Select: Must-Have first, then Nice-to-Have

Don't create plans or execute automatically
```

**Time:** ~2-3 min (vs 5-10 min interactive)

---

### Wave 3: Polish Skills

#### scheduling-implementation-plan Autonomous Mode

**Invocation:** "auto-schedule plan [filename]" or just "auto-schedule plan"

**Auto-Detection:**

**1. Plan Discovery:**
```bash
# If no filename provided, find recent plans
find docs/plans/ -name "*-plan.md" -o -name "*-implementation-plan.md" | head -5

# Select most recent unscheduled plan
```

**2. Task Counting:**
```bash
# Count tasks in plan
task_count=$(grep -c "^## Task\|^### Task\|- \[ \]" $plan_file)
```

**3. Sprint Sizing Heuristics:**
```
≤8 tasks → Single sprint (1-2 weeks)
9-16 tasks → Two sprints (2-4 weeks)
17-24 tasks → Three sprints (3-6 weeks)
>24 tasks → Four sprints or more
```

**Auto-Decisions:**
```
Parse plan for tasks
Count tasks
Determine sprint count based on task_count

If single sprint:
  → Create SPRINT-XXX with all tasks
  → Sprint name from plan title

If multiple sprints:
  → Split at natural boundaries (look for "## Phase" or similar)
  → Create SPRINT-XXX, SPRINT-YYY, etc.
  → Update ROADMAP.md with all sprints

If FEAT-XXX in plan filename:
  → Update features.yaml with sprint_id

Link plan to sprints (add metadata to plan)

Conservative fallback: When boundaries unclear, default to single sprint
```

**Time:** ~1-2 min (vs 2-7 min interactive)

---

#### fixing-bugs Autonomous Enhancements

**Invocation:** "auto-fix bug" (without specifying bug ID)

**Current state:** Already autonomous in debugging approach, just needs bug selection

**Auto-Detection:**

**1. Bug Selection:**
```
Read bugs.yaml for unresolved bugs (status != "resolved")

Priority order:
  1. P0 bugs in current sprint (sprint_id matches active sprint)
  2. P0 bugs triaged/scheduled
  3. P1 bugs in current sprint
  4. P1 bugs triaged/scheduled
  5. P2 bugs

Prefer bugs with E2E tests (easier to verify fix)
```

**Auto-Decisions:**
```
If single highest-priority bug:
  → Select that bug
  → Follow existing systematic-debugging workflow

If multiple P0 bugs:
  → Ask user which to fix (too critical to guess)

If no P0/P1 bugs:
  → Auto-select first P2 bug
  → Follow systematic-debugging workflow

After fix complete:
  → Auto-update bugs.yaml (status="resolved")
  → Run E2E test if exists

Conservative fallback: If ambiguous, ask user
```

**Output:**
```
✅ Auto-Fix Complete

Bug Selected: BUG-023 - Timeline crashes on scroll (P0)
Reason: Highest priority unresolved bug in current sprint

Fix Applied:
  - Root cause: Null pointer in ScrollView handler
  - Solution: Add null check before accessing data
  - Tests: All passing (47/47)
  - E2E test: BUG-023 now passing

Files Updated:
  - bugs.yaml (BUG-023: in-progress → resolved)
  - src/components/Timeline.tsx (fix applied)
  - tests/Timeline.test.tsx (test updated)

Changes committed to git.
```

**Time:** Same as interactive (autonomous only affects selection, ~30-60 min for fix)

---

## Shared Utilities Design

### File: `scripts/autonomous-helpers.sh`

**Purpose:** Reusable detection and decision functions for all skills

**Functions:**

#### 1. Severity Detection
```bash
detect_bug_severity() {
  local bug_title="$1"
  local bug_description="$2"

  # Convert to lowercase for matching
  local text=$(echo "$bug_title $bug_description" | tr '[:upper:]' '[:lower:]')

  # P0 patterns (critical)
  if echo "$text" | grep -qE "crash|data loss|corruption|unusable|breaks app|critical"; then
    echo "P0"
    return 0
  fi

  # P1 patterns (high)
  if echo "$text" | grep -qE "broken|fails|error|doesn't work|not working|blocks|regression"; then
    echo "P1"
    return 0
  fi

  # P2 patterns (low)
  if echo "$text" | grep -qE "alignment|styling|minor|cosmetic|polish|typo|ui.*issue|layout"; then
    echo "P2"
    return 0
  fi

  # Default fallback
  echo "P1"
}
```

#### 2. Velocity Calculation
```bash
calculate_sprint_velocity() {
  local roadmap_file="${1:-ROADMAP.md}"

  if [ ! -f "$roadmap_file" ]; then
    echo "0"
    return 1
  fi

  # Extract completed sprint stats from ROADMAP.md
  # Format: "Completion: 43% (3/7 items)"
  local total_items=0
  local completed_items=0
  local sprint_count=0

  while IFS= read -r line; do
    if echo "$line" | grep -q "completed -"; then
      ((sprint_count++))

      # Extract item counts
      if echo "$line" | grep -qE '\([0-9]+/[0-9]+ items\)'; then
        completed=$(echo "$line" | grep -oE '[0-9]+/[0-9]+ items' | cut -d'/' -f1)
        total=$(echo "$line" | grep -oE '[0-9]+/[0-9]+ items' | cut -d'/' -f2 | cut -d' ' -f1)

        completed_items=$((completed_items + completed))
        total_items=$((total_items + total))
      fi
    fi
  done < "$roadmap_file"

  if [ $sprint_count -eq 0 ]; then
    echo "0"
    return 1
  fi

  # Calculate average velocity
  local avg_velocity=$((completed_items / sprint_count))
  echo "$avg_velocity"
}
```

#### 3. Git Commit Scanning
```bash
check_item_in_commits() {
  local item_id="$1"     # BUG-XXX or FEAT-XXX
  local pattern="$2"     # "fix", "implement", "complete"
  local since_date="$3"  # Optional: only check commits after this date

  local grep_pattern="${pattern}.*${item_id}|${item_id}.*${pattern}"

  if [ -n "$since_date" ]; then
    git log --all --grep="$grep_pattern" -i --since="$since_date" --oneline | head -1
  else
    git log --all --grep="$grep_pattern" -i --oneline | head -1
  fi

  # Returns: commit SHA if found, empty if not
}
```

#### 4. Fuzzy Duplicate Detection
```bash
find_similar_items() {
  local item_type="$1"  # "bug" or "feature"
  local title="$2"
  local threshold="${3:-80}"  # Default 80% similarity

  # Requires fzf or similar fuzzy matching tool
  # For now, use simple substring matching
  # Production would use Levenshtein distance

  local yaml_file
  if [ "$item_type" = "bug" ]; then
    yaml_file="bugs.yaml"
  else
    yaml_file="features.yaml"
  fi

  # Extract all titles from yaml
  # Compare using basic similarity (count matching words)
  # Return IDs of items above threshold

  # Placeholder for actual implementation
  echo ""
}
```

#### 5. YAML Helpers
```bash
get_item_status() {
  local item_id="$1"
  local item_type="${item_id%%-*}"  # FEAT or BUG

  if [ "$item_type" = "FEAT" ]; then
    yq eval ".features[] | select(.id == \"$item_id\") | .status" features.yaml
  else
    yq eval ".bugs[] | select(.id == \"$item_id\") | .status" bugs.yaml
  fi
}

update_item_status() {
  local item_id="$1"
  local new_status="$2"
  local item_type="${item_id%%-*}"

  if [ "$item_type" = "FEAT" ]; then
    yq eval "(.features[] | select(.id == \"$item_id\") | .status) = \"$new_status\"" -i features.yaml
    yq eval "(.features[] | select(.id == \"$item_id\") | .updated_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i features.yaml
  else
    yq eval "(.bugs[] | select(.id == \"$item_id\") | .status) = \"$new_status\"" -i bugs.yaml
    yq eval "(.bugs[] | select(.id == \"$item_id\") | .updated_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i bugs.yaml
  fi
}
```

#### 6. Sprint Theme Extraction
```bash
extract_sprint_themes() {
  local item_ids="$@"

  # Collect all titles
  local titles=""
  for item_id in $item_ids; do
    local title=$(yq eval ".features[] | select(.id == \"$item_id\") | .title" features.yaml 2>/dev/null)
    if [ -z "$title" ]; then
      title=$(yq eval ".bugs[] | select(.id == \"$item_id\") | .title" bugs.yaml 2>/dev/null)
    fi
    titles="$titles $title"
  done

  # Extract common keywords (simple approach)
  # Production would use NLP or frequency analysis
  # For now, take most common nouns from titles

  echo "Bug Fixes and Features"  # Placeholder
}
```

**Script Size:** ~300-400 lines total

**Usage in Skills:**
```bash
#!/usr/bin/env bash
# In any autonomous mode section

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/autonomous-helpers.sh"

# Use shared functions
severity=$(detect_bug_severity "$title" "$description")
velocity=$(calculate_sprint_velocity)
similar=$(find_similar_items "bug" "$title" 85)
```

**Benefits:**
- Single source of truth for detection algorithms
- Easy to improve algorithms (update one file)
- Testable independently
- Consistent behavior across all skills

---

### Wave 2 (Continued): scheduling-work-items & scheduling-features

Both use same helpers:
- `calculate_sprint_velocity` for capacity planning
- `extract_sprint_themes` for naming
- `get_item_status` and `update_item_status` for YAML operations

**scheduling-features specifics:**
- Filter for features-only velocity (exclude bugs from calculation)
- Check for epic groupings
- Otherwise same logic as scheduling-work-items

---

### Wave 3: scheduling-implementation-plan & fixing-bugs

**scheduling-implementation-plan:**
Uses task counting and sprint sizing logic (could be in helpers):

```bash
get_task_count_from_plan() {
  local plan_file="$1"
  grep -c "^## Task\|^### Task\|- \[ \]" "$plan_file"
}

suggest_sprint_breakdown() {
  local task_count="$1"

  if [ $task_count -le 8 ]; then
    echo "1"  # Single sprint
  elif [ $task_count -le 16 ]; then
    echo "2"  # Two sprints
  elif [ $task_count -le 24 ]; then
    echo "3"  # Three sprints
  else
    echo "4"  # Four or more
  fi
}
```

**fixing-bugs:**
Uses severity detection and status checking:

```bash
select_highest_priority_bug() {
  # Check for P0 bugs in current sprint
  # Then P0 bugs triaged
  # Then P1 bugs in sprint
  # Then P1 bugs triaged
  # Then P2 bugs

  # Returns: BUG-XXX ID
}
```

---

## Master Implementation Plan Structure

### Plan File: `docs/plans/2025-11-21-autonomous-modes-implementation-plan.md`

**Structure:**

```markdown
# Autonomous Modes Implementation Plan

> **For Claude:** Use dispatching-parallel-agents to execute in 3 waves

## Shared Infrastructure (Complete First)

### Task 0: Create Shared Utilities Script
- Create scripts/autonomous-helpers.sh
- Implement 6 shared functions
- Test each function independently
- Commit

[Detailed tasks]

---

## Wave 1: Triage Skills (2 Parallel Agents)

### Section A: triaging-bugs Autonomous Mode
**Agent 1 implements this section independently**

**Current State:** Interactive only, prompts for each bug
**Goal:** Add auto-detection and aggressive auto-triage

**Tasks:**
1. Add autonomous mode section to SKILL.md
2. Implement severity auto-detection using autonomous-helpers.sh
3. Implement fix detection from git commits
4. Add auto-decision logic
5. Update documentation
6. Create test cases
7. Commit

[Detailed implementation steps]

---

### Section B: triaging-features Autonomous Mode
**Agent 2 implements this section independently**

[Similar structure]

---

## Wave 2: Scheduling Skills (2 Parallel Agents)

### Section C: scheduling-work-items Autonomous Mode
**Agent 3 implements this section independently**

[Detailed tasks]

### Section D: scheduling-features Autonomous Mode
**Agent 4 implements this section independently**

[Detailed tasks]

---

## Wave 3: Polish Skills (2 Parallel Agents)

### Section E: scheduling-implementation-plan Autonomous Mode
**Agent 5 implements this section independently**

[Detailed tasks]

### Section F: fixing-bugs Autonomous Enhancements
**Agent 6 implements this section independently**

[Detailed tasks]

---

## Final Integration (After All Waves)

### Task: Update Documentation
- Update CHANGELOG.md (v2.2.0 entry)
- Update README.md "What's New"
- Update EXTENSIONS.md
- Update each skill's parent README

[Detailed tasks]

### Task: Integration Testing
- Test end-to-end autonomous workflow
- Validate cross-skill data flow
- Run validate-sprint-data.sh

[Detailed tasks]
```

**Total tasks estimate:**
- Shared utilities: ~8 tasks
- Per skill: ~6-8 tasks each (×6 = 36-48 tasks)
- Documentation: ~4-5 tasks
- Integration: ~3-4 tasks
- **Total: ~50-65 tasks**

**With parallel execution:**
- Task 0: Sequential (~15-20 min)
- Wave 1: Parallel (~30-45 min)
- Wave 2: Parallel (~45-60 min)
- Wave 3: Parallel (~30-45 min)
- Final: Sequential (~30-45 min)
- **Total: ~3-4 hours**

Does this master plan structure provide enough detail for autonomous agent execution?