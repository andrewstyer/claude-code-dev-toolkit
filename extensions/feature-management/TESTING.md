# Feature Request Skills - Test Results

**Tested:** 2025-01-14

## Test Cases

### TC1: reporting-features basic flow
- **Status:** NOT TESTED
- **Notes:** Manual testing required
- **Test steps:**
  1. Run: "report a feature"
  2. Verify skill announces usage
  3. Provide test data:
     - Title: "Test feature 1"
     - Description: "A test feature for validation"
     - Category: New Functionality
     - User Value: "Helps validate the system"
     - Priority: Nice-to-Have
     - Context: (skip)
  4. Verify FEAT-001 created in features.yaml
  5. Verify docs/features/index.yaml updated
  6. Verify git commit created
  7. Verify summary displayed with next steps

### TC2: triaging-features basic flow
- **Status:** NOT TESTED
- **Notes:** Requires TC1 to pass first
- **Test steps:**
  1. Run: "triage features"
  2. Verify FEAT-001 shown as proposed
  3. Select FEAT-001 for review
  4. Choose action: Approve
  5. Verify features.yaml updated (status = approved)
  6. Verify index.yaml updated
  7. Verify git commit created
  8. Verify summary displayed

### TC3: scheduling-features basic flow
- **Status:** NOT TESTED
- **Notes:** Requires TC2 to pass first
- **Test steps:**
  1. Run: "schedule features"
  2. Verify FEAT-001 shown as approved
  3. Choose: Create new sprint
  4. Provide sprint details:
     - Name: "Sprint 1: Test Sprint"
     - Goal: "Test the scheduling system"
  5. Select FEAT-001 for sprint
  6. Choose: No (skip planning)
  7. Verify sprint document created in docs/plans/sprints/
  8. Verify FEAT-001 status = scheduled, sprint_id set
  9. Verify ROADMAP.md updated with sprint entry
  10. Verify git commit created
  11. Verify summary displayed

### TC4: scheduling-features with planning
- **Status:** NOT TESTED
- **Notes:** Requires approved feature (can reuse or create new)
- **Test steps:**
  1. Create another test feature (FEAT-002) and approve it
  2. Run: "schedule features"
  3. Add FEAT-002 to existing sprint OR create new sprint
  4. Choose: Yes for implementation planning
  5. Verify brainstorming skill called
  6. Verify writing-plans skill called
  7. Verify implementation plan created in docs/plans/
  8. Verify feature.implementation_plan field set
  9. Verify sprint doc updated with plan link
  10. Verify ROADMAP.md updated with plan link
  11. Verify git commit created

### TC5: End-to-end workflow (report → triage → schedule)
- **Status:** NOT TESTED
- **Notes:** Full workflow test
- **Test steps:**
  1. Report new feature (FEAT-003)
  2. Verify proposed status
  3. Triage and approve FEAT-003
  4. Verify approved status
  5. Schedule FEAT-003 into sprint
  6. Verify scheduled status
  7. Verify complete workflow tracked in git history
  8. Verify all files (features.yaml, index.yaml, sprint doc, ROADMAP.md) consistent

### TC6: Duplicate detection
- **Status:** NOT TESTED
- **Notes:** Tests duplicate feature detection
- **Test steps:**
  1. Report feature with title "Add user settings"
  2. Verify created successfully
  3. Report another feature with title "User settings screen"
  4. Verify skill detects similar feature
  5. Verify AskUserQuestion offers to continue or cancel
  6. Test both paths (continue and cancel)

### TC7: Filtering in triaging
- **Status:** NOT TESTED
- **Notes:** Tests smart filtering
- **Test steps:**
  1. Create multiple proposed features with different categories/priorities
  2. Run triage with "By Category" filter
  3. Verify only matching category shown
  4. Run triage with "By Priority" filter
  5. Verify only matching priority shown
  6. Run triage with "Recent Only" filter
  7. Verify only recent features shown

### TC8: Epic assignment
- **Status:** NOT TESTED
- **Notes:** Tests epic linking during triage
- **Test steps:**
  1. Create proposed feature
  2. Triage feature
  3. Choose: Assign to Epic
  4. Provide epic name: "Epic 1: Test Epic"
  5. Verify feature.epic field set
  6. Verify git commit includes epic info

## Issues Found

_No issues found yet - testing not started_

## Sign-off

- **All tests passing:** NO - Testing not complete
- **Ready for use:** NO - Manual testing required

---

## Testing Instructions

To complete this checklist:
1. Run each test case in order (TC1-5 are sequential)
2. Update Status to PASS/FAIL
3. Add notes for any issues found
4. Document issues in "Issues Found" section
5. Update sign-off when all tests pass
