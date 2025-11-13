# Testing Infrastructure Setup Guide - Design Document

**Date:** November 3, 2025
**Status:** Design Complete
**Purpose:** Project-agnostic guide for autonomous Claude developers to set up E2E testing infrastructure with quality gates

---

## Overview

This design describes a comprehensive, project-agnostic testing infrastructure setup system that autonomous Claude developers can use to establish E2E testing workflows with minimal user input. The system supports multiple project types through distinct paths while maintaining common patterns and robust error handling.

**Key Goals:**
1. Enable autonomous setup with 2-4 targeted questions
2. Support 4 distinct project types through specialized paths
3. Provide both prompt-based and skill-based usage
4. Ensure robust error handling and recovery
5. Generate comprehensive documentation automatically

---

## Architecture

### File Structure

```
testing-infrastructure-setup/
├── README.md                          # Overview + usage instructions
├── prompts/
│   ├── master-prompt.md              # Entry point - asks project type
│   ├── react-native-ios.md           # Path 1: React Native + iOS
│   ├── react-native-cross-platform.md # Path 2: React Native + iOS/Android
│   ├── native-mobile.md              # Path 3: Native Swift/Kotlin apps
│   └── web-e2e.md                    # Path 4: Web applications
└── skills/
    ├── setup-testing-infrastructure/
    │   └── SKILL.md                  # Main skill with invocation logic
    └── paths/
        ├── react-native-ios.md
        ├── react-native-cross-platform.md
        ├── native-mobile.md
        └── web-e2e.md
```

### Two Usage Modes

**1. Prompt-Based (No Framework Required)**
- User copies `master-prompt.md` to Claude
- Claude asks project type (1 question)
- User provides path file or Claude loads it
- Claude executes selected path

**2. Skill-Based (Superpowers Framework)**
- User invokes: `/setup-testing-infrastructure`
- Skill uses `AskUserQuestion` for project type
- Skill loads appropriate path automatically
- Follows same logic as prompt version

---

## Four Paths

### Common Elements (All Paths)

All paths follow this structure:

**Phase 1: Environment Detection** (Autonomous)
- Detect project type from files (package.json, Gemfile, build.gradle, etc.)
- Identify existing test setup (jest config, existing E2E, etc.)
- Check for required tools and versions
- Generate summary: "Here's what I found..."

**Phase 2: Minimal Questions** (2-4 Questions)
- Use `AskUserQuestion` tool for structured choices
- Questions specific to each path
- Include trade-offs in option descriptions
- Provide recommended defaults

**Phase 3: Implementation** (Autonomous)
- Install E2E framework if needed
- Create/modify build automation (Fastlane, Gradle, npm scripts)
- Add quality gates that block deployment
- Create test workflows
- Generate documentation (4 files)
- Create sample test to verify setup

**Phase 4: Verification** (Autonomous)
- Run sample unit test
- Run sample E2E test
- Verify quality gates block on failure
- Verify quality gates allow on success
- Output results with clear pass/fail

**Phase 5: Handoff** (Documentation)
- Update session management docs (if present)
- Generate quick reference card
- Commit all changes with clear messages
- Provide next steps

### Path-Specific Details

#### Path 1: React Native + iOS

**Target Projects:**
- React Native with Expo or bare workflow
- iOS-only deployment
- Jest for unit tests

**Environment Detection:**
- package.json with "react-native"
- ios/ directory with Xcode project
- Jest configuration
- Existing Fastlane setup

**Questions (2-4):**
1. "Should E2E tests block deployment?" (Yes/No)
2. "Which E2E framework?" (Maestro/Detox - with trade-offs)
3. "Testing targets?" (Simulator only / Physical devices / Both)
4. "Create sample test?" (Yes/No)

**Implementation:**
- Install Maestro or Detox
- Create/modify `ios/fastlane/Fastfile`
- Add test lane with quality gates
- Add automatic app cleanup (uninstall/reinstall)
- Create `.maestro/` or `e2e/` directory
- Generate sample E2E test

