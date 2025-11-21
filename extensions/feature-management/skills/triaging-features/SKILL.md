---
name: triaging-features
description: Batch review and prioritization of proposed features - approve, reject, reprioritize, assign to epics
---

# Triaging Features

## Overview

Review and prioritize proposed feature requests in batches. Approve features for development, reject invalid requests, adjust priorities, and optionally assign features to epics or themes.

**Announce at start:** "I'm using the triaging-features skill to review proposed features."

## When to Use

- User says: "triage features" or "review features"
- After one or more features have been reported
- Before sprint planning (to ensure features are approved)
- Weekly/biweekly triage sessions
- When backlog needs cleanup

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

## Process

### Phase 1: List Proposed Features

**Read features.yaml and show all features with status="proposed"**

**Display format:**
```
📋 Proposed Features for Triage

[If none found]
No proposed features found. All features have been triaged.

[If found, group by category]

New Functionality:
  • FEAT-001: Add medication tracking [Must-Have]
  • FEAT-003: Export health summary as PDF [Nice-to-Have]

UX Improvement:
  • FEAT-002: Improve document upload flow [Must-Have]

[Count] proposed features found.
```

**If no proposed features:**
- Exit with message: "All features have been triaged. Use /report-feature to add more."

### Phase 2: Apply Filters (Optional)

**Before batch selection, ask about filtering:**
```
Use AskUserQuestion:
Question: "How would you like to filter the features?"
Header: "Filter Options"
multiSelect: false
Options:
  - Label: "All Proposed"
    Description: "Show all proposed features"
  - Label: "By Category"
    Description: "Filter by specific category"
  - Label: "By Priority"
    Description: "Filter by current priority level"
  - Label: "Recent Only"
    Description: "Show features from last 7 days only"
```

**If "By Category" selected:**
```
Use AskUserQuestion with category options:
Question: "Which category?"
Options: New Functionality | UX Improvement | Performance | Platform-Specific
```

**If "By Priority" selected:**
```
Use AskUserQuestion with priority options:
Question: "Which priority?"
Options: Must-Have | Nice-to-Have | Future
```

**Apply filter and re-display matching features**

### Phase 3: Batch Selection

**Select features for review:**
```
Use AskUserQuestion:
Question: "Select features to review in this session"
Header: "Feature Selection"
multiSelect: true  # IMPORTANT: Allow multiple selection
Options:
  - Label: "FEAT-001: Add medication tracking"
    Description: "Must-Have | New Functionality"
  - Label: "FEAT-002: Improve document upload flow"
    Description: "Must-Have | UX Improvement"
  [... for each proposed feature in filtered list]
```

**If no features selected:**
- Exit with message: "No features selected for triage."

### Phase 4: Review Each Selected Feature

**For each selected feature, IN ORDER:**

**Display full details:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reviewing: FEAT-XXX

Title: [title]
Description: [description]

User Value: [user_value]
Category: [category]
Current Priority: [priority]
Context: [context if present]
Created: [created_at formatted nicely]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Ask for action:**
```
Use AskUserQuestion:
Question: "What action for FEAT-XXX?"
Header: "Triage Action"
multiSelect: false
Options:
  - Label: "Approve"
    Description: "Accept feature, change status to 'approved'"
  - Label: "Reprioritize"
    Description: "Change priority level (keep as proposed)"
  - Label: "Assign to Epic"
    Description: "Link to epic/theme (and approve)"
  - Label: "Reject"
    Description: "Decline feature request with reason"
  - Label: "Skip"
    Description: "Leave as proposed, review later"
```

**Handle each action:**

#### Action: Approve
- Update feature: `status: approved`
- Update feature: `updated_at: [current timestamp]`
- Track change for git commit
- Continue to next feature

#### Action: Reprioritize
```
Use AskUserQuestion:
Question: "New priority for FEAT-XXX?"
Header: "Priority"
Options:
  - Label: "Must-Have"
  - Label: "Nice-to-Have"
  - Label: "Future"
```
- Update feature: `priority: [new priority]`
- Update feature: `updated_at: [current timestamp]`
- Ask: "Also approve this feature now?" (Yes/No)
  - If Yes: `status: approved`
  - If No: keep `status: proposed`
- Track change for git commit
- Continue to next feature

#### Action: Assign to Epic
```
Prompt: "Epic name?" (e.g., "Epic 3: Medication Management")
```
- Update feature: `epic: "[epic name]"`
- Update feature: `status: approved` (assigning to epic implies approval)
- Update feature: `updated_at: [current timestamp]`
- Track change for git commit
- Continue to next feature

