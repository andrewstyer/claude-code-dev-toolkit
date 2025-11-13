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
