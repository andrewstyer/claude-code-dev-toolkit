# Autonomous Modes Implementation Plan

> **For Claude:** Use dispatching-parallel-agents to execute in 3 waves with review checkpoints between waves.

**Created:** 2025-11-21
**Goal:** Add autonomous operation modes to all 6 skills following the completing-sprints pattern
**Architecture:** Dual-mode operation (interactive + autonomous) with auto-detection from project state
**Execution Strategy:** 3 waves of parallel agents + shared infrastructure + final integration

---

## Overview

This plan adds autonomous modes to 6 skills in the dev-toolkit:
- Wave 1: triaging-bugs, triaging-features (aggressive auto-detection)
- Wave 2: scheduling-work-items, scheduling-features (moderate auto-detection)
- Wave 3: scheduling-implementation-plan, fixing-bugs (conservative auto-detection)

**Total estimated time:** 3-4 hours with parallel execution
**Total tasks:** ~60-65 tasks across all sections

---

## Task 0: Shared Infrastructure (Complete First)

**Purpose:** Create reusable autonomous helper functions for all skills
**File:** `scripts/autonomous-helpers.sh`
**Dependencies:** None - must complete before any wave
**Estimated time:** 15-20 minutes

### Task 0.1: Create Script File with Header

**Step 1: Create script with header and dependency checks**

```bash
cat > scripts/autonomous-helpers.sh << 'EOF'
#!/usr/bin/env bash

# Autonomous Helpers - Shared Utilities for Autonomous Skill Modes
# Provides reusable detection and decision functions

set -euo pipefail

# Check for required tools
if ! command -v yq &> /dev/null; then
  echo "Error: yq not found. Install with: brew install yq" >&2
  exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

EOF
```

**Step 2: Make script executable**

```bash
chmod +x scripts/autonomous-helpers.sh
```

**Step 3: Test script**

```bash
bash -n scripts/autonomous-helpers.sh
```

**Expected:** No syntax errors

**Step 4: Commit**

```bash
git add scripts/autonomous-helpers.sh
git commit -m "feat(autonomous): create shared autonomous-helpers.sh script"
```

---

### Task 0.2: Add Bug Severity Detection Function

**Step 1: Append severity detection function**

```bash
cat >> scripts/autonomous-helpers.sh << 'EOF'

# Detect bug severity from title and description
# Usage: detect_bug_severity "title" "description"
# Returns: P0, P1, or P2
detect_bug_severity() {
  local bug_title="$1"
  local bug_description="${2:-}"

  # Convert to lowercase for matching
  local text=$(echo "$bug_title $bug_description" | tr '[:upper:]' '[:lower:]')

  # P0 patterns (critical)
  if echo "$text" | grep -qE "crash|data loss|corruption|unusable|breaks app|critical|cannot start|fatal"; then
    echo "P0"
    return 0
  fi

  # P1 patterns (high)
  if echo "$text" | grep -qE "broken|fails|error|doesn't work|not working|blocks|regression|broken feature"; then
    echo "P1"
    return 0
  fi

  # P2 patterns (low)
  if echo "$text" | grep -qE "alignment|styling|minor|cosmetic|polish|typo|ui.*issue|layout|spacing"; then
    echo "P2"
    return 0
  fi

  # Default fallback
  echo "P1"
}

EOF
```

**Step 2: Test function**

```bash
bash -n scripts/autonomous-helpers.sh
```

**Step 3: Commit**

```bash
git add scripts/autonomous-helpers.sh
git commit -m "feat(autonomous): add detect_bug_severity function"
```

---

### Task 0.3: Add Velocity Calculation Function

**Step 1: Append velocity calculation function**

```bash
cat >> scripts/autonomous-helpers.sh << 'EOF'

# Calculate sprint velocity from completed sprints
# Usage: calculate_sprint_velocity [roadmap_file]
# Returns: Average items per sprint, or 0 if no data
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

EOF
```

**Step 2: Test function**

```bash
bash -n scripts/autonomous-helpers.sh
```

**Step 3: Commit**

```bash
git add scripts/autonomous-helpers.sh
git commit -m "feat(autonomous): add calculate_sprint_velocity function"
```

---

### Task 0.4: Add Git Commit Scanning Function

**Step 1: Append git commit scanning function**

```bash
cat >> scripts/autonomous-helpers.sh << 'EOF'

# Check if work item appears in git commits with specific pattern
# Usage: check_item_in_commits "BUG-123" "fix" ["2025-11-01"]
# Returns: commit SHA if found, empty if not
check_item_in_commits() {
  local item_id="$1"     # BUG-XXX or FEAT-XXX
  local pattern="$2"     # "fix", "implement", "complete"
  local since_date="${3:-}"  # Optional: only check commits after this date

  local grep_pattern="${pattern}.*${item_id}|${item_id}.*${pattern}"

  if [ -n "$since_date" ]; then
    git log --all --grep="$grep_pattern" -i --since="$since_date" --oneline 2>/dev/null | head -1
  else
    git log --all --grep="$grep_pattern" -i --oneline 2>/dev/null | head -1
  fi

  # Returns: commit SHA if found, empty if not
}

EOF
```

**Step 2: Test function**

```bash
bash -n scripts/autonomous-helpers.sh
```

**Step 3: Commit**

```bash
git add scripts/autonomous-helpers.sh
git commit -m "feat(autonomous): add check_item_in_commits function"
```

---

### Task 0.5: Add YAML Helper Functions

**Step 1: Append YAML helper functions**

```bash
cat >> scripts/autonomous-helpers.sh << 'EOF'

# Get item status from YAML
# Usage: get_item_status "BUG-123"
# Returns: status string (e.g., "triaged", "scheduled", "resolved")
get_item_status() {
  local item_id="$1"
  local item_type="${item_id%%-*}"  # FEAT or BUG

  if [ "$item_type" = "FEAT" ]; then
    yq eval ".features[] | select(.id == \"$item_id\") | .status" features.yaml 2>/dev/null || echo ""
  else
    yq eval ".bugs[] | select(.id == \"$item_id\") | .status" bugs.yaml 2>/dev/null || echo ""
  fi
}

# Update item status in YAML
# Usage: update_item_status "BUG-123" "resolved"
update_item_status() {
  local item_id="$1"
  local new_status="$2"
  local item_type="${item_id%%-*}"

  local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  if [ "$item_type" = "FEAT" ]; then
    yq eval "(.features[] | select(.id == \"$item_id\") | .status) = \"$new_status\"" -i features.yaml
    yq eval "(.features[] | select(.id == \"$item_id\") | .updated_at) = \"$timestamp\"" -i features.yaml
  else
    yq eval "(.bugs[] | select(.id == \"$item_id\") | .status) = \"$new_status\"" -i bugs.yaml
    yq eval "(.bugs[] | select(.id == \"$item_id\") | .updated_at) = \"$timestamp\"" -i bugs.yaml
  fi
}

# Get item title from YAML
# Usage: get_item_title "FEAT-001"
# Returns: item title string
get_item_title() {
  local item_id="$1"
  local item_type="${item_id%%-*}"

  if [ "$item_type" = "FEAT" ]; then
    yq eval ".features[] | select(.id == \"$item_id\") | .title" features.yaml 2>/dev/null || echo ""
  else
    yq eval ".bugs[] | select(.id == \"$item_id\") | .title" bugs.yaml 2>/dev/null || echo ""
  fi
}

EOF
```

**Step 2: Test functions**

```bash
bash -n scripts/autonomous-helpers.sh
```

**Step 3: Commit**

```bash
git add scripts/autonomous-helpers.sh
git commit -m "feat(autonomous): add YAML helper functions"
```

---

### Task 0.6: Add Sprint Theme Extraction Function

**Step 1: Append theme extraction function**

