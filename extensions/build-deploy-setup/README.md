# Build & Deploy Setup Guide

**Version:** 1.0
**Last Updated:** November 3, 2025
**Purpose:** Project-agnostic guide for setting up iOS (and optionally Android) build & deploy workflows with quality gates

---

## What This Is

A comprehensive, autonomous build & deploy workflow setup system that Claude developers can use to establish iOS deployment pipelines with minimal user input.

Supports:
- iOS deployment (TestFlight + App Store)
- Android deployment (Google Play) - optional
- Fastlane automation
- Quality gates (tests → build → upload)
- Code signing setup
- CI/CD integration (GitHub Actions, GitLab CI, Bitrise, etc.)

---

## Two Ways to Use This

### Option 1: Prompt-Based (No Framework Needed)

**Best for:** Anyone using Claude without the superpowers framework

1. Copy the contents of `prompts/master-prompt.md`
2. Paste into Claude
3. Answer 3-5 questions about your setup preferences
4. Claude sets up everything autonomously

**Time:** 30-60 minutes for complete iOS setup

### Option 2: Skill-Based (Superpowers Framework)

**Best for:** Users with the superpowers plugin installed

1. Copy the `skills/setup-build-deploy/` directory to your superpowers skills location
2. Run: `/setup-build-deploy`
3. Answer 3-5 questions about your setup preferences
4. Claude sets up everything with full skill integration

**Time:** 30-60 minutes for complete iOS setup

**Benefits:**
- TodoWrite tracking for each phase
- State file for resumability
- Integration with other superpowers skills
- Can resume if interrupted: `/setup-build-deploy --resume`

---

## What Gets Set Up

### Phase 1: Environment & Code Signing (10-15 min)

- Apple Developer account verification
- Code signing method selection (API Key, Manual, or Match)
- Certificate and provisioning profile setup
- Xcode configuration validation
- Credential verification (tests API access)

**Deliverable:** CODE_SIGNING_GUIDE.md (200-300 lines)

### Phase 2: Fastlane Installation & Setup (5-10 min)

- Fastlane installation
- Appfile and Fastfile creation
- Basic lanes (test, build, version)
- Version bumping automation
- iOS-specific configuration

**Deliverable:** FASTLANE_SETUP_GUIDE.md (250-350 lines)

### Phase 3: Quality Gates Integration (5-10 min)

- Test framework integration (Jest, XCTest)
- Quality gate lanes (block on test failure)
- Build verification
- Pre-deployment checks
- Automatic rollback on failure

**Deliverable:** QUALITY_GATES_GUIDE.md (200-300 lines)

### Phase 4: TestFlight/App Store Configuration (10-15 min)

- TestFlight beta deployment lane
- App Store release lane
- Metadata management
- Screenshot automation (optional)
- External tester groups

**Deliverable:** DEPLOYMENT_GUIDE.md (300-400 lines)

### Phase 5: CI/CD Integration (10-20 min, optional)

- Platform selection (GitHub Actions, GitLab CI, Bitrise, etc.)
- Secrets configuration
- Workflow file generation
- Trigger setup (push, tag, manual)
- Status badges

**Deliverable:** CI_CD_GUIDE.md (400-600 lines)

### Android Optional Path (if selected)

After Phase 2, can branch to Android setup:
- **Phase 2b:** Android environment setup (10-15 min)
- **Phase 3b:** Android build configuration (10-15 min)
- **Phase 4b:** Google Play deployment (10-15 min)
- **Phase 5b:** Multi-platform CI/CD (15-20 min)

**Total Android Deliverables:** 4 additional guides (800-1,200 lines)

---

## Total Documentation Generated

### iOS Only:
- 5 comprehensive guides
- 1,350-1,950 lines of documentation
- Customized for your project

### iOS + Android:
- 9 comprehensive guides
- 2,150-3,150 lines of documentation
- Dual-platform deployment workflows

---

## Quick Start

### Using Prompts

```bash
# 1. Navigate to your project directory
cd /path/to/your/project

# 2. Copy master-prompt.md contents
cat /path/to/build-deploy-setup/prompts/master-prompt.md

# 3. Paste into Claude and follow the prompts
```

