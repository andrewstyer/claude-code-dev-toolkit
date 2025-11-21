# Feature Management Extension

**Complete feature request workflow: capture → triage → schedule → implement → complete**

Version: 1.1
Last Updated: 2025-11-21
Based on: Health Narrative 2 feature request system (real-world usage)

---

## Overview

Seven-skill system for managing features and bugs from idea to implementation:

| Skill | Description | Time (Interactive / Autonomous) |
|-------|-------------|--------------------------------|
| **triaging-bugs** | Triage reported bugs (interactive + autonomous) | ~1-2 min/bug / ~5-10 sec/bug |
| **triaging-features** | Triage proposed features (interactive + autonomous) | ~1-2 min/feature / ~5-10 sec/feature |
| **scheduling-work-items** | Schedule bugs + features into sprints (interactive + autonomous) | ~5-10 min / ~2-3 min |
| **scheduling-features** | Schedule features-only sprints (interactive + autonomous) | ~5-10 min / ~2-3 min |
| **scheduling-implementation-plan** | Schedule plans to sprints (interactive + autonomous) | ~2-7 min / ~1-2 min |
| **fixing-bugs** | Fix bugs with auto-selection (interactive + autonomous) | ~30-60 min (same for both) |
| **completing-sprints** | Complete sprints systematically (interactive + autonomous) | ~5-10 min / ~2-3 min |

**Design goals:**
- Lightweight YAML storage (features.yaml + bugs.yaml)
- Minimal overhead during capture
- Batch operations for efficiency
- Optional integration with superpowers for full lifecycle
- Auto-generated roadmap
- Bridge standalone implementation plans into sprint system
- Unified sprint planning across bugs and features

---

## When to Use This Extension

✅ **Use if:**
- You're planning features across multiple sprints
- You want structured feature request capture
- You need sprint planning with roadmap tracking
- You're using superpowers workflow and want integration
- You have more features than you can implement immediately

❌ **Skip if:**
- Single-feature projects (no backlog needed)
- All features implemented immediately (no triage/scheduling needed)
- Ad-hoc development without sprint structure

---

## Quick Start

### 1. Installation

**Copy skills to your project:**
```bash
# From dev-toolkit root
cp -r extensions/feature-management/skills/* .claude/skills/

# OR if using skills-extensions approach
cp -r extensions/feature-management/skills/reporting-features ~/.config/claude/skills/
cp -r extensions/feature-management/skills/triaging-features ~/.config/claude/skills/
cp -r extensions/feature-management/skills/scheduling-features ~/.config/claude/skills/
```

**Initialize project structure:**
```bash
# Will be created automatically on first use, but you can pre-create:
mkdir -p docs/features docs/plans/{sprints,features}
touch features.yaml ROADMAP.md
```

### 2. Workflow

**Step 1: Capture feature requests**
```
User: "report a feature"
Claude Code: [Uses reporting-features skill]
- Interactive prompts for title, description, category, priority, etc.
- Creates FEAT-001 in features.yaml with status="proposed"
- Duplicate detection prevents redundant entries
```

**Step 2: Triage and approve**
```
User: "triage features"
Claude Code: [Uses triaging-features skill]
- Shows all proposed features
- Batch selection and filtering (by category/priority/date)
- Approve, reject, reprioritize, or assign to epics
- Updates status to "approved" or "rejected"
```

**Step 3: Schedule into sprints**
```
User: "schedule features"
Claude Code: [Uses scheduling-features skill]
- Shows all approved features
- Create new sprint or add to existing
- Optional: Create implementation plans (superpowers integration)
- Optional: Execute features immediately
- Updates status to "scheduled" or "in-progress"
- Auto-generates ROADMAP.md
```

---

## Skills Reference

### reporting-features

**Purpose:** Interactive feature request capture

**Usage:**
- User says: "report a feature" or "feature request"
- During manual testing when user suggests improvements
- Anytime user describes desired functionality

