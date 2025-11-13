# Phase Implementation Files - Structure Guide

**Purpose:** This document describes the structure and content pattern for phase implementation files

---

## Completed Phase Files

### ✅ phase1-code-signing.md (Complete - 500+ lines)

**Location:** `skills/setup-build-deploy/phases/phase1-code-signing.md`

**Structure:**
- Overview and goals
- Pre-flight checks (Xcode, disk space, git, etc.)
- Project detection (React Native, Flutter, native iOS, Expo)
- Apple Developer account verification
- Code signing method selection (API Key, Manual, Match)
- Detailed configuration for each method
- Credential verification (actual API tests)
- Documentation generation (CODE_SIGNING_GUIDE.md template)
- Git commit
- Verification checklist
- Troubleshooting guide

**Key Features:**
- Complete bash scripts for all checks
- Interactive troubleshooting patterns
- AskUserQuestion JSON examples
- Verification commands with expected outputs
- Error handling for common issues
- Full documentation template

---

## Remaining Phase Files (To Be Created)

The following files follow the same pattern as phase1-code-signing.md:

### phase2-fastlane-setup.md

**Estimated:** 400-450 lines

**Contents:**
- Pre-flight checks (Ruby, Bundler, gems)
- Fastlane installation (Homebrew vs gem)
- Appfile creation (app identifier, Apple ID, team ID)
- Fastfile creation with lanes:
  - `test`: Run all tests
  - `build`: Build for release
  - `version`: Bump version numbers
  - Base structure for beta/release (added in Phase 3/4)
- Verification:
  - `fastlane --version` check
  - `fastlane lanes` lists all lanes
  - `ruby -c fastlane/Fastfile` syntax check
  - `fastlane test` actually runs
- FASTLANE_SETUP_GUIDE.md template
- Git commit
- Troubleshooting

**Fastfile Base Template:**
```ruby
default_platform(:ios)

platform :ios do
  desc "Run all tests"
  lane :test do
    # Detect test type (Jest, XCTest, etc.)
    # Run appropriate test command
    # Fail if tests fail
  end

  desc "Build app for release"
  lane :build do
    # Will add quality gate in Phase 3
    build_app(
      workspace: "[WORKSPACE]",
      scheme: "[SCHEME]",
      export_method: "app-store",
      clean: true
    )
  end

  desc "Bump version number"
  lane :version do |options|
    bump_type = options[:bump_type] || "patch"
    increment_build_number
    if bump_type != "build"
      increment_version_number(bump_type: bump_type)
    end
    commit_version_bump
    add_git_tag
  end
end
```

---

### phase3-quality-gates.md

**Estimated:** 400-450 lines

**Contents:**
- Detect test framework (Jest, XCTest, Detox, etc.)
- Update `test` lane to fail on test failure
- Create `beta` lane with quality gate:
  ```ruby
  lane :beta do
    UI.message "🔒 Quality Gate: Running tests..."
    test  # Blocks if tests fail

    increment_build_number
    build_app(...)
    # Upload added in Phase 4
  end
  ```
- Create `release` lane with quality gate
- **CRITICAL: Test quality gates**
  1. Make a test fail intentionally
  2. Run `fastlane beta`
  3. Verify deployment blocked
  4. Fix test
  5. Run `fastlane beta` again
  6. Verify deployment proceeds
- QUALITY_GATES_GUIDE.md template (with test results)
- Git commit
- Troubleshooting

**Verification Script:**
```bash
# Create temporary failing test
echo "test('should fail', () => { expect(true).toBe(false); });" >> __tests__/temp.test.js

# Run beta lane - should fail
cd ios && fastlane beta
if [ $? -eq 0 ]; then
  echo "✗ Quality gate FAILED - deployment proceeded despite failing test"
  exit 1
else
  echo "✓ Quality gate PASSED - deployment blocked"
fi

# Remove failing test
rm __tests__/temp.test.js

# Run beta lane again - should succeed
cd ios && fastlane beta
if [ $? -eq 0 ]; then
  echo "✓ Quality gate PASSED - deployment allowed with passing tests"
else
  echo "✗ Quality gate FAILED - deployment blocked despite passing tests"
  exit 1
fi
```