### Using Skills

```bash
# 1. Install the skill (one time)
cp -r /path/to/build-deploy-setup/skills/setup-build-deploy ~/.claude/skills/

# 2. Navigate to your project directory
cd /path/to/your/project

# 3. Invoke the skill
# (In Claude) /setup-build-deploy
```

---

## What to Expect

### Initial Detection (Autonomous, 1-2 min)

Claude analyzes your project:
- Detects platform (iOS, React Native, Flutter, etc.)
- Identifies existing build configuration
- Checks for Fastlane/Xcode setup
- Verifies Apple Developer account status
- Shows summary of findings

### Configuration Questions (3-5 questions)

Claude asks targeted questions:
1. **Platform:** iOS only or iOS + Android?
2. **Code signing:** API Key, Manual, or Match?
3. **Deployment targets:** TestFlight, App Store, or both?
4. **CI/CD platform:** Which service to integrate?
5. **Android setup:** (if applicable) Google Play configuration?

All questions use `AskUserQuestion` with clear options and trade-offs.

### Phase-by-Phase Setup (Autonomous)

For each phase:
1. **Detection:** Analyze current state
2. **Pre-flight checks:** Validate requirements
3. **Implementation:** Execute setup steps
4. **Validation:** Verify everything works (NO ASSUMPTIONS)
5. **Documentation:** Generate phase-specific guide
6. **Commit:** Save progress to git
7. **Handoff:** Show what was done, what's next

### Verification Testing (Autonomous)

After each phase, Claude MUST verify:
- Commands execute successfully
- Configuration files are valid
- Credentials work (API calls succeed)
- Quality gates actually block deployment
- Documentation is accurate

**No phase is complete until verification passes.**

---

## Key Features

### 1. Autonomous Validation

Claude MUST after EVERY step:
- Run verification command
- Check exit codes
- Parse output for success/failure
- Re-test if uncertain
- Show user what was verified

Claude CANNOT:
- Assume command worked
- Skip verification
- Proceed on verification failure
- Batch changes before testing
- Mark complete without validation

### 2. Robust Error Handling

**Pre-Flight Checks:**
- Xcode installation and version
- Apple Developer account status
- Code signing certificates validity
- API key permissions
- Network connectivity
- Disk space (>10GB for builds)

**Interactive Troubleshooting:**
When errors occur:
1. **Detect:** Identify the specific failure
2. **Diagnose:** Analyze root cause
3. **Suggest:** Offer 2-3 fix options with trade-offs
4. **Fix:** Execute chosen solution
5. **Verify:** Confirm fix worked before proceeding

**Rollback Capabilities:**
Before each phase:
- Create git snapshot
- Tag with phase name
- Backup Xcode project
- Save current state

On failure:
- Offer rollback to previous phase
- Test rollback before using it
- Restore all configuration

**Dry-Run Mode:**
- Simulate entire setup without making changes
- Show what would be done
- Estimate time required
- Identify potential issues
- User can abort before commitment

### 3. Quality Gates That Actually Work

All quality gates are TESTED during setup:
1. Make a test fail
2. Run quality gate lane
3. Verify it blocks deployment
4. Fix the test
5. Run quality gate lane again
6. Verify it allows deployment

**No assumptions - everything is verified.**

### 4. Incremental Git Commits

Commits after each phase:
- `chore: configure iOS code signing with API key`
- `feat: add Fastlane configuration with quality gates`
- `feat: add TestFlight deployment lane`
- `docs: add comprehensive deployment guides`
- `ci: add GitHub Actions workflow for iOS deployment`

**Not just one commit at the end - incremental, revertible progress.**

### 5. State Management & Resume

The `.build-deploy-setup-state.json` file tracks:
- Which phases completed
- Platform choices (iOS/Android)
- Code signing method
- CI/CD platform
- Git commits made
- Rollback points available

Can resume from any interruption:
```bash
# Skill mode
/setup-build-deploy --resume

# Prompt mode
# Re-paste master-prompt.md
# Claude detects state file and offers to continue
```