**What it does:**
1. Prompts for: title, description, category, user value, priority, context
2. Detects potential duplicates (fuzzy matching)
3. Generates auto-incrementing ID (FEAT-001, FEAT-002, etc.)
4. Stores in features.yaml with status="proposed"
5. Updates docs/features/index.yaml for fast querying
6. Git commit with feature details

**Output:**
- features.yaml entry with status="proposed"
- docs/features/index.yaml updated
- Git commit

**Time:** ~2 minutes per feature

**See:** [skills/reporting-features/SKILL.md](skills/reporting-features/SKILL.md)

---

### triaging-features

**Purpose:** Batch review and prioritization of proposed features

**Usage:**
- User says: "triage features" or "review features"
- After one or more features have been reported
- Before sprint planning (ensure features are approved)
- Weekly/biweekly triage sessions

**What it does:**
1. Lists all features with status="proposed"
2. Optional filtering (by category, priority, recent only)
3. Batch selection of features to review
4. For each feature: approve, reject, reprioritize, assign to epic, or skip
5. Updates features.yaml with new statuses
6. Git commit with triage changelog

**Output:**
- Updated features.yaml (approved/rejected/reprioritized)
- docs/features/index.yaml updated
- Git commit with summary

**Time:** ~1-2 minutes per feature

**See:** [skills/triaging-features/SKILL.md](skills/triaging-features/SKILL.md)

---

### scheduling-features

**Purpose:** Schedule approved features into sprints with optional implementation planning

**Usage:**
- User says: "schedule features" or "plan sprint"
- After features have been approved
- At start of new sprint cycle
- When ready to execute approved features

**What it does:**
1. Lists all features with status="approved"
2. Optional filtering (by priority, epic, category)
3. Create new sprint or add to existing sprint
4. Optional: Run superpowers:brainstorming for each feature
5. Optional: Run superpowers:writing-plans to create implementation plans
6. Optional: Execute features immediately (superpowers:executing-plans or subagent-driven-development)
7. Updates features.yaml with sprint_id and status="scheduled" (or "in-progress")
8. Creates/updates sprint document in docs/plans/sprints/
9. Auto-generates ROADMAP.md
10. Git commit

**Output:**
- Updated features.yaml (scheduled/in-progress)
- docs/plans/sprints/SPRINT-XXX-[name].md (sprint document)
- docs/plans/features/FEAT-XXX-implementation-plan.md (optional)
- ROADMAP.md (auto-generated)
- Git commit

**Time:**
- Basic scheduling: ~1-2 minutes per feature
- With planning: ~5-10 minutes per feature
- With execution: ~30-60+ minutes per feature (depends on complexity)

**See:** [skills/scheduling-features/SKILL.md](skills/scheduling-features/SKILL.md)

---

### scheduling-implementation-plan

**Purpose:** Convert existing implementation plans into sprint tasks and update roadmap

**Usage:**
- After creating implementation plan with superpowers:writing-plans (outside feature workflow)
- When you have implementation plans that need sprint scheduling
- When you want to break a large plan into multiple sprints
- To bridge standalone plans into the feature-management system

**What it does:**
1. Lists all implementation plans in docs/plans/
2. User selects which plan to schedule
3. Parses tasks, dependencies, and estimates from plan
4. Asks: Create single sprint, multiple sprints, or add to existing sprint?
5. Breaks tasks into sprint-sized chunks (if multiple sprints)
6. Updates ROADMAP.md with task-level detail and dependencies
7. Creates/updates sprint documents in docs/plans/sprints/
8. Links implementation plan to sprints (adds metadata to plan)
9. If FEAT-XXX plan: Updates features.yaml with sprint_id and status="scheduled"
10. Git commit

**Output:**
- ROADMAP.md (updated with tasks from plan)
- docs/plans/sprints/SPRINT-XXX-[name].md (sprint documents with task detail)
- Implementation plan updated with sprint metadata
- features.yaml updated (if FEAT-XXX plan)
- Git commit

**Time:**
- Single sprint: ~2-3 minutes
- Multiple sprints: ~5-7 minutes
- Depends on plan complexity

