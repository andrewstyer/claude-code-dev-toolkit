---
name: setup-build-deploy
description: Use to set up automated iOS (and optionally Android) build & deploy workflows with Fastlane, quality gates, and CI/CD integration - autonomous setup with minimal user input
---

# Build & Deploy Setup Skill

## When to Use This Skill

Use this skill when:
- Starting an iOS or React Native project that needs deployment automation
- Setting up TestFlight or App Store deployment workflows
- Adding quality gates to prevent shipping broken code
- Configuring CI/CD for automated deployments
- Replacing manual deployment processes with one-command automation

**Time to complete:** 45-75 minutes for iOS, 90-140 minutes for iOS + Android

## What This Skill Does

Sets up complete build and deploy automation including:
- Code signing configuration (certificates, profiles, API keys)
- Fastlane installation and lane setup
- Quality gates that block deployment when tests fail
- TestFlight and App Store deployment workflows
- Optional CI/CD integration (GitHub Actions, GitLab CI, etc.)
- Comprehensive documentation (5-9 guides, 1,350-3,150 lines)

## Core Principles

This skill operates autonomously with these non-negotiable rules:

1. **VERIFY EVERYTHING**: Never assume a command worked. Always check exit codes and parse output.
2. **NO ASSUMPTIONS**: If you didn't test it, it doesn't work.
3. **INCREMENTAL PROGRESS**: Complete each phase fully before moving to the next.
4. **TEST QUALITY GATES**: Don't just create gates - verify they actually block deployment.
5. **DOCUMENT AS YOU GO**: Generate guides during phases, not at the end.

## Usage

### Basic Invocation

```
/setup-build-deploy
```

Claude will:
1. Analyze your project (detect React Native, native iOS, Flutter, etc.)
2. Ask 3-5 questions about your preferences
3. Execute 5 phases autonomously
4. Verify everything works
5. Generate comprehensive documentation

### Resume from Interruption

```
/setup-build-deploy --resume
```

Continues from last successful phase using `.build-deploy-setup-state.json`.

### Dry-Run Mode

```
/setup-build-deploy --dry-run
```

Shows what would be done without making changes. Useful for:
- Understanding what will happen
- Identifying potential issues
- Estimating time required

### Add Android Later

```
/setup-build-deploy --add-platform android
```

Adds Android deployment to existing iOS setup.

## Setup Phases

### Phase 1: Environment & Code Signing (10-15 min)

**What happens:**
- Verify Apple Developer account
- Choose code signing method (API Key, Manual, or Match)
- Set up certificates and provisioning profiles
- **VERIFY:** Test API credentials with actual API call
- **VERIFY:** Check certificate expiration dates
- Generate CODE_SIGNING_GUIDE.md (200-300 lines)
- Commit: "chore: configure iOS code signing"

**TodoWrite tracking:**
- [ ] Detect project type
- [ ] Verify Apple Developer account
- [ ] Configure code signing
- [ ] Verify credentials work
- [ ] Generate documentation
- [ ] Commit changes

### Phase 2: Fastlane Installation & Setup (5-10 min)

**What happens:**
- Install Fastlane (if not already installed)
- Create Appfile and Fastfile
- Create lanes: test, build, version, beta, release
- **VERIFY:** Run `fastlane test` and confirm it works
- **VERIFY:** Check Fastfile syntax is valid
- Generate FASTLANE_SETUP_GUIDE.md (250-350 lines)
- Commit: "feat: add Fastlane configuration"

**TodoWrite tracking:**
- [ ] Check/install Fastlane
- [ ] Create Appfile
- [ ] Create Fastfile with lanes
- [ ] Verify lanes work
- [ ] Generate documentation
- [ ] Commit changes

### Phase 3: Quality Gates Integration (5-10 min)

**What happens:**
- Integrate test framework (Jest, XCTest)
- Add quality gates to block deployment on test failure
- **VERIFY:** Make test fail, run `fastlane beta`, confirm blocking
- **VERIFY:** Fix test, run `fastlane beta`, confirm it proceeds
- Generate QUALITY_GATES_GUIDE.md (200-300 lines)
- Commit: "feat: add quality gates to block deployment"

**TodoWrite tracking:**
- [ ] Detect test framework
- [ ] Update test lane
- [ ] Add quality gates to beta/release lanes
- [ ] TEST: Verify blocking on failure
- [ ] TEST: Verify allowing on success
- [ ] Generate documentation
- [ ] Commit changes

### Phase 4: TestFlight/App Store Configuration (10-15 min)

**What happens:**
- Configure TestFlight deployment lane
- Configure App Store release lane
- Add automatic version bumping
- **VERIFY:** Test deployment with dry-run
- **VERIFY:** Confirm API access to App Store Connect
- Generate DEPLOYMENT_GUIDE.md (300-400 lines)
- Commit: "feat: add TestFlight and App Store deployment"