---

### phase4-deployment.md

**Estimated:** 450-500 lines

**Contents:**
- Update `beta` lane for TestFlight upload:
  ```ruby
  lane :beta do
    test  # Quality gate

    increment_build_number

    build_app(
      workspace: "[WORKSPACE]",
      scheme: "[SCHEME]",
      export_method: "app-store",
      clean: true
    )

    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: false,
      distribute_external: true,
      notify_external_testers: true,
      changelog: "Bug fixes and improvements"
    )

    commit_version_bump
    add_git_tag
  end
  ```
- Update `release` lane for App Store:
  ```ruby
  lane :release do |options|
    test  # Quality gate

    bump_type = options[:bump_type] || "patch"
    version bump_type: bump_type

    build_app(...)

    upload_to_app_store(
      api_key: api_key,
      skip_metadata: true,
      skip_screenshots: true,
      submit_for_review: false,  # Manual submission
      automatic_release: false
    )
  end
  ```
- API key helper:
  ```ruby
  def api_key
    app_store_connect_api_key(
      key_id: ENV['APP_STORE_CONNECT_API_KEY_KEY_ID'],
      issuer_id: ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'],
      key_filepath: ENV['APP_STORE_CONNECT_API_KEY_KEY_FILEPATH']
    )
  end
  ```
- Test with dry-run (if available) or explain steps
- DEPLOYMENT_GUIDE.md template
- Git commit
- Troubleshooting

---

### phase5-cicd.md

**Estimated:** 500-550 lines

**Contents:**
- Ask user for CI/CD platform (AskUserQuestion)
- Generate workflow file based on platform

**GitHub Actions Example:**
```yaml
name: iOS Deployment

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test

  deploy:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: npm install

      - name: Set up Fastlane
        run: |
          brew install fastlane
          cd ios && bundle install

      - name: Deploy to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY_KEY }}
        run: |
          echo "$APP_STORE_CONNECT_API_KEY_KEY" > /tmp/key.p8
          export APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=/tmp/key.p8
          cd ios && fastlane beta
```

- Document required secrets
- Validate workflow syntax
- CI_CD_GUIDE.md template
- Git commit
- Troubleshooting for CI/CD issues

**Also generate for:**
- GitLab CI (.gitlab-ci.yml)
- Bitrise (bitrise.yml)
- CircleCI (.circleci/config.yml)

---

## Android Phase Files (Optional)

### phase2b-android-environment.md

**Estimated:** 400-450 lines

**Contents:**
- Check for Android SDK
- Check for JDK (Java 11 or later)
- Verify Gradle
- Configure signing keystore:
  ```bash
  keytool -genkey -v -keystore android/app/release.keystore \
    -alias release -keyalg RSA -keysize 2048 -validity 10000
  ```
- Update android/gradle.properties with keystore info
- Add Fastlane for Android platform
- ANDROID_CODE_SIGNING_GUIDE.md template
- Git commit

---

### phase3b-android-build.md

**Estimated:** 400-450 lines

**Contents:**
- Add Android lanes to Fastfile:
  ```ruby
  platform :android do
    desc "Run Android tests"
    lane :test do
      gradle(task: "test")
    end

    desc "Build Android APK"
    lane :build do
      test  # Quality gate
      gradle(
        task: "bundle",
        build_type: "Release"
      )
    end
  end
  ```
- Quality gates for Android
- ANDROID_FASTLANE_SETUP_GUIDE.md template
- Git commit

---

### phase4b-google-play.md

**Estimated:** 450-500 lines

**Contents:**
- Set up Google Play service account
- Download JSON key file
- Configure Fastlane with Google Play:
  ```ruby
  lane :beta do
    test
    build

    upload_to_play_store(
      track: 'beta',
      json_key: ENV['GOOGLE_PLAY_JSON_KEY_PATH']
    )
  end
  ```