**Documentation Generated:**
- TESTING-WORKFLOW.md (Fastlane commands, workflows)
- SIMULATOR-TESTING-CHECKLIST.md (Pre-deployment checklist)
- PHYSICAL-DEVICE-TESTING.md (Device testing guide)
- scripts/verify-build.sh (Build validation)

**Quality Gate:**
```ruby
lane :test do
  # Unit tests
  sh("cd ../.. && npm test")

  # App cleanup
  sh("xcrun simctl uninstall booted #{app_identifier}")

  # Fresh install
  sh("cd ../.. && npm run ios -- --no-packager")

  # E2E tests
  sh("cd ../.. && maestro test .maestro/flows/")
end
```

---

#### Path 2: React Native + Cross-Platform

**Target Projects:**
- React Native with iOS and Android
- Dual-platform deployment
- Jest for unit tests

**Environment Detection:**
- package.json with "react-native"
- ios/ and android/ directories
- Existing build configurations

**Questions (3-4):**
1. "Should E2E tests block deployment?" (Yes/No)
2. "Which E2E framework?" (Maestro for both / Platform-specific)
3. "Testing targets?" (Simulators/Emulators / Devices / Both)
4. "Create sample tests for both platforms?" (Yes/No)

**Implementation:**
- Install E2E framework(s)
- Configure Fastlane for iOS
- Configure Gradle/Fastlane for Android
- Add dual quality gates
- Create platform-specific test directories
- Generate sample E2E tests for both platforms

**Documentation Generated:**
- TESTING-WORKFLOW.md (iOS and Android commands)
- IOS-SIMULATOR-TESTING-CHECKLIST.md
- ANDROID-EMULATOR-TESTING-CHECKLIST.md
- PHYSICAL-DEVICE-TESTING.md (both platforms)
- scripts/verify-ios-build.sh
- scripts/verify-android-build.sh

**Quality Gates:**
- iOS: Same as Path 1
- Android: Gradle lane with Maestro/Espresso integration

---

#### Path 3: Native Mobile (Swift/Kotlin)

**Target Projects:**
- Native iOS (Swift, Xcode)
- Native Android (Kotlin, Android Studio)
- Platform-native test frameworks

**Environment Detection:**
- iOS: .xcodeproj or .xcworkspace files
- Android: build.gradle with Android plugin
- Existing XCTest or Espresso setup

**Questions (3-4):**
1. "Which platform?" (iOS / Android / Both)
2. "E2E framework?" (XCUITest / Maestro for iOS; Espresso / Maestro for Android)
3. "Should E2E tests block deployment?" (Yes/No)
4. "Create sample E2E test?" (Yes/No)

**Implementation:**
- Configure platform-native testing (XCUITest, Espresso)
- Or install Maestro for cross-platform
- Set up Fastlane (iOS) or Gradle (Android)
- Add quality gates
- Create test targets
- Generate sample tests

**Documentation Generated:**
- TESTING-WORKFLOW.md (platform-specific commands)
- Platform-specific checklists
- Build verification scripts
- Device testing guides

---

#### Path 4: Web E2E

**Target Projects:**
- Web applications (React, Vue, Angular, etc.)
- Browser-based testing
- Jest/Vitest for unit tests

**Environment Detection:**
- package.json without "react-native"
- Presence of HTML entry point
- Web bundler (webpack, vite, etc.)
- Existing test setup

**Questions (3-4):**
1. "Which E2E framework?" (Playwright / Cypress / Puppeteer)
2. "Target browsers?" (Chromium only / All major browsers)
3. "Should E2E tests block deployment?" (Yes/No)
4. "Create sample test?" (Yes/No)

**Implementation:**
- Install selected E2E framework
- Create test directory structure
- Add npm scripts for testing
- Configure quality gates in CI or npm scripts
- Handle browser state cleanup
- Generate sample E2E test

