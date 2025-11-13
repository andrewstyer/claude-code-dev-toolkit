# iOS Build & Deploy Setup Guide - Design Document

**Date:** November 3, 2025
**Status:** Design Complete
**Purpose:** Project-agnostic iOS build & deploy setup guide for autonomous Claude developers

---

## Overview

This design describes a comprehensive, autonomous iOS build and deployment setup system that Claude developers can use to establish Fastlane-based deployment workflows with quality gates and minimal user input.

**Key Goals:**
1. Enable autonomous setup with 5-10 targeted questions total
2. Support iOS (primary) with optional Android path
3. Include complete code signing setup
4. Provide phased progressive approach (each phase builds on previous)
5. Ensure robust error handling and validation
6. Support multiple CI/CD platforms
7. Generate comprehensive documentation automatically

---

## Architecture

### Phased Progressive Setup

Unlike the testing-infra guide's multi-path approach, this uses **sequential phases** where each builds on the previous:

```
Phase 1: Environment & Code Signing (10-15 min)
    ↓
Phase 2: Fastlane Installation & Setup (5-10 min)
    ↓
Phase 3: Quality Gates Integration (5-10 min)
    ↓
Phase 4: TestFlight/App Store Configuration (10-15 min)
    ↓
Phase 5: CI/CD Integration (10-20 min, optional)
    ↓
[Optional: Android path branches after Phase 2]
```

**Why phased approach:**
- Natural progression (must have signing before deploying)
- Works for all iOS projects (React Native, Flutter, native)
- Easy to resume from any phase
- Clear stopping points if user wants partial setup

---

## File Structure

```
build-deploy-setup/
├── README.md                          # Overview + quick start
├── GETTING-STARTED.md                 # Simple entry point
├── DELIVERABLES.md                    # What you'll get
├── 2025-11-03-build-deploy-setup-guide-design.md  # This file
├── prompts/
│   └── master-prompt.md               # Autonomous setup prompt
└── skills/
    └── setup-build-deploy/
        ├── SKILL.md                   # Main skill
        └── phases/
            ├── phase1-code-signing.md
            ├── phase2-fastlane-setup.md
            ├── phase3-quality-gates.md
            ├── phase4-deployment.md
            ├── phase5-cicd.md
            └── android/                # Optional Android phases
                ├── phase2b-android-environment.md
                ├── phase3b-android-build.md
                ├── phase4b-google-play.md
                └── phase5b-multiplatform-cicd.md
```

---

## Phase Detailed Specifications

### Phase 1: Environment & Code Signing (10-15 min)

**Purpose:** Establish Apple Developer credentials and code signing

**Detection:**
```bash
# Check for existing setup
security find-identity -v -p codesigning
ls ~/Library/MobileDevice/Provisioning\ Profiles/
test -f ~/.appstoreconnect/private_keys/*.p8
```

**Questions (3):**
1. "Do you have an Apple Developer account?"
   - Yes, already enrolled ($99/year)
   - Need to enroll (will guide to Apple)
   - Using organization account

2. "Code signing method?"
   - Automatic (Xcode manages) - Easier, good for small teams
   - Manual (you control profiles) - More control, good for large teams
   - API Key (recommended) - Best for CI/CD, no 2FA prompts

3. "Deployment target?"
   - TestFlight only
   - App Store only
   - Both (recommended)

**Implementation:**

**Step 1: Verify Apple Developer Account**
```bash
# Test credentials work
if [ -n "$FASTLANE_APPLE_ID" ]; then
  fastlane run validate_apple_account
else
  echo "⚠️  Apple ID not configured"
  # Prompt user for credentials
fi
```

**Step 2: Set Up Code Signing (Method: API Key - Recommended)**
```bash
# Guide user to create API key
echo "📋 Creating App Store Connect API Key..."
echo "1. Go to: https://appstoreconnect.apple.com/access/api"
echo "2. Click '+' to create new key"
echo "3. Name: 'Fastlane Deploy Key'"
echo "4. Role: 'App Manager'"
echo "5. Download the .p8 file"
echo ""
echo "Waiting for download... (press Enter when ready)"
read

# Store API key securely
mkdir -p ~/.appstoreconnect/private_keys
echo "📁 Move the .p8 file to: ~/.appstoreconnect/private_keys/"
# Wait for file
while [ ! -f ~/.appstoreconnect/private_keys/*.p8 ]; do
  sleep 1
done

# Set environment variables
cat >> ~/.zshrc <<EOF
export APP_STORE_CONNECT_API_KEY_KEY_ID="<from Apple>"
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="<from Apple>"
export APP_STORE_CONNECT_API_KEY_KEY_FILEPATH="$HOME/.appstoreconnect/private_keys/AuthKey_*.p8"
EOF

source ~/.zshrc
```