**Difference from scheduling-features:**
- scheduling-features: Works with feature requests (features.yaml), creates plans optionally
- scheduling-implementation-plan: Works with existing plans, converts to sprint tasks
- Use this when you already have an implementation plan created outside the feature workflow

**See:** [skills/scheduling-implementation-plan/SKILL.md](skills/scheduling-implementation-plan/SKILL.md)

---

### scheduling-work-items

**Purpose:** Unified sprint planning with both bugs AND features

**Usage:**
- Planning new sprint with bugs and features together
- Want to prioritize across bugs vs features (e.g., "P0 bug vs Must-Have feature?")
- Need unified view of all schedulable work
- Capacity planning for sprint ("We can do 10 items total")
- After triaging bugs (via triaging-bugs) and features (via triaging-features)

**What it does:**
1. Reads both bugs.yaml (status="triaged") and features.yaml (status="approved")
2. Displays unified view of all schedulable work items
3. Optional filtering (bugs only, features only, high priority only, by category)
4. Create new sprint or add to existing sprint
5. User selects which bugs and features to schedule
6. Capacity check (shows total items before committing)
7. Optional: Create implementation plans for features (not bugs)
8. Updates bugs.yaml with sprint_id and status="scheduled"
9. Updates features.yaml with sprint_id and status="scheduled"
10. Creates/updates sprint document with bugs and features sections
11. Updates ROADMAP.md with unified view (bugs + features together)
12. Git commit

**Output:**
- bugs.yaml updated (triaged → scheduled) + sprint_id
- features.yaml updated (approved → scheduled) + sprint_id
- docs/plans/sprints/SPRINT-XXX-[name].md (sprint document with bugs and features)
- ROADMAP.md (unified bugs + features view)
- Index files updated
- Git commit

**Time:**
- Basic scheduling: ~3-5 minutes per sprint
- With implementation planning: +5-10 minutes per feature

**Difference from other scheduling skills:**
- scheduling-features: Features only, creates feature-only sprints
- scheduling-work-items: Bugs + features, unified prioritization and capacity planning
- triaging-bugs "Assign to Sprint": Quick bug-only assignment during triage
- Use this when you want to plan a sprint with BOTH bugs and features

**See:** [skills/scheduling-work-items/SKILL.md](skills/scheduling-work-items/SKILL.md)

---

### completing-sprints

**Purpose:** Systematic sprint completion with retrospectives and data consistency validation

**Usage:**
- User says: "complete sprint" or "end sprint"
- At end of sprint cycle
- When reviewing sprint progress
- Both interactive and autonomous modes supported

**What it does:**

**Interactive Mode (~5-10 minutes per sprint):**
1. Lists all active/planned sprints
2. User selects sprint to complete
3. Displays all work items (bugs + features)
4. User marks bugs as resolved/unresolved
5. User marks features as completed/partial/incomplete
6. For incomplete items: asks how to handle (backlog/next sprint/keep)
7. Sets completion type (successful/partial/pivoted)
8. Optional: Generate retrospective with stats and notes
9. Updates all files (bugs.yaml, features.yaml, sprint docs, ROADMAP.md)
10. Runs validation script to ensure consistency
11. Git commit with detailed changelog

**Autonomous Mode (~2-3 minutes per sprint):**
1. Auto-selects oldest active sprint
2. Auto-detects completion from:
   - bugs.yaml/features.yaml status fields
   - ROADMAP.md checkboxes
   - Sprint document checkboxes
   - Implementation plan task completion
   - Git commit history
3. Auto-determines completion type (≥80% = successful, 50-79% = partial, <50% = pivoted)
4. Auto-handles incomplete items (high-priority → next sprint, others → backlog)
5. Auto-generates retrospective with stats only
6. Updates files, validates, commits

