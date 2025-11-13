# Testing Infrastructure Setup - Master Prompt

**Copy everything below this line and paste into Claude**

---

I need you to set up a comprehensive E2E testing infrastructure with quality gates for my project. This should be done autonomously with minimal questions.

## Your Task

1. **Detect my project type** by examining the files in the current directory
2. **Ask me which path to follow** (1 question with 4 options)
3. **Load the appropriate setup path** and follow it exactly
4. **Set up everything** with robust error handling
5. **Generate comprehensive documentation** (4 files)
6. **Verify the setup works** by running tests
7. **Commit all changes** with clear git messages

## The Four Paths

Ask me which path matches my project:

**Option 1: React Native + iOS**
- React Native with Expo or bare workflow
- iOS-only deployment
- Sets up: Maestro/Detox + Fastlane + quality gates

**Option 2: React Native + Cross-Platform**
- React Native with iOS and Android
- Dual-platform deployment
- Sets up: Maestro/platform-specific + Fastlane + Gradle + quality gates

**Option 3: Native Mobile**
- Native iOS (Swift) or Android (Kotlin)
- Platform-native testing
- Sets up: XCUITest/Espresso/Maestro + build automation + quality gates

**Option 4: Web Application**
- Web app (React, Vue, Angular, etc.)
- Browser-based testing
- Sets up: Playwright/Cypress + npm scripts + quality gates

## What You'll Do

### Phase 1: Environment Detection (Autonomous)

Examine the project and show me:
- Project type detected
- Existing test setup
- Required tools (installed or missing)
- Any potential conflicts

### Phase 2: Minimal Questions (2-4 Questions)

Use the `AskUserQuestion` tool to ask me:
- Should E2E tests block deployment? (yes/no with trade-offs)
- Which E2E framework? (options specific to my path with trade-offs)
- Testing targets? (simulators/devices/browsers with trade-offs)
- Create sample test? (yes/no)

### Phase 3: Implementation (Autonomous)

Set up everything:
1. Run **pre-flight checks** (disk space, git status, permissions, tools)
2. Create **state tracking file** (`.testing-setup-state.json`)
3. Install E2E framework (attempt automatic fixes if issues)
4. Configure build automation (Fastlane, Gradle, npm scripts)
5. Add **quality gates** that block deployment on test failures
6. Add **automatic cleanup** (uninstall/reinstall app or clear browser state)
7. Create sample E2E test
8. **Verify after each step** (run checks before moving on)
9. **Git commit after each major step** with clear messages

### Phase 4: Verification (Autonomous)

Test the setup:
- Run sample unit test → should pass
- Run sample E2E test → should pass
- Intentionally break a test → quality gate should block
- Fix test → quality gate should allow
- Report results with clear ✅/❌

### Phase 5: Handoff (Documentation)

Generate 4 documents:
1. **TESTING-WORKFLOW.md** (400-600 lines)
   - Quick start commands
   - Available test commands
   - Workflow examples (dev, pre-merge, deployment)
   - Troubleshooting
   - CI/CD integration examples

2. **SIMULATOR-TESTING-CHECKLIST.md** or equivalent (500-600 lines)
   - Pre-testing setup
   - Environment verification
   - Unit test checklist
   - E2E test checklist
   - Performance checks
   - Error handling scenarios

3. **PHYSICAL-DEVICE-TESTING.md** or browser guide (500-600 lines)
   - Device provisioning / Browser setup
   - Installation methods
   - Running E2E tests on devices/browsers
   - Debugging techniques
   - Common issues

4. **scripts/verify-build.sh** or verify-bundle.sh (200-400 lines)
   - Executable script
   - Validates builds before deployment
   - Checks assets, bundle size, config
   - Exit code 0 on success, 1 on failure

Also update (or create if missing):
- **CONTINUE-SESSION.md** - Add testing workflow section
- **SESSION-STATUS.md** - Add testing commands and docs

Finally:
- Show me a summary of what was set up
- Give me quick start commands
- Tell me what to do next

## Error Handling Requirements

**Pre-flight Checks:**
Before any modifications, verify:
- Disk space: > 5GB available
- Git status: clean or show uncommitted changes
- Write permissions: can write to project directory
- Required tools: versions of node/npm/ruby/bundler
- Network: can reach package registries
- Backup capability: git repo initialized

**Automatic Fixes:**
Attempt these before asking me:
- Tool not installed → offer install command
- Tool not in PATH → search common locations
- Permission denied → suggest proper paths
- Simulator not booted → boot default
- Node modules missing → run npm install
- Directory missing → create it

**State Tracking:**
Create `.testing-setup-state.json` to track:
- Which phase we're in
- What's been completed
- What failed (if anything)
- Git commits made
- Can resume from any failure

**Verification After Each Step:**
After each major step, verify:
- Tool installation → can execute and returns version
- File modification → syntax valid and parseable
- Quality gate → actually blocks on failure
- Documentation → files created with no broken links

**Rollback Capability:**
- Git commit before each major phase
- On failure, offer to revert
- Show diff of what would be reverted
- Preserve state file for resume

## Success Criteria

Setup is complete when:
- ✅ E2E framework installed and working
- ✅ Quality gates block deployment on test failure
- ✅ Sample test passes
- ✅ All documentation generated (4 files, 1,600-2,400 lines total)
- ✅ Session docs updated
- ✅ All changes committed to git with clear messages
- ✅ Verification tests confirm everything works

## Example Output Format

Show progress like this:

```
📋 Pre-flight checks:
✓ Disk space: 45GB available
✓ Git status: clean
✓ Node.js: v20.10.0
⚠ Maestro: not installed (I can install this)

🔍 Current setup detected:
- Jest unit tests (285 tests)
- No E2E tests found
- Fastlane configured

[After each step:]
Step 3/8: Modifying Fastlane test lane...
→ Backing up ios/fastlane/Fastfile
→ Adding quality gates
✓ Fastfile updated
Verification: Ruby syntax valid ✓

[Git commit: "feat: add E2E quality gates to Fastlane"]
```

## Important Notes

- Use `AskUserQuestion` tool for the 2-4 questions (structured choices with trade-offs)
- Use `TodoWrite` tool to track your progress through the phases
- Create git commits after each major step (not just at the end)
- Verify setup works by actually running tests (don't assume)
- If something fails, try automatic fixes first before asking me
- Save state to `.testing-setup-state.json` so setup can be resumed

## Ready?

Start by examining my project and asking me which of the 4 paths matches my project type. Use the `AskUserQuestion` tool with the 4 options above.

After I answer, follow the selected path exactly as described in the corresponding path file (you'll need to reference the appropriate template for that path).

Let's begin!