**Step 3: Validate Credentials Work**
```bash
# MUST verify before proceeding
fastlane run app_store_connect_api_key \
  key_id:"$APP_STORE_CONNECT_API_KEY_KEY_ID" \
  issuer_id:"$APP_STORE_CONNECT_API_KEY_ISSUER_ID" \
  key_filepath:"$APP_STORE_CONNECT_API_KEY_KEY_FILEPATH"

# Test API access
curl -H "Authorization: Bearer $(generate_token)" \
  https://api.appstoreconnect.apple.com/v1/apps

# Expected: 200 OK with app list
# If fails: STOP, fix credentials, retry
```

**Step 4: Configure Signing Certificates**
```bash
# Check existing certificates
security find-identity -v -p codesigning

# If missing development cert
fastlane cert development

# If missing distribution cert (for TestFlight/App Store)
fastlane cert distribution

# Verify installed
security find-identity -v -p codesigning | grep "iPhone Distribution"
# Must see: 1 valid certificate
```

**Step 5: Configure Provisioning Profiles**
```bash
# Get bundle ID from Xcode project
BUNDLE_ID=$(xcodebuild -showBuildSettings | grep PRODUCT_BUNDLE_IDENTIFIER | awk '{print $3}')

# Generate provisioning profiles
fastlane sigh --app_identifier "$BUNDLE_ID"

# Verify
ls ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision
# Must have: at least 1 profile for bundle ID
```

**Verification (MUST PASS):**
```bash
✓ API key file exists
✓ API key authenticates successfully
✓ Development certificate installed
✓ Distribution certificate installed
✓ Provisioning profiles generated
✓ Test build with codesign works
```

**Documentation Generated:**
- CODE_SIGNING_GUIDE.md (200-300 lines)
  - What was configured
  - Where credentials are stored
  - How to update/renew
  - Troubleshooting common issues

**Git Commit:**
```bash
git add .
git commit -m "chore: configure code signing for deployment"
```

**State File Updated:**
```json
{
  "phases": {
    "code_signing": {
      "status": "completed",
      "method": "api_key",
      "certificates": ["development", "distribution"],
      "profiles_generated": true,
      "verified": true
    }
  }
}
```

---

### Phase 2: Fastlane Installation & Basic Setup (5-10 min)

**Purpose:** Install Fastlane and create basic lane structure

**Detection:**
```bash
# Check if Fastlane already installed
command -v fastlane
fastlane --version

# Check for existing Fastfile
test -f ios/fastlane/Fastfile
```

**Questions (2):**
1. "Install Fastlane via?"
   - Homebrew (recommended for macOS)
   - RubyGems (system-wide)
   - Bundler (project-specific)

2. "Initial lanes to create?"
   - Basic (test, build, beta)
   - Full (test, build, beta, release, hotfix)
   - Minimal (beta only, add others later)

**Implementation:**

**Step 1: Install Fastlane**
```bash
# Install via chosen method
if [ "$METHOD" = "homebrew" ]; then
  brew install fastlane
elif [ "$METHOD" = "rubygems" ]; then
  sudo gem install fastlane
elif [ "$METHOD" = "bundler" ]; then
  cd ios
  bundle init
  echo 'gem "fastlane"' >> Gemfile
  bundle install
fi

# Verify installation
fastlane --version
# Expected: fastlane 2.228.0 or higher
```

**Step 2: Initialize Fastlane**
```bash
cd ios
fastlane init

# Select: "Automate App Store distribution"
# This creates:
# - fastlane/Fastfile (lane definitions)
# - fastlane/Appfile (Apple credentials)
```

**Step 3: Configure Appfile**
```ruby
# ios/fastlane/Appfile
apple_id ENV["FASTLANE_APPLE_ID"] || "your-email@example.com"
team_id ENV["FASTLANE_TEAM_ID"] || "YOUR_TEAM_ID"

# Get bundle ID from Xcode project
app_identifier CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier) || "com.company.app"
```