**Output:**
- bugs.yaml updated (resolved bugs keep sprint_id, incomplete bugs handled per disposition)
- features.yaml updated (completed features keep sprint_id, partial completion tracked)
- docs/plans/sprints/SPRINT-XXX-[name].md (status: completed, duration, completion type)
- docs/plans/sprints/retrospectives/SPRINT-XXX-retrospective.md (optional)
- docs/plans/sprints/SPRINT-YYY-[name].md (updated if items moved to next sprint)
- ROADMAP.md (sprint moved to completed section)
- Index files updated
- Git commit with statistics

**Incomplete Item Handling:**
- **Return to backlog:** Remove sprint_id, reset status to triaged/approved
- **Move to next sprint:** Update sprint_id, append to next sprint document
- **Keep in current sprint:** Leave sprint_id for historical reference

**Validation Script:**
- `scripts/validate-sprint-data.sh` - Ensures data consistency
- Validates sprint docs ↔ YAML ↔ ROADMAP.md consistency
- Checks status lifecycle validity
- Catches orphaned references
- Verifies completion integrity
- Runs before commit in completing-sprints workflow

**Time:**
- Interactive mode: ~5-10 minutes per sprint
- Autonomous mode: ~2-3 minutes per sprint
- Includes validation and git commit

**Difference from other skills:**
- scheduling-work-items: Creates sprints → completing-sprints: Ends sprints
- Works with sprints created by any scheduling skill
- Handles both unified (bugs + features) and feature-only sprints

**See:** [skills/completing-sprints/SKILL.md](skills/completing-sprints/SKILL.md)

---

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

---

## Integration with Superpowers

**scheduling-features integrates with superpowers workflow:**

### Full Lifecycle Example

```
User: "schedule features"

Claude Code:
1. Shows approved features
2. User selects FEAT-001, FEAT-003
3. Creates SPRINT-005
4. Asks: "Create implementation plans?" → User: "Yes"

For FEAT-001:
  5. Runs superpowers:brainstorming
     - Socratic refinement of feature requirements
     - Validates design choices

  6. Runs superpowers:writing-plans
     - Creates detailed implementation plan
     - Generates bite-sized tasks
     - Saves to docs/plans/features/FEAT-001-implementation-plan.md

  7. Asks: "Execute now?" → User: "Yes, batched execution"

  8. Runs superpowers:executing-plans
     - Executes tasks in batches with review checkpoints
     - Updates feature status to "in-progress"

[Repeat for FEAT-003]

9. Updates ROADMAP.md with sprint progress
10. Git commit
```

### Flexible Workflows

**Option 1: Schedule only (no planning)**
- Quick sprint creation
- Plan implementation later

**Option 2: Schedule + plan (defer execution)**
- Create implementation plans during sprint planning
- Execute features as capacity allows

**Option 3: Schedule + plan + execute**
- Full lifecycle in one session
- Best for small features or focused sprints

**Option 4: Bridge standalone plans (NEW)**
- Create plan with superpowers:writing-plans first
- Then use scheduling-implementation-plan to convert to sprints
- Useful when plan creation is separate from sprint planning

### Bridging Standalone Plans Example

```
User: "Create implementation plan for authentication refactor"

Claude Code:
1. Runs superpowers:brainstorming
   - Refines authentication requirements
   - Validates security approach

2. Runs superpowers:writing-plans
   - Creates docs/plans/authentication-refactor-plan.md
   - 15 detailed tasks with verification steps

User: "Schedule that plan into sprints"

Claude Code: [Uses scheduling-implementation-plan skill]
3. Lists available plans, user selects authentication-refactor-plan.md
4. Parses 15 tasks with dependencies
5. Suggests breakdown:
   - Sprint 1: Core changes (Tasks 1-5)
   - Sprint 2: Integration (Tasks 6-10)
   - Sprint 3: Testing & rollout (Tasks 11-15)
6. User approves breakdown
7. Updates ROADMAP.md with all 15 tasks
8. Creates 3 sprint documents
9. Links plan to sprints (adds metadata)
10. Git commit

Result:
- 3 sprints created with task-level detail
- ROADMAP.md shows all tasks with dependencies
- Implementation plan linked to sprints
- Ready to execute with superpowers:executing-plans
```

