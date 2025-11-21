# Feature Management Extension - Examples

This directory contains example files demonstrating the complete feature management workflow, including sprint completion.

---

## Example Files

### Basic Examples (Original)

**features.yaml** - Example feature request file
- Shows features in various states (proposed, approved, scheduled, completed, rejected)
- Demonstrates feature metadata (category, priority, epic, status lifecycle)

**ROADMAP.md** - Example roadmap file
- Shows how features are organized into sprints
- Demonstrates sprint planning and progress tracking

**sprint-example.md** - Example sprint document
- Shows active sprint with features and work items
- Demonstrates sprint structure and progress tracking

### Sprint Completion Examples (NEW)

**sprint-completed-example.md** - Completed sprint document
- Shows SPRINT-001 after completion (status: completed)
- Demonstrates completion metadata: completed date, duration, completion type
- Shows work items with completion status:
  - Completed features (FEAT-003, FEAT-007) with checkboxes
  - Partial feature (FEAT-001 at 75%) moved to next sprint
  - Incomplete features returned to backlog
  - Resolved bug (BUG-001) with checkbox
  - Unresolved bug (BUG-003) moved to next sprint
- Links to retrospective document
- Last updated timestamp

**sprint-retrospective-example.md** - Sprint retrospective
- Comprehensive retrospective for SPRINT-001
- Statistics section:
  - Completion summary with percentages
  - Velocity metrics (items/day)
  - Disposition of incomplete items
- Completed work section with details
- Incomplete work section with reasons and next steps
- Retrospective notes:
  - What went well (velocity, bug resolution, quality)
  - What didn't go well (scope estimation, device testing, planning)
  - Action items for next sprint (specific improvements)
- Created timestamp and link to sprint document

**bugs-completed-sprint-example.yaml** - Bugs with sprint completion data
- BUG-001: Resolved bug (status: resolved)
  - Keeps sprint_id for historical reference
  - Has resolved_at timestamp
  - Links to E2E test
- BUG-003: Bug moved to next sprint (status: in-progress)
  - Updated sprint_id to SPRINT-002
  - Has moved_from field tracking origin
  - Root cause documented
- BUG-002: Triaged bug not yet scheduled
  - Shows normal triaged bug for comparison

**features-completed-sprint-example.yaml** - Features with sprint completion data
- FEAT-003: Completed feature (status: completed)
  - Keeps sprint_id for historical reference
  - Has completed_at timestamp
- FEAT-007: Completed feature (status: completed)
  - Shows another completed feature
- FEAT-001: Partially completed feature (status: in-progress)
  - Has completion_percentage: 75
  - Updated sprint_id to SPRINT-002
  - Has moved_from field tracking origin
  - Notes explain remaining work
- FEAT-005: Feature returned to backlog (status: approved)
  - sprint_id removed (no longer in sprint)
  - Notes explain why returned to backlog
- FEAT-008: Feature returned to backlog (status: approved)
  - sprint_id removed
  - Notes explain deferral
- FEAT-002: Approved feature not yet scheduled
  - Shows normal approved feature for comparison
- FEAT-006: Proposed feature awaiting triage
  - Shows feature in early stage
- FEAT-004: Rejected feature
  - Shows rejection with reason documented

**ROADMAP-completed-sprint-example.md** - Roadmap with completed sprint
- Current Sprint: SPRINT-002 (active)
  - Shows items moved from SPRINT-001
  - Includes partial feature (75% complete) and bug
- Planned Sprints: SPRINT-003
  - Shows items returned to backlog being re-scheduled
- Completed Sprints: SPRINT-001
  - Shows completion metadata (date, duration, percentage)
  - Links to retrospective and sprint document
  - Summary of what was completed and what moved
  - Retrospective highlights (what went well, what to improve)
- Backlog section showing returned items
- Statistics section with velocity metrics
- Validation timestamp

---

## How These Examples Work Together

### Sprint Creation (Existing Examples)
1. features.yaml - Features are captured and triaged
2. scheduling-work-items creates sprint
3. sprint-example.md - Active sprint document
4. ROADMAP.md - Sprint appears in "Current Sprint"