**Step 4: Create Basic Fastfile**
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  # Lane: Build only (no upload)
  desc "Build the iOS application"
  lane :build do
    UI.message "🔨 Building app..."
    build_app(
      workspace: "YourApp.xcworkspace",
      scheme: "YourApp",
      export_method: "app-store",
      clean: true
    )
    UI.success "✅ Build successful!"
  end

  # Lane: Deploy to TestFlight
  desc "Build and upload to TestFlight"
  lane :beta do
    # API key configuration
    api_key = app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_API_KEY_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"],
      key_filepath: ENV["APP_STORE_CONNECT_API_KEY_KEY_FILEPATH"]
    )

    # Increment build number
    increment_build_number

    # Build
    build

    # Upload
    UI.message "🚀 Uploading to TestFlight..."
    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: true
    )
    UI.success "✅ Uploaded to TestFlight!"
  end

  # Error handler
  error do |lane, exception|
    UI.error "❌ Lane '#{lane}' failed!"
    UI.error exception.message
  end
end
```

**Verification (MUST PASS):**
```bash
cd ios

# Verify Fastlane can parse Fastfile
fastlane lanes
# Expected: Shows list of lanes (build, beta)

# Verify Ruby syntax
ruby -c fastlane/Fastfile
# Expected: Syntax OK