---

## File Structure

```
project-root/
├── features.yaml                           # All feature requests
├── ROADMAP.md                              # Auto-generated roadmap
└── docs/
    ├── features/
    │   └── index.yaml                      # Fast lookup index
    └── plans/
        ├── sprints/
        │   ├── SPRINT-001-core-features.md
        │   └── SPRINT-002-ux-polish.md
        └── features/
            ├── FEAT-001-implementation-plan.md
            └── FEAT-003-implementation-plan.md
```

---

## Data Schema

### features.yaml

```yaml
nextId: 5  # Auto-incremented ID counter

features:
  - id: FEAT-001
    title: "Add medication tracking"
    description: "Allow users to track medications with dosage and schedule"
    category: new-functionality  # new-functionality | ux-improvement | performance | platform-specific
    user_value: "Helps users manage complex medication regimens"
    priority: must-have  # must-have | nice-to-have | future
    status: scheduled  # proposed | approved | rejected | scheduled | in-progress | completed
    sprint_id: SPRINT-001  # Optional, added during scheduling
    implementation_plan: docs/plans/features/FEAT-001-implementation-plan.md  # Optional
    epic: "Epic 3: Medication Management"  # Optional, added during triage
    created_at: "2025-01-14T10:30:00Z"
    scheduled_at: "2025-01-20T14:15:00Z"  # Added during scheduling
    updated_at: "2025-01-20T14:15:00Z"
    context: "Requested during iPad testing"  # Optional

  - id: FEAT-002
    title: "Export health summary as PDF"
    description: "Generate PDF reports of health data"
    category: new-functionality
    user_value: "Allows users to share data with doctors"
    priority: nice-to-have
    status: approved
    created_at: "2025-01-15T11:20:00Z"
    updated_at: "2025-01-16T09:45:00Z"
```

### Status Lifecycle

```
proposed → approved → scheduled → in-progress → completed
         ↓
      rejected
```

**Status definitions:**
- **proposed**: Feature captured, awaiting triage
- **approved**: Triaged and approved, ready for scheduling
- **rejected**: Reviewed and declined (with rejection_reason)
- **scheduled**: Assigned to sprint, not yet started
- **in-progress**: Implementation in progress
- **completed**: Feature implemented and shipped

---

## Common Workflows

### Workflow 1: Weekly Triage Cadence

**Monday morning:**
```
User: "triage features"
Claude Code:
- Shows all proposed features from last week
- User approves Must-Have features
- User rejects out-of-scope features
- User assigns features to epics
```

**Result:** Clean backlog of approved features ready for sprint planning

---

### Workflow 2: Sprint Planning Session

**Start of 2-week sprint:**
```
User: "schedule features"
Claude Code:
- Filter by priority="must-have"
- Select 5-7 features for sprint
- Create SPRINT-005: "Core Features Sprint"
- Choose "Yes, create plans"
- For each feature: brainstorm → write plan
- Choose "No, plan only" (defer execution)
```

**Result:** Sprint document with implementation plans ready, execute features throughout sprint

---

### Workflow 3: Quick Feature Implementation

**Single feature from idea to execution:**
```
User: "report a feature"
Claude Code: [Creates FEAT-015]

User: "triage features"
Claude Code: [Approves FEAT-015]

User: "schedule features"
Claude Code:
- Add to existing sprint (SPRINT-005)
- Choose "Yes, create plans"
- Choose "Yes, execute now" → "Subagent-Driven"
- Feature completed
```

**Result:** Feature goes from idea to in-progress in single session

---

### Workflow 4: Sprint Completion

