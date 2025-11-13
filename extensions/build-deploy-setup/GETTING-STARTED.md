# Getting Started with Build & Deploy Setup

**Time to complete:** 45-75 minutes
**What you'll have:** Automated iOS deployment to TestFlight with one command

---

## Prerequisites

Before starting, ensure you have:

- ✅ Mac with macOS 12.0 or later
- ✅ Xcode 13.0 or later installed
- ✅ Apple Developer account (paid account required for TestFlight/App Store)
- ✅ Project already created in Xcode
- ✅ Git repository initialized
- ✅ 10GB+ free disk space

**Nice to have (but not required):**
- Homebrew installed
- Ruby 3.0+ installed
- Basic familiarity with terminal

---

## Quick Start (3 Steps)

### Step 1: Choose Your Mode

**Option A: Prompt-Based** (no special tools needed)

1. Open this file: `prompts/master-prompt.md`
2. Copy the entire contents
3. Paste into Claude
4. Skip to Step 3

**Option B: Skill-Based** (requires superpowers plugin)

1. Copy the skill to your Claude skills directory:
   ```bash
   cp -r skills/setup-build-deploy ~/.claude/skills/
   ```
2. In Claude, run: `/setup-build-deploy`
3. Skip to Step 3

### Step 2: Navigate to Your Project

```bash
cd /path/to/your/ios/project

# Verify you're in the right place:
ls -la
# You should see: YourApp.xcodeproj or YourApp.xcworkspace
```

### Step 3: Answer Questions

Claude will ask 3-5 questions. Here's what to expect:

**Question 1: Platform**
```
Which platform(s) do you want to set up?
1. iOS only
2. iOS + Android

Recommendation: Start with iOS only
```

**Question 2: Code Signing**
```
How do you want to handle code signing?
1. App Store Connect API Key (recommended - most automated)
2. Manual (use existing certificates from Keychain)
3. Match (team-based, certificates in git repo)

Recommendation: API Key for solo developers, Match for teams
```

**Question 3: Deployment Targets**
```
Where do you want to deploy?
1. TestFlight only
2. App Store only
3. Both TestFlight and App Store

Recommendation: Both
```

**Question 4: CI/CD (Optional)**
```
Set up automated deployment via CI/CD?
1. Yes - GitHub Actions
2. Yes - GitLab CI
3. Yes - Other platform
4. No - local deployment only

Recommendation: Yes if you use GitHub/GitLab
```

**Question 5: Android Setup (Only if you selected iOS + Android)**
```
Configure Android deployment?
1. Yes - Google Play
2. No - iOS only for now

Recommendation: Start with iOS, add Android later
```

---

## What Happens Next

Claude will autonomously:

### Phase 1: Code Signing (10-15 min)
- Verify your Apple Developer account
- Set up certificates and provisioning profiles
- Configure App Store Connect API key (if selected)
- Test that everything works
- Generate CODE_SIGNING_GUIDE.md

### Phase 2: Fastlane Setup (5-10 min)
- Install Fastlane (if not already installed)
- Create Appfile and Fastfile
- Set up basic lanes (test, build, version)
- Verify lanes work
- Generate FASTLANE_SETUP_GUIDE.md

### Phase 3: Quality Gates (5-10 min)
- Integrate your test framework
- Add quality gates that block deployment on test failures
- Test that gates actually work (makes a test fail, verifies blocking)
- Generate QUALITY_GATES_GUIDE.md

### Phase 4: Deployment (10-15 min)
- Configure TestFlight deployment
- Configure App Store release (if selected)
- Test deployment workflow (dry-run)
- Generate DEPLOYMENT_GUIDE.md

### Phase 5: CI/CD (10-20 min, if selected)
- Generate workflow file for your CI/CD platform
- Configure secrets and credentials
- Set up triggers (push, tag, manual)
- Test workflow syntax
- Generate CI_CD_GUIDE.md

---

## During Setup

### What Claude Will Do