- ANDROID_DEPLOYMENT_GUIDE.md template
- Git commit

---

### phase5b-multiplatform-cicd.md

**Estimated:** 500-550 lines

**Contents:**
- Update CI/CD workflow for both platforms
- Matrix builds:
  ```yaml
  strategy:
    matrix:
      platform: [ios, android]
  ```
- Platform-specific steps
- Conditional deployment
- MULTIPLATFORM_CI_CD_GUIDE.md template
- Git commit

---

## Common Structure for All Phase Files

Each phase file should include:

### 1. Header Section
- Phase number and name
- Estimated time
- Goal statement

### 2. Overview
- What this phase does
- Why it's important
- Dependencies on previous phases

### 3. Pre-Flight Checks
- Environment verification
- Required tools check
- Previous phase validation

### 4. Step-by-Step Implementation
- Numbered steps (Step 1, Step 2, etc.)
- Bash scripts with comments
- Expected output documented
- Error handling for each step

### 5. Interactive Questions
- AskUserQuestion JSON examples
- Options with descriptions and trade-offs
- Handle all possible responses

### 6. Verification Section
- Commands to verify each change
- Expected vs actual output comparison
- Checklist format

### 7. Documentation Template
- Full markdown template for generated guide
- Include all configuration details
- Troubleshooting section
- Examples and usage

### 8. Git Commit
- Commit message template
- What to stage
- Verification before commit

### 9. Troubleshooting
- Common issues
- Error messages with solutions
- Alternative approaches

### 10. Completion Summary
- What was accomplished
- Verification checklist
- Next phase preview
- State file update

---

## Implementation Notes

### Verification is Critical

Every phase file MUST include:
- Commands to verify changes
- Expected output documented
- Actual testing (not assumptions)
- Exit code checks
- Rollback procedures if verification fails

### Interactive Troubleshooting Pattern

When errors occur:
```
❌ Error: [specific error message]

🔍 Diagnostics:
   - [What was checked]
   - [What was found]
   - [Root cause analysis]

💡 Suggested fixes:
   1. [Auto-fix option] - [description] - [time estimate]
   2. [Manual option] - [user steps needed]
   3. [Alternative] - [different approach]

[Present via AskUserQuestion]
```

### Documentation Templates

Each phase generates a guide. Templates should include:
- Current configuration summary
- Step-by-step usage instructions
- Examples with expected output
- Troubleshooting common issues
- Security best practices
- Next steps

---

## File Locations

```
skills/setup-build-deploy/phases/
├── phase1-code-signing.md           ✅ COMPLETE (500+ lines)
├── phase2-fastlane-setup.md         📝 To create (400-450 lines)
├── phase3-quality-gates.md          📝 To create (400-450 lines)
├── phase4-deployment.md             📝 To create (450-500 lines)
├── phase5-cicd.md                   📝 To create (500-550 lines)
└── android/
    ├── phase2b-android-environment.md   📝 To create (400-450 lines)
    ├── phase3b-android-build.md         📝 To create (400-450 lines)
    ├── phase4b-google-play.md           📝 To create (450-500 lines)
    └── phase5b-multiplatform-cicd.md    📝 To create (500-550 lines)
```

**Total estimated:** 3,900-4,400 lines for remaining phase files

---

## Usage

These phase files are loaded by the SKILL.md when the skill is invoked. Each phase:

1. Reads the corresponding phase file
2. Executes the steps autonomously
3. Verifies every change
4. Generates documentation
5. Commits to git
6. Updates state file
7. Proceeds to next phase

The master-prompt.md already contains condensed versions of all phase instructions, so the system is usable now. These detailed phase files provide even more comprehensive step-by-step guidance.

---

## Future Enhancements

Potential additions:
- Screenshot automation setup (Fastlane Snapshot)
- Metadata management (Fastlane Deliver)
- tvOS and watchOS phases
- App clips deployment
- Widget deployment
- Notification service extensions

---

**Status:** Phase 1 complete, remaining 8 phase files follow this structure