#### Action: Reject
```
Prompt: "Rejection reason?" (explain why declining)
```
- Update feature: `status: rejected`
- Update feature: `rejection_reason: "[reason]"`
- Update feature: `updated_at: [current timestamp]`
- Track change for git commit
- Continue to next feature

#### Action: Skip
- No changes made
- Continue to next feature

### Phase 5: Update Files

**After all selected features reviewed:**

1. **Update features.yaml** with all changes
2. **Update docs/features/index.yaml** to reflect new statuses/priorities/epics
3. **Validate YAML syntax** before writing

### Phase 6: Git Commit

**Create descriptive commit:**
```bash
git add features.yaml docs/features/index.yaml
git commit -m "feat: triage features - [count] approved, [count] rejected

Triaged [total count] features:

Approved:
- FEAT-XXX: [title]
- FEAT-YYY: [title]

[If any reprioritized]
Reprioritized:
- FEAT-ZZZ: [old priority] → [new priority]

[If any assigned to epics]
Assigned to Epics:
- FEAT-AAA → [epic name]

[If any rejected]
Rejected:
- FEAT-BBB: [reason]"
```

### Phase 7: Display Summary

**Show triage results:**
```
✅ Feature Triage Complete

Summary:
  • [X] features approved
  • [Y] features reprioritized
  • [Z] features assigned to epics
  • [W] features rejected
  • [V] features skipped (still proposed)

Approved Features:
  FEAT-XXX: [title] ([priority])
  FEAT-YYY: [title] ([priority])

[If any rejected]
Rejected Features:
  FEAT-BBB: [title] - [reason]

Next Steps:
1. Approved features can be scheduled in sprints
2. Use /schedule-features to create sprint plans
3. Skipped features remain proposed for future triage

Changes committed to git.
```

## Smart Filtering Examples

**Filter by category:**
- User wants to focus on UX improvements only
- Filter shows only category="ux-improvement"

**Filter by priority:**
- User wants to triage Must-Have features first
- Filter shows only priority="must-have"

**Recent only:**
- User wants to review features from last 7 days
- Filter shows created_at >= (now - 7 days)

**Multiple triage sessions:**
- Session 1: Review Must-Have features
- Session 2: Review Nice-to-Have features
- Session 3: Clean up old proposed features

## Data Validation

**Before committing:**
- Verify all updated features have `updated_at` timestamp
- Verify `status` values are valid (proposed/approved/rejected/scheduled/in-progress/completed)
- Verify `priority` values are valid (must-have/nice-to-have/future)
- Verify rejected features have `rejection_reason`
- Verify YAML is valid (will not corrupt features.yaml)

## Error Handling

**If features.yaml not found:**
- Error: "No features.yaml found. Use /report-feature to create first feature."

**If features.yaml is malformed:**
- Error: "features.yaml is corrupted. Please fix YAML syntax."
- Do not overwrite file

**If git commit fails:**
- Warn user
- Changes are saved to files
- User can commit manually

## Integration with Other Skills

**Upstream:** reporting-features (creates proposed features)
**Downstream:** scheduling-features (works with approved features)
**Complementary:** reporting-bugs (similar triage workflow)

## Workflow Tips

**Weekly Triage Cadence:**
1. Monday: Triage all new features from last week
2. Approve Must-Have features immediately
3. Batch-approve Nice-to-Have features for later sprints
4. Reject clearly out-of-scope features

**Epic Organization:**
- Assign features to epics during triage
- Makes sprint planning easier (group by epic)
- Example epics: "Epic 1: Core Features", "Epic 2: UX Polish"

**Priority Discipline:**
- Must-Have: Next 1-2 sprints
- Nice-to-Have: Next 3-6 months
- Future: Parking lot for good ideas

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

## Success Criteria

✅ Batch review of multiple features in one session
✅ Smart filtering by category/priority/date
✅ Approve, reject, or reprioritize efficiently
✅ Optional epic assignment for organization
✅ Clear summary of triage results
✅ Git commit with detailed changelog
✅ Index updated for fast querying

## Testing

**Test cases:**
1. Triage with no proposed features (graceful exit)
2. Approve multiple features
3. Reject feature with reason
4. Reprioritize feature
5. Assign feature to epic
6. Filter by category
7. Skip feature for later review
8. Verify index stays in sync

## Notes

- This skill ONLY works with status="proposed" features
- Approved features are ready for scheduling-features skill
- Rejected features stay in features.yaml for history
- Epic assignment is optional but helpful for organization
- Multiple triage sessions are expected (don't feel pressure to review everything at once)

---

**Version:** 1.0
**Last Updated:** 2025-11-14
**Based on:** Health Narrative 2 feature request system design