# Test build lane (doesn't upload)
fastlane build
# Expected: Build completes successfully
```

**Documentation Generated:**
- FASTLANE_SETUP_GUIDE.md (250-350 lines)
  - Installation method used
  - Available lanes and what they do
  - How to add custom lanes
  - Configuration reference

**Git Commit:**
```bash
git add ios/fastlane ios/Gemfile ios/Gemfile.lock
git commit -m "feat: add Fastlane build automation"
```

---

### Phase 3: Quality Gates Integration (5-10 min)

**Purpose:** Add test enforcement that blocks deployment on failure

**Detection:**
```bash
# Detect test framework
test -f package.json && grep -q "jest" package.json  # Jest
test -f ios/*.xcodeproj && grep -q "XCTest"  # XCUITest
test -d .maestro  # Maestro
```

**Questions (1-2):**
1. "Which tests should block deployment?"
   - Unit tests only (fast, catches code issues)
   - Unit + E2E tests (comprehensive, slower)
   - Unit + E2E + Lint (strictest quality gate)

2. "Allow emergency bypass?" (optional)
   - Yes, with SKIP_TESTS=true flag (use sparingly)
   - No, tests always required (strictest)

**Implementation:**

**Step 1: Add Test Lane**
```ruby
# Add to ios/fastlane/Fastfile

lane :test do
  UI.message "🧪 Running tests..."

  # Run unit tests
  sh("cd ../.. && npm test -- --passWithNoTests")

  # Optional: Run E2E tests
  unless ENV['SKIP_E2E'] == 'true'
    sh("cd ../.. && maestro test .maestro/flows/")
  end

  UI.success "✅ All tests passed!"
end
```

**Step 2: Integrate into Beta Lane**
```ruby
lane :beta do
  # QUALITY GATE: Tests must pass
  UI.message "🔒 Quality Gate: Running tests..."
  test

  # Rest of beta lane...
  api_key = app_store_connect_api_key(...)
  increment_build_number
  build
  upload_to_testflight(...)
end
```

**Step 3: Test Quality Gate Blocks**
```bash
# Create failing test
echo "test('fails', () => { expect(true).toBe(false); });" >> src/__tests__/temp.test.js

# Try to deploy
cd ios && fastlane beta
# Expected: ❌ Blocks at quality gate, does NOT upload

# Remove failing test
rm src/__tests__/temp.test.js

# Try again
cd ios && fastlane beta
# Expected: ✅ Passes quality gate, proceeds to upload
```

**Verification (MUST PASS):**
```bash
✓ Test lane exists and runs
✓ Test lane returns correct exit codes
✓ Quality gate blocks on test failure
✓ Quality gate allows on test success
✓ No deployment occurs when tests fail
```

**Documentation Generated:**
- QUALITY_GATES_GUIDE.md (200-300 lines)
  - What quality gates are configured
  - How they block deployment
  - How to bypass (if allowed)
  - Testing the gates work

**Git Commit:**
```bash
git add ios/fastlane/Fastfile
git commit -m "feat: add quality gates to deployment pipeline"
```

---

### Phase 4: TestFlight/App Store Configuration (10-15 min)

**Purpose:** Configure deployment lanes and test upload

**Detection:**
```bash
# Check if app exists in App Store Connect
fastlane run app_exists app_identifier:"$BUNDLE_ID"

# Check build number
xcodebuild -showBuildSettings | grep CURRENT_PROJECT_VERSION
```

**Questions (2-3):**
1. "Automatic version management?"
   - Yes, auto-increment build numbers (recommended)
   - No, manual version control
   - Semantic versioning with tags

2. "TestFlight distribution?"
   - Internal testers only
   - Internal + External testers
   - External testers only

3. "App Store release lane?"
   - Create now (even if not using yet)
   - Skip for now (can add later)

**Implementation:**

**Step 1: Configure Automatic Versioning**
```ruby
# Add to beta lane
increment_build_number(
  xcodeproj: "YourApp.xcodeproj",
  build_number: latest_testflight_build_number + 1
)
```

**Step 2: Configure Beta Lane (Full)**
```ruby
lane :beta do
  # Quality gate
  test

  # API key
  api_key = app_store_connect_api_key(
    key_id: ENV["APP_STORE_CONNECT_API_KEY_KEY_ID"],
    issuer_id: ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"],
    key_filepath: ENV["APP_STORE_CONNECT_API_KEY_KEY_FILEPATH"]
  )

  # Auto-increment
  current_build = get_build_number
  new_build = (current_build.to_i + 1).to_s
  increment_build_number(build_number: new_build)

  # Build
  build_app(
    workspace: "YourApp.xcworkspace",
    scheme: "YourApp",
    export_method: "app-store"
  )

  # Upload
  upload_to_testflight(
    api_key: api_key,
    skip_waiting_for_build_processing: false,
    distribute_external: true,
    notify_external_testers: true,
    changelog: "Bug fixes and improvements"
  )

  # Git automation
  commit_version_bump(
    message: "chore: bump build to #{new_build}",
    xcodeproj: "YourApp.xcodeproj"
  )
  add_git_tag(tag: "testflight/#{new_build}")
  push_to_git_remote

  UI.success "✅ Build #{new_build} uploaded to TestFlight!"
end
```

**Step 3: Create Release Lane (Optional)**
```ruby
lane :release do
  # Quality gate
  test

  # Manual confirmation
  UI.important "⚠️  You are about to submit to App Store"
  UI.important "Press Enter to continue, Ctrl+C to cancel..."
  STDIN.gets

  # Similar to beta but for App Store
  api_key = app_store_connect_api_key(...)
  increment_build_number
  build_app(...)
  upload_to_app_store(
    api_key: api_key,
    skip_metadata: false,
    skip_screenshots: false,
    submit_for_review: false  # Manual submission
  )

  UI.success "✅ Submitted to App Store!"
  UI.message "Next: Go to App Store Connect to submit for review"
end
```

**Step 4: Test Upload to TestFlight**
```bash
cd ios
fastlane beta

# Expected:
# ✅ Tests pass
# ✅ Build succeeds
# ✅ Upload starts
# ✅ TestFlight receives build
# (May take 5-10 minutes to process)
```

**Verification (MUST PASS):**
```bash
✓ Build number auto-incremented
✓ Build uploaded to TestFlight
✓ Build appears in App Store Connect
✓ Version bump committed to git
✓ Git tag created
```

**Documentation Generated:**
- DEPLOYMENT_GUIDE.md (300-400 lines)
  - How to deploy to TestFlight
  - How to deploy to App Store
  - Version management strategy
  - Rollback procedures
  - TestFlight tester management

**Git Commit:**
```bash
git add ios/fastlane/Fastfile
git commit -m "feat: configure TestFlight and App Store deployment"
```

---

### Phase 5: CI/CD Integration (10-20 min, Optional)

**Purpose:** Automate deployment from CI/CD platform

**Detection:**
```bash
# Detect git hosting
git remote -v | grep github  # GitHub
git remote -v | grep gitlab  # GitLab
git remote -v | grep bitbucket  # Bitbucket

# Check for existing CI/CD config
test -f .github/workflows/*.yml  # GitHub Actions
test -f .gitlab-ci.yml  # GitLab CI
test -f bitrise.yml  # Bitrise
```

**Questions (3):**
1. "CI/CD platform?"
   - GitHub Actions (most common)
   - GitLab CI
   - Bitrise
   - CircleCI
   - Other/None

2. "Deployment trigger?"
   - Every push to main (continuous deployment)
   - Manual trigger only (workflow_dispatch)
   - On git tag (release tags)
   - On PR merge

3. "What to deploy?"
   - TestFlight only (beta testing)
   - App Store only (production)
   - Both (separate workflows)

**Implementation (GitHub Actions Example):**

**Step 1: Generate Workflow File**
```yaml
# .github/workflows/deploy-testflight.yml
name: Deploy to TestFlight

on:
  push:
    branches: [main]
  workflow_dispatch:  # Manual trigger

jobs:
  deploy:
    runs-on: macos-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm install

      - name: Install CocoaPods
        run: |
          cd ios
          pod install

      - name: Setup Fastlane
        run: |
          brew install fastlane

      - name: Deploy to TestFlight
        run: |
          cd ios
          fastlane beta
        env:
          FASTLANE_APPLE_ID: ${{ secrets.APPLE_ID }}
          FASTLANE_TEAM_ID: ${{ secrets.TEAM_ID }}
          APP_STORE_CONNECT_API_KEY_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.ASC_KEY_CONTENT }}
```

**Step 2: Configure Secrets**
```bash
echo "📋 Configure these secrets in GitHub:"
echo ""
echo "Repository → Settings → Secrets and variables → Actions"
echo ""
echo "Add these secrets:"
echo "  APPLE_ID = $FASTLANE_APPLE_ID"
echo "  TEAM_ID = $FASTLANE_TEAM_ID"
echo "  ASC_KEY_ID = $APP_STORE_CONNECT_API_KEY_KEY_ID"
echo "  ASC_ISSUER_ID = $APP_STORE_CONNECT_API_KEY_ISSUER_ID"
echo "  ASC_KEY_CONTENT = <contents of .p8 file>"
```

**Step 3: Test CI/CD Pipeline**
```bash
# Push to trigger workflow
git add .github/workflows/deploy-testflight.yml
git commit -m "ci: add GitHub Actions workflow for TestFlight"
git push origin main

# Monitor workflow
echo "Check: https://github.com/USER/REPO/actions"

# Expected:
# ✅ Workflow starts automatically
# ✅ Tests run in CI
# ✅ Build succeeds
# ✅ Upload to TestFlight
```

**Additional CI/CD Platforms:**

Create similar configurations for:
- GitLab CI (.gitlab-ci.yml)
- Bitrise (bitrise.yml)
- CircleCI (.circleci/config.yml)

**Verification (MUST PASS):**
```bash
✓ Workflow file created
✓ Secrets configured in CI platform
✓ Test commit triggers workflow
✓ Workflow runs successfully
✓ Build uploads to TestFlight
```

**Documentation Generated:**
- CI_CD_GUIDE.md (400-600 lines)
  - Platform-specific setup instructions
  - Secret configuration
  - Workflow customization
  - Troubleshooting CI issues
  - Multi-platform examples

**Git Commit:**
```bash
git add .github/workflows/
git commit -m "ci: add GitHub Actions deployment automation"
```

---

## Android Optional Path

After Phase 2 completes, Claude asks:

```
✅ iOS setup complete!

Do you also want to set up Android deployment?

Options:
1. Yes, set up Android now
2. No, iOS only
3. Maybe later (save progress, can resume)
```

### If "Yes, set up Android now":

**Phase 2b: Android Environment** (5-10 min)
- Verify Android SDK
- Configure signing keystore
- Set up Google Play Console access
- Output: ANDROID_SIGNING_GUIDE.md

**Phase 3b: Android Build Automation** (5-10 min)
- Add Gradle lanes to Fastlane OR
- Set up Gradle-only build
- Integrate with quality gates
- Output: ANDROID_BUILD_GUIDE.md

**Phase 4b: Google Play Deployment** (10-15 min)
- Configure Play Console API
- Set up deployment tracks
- Test upload
- Output: GOOGLE_PLAY_GUIDE.md

**Phase 5b: Multi-Platform CI/CD** (10-15 min)
- Update CI/CD for both platforms
- Configure platform-specific secrets
- Test dual-platform pipeline
- Output: Updates CI_CD_GUIDE.md

**Android adds:** 30-50 minutes

---

## Comprehensive Error Handling

### 1. Apple Credential Validation

**Before Phase 1 completes:**

```bash
# Test Apple ID works
fastlane run validate_apple_account

# Test API key works
curl -H "Authorization: Bearer $(generate_token)" \
  https://api.appstoreconnect.apple.com/v1/apps
# MUST return 200 OK

# Verify certificates valid
security find-identity -v -p codesigning
# MUST show at least 1 valid certificate

# Test provisioning profiles
security cms -D -i profile.mobileprovision
# MUST parse successfully

# Test code signing works
codesign -dv --verbose=4 ios/build/YourApp.app
# MUST verify successfully
```

**If ANY fail:** Stop, diagnose, fix, verify, retry

---

### 2. Interactive Troubleshooting

**Pattern for every error:**

1. **Detect error** - Parse command output
2. **Run diagnostics** - Automated checks
3. **Present findings** - Clear summary
4. **Suggest fixes** - 2-3 options
5. **Apply fix** - User chooses or auto-fix
6. **Re-test** - Verify fixed
7. **Continue** - Only if verified

**Example:**

```
❌ Error: Certificate "iPhone Distribution" expired

🔍 Diagnostics:
   - Certificate expired: 2025-10-15
   - New certificate available on Apple Portal
   - 3 provisioning profiles need update

💡 Suggested fixes:
   1. Auto-fix: Download + install new cert (2 min)
   2. Manual: I'll guide you through Apple Portal
   3. Skip: Continue without this certificate

[User chooses 1]

✓ Downloaded certificate from Apple
✓ Installed to Keychain
✓ Regenerated 3 provisioning profiles
✓ Verified: Valid until 2026-10-15

Continuing...
```

---

### 3. Rollback Scenarios

**Before each phase:**
```bash
# Create snapshot
git add -A
git commit -m "snapshot: before phase 3"
git tag "build-deploy-snapshot-phase3"

# Backup Xcode project
cp -r ios/YourApp.xcodeproj ios/.backup-phase3/

# Backup credentials
security export -k login.keychain > .backup-phase3/keychain.p12
```

**On failure:**
```
❌ Phase 3 failed

Options:
1. Fix and retry
2. Restart Phase 3
3. Rollback to Phase 2
4. Show logs

[User chooses 3]

🔄 Rolling back...
✓ Git: reset to snapshot-phase2
✓ Xcode: restored from backup
✓ Credentials: restored
✓ State: cleared phase 3

Ready to retry Phase 3?
```

**Test rollback:**
```bash
# After each phase
git reset --hard previous-snapshot
[verify project still works]
git reset --hard current-snapshot
```

---

### 4. Dry-Run Mode

**Usage:**
```bash
# Set before running
export DRY_RUN=true
# Then paste master-prompt.md
```

**Output:**
```
🔍 DRY-RUN MODE: Simulation only

Phase 1: Code Signing
   Would check: Keychain certificates
   Would create: API key
   Would configure: Provisioning profiles
   ✓ No issues detected

Phase 2: Fastlane
   Would install: via Homebrew
   Would create: Fastfile, Appfile
   ✓ No conflicts found

Phase 3: Quality Gates
   Would add: Test lane
   Would modify: Beta lane
   ✓ No issues

Phase 4: Deployment
   Would configure: TestFlight lane
   ⚠️  Warning: No app in App Store Connect
   💡 Create app first

Phase 5: CI/CD
   Would generate: .github/workflows/deploy.yml
   Would need: 5 secrets configured
   ✓ Ready

━━━━━━━━━━━━━━━━━━━━━━
Summary:
✓ 4 phases ready
⚠️  1 warning (Phase 4)
⏱  Est. time: 45-60 min
📝 Files to create: 15

Run for real? (Y/n)
```

---

### 5. Autonomous Validation Rules

**MANDATORY for Claude after EVERY step:**

**1. Verify change worked:**
```bash
# After adding test lane
fastlane lanes | grep "test"
# MUST see: fastlane ios test
```

**2. Test functionality:**
```bash
# After adding test lane
fastlane test
# MUST execute without crashing
```

**3. Check side effects:**
```bash
# After modifying Fastfile
ruby -c fastlane/Fastfile  # Syntax OK
git diff fastlane/Fastfile  # Show changes
```

**4. Document action:**
```
Step 3: Added test lane
- Modified: ios/fastlane/Fastfile (lines 15-20)
- Added: test lane running npm test
- Verified: fastlane lanes shows "test"
- Tested: fastlane test executes
- Result: ✅ Working correctly
```

**Claude CANNOT:**
- ❌ Assume command worked
- ❌ Skip verification
- ❌ Proceed on verification failure
- ❌ Batch changes before testing
- ❌ Mark complete without validation

**Claude MUST:**
- ✅ Run verification after EVERY change
- ✅ Check exit codes
- ✅ Parse output for success/fail
- ✅ Re-test if uncertain
- ✅ Show user what was verified

---

## State Management

**File:** `.build-deploy-setup-state.json`

```json
{
  "version": "1.0",
  "platform": "ios",
  "started_at": "2025-11-03T20:00:00Z",
  "last_updated": "2025-11-03T20:45:00Z",
  "phases": {
    "code_signing": {
      "status": "completed",
      "method": "api_key",
      "certificates": ["development", "distribution"],
      "profiles": 3,
      "verified": true,
      "completed_at": "2025-11-03T20:15:00Z"
    },
    "fastlane_setup": {
      "status": "completed",
      "version": "2.228.0",
      "install_method": "homebrew",
      "lanes_created": ["build", "beta"],
      "verified": true,
      "completed_at": "2025-11-03T20:25:00Z"
    },
    "quality_gates": {
      "status": "in_progress",
      "test_framework": "jest",
      "gates_configured": ["unit_tests"],
      "last_step": "testing_gate_blocks",
      "verified": false
    },
    "deployment": {"status": "pending"},
    "cicd": {"status": "pending"}
  },
  "git_commits": [
    "abc123: configure code signing",
    "def456: add Fastlane automation"
  ],
  "rollback_tags": [
    "build-deploy-snapshot-phase1",
    "build-deploy-snapshot-phase2"
  ],
  "android": {
    "requested": false
  }
}
```

**Resume Flow:**
```
User: [Re-runs prompt]

Claude: Found incomplete setup (45 minutes ago)

        ✓ Phase 1: Code signing
        ✓ Phase 2: Fastlane setup
        ❌ Phase 3: Quality gates (failed)
           Step: Testing gate blocks
           Error: Jest test failed

        Options:
        1. Continue from Phase 3, step 3
        2. Restart Phase 3 from beginning
        3. Rollback to Phase 2
        4. Start completely over

        Choose: _
```

---

## Documentation Generated

**Per Setup:**
1. CODE_SIGNING_GUIDE.md (200-300 lines)
2. FASTLANE_SETUP_GUIDE.md (250-350 lines)
3. QUALITY_GATES_GUIDE.md (200-300 lines)
4. DEPLOYMENT_GUIDE.md (300-400 lines)
5. CI_CD_GUIDE.md (400-600 lines, optional)

**Android adds:**
6. ANDROID_SIGNING_GUIDE.md (250-300 lines)
7. ANDROID_BUILD_GUIDE.md (200-300 lines)
8. GOOGLE_PLAY_GUIDE.md (300-400 lines)

**Total:** 1,550-2,450 lines (iOS only) or 2,300-3,450 lines (iOS + Android)

---

## Success Criteria

Setup complete when:

- ✅ All phases completed successfully
- ✅ Code signing verified working
- ✅ Fastlane lanes functional
- ✅ Quality gates tested and blocking
- ✅ Successfully deployed to TestFlight
- ✅ CI/CD pipeline tested (if configured)
- ✅ All documentation generated
- ✅ All changes committed to git
- ✅ State file shows all phases complete

---

## Time Estimates

**iOS Only:**
- Phase 1: 10-15 min
- Phase 2: 5-10 min
- Phase 3: 5-10 min
- Phase 4: 10-15 min
- Phase 5: 10-20 min (optional)
- **Total:** 40-70 minutes

**iOS + Android:**
- iOS phases: 40-70 min
- Android phases: 30-50 min
- **Total:** 70-120 minutes

---

## Design Status

✅ **Complete and validated**

**Next Step:** Create the actual prompt templates and skill files

**Estimated Implementation Time:** 8-12 hours for all phases and documentation