**Documentation Generated:**
- TESTING-WORKFLOW.md (npm commands, browser setup)
- BROWSER-TESTING-CHECKLIST.md
- CI-INTEGRATION-GUIDE.md
- scripts/verify-bundle.sh

**Quality Gate Example:**
```json
{
  "scripts": {
    "test": "jest",
    "test:e2e": "playwright test",
    "test:all": "npm test && npm run test:e2e",
    "deploy": "npm run test:all && npm run build && npm run upload"
  }
}
```

---

## Robust Error Handling

### Pre-Flight Checks

Before any modifications, verify:

```
✓ Disk space: > 5GB available
✓ Git status: clean or list uncommitted changes
✓ Write permissions: project directory writable
✓ Required tools: node/npm/ruby/bundler versions
✓ Network: can reach package registries
✓ Existing setup: detect conflicts with current config
✓ Backup capability: git repo initialized
```

If any check fails:
- Show clear error message
- Suggest fix (install tool, free space, commit changes)
- Offer to continue anyway (with warning) or exit

### State Tracking

Create `.testing-setup-state.json` to track progress:

```json
{
  "version": "1.0",
  "path": "react-native-ios",
  "started_at": "2025-11-03T10:30:00Z",
  "phases": {
    "detection": {
      "status": "completed",
      "data": {
        "project_type": "react-native",
        "existing_tests": "jest",
        "fastlane_present": true
      }
    },
    "questions": {
      "status": "completed",
      "answers": {
        "e2e_framework": "maestro",
        "block_deployment": true,
        "targets": "simulator_and_device"
      }
    },
    "implementation": {
      "status": "in_progress",
      "steps": {
        "install_maestro": "completed",
        "create_fastfile": "completed",
        "add_quality_gates": "failed",
        "last_error": "Ruby syntax error on line 45"
      }
    }
  },
  "git_commits": ["abc123", "def456"],
  "rollback_available": true
}
```

**Resume Capability:**
If setup is interrupted:
1. Claude detects `.testing-setup-state.json`
2. Shows user what was completed
3. Offers to continue from last step or restart
4. Preserves all prior work

### Automatic Fixes

Before asking user, Claude attempts:

| Issue | Automatic Fix |
|-------|--------------|
| Tool not installed | Check package manager, offer install command |
| Tool not in PATH | Search common locations, add to PATH temporarily |
| Permission denied | Try with proper paths, suggest chmod if needed |
| Port already in use | Find free port, update config |
| Simulator not booted | Boot default simulator automatically |
| Node modules missing | Run npm install automatically |
| Git not initialized | Initialize with sensible defaults |
| Directory doesn't exist | Create directory structure |

Only escalate to user if automatic fix fails or is risky.

### Verification After Each Step

After each major step, run verification:

```
After tool installation:
  ✓ Can execute tool (maestro --version)
  ✓ Tool returns expected output
  ✓ Tool is in PATH

After Fastfile modification:
  ✓ Ruby syntax valid (ruby -c Fastfile)
  ✓ Fastlane can parse file (fastlane lanes)
  ✓ Required lanes present

After quality gate addition:
  ✓ Test lane runs (even if tests fail)
  ✓ Failure properly blocks deployment
  ✓ Success allows continuation

After documentation:
  ✓ All files created with correct names
  ✓ No broken internal links
  ✓ Commands in docs are executable
  ✓ File sizes reasonable (not empty)
```

If verification fails:
- Show what failed and why
- Attempt automatic fix if possible
- Offer to retry, skip, or rollback
- Save state before continuing

### Rollback Strategy

For safety:
1. Git commit before each major phase
2. Tag commits with `.testing-setup-backup-N`
3. On failure, offer to revert to last good state
4. Show diff of what would be reverted
5. Preserve `.testing-setup-state.json` even after rollback

---

## Documentation Generation

Each path generates 4 core documents using templates with placeholders.

### Template System