**TodoWrite tracking:**
- [ ] Configure beta lane (TestFlight)
- [ ] Configure release lane (App Store)
- [ ] Add version bumping
- [ ] Verify deployment workflow
- [ ] Generate documentation
- [ ] Commit changes

### Phase 5: CI/CD Integration (10-20 min, optional)

**What happens:**
- Generate workflow file for chosen platform (GitHub Actions, GitLab CI, etc.)
- Document required secrets
- Configure triggers (push, tags, manual)
- **VERIFY:** Validate workflow file syntax
- **VERIFY:** All secrets documented
- Generate CI_CD_GUIDE.md (400-600 lines)
- Commit: "ci: add [platform] workflow"

**TodoWrite tracking:**
- [ ] Generate workflow file
- [ ] Document secrets configuration
- [ ] Configure triggers
- [ ] Validate workflow syntax
- [ ] Generate documentation
- [ ] Commit changes

### Android Optional Phases (if selected)

After Phase 2, can branch to Android:

**Phase 2b: Android Environment (10-15 min)**
- Verify JDK and Android SDK
- Configure signing keystore
- Set up Fastlane for Android
- Generate ANDROID_CODE_SIGNING_GUIDE.md

**Phase 3b: Android Build (10-15 min)**
- Add Android lanes (test, build, version)
- Configure quality gates
- Generate ANDROID_FASTLANE_SETUP_GUIDE.md

**Phase 4b: Google Play (10-15 min)**
- Set up Google Play API access
- Add deployment lanes (internal, beta, production)
- Generate ANDROID_DEPLOYMENT_GUIDE.md

**Phase 5b: Multi-platform CI/CD (15-20 min)**
- Update CI/CD for both platforms
- Add matrix builds
- Generate MULTIPLATFORM_CI_CD_GUIDE.md

## Questions This Skill Asks

Use `AskUserQuestion` for ALL questions:

**Question 1: Platform** (Required)
- iOS only
- iOS + Android

**Question 2: Code Signing** (Required for iOS)
- App Store Connect API Key (recommended)
- Manual (use existing certificates)
- Match (team-based)

**Question 3: Deployment Targets** (Required)
- TestFlight only
- App Store only
- Both (recommended)

**Question 4: CI/CD** (Optional)
- GitHub Actions
- GitLab CI
- Bitrise
- Other
- None

**Question 5: Android Setup** (Only if iOS + Android selected)
- Yes - full Google Play deployment
- No - build only

## Verification Requirements

This skill MUST verify every step. No exceptions.

### After Code Signing Setup

```bash
# MUST verify API credentials work
curl -H "Authorization: Bearer $TOKEN" \
  https://api.appstoreconnect.apple.com/v1/apps
# Expected: 200 OK

# MUST verify certificates not expired
security find-identity -v -p codesigning
# Expected: Valid certificates listed
```

### After Fastlane Setup

```bash
# MUST verify Fastlane installed
fastlane --version
# Expected: Version number displayed

# MUST verify Fastfile syntax
ruby -c ios/fastlane/Fastfile
# Expected: "Syntax OK"

# MUST verify test lane works
cd ios && fastlane test
# Expected: Tests run successfully
```

### After Quality Gates

```bash
# MUST verify gates block on failure
# 1. Make a test fail
# 2. Run: cd ios && fastlane beta
# 3. Verify: Deployment blocked

# MUST verify gates allow on success
# 1. Fix the test
# 2. Run: cd ios && fastlane beta
# 3. Verify: Deployment proceeds
```

### After Deployment Setup

```bash
# MUST verify deployment workflow
cd ios && fastlane beta --dry-run
# Expected: No errors (or clear next steps if dry-run not supported)

# MUST verify API access
fastlane run app_store_connect_api_key ...
# Expected: Success
```

### After CI/CD Setup

```bash
# MUST verify workflow file syntax
# GitHub Actions:
cat .github/workflows/ios-deploy.yml | docker run --rm -i rhysd/actionlint -
# Expected: No errors
```

**If ANY verification fails, STOP and troubleshoot before proceeding.**

## Error Handling

### Pre-Flight Checks

Before each phase, verify:

**Phase 1:**
- [ ] Xcode installed: `xcodebuild -version`
- [ ] 10GB+ disk space: `df -h`
- [ ] Git repository initialized
- [ ] Apple Developer account accessible

**Phase 2:**
- [ ] Ruby >= 2.5: `ruby --version`
- [ ] Bundler installed: `bundle --version`
- [ ] Xcode command line tools: `xcode-select -p`

**Phase 3:**
- [ ] Tests exist and run
- [ ] Test framework detected

**Phase 4:**
- [ ] App Store Connect API access verified
- [ ] Bundle identifier configured

