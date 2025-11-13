# Testing Infrastructure Setup Guide

**Version:** 1.0
**Last Updated:** November 3, 2025
**Purpose:** Project-agnostic guide for setting up E2E testing infrastructure with quality gates

---

## What This Is

A comprehensive, autonomous testing infrastructure setup system that Claude developers can use to establish E2E testing workflows with minimal user input.

Supports:
- React Native + iOS
- React Native + Cross-platform (iOS + Android)
- Native mobile apps (Swift/Kotlin)
- Web applications

---

## Two Ways to Use This

### Option 1: Prompt-Based (No Framework Needed)

**Best for:** Anyone using Claude without the superpowers framework

1. Copy the contents of `prompts/master-prompt.md`
2. Paste into Claude
3. Answer 1 question about your project type
4. Claude loads the appropriate path and sets up everything

**Time:** 5-10 minutes for complete setup

### Option 2: Skill-Based (Superpowers Framework)

**Best for:** Users with the superpowers plugin installed

1. Copy the `skills/setup-testing-infrastructure/` directory to your superpowers skills location
2. Run: `/setup-testing-infrastructure`
3. Answer 1 question about your project type
4. Claude sets up everything with full skill integration

**Time:** 5-10 minutes for complete setup

**Benefits:**
- TodoWrite tracking
- State file for resumability
- Integration with other superpowers skills
- Can resume if interrupted: `/setup-testing-infrastructure --resume`

---

## What Gets Set Up

### All Paths Include:

1. **E2E Testing Framework** (Maestro, Detox, Playwright, etc.)
2. **Quality Gates** (tests block deployment on failure)
3. **Automatic Cleanup** (ensures tests start from clean state)
4. **Sample Tests** (verify setup works)
5. **Comprehensive Documentation:**
   - TESTING-WORKFLOW.md (400-600 lines)
   - Testing checklist (500-600 lines)
   - Device/browser testing guide (500-600 lines)
   - Build verification script (200-400 lines)
6. **Session Management Updates** (for future developers)
7. **Git Commits** (all changes committed with clear messages)

### Total Documentation Generated:
- 1,600-2,400 lines across 4 files
- Customized for your project type
- Ready to use immediately

---

## Quick Start

### Using Prompts

```bash
# 1. Navigate to your project directory
cd /path/to/your/project

# 2. Copy master-prompt.md contents
cat testing-infrastructure-setup/prompts/master-prompt.md

# 3. Paste into Claude and follow the prompts
```

### Using Skills

```bash
# 1. Install the skill (one time)
cp -r testing-infrastructure-setup/skills/setup-testing-infrastructure ~/.claude/skills/

# 2. Navigate to your project directory
cd /path/to/your/project

# 3. Invoke the skill
# (In Claude) /setup-testing-infrastructure
```

---

## What to Expect

### Phase 1: Detection (Autonomous)
Claude analyzes your project:
- Detects project type
- Identifies existing tests
- Checks for required tools
- Shows summary of findings

### Phase 2: Questions (2-4 Questions)
Claude asks targeted questions:
- Should tests block deployment?
- Which E2E framework? (with trade-offs)
- Testing targets? (simulators, devices, browsers)
- Create sample test?

### Phase 3: Implementation (Autonomous)
Claude sets everything up:
- Installs E2E framework
- Configures build automation
- Adds quality gates
- Creates test workflows
- Generates documentation
- Creates sample test

### Phase 4: Verification (Autonomous)
Claude tests the setup:
- Runs sample unit test
- Runs sample E2E test
- Verifies quality gates work
- Reports results

### Phase 5: Handoff (Documentation)
Claude wraps up:
- Updates session management docs
- Generates quick reference
- Commits all changes
- Provides next steps

**Total Time:** 5-10 minutes

---

## Error Handling

The setup includes robust error handling:

- **Pre-flight checks** - Validates environment before starting
- **State tracking** - Can resume from any failure point
- **Automatic fixes** - Attempts common fixes before asking
- **Verification tests** - Catches issues immediately
- **Rollback capability** - Can revert to any previous state

---

## Path-Specific Details

### Path 1: React Native + iOS
- E2E: Maestro or Detox
- Build: Fastlane
- Targets: iOS Simulator + Physical devices
- Documentation: iOS-specific guides

### Path 2: React Native + Cross-Platform
- E2E: Maestro (both platforms) or platform-specific
- Build: Fastlane (iOS) + Gradle (Android)
- Targets: Simulators, emulators, devices
- Documentation: Dual-platform guides

### Path 3: Native Mobile
- E2E: XCUITest, Espresso, or Maestro
- Build: Platform-native or Fastlane
- Targets: iOS/Android devices
- Documentation: Native framework guides

### Path 4: Web Applications
- E2E: Playwright, Cypress, or Puppeteer
- Build: npm scripts
- Targets: Browsers (Chrome, Firefox, Safari)
- Documentation: Browser testing guides

---

## Success Criteria

Setup is complete when:

- ✅ E2E framework installed and working
- ✅ Quality gates block deployment on test failure
- ✅ Sample test passes
- ✅ All documentation generated (4 files)
- ✅ Session docs updated
- ✅ All changes committed to git

---

## Example Output

After setup completes:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Testing Infrastructure Setup Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 What was set up:
- Maestro E2E testing framework
- Quality gates in Fastlane
- Automatic app cleanup
- Sample E2E test
- Comprehensive documentation (4 files, 2,007 lines)

🚀 Quick Start Commands:

Development:
$ npm test

Pre-deployment:
$ cd ios && fastlane test

Deploy:
$ cd ios && fastlane beta

📚 Full Documentation:
- TESTING-WORKFLOW.md
- SIMULATOR-TESTING-CHECKLIST.md
- PHYSICAL-DEVICE-TESTING.md
- scripts/verify-build.sh
```

---

## Troubleshooting

### Issue: Claude doesn't detect my project type

**Solution:** Check that you're in the project root directory with package.json or build files.

### Issue: Tool installation fails

**Solution:** Claude will show the error and suggest fixes. You may need to install manually then re-run.

### Issue: Setup interrupted

**Solution (Skill users):** Run `/setup-testing-infrastructure --resume` to continue from where you left off.

**Solution (Prompt users):** Re-paste the prompt. Claude will detect partial setup and offer to continue.

### Issue: Tests fail after setup

**Solution:** This is expected! The quality gate is working. Claude will help debug the test setup.

---

## Contributing

This is a project-agnostic testing infrastructure setup guide. Improvements welcome!

---

## Questions?

Refer to the design document: `2025-11-03-testing-infrastructure-setup-guide-design.md`

---

## License

MIT - Use freely in any project