---

## Success Criteria

Setup is complete when:

- ✅ Code signing configured and verified
- ✅ Fastlane installed with working lanes
- ✅ Quality gates block deployment on test failure
- ✅ Quality gates allow deployment when tests pass
- ✅ TestFlight deployment tested (dry-run or real)
- ✅ All documentation generated (5-9 guides)
- ✅ CI/CD workflow configured (if selected)
- ✅ All changes committed to git
- ✅ State file shows all phases complete

---

## Example Output

After iOS-only setup completes:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Build & Deploy Setup Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 What was set up:
- iOS code signing with App Store Connect API Key
- Fastlane with 5 lanes (test, build, version, beta, release)
- Quality gates that block deployment on test failures
- TestFlight deployment workflow
- GitHub Actions CI/CD pipeline
- Comprehensive documentation (5 guides, 1,687 lines)

🚀 Quick Start Commands:

Run tests:
$ cd ios && fastlane test

Build for release:
$ cd ios && fastlane build

Deploy to TestFlight:
$ cd ios && fastlane beta

Deploy to App Store:
$ cd ios && fastlane release

Bump version:
$ cd ios && fastlane version bump_type:patch

📚 Full Documentation:
- ios/fastlane/CODE_SIGNING_GUIDE.md
- ios/fastlane/FASTLANE_SETUP_GUIDE.md
- ios/fastlane/QUALITY_GATES_GUIDE.md
- ios/fastlane/DEPLOYMENT_GUIDE.md
- .github/workflows/CI_CD_GUIDE.md

🔐 Credentials Configured:
- App Store Connect API Key: ✅ Verified
- Distribution Certificate: ✅ Valid until 2026-11-03
- Provisioning Profile: ✅ Valid until 2026-11-03

📊 Next Steps:
1. Review CODE_SIGNING_GUIDE.md for credential management
2. Test deployment: cd ios && fastlane beta --dry-run
3. Configure TestFlight external testers in App Store Connect
4. Push to main branch to trigger CI/CD pipeline
```

---

## Time Estimates

### iOS Only Setup

| Phase | Time | What Happens |
|-------|------|--------------|
| Detection | 1-2 min | Project analysis |
| Questions | 2-3 min | User input |
| Phase 1 (Code Signing) | 10-15 min | Certificate setup + verification |
| Phase 2 (Fastlane) | 5-10 min | Installation + configuration |
| Phase 3 (Quality Gates) | 5-10 min | Test integration + verification |
| Phase 4 (Deployment) | 10-15 min | TestFlight/App Store setup |
| Phase 5 (CI/CD) | 10-20 min | Workflow generation + testing |
| **Total** | **45-75 min** | Includes verification at every step |

### iOS + Android Setup

| Phase | Time | What Happens |
|-------|------|--------------|
| iOS Setup | 45-75 min | As above |
| Android Environment | 10-15 min | SDK, JDK, signing |
| Android Build | 10-15 min | Gradle, Fastlane lanes |
| Google Play | 10-15 min | Service account, deployment |
| Multi-platform CI/CD | 15-20 min | Unified workflows |
| **Total** | **90-140 min** | Full dual-platform setup |

**Note:** Times include verification testing at every step. No assumptions are made - everything is validated.

---

## Comparison to Manual Setup

### Without This Guide:
- Research best practices (2-3 hours)
- Configure code signing (2-4 hours, often painful)
- Install and learn Fastlane (1-2 hours)
- Set up quality gates (1-2 hours)
- Configure TestFlight deployment (1-2 hours)
- Set up CI/CD (2-4 hours)
- Write documentation (2-3 hours)
- Debug issues (2-6 hours)
- **Total: 13-26 hours** (often spread over days)

### With This Guide:
- Copy prompt or invoke skill (10 seconds)
- Answer 3-5 questions (2-3 minutes)
- Wait for autonomous setup (40-70 minutes)
- Review and test (5-10 minutes)
- **Total: 45-75 minutes**

**Time saved:** 11.25-24.75 hours per project

---

## Platform Support

### Fully Supported:

- ✅ React Native + iOS
- ✅ Native iOS (Swift/Objective-C)
- ✅ Flutter + iOS
- ✅ React Native + Android (optional)
- ✅ Native Android (Kotlin/Java) (optional)
- ✅ Flutter + Android (optional)

### Partially Supported:

- ⚠️ Xamarin (Fastlane works, but needs manual tweaks)
- ⚠️ Cordova/Ionic (basic support)

### Not Supported:

- ❌ Desktop platforms (macOS, Windows, Linux)
- ❌ Web-only applications

---

## CI/CD Platform Support

Claude can generate workflows for:

- GitHub Actions
- GitLab CI
- Bitrise
- CircleCI
- Travis CI
- Jenkins
- Azure Pipelines
- AWS CodePipeline
- Custom (Claude helps adapt examples)

---

## Troubleshooting

### Issue: Code signing fails

**Solution:**
1. Claude will detect the specific error
2. Offer interactive troubleshooting
3. Suggest: regenerate certificate, update provisioning profile, or switch to Match
4. Verify fix before proceeding

### Issue: Fastlane installation fails

**Solution:**
1. Claude checks Ruby version
2. Suggests: system Ruby, rbenv, or rvm
3. Attempts installation with different methods
4. Verifies installation: `fastlane --version`

### Issue: Quality gate doesn't block deployment

**Solution:**
1. This is detected during Phase 3 verification
2. Claude fixes the Fastfile lane structure
3. Re-tests with failing test
4. Confirms blockage works before continuing

### Issue: Setup interrupted

**Solution (Skill users):**
Run `/setup-build-deploy --resume` to continue from where you left off.

**Solution (Prompt users):**
Re-paste the prompt. Claude will detect `.build-deploy-setup-state.json` and offer to continue.

### Issue: Apple Developer account not set up

**Solution:**
1. Claude detects during Phase 1 pre-flight checks
2. Provides step-by-step guide to create account
3. Waits for user confirmation
4. Verifies account access before proceeding

### Issue: Xcode command line tools missing

**Solution:**
```bash
# Claude runs this automatically:
xcode-select --install