**End of 2-week sprint:**
```
User: "complete sprint"
Claude Code: [Uses completing-sprints skill]
- Shows all active sprints
- User selects SPRINT-005

Claude Code:
- Displays 7 work items (5 features, 2 bugs)
- Shows current status from bugs.yaml/features.yaml

User: [Marks completion]
- Features: 3 completed, 1 partial (75%), 1 incomplete
- Bugs: 1 resolved, 1 unresolved

Claude Code: "How should incomplete items be handled?"
User: "Move to next sprint"

Claude Code:
- Creates SPRINT-006 document
- Moves 2 incomplete items to SPRINT-006
- Calculates stats (57% completion rate)
- Sets completion type: "partial"

User: "Create retrospective with notes"

Claude Code: [Prompts for retrospective notes]
- What went well?
- What didn't go well?
- Action items for next sprint?

User: [Provides notes]

Claude Code:
- Updates bugs.yaml (1 resolved, 1 moved to SPRINT-006)
- Updates features.yaml (3 completed, 1 partial moved, 1 moved)
- Updates SPRINT-005 document (status: completed)
- Creates SPRINT-006 document (2 items from SPRINT-005)
- Generates retrospective: docs/plans/sprints/retrospectives/SPRINT-005-retrospective.md
- Updates ROADMAP.md (SPRINT-005 → completed, SPRINT-006 → active)
- Runs validation script (all checks pass ✓)
- Git commit with detailed changelog
```

**Result:**
- Sprint properly closed with statistics
- Retrospective created for learning
- Incomplete work tracked to next sprint
- All files consistent (validated)
- Clear record of what was accomplished

---

## Tips and Best Practices

### Feature Capture

**Do:**
- Capture features immediately when ideas arise
- Include context (where/when idea came from)
- Be specific about user value

**Don't:**
- Overthink during capture (triage later)
- Skip duplicate detection confirmation
- Batch up features mentally (capture as you go)

### Triage

**Do:**
- Batch review multiple features in one session
- Use filtering to focus (e.g., Must-Have only)
- Assign features to epics for organization
- Document rejection reasons

**Don't:**
- Feel pressure to approve everything
- Triage alone if team project (get input)
- Let proposed features pile up (weekly cadence)

### Scheduling