**Placeholders:**
- `{{E2E_FRAMEWORK}}` → "Maestro", "Playwright", etc.
- `{{BUILD_COMMAND}}` → "fastlane build", "npm run build"
- `{{TEST_COMMAND}}` → "fastlane test", "npm run test:all"
- `{{PROJECT_TYPE}}` → "React Native + iOS", "Web Application"
- `{{DEPLOY_COMMAND}}` → "fastlane beta", "npm run deploy"
- `{{DATE}}` → Current date

### Document 1: TESTING-WORKFLOW.md

**Sections:**
1. Overview (what was set up)
2. Quick start commands
3. Available test commands (unit, E2E, full suite)
4. Workflow examples (development, pre-merge, deployment)
5. Quality gates explanation
6. Troubleshooting common issues
7. CI/CD integration examples

**Length:** 400-600 lines

### Document 2: SIMULATOR-TESTING-CHECKLIST.md (or equivalent)

**Sections:**
1. Pre-testing setup
2. Environment verification checklist
3. Unit test checklist
4. E2E test checklist
5. Performance checks
6. Error handling scenarios
7. Regression testing
8. Build verification (pre-release)

**Length:** 500-600 lines

### Document 3: PHYSICAL-DEVICE-TESTING.md (mobile paths)

**Sections:**
1. Device provisioning (UDID registration)
2. Installation methods (development, ad-hoc, TestFlight)
3. Running E2E tests on devices
4. Debugging with device logs
5. Common device-specific issues
6. TestFlight workflow

**Length:** 500-600 lines

**Note:** Web path generates BROWSER-TESTING-GUIDE.md instead

### Document 4: scripts/verify-build.sh (or verify-bundle.sh)

**Purpose:** Executable script to validate builds before deployment

**Checks:**
- Critical assets present (images, data files)
- Bundle/binary size within expected range
- Configuration files valid (Info.plist, manifest.json)
- Required permissions set
- No development artifacts in production build

**Exit codes:**
- 0: All checks passed
- 1: Verification failed

**Length:** 200-400 lines

### Session Management Updates

If these files exist, update them:

**CONTINUE-SESSION.md:**
```markdown
**Testing workflow (UPDATED {{DATE}}):**
# Quick unit tests during development
{{UNIT_TEST_COMMAND}}

# Full test suite (unit + E2E) before merge/deploy
{{FULL_TEST_COMMAND}}
# This automatically:
# - Runs all unit tests
# - Cleans app state
# - Runs all E2E tests
# - Blocks on any failure

# Deploy
{{DEPLOY_COMMAND}}
```

**SESSION-STATUS.md:**
```markdown
**⭐ NEW: Automated Testing Workflow (Updated {{DATE}}):**

**Quick Commands:**
- Unit tests: {{UNIT_TEST_COMMAND}}
- Full suite: {{FULL_TEST_COMMAND}}
- Deploy: {{DEPLOY_COMMAND}}

**📚 Testing Documentation:**
- `TESTING-WORKFLOW.md` - Complete testing guide ⭐ NEW
- `SIMULATOR-TESTING-CHECKLIST.md` - Pre-deployment checklist ⭐ NEW
- `PHYSICAL-DEVICE-TESTING.md` - Device testing guide ⭐ NEW
- `scripts/verify-build.sh` - Build verification script ⭐ NEW
```

If files don't exist, create minimal versions with this info.

---

## Example End-to-End Flow

### User Experience (Prompt-Based)

