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
