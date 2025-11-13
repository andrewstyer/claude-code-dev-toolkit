---
name: setup-testing-infrastructure
description: Use to set up comprehensive E2E testing infrastructure with quality gates - supports React Native, native mobile, and web projects with minimal user questions
---

# Testing Infrastructure Setup Skill

## Overview

Autonomously set up E2E testing infrastructure with quality gates for any project type.

**Announce at start:** "I'm using the setup-testing-infrastructure skill to set up your E2E testing workflow."

## When to Use This Skill

Use this skill when:
- User wants to add E2E testing to their project
- Project has no E2E tests but needs quality gates
- User mentions "testing infrastructure", "E2E tests", "Maestro", "Playwright", etc.
- During brainstorming when testing infrastructure is needed
- TDD skill detects missing E2E capability

## What This Skill Does

1. **Detects project type** (React Native, native mobile, web)
2. **Asks minimal questions** (2-4 via AskUserQuestion)
3. **Sets up everything autonomously**:
   - Installs E2E framework
   - Configures build automation
   - Adds quality gates
   - Creates sample tests
   - Generates documentation (4 files, 1,600-2,400 lines)
4. **Verifies setup works** by running tests
5. **Commits all changes** with clear git messages

## Supported Project Types

- **Path 1:** React Native + iOS (Maestro/Detox + Fastlane)
- **Path 2:** React Native + Cross-platform (iOS + Android)
- **Path 3:** Native mobile (Swift/Kotlin with XCUITest/Espresso)
- **Path 4:** Web applications (Playwright/Cypress/Puppeteer)

## Workflow

### Phase 1: Environment Detection (Autonomous)

Examine project files to determine type:

```bash
# Check for React Native
cat package.json | grep "react-native"

# Check for iOS
ls ios/*.xcodeproj ios/*.xcworkspace 2>/dev/null

# Check for Android
ls android/build.gradle 2>/dev/null

# Check for web
test -f package.json && ! grep -q "react-native" package.json
```

Show user:
```
🔍 Current setup detected:
- Project type: [React Native iOS / Web / etc.]
- Existing tests: [found/not found]
- Required tools: [installed/missing]
```

### Phase 2: Path Selection

Use `AskUserQuestion` to ask which path:

```
Question: "What type of project are you working with?"
Header: "Project Type"
multiSelect: false
Options:
  - Label: "React Native + iOS"
    Description: "React Native with Expo or bare workflow, iOS-only deployment. Sets up Maestro/Detox + Fastlane + quality gates."

  - Label: "React Native + Cross-platform"
    Description: "React Native with iOS and Android. Sets up Maestro/platform-specific + Fastlane + Gradle + quality gates."

  - Label: "Native mobile"
    Description: "Native iOS (Swift) or Android (Kotlin). Sets up XCUITest/Espresso/Maestro + build automation."

  - Label: "Web application"
    Description: "Web app (React, Vue, Angular, etc.). Sets up Playwright/Cypress + npm scripts + quality gates."
```

### Phase 3: Load and Execute Path

Based on user's answer, read and execute the appropriate path file:

```
If "React Native + iOS":
  Read paths/react-native-ios.md
  Execute those instructions exactly

If "React Native + Cross-platform":
  Read paths/react-native-cross-platform.md
  Execute those instructions exactly

If "Native mobile":
  Read paths/native-mobile.md
  Execute those instructions exactly

If "Web application":
  Read paths/web-e2e.md
  Execute those instructions exactly
```

### Phase 4: TodoWrite Tracking

Create todos for each phase:

```
- [ ] Phase 1: Environment detection
- [ ] Phase 2: Minimal questions (2-4 questions)
- [ ] Phase 3: Implementation (8 steps)
- [ ] Phase 4: Verification (4 checks)
- [ ] Phase 5: Documentation handoff
```

Mark them complete as you progress.

### Phase 5: State Tracking

Create `.testing-setup-state.json`:

```json
{
  "version": "1.0",
  "path": "react-native-ios",
  "started_at": "2025-11-03T10:30:00Z",
  "phases": {
    "detection": {"status": "completed"},
    "questions": {"status": "in_progress"},
    "implementation": {"status": "pending"}
  },
  "git_commits": []
}
```

Update after each major step.

## Resume Capability

If `.testing-setup-state.json` exists:

```
Resuming testing infrastructure setup...

📊 Progress from previous session:
✓ Phase 1: Detection (completed)
✓ Phase 2: Questions (completed)
❌ Phase 3: Implementation - Step 4 (failed)
   Error: [error message]

I can:
1. Fix the error and continue
2. Show you the error details
3. Rollback to before this step
4. Restart entire setup

What would you like to do?
```

Use `AskUserQuestion` to let user choose.