```
User: [Pastes master-prompt.md]

Claude: I'll help you set up E2E testing infrastructure with quality gates.
        What type of project are you working with?
        1. React Native + iOS
        2. React Native + Cross-platform (iOS + Android)
        3. Native mobile (Swift/Kotlin)
        4. Web application

User: 1

Claude: Great! Setting up for React Native + iOS.

        📋 Pre-flight checks:
        ✓ Disk space: 45GB available
        ✓ Git status: clean
        ✓ Node.js: v20.10.0
        ✓ Ruby: 3.2.0
        ⚠ Maestro: not installed (I can install this)
        ✓ Fastlane: 2.217.0

        🔍 Current setup detected:
        - Jest unit tests (285 tests)
        - No E2E tests found
        - Fastlane configured (ios/fastlane/)
        - iOS Simulator available

        I have 3 questions to customize the setup:

[Claude uses AskUserQuestion for structured choices]

Question 1: Should E2E tests block deployment on failure?
[Options with trade-offs]

User: Yes

Question 2: Which E2E framework?
[Options: Maestro vs Detox with trade-offs]

User: Maestro

Question 3: What testing targets?
[Options: Simulator / Devices / Both]

User: Both

Claude: Perfect! Starting implementation...

        Step 1/8: Installing Maestro...
        → Running: brew tap mobile-dev-inc/tap
        → Running: brew install maestro
        ✓ Installed Maestro 2.0.8
        Verification: maestro --version → 2.0.8 ✓

        [Git commit: "chore: install Maestro for E2E testing"]

        Step 2/8: Creating E2E test directory structure...
        → Creating .maestro/flows/features/
        ✓ Directory created
        Verification: Directory exists and writable ✓

        [Git commit: "chore: create E2E test directory structure"]

        Step 3/8: Modifying Fastlane test lane...
        → Backing up ios/fastlane/Fastfile
        → Adding quality gates to test lane
        → Adding automatic app cleanup
        ✓ Fastfile updated
        Verification: Ruby syntax valid ✓
        Verification: Fastlane can parse file ✓

        [Git commit: "feat: add E2E quality gates to Fastlane"]

        Step 4/8: Creating sample E2E test...
        → Writing .maestro/flows/features/app-launches.yaml
        ✓ Sample test created
        Verification: YAML syntax valid ✓

        [Git commit: "test: add sample E2E test for app launch"]

        Step 5/8: Generating documentation...
        → Creating TESTING-WORKFLOW.md (542 lines)
        → Creating SIMULATOR-TESTING-CHECKLIST.md (575 lines)
        → Creating PHYSICAL-DEVICE-TESTING.md (560 lines)
        → Creating scripts/verify-build.sh (330 lines)
        ✓ Documentation generated
        Verification: All files created ✓
        Verification: No broken links ✓

        [Git commit: "docs: add comprehensive testing documentation"]

        Step 6/8: Updating session management docs...
        → Updating CONTINUE-SESSION.md
        → Updating SESSION-STATUS.md
        ✓ Session docs updated

        [Git commit: "docs: update session docs with testing workflow"]

        Step 7/8: Running verification tests...
        → Running unit tests: npm test
        ✓ Unit tests pass (285/285)

        → Running sample E2E test: maestro test .maestro/flows/features/app-launches.yaml
        ✓ E2E test passes

        → Testing quality gate blocks on failure...
        → Temporarily breaking a test
        → Running: cd ios && fastlane test
        ✓ Quality gate correctly blocked deployment

        → Fixing test and retrying...
        ✓ Quality gate correctly allowed deployment

        Step 8/8: Final cleanup...
        ✓ Removed temporary test modifications
        ✓ All state cleaned up

        [Git commit: "chore: finalize testing infrastructure setup"]

        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ✅ Testing Infrastructure Setup Complete!
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        📦 What was set up:
        - Maestro E2E testing framework
        - Quality gates in Fastlane (blocks deployment on failure)
        - Automatic app cleanup for reliable testing
        - Sample E2E test (app-launches.yaml)
        - Comprehensive documentation (4 files, 2,007 lines)
        - Session management updates

        🚀 Quick Start Commands:

        Development (fast iteration):
        $ npm test

        Pre-deployment (full validation):
        $ cd ios && fastlane test

        Deploy to TestFlight:
        $ cd ios && fastlane beta

        📚 Full Documentation:
        - TESTING-WORKFLOW.md - Start here for complete guide
        - SIMULATOR-TESTING-CHECKLIST.md - Pre-deployment checklist
        - PHYSICAL-DEVICE-TESTING.md - Device testing guide
        - scripts/verify-build.sh - Build verification script

        💾 Git History:
        8 commits created with descriptive messages
        All changes are committed and ready to push

        🎯 Next Steps:
        1. Review TESTING-WORKFLOW.md
        2. Run: cd ios && fastlane test
        3. Add more E2E tests to .maestro/flows/features/
        4. Update quality gates if needed
```

