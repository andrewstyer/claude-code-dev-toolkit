# Path 1: React Native + iOS Testing Infrastructure Setup

This path sets up E2E testing infrastructure for React Native iOS projects with Maestro or Detox.

---

## Phase 1: Environment Detection

### Examine Project

Look for:
- `package.json` with "react-native" dependency
- `ios/` directory with Xcode project (.xcodeproj or .xcworkspace)
- Existing test setup (jest.config.js, __tests__/)
- Existing Fastlane setup (ios/fastlane/)
- iOS Simulator availability

### Show User Summary

```
🔍 Current setup detected:
- React Native: v0.XX.X
- Jest unit tests: XXX tests found
- E2E tests: [Present/Not found]
- Fastlane: [Configured/Not configured]
- iOS Simulator: [Available/Not available]
- Maestro: [Installed/Not installed]
- Detox: [Installed/Not installed]
```

---

## Phase 2: Minimal Questions

Use `AskUserQuestion` tool to ask these 3-4 questions:

### Question 1: Deployment Blocking

```
Question: "Should E2E tests block deployment to TestFlight if they fail?"
Header: "Quality Gates"
Options:
  - "Yes, block deployment"
    Description: "Tests must pass before deploying. Prevents broken builds reaching users. Recommended for production apps."

  - "No, tests are optional"
    Description: "Deployment proceeds even if tests fail. Useful for early development but risky for production."
```

### Question 2: E2E Framework

```
Question: "Which E2E testing framework should we use?"
Header: "E2E Framework"
Options:
  - "Maestro"
    Description: "Cloud-based, easy setup, works without rebuilding app, supports React Native well. Recommended for most cases."

  - "Detox"
    Description: "Runs directly on device, faster execution, more control, but requires app rebuild for each test run. Better for complex interactions."
```

### Question 3: Testing Targets

```
Question: "What testing targets do you need?"
Header: "Test Targets"
Options:
  - "iOS Simulator only"
    Description: "Fastest iteration, sufficient for most development. Tests run only on Mac simulator."

  - "Physical iOS devices"
    Description: "Tests real device behavior, required for hardware-specific features (camera, sensors). Requires device provisioning."

  - "Both simulator and devices"
    Description: "Most comprehensive. Simulator for fast iteration, devices for release validation. Recommended."
```

### Question 4: Sample Test

```
Question: "Should I create a sample E2E test to verify the setup works?"
Header: "Sample Test"
Options:
  - "Yes, create sample test"
    Description: "Creates app-launches.yaml test that verifies app can launch. Helps validate setup immediately."

  - "No sample test needed"
    Description: "Skip sample test creation. You'll write your own tests from scratch."
```

---

## Phase 3: Implementation

### Pre-Flight Checks

Before making any changes:

```bash
# Check disk space
df -h . | awk 'NR==2 {print "Disk space: " $4 " available"}'

# Check git status
git status --porcelain

# Check tool versions
node --version
npm --version
ruby --version
bundle --version

# Check Xcode
xcodebuild -version

# Check simulator
xcrun simctl list devices | grep "Booted"

# Check network
curl -I https://registry.npmjs.org/ > /dev/null 2>&1
```

Report results:
```
📋 Pre-flight checks:
✓ Disk space: 45GB available
✓ Git status: clean (or list uncommitted files)
✓ Node.js: v20.10.0
✓ npm: 10.2.0
✓ Ruby: 3.2.0
✓ Bundler: 2.4.10
✓ Xcode: 15.0
✓ iOS Simulator: iPhone 16 Pro (Booted)
✓ Network: Connected to npm registry
```

If any checks fail, attempt automatic fixes or show user how to fix.

### Create State File

```bash
cat > .testing-setup-state.json <<EOF
{
  "version": "1.0",
  "path": "react-native-ios",
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "phases": {
    "detection": {"status": "completed"},
    "questions": {"status": "completed", "answers": {}},
    "implementation": {"status": "in_progress", "steps": {}}
  },
  "git_commits": []
}
EOF
```

### Step 1: Install E2E Framework

**If Maestro:**

```bash
# Check if already installed
if ! command -v maestro &> /dev/null; then
  echo "Installing Maestro..."
  brew tap mobile-dev-inc/tap
  brew install maestro
fi

# Verify installation
maestro --version
```

**If Detox:**

```bash
# Install Detox CLI
npm install -g detox-cli

# Install Detox as dev dependency
npm install --save-dev detox

# Initialize Detox
detox init
```

Verify:
```bash
# For Maestro
maestro --version  # Should output version number

# For Detox
detox --version  # Should output version number
```

Update state file:
```json
"implementation": {
  "steps": {
    "install_e2e_framework": "completed"
  }
}
```