# Verifies installation:
xcode-select -p
# Expected: /Applications/Xcode.app/Contents/Developer
```

---

## Error Handling Examples

### Apple Credential Validation

```bash
# Claude MUST verify credentials work before proceeding:

# Test 1: Validate API key format
✓ Key ID format: valid (10 characters)
✓ Issuer ID format: valid (UUID)
✓ Key file: exists and readable

# Test 2: Generate JWT token
✓ Token generated successfully

# Test 3: API call to App Store Connect
$ curl -H "Authorization: Bearer $TOKEN" \
  https://api.appstoreconnect.apple.com/v1/apps

✓ Response: 200 OK
✓ Apps returned: 3
✓ API access confirmed

Credentials verified. Proceeding to Phase 2...
```

### Interactive Troubleshooting

```
❌ Error: Build failed - Provisioning profile expired

🔍 Diagnostics:
   - Profile "iOS Team Provisioning Profile" expired: 2025-10-15
   - Certificate is still valid
   - 2 devices registered
   - New profile available on Apple Portal

💡 Suggested fixes:
   1. Auto-fix: Download + install new profile (1 min) [Recommended]
   2. Manual: I'll guide you through Apple Portal
   3. Match: Switch to automatic code signing with Match

Which option? [User chooses 1]

Downloading profile from Apple...
✓ Downloaded: iOS_Team_Provisioning_Profile.mobileprovision
✓ Installed to: ~/Library/MobileDevice/Provisioning Profiles/
✓ Verified expiration: 2026-10-15

Re-running build...
✓ Build successful!

Continuing to Phase 4...
```

### Rollback Example

```
⚠️  Phase 4 failed: TestFlight upload error

Current state:
- Phase 1: ✅ Complete
- Phase 2: ✅ Complete
- Phase 3: ✅ Complete
- Phase 4: ❌ Failed at upload step