```bash
cat >> scripts/autonomous-helpers.sh << 'EOF'

# Extract common themes from work item titles
# Usage: extract_sprint_themes "FEAT-001 FEAT-002 BUG-003"
# Returns: theme string (e.g., "Timeline and Document Management")
extract_sprint_themes() {
  local item_ids="$@"

  # Collect all titles
  local titles=""
  for item_id in $item_ids; do
    local title=$(get_item_title "$item_id")
    if [ -n "$title" ]; then
      titles="$titles $title"
    fi
  done

  if [ -z "$titles" ]; then
    echo "Bug Fixes and Features"
    return
  fi

  # Extract keywords (simplified - production would use NLP)
  # Look for common words (nouns) appearing multiple times

  # Count word frequency
  local keywords=$(echo "$titles" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' '\n' |
    grep -Ev '^(a|an|the|and|or|but|in|on|at|to|for|of|with|by|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|may|might|can|fix|add|update|improve|create|delete|remove)$' |
    sort | uniq -c | sort -rn | head -3 | awk '{print $2}')

  if [ -z "$keywords" ]; then
    echo "Bug Fixes and Features"
    return
  fi

  # Capitalize and combine keywords
  local theme=""
  for word in $keywords; do
    local cap_word=$(echo "$word" | sed 's/./\U&/')
    theme="$theme$cap_word and "
  done

  # Remove trailing " and " and add default suffix
  theme=$(echo "$theme" | sed 's/ and $//')

  if [ -n "$theme" ]; then
    echo "$theme"
  else
    echo "Bug Fixes and Features"
  fi
}

EOF
```

**Step 2: Test function**

```bash
bash -n scripts/autonomous-helpers.sh
```

**Step 3: Commit**

```bash
git add scripts/autonomous-helpers.sh
git commit -m "feat(autonomous): add extract_sprint_themes function"
```

---

## Wave 1: Triage Skills (2 Parallel Agents)

**Review Checkpoint:** Validate both implementations before starting Wave 2

---

### Section A: triaging-bugs Autonomous Mode

**Agent 1 implements this section independently**

**Current State:** Interactive only, prompts for each bug decision
**Goal:** Add aggressive auto-detection and auto-triage with minimal user intervention
**Invocation:** "auto-triage bugs"
**Estimated time:** 30-45 minutes

---

#### Task A.1: Add Autonomous Mode Detection to SKILL.md

**Files:** `.claude/skills/triaging-bugs/SKILL.md`

**Step 1: Read current SKILL.md**

```bash
cat .claude/skills/triaging-bugs/SKILL.md | head -50
```

**Step 2: Add autonomous mode section after invocation**

Add after the "Invocation" section:

```markdown

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
```

**Step 3: Verify addition**

```bash
grep -A 5 "Autonomous Mode" .claude/skills/triaging-bugs/SKILL.md
```

**Expected:** See autonomous mode section

**Step 4: Commit**

```bash
git add .claude/skills/triaging-bugs/SKILL.md
git commit -m "feat(triaging-bugs): add autonomous mode overview"
```

---

#### Task A.2: Document Auto-Detection Logic for Severity

**Step 1: Add auto-detection section**

Add new section in SKILL.md:

```markdown

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
```

**Step 2: Verify addition**

```bash
grep "Severity Detection" .claude/skills/triaging-bugs/SKILL.md
```

**Step 3: Commit**

```bash
git add .claude/skills/triaging-bugs/SKILL.md
git commit -m "feat(triaging-bugs): document auto-detection logic for severity and fixes"
```

---

#### Task A.3: Document Auto-Decision Rules

**Step 1: Add decision rules section**

```markdown

## Autonomous Mode - Auto-Decision Rules

**For each bug with status="reported":**

```
IF fix detected in git commits:
  → status="resolved"
  → Add resolved_at timestamp
  → Add note: "Auto-detected as fixed from git commits"

ELSE IF severity=P0:
  → status="triaged"
  → Add note: "Auto-triaged as P0 (critical)"
  → Optionally offer immediate fix (ask user)

ELSE IF severity=P1:
  → status="triaged"
  → Add note: "Auto-triaged as P1 (high priority)"

ELSE IF severity=P2:
  → status="triaged"
  → Add note: "Auto-triaged as P2 (low priority)"