**Phase 5:**
- [ ] CI/CD platform account exists
- [ ] Repository connected

### Interactive Troubleshooting

When errors occur:

```
❌ Error: [specific error]

🔍 Diagnostics:
   - [What was checked]
   - [What was found]
   - [Root cause]

💡 Suggested fixes:
   1. [Auto-fix option] - [description] - [time] [Recommended]
   2. [Manual option] - [description]
   3. [Alternative approach] - [description]

[Use AskUserQuestion with these options]
```

### Rollback Strategy

Before each phase:
```bash
git add -A
git commit -m "snapshot: before phase [N]"
git tag "build-deploy-snapshot-phase[N]"
```

On failure, offer:
1. Fix and retry
2. Rollback to previous phase
3. Show detailed error logs
4. Skip phase (if optional)

## State Management

Create and maintain `.build-deploy-setup-state.json`:

```json
{
  "version": "1.0",
  "started_at": "2025-11-03T20:00:00Z",
  "platform": "ios",
  "code_signing_method": "api_key",
  "deployment_targets": ["testflight", "app_store"],
  "ci_cd_platform": "github_actions",
  "phases": {
    "code_signing": {
      "status": "completed",
      "completed_at": "2025-11-03T20:15:00Z",
      "verified": true
    },
    "fastlane_setup": {
      "status": "in_progress",
      "started_at": "2025-11-03T20:15:00Z"
    }
  },
  "git_commits": ["abc123", "def456"],
  "rollback_points": ["build-deploy-snapshot-phase1"]
}
```

Update after every phase.

## TodoWrite Integration

Create TodoWrite entries for:
1. Overall phase progress (5 main phases)
2. Individual steps within each phase
3. Verification checks
4. Documentation generation

Example:
```
Phase 1: Code Signing (in_progress)
├─ Detect project type (completed)
├─ Verify Apple account (completed)
├─ Configure API key (in_progress)
├─ Verify credentials (pending)
├─ Generate docs (pending)
└─ Commit (pending)
```