## Error Handling Protocol

### Pre-Flight Checks

Before ANY modifications:

```bash
# Disk space
df -h . | awk 'NR==2 {print $4}'

# Git status
git status --porcelain

# Tool versions
node --version
npm --version
ruby --version  # if iOS
```

If checks fail, attempt automatic fixes:
- Suggest freeing disk space
- Offer to commit changes
- Offer to install missing tools

### Automatic Fixes

Before asking user, try:
- Tool not installed → show install command, offer to run it
- Permission denied → suggest proper paths/permissions
- Directory missing → create it automatically
- Port in use → find free port

### Verification After Each Step

After each major step:

```bash
# After tool install
maestro --version  # or whatever tool

# After file modification
ruby -c fastlane/Fastfile  # syntax check

# After quality gate
# Actually test that it blocks on failure
```

Report: ✅ or ❌ with details

### Git Commits

Commit after EACH major step (not just at end):

```bash
git add [files]
git commit -m "feat: add E2E quality gates to Fastlane"
```

Save commit hash to state file for rollback.

## Integration with Other Skills

### With brainstorming

If user mentions E2E testing during brainstorming:
- Suggest using this skill after design is complete
- Seamless handoff

### With test-driven-development

If TDD skill detects no E2E infrastructure:
- Recommend this skill
- Set up before starting TDD

### With verification-before-completion

After setup completes:
- Verification skill can validate infrastructure
- Confirms quality gates work

## Success Criteria

Setup is complete when:

- ✅ E2E framework installed and executable
- ✅ Quality gates block deployment on test failure
- ✅ Sample test passes
- ✅ Documentation generated (4 files, 1,600-2,400 lines)
- ✅ Session management docs updated
- ✅ All changes committed with clear messages
- ✅ Verification tests confirm everything works

## Example Invocation

```
User: /setup-testing-infrastructure

Claude: I'm using the setup-testing-infrastructure skill to set up your E2E testing workflow.

        📋 Pre-flight checks:
        ✓ Disk space: 45GB available
        ✓ Git status: clean
        ✓ Node.js: v20.10.0
        ✓ Ruby: 3.2.0
        ⚠ Maestro: not installed (I can install this)

        🔍 Current setup detected:
        - React Native with iOS
        - Jest unit tests (285 tests)
        - No E2E tests found
        - Fastlane configured

        What type of project are you working with?
        [Uses AskUserQuestion with 4 options]

User: React Native + iOS

Claude: Perfect! Following the React Native + iOS path.

        I have 3 questions to customize the setup:
        [Uses AskUserQuestion for each]

        Starting implementation...

        Step 1/8: Installing Maestro...
        ✓ Maestro 2.0.8 installed
        [Git commit: "chore: install Maestro for E2E testing"]

        [continues through all steps]

        ✅ Testing Infrastructure Setup Complete!
        [Shows summary and next steps]
```

## Resume Example

```
User: /setup-testing-infrastructure --resume

Claude: Resuming from previous session...

        📊 Found incomplete setup:
        ✓ Phases 1-2 completed
        ❌ Phase 3: Step 4 failed (Fastfile syntax error)

        I can:
        1. Fix error and continue
        2. Show error details
        3. Rollback to Step 3
        4. Restart from beginning

        [Uses AskUserQuestion]

User: Fix error and continue

Claude: Fixing Fastfile syntax...
        [continues from Step 4]
```

## Path Files Location

The path-specific instructions are in:
- `paths/react-native-ios.md`
- `paths/react-native-cross-platform.md`
- `paths/native-mobile.md`
- `paths/web-e2e.md`

Read the appropriate file and follow its instructions exactly.

## Important Notes

- **Always use AskUserQuestion** for structured choices (not open-ended questions)
- **Always use TodoWrite** to track progress through phases
- **Always create state file** for resumability
- **Always verify after each step** (don't assume it worked)
- **Always commit after each major step** (not just at end)
- **Attempt automatic fixes** before asking user for help
- **Follow the path files exactly** - they contain all implementation details

## Common Rationalizations to Avoid

Don't think:
- "This is simple, I don't need the path file" → WRONG. Use the path file.
- "I'll skip verification to save time" → WRONG. Verify every step.
- "I'll commit everything at the end" → WRONG. Commit after each step.
- "User probably doesn't need documentation" → WRONG. Generate all 4 docs.
- "Quality gate can be tested later" → WRONG. Verify it blocks now.

## Summary

This skill provides a robust, autonomous way to set up E2E testing infrastructure for any project type. Use it whenever testing infrastructure is needed, follow the path files exactly, and ensure all quality gates are working before marking complete.

The end result: A fully-functional E2E testing system with quality gates that block deployment, comprehensive documentation, and verified operation.