### Skill Experience (Superpowers Framework)

```
User: /setup-testing-infrastructure

Claude: I'm using the setup-testing-infrastructure skill to set up your E2E testing workflow.

[Same flow as prompt-based, but with:]
- TodoWrite tracking for each phase
- State saved to .testing-setup-state.json
- Automatic resume capability
- Integration with other superpowers skills

[If interrupted:]

User: /setup-testing-infrastructure --resume

Claude: Resuming testing infrastructure setup...

        📊 Progress from previous session:
        ✓ Phase 1: Detection (completed)
        ✓ Phase 2: Questions (completed)
        ✓ Phase 3: Implementation - Steps 1-3 (completed)
        ❌ Phase 3: Implementation - Step 4 (failed)
           Error: Ruby syntax error in Fastfile line 45
        ⏸ Phase 3: Implementation - Steps 5-8 (pending)

        I can:
        1. Fix the Fastfile error and continue
        2. Show you the error and let you fix it
        3. Rollback to before Fastfile modification
        4. Restart entire setup

        What would you like to do?
```

---

## Integration with Superpowers Skills

### skill: brainstorming
- If user mentions E2E testing during brainstorming
- Claude suggests: "I can use setup-testing-infrastructure skill"
- Seamless handoff after design phase

### skill: test-driven-development
- TDD skill checks for testing infrastructure
- If missing, recommends setup-testing-infrastructure
- Ensures tests can actually run before starting TDD

### skill: verification-before-completion
- After setup, verification skill validates infrastructure
- Confirms quality gates work as expected
- Ensures documentation is accurate

### skill: writing-plans
- Can generate implementation plan for custom test scenarios
- Extends beyond basic setup for complex requirements

### skill: using-git-worktrees
- Can set up testing infrastructure in isolated worktree
- Test changes before merging to main
- Useful for experimentation

---

## Success Criteria

Setup is considered successful when:

1. ✅ **Pre-flight checks pass** - All required tools available
2. ✅ **E2E framework installed** - Can execute E2E commands
3. ✅ **Quality gates working** - Tests block deployment on failure
4. ✅ **Sample test passes** - Verification test runs successfully
5. ✅ **Documentation generated** - All 4 files created and valid
6. ✅ **Session docs updated** - Future developers know about testing
7. ✅ **Git commits clean** - All changes committed with clear messages
8. ✅ **State file created** - Setup can be resumed if needed

---

## Future Enhancements

Potential additions (not in initial version):

1. **CI/CD Integration**
   - Automatically configure GitHub Actions, GitLab CI
   - Add testing workflows for popular platforms

2. **Test Generation**
   - AI-powered E2E test generation from user stories
   - Analyze existing features and suggest tests

3. **Coverage Integration**
   - Set up code coverage tools
   - Add coverage quality gates

4. **Visual Regression Testing**
   - Integrate Percy, Chromatic, or similar
   - Screenshot comparison workflows

5. **Performance Testing**
   - Add performance test suite
   - Monitor bundle size, load times

6. **Multi-Environment Support**
   - Separate test configs for dev/staging/prod
   - Environment-specific quality gates

---

## Conclusion

This design provides a comprehensive, autonomous testing infrastructure setup system that:

- Supports 4 distinct project types through specialized paths
- Requires minimal user input (2-4 questions)
- Provides robust error handling and recovery
- Generates comprehensive documentation automatically
- Works with or without the superpowers framework
- Integrates seamlessly with existing development workflows

The system is designed for autonomous execution by Claude developers and works with any project type.

---

**Design Status:** ✅ Complete and validated
**Next Step:** Create the actual prompt templates and skill files
**Estimated Implementation Time:** 4-6 hours for all paths and documentation
