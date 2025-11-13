---
name: reporting-features
description: Interactive feature request capture during development - prompts for details, stores in features.yaml, detects duplicates
---

# Reporting Features

## Overview

Capture feature requests during development and testing with structured prompting. Creates entry in features.yaml with auto-incrementing IDs (FEAT-001, FEAT-002, etc.), detects potential duplicates, and integrates with sprint planning workflow.

**Announce at start:** "I'm using the reporting-features skill to capture this feature request."

## When to Use

- User says: "report a feature" or "feature request"
- During manual testing when user suggests improvements
- Anytime user describes desired functionality
- When brainstorming new capabilities

## Process

### Phase 1: Gather Required Information

Ask for information ONE question at a time:

**1. Feature Title**
```
What's a short title for this feature request? (one line summary)
```

**2. Description**
```
Describe what this feature should do (be specific about functionality)
```

**3. Category (use AskUserQuestion)**
```
Use AskUserQuestion tool with these options:
Question: "What category does this feature fall under?"
Header: "Category"
multiSelect: false
Options:
  - Label: "New Functionality"
    Description: "Adds completely new capability to the app"
  - Label: "UX Improvement"
    Description: "Enhances existing feature usability or design"
  - Label: "Performance"
    Description: "Improves speed, efficiency, or resource usage"
  - Label: "Platform-Specific"
    Description: "iOS-specific, Android-specific, or iPad-specific enhancement"
```

**4. User Value**
```
Why would this be valuable to users? (describe the benefit)
```

**5. Priority (use AskUserQuestion)**
```
Use AskUserQuestion tool with these options:
Question: "What is the priority for this feature?"
Header: "Priority"
multiSelect: false
Options:
  - Label: "Must-Have"
    Description: "Critical for product success, should be in next sprint"
  - Label: "Nice-to-Have"
    Description: "Valuable but not urgent, schedule when capacity allows"
  - Label: "Future"
    Description: "Good idea for later, not near-term priority"
```

### Phase 2: Gather Optional Information

**6. Additional Context**
```
(Optional) Any additional context? (device info, related features, user feedback, etc.)
Press Enter to skip.
```

### Phase 3: Duplicate Detection

**Before creating the feature:**

1. Read existing features.yaml
2. Search for similar titles using fuzzy matching
3. If potential duplicates found (similarity > 70%):
   ```
   Use AskUserQuestion:
   Question: "Found similar feature(s): [list titles]. Continue creating new feature?"
   Header: "Duplicate Check"
   Options:
     - Label: "Yes, create new"
       Description: "This is different enough to warrant a new entry"
     - Label: "No, cancel"
       Description: "This is a duplicate, don't create"
   ```
4. If user chooses "No, cancel" → Exit without creating

### Phase 4: Create Feature Entry

**Generate feature ID:**
- Read `nextId` from features.yaml (or start at 1 if file doesn't exist)
- Format as FEAT-{nextId:03d} (e.g., FEAT-001, FEAT-002)
- Increment nextId

**Create feature entry:**
```yaml
- id: FEAT-XXX
  title: "[user's title]"
  description: "[user's description]"
  category: "[selected category]"  # new-functionality | ux-improvement | performance | platform-specific
  user_value: "[user's value description]"
  priority: "[selected priority]"  # must-have | nice-to-have | future
  status: proposed
  created_at: "[ISO 8601 timestamp]"
  updated_at: "[ISO 8601 timestamp]"
  context: "[optional context]"  # omit if not provided
```

**Update files:**
1. Add entry to features.yaml (create file if doesn't exist)
2. Increment nextId in features.yaml
3. Update docs/features/index.yaml (create if doesn't exist):
   ```yaml
   features:
     - id: FEAT-XXX
       title: "[title]"
       status: proposed
       priority: "[priority]"
       category: "[category]"
       created_at: "[timestamp]"
       file: features.yaml
   ```

### Phase 5: Git Commit

**Commit with descriptive message:**
```bash
git add features.yaml docs/features/index.yaml
git commit -m "feat: add FEAT-XXX - [short title]

Feature request: [title]
Category: [category]
Priority: [priority]
Status: proposed

[description]

User value: [user_value]"
```

### Phase 6: Display Summary

**Show user:**
```
✅ Feature Request Captured

ID: FEAT-XXX
Title: [title]
Category: [category]
Priority: [priority]
Status: proposed

Next Steps:
1. Use /triage-features to review and approve this feature
2. After approval, use /schedule-features to add to a sprint
3. Feature stored in: features.yaml

Feature requests help plan future development. Thanks for the suggestion!
```

## File Structure Created

**On first use, creates:**
```
project-root/
├── features.yaml                    # All features
└── docs/
    └── features/
        └── index.yaml              # Fast lookup index
```

## Data Format

### features.yaml
```yaml
nextId: 5
features:
  - id: FEAT-001
    title: "Add medication tracking"
    description: "Allow users to track medications with dosage and schedule"
    category: new-functionality
    user_value: "Helps users manage complex medication regimens"
    priority: must-have
    status: proposed
    created_at: "2025-01-14T10:30:00Z"
    updated_at: "2025-01-14T10:30:00Z"
    context: "Requested during iPad testing"  # optional
```

### docs/features/index.yaml
```yaml
features:
  - id: FEAT-001
    title: "Add medication tracking"
    status: proposed
    priority: must-have
    category: new-functionality
    created_at: "2025-01-14T10:30:00Z"
    file: features.yaml
```

## Error Handling

**If features.yaml exists but is malformed:**
- Show error message
- Do not overwrite existing data
- Ask user to check file format

**If git commit fails:**
- Show error message
- Feature data is still written to files
- User can commit manually

**If duplicate detection fails:**
- Warn user
- Allow creation to proceed
- Log warning in commit message

## Integration with Other Skills

**Works with:**
- `triaging-features` - Next step after reporting
- `scheduling-features` - After features are approved
- `reporting-bugs` - Complementary (features are planned, bugs are reactive)

**Feature can reference bugs:**
- In context field: "Related to BUG-012"
- In description: "Fixes underlying issue in BUG-012"

## Success Criteria

✅ User can report feature in ~2 minutes
✅ All required fields captured with clear prompts
✅ Feature stored with auto-incremented ID
✅ Index updated for fast querying by other skills
✅ Duplicate detection prevents redundant entries
✅ Clear next steps displayed
✅ Git commit with descriptive message

## Testing

**Test cases:**
1. Report first feature (creates features.yaml)
2. Report second feature (increments ID)
3. Report duplicate (detects and prevents)
4. Report with all optional fields
5. Report with no optional fields
6. Verify git commits are clean and descriptive

## Notes

- This skill ONLY creates features with status="proposed"
- Triaging and scheduling are handled by separate skills
- Keep prompts concise - users are interrupting workflow to report ideas
- Duplicate detection is helpful but not perfect - allow override
- Context field is valuable for preserving "where/when" info

---

**Version:** 1.0
**Last Updated:** 2025-11-14
**Based on:** Health Narrative 2 feature request system design
