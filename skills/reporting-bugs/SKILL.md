---
name: reporting-bugs
description: Interactive bug capture during manual testing - prompts for details, creates E2E test, stores in bugs.yaml
---

# Reporting Bugs

## Overview

Capture bug reports during manual testing with structured prompting. Creates entry in bugs.yaml, optionally generates E2E test, integrates with TDD workflow.

**Announce at start:** "I'm using the reporting-bugs skill to capture this issue."

## When to Use

- User says: "report a bug" or "/report-bug"
- During manual device/iPad testing when issue discovered
- Anytime user notices unexpected behavior

## Process

### Phase 1: Gather Required Information

Ask for information ONE question at a time:

**1. Bug Title**
```
What's a short title for this bug? (one line summary)
```

**2. Observed Behavior**
```
What did you observe? (what went wrong)
```

**3. Expected Behavior**
```
What did you expect to happen?
```

**4. Steps to Reproduce**
```
What are the steps to reproduce this issue? (provide as numbered list)
```

**5. Severity (use AskUserQuestion)**
```
Use AskUserQuestion tool with these options:
Question: "What is the severity of this bug?"
Options:
  - P0: Critical (feature broken, blocks usage)
  - P1: High (major issue, workaround exists)
  - P2: Low (minor issue, cosmetic, nice-to-have)
```

### Phase 2: Gather Optional Information

**6. Device/Environment**
```
(Optional) Device or environment info? (e.g., "iPad Pro 11-inch, iOS 17.5")
Press Enter to skip.
```

**7. Screenshots/Logs**
```
(Optional) Any screenshots or log file paths?
Press Enter to skip.
```

**8. Suggested Fix**
```
(Optional) Do you have any thoughts on how to fix this?
Press Enter to skip.
```

### Phase 3: E2E Test Generation

**9. Ask about E2E test (use AskUserQuestion)**
```
Use AskUserQuestion tool:
Question: "Generate failing E2E test now? (Recommended for TDD workflow)"
Options:
  - Yes: Generate Maestro test that reproduces the bug (RED phase)
  - No: Skip test generation, can add later manually
```

If Yes:
- Use logic from `lib/e2e-test-generation.md`
- Parse steps to reproduce
- Generate `.maestro/flows/bugs/BUG-XXX-<slug>.yaml`
- Add file path to bug.e2e_test field
- Display: "E2E test created at: <path>"

### Phase 4: Validation and Storage

**10. Validate bug data**

Use validation logic from `lib/bug-validation.md`:
```typescript
const validation = validateBugData({
  title,
  observed,
  expected,
  steps,
  severity,
  device,  // optional
  screenshots,  // optional
  suggested_fix  // optional
});

if (!validation.valid) {
  Display errors and ask user to correct
  Return to gathering phase
}
```

**11. Check for duplicate bugs**

```typescript
// Read existing bugs
const {bugs} = readBugs();

// Search for similar titles
const similar = searchSimilarBugs(title, bugs);

if (similar.length > 0) {
  Display: "Similar bug(s) found:"
  for each similar bug:
    Display: "- ${bug.id}: ${bug.title} (${bug.severity})"

  Use AskUserQuestion:
  Question: "A similar bug exists. Report this as a new bug anyway?"
  Options:
    - Yes: Report as new bug
    - No: Cancel, user will check existing bug

  If No: Exit skill
}
```

**12. Save bug to bugs.yaml**

```typescript
// Read current bugs.yaml (or create if doesn't exist)
const data = readBugs();  // {nextId: N, bugs: [...]}

// Create bug object
const bug = {
  id: `BUG-${String(data.nextId).padStart(3, '0')}`,
  title,
  status: 'reported',
  severity,
  observed,
  expected,
  steps,
  device: device || undefined,
  screenshots: screenshots || undefined,
  suggested_fix: suggested_fix || undefined,
  created_at: new Date().toISOString(),
  e2e_test: e2eTestPath || undefined  // If test was generated
};

// Add to bugs array
data.bugs.push(bug);

// Increment nextId
data.nextId++;

// Write back to bugs.yaml
writeBugs(data);
```

**13. Update index.yaml**

```typescript
// Read docs/bugs/index.yaml (create if doesn't exist)
const index = readIndex();  // {bugs: [...]}

// Add bug to index
index.bugs.push({
  id: bug.id,
  title: bug.title,
  status: bug.status,
  severity: bug.severity,
  created_at: bug.created_at,
  file: 'bugs.yaml'
});

// Sort by created_at DESC (newest first)
index.bugs.sort((a, b) =>
  new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
);

// Write back
writeIndex(index);
```

**14. Commit bug report**

```bash
git add bugs.yaml docs/bugs/index.yaml
# If E2E test generated:
git add .maestro/flows/bugs/${BUG_ID}-*.yaml

git commit -m "bug: report ${BUG_ID} - ${title}

Severity: ${severity}
Status: reported

${observed}

Steps to reproduce:
${steps.map((s, i) => `${i+1}. ${s}`).join('\n')}

${e2eTestPath ? 'E2E test: ' + e2eTestPath : 'No E2E test generated'}"
```

### Phase 5: Display Summary

```
✅ Bug reported: ${BUG_ID}

Title: ${title}
Severity: ${severity} (${severityLabel})
Status: reported
${device ? 'Device: ' + device : ''}
${e2eTestPath ? 'E2E Test: ' + e2eTestPath : ''}

Next steps:
- Bug is now tracked in bugs.yaml
- Use /triage-bugs to prioritize and plan fixes
- Or say "fix ${BUG_ID}" to start fixing immediately
```

## Error Handling

### Concurrent Modification

If bugs.yaml modified during reporting:
```typescript
try {
  writeBugs(data);
} catch (error) {
  if (error.message.includes('nextId changed')) {
    // Re-read bugs.yaml
    const freshData = readBugs();
    // Use fresh nextId
    bug.id = `BUG-${String(freshData.nextId).padStart(3, '0')}`;
    freshData.bugs.push(bug);
    freshData.nextId++;
    writeBugs(freshData);
  } else {
    throw error;
  }
}
```

### Missing Files

If bugs.yaml doesn't exist:
```typescript
function readBugs() {
  if (!fileExists('bugs.yaml')) {
    return {nextId: 1, bugs: []};
  }
  // ...parse existing file
}
```

### E2E Test Generation Failure

If E2E test generation fails or produces unclear results:
```
⚠️  E2E test generated but may need manual editing.

Review test at: ${testPath}

Steps that need attention:
- Step 3: Could not parse navigation target
- Step 5: Generic assertion added - specify expected text

Please edit test to add specific selectors and assertions.
```

## Integration Points

- **triaging-bugs skill:** Reads bugs from bugs.yaml
- **fixing-bugs skill:** Updates bug status when fixing
- **TDD workflow:** E2E test = RED phase of test-driven-development

## Files Modified

- `bugs.yaml` - Added new bug entry, incremented nextId
- `docs/bugs/index.yaml` - Added bug to index
- `.maestro/flows/bugs/BUG-XXX-*.yaml` - E2E test (if generated)

## Success Criteria

✅ User can report bug in ~2 minutes
✅ All required fields captured
✅ Bug stored in bugs.yaml with auto-incremented ID
✅ Index updated for fast querying
✅ E2E test generated (if requested)
✅ Similar bugs detected before creating duplicate
✅ Clear next steps displayed to user