✅ **Detect your project setup automatically**
- React Native, native iOS, Flutter, or other
- Existing Fastlane configuration (won't overwrite)
- Test framework (Jest, XCTest, etc.)
- Git status and branch

✅ **Verify everything before proceeding**
- Test API credentials work
- Verify certificates are valid
- Check that quality gates actually block deployment
- Confirm all files are valid

✅ **Show you what's happening**
- Clear progress updates
- Verification results
- What was created/modified
- What to do next

✅ **Handle errors gracefully**
- Pre-flight checks catch issues early
- Interactive troubleshooting when problems arise
- Rollback options if something fails
- Clear error messages with suggested fixes

### What You'll Do

Your involvement:
1. **Answer 3-5 questions** (2-3 minutes)
2. **Provide Apple Developer credentials** (when prompted)
3. **Review verification results** (optional, but recommended)
4. **Test the final setup** (5 minutes)

That's it! Claude handles everything else autonomously.

---

## After Setup Completes

### You'll Have These Commands

```bash
# Run all tests
cd ios && fastlane test

# Build for release
cd ios && fastlane build

# Deploy to TestFlight
cd ios && fastlane beta

# Deploy to App Store
cd ios && fastlane release

# Bump version (patch: 1.0.0 -> 1.0.1)
cd ios && fastlane version bump_type:patch

# Bump version (minor: 1.0.1 -> 1.1.0)
cd ios && fastlane version bump_type:minor

# Bump version (major: 1.1.0 -> 2.0.0)
cd ios && fastlane version bump_type:major
```

### You'll Have This Documentation

All in `ios/fastlane/`:
1. **CODE_SIGNING_GUIDE.md** - How to manage certificates and profiles
2. **FASTLANE_SETUP_GUIDE.md** - How to customize lanes and add new ones
3. **QUALITY_GATES_GUIDE.md** - How quality gates work and how to modify them
4. **DEPLOYMENT_GUIDE.md** - How to deploy to TestFlight and App Store
5. **CI_CD_GUIDE.md** - How to use CI/CD for automated deployment (if configured)

### Test Your Setup

```bash
# 1. Verify tests run
cd ios && fastlane test
# Expected: All tests pass ✅

# 2. Verify quality gate works
# (Make a test fail, then run fastlane beta)
# Expected: Deployment blocked ❌

# 3. Fix the test and try again
cd ios && fastlane beta --dry-run
# Expected: Dry-run succeeds ✅

# 4. Deploy for real
cd ios && fastlane beta
# Expected: App uploaded to TestFlight ✅
```

---

## Common Issues & Solutions

### Issue: "Apple Developer account not found"

**Solution:**
```bash
# Set environment variable with your Apple ID:
export FASTLANE_APPLE_ID="your@email.com"

# Or add to ~/.zshrc or ~/.bash_profile:
echo 'export FASTLANE_APPLE_ID="your@email.com"' >> ~/.zshrc
```

### Issue: "Xcode command line tools not found"

**Solution:**
```bash
# Install Xcode command line tools:
xcode-select --install

# Verify:
xcode-select -p
# Expected: /Applications/Xcode.app/Contents/Developer
```

### Issue: "Provisioning profile expired"

**Solution:**
Claude will detect this during setup and either:
1. Download a new profile automatically
2. Guide you through creating one
3. Configure automatic profile management

### Issue: "Not enough disk space"

**Solution:**
```bash
# Check available space:
df -h

# You need at least 10GB free. To free up space:
# - Clear Xcode derived data: rm -rf ~/Library/Developer/Xcode/DerivedData
# - Clear old simulators: xcrun simctl delete unavailable
# - Clear Homebrew cache: brew cleanup
```

### Issue: "Ruby version too old"

**Solution:**
```bash
# Check Ruby version:
ruby --version

# If < 3.0, install rbenv and newer Ruby:
brew install rbenv
rbenv install 3.2.2
rbenv global 3.2.2

# Add to shell config:
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
```

---

## If Setup Gets Interrupted

### Using Skill Mode

```bash
# Resume from where you left off:
/setup-build-deploy --resume

# Claude will:
# - Read .build-deploy-setup-state.json
# - Show what was completed
# - Offer to continue from last successful phase
```

### Using Prompt Mode

```bash
# Re-paste master-prompt.md into Claude

# Claude will:
# - Detect partial setup
# - Ask if you want to continue or restart
# - Resume from last successful phase
```

---

## Need Help?

### Check the Documentation

1. **README.md** - Overview and features
2. **2025-11-03-build-deploy-setup-guide-design.md** - Complete technical design
3. **Phase-specific guides** - In `skills/setup-build-deploy/phases/`

### Dry-Run Mode

Not sure what will happen? Run in dry-run mode first:

```bash
# Skill mode:
/setup-build-deploy --dry-run

# Prompt mode:
# Add to your first message: "Run in dry-run mode first"
```

This shows you exactly what would be done without making any changes.

### Rollback

If something goes wrong and you want to undo:

```bash
# Claude creates git snapshots before each phase
# You can rollback to any phase:

git tag
# Shows: build-deploy-snapshot-phase1, phase2, etc.

git reset --hard build-deploy-snapshot-phase2
# Resets to after Phase 2 completed
```

---

## Tips for Success

### Before You Start

1. ✅ Commit any pending changes: `git status` should be clean
2. ✅ Make sure tests pass: `npm test` or `xcodebuild test`
3. ✅ Have your Apple Developer credentials ready
4. ✅ Close other resource-intensive apps (Xcode builds need RAM)
5. ✅ Ensure stable internet connection (downloads Fastlane, gems, etc.)

### During Setup

1. ✅ Read verification results (shows what Claude tested)
2. ✅ Don't interrupt during file writes (wait for phase completion)
3. ✅ If asked for credentials, use environment variables (not hardcoded)
4. ✅ Review generated Fastfile (it's readable and well-documented)

### After Setup

1. ✅ Test the deployment workflow before relying on it
2. ✅ Read the generated documentation
3. ✅ Set up CI/CD secrets securely (use encrypted secrets)
4. ✅ Test quality gates (make a test fail, verify deployment blocked)
5. ✅ Bookmark the deployment commands (you'll use them often)

---

## Expected Timeline

| Time | What's Happening |
|------|------------------|
| 0:00 | Start - Paste prompt or invoke skill |
| 0:01 | Claude analyzes your project |
| 0:02 | Questions (your input needed) |
| 0:05 | Phase 1 starts - Code signing |
| 0:15 | Phase 2 starts - Fastlane setup |
| 0:25 | Phase 3 starts - Quality gates |
| 0:35 | Phase 4 starts - Deployment config |
| 0:45 | Phase 5 starts - CI/CD (if selected) |
| 1:00 | Verification and testing |
| 1:05 | Complete! |

**Total:** 45-75 minutes depending on:
- Internet speed (downloading Fastlane and dependencies)
- Whether you choose iOS only or iOS + Android
- Whether you set up CI/CD
- How many credentials need to be configured

---

## What Makes This Different

### Traditional Fastlane Setup:
1. Read Fastlane docs (1-2 hours)
2. Figure out code signing (2-4 hours, often frustrating)
3. Write Fastfile manually (1-2 hours)
4. Debug issues (2-6 hours)
5. Write documentation (2-3 hours)
6. **Total: 8-17 hours** spread over days

### With This Guide:
1. Answer 3-5 questions (2 minutes)
2. Wait for autonomous setup (45-70 minutes)
3. Test and verify (5 minutes)
4. **Total: ~1 hour** in one session

### Plus You Get:
- ✅ Verified working setup (not guesswork)
- ✅ Quality gates that actually work (tested during setup)
- ✅ Comprehensive documentation (1,350-1,950 lines)
- ✅ CI/CD integration (if selected)
- ✅ Rollback capability (git snapshots)
- ✅ Resume capability (state tracking)

---

## Ready to Start?

### Option A: Prompt-Based

```bash
# 1. Navigate to your project
cd /path/to/your/project

# 2. Copy this file and paste into Claude:
cat /path/to/build-deploy-setup/prompts/master-prompt.md

# 3. Follow the prompts
```

### Option B: Skill-Based

```bash
# 1. Install the skill (one time)
cp -r /path/to/build-deploy-setup/skills/setup-build-deploy ~/.claude/skills/

# 2. Navigate to your project
cd /path/to/your/project

# 3. In Claude, run:
/setup-build-deploy
```

---

## After You're Done

### Share Your Feedback

This guide is designed to work for all iOS projects. If you encounter:
- Issues during setup
- Missing features
- Unclear documentation
- Ways to improve the automation

Please share your feedback so we can improve it!

### Next Steps

Once your iOS deployment is set up:

1. **Deploy your first build:**
   ```bash
   cd ios && fastlane beta
   ```

2. **Set up TestFlight external testers** in App Store Connect

3. **Configure release notes** automation (optional)

4. **Set up screenshot automation** (optional - ask Claude!)

5. **Add Android deployment** (if needed):
   ```bash
   /setup-build-deploy --add-platform android
   ```

---

## You're Ready!

This setup will save you hours on every deployment going forward.

**From commit to TestFlight:** One command, ~10 minutes.

**Let's get started!**