Mark todos complete IMMEDIATELY after finishing (don't batch).

## Documentation Generation

This skill generates 5-9 comprehensive guides:

**iOS Setup (always generated):**
1. CODE_SIGNING_GUIDE.md (200-300 lines)
2. FASTLANE_SETUP_GUIDE.md (250-350 lines)
3. QUALITY_GATES_GUIDE.md (200-300 lines)
4. DEPLOYMENT_GUIDE.md (300-400 lines)
5. CI_CD_GUIDE.md (400-600 lines, if CI/CD configured)

**Android Setup (if selected):**
6. ANDROID_CODE_SIGNING_GUIDE.md (200-300 lines)
7. ANDROID_FASTLANE_SETUP_GUIDE.md (250-350 lines)
8. ANDROID_DEPLOYMENT_GUIDE.md (300-400 lines)
9. MULTIPLATFORM_CI_CD_GUIDE.md (400-600 lines)

All documentation is:
- ✅ Comprehensive (includes examples, troubleshooting)
- ✅ Accurate (reflects actual setup)
- ✅ Actionable (clear commands and steps)
- ✅ Verified (matches actual configuration)

## Git Workflow

Commit after EACH phase:

```bash
# Phase 1
git add -A
git commit -m "chore: configure iOS code signing with API key"

# Phase 2
git add -A
git commit -m "feat: add Fastlane configuration with quality gates"

# Phase 3
git add -A
git commit -m "feat: add quality gates to block deployment on test failure"

# Phase 4
git add -A
git commit -m "feat: add TestFlight and App Store deployment workflows"

# Phase 5
git add -A
git commit -m "ci: add GitHub Actions workflow for iOS deployment"
```

**Do NOT wait until the end to commit. Incremental commits allow rollback.**

## Success Criteria

Setup is complete when:

- ✅ All phases completed successfully
- ✅ All verification tests passed (no assumptions)
- ✅ Quality gates tested (both blocking and allowing)
- ✅ All documentation generated (5-9 guides)
- ✅ All changes committed to git (5-7 commits)
- ✅ State file shows complete status
- ✅ User can deploy with: `cd ios && fastlane beta`

## Final Handoff

After completion, show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Build & Deploy Setup Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 What was set up:
- iOS code signing: [method]
- Fastlane lanes: [list]
- Quality gates: ✅ Verified
- Deployment: [targets]
- CI/CD: [platform or "Not configured"]
- Documentation: [N] guides, [X,XXX] lines

🚀 Quick Start Commands:
$ cd ios && fastlane test
$ cd ios && fastlane beta
$ cd ios && fastlane release

📚 Full Documentation:
[List of generated docs]

✅ Verification Completed:
[Summary of what was verified]

📊 Next Steps:
1. Test deployment: cd ios && fastlane beta --dry-run
2. Review CODE_SIGNING_GUIDE.md
3. Configure TestFlight external testers
[4. Set up CI/CD secrets]
5. Deploy first build: cd ios && fastlane beta
```

## Integration with Other Skills

This skill works with:

### brainstorming
Use BEFORE this skill to design custom deployment workflows or discuss trade-offs.

### test-driven-development
This skill sets up quality gates that enforce TDD by blocking deployment on test failures.

### verification-before-completion
This skill EMBODIES verification-before-completion. Every step is verified before proceeding.

### using-git-worktrees
Can use worktrees for isolated setup testing before applying to main branch.

## Common Pitfalls to Avoid

❌ **Assuming commands worked** → Always verify with exit codes and output
❌ **Skipping quality gate testing** → Must test both blocking and allowing
❌ **Batching commits** → Commit after each phase for rollback capability
❌ **Generating docs at end** → Create during phases while context is fresh
❌ **Not using TodoWrite** → Tracking progress helps prevent skipped steps
❌ **Hardcoding credentials** → Always use environment variables
❌ **Not testing rollback** → Verify snapshots work before relying on them

## Examples

### Example 1: Basic iOS Setup

```
User: /setup-build-deploy

Claude:
Using setup-build-deploy skill.

[Analyzes project - React Native iOS detected]

I'll help set up iOS deployment automation. Let me ask a few questions.

[AskUserQuestion: 4 questions about platform, code signing, targets, CI/CD]

[User answers: iOS only, API Key, Both, GitHub Actions]

Creating TodoWrite for 5 phases...

Phase 1: Code Signing (10-15 min)
[Autonomous execution with verification]

Phase 2: Fastlane Setup (5-10 min)
[Autonomous execution with verification]

Phase 3: Quality Gates (5-10 min)
[Autonomous execution with verification - tests both failure and success]

Phase 4: Deployment (10-15 min)
[Autonomous execution with verification]

Phase 5: CI/CD (10-20 min)
[Autonomous execution with verification]

✅ Complete! You can now deploy with: cd ios && fastlane beta
```

### Example 2: Resume After Interruption

```
User: /setup-build-deploy --resume

Claude:
Found incomplete setup from 2 hours ago.

Completed phases:
- ✅ Phase 1: Code Signing
- ✅ Phase 2: Fastlane Setup
- ❌ Phase 3: Quality Gates (failed at verification step)

Options:
1. Fix and continue Phase 3
2. Rollback to Phase 2 and try different approach
3. Show error details
4. Restart from beginning

[AskUserQuestion with these options]

[User chooses 1]

Continuing Phase 3...
[Troubleshoots the issue, fixes it, verifies, continues]
```

### Example 3: Dry-Run

```
User: /setup-build-deploy --dry-run

Claude:
Running in dry-run mode. No changes will be made.

Project detected: React Native iOS

Simulated questions:
1. Platform: iOS only
2. Code signing: API Key
3. Targets: Both TestFlight and App Store
4. CI/CD: GitHub Actions

What would be done:

Phase 1: Code Signing (10-15 min)
  Would create:
    - ios/fastlane/CODE_SIGNING_GUIDE.md
  Would modify:
    - ios/YourApp.xcodeproj/project.pbxproj
  Would verify:
    - API key permissions
    - Certificate validity

[... continues for all phases ...]

Total time: ~55 minutes
Total files created: 5 docs + config files
Git commits: 6

Potential issues detected:
  ⚠️  Ruby 2.6.10 is old (recommend 3.0+)

Proceed with actual setup? (yes/no)
```

## Phase Implementation Files

This skill loads detailed phase instructions from:

- `phases/phase1-code-signing.md`
- `phases/phase2-fastlane-setup.md`
- `phases/phase3-quality-gates.md`
- `phases/phase4-deployment.md`
- `phases/phase5-cicd.md`
- `phases/android/phase2b-android-environment.md`
- `phases/android/phase3b-android-build.md`
- `phases/android/phase4b-google-play.md`
- `phases/android/phase5b-multiplatform-cicd.md`

Each phase file contains:
- Detailed step-by-step instructions
- Verification commands
- Error handling scenarios
- Documentation templates
- Example output

## Now Execute

When this skill is invoked:

1. **Load phase files** from `phases/` directory
2. **Detect project** in current working directory
3. **Create TodoWrite** for all phases
4. **Ask questions** using AskUserQuestion
5. **Execute phases** 1-5 (and Android if selected)
6. **Verify EVERYTHING** (no assumptions)
7. **Generate documentation** during each phase
8. **Commit incrementally** after each phase
9. **Update state file** throughout
10. **Provide final handoff** with summary

Remember:
- Verify every step
- Test quality gates actually work
- Commit after each phase
- Generate docs as you go
- No assumptions

**Let's set up build & deploy automation!**