**Do:**
- Create realistic sprints (don't overcommit)
- Use implementation planning for complex features
- Update sprint documents as features progress
- Review ROADMAP.md regularly

**Don't:**
- Schedule features without approval first
- Create implementation plans if requirements unclear (brainstorm first)
- Forget to update feature status as work progresses

---

## Metrics and Success Indicators

**From Health Narrative 2 real-world usage:**

**Feature capture:**
- ~2 min per feature (down from ~5 min manual process)
- 0 duplicate features created after adding duplicate detection
- 100% of feature requests captured (nothing lost in verbal discussion)

**Triage:**
- ~1-2 min per feature review
- Batch processing: 10 features in ~15 min
- Clear approval/rejection decisions with documented reasons

**Scheduling:**
- Sprint creation: ~5-10 min (including feature selection)
- With planning: ~5-10 min per feature for implementation plans
- ROADMAP.md always current (auto-generated)

---

## Troubleshooting

### Issue: features.yaml is getting large

**Symptom:** File is 1000+ lines, slow to read

**Solution:**
1. Archive completed features (older than 6 months)
2. Archive rejected features (older than 3 months)
3. Create archive/features/ directory
4. Move old features to archive/features/YYYY-MM.yaml

**Prevention:** Run archival monthly

---

### Issue: Duplicate features despite detection

**Symptom:** Similar features with different IDs

**Solution:**
1. During triage, reject duplicates with reason: "Duplicate of FEAT-XXX"
2. Update original feature if needed
3. Improve feature titles to be more distinct

**Prevention:** Use clear, descriptive titles during capture

---

### Issue: Sprint documents out of sync with features.yaml

**Symptom:** Sprint document shows wrong status

**Solution:**
1. Sprint documents are generated, don't edit manually
2. Update features.yaml with correct status
3. Re-run scheduling-features to regenerate sprint document

**Prevention:** Always update features.yaml, regenerate sprint docs

---

### Issue: ROADMAP.md not updating

**Symptom:** Roadmap shows old sprint status

**Solution:**
1. ROADMAP.md is auto-generated by scheduling-features
2. Run "schedule features" → "View Sprint Status" to regenerate

**Prevention:** ROADMAP.md is not manually edited, always regenerate

---

## Advanced Usage

### Epic-Based Organization

**During triage:**
```
User: "triage features"
Claude Code:
- For each approved feature, choose "Assign to Epic"
- Enter epic name: "Epic 3: Medication Management"
```

**During scheduling:**
```
User: "schedule features"
Claude Code:
- Filter by epic: "Epic 3: Medication Management"
- Schedule entire epic into one sprint
```

**Benefit:** Group related features, schedule by theme

---

### Multi-Sprint Planning

**Create multiple sprints in one session:**
```
User: "schedule features"
Claude Code:
- Filter by priority="must-have"
- Create SPRINT-005 with 5 features
- Choose "No, schedule only"

User: "schedule features"
Claude Code:
- Filter by priority="nice-to-have"
- Create SPRINT-006 with 3 features
- Choose "No, schedule only"
```

**Result:** Roadmap with multiple planned sprints

---

### Reschedule Features

**Move feature to different sprint:**
```
User: "schedule features"
Claude Code:
- Shows FEAT-015 already scheduled in SPRINT-005
- Asks: "Reschedule?"
- User: "Yes"
- Select new sprint: SPRINT-006
```

**Result:** Feature moved, sprint documents updated

---

## Testing

### Validation Testing

**Before deploying to your project:**

1. **Test capture:**
   ```
   - Create first feature (initializes features.yaml)
   - Create second feature (tests ID increment)
   - Create duplicate (tests duplicate detection)
   ```

2. **Test triage:**
   ```
   - Approve multiple features
   - Reject one feature with reason
   - Reprioritize one feature
   - Assign one feature to epic
   ```

3. **Test scheduling:**
   ```
   - Create new sprint with 2 features
   - Add feature to existing sprint
   - View sprint status
   ```

4. **Verify files:**
   ```bash
   cat features.yaml  # Check structure
   cat docs/features/index.yaml  # Verify index
   cat docs/plans/sprints/SPRINT-001-*.md  # Check sprint doc
   cat ROADMAP.md  # Verify roadmap
   ```

**See:** [TESTING.md](TESTING.md) for detailed test cases

---

## Customization

### Custom Categories

**Edit reporting-features/SKILL.md:**
```yaml
# Change category options (Phase 1, Step 3)
Options:
  - Label: "Backend"
    Description: "Server-side functionality"
  - Label: "Frontend"
    Description: "Client-side UI/UX"
  - Label: "DevOps"
    Description: "Infrastructure and deployment"
```

### Custom Priorities

**Edit all three skills:**
```yaml
# Change priority options
Options:
  - Label: "P0 - Critical"
  - Label: "P1 - High"
  - Label: "P2 - Medium"
  - Label: "P3 - Low"
```

### Custom Sprint Durations

**Edit scheduling-features/SKILL.md:**
```markdown
# Phase 4a, Step 1
Prompt: "Sprint duration?" (default: 1 week)  # Change default
```

---

## Design Documentation

**Full design docs available:**
- [DESIGN.md](DESIGN.md) - System architecture and design decisions
- [TESTING.md](TESTING.md) - Test cases and validation

**Based on:**
- Health Narrative 2 feature request system (real-world usage, 2+ weeks)
- /dev/healthnarrative2/healthnarrative/docs/plans/2025-11-14-feature-request-system-design.md

---

## Version History

**v1.0 (November 2025)**
- Initial release based on HN2 production system
- Three skills: reporting, triaging, scheduling
- Superpowers integration for full lifecycle
- Auto-generated roadmap

---

## Contributing

**Found a bug or have a suggestion?**
1. Add to features.yaml using reporting-features skill
2. Submit pull request to dev-toolkit repository

**Want to improve the skills?**
1. Test changes in your project first
2. Document changes in TESTING.md
3. Update this README with new workflows
4. Submit pull request

---

## License

Part of Claude Code Development Toolkit - see main repository for license

---

**Questions or issues?** See main dev-toolkit README or create an issue in the repository.