Options:
1. Fix and retry Phase 4
2. Rollback to Phase 3 and try different approach
3. Show detailed error logs
4. Skip Phase 4 and continue to Phase 5

Which option? [User chooses 2]

Rolling back to Phase 3...
✓ Reset to snapshot: build-deploy-snapshot-phase3
✓ Restored Fastfile
✓ Restored state file
✓ Verified: All Phase 3 tests still pass

You're back at Phase 3. Would you like to:
1. Try a different deployment approach
2. Review TestFlight configuration
3. Check App Store Connect settings
```

---

## Dry-Run Mode

Before making any changes, run in dry-run mode:

```bash
# Skill mode
/setup-build-deploy --dry-run

# Prompt mode
# Add to first message: "Run in dry-run mode first"
```

**Dry-run shows:**
- What files will be created/modified
- What commands will be run
- What credentials are needed
- Estimated time for each phase
- Potential issues detected
- Total time estimate

**Example output:**
```
🔍 DRY-RUN MODE - No changes will be made

Phase 1: Environment & Code Signing (10-15 min)
  Would create:
    - ios/fastlane/CODE_SIGNING_GUIDE.md
  Would modify:
    - ios/YourApp.xcodeproj/project.pbxproj
  Would verify:
    - Apple Developer account access
    - API key permissions
    - Certificate validity

Phase 2: Fastlane Installation & Setup (5-10 min)
  Would install:
    - Fastlane via Homebrew
  Would create:
    - ios/fastlane/Appfile
    - ios/fastlane/Fastfile
    - ios/fastlane/FASTLANE_SETUP_GUIDE.md
  Would run:
    - fastlane init
    - fastlane test (verification)

[... continues for all phases ...]

Total estimated time: 45-75 minutes
Total files created: 5 documentation files + config files
Git commits: 5-7 incremental commits

Potential issues detected:
  ⚠️  Ruby version 2.6.10 is old (recommend 3.0+)
  ⚠️  Disk space: 8.2GB free (recommend 10GB+)

Proceed with actual setup? (yes/no)
```

---

## Advanced Features

### Automatic Version Bumping

```ruby
# Generated Fastfile includes version management:

lane :version do |options|
  bump_type = options[:bump_type] || "patch"

  increment_build_number(xcodeproj: "YourApp.xcodeproj")

  if bump_type != "build"
    increment_version_number(
      bump_type: bump_type,
      xcodeproj: "YourApp.xcodeproj"
    )
  end

  commit_version_bump(
    message: "chore: bump version to #{get_version_number}",
    xcodeproj: "YourApp.xcodeproj"
  )

  add_git_tag(tag: "v#{get_version_number}-#{get_build_number}")
  push_to_git_remote
end

