# Getting Started with Testing Infrastructure Setup

**Want to add E2E testing to your project in 5-10 minutes? You're in the right place.**

---

## Choose Your Method

### Method 1: Copy & Paste (Easiest - No Setup Required)

**Best for:** Anyone using Claude without special frameworks

1. Open: `prompts/master-prompt.md`
2. Copy the entire contents
3. Paste into Claude
4. Answer 4 questions
5. Wait 5-10 minutes
6. Done! ✅

**What you get:**
- E2E framework installed
- Quality gates that block deployment
- Sample test
- 1,600-2,400 lines of documentation
- Verified to work

---

### Method 2: Superpowers Skill (Most Powerful)

**Best for:** Users with the superpowers framework

1. **One-time setup:**
   ```bash
   cp -r testing-infrastructure-setup/skills/setup-testing-infrastructure ~/.claude/skills/
   ```

2. **Every time you need it:**
   - Navigate to your project: `cd /path/to/project`
   - In Claude: `/setup-testing-infrastructure`
   - Answer 4 questions
   - Wait 5-10 minutes
   - Done! ✅

**Extra features:**
- TodoWrite progress tracking
- Can resume if interrupted: `/setup-testing-infrastructure --resume`
- Integrates with other superpowers skills
- State tracking in `.testing-setup-state.json`

---

## What Will Happen

### Phase 1: Detection (30 seconds)
Claude examines your project:
- Detects project type
- Checks existing tests
- Verifies required tools
- Shows you what it found

### Phase 2: Questions (1 minute)
Claude asks 4 targeted questions:
1. Which path? (React Native iOS / Cross-platform / Native / Web)
2. Block deployment on test failure? (Yes/No)
3. Which E2E framework? (options depend on your path)
4. Create sample test? (Yes/No)

### Phase 3: Implementation (4-8 minutes)
Claude sets everything up:
- Installs E2E framework
- Configures build automation
- Adds quality gates
- Creates test directories
- Generates documentation
- Creates sample test
- Commits changes to git

### Phase 4: Verification (30 seconds)
Claude tests the setup:
- Runs unit tests
- Runs E2E test
- Tests that quality gate blocks on failure
- Tests that quality gate allows on success

### Phase 5: Handoff (30 seconds)
Claude shows you:
- Summary of what was set up
- Quick start commands
- Links to documentation
- Next steps

**Total time: 5-10 minutes**

---

## What You'll Get

### Installed & Configured

Depending on your project type:
- **React Native iOS:** Maestro or Detox + Fastlane + quality gates
- **React Native Cross-platform:** Maestro/Detox/Espresso + Fastlane + Gradle + quality gates
- **Native Mobile:** XCUITest/Espresso/Maestro + build automation + quality gates
- **Web:** Playwright/Cypress/Puppeteer + npm scripts + quality gates

### Documentation (4 Files)

1. **TESTING-WORKFLOW.md** (400-600 lines)
   - Complete testing guide
   - All commands explained
   - Workflow examples
   - Troubleshooting

2. **Testing Checklist** (500-600 lines)
   - Pre-deployment checklist
   - Step-by-step verification
   - Performance checks

3. **Device/Browser Guide** (500-600 lines)
   - Setup instructions
   - Running tests
   - Debugging tips

4. **Build Verification Script** (200-400 lines)
   - Executable script
   - Validates builds
   - Pass/fail reporting

**Total: 1,600-2,400 lines of project-specific documentation**

### Git History

6-8 commits with clear messages:
- "chore: install [framework] for E2E testing"
- "feat: add E2E quality gates to [build tool]"
- "test: add sample E2E test"
- "docs: add comprehensive testing documentation"
- etc.

### Session Management

If you have `CONTINUE-SESSION.md` or `SESSION-STATUS.md`, they'll be updated with testing workflow info so future developers know what to do.

---

## After Setup is Complete

### Quick Commands

**React Native iOS:**
```bash
# Development
npm test

# Pre-deployment
cd ios && fastlane test

# Deploy
cd ios && fastlane beta
```

**Web:**
```bash
# Development
npm test

# E2E tests
npm run test:e2e

# Full suite
npm run test:all

# Deploy (quality gates enforced)
npm run deploy
```

### Next Steps

1. Review `TESTING-WORKFLOW.md` for complete guide
2. Run the full test suite to see it work
3. Add more E2E tests for your features
4. Enjoy the confidence of quality gates! 🎉

---

## Troubleshooting

### "Claude can't find the prompt file"

Make sure you copied the **entire contents** of `master-prompt.md`, not just the filename.

### "Setup failed at some step"

**If using prompt mode:** Re-paste the prompt. Claude will detect partial setup and offer to continue.

**If using skill mode:** Run `/setup-testing-infrastructure --resume` and choose "Fix and continue".

### "Tests are failing after setup"

This is expected if you have existing test failures! The quality gate is working correctly. Fix the failing tests and try again.

### "I want to skip E2E tests for now"

You can, but it's not recommended. If you must:
- iOS: `SKIP_E2E=true fastlane beta`
- Web: `npm run build && npm run upload` (skip test:all)

---

## Examples

### Example 1: New React Native iOS App

```
You: [Paste master-prompt.md]

Claude: Detected React Native iOS project
        Which path? → "React Native + iOS"
        Block deployment? → "Yes"
        E2E framework? → "Maestro"
        Create sample? → "Yes"

        [5 minutes later]

        ✅ Complete!
        - Maestro installed
        - Fastlane configured
        - Quality gates active
        - Sample test passing
        - 2,007 lines of docs

        Quick start:
        $ npm test
        $ cd ios && fastlane test
```

### Example 2: Existing Web App

```
You: /setup-testing-infrastructure

Claude: [TodoWrite: 5 phases created]
        Detected web application
        Which path? → "Web application"
        Block deployment? → "Yes"
        E2E framework? → "Playwright"
        Browser targets? → "All major browsers"
        Create sample? → "Yes"

        [6 minutes later]

        ✅ Complete!
        - Playwright installed (Chrome, Firefox, WebKit)
        - npm scripts configured
        - predeploy hook added
        - Sample test passing
        - 1,850 lines of docs

        Quick start:
        $ npm test
        $ npm run test:e2e
        $ npm run deploy
```

---

## Time Savings

**Manual setup:** 6-15 hours (research, configure, debug, document)
**With this system:** 5-10 minutes (answer questions, wait)

**Time saved:** 5.5-14.5 hours per project

---

## Questions?

- **Usage guide:** Read `README.md`
- **Full design:** Read `docs/plans/2025-11-03-testing-infrastructure-setup-guide-design.md`
- **What you'll get:** Read `DELIVERABLES.md`
- **This guide:** You're reading it!

---

## Ready?

1. Choose your method (copy/paste or skill)
2. Navigate to your project directory
3. Start the setup
4. Answer 4 questions
5. Wait 5-10 minutes
6. Enjoy your new testing infrastructure! 🚀

**Let's go!**
