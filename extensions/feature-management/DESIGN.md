# Feature Request System Design

**Created:** 2025-01-14
**Status:** Approved
**Purpose:** Create a structured process for capturing, triaging, and scheduling feature requests

## Overview

This design establishes a three-skill workflow for managing feature requests from initial capture through sprint scheduling and implementation. The system mirrors the existing bug reporting workflow while adding sprint integration and superpowers execution capabilities.

## Goals

1. Capture feature requests during manual testing sessions
2. Provide structured triage process for prioritization
3. Enable sprint creation and feature scheduling
4. Integrate with superpowers workflow for implementation
5. Maintain clear feature lifecycle from proposal to completion

## System Architecture

### Three-Skill Workflow

```
reporting-features → triaging-features → scheduling-features
    (capture)           (prioritize)         (plan & execute)
      ↓                     ↓                      ↓
  proposed              approved              scheduled
```

### Data Storage

- **features.yaml** - All feature requests with auto-incrementing IDs (FEAT-001, FEAT-002, etc.)
- **docs/features/index.yaml** - Fast lookup index for querying
- **docs/plans/sprints/** - Sprint planning documents
- **docs/plans/ROADMAP.md** - Chronological view of all sprints (auto-updated)

### Feature State Flow

```
proposed → approved → scheduled → in-progress → completed
                  ↓
              rejected
```

## Skill 1: reporting-features

**Purpose:** Interactive capture of feature requests during manual testing

### Capture Flow

Interactive prompts (one at a time):

1. **Title** - "What's a short title for this feature request?"
2. **Description** - "Describe what this feature should do"
3. **Category** (AskUserQuestion) - Options:
   - New Functionality
   - UX Improvement
   - Performance
   - Platform-Specific
4. **User Value** - "Why would this be valuable to users?"
5. **Priority** (AskUserQuestion) - Options:
   - Must-Have
   - Nice-to-Have
   - Future
6. **Context** (optional) - "Any additional context? (device, screenshots, related features)"

### Features

- **Duplicate Detection:** Searches existing features by title similarity before creating
- **Validation:** Requires title, description, category, user_value, priority
- **Auto-ID Generation:** FEAT-001, FEAT-002, etc.
- **Git Integration:** Commits new feature with descriptive message

### Output

- Creates entry in features.yaml with status="proposed"
- Updates docs/features/index.yaml
- Displays summary with next steps: "Use /triage-features to review and prioritize"

## Skill 2: triaging-features

**Purpose:** Review, prioritize, and approve proposed feature requests

### Workflow

1. **List Features** - Display all features with status="proposed", grouped by category
2. **Batch Selection** (AskUserQuestion multiSelect) - Select which features to review
3. **For Each Selected Feature:**
   - Display: Title, description, user value, current priority, category
   - **Actions** (AskUserQuestion):
     - Approve (change status to "approved")
     - Reprioritize (change priority: Must-Have/Nice-to-Have/Future)
     - Assign to Epic/Theme (optional: link to existing epic)
     - Reject (change status to "rejected", add rejection reason)
     - Skip (leave as "proposed")

4. **Batch Updates** - Update features.yaml and index
5. **Summary** - Show counts: X approved, Y reprioritized, Z rejected
6. **Git Commit** - Commit all triaging changes

### Smart Filtering

- Filter by category: "Show only UX improvements"
- Filter by priority: "Show only Must-Have features"
- Show recently reported (last 7 days)

### Output

Features with status="approved", ready for sprint scheduling

## Skill 3: scheduling-features

**Purpose:** Create sprints from approved features and optionally execute with superpowers

### Workflow

1. **Show Approved Features** - Display all features with status="approved", grouped by priority/epic

2. **Sprint Action** (AskUserQuestion):
   - Create new sprint
   - Add to existing sprint

#### Create New Sprint

- Prompt: "Sprint name/number?" (e.g., "Sprint 5: User Settings")
- Prompt: "Sprint goal/description?"
- Multi-select approved features to include
- Generate sprint document: `docs/plans/sprints/YYYY-MM-DD-sprint-N.md`
- Update selected features: status="scheduled", add sprint_id field

#### Add to Existing Sprint

- List existing sprints from docs/plans/sprints/
- Select target sprint
- Multi-select approved features to add
- Append features to sprint document
- Update features: status="scheduled", add sprint_id field

### Implementation Planning Integration

3. **Implementation Planning** (AskUserQuestion):
   - "Generate detailed implementation plan now?"
   - **Yes:** Use superpowers workflow
   - **No:** Skip (can be done later)

**If Yes:**
- For each feature in sprint (or selected subset):
  - Run `superpowers:brainstorming` to refine feature into detailed design
  - Run `superpowers:writing-plans` to create implementation plan
  - Store plan in `docs/plans/YYYY-MM-DD-feat-XXX-[slug].md`
  - Link plan path back to feature in features.yaml

### Execution Integration

4. **Execution Mode** (AskUserQuestion - only if plans created):
   - "Ready to start implementation?"
   - Execute now with subagent-driven-development
   - Execute now with executing-plans
   - Save for later (sprint scheduled, plans ready)

**If Execute Now:**
- **subagent-driven-development:** Dispatch subagents for independent tasks, code review between tasks
- **executing-plans:** Execute plan in batches with review checkpoints
- Features update to status="in-progress" during execution
- Features update to status="completed" when done

### Integration Points

- `superpowers:brainstorming` - Refine feature into design
- `superpowers:writing-plans` - Create detailed implementation plans
- `superpowers:subagent-driven-development` - Fast parallel execution with quality gates
- `superpowers:executing-plans` - Controlled batch execution with reviews
- `superpowers:using-git-worktrees` - Isolate implementation work

### Output

- Sprint document created/updated
- Features marked as "scheduled" with sprint_id
- Optional: Implementation plans generated and linked
- Optional: Implementation execution in progress
- Git commit with all changes

## Data Structures

### features.yaml

```yaml
nextId: 5
features:
  - id: FEAT-001
    title: "Add medication tracking"
    description: "Allow users to track medications with dosage and schedule"
    category: new-functionality  # new-functionality | ux-improvement | performance | platform-specific
    user_value: "Helps users manage complex medication regimens"
    priority: must-have  # must-have | nice-to-have | future
    status: scheduled  # proposed | approved | scheduled | in-progress | completed | rejected
    created_at: "2025-01-14T10:30:00Z"
    updated_at: "2025-01-14T15:45:00Z"
    context: "Requested during iPad testing"  # optional
    epic: "Epic 3: Medication Management"  # optional
    sprint_id: "sprint-5"  # optional, set when scheduled
    implementation_plan: "docs/plans/2025-01-14-feat-001-medication-tracking.md"  # optional
    rejection_reason: ""  # optional, only if rejected
```

### docs/features/index.yaml

```yaml
features:
  - id: FEAT-001
    title: "Add medication tracking"
    status: scheduled
    priority: must-have
    category: new-functionality
    created_at: "2025-01-14T10:30:00Z"
    file: features.yaml
```

### Sprint Document Template

**Location:** `docs/plans/sprints/YYYY-MM-DD-sprint-N-[slug].md`

**Example:** `docs/plans/sprints/2025-01-14-sprint-5-medication-tracking.md`

```markdown
# Sprint N: [Name]

**Goal:** [Sprint goal]
**Created:** YYYY-MM-DD
**Status:** planned | in-progress | completed

## Features

### FEAT-XXX: [Title]
- **Category:** [category]
- **Priority:** [priority]
- **User Value:** [user_value]
- **Description:** [description]
- **Implementation Plan:** [path to plan if exists]

[Repeat for each feature]

## Success Criteria
- [ ] All features implemented
- [ ] Tests passing
- [ ] Deployed to TestFlight
```

### Implementation Plan Linking

- **Plans stored in:** `docs/plans/YYYY-MM-DD-feat-XXX-[slug].md`
- **Path stored in:** feature's `implementation_plan` field
- **Navigation:** feature → plan → implementation

### Roadmap Document

**Location:** `docs/plans/ROADMAP.md`

**Auto-Management:** Updated automatically by `scheduling-features` skill when sprints are created or modified

**Structure:**
```markdown
# Product Roadmap

**Last Updated:** YYYY-MM-DD

## Sprints

### Sprint 6: User Settings
- **Status:** planned
- **Created:** 2025-01-15
- **Goal:** Implement user preferences and settings management
- **Sprint Document:** [docs/plans/sprints/2025-01-15-sprint-6-user-settings.md](sprints/2025-01-15-sprint-6-user-settings.md)
- **Features:** 4 features scheduled

### Sprint 5: Medication Tracking
- **Status:** in-progress
- **Created:** 2025-01-14
- **Goal:** Add medication tracking and reminders
- **Sprint Document:** [docs/plans/sprints/2025-01-14-sprint-5-medication-tracking.md](sprints/2025-01-14-sprint-5-medication-tracking.md)
- **Features:** 5 features scheduled
- **Implementation Plans:**
  - [FEAT-001: Medication database schema](2025-01-14-feat-001-medication-schema.md)
  - [FEAT-002: Medication UI components](2025-01-14-feat-002-medication-ui.md)

### Sprint 4: Document Export
- **Status:** completed
- **Created:** 2025-01-10
- **Completed:** 2025-01-13
- **Goal:** Enable PDF export of health documents
- **Sprint Document:** [docs/plans/sprints/2025-01-10-sprint-4-document-export.md](sprints/2025-01-10-sprint-4-document-export.md)
- **Features:** 3 features completed
```

**Auto-Update Behavior:**
- When `scheduling-features` creates a new sprint → Add to top of "Sprints" section
- When sprint status changes (planned → in-progress → completed) → Update status and add completion date
- When features in sprint get implementation plans → Add links to "Implementation Plans" section
- Sprints listed in reverse chronological order (newest first)

## Complete Workflow Example

### Scenario: User notices missing feature during iPad testing

1. **Report Feature**
   ```
   User: "Report a feature request"
   → reporting-features skill runs
   → Interactive prompts gather info
   → FEAT-005 created with status="proposed"
   → Committed to features.yaml
   ```

2. **Triage Feature**
   ```
   User: "Triage features"
   → triaging-features skill runs
   → Shows FEAT-005 among other proposed features
   → User approves, assigns to "Epic 4"
   → FEAT-005 updated to status="approved"
   → Committed
   ```

3. **Schedule Feature**
   ```
   User: "Schedule features"
   → scheduling-features skill runs
   → User creates "Sprint 6: User Settings"
   → Selects FEAT-005 and other approved features
   → Sprint document created at docs/plans/sprints/2025-01-14-sprint-6-user-settings.md
   → ROADMAP.md updated with new sprint entry
   → FEAT-005 updated to status="scheduled", sprint_id="sprint-6"
   ```

4. **Plan Implementation** (optional)
   ```
   → User chooses "Yes" to implementation planning
   → For FEAT-005: superpowers:brainstorming runs
   → Design refined and validated
   → superpowers:writing-plans creates detailed plan
   → Plan saved to docs/plans/2025-01-14-feat-005-settings-screen.md
   → FEAT-005.implementation_plan updated with path
   → ROADMAP.md updated with link to implementation plan
   ```

5. **Execute** (optional)
   ```
   → User chooses "Execute now with subagent-driven-development"
   → Subagents dispatched for independent tasks
   → Code review between tasks
   → FEAT-005 status: "in-progress" → "completed"
   → Tests passing, changes committed
   ```

## Files Modified by Skills

### reporting-features
- features.yaml (new entry, increment nextId)
- docs/features/index.yaml (add to index)
- Git commit

### triaging-features
- features.yaml (update status, priority, epic, rejection_reason)
- docs/features/index.yaml (update index)
- Git commit

### scheduling-features
- features.yaml (update status, sprint_id, implementation_plan)
- docs/features/index.yaml (update index)
- docs/plans/sprints/YYYY-MM-DD-sprint-N.md (create or update)
- docs/plans/ROADMAP.md (auto-update with sprint info)
- docs/plans/YYYY-MM-DD-feat-XXX-[slug].md (if planning enabled)
- Git commit

## Success Criteria

### reporting-features
✅ User can report feature in ~2 minutes
✅ All required fields captured
✅ Feature stored in features.yaml with auto-incremented ID
✅ Index updated for fast querying
✅ Similar features detected before creating duplicate
✅ Clear next steps displayed to user

### triaging-features
✅ Batch review of multiple features
✅ Smart filtering by category/priority
✅ Approve, reject, or reprioritize in one session
✅ Optional epic assignment
✅ Clear summary of changes

### scheduling-features
✅ Create new sprints or add to existing
✅ Sprint documents auto-generated
✅ Features linked to sprints
✅ Optional implementation planning with superpowers
✅ Optional execution with superpowers workflows
✅ Complete flow: report → triage → schedule → plan → execute

## Integration with Existing Systems

### Similar to Bug Workflow
- Same YAML storage pattern
- Same index structure
- Same ID generation (FEAT- vs BUG-)
- Same interactive prompting style
- Same git commit conventions

### Extends Bug Workflow
- Sprint scheduling capability
- Superpowers workflow integration
- Implementation plan linking
- Execution modes (subagent-driven, executing-plans)

### Compatibility
- Does not conflict with existing bug system
- Can reference bugs from features (e.g., "Fixes BUG-012")
- Can link features to epics in sprint roadmap
- Integrates with existing docs/plans/ structure

## Implementation Notes

### Skill Creation Order
1. reporting-features (foundation)
2. triaging-features (depends on features.yaml structure)
3. scheduling-features (depends on approved features, integrates superpowers)

### Testing Strategy
- Test each skill independently first
- Test complete workflow: report → triage → schedule
- Test edge cases: duplicates, empty lists, concurrent modifications
- Test superpowers integration: brainstorming → planning → execution

### Migration Path
- No existing features to migrate (greenfield)
- Create features.yaml and docs/features/index.yaml when first feature reported
- Create docs/plans/sprints/ directory when first sprint created