# Usage:
# fastlane version bump_type:patch  # 1.0.0 -> 1.0.1
# fastlane version bump_type:minor  # 1.0.1 -> 1.1.0
# fastlane version bump_type:major  # 1.1.0 -> 2.0.0
# fastlane version bump_type:build  # Only bump build number
```

### Multi-Environment Support

Claude can configure multiple environments:
- Development (local testing)
- Staging (internal testers)
- Production (App Store)

Each with separate:
- Bundle identifiers
- Provisioning profiles
- API endpoints
- Feature flags

### Screenshot Automation

Optional screenshot generation for App Store:
- Delivers screenshots for all device sizes
- Uses Fastlane Snapshot
- Configures UI tests for screenshot capture
- Generates localized screenshots

### Metadata Management

App Store metadata in version control:
- App description
- Keywords
- Release notes
- Support URLs
- Privacy policy

All manageable via Fastlane Deliver.

---

## Security Best Practices

### Credentials Management

Claude will:
- ✅ Store API keys in environment variables
- ✅ Add sensitive files to .gitignore
- ✅ Use Keychain for certificates
- ✅ Encrypt credentials in CI/CD
- ✅ Recommend 1Password/dotenv for team sharing

Claude will NOT:
- ❌ Commit credentials to git
- ❌ Log sensitive information
- ❌ Share credentials in documentation
- ❌ Use weak encryption

### Code Signing Security

Recommended approach:
1. **API Key** (most secure): Store key file outside repo, use env vars
2. **Match** (team-friendly): Encrypted repository for certificates
3. **Manual** (legacy): Keychain-based, not recommended for teams

---

## Contributing

This is a project-agnostic build & deploy setup guide. Improvements welcome!

To improve:
1. Modify phase files in `prompts/` or `skills/`
2. Update design document if architecture changes
3. Test with real projects (iOS and Android)
4. Share your improvements

---

## Support

### Documentation

- **Design Document:** `2025-11-03-build-deploy-setup-guide-design.md` (complete architecture)
- **Getting Started:** `GETTING-STARTED.md` (quick start guide)
- **Deliverables:** `DELIVERABLES.md` (what gets created)

### Common Questions

**Q: Can I use this for an existing project with Fastlane already set up?**
A: Yes! Claude detects existing Fastlane and offers to enhance it rather than replace it.

**Q: Do I need a paid Apple Developer account?**
A: Yes, for TestFlight and App Store deployment. But Phase 1-3 can work with free account for local testing.

**Q: Can I skip phases?**
A: Yes, especially Phase 5 (CI/CD). But Phases 1-4 build on each other.

**Q: What if I use a different code signing approach?**
A: Claude supports API Key, Manual, and Match. Choose during Phase 1.

**Q: Can I add custom Fastlane lanes?**
A: Absolutely! Claude generates a foundation. You can extend it.

**Q: Does this work with Expo?**
A: Yes! Claude detects Expo and uses `eas-cli` instead of raw Xcode commands where appropriate.

---

## License

MIT - Use freely in any project

---

## Quick Reference

**For prompt users:**
```
Copy: prompts/master-prompt.md
Paste: Into Claude
Result: Complete iOS deployment setup in 45-75 minutes
```

**For skill users:**
```
Install: cp -r skills/setup-build-deploy ~/.claude/skills/
Invoke: /setup-build-deploy
Result: Complete iOS deployment setup in 45-75 minutes with TodoWrite tracking
```

**For resume:**
```
Skill: /setup-build-deploy --resume
Prompt: Re-paste master-prompt.md, Claude detects state file
```

**For dry-run:**
```
Skill: /setup-build-deploy --dry-run
Prompt: Add "--dry-run" to first message
```

---

## What You'll Have When Done

After completing the setup, your project will have:

### Configuration Files
- `ios/fastlane/Appfile` - App identifier and Apple ID
- `ios/fastlane/Fastfile` - All deployment lanes
- `ios/fastlane/Matchfile` - Code signing config (if using Match)
- `.build-deploy-setup-state.json` - Setup state tracking
- `.github/workflows/ios-deploy.yml` - CI/CD workflow (if selected)

### Documentation (1,350-1,950 lines)
- `ios/fastlane/CODE_SIGNING_GUIDE.md` - Certificate and profile management
- `ios/fastlane/FASTLANE_SETUP_GUIDE.md` - Lane reference and customization
- `ios/fastlane/QUALITY_GATES_GUIDE.md` - Testing and quality checks
- `ios/fastlane/DEPLOYMENT_GUIDE.md` - TestFlight and App Store deployment
- `.github/workflows/CI_CD_GUIDE.md` - CI/CD configuration and usage

### Fastlane Lanes
- `test` - Run all tests with quality gate
- `build` - Build for release
- `version` - Bump version numbers
- `beta` - Deploy to TestFlight
- `release` - Deploy to App Store
- `screenshots` - Generate App Store screenshots (if configured)

### Verified Working
- ✅ Code signing credentials
- ✅ Quality gates that block on failure
- ✅ TestFlight deployment (tested via dry-run or real upload)
- ✅ CI/CD pipeline (if configured)
- ✅ All documentation accurate and complete

**You'll be able to deploy to TestFlight with one command:**
```bash
cd ios && fastlane beta
```

**Time from commit to TestFlight:** ~10 minutes
**Time saved on future deployments:** ~30-60 minutes each