### Sprint Completion (NEW Examples)
1. **During sprint:** Work progresses, statuses update in features.yaml/bugs.yaml
2. **End of sprint:** User invokes completing-sprints skill
3. **Sprint completion process:**
   - Marks completed: FEAT-003, FEAT-007, BUG-001
   - Marks partial: FEAT-001 (75%)
   - Handles incomplete: FEAT-005, FEAT-008 → backlog; FEAT-001, BUG-003 → SPRINT-002
4. **Files updated:**
   - bugs-completed-sprint-example.yaml - Shows updated bug statuses
   - features-completed-sprint-example.yaml - Shows updated feature statuses
   - sprint-completed-example.md - Sprint marked completed with metadata
   - sprint-retrospective-example.md - Generated retrospective
   - ROADMAP-completed-sprint-example.md - Sprint moved to "Completed Sprints"

### Data Consistency

All completion examples demonstrate:
- **Completed items keep sprint_id** for historical reference
- **Moved items have moved_from** field tracking origin
- **Partial features have completion_percentage** (0-100)
- **Returned items have sprint_id removed** (back to backlog)
- **Sprint documents show completion metadata** (date, duration, type)
- **Retrospectives provide learning** (stats + notes)
- **ROADMAP shows full history** (completed sprints section)

These examples would all pass validation with `scripts/validate-sprint-data.sh`:
- ✅ Sprint document ↔ YAML consistency (all work items exist)
- ✅ ROADMAP ↔ Sprint document consistency (statuses match)
- ✅ Status lifecycle valid (completed items follow proper transitions)
- ✅ Completion integrity (all metadata fields present)

---

## Using These Examples

**To understand sprint completion:**
1. Read sprint-example.md (active sprint before completion)
2. Read sprint-completed-example.md (same sprint after completion)
3. Compare the differences (status, metadata, item disposition)

**To understand retrospectives:**
1. Read sprint-retrospective-example.md
2. Note the structure: Statistics → Completed → Incomplete → Notes
3. See how action items drive next sprint improvements

**To understand data updates:**
1. Compare features.yaml (basic) vs features-completed-sprint-example.yaml
2. Note completed_at timestamps, completion_percentage, moved_from fields
3. See how sprint_id is handled differently for completed vs moved vs returned items

**To set up your own sprint completion:**
1. Use completing-sprints skill at end of sprint
2. Follow interactive prompts to mark completion
3. Generate retrospective (with notes recommended)
4. Files will match these examples' structure
5. Run validate-sprint-data.sh to ensure consistency

---

## Key Concepts Demonstrated

**Completion Types:**
- **Successful** (≥80%): Most items completed (not shown in examples, use SPRINT-002 if 100% complete)
- **Partial** (50-79%): Some items completed (SPRINT-001 is 43%, close to partial)
- **Pivoted** (<50%): Sprint redirected (not shown, would need <50% completion)

**Incomplete Item Handling:**
- **Return to backlog**: Remove sprint_id, back to approved/triaged (FEAT-005, FEAT-008)
- **Move to next sprint**: Update sprint_id, add moved_from (FEAT-001, BUG-003)
- **Keep in current sprint**: Leave sprint_id for reference (not shown in examples)

**Partial Completion:**
- Features can be 0-100% complete (FEAT-001 at 75%)
- Bugs are binary (resolved or not)
- Partial features typically moved to next sprint to finish

**Retrospective Value:**
- **Statistics**: Quantify what was accomplished
- **Completed work**: Document successes for morale
- **Incomplete work**: Understand reasons, plan next steps
- **Retrospective notes**: Learn and improve process
- **Action items**: Concrete improvements for next sprint

**Data Validation:**
- Ensures all files stay consistent
- Catches orphaned references
- Verifies status transitions
- Confirms completion metadata
- Prevents data drift over time

---

## Files Relationship Diagram

```
features.yaml                    bugs.yaml
    ↓                                ↓
    └─────────┬──────────────────────┘
              ↓
    sprint-completed-example.md
    (references FEAT-XXX, BUG-XXX)
              ↓
    sprint-retrospective-example.md
    (stats from sprint document)
              ↓
    ROADMAP-completed-sprint-example.md
    (aggregates all sprint data)
              ↓
    validate-sprint-data.sh
    (ensures consistency)
```

---

**Questions?** See extensions/feature-management/README.md for full workflow documentation.