Git commit:
```bash
git add package.json package-lock.json .testing-setup-state.json
git commit -m "chore: install Maestro for E2E testing"
```

### Step 2: Create E2E Test Directory

**For Maestro:**

```bash
mkdir -p .maestro/flows/features
```

**For Detox:**

```bash
mkdir -p e2e
```

Update state and commit:
```bash
git add .maestro/ .testing-setup-state.json  # or e2e/
git commit -m "chore: create E2E test directory structure"
```

### Step 3: Configure Fastlane

Check if Fastlane exists:

```bash
if [ ! -f "ios/fastlane/Fastfile" ]; then
  echo "Fastlane not found. Initializing..."
  cd ios
  bundle init
  bundle add fastlane
  fastlane init
  cd ..
fi
```

Modify `ios/fastlane/Fastfile` to add quality gates:

**Add/modify test lane:**

```ruby
desc "Run all tests (unit + E2E)"
lane :test do
  # Step 1: Run unit tests
  UI.message "🔒 Quality Gate 1: Running Jest unit tests..."
  sh("cd ../.. && npm test -- --passWithNoTests")
  UI.success "✅ Unit tests passed!"

  # Step 2: Run E2E tests
  skip_e2e = ENV['SKIP_E2E'] == 'true'

  if skip_e2e
    UI.important "⚠️  Skipping E2E tests (SKIP_E2E=true)"
  else
    UI.message "🔒 Quality Gate 2: Running Maestro E2E tests..."

    begin
      # Check if Maestro is installed
      sh("command -v maestro > /dev/null 2>&1")

      # Clean app state
      UI.message "🧹 Cleaning app state on simulator..."
      sh("xcrun simctl uninstall booted #{app_identifier} 2>/dev/null || true")
      sleep(1)

      # Build and install fresh app
      UI.message "📱 Installing fresh app build..."
      sh("cd ../.. && npm run ios -- --no-packager 2>&1 | grep -E '(success|error|Build Succeeded)' || true")
      sleep(3)

      # Run E2E tests
      UI.message "🧪 Running E2E tests..."
      sh("cd ../.. && maestro test .maestro/flows/features/")

      UI.success "✅ E2E tests passed!"
    rescue => ex
      if ex.message.include?("command not found")
        UI.important "⚠️  Maestro not found - skipping E2E tests"
      else
        UI.error "❌ E2E tests failed!"
        UI.error "Fix the failing tests before deploying."
        UI.error "To skip (NOT recommended): SKIP_E2E=true fastlane beta"
        raise ex
      end
    end
  end

  UI.success "✅ All quality gates passed!"
end
```

**Add/modify beta lane to include quality gate:**

```ruby
desc "Build and upload to TestFlight"
lane :beta do
  # QUALITY GATE: Tests must pass
  ensure_git_status_clean
  test  # This blocks if tests fail

  # Increment build
  increment_build_number

  # Build and upload
  build_app(
    workspace: "YourApp.xcworkspace",
    scheme: "YourApp",
    configuration: "Release"
  )

  upload_to_testflight

  # Git automation
  commit_version_bump
  add_git_tag
  push_to_git_remote
end
```

Verify:
```bash
cd ios
ruby -c fastlane/Fastfile  # Check syntax
fastlane lanes  # List lanes
cd ..
```

Git commit:
```bash
git add ios/fastlane/Fastfile .testing-setup-state.json
git commit -m "feat: add E2E quality gates to Fastlane"
```

### Step 4: Create Sample E2E Test (if requested)

**For Maestro:**

Create `.maestro/flows/features/app-launches.yaml`:

```yaml
appId: com.yourcompany.yourapp  # Update with actual app ID

---

- launchApp
- assertVisible: ".*"  # Assert something is visible
- takeScreenshot: screenshots/app-launched
```

**For Detox:**

Create `e2e/firstTest.e2e.js`:

```javascript
describe('App Launch', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('should show home screen after launch', async () => {
    await expect(element(by.id('home-screen'))).toBeVisible();
  });
});
```

Verify:
```bash
# For Maestro
maestro test .maestro/flows/features/app-launches.yaml

# For Detox
detox test
```

Git commit:
```bash
git add .maestro/ .testing-setup-state.json  # or e2e/
git commit -m "test: add sample E2E test for app launch"
```

### Step 5: Generate Documentation

Create `TESTING-WORKFLOW.md`:

```markdown
# Testing Workflow - React Native iOS

**Last Updated:** $(date +"%B %d, %Y")
**Framework:** Maestro (or Detox)
**Platform:** iOS

## Quick Start

### Development Testing
npm test  # Run unit tests

### Pre-Deployment Testing
cd ios && fastlane test  # Run unit + E2E tests

### Deploy to TestFlight
cd ios && fastlane beta  # Quality gates enforced

## Available Commands

### fastlane test_unit
- Runs Jest unit tests only
- Fast feedback (< 10 seconds)
- Use during active development

### fastlane test
- Runs unit tests + E2E tests
- Automatic app cleanup
- Required before deployment
- Time: 2-3 minutes

### fastlane beta
- Runs all quality gates
- Builds release IPA
- Uploads to TestFlight
- Time: 8-10 minutes

## Workflows

### Development Iteration
1. Make code changes
2. Run `npm test`
3. Fix any failures
4. Commit changes

### Pre-Merge Validation
1. Run `npm test`
2. Start iOS Simulator
3. Run `cd ios && fastlane test`
4. All tests must pass
5. Merge to main

### Deployment to TestFlight
1. Checkout main branch
2. Ensure git clean
3. Run `cd ios && fastlane beta`
4. Quality gates auto-enforce
5. Build uploads automatically

## Troubleshooting

[Add common issues and solutions]

## CI/CD Integration

[Add GitHub Actions / GitLab CI examples]
```

Create `SIMULATOR-TESTING-CHECKLIST.md`, `PHYSICAL-DEVICE-TESTING.md`, and `scripts/verify-build.sh` with similar comprehensive content (see design doc for full templates).

Git commit:
```bash
git add TESTING-WORKFLOW.md SIMULATOR-TESTING-CHECKLIST.md PHYSICAL-DEVICE-TESTING.md scripts/ .testing-setup-state.json
git commit -m "docs: add comprehensive testing documentation"
```

### Step 6: Update Session Management Docs

If `CONTINUE-SESSION.md` exists, add:

```markdown
**Testing workflow (UPDATED November 3, 2025):**
# Quick unit tests
npm test

# Full test suite (unit + E2E) with automatic cleanup
cd ios && fastlane test

# Deploy to TestFlight with quality gates
cd ios && fastlane beta
```

If `SESSION-STATUS.md` exists, add:

```markdown
**⭐ NEW: Automated Testing Workflow**

Quick Commands:
- Unit tests: npm test
- Full suite: cd ios && fastlane test
- Deploy: cd ios && fastlane beta

Documentation:
- TESTING-WORKFLOW.md ⭐ NEW
- SIMULATOR-TESTING-CHECKLIST.md ⭐ NEW
- PHYSICAL-DEVICE-TESTING.md ⭐ NEW
- scripts/verify-build.sh ⭐ NEW
```

Git commit:
```bash
git add CONTINUE-SESSION.md SESSION-STATUS.md .testing-setup-state.json
git commit -m "docs: update session docs with testing workflow"
```

---

## Phase 4: Verification

### Test Unit Tests

```bash
npm test
```

Expected: All tests pass ✅

### Test Sample E2E

```bash
# For Maestro
maestro test .maestro/flows/features/app-launches.yaml

# For Detox
detox test
```

Expected: Test passes ✅

### Test Quality Gate Blocks

```bash
# Temporarily break a test
echo "test('fails', () => { expect(true).toBe(false); });" >> src/__tests__/temp.test.js

# Try to run quality gate
cd ios && fastlane test
```

Expected: Should FAIL and block ❌ (this is good!)

```bash
# Remove temp test
rm src/__tests__/temp.test.js

# Try again
cd ios && fastlane test
```

Expected: Should PASS ✅

### Test Quality Gate Allows

With all tests passing:

```bash
cd ios && fastlane test
```

Expected: All quality gates pass, deployment would be allowed ✅

---

## Phase 5: Handoff

### Show Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Testing Infrastructure Setup Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 What was set up:
- Maestro E2E testing framework (v2.0.8)
- Quality gates in Fastlane (blocks deployment on failure)
- Automatic app cleanup (ensures clean test state)
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
6 commits created with descriptive messages
All changes are committed and ready to push

✅ Verification Results:
- Unit tests: 285/285 passed
- E2E tests: 1/1 passed
- Quality gate blocks on failure: Confirmed
- Quality gate allows on success: Confirmed

🎯 Next Steps:
1. Review TESTING-WORKFLOW.md
2. Run: cd ios && fastlane test
3. Add more E2E tests to .maestro/flows/features/
4. Configure TestFlight credentials for deployment
```

### Clean Up State File

```bash
# Mark as completed
echo '{"status": "completed", "completed_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' > .testing-setup-state.json
```

### Final Commit

```bash
git add .testing-setup-state.json
git commit -m "chore: finalize testing infrastructure setup"
```

---

## Setup Complete!

The React Native + iOS testing infrastructure is now fully configured and verified. All quality gates are in place and working.