IF duplicate detected (>90% similarity):
  → Display warning: "Possible duplicate of BUG-XXX"
  → Keep as reported (don't auto-reject)
  → Add duplicate_candidate field

CONSERVATIVE FALLBACK:
  When severity unclear → default to P1
  When duplicate uncertain → keep bug, add warning
  When fix detection unclear → leave as reported
```

**Aggressiveness Level:** Aggressive
- Auto-triages all bugs with clear severity indicators
- Marks bugs as resolved if fix commits found
- Warns about duplicates but doesn't auto-reject
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-bugs/SKILL.md
git commit -m "feat(triaging-bugs): add auto-decision rules with conservative fallbacks"
```

---

#### Task A.4: Document Autonomous Mode Output Format

**Step 1: Add output format section**

```markdown

## Autonomous Mode - Output Format

```
✅ Auto-Triage Complete

Bugs Processed: 12

Auto-Detected:
  - 2 bugs resolved (found fix commits)
  - 3 bugs triaged as P0 (critical keywords)
  - 5 bugs triaged as P1 (error keywords)
  - 2 bugs triaged as P2 (minor keywords)

Warnings:
  - BUG-025: Possible duplicate of BUG-018 (85% similar)

Files Updated:
  - bugs.yaml (12 bugs updated)
  - docs/bugs/index.yaml

Changes committed to git.

Note: Run "triage bugs" (interactive) for manual review and overrides.
```

**Time Comparison:**
- Interactive: ~1-2 minutes per bug (12 bugs = 12-24 minutes)
- Autonomous: ~5-10 seconds per bug (12 bugs = 1-2 minutes)
- **Speedup:** 10-20x faster
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-bugs/SKILL.md
git commit -m "feat(triaging-bugs): document autonomous mode output format"
```

---

#### Task A.5: Add Autonomous Mode Implementation Steps

**Step 1: Add implementation workflow**

```markdown

## Implementation Workflow - Autonomous Mode

**Step 1: Load bugs from bugs.yaml**

```bash
# Filter for reported bugs only
reported_bugs=$(yq eval '.bugs[] | select(.status == "reported") | .id' bugs.yaml)
bug_count=$(echo "$reported_bugs" | wc -l | tr -d ' ')

echo "Found $bug_count reported bugs to triage"
```

**Step 2: Process each bug**

```bash
for bug_id in $reported_bugs; do
  # Extract bug data
  bug_title=$(yq eval ".bugs[] | select(.id == \"$bug_id\") | .title" bugs.yaml)
  bug_description=$(yq eval ".bugs[] | select(.id == \"$bug_id\") | .description" bugs.yaml)
  bug_reported_date=$(yq eval ".bugs[] | select(.id == \"$bug_id\") | .reported_date" bugs.yaml)

  # Auto-detect severity
  severity=$(detect_bug_severity "$bug_title" "$bug_description")

  # Check for fix commits
  fix_commit=$(check_item_in_commits "$bug_id" "fix" "$bug_reported_date")

  # Apply decision rules
  if [ -n "$fix_commit" ]; then
    # Bug already fixed
    update_item_status "$bug_id" "resolved"
    yq eval "(.bugs[] | select(.id == \"$bug_id\") | .resolved_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i bugs.yaml
    yq eval "(.bugs[] | select(.id == \"$bug_id\") | .notes) = \"Auto-detected as fixed from commit $fix_commit\"" -i bugs.yaml
    echo "  ✓ $bug_id: resolved (fix found)"
  else
    # Auto-triage based on severity
    update_item_status "$bug_id" "triaged"
    yq eval "(.bugs[] | select(.id == \"$bug_id\") | .severity) = \"$severity\"" -i bugs.yaml
    yq eval "(.bugs[] | select(.id == \"$bug_id\") | .notes) = \"Auto-triaged as $severity\"" -i bugs.yaml
    echo "  ✓ $bug_id: triaged as $severity"
  fi
done
```

**Step 3: Update index file**

```bash
# Sync bugs.yaml changes to docs/bugs/index.yaml
cp bugs.yaml docs/bugs/index.yaml
```

**Step 4: Create git commit**

```bash
git add bugs.yaml docs/bugs/index.yaml

git commit -m "$(cat <<'EOF'
feat: auto-triage $bug_count bugs

Auto-Detection Results:
- $resolved_count bugs resolved (fix commits found)
- $p0_count bugs triaged as P0
- $p1_count bugs triaged as P1
- $p2_count bugs triaged as P2

Files updated:
- bugs.yaml ($bug_count bugs updated)
- docs/bugs/index.yaml

🤖 Generated with Claude Code (autonomous mode)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Step 5: Display summary**

Display output format from previous section.
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-bugs/SKILL.md
git commit -m "feat(triaging-bugs): add autonomous mode implementation workflow"
```

---

#### Task A.6: Test Autonomous Mode Documentation

**Step 1: Verify all sections present**

```bash
grep -c "Autonomous Mode" .claude/skills/triaging-bugs/SKILL.md
```

**Expected:** At least 5 matches (different sections)

**Step 2: Check for shared helpers reference**

```bash
grep "autonomous-helpers.sh" .claude/skills/triaging-bugs/SKILL.md
```

**Expected:** See reference to shared script

**Step 3: Validate markdown syntax**

```bash
# No built-in markdown validator, just check file exists and is readable
cat .claude/skills/triaging-bugs/SKILL.md > /dev/null && echo "✓ File is readable"
```

**Step 4: Commit test validation**

```bash
git add .
git commit -m "test(triaging-bugs): validate autonomous mode documentation complete"
```

---

### Section B: triaging-features Autonomous Mode

**Agent 2 implements this section independently**

**Current State:** Interactive only with duplicate detection
**Goal:** Add aggressive auto-detection and auto-approval/rejection
**Invocation:** "auto-triage features"
**Estimated time:** 30-45 minutes

---

#### Task B.1: Add Autonomous Mode Detection to SKILL.md

**Files:** `.claude/skills/triaging-features/SKILL.md`

**Step 1: Read current SKILL.md**

```bash
cat .claude/skills/triaging-features/SKILL.md | head -50
```

**Step 2: Add autonomous mode section**

Add after the "Invocation" section:

```markdown

## Dual-Mode Operation

**Interactive Mode (Default):**
- User says "triage features"
- Prompts for each decision with AskUserQuestion
- Full human control over approval/rejection
- Estimated time: 1-2 minutes per feature

**Autonomous Mode:**
- User says "auto-triage features"
- Auto-detects in-scope vs out-of-scope from existing features
- Auto-approves clear must-have features in existing categories
- Auto-rejects clear duplicates (>90% similarity)
- Keeps proposed status for uncertain cases
- Estimated time: 5-10 seconds per feature

**Mode Selection:**
Mode is determined by invocation phrase:
- Contains "auto-": Use autonomous mode
- Otherwise: Use interactive mode
```

**Step 3: Commit**

```bash
git add .claude/skills/triaging-features/SKILL.md
git commit -m "feat(triaging-features): add autonomous mode overview"
```

---

#### Task B.2: Document Auto-Detection Logic for Features

**Step 1: Add auto-detection section**

```markdown

## Autonomous Mode - Auto-Detection Logic

### 1. Scope Detection

Check if feature category aligns with existing approved features:

```bash
# Extract categories from approved features
existing_categories=$(yq eval '.features[] | select(.status == "approved") | .category' features.yaml | sort -u)

# Check if feature category exists
feature_category=$(yq eval ".features[] | select(.id == \"$feature_id\") | .category" features.yaml)

in_scope=false
for cat in $existing_categories; do
  if [ "$feature_category" = "$cat" ]; then
    in_scope=true
    break
  fi
done
```

**Detection rules:**
- Category in existing approved features → In scope
- Category never used before → Potentially out of scope (needs review)
- Priority + category combination common → Likely valid

### 2. Priority Validation

Check if priority aligns with category patterns:

```bash
# Common valid patterns:
# - new-functionality + must-have → Common, likely valid
# - performance + future → Unusual, might need review
# - ux-improvement + nice-to-have → Common pattern
# - bug-fix + must-have → Should be a bug, not feature

# Count existing features with same category+priority combination
pattern_count=$(yq eval ".features[] | select(.category == \"$category\" and .priority == \"$priority\")" features.yaml | wc -l)

if [ $pattern_count -gt 0 ]; then
  pattern_valid=true
else
  pattern_valid=false
fi
```

### 3. Enhanced Duplicate Detection

Uses enhanced fuzzy matching from reporting-features:

```bash
# Compare title and description
# Threshold: 85% similarity for warning, 90% for auto-reject

feature_title=$(yq eval ".features[] | select(.id == \"$feature_id\") | .title" features.yaml)
feature_desc=$(yq eval ".features[] | select(.id == \"$feature_id\") | .description" features.yaml)

# Check against existing features (simplified implementation)
existing_features=$(yq eval '.features[] | select(.id != "'$feature_id'") | .title' features.yaml)

for existing_title in $existing_features; do
  # Calculate similarity (simplified - production would use Levenshtein)
  # If >90% similar, mark as duplicate
done
```
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-features/SKILL.md
git commit -m "feat(triaging-features): document auto-detection logic"
```

---

#### Task B.3: Document Auto-Decision Rules

**Step 1: Add decision rules section**

```markdown

## Autonomous Mode - Auto-Decision Rules

**For each feature with status="proposed":**

```
IF clear duplicate (>90% similarity):
  → status="rejected"
  → rejection_reason="Duplicate of FEAT-XXX"
  → Add duplicate_of field
  → Add note: "Auto-rejected (duplicate)"

ELSE IF priority=must-have AND category in existing approved:
  → status="approved"
  → Add note: "Auto-approved (must-have, in-scope)"

ELSE IF priority=nice-to-have AND category in existing approved:
  → status="approved"
  → Add note: "Auto-approved (nice-to-have, in-scope)"

ELSE IF priority=future:
  → Keep status="proposed"
  → Add note: "Kept as proposed (future priority, defer decision)"

ELSE IF category NOT in existing approved:
  → Keep status="proposed"
  → Add note: "Kept as proposed (new category, needs review)"

ELSE:
  → Keep status="proposed"
  → Add note: "Kept as proposed (uncertain, needs review)"

CONSERVATIVE FALLBACK:
  When unsure → Keep as proposed (don't approve or reject)
  Only auto-reject clear duplicates (>90%)
  Only auto-approve when priority+category clearly valid
```

**Aggressiveness Level:** Aggressive
- Auto-approves must-have and nice-to-have features in existing categories
- Auto-rejects clear duplicates (>90% similarity)
- Keeps uncertain cases as proposed for human review
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-features/SKILL.md
git commit -m "feat(triaging-features): add auto-decision rules"
```

---

#### Task B.4: Document Autonomous Mode Output Format

**Step 1: Add output format section**

```markdown

## Autonomous Mode - Output Format

```
✅ Auto-Triage Complete

Features Processed: 8

Auto-Detected:
  - 4 features approved (must-have, in-scope)
  - 2 features approved (nice-to-have, in-scope)
  - 1 feature kept as proposed (future priority)
  - 1 feature rejected (duplicate of FEAT-015)

Warnings:
  - FEAT-042: New category "analytics" - kept as proposed for review

Files Updated:
  - features.yaml (8 features updated)
  - docs/features/index.yaml

Changes committed to git.

Note: Run "triage features" (interactive) for manual review.
```

**Time Comparison:**
- Interactive: ~1-2 minutes per feature (8 features = 8-16 minutes)
- Autonomous: ~5-10 seconds per feature (8 features = 1-2 minutes)
- **Speedup:** 8-15x faster
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-features/SKILL.md
git commit -m "feat(triaging-features): document autonomous mode output"
```

---

#### Task B.5: Add Autonomous Mode Implementation Steps

**Step 1: Add implementation workflow**

```markdown

## Implementation Workflow - Autonomous Mode

**Step 1: Load features from features.yaml**

```bash
# Filter for proposed features only
proposed_features=$(yq eval '.features[] | select(.status == "proposed") | .id' features.yaml)
feature_count=$(echo "$proposed_features" | wc -l | tr -d ' ')

echo "Found $feature_count proposed features to triage"
```

**Step 2: Extract existing categories**

```bash
# Get categories from approved features
existing_categories=$(yq eval '.features[] | select(.status == "approved") | .category' features.yaml | sort -u)
```

**Step 3: Process each feature**

```bash
approved_count=0
rejected_count=0
kept_count=0

for feature_id in $proposed_features; do
  # Extract feature data
  title=$(yq eval ".features[] | select(.id == \"$feature_id\") | .title" features.yaml)
  category=$(yq eval ".features[] | select(.id == \"$feature_id\") | .category" features.yaml)
  priority=$(yq eval ".features[] | select(.id == \"$feature_id\") | .priority" features.yaml)

  # Check for duplicates (>90% similarity)
  duplicate=$(check_for_duplicate "$feature_id")

  if [ -n "$duplicate" ]; then
    # Auto-reject duplicate
    update_item_status "$feature_id" "rejected"
    yq eval "(.features[] | select(.id == \"$feature_id\") | .rejection_reason) = \"Duplicate of $duplicate\"" -i features.yaml
    yq eval "(.features[] | select(.id == \"$feature_id\") | .duplicate_of) = \"$duplicate\"" -i features.yaml
    echo "  ✗ $feature_id: rejected (duplicate of $duplicate)"
    ((rejected_count++))
    continue
  fi

  # Check if category in scope
  in_scope=false
  for cat in $existing_categories; do
    if [ "$category" = "$cat" ]; then
      in_scope=true
      break
    fi
  done

  # Apply decision rules
  if [ "$in_scope" = true ] && ([ "$priority" = "must-have" ] || [ "$priority" = "nice-to-have" ]); then
    # Auto-approve
    update_item_status "$feature_id" "approved"
    yq eval "(.features[] | select(.id == \"$feature_id\") | .notes) = \"Auto-approved ($priority, in-scope)\"" -i features.yaml
    echo "  ✓ $feature_id: approved ($priority, $category)"
    ((approved_count++))
  else
    # Keep as proposed
    yq eval "(.features[] | select(.id == \"$feature_id\") | .notes) = \"Kept as proposed (needs review)\"" -i features.yaml
    echo "  • $feature_id: kept as proposed (needs review)"
    ((kept_count++))
  fi
done
```

**Step 4: Update index and commit**

```bash
cp features.yaml docs/features/index.yaml

git add features.yaml docs/features/index.yaml

git commit -m "$(cat <<'EOF'
feat: auto-triage $feature_count features

Auto-Detection Results:
- $approved_count features approved
- $rejected_count features rejected (duplicates)
- $kept_count features kept as proposed

Files updated:
- features.yaml ($feature_count features processed)
- docs/features/index.yaml

🤖 Generated with Claude Code (autonomous mode)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Step 5: Display summary**

Display output format from previous section.
```

**Step 2: Commit**

```bash
git add .claude/skills/triaging-features/SKILL.md
git commit -m "feat(triaging-features): add autonomous mode implementation workflow"
```

---

#### Task B.6: Test Autonomous Mode Documentation

**Step 1: Verify all sections present**

```bash
grep -c "Autonomous Mode" .claude/skills/triaging-features/SKILL.md
```

**Expected:** At least 5 matches

**Step 2: Commit validation**

```bash
git add .
git commit -m "test(triaging-features): validate autonomous mode documentation complete"
```

---

## Wave 2: Scheduling Skills (2 Parallel Agents)

**Review Checkpoint:** Validate both implementations before starting Wave 3

---

### Section C: scheduling-work-items Autonomous Mode

**Agent 3 implements this section independently**

**Current State:** Interactive with manual sprint creation decisions
**Goal:** Add moderate auto-detection with velocity-based capacity planning
**Invocation:** "auto-schedule work items"
**Estimated time:** 45-60 minutes

---

#### Task C.1: Add Autonomous Mode Detection to SKILL.md

**Files:** `.claude/skills/scheduling-work-items/SKILL.md`

**Step 1: Add autonomous mode section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-work-items/SKILL.md
git commit -m "feat(scheduling-work-items): add autonomous mode overview"
```

---

#### Task C.2: Document Velocity Calculation Auto-Detection

**Step 1: Add velocity detection section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-work-items/SKILL.md
git commit -m "feat(scheduling-work-items): document velocity and theme auto-detection"
```

---

#### Task C.3: Document Item Selection Auto-Logic

**Step 1: Add selection rules section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-work-items/SKILL.md
git commit -m "feat(scheduling-work-items): add item selection auto-logic"
```

---

#### Task C.4: Document Sprint Creation Auto-Logic

**Step 1: Add sprint creation section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-work-items/SKILL.md
git commit -m "feat(scheduling-work-items): document sprint creation auto-logic"
```

---

#### Task C.5: Document YAML and ROADMAP Updates

**Step 1: Add file update section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-work-items/SKILL.md
git commit -m "feat(scheduling-work-items): document file update logic"
```

---

#### Task C.6: Document Output Format and Error Handling

**Step 1: Add output and error sections**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-work-items/SKILL.md
git commit -m "feat(scheduling-work-items): add output format and error handling"
```

---

### Section D: scheduling-features Autonomous Mode

**Agent 4 implements this section independently**

**Current State:** Interactive with epic grouping support
**Goal:** Add moderate auto-detection with epic-aware scheduling
**Invocation:** "auto-schedule features"
**Estimated time:** 45-60 minutes

---

#### Task D.1: Add Autonomous Mode Detection to SKILL.md

**Files:** `.claude/skills/scheduling-features/SKILL.md`

**Step 1: Add autonomous mode section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-features/SKILL.md
git commit -m "feat(scheduling-features): add autonomous mode overview"
```

---

#### Task D.2: Document Feature-Only Velocity Calculation

**Step 1: Add velocity section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-features/SKILL.md
git commit -m "feat(scheduling-features): document feature-only velocity calculation"
```

---

#### Task D.3: Document Epic Grouping Auto-Logic

**Step 1: Add epic grouping section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-features/SKILL.md
git commit -m "feat(scheduling-features): document epic grouping auto-logic"
```

---

#### Task D.4: Document Sprint Creation for Features

**Step 1: Add sprint creation section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-features/SKILL.md
git commit -m "feat(scheduling-features): document sprint creation logic"
```

---

#### Task D.5: Document Output Format

**Step 1: Add output section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-features/SKILL.md
git commit -m "feat(scheduling-features): document output format"
```

---

#### Task D.6: Add Implementation Workflow

**Step 1: Add workflow section**

```markdown

## Implementation Workflow - Autonomous Mode

**Step 1: Calculate feature velocity**

```bash
velocity=$(calculate_feature_velocity)
echo "Feature velocity: $velocity features per sprint"
```

**Step 2: Check for epic grouping**

```bash
features_with_epics=$(yq eval '.features[] | select(.status == "approved" and .epic != null) | .id' features.yaml)

if [ -n "$features_with_epics" ]; then
  use_epic_grouping=true
else
  use_epic_grouping=false
fi
```

**Step 3: Create sprint(s)**

```bash
if [ "$use_epic_grouping" = true ]; then
  # Group by epic and create multiple sprints
  create_epic_sprints
else
  # Create single sprint with priority-based selection
  create_single_feature_sprint
fi
```

**Step 4: Update files and commit**

```bash
# Update features.yaml with sprint_id
# Create sprint documents
# Update ROADMAP.md

git add features.yaml docs/plans/sprints/ ROADMAP.md
git commit -m "feat: auto-schedule $feature_count features across $sprint_count sprint(s)"
```

**Step 5: Display summary**

Display appropriate output format from previous section.
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-features/SKILL.md
git commit -m "feat(scheduling-features): add autonomous mode implementation workflow"
```

---

## Wave 3: Polish Skills (2 Parallel Agents)

**Review Checkpoint:** Validate both implementations before final integration

---

### Section E: scheduling-implementation-plan Autonomous Mode

**Agent 5 implements this section independently**

**Current State:** Interactive with plan discovery and task counting
**Goal:** Add conservative auto-detection with plan-to-sprint mapping
**Invocation:** "auto-schedule plan [filename]"
**Estimated time:** 30-45 minutes

---

#### Task E.1: Add Autonomous Mode Detection to SKILL.md

**Files:** `.claude/skills/scheduling-implementation-plan/SKILL.md`

**Step 1: Add autonomous mode section**

```markdown

## Dual-Mode Operation

**Interactive Mode (Default):**
- User says "schedule plan" or provides plan filename
- Prompts for plan selection, sprint breakdown, feature linking
- Full human control over sprint boundaries
- Estimated time: 2-7 minutes per plan

**Autonomous Mode:**
- User says "auto-schedule plan [filename]" or "auto-schedule plan"
- Auto-discovers unscheduled plans if no filename provided
- Auto-counts tasks and determines sprint breakdown
- Auto-splits at natural boundaries (phases, sections)
- Creates sprints without prompting for confirmation
- Estimated time: 1-2 minutes per plan

**Mode Selection:**
Mode is determined by invocation phrase:
- Contains "auto-": Use autonomous mode
- Otherwise: Use interactive mode
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-implementation-plan/SKILL.md
git commit -m "feat(scheduling-implementation-plan): add autonomous mode overview"
```

---

#### Task E.2: Document Plan Discovery Auto-Logic

**Step 1: Add plan discovery section**

```markdown

## Autonomous Mode - Auto-Detection Logic

### 1. Plan Discovery

If no filename provided, find recent unscheduled plans:

```bash
# Find all implementation plan files
plans=$(find docs/plans/ -name "*-plan.md" -o -name "*-implementation-plan.md" | head -10)

# Check which plans are already scheduled
for plan_file in $plans; do
  # Extract plan name/ID
  plan_name=$(basename "$plan_file" | sed 's/-plan.md$//' | sed 's/-implementation-plan.md$//')

  # Check if plan already mentioned in ROADMAP.md or sprint documents
  if grep -q "$plan_name" ROADMAP.md 2>/dev/null; then
    echo "  ⊗ $plan_file (already scheduled)"
  else
    echo "  ○ $plan_file (unscheduled)"
    unscheduled_plans+=("$plan_file")
  fi
done

# Select most recent unscheduled plan
if [ ${#unscheduled_plans[@]} -eq 0 ]; then
  echo "No unscheduled plans found"
  exit 0
fi

# Use most recent by file modification time
selected_plan=$(ls -t "${unscheduled_plans[@]}" | head -1)
echo "Selected plan: $selected_plan"
```

### 2. Task Counting

Count tasks in plan:

```bash
# Count task markers:
# - "## Task" or "### Task" headings
# - "- [ ]" checkboxes

task_count=$(grep -c "^## Task\|^### Task\|- \[ \]" "$plan_file")

echo "Found $task_count tasks in plan"
```

### 3. Sprint Sizing Heuristics

Determine number of sprints based on task count:

```
≤8 tasks   → 1 sprint (1-2 weeks)
9-16 tasks → 2 sprints (2-4 weeks)
17-24 tasks → 3 sprints (3-6 weeks)
>24 tasks  → 4+ sprints (4-8 weeks)
```

```bash
if [ $task_count -le 8 ]; then
  sprint_count=1
elif [ $task_count -le 16 ]; then
  sprint_count=2
elif [ $task_count -le 24 ]; then
  sprint_count=3
else
  sprint_count=4
fi

echo "Recommended: $sprint_count sprint(s)"
```
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-implementation-plan/SKILL.md
git commit -m "feat(scheduling-implementation-plan): document plan discovery and sizing"
```

---

#### Task E.3: Document Sprint Splitting Auto-Logic

**Step 1: Add splitting logic section**

```markdown

### 4. Natural Boundary Detection

Look for natural split points in plan:

```bash
# Look for section headings that indicate phases or waves
boundaries=$(grep -n "^## \(Phase\|Wave\|Part\|Section\)" "$plan_file" | cut -d: -f1)

if [ -n "$boundaries" ]; then
  echo "Found natural boundaries at lines: $boundaries"
  use_natural_boundaries=true
else
  echo "No natural boundaries, will split evenly by task count"
  use_natural_boundaries=false
fi
```

**Splitting strategies:**

**Strategy 1: Natural boundaries exist**

```
IF plan has "## Phase 1", "## Phase 2", etc:
  → Split at each phase
  → Create SPRINT-XXX per phase
  → Sprint name: "Sprint XX: [Plan Name] - Phase 1"

EXAMPLE:
  Plan with "## Phase 1" (5 tasks), "## Phase 2" (7 tasks)
  → SPRINT-001: Feature ABC - Phase 1 (5 tasks)
  → SPRINT-002: Feature ABC - Phase 2 (7 tasks)
```

**Strategy 2: No natural boundaries**

```
IF plan has no clear phases:
  → Split evenly by task count
  → Tasks 1-8 → Sprint 1
  → Tasks 9-16 → Sprint 2
  → etc.
```

**Strategy 3: Single sprint**

```
IF task_count ≤ 8:
  → Create single sprint with all tasks
  → Sprint name: "Sprint XX: [Plan Name]"
```

**Conservative fallback:** When boundaries unclear, default to single sprint
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-implementation-plan/SKILL.md
git commit -m "feat(scheduling-implementation-plan): document sprint splitting logic"
```

---

#### Task E.4: Document Feature Linking Auto-Logic

**Step 1: Add feature linking section**

```markdown

### 5. Feature Linking

If FEAT-XXX in plan filename, link to feature:

```bash
# Extract FEAT-XXX from filename
feature_id=$(basename "$plan_file" | grep -oE 'FEAT-[0-9]{3}')

if [ -n "$feature_id" ]; then
  echo "Detected feature: $feature_id"

  # Update features.yaml with sprint_id(s)
  for sprint_id in $created_sprint_ids; do
    yq eval "(.features[] | select(.id == \"$feature_id\") | .sprint_id) = \"$sprint_id\"" -i features.yaml
  done

  # Add implementation_plan field if not exists
  yq eval "(.features[] | select(.id == \"$feature_id\") | .implementation_plan) = \"$plan_file\"" -i features.yaml

  # Update status to scheduled
  update_item_status "$feature_id" "scheduled"
fi
```

**Linking rules:**
- Single sprint: feature.sprint_id = SPRINT-XXX
- Multiple sprints: feature.sprint_id = first sprint, add sprints field with array
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-implementation-plan/SKILL.md
git commit -m "feat(scheduling-implementation-plan): document feature linking logic"
```

---

#### Task E.5: Document Output Format

**Step 1: Add output section**

```markdown

## Autonomous Mode - Output Format

**Single Sprint:**

```
✅ Auto-Schedule Complete

Plan: docs/plans/features/FEAT-042-medication-tracking-plan.md
Tasks: 7

Sprint Created: SPRINT-008 - Medication Tracking
Duration: 1-2 weeks
Tasks: 7

Files Updated:
  - docs/plans/sprints/SPRINT-008-medication-tracking.md
  - features.yaml (FEAT-042: sprint_id = SPRINT-008)
  - ROADMAP.md

Changes committed to git.

Next: Use executing-plans to implement SPRINT-008 tasks
```

**Multiple Sprints:**

```
✅ Auto-Schedule Complete

Plan: docs/plans/features/FEAT-050-analytics-dashboard-plan.md
Tasks: 18

Sprints Created: 2 (split at natural boundaries)

SPRINT-009: Analytics Dashboard - Phase 1
  - Duration: 2 weeks
  - Tasks: 8 (tasks 1-8)

SPRINT-010: Analytics Dashboard - Phase 2
  - Duration: 2 weeks
  - Tasks: 10 (tasks 9-18)

Files Updated:
  - docs/plans/sprints/SPRINT-009-analytics-dashboard-phase-1.md
  - docs/plans/sprints/SPRINT-010-analytics-dashboard-phase-2.md
  - features.yaml (FEAT-050: sprint_id = SPRINT-009, sprints = [009, 010])
  - ROADMAP.md

Changes committed to git.

Next: Start with SPRINT-009, then proceed to SPRINT-010
```
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-implementation-plan/SKILL.md
git commit -m "feat(scheduling-implementation-plan): document output format"
```

---

#### Task E.6: Add Implementation Workflow

**Step 1: Add workflow section**

```markdown

## Implementation Workflow - Autonomous Mode

**Step 1: Discover or load plan**

```bash
if [ -z "$plan_file" ]; then
  # Auto-discover
  plan_file=$(find_most_recent_unscheduled_plan)
else
  # Use provided filename
  if [ ! -f "$plan_file" ]; then
    echo "Error: Plan file not found: $plan_file"
    exit 1
  fi
fi
```

**Step 2: Count tasks and determine sprint breakdown**

```bash
task_count=$(grep -c "^## Task\|^### Task\|- \[ \]" "$plan_file")
sprint_count=$(calculate_sprint_count $task_count)

echo "Plan: $plan_file"
echo "Tasks: $task_count"
echo "Sprints: $sprint_count"
```

**Step 3: Split plan and create sprints**

```bash
if [ $sprint_count -eq 1 ]; then
  create_single_sprint "$plan_file" "$task_count"
else
  create_multiple_sprints "$plan_file" "$task_count" "$sprint_count"
fi
```

**Step 4: Link to feature if applicable**

```bash
feature_id=$(extract_feature_id "$plan_file")
if [ -n "$feature_id" ]; then
  link_feature_to_sprints "$feature_id" "${created_sprint_ids[@]}"
fi
```

**Step 5: Update ROADMAP and commit**

```bash
update_roadmap_with_sprints "${created_sprint_ids[@]}"

git add docs/plans/sprints/ features.yaml ROADMAP.md
git commit -m "feat: auto-schedule plan $plan_file across $sprint_count sprint(s)"
```

**Step 6: Display summary**

Display appropriate output format from previous section.
```

**Step 2: Commit**

```bash
git add .claude/skills/scheduling-implementation-plan/SKILL.md
git commit -m "feat(scheduling-implementation-plan): add autonomous mode workflow"
```

---

### Section F: fixing-bugs Autonomous Enhancements

**Agent 6 implements this section independently**

**Current State:** Already uses systematic-debugging autonomously, just needs bug selection
**Goal:** Add conservative auto-selection of highest priority unresolved bug
**Invocation:** "auto-fix bug"
**Estimated time:** 30-45 minutes

---

#### Task F.1: Add Autonomous Mode Detection to SKILL.md

**Files:** `.claude/skills/fixing-bugs/SKILL.md`

**Step 1: Add autonomous mode section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/fixing-bugs/SKILL.md
git commit -m "feat(fixing-bugs): add autonomous mode overview"
```

---

#### Task F.2: Document Bug Selection Auto-Logic

**Step 1: Add selection logic section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/fixing-bugs/SKILL.md
git commit -m "feat(fixing-bugs): document bug selection auto-logic"
```

---

#### Task F.3: Document Post-Fix Auto-Updates

**Step 1: Add post-fix updates section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/fixing-bugs/SKILL.md
git commit -m "feat(fixing-bugs): document post-fix auto-updates"
```

---

#### Task F.4: Document Output Format

**Step 1: Add output section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/fixing-bugs/SKILL.md
git commit -m "feat(fixing-bugs): document output format"
```

---

#### Task F.5: Add Implementation Workflow

**Step 1: Add workflow section**

```markdown

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
```

**Step 2: Commit**

```bash
git add .claude/skills/fixing-bugs/SKILL.md
git commit -m "feat(fixing-bugs): add autonomous mode workflow"
```

---

#### Task F.6: Test Autonomous Mode Documentation

**Step 1: Verify all sections present**

```bash
grep -c "Autonomous Mode" .claude/skills/fixing-bugs/SKILL.md
```

**Expected:** At least 4 matches

**Step 2: Commit validation**

```bash
git add .
git commit -m "test(fixing-bugs): validate autonomous mode documentation complete"
```

---

## Final Integration (After All Waves)

**Dependencies:** Waves 1-3 must be complete
**Estimated time:** 30-45 minutes

---

### Task Z.1: Update CHANGELOG.md

**Files:** `CHANGELOG.md`

**Step 1: Add v2.2.0 entry**

Add at top of CHANGELOG.md:

```markdown
## [2.2.0] - 2025-11-21

### Added

**Autonomous Modes for All Skills:**

**Shared Infrastructure:**
- **scripts/autonomous-helpers.sh** - Reusable detection and decision functions
  - detect_bug_severity() - Auto-detect bug severity from keywords (P0/P1/P2)
  - calculate_sprint_velocity() - Calculate average items per sprint from completed sprints
  - check_item_in_commits() - Scan git commits for work item patterns
  - get_item_status() / update_item_status() - YAML helper functions
  - extract_sprint_themes() - Generate sprint themes from work item titles
  - Eliminates code duplication across skills
  - Single source of truth for detection algorithms

**Wave 1: Triage Skills (Aggressive):**
- **triaging-bugs autonomous mode** - Auto-triage bugs with severity detection
  - Auto-detects P0/P1/P2 from title/description keywords
  - Auto-detects resolved bugs from git commit messages
  - Auto-triages all bugs with clear severity indicators
  - Warns about potential duplicates (>80% similarity)
  - Time: 5-10 seconds per bug (vs 1-2 min interactive)
  - Invocation: "auto-triage bugs"

- **triaging-features autonomous mode** - Auto-approve/reject features
  - Auto-detects in-scope vs out-of-scope from existing approved features
  - Auto-approves must-have and nice-to-have features in existing categories
  - Auto-rejects clear duplicates (>90% similarity)
  - Keeps uncertain cases as proposed for human review
  - Time: 5-10 seconds per feature (vs 1-2 min interactive)
  - Invocation: "auto-triage features"

**Wave 2: Scheduling Skills (Moderate):**
- **scheduling-work-items autonomous mode** - Auto-create sprints from backlog
  - Auto-calculates velocity from completed sprints
  - Auto-selects items by priority (P0→P1→Must-Have→Nice-to-Have)
  - Auto-generates sprint theme from item titles
  - Creates sprint without prompting for execution
  - Time: 2-3 minutes per sprint (vs 5-10 min interactive)
  - Invocation: "auto-schedule work items"

- **scheduling-features autonomous mode** - Auto-create feature sprints
  - Auto-calculates feature-only velocity
  - Auto-groups features by epic (if assigned)
  - Auto-selects features by priority
  - Creates single or multiple sprints based on epic grouping
  - Time: 2-3 minutes per sprint (vs 5-10 min interactive)
  - Invocation: "auto-schedule features"

**Wave 3: Polish Skills (Conservative):**
- **scheduling-implementation-plan autonomous mode** - Auto-schedule plans to sprints
  - Auto-discovers unscheduled plans (if no filename provided)
  - Auto-counts tasks and determines sprint breakdown
  - Auto-splits at natural boundaries (phases, sections)
  - Auto-links to features (if FEAT-XXX in filename)
  - Time: 1-2 minutes per plan (vs 2-7 min interactive)
  - Invocation: "auto-schedule plan [filename]"

- **fixing-bugs autonomous enhancements** - Auto-select bug to fix
  - Auto-selects highest priority unresolved bug
  - Priority: P0 in sprint → P0 triaged → P1 in sprint → P1 triaged → P2
  - Asks for confirmation if multiple P0 bugs (too critical to guess)
  - Prefers bugs with E2E tests (easier to verify)
  - Time: Same as interactive (30-60 min), just auto-selects bug
  - Invocation: "auto-fix bug"

### Changed

**Dual-Mode Operation Pattern:**
- All 6 skills now support both interactive and autonomous modes
- Interactive mode: Full human control with prompts (default)
- Autonomous mode: Auto-detection with conservative fallbacks (opt-in with "auto-" prefix)
- Mode selection: Determined by invocation phrase ("auto-triage" vs "triage")

**Aggressiveness Levels:**
- Aggressive (triaging): Easy to undo, high value (auto-triage all)
- Moderate (scheduling): Medium risk, needs velocity data (auto-schedule with capacity planning)
- Conservative (polish): Low frequency, complex decisions (auto-select but verify)

**Consistency Across Skills:**
- All autonomous modes source shared helpers from scripts/autonomous-helpers.sh
- All autonomous modes display detailed summaries without confirmation prompts
- All autonomous modes create structured git commits with changelogs
- All autonomous modes include conservative fallbacks for ambiguous cases

### Benefits

**Speed Improvements:**
- Triaging: 10-20x faster (1-2 min → 5-10 sec per item)
- Scheduling: 2-5x faster (5-10 min → 2-3 min per sprint)
- Bug fixing: Same speed (just auto-selects bug)

**Workflow Automation:**
Enables fully autonomous workflows:
```
auto-triage bugs → auto-schedule work items → auto-fix bug → auto-complete sprint
```

**Code Quality:**
- Shared utilities eliminate duplication
- Single source of truth for detection algorithms
- Easy to improve algorithms (update one file affects all skills)
- Testable independently

### Integration

**With Existing Skills:**
- completing-sprints already had autonomous mode (reference implementation)
- All 6 new autonomous modes follow the same pattern
- Backward compatible: interactive mode unchanged, autonomous opt-in

**With Workflow:**
- Autonomous modes integrate seamlessly with existing workflows
- Can mix interactive and autonomous (e.g., auto-triage, then manual schedule)
- Conservative fallbacks ensure safe operation

### Notes

**Use autonomous modes when:**
- Processing many items quickly (batch operations)
- Clear priority indicators exist (P0/P1, must-have)
- Trust auto-detection algorithms
- Want fast iteration without prompts

**Use interactive modes when:**
- Uncertain about decisions (new categories, ambiguous severity)
- Want full control over every decision
- Complex edge cases that need human judgment
- Prefer explicit confirmation at each step

**Future enhancements:**
- Add --dry-run flags for autonomous modes (preview before commit)
- Add configurable aggressiveness levels (strict/moderate/aggressive)
- Add machine learning for improved duplicate detection
- Add integration with CI/CD for automated triaging
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: add v2.2.0 release notes for autonomous modes"
```

---

### Task Z.2: Update README.md

**Files:** `README.md`

**Step 1: Add What's New section**

Add after existing entries:

```markdown
### v2.2.0 (November 2025) - Autonomous Modes for All Skills

**NEW: All 6 skills now support autonomous operation!**

- **Autonomous modes** - Auto-detect and auto-execute with minimal prompting
  - triaging-bugs: Auto-triage with severity detection (10-20x faster)
  - triaging-features: Auto-approve/reject with scope detection (8-15x faster)
  - scheduling-work-items: Auto-create sprints with velocity planning (2-5x faster)
  - scheduling-features: Auto-create feature sprints with epic grouping
  - scheduling-implementation-plan: Auto-schedule plans to sprints
  - fixing-bugs: Auto-select highest priority bug to fix

- **Shared utilities** - Reusable autonomous helper functions
  - scripts/autonomous-helpers.sh with 6 shared functions
  - Eliminates code duplication across skills
  - Single source of truth for detection algorithms

- **Aggressiveness levels** - Conservative, moderate, and aggressive
  - Aggressive: Triage skills (easy to undo)
  - Moderate: Scheduling skills (needs velocity data)
  - Conservative: Polish skills (complex decisions)

**[See CHANGELOG.md for full details →](CHANGELOG.md)**
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add v2.2.0 What's New section for autonomous modes"
```

---

### Task Z.3: Update EXTENSIONS.md

**Files:** `EXTENSIONS.md`

**Step 1: Update feature management section**

Find feature management extension and update description:

```markdown
### Feature Management Extension

**Location:** `extensions/feature-management/`
**Purpose:** Complete feature and bug lifecycle management with autonomous operation modes

**Skills (7):**
- **skills/reporting-bugs/** - Capture bugs during testing
- **skills/triaging-bugs/** - Triage reported bugs (interactive + autonomous)
- **skills/reporting-features/** - Capture feature requests
- **skills/triaging-features/** - Triage proposed features (interactive + autonomous)
- **skills/scheduling-work-items/** - Schedule bugs + features into sprints (interactive + autonomous)
- **skills/scheduling-features/** - Schedule features-only sprints (interactive + autonomous)
- **skills/scheduling-implementation-plan/** - Schedule implementation plans (interactive + autonomous)
- **skills/completing-sprints/** - Complete sprints systematically (interactive + autonomous)

**Supporting Scripts:**
- **scripts/autonomous-helpers.sh** - Shared autonomous detection and decision functions
- **scripts/validate-sprint-data.sh** - Sprint data consistency validation

**All skills support dual-mode operation:**
- Interactive mode: Full human control (default)
- Autonomous mode: Auto-detection with conservative fallbacks (opt-in)
```

**Step 2: Commit**

```bash
git add EXTENSIONS.md
git commit -m "docs: update EXTENSIONS.md with autonomous mode information"
```

---

### Task Z.4: Update Extension README

**Files:** `extensions/feature-management/README.md`

**Step 1: Update each skill description with dual-mode info**

Add dual-mode indicator to each skill:

```markdown
| **triaging-bugs** | Triage reported bugs (interactive + autonomous) | ~1-2 min/bug (interactive), ~5-10 sec/bug (autonomous) |
| **triaging-features** | Triage proposed features (interactive + autonomous) | ~1-2 min/feature (interactive), ~5-10 sec/feature (autonomous) |
| **scheduling-work-items** | Schedule bugs + features into sprints (interactive + autonomous) | ~5-10 min (interactive), ~2-3 min (autonomous) |
| **scheduling-features** | Schedule features-only sprints (interactive + autonomous) | ~5-10 min (interactive), ~2-3 min (autonomous) |
| **scheduling-implementation-plan** | Schedule plans to sprints (interactive + autonomous) | ~2-7 min (interactive), ~1-2 min (autonomous) |
| **fixing-bugs** | Fix bugs with auto-selection (interactive + autonomous) | ~30-60 min (same for both) |
| **completing-sprints** | Complete sprints systematically (interactive + autonomous) | ~5-10 min (interactive), ~2-3 min (autonomous) |
```

**Step 2: Add autonomous modes section**

Add new section:

```markdown

## Autonomous Modes

All skills now support autonomous operation with "auto-" prefix invocation.

**Usage:**
- Interactive: "triage bugs" (default, prompts for decisions)
- Autonomous: "auto-triage bugs" (auto-detects, no prompts)

**Aggressiveness Levels:**

| Skill | Level | Rationale | Time Savings |
|-------|-------|-----------|--------------|
| triaging-bugs | Aggressive | Easy to undo, high value | 10-20x faster |
| triaging-features | Aggressive | Easy to undo, high value | 8-15x faster |
| scheduling-work-items | Moderate | Medium risk, needs velocity | 2-5x faster |
| scheduling-features | Moderate | Medium risk, needs velocity | 2-5x faster |
| scheduling-implementation-plan | Conservative | Low frequency, complex | 2-3x faster |
| fixing-bugs | Conservative | Code changes, need confidence | Same speed |

**Shared Infrastructure:**

All autonomous modes use shared functions from `scripts/autonomous-helpers.sh`:
- detect_bug_severity() - Auto-detect P0/P1/P2 from keywords
- calculate_sprint_velocity() - Average items per sprint
- check_item_in_commits() - Scan git for work item patterns
- get_item_status() / update_item_status() - YAML helpers
- extract_sprint_themes() - Generate sprint themes

**See:** [scripts/autonomous-helpers.sh](../../scripts/autonomous-helpers.sh)
```

**Step 3: Commit**

```bash
git add extensions/feature-management/README.md
git commit -m "docs: add autonomous modes section to feature management README"
```

---

### Task Z.5: Integration Testing Instructions

**Files:** Create `docs/plans/2025-11-21-autonomous-modes-testing.md`

**Step 1: Create testing document**

```markdown
# Autonomous Modes Integration Testing

**Created:** 2025-11-21
**Purpose:** Test all 6 autonomous modes end-to-end

## Test Scenarios

### Scenario 1: Full Autonomous Workflow

**Goal:** Test complete autonomous workflow from triage to completion

**Steps:**

1. **Setup test data**
   - Create 10 test bugs with various severities in bugs.yaml (status="reported")
   - Create 8 test features with various priorities in features.yaml (status="proposed")
   - Ensure ROADMAP.md exists with velocity data

2. **Test auto-triage bugs**
   ```
   User: "auto-triage bugs"
   ```
   **Expected:**
   - All 10 bugs triaged with auto-detected severities
   - P0/P1/P2 assigned based on keywords
   - bugs.yaml updated with status="triaged"
   - Git commit created

3. **Test auto-triage features**
   ```
   User: "auto-triage features"
   ```
   **Expected:**
   - Features approved/rejected/kept based on category and priority
   - features.yaml updated
   - Git commit created

4. **Test auto-schedule work items**
   ```
   User: "auto-schedule work items"
   ```
   **Expected:**
   - Sprint created with capacity based on velocity
   - Items selected by priority (P0→P1→Must-Have→Nice-to-Have)
   - Sprint document created
   - ROADMAP.md updated
   - Git commit created

5. **Test auto-fix bug**
   ```
   User: "auto-fix bug"
   ```
   **Expected:**
   - Highest priority bug auto-selected
   - systematic-debugging workflow followed
   - Bug fixed and tested
   - bugs.yaml updated (status="resolved")
   - Git commit created

6. **Test auto-complete sprint**
   ```
   User: "auto-complete sprint"
   ```
   **Expected:**
   - Sprint completion auto-detected
   - Incomplete items dispositioned
   - Sprint document updated
   - bugs.yaml and features.yaml updated
   - Git commit created

**Total time:** ~10-15 minutes (vs 30-60 minutes interactive)

### Scenario 2: Individual Autonomous Mode Tests

**Test each mode independently:**

1. **auto-triage bugs**
   - Test with P0 keywords (crash, data loss)
   - Test with P1 keywords (error, broken)
   - Test with P2 keywords (styling, typo)
   - Verify severity auto-detection
   - Verify git commit scanning for fixes

2. **auto-triage features**
   - Test with in-scope categories
   - Test with new categories (should keep as proposed)
   - Test with clear duplicates (>90% similar)
   - Verify auto-approval logic

3. **auto-schedule work items**
   - Test with velocity data present
   - Test with no velocity data (should use default 5)
   - Test with <3 items (should exit with error)
   - Verify item selection by priority

4. **auto-schedule features**
   - Test with epic assignments (should create multiple sprints)
   - Test without epics (should create single sprint)
   - Verify feature-only velocity calculation

5. **auto-schedule plan**
   - Test with plan filename provided
   - Test without filename (should auto-discover)
   - Test with natural boundaries (phases)
   - Test without boundaries (even split)
   - Verify sprint creation and task splitting

6. **auto-fix bug**
   - Test with single P0 bug (should auto-select)
   - Test with multiple P0 bugs (should ask user)
   - Test with P1 bugs only
   - Test with no bugs (should exit gracefully)
   - Verify E2E test execution

### Scenario 3: Shared Helpers Testing

**Test autonomous-helpers.sh functions:**

```bash
# Source helpers
source scripts/autonomous-helpers.sh

# Test severity detection
detect_bug_severity "App crashes on startup" "When I open the app it crashes"
# Expected: P0

detect_bug_severity "Button alignment off by 2px" "Minor styling issue"
# Expected: P2

# Test velocity calculation
calculate_sprint_velocity
# Expected: Average from ROADMAP.md or 0 if no data

# Test git commit scanning
check_item_in_commits "BUG-001" "fix" "2025-11-01"
# Expected: Commit SHA if fix found, empty if not

# Test YAML helpers
get_item_status "FEAT-001"
# Expected: Current status (e.g., "approved")

update_item_status "FEAT-001" "scheduled"
# Expected: features.yaml updated

# Test theme extraction
extract_sprint_themes "FEAT-001 FEAT-002 BUG-003"
# Expected: Theme string (e.g., "Timeline and Document Management")
```

## Success Criteria

✅ All autonomous modes complete without errors
✅ Shared helpers used consistently across all skills
✅ Conservative fallbacks work correctly (ambiguous cases)
✅ Git commits created with proper messages
✅ YAML files updated correctly
✅ Speed improvements measured (10-20x for triage, 2-5x for scheduling)
✅ Error handling works (not enough items, no velocity data, etc.)
✅ Integration with existing interactive modes preserved

## Known Issues / Edge Cases

- **Duplicate detection:** Simplified implementation (substring matching), production would use Levenshtein distance
- **Theme extraction:** Simplified keyword extraction, production would use NLP or frequency analysis
- **Velocity calculation:** Assumes consistent completion rates, may not account for complexity changes
- **Fix detection:** Git commit patterns may miss unconventional commit messages

## Future Enhancements

- Add --dry-run flags for preview without commit
- Add configurable aggressiveness levels (strict/moderate/aggressive)
- Add machine learning for improved duplicate detection
- Add integration with CI/CD for automated triaging
- Add metrics dashboard for autonomous mode usage and accuracy
```

**Step 2: Commit**

```bash
git add docs/plans/2025-11-21-autonomous-modes-testing.md
git commit -m "test: add autonomous modes integration testing document"
```

---

### Task Z.6: Final Validation and Summary

**Step 1: Verify all files exist**

```bash
# Check shared helpers
ls -la scripts/autonomous-helpers.sh

# Check all skill SKILL.md files updated
grep -l "Autonomous Mode" .claude/skills/*/SKILL.md extensions/*/skills/*/SKILL.md

# Check documentation updated
grep -l "autonomous" CHANGELOG.md README.md EXTENSIONS.md extensions/feature-management/README.md
```

**Expected:** All files exist and contain autonomous mode content

**Step 2: Count total tasks completed**

```bash
git log --oneline | grep -E "(feat\(|test\(|docs:)" | wc -l
```

**Expected:** ~60-65 commits for all tasks

**Step 3: Verify structure**

```bash
echo "Task 0: Shared Infrastructure"
git log --oneline | grep "autonomous-helpers" | wc -l
echo "Expected: 6 commits"

echo ""
echo "Wave 1: Triage Skills"
git log --oneline | grep -E "(triaging-bugs|triaging-features)" | wc -l
echo "Expected: ~12 commits"

echo ""
echo "Wave 2: Scheduling Skills"
git log --oneline | grep -E "(scheduling-work-items|scheduling-features)" | wc -l
echo "Expected: ~12 commits"

echo ""
echo "Wave 3: Polish Skills"
git log --online | grep -E "(scheduling-implementation-plan|fixing-bugs)" | wc -l
echo "Expected: ~12 commits"

echo ""
echo "Final Integration"
git log --oneline | grep -E "(docs:|test:)" | wc -l
echo "Expected: ~6 commits"
```

**Step 4: Create final summary commit**

```bash
git add .
git commit -m "feat: complete autonomous modes implementation for 6 skills (v2.2.0)

Summary:
- Task 0: Shared infrastructure (autonomous-helpers.sh)
- Wave 1: triaging-bugs, triaging-features (aggressive)
- Wave 2: scheduling-work-items, scheduling-features (moderate)
- Wave 3: scheduling-implementation-plan, fixing-bugs (conservative)
- Final integration: Documentation and testing

Total tasks: 65
Total commits: ~65
Estimated time: 3-4 hours with parallel execution

All 6 skills now support dual-mode operation:
- Interactive mode: Full human control (default)
- Autonomous mode: Auto-detection with fallbacks (opt-in)

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Execution Instructions for Parallel Agents

### Using dispatching-parallel-agents

**Wave 1:**

```bash
# In main conversation
User: "Use dispatching-parallel-agents to execute Wave 1"

# Claude will dispatch 2 agents:
# - Agent 1: Section A (triaging-bugs)
# - Agent 2: Section B (triaging-features)

# Wait for both to complete, then review
```

**Wave 2:**

```bash
# After Wave 1 review checkpoint
User: "Use dispatching-parallel-agents to execute Wave 2"

# Claude will dispatch 2 agents:
# - Agent 3: Section C (scheduling-work-items)
# - Agent 4: Section D (scheduling-features)

# Wait for both to complete, then review
```

**Wave 3:**

```bash
# After Wave 2 review checkpoint
User: "Use dispatching-parallel-agents to execute Wave 3"

# Claude will dispatch 2 agents:
# - Agent 5: Section E (scheduling-implementation-plan)
# - Agent 6: Section F (fixing-bugs)

# Wait for both to complete, then review
```

**Final Integration:**

```bash
# After Wave 3 review checkpoint
User: "Execute final integration tasks (Z.1 through Z.6)"

# Main agent executes sequentially:
# - Update CHANGELOG.md
# - Update README.md
# - Update EXTENSIONS.md
# - Update extension README
# - Create testing document
# - Final validation
```

### Review Checkpoints

**Between each wave:**

1. Verify all commits created
2. Check for conflicts or issues
3. Review SKILL.md updates for completeness
4. Test basic functionality (if possible)
5. Approve to continue to next wave

---

## Summary

**Plan Structure:**
- Task 0: Shared Infrastructure (6 tasks)
- Wave 1: Section A + Section B (12 tasks)
- Wave 2: Section C + Section D (12 tasks)
- Wave 3: Section E + Section F (12 tasks)
- Final Integration: Tasks Z.1 through Z.6 (6 tasks)

**Total: ~65 tasks**

**Execution:**
- Task 0: Sequential (15-20 min)
- Wave 1: Parallel (30-45 min)
- Wave 2: Parallel (45-60 min)
- Wave 3: Parallel (30-45 min)
- Final: Sequential (30-45 min)

**Total time: 3-4 hours**

**Files created/modified:**
- scripts/autonomous-helpers.sh (new)
- .claude/skills/triaging-bugs/SKILL.md (modified)
- .claude/skills/triaging-features/SKILL.md (modified)
- .claude/skills/scheduling-work-items/SKILL.md (modified)
- .claude/skills/scheduling-features/SKILL.md (modified)
- .claude/skills/scheduling-implementation-plan/SKILL.md (modified)
- .claude/skills/fixing-bugs/SKILL.md (modified)
- CHANGELOG.md (modified)
- README.md (modified)
- EXTENSIONS.md (modified)
- extensions/feature-management/README.md (modified)
- docs/plans/2025-11-21-autonomous-modes-testing.md (new)

---

**Version:** 1.0
**Last Updated:** 2025-11-21
**Ready for execution by parallel agents**
