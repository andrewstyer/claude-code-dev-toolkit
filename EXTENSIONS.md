# Extensions Guide - Claude Code Development Toolkit

**Purpose:** Optional add-ons for specialized workflows and advanced automation

---

## What Are Extensions?

Extensions are optional components that add specialized capabilities to the core toolkit. Unlike the core workflow documents (which every project should use), extensions are project-specific tools you install only when needed.

**Core toolkit provides:** Session management, handoffs, recovery, quality gates
**Extensions provide:** Bug tracking, testing infrastructure, build/deploy automation

---

## 🐛 Bug Reporting System (INCLUDED)

**Status:** ✅ Included in core toolkit

**Location:** `skills/reporting-bugs/`, `skills/triaging-bugs/`, `skills/fixing-bugs/`

**Purpose:** Structured bug capture and triage workflow during development and testing

### When to Use

- Project is in active development/testing
- You're doing manual testing and finding bugs
- You need to track bugs systematically
- You want to convert bug reports → E2E tests automatically

### What It Provides

**Skills:**
- `reporting-bugs` - Interactive bug capture (title, repro steps, severity, optional E2E test)
- `triaging-bugs` - Batch review and prioritization of bugs
- `fixing-bugs` - Autonomous bug fixing with systematic debugging + TDD

**Slash Commands (optional):**
- `/report-bug` - Quick bug capture
- `/list-bugs` - View all bugs
- `/triage-bugs` - Batch triage workflow

**Storage:**
- `bugs.yaml` - Active bugs (project root)
- `docs/bugs/resolved/` - Archived bugs (by month)
- `.maestro/flows/bugs/` - E2E tests for bugs (optional)

### Installation

**Already included!** Skills are in `skills/` directory.

**Optional: Add slash commands:**
```bash
# Copy from bug-reporting source
cp extensions/testing-infra/commands/* .claude/commands/
# (if you want /report-bug, /list-bugs, /triage-bugs shortcuts)
```

### Usage

**Report a bug:**
```
I found a bug - [describe the issue]
```
Claude will use the `reporting-bugs` skill and prompt you for:
- Title
- Observed behavior
- Expected behavior
- Repro steps
- Severity (P0/P1/P2)
- Optional: device info, screenshots, E2E test

**Triage bugs:**
```
Let's triage bugs
```
Claude will use the `triaging-bugs` skill to review bugs.yaml and help prioritize.

**Fix specific bug:**
```
Fix BUG-005
```
Claude will use the `fixing-bugs` skill with systematic debugging.

### Example Workflow

```yaml
# bugs.yaml (auto-generated)
bugs:
  - id: BUG-001
    title: Document upload fails on iPad
    severity: P1
    status: open
    observed: Upload button does nothing on iPad
    expected: Should upload document like on iPhone
    reproSteps:
      - Open app on iPad Pro 11-inch
      - Navigate to Documents screen
      - Tap Upload button
      - Nothing happens
    reportedDate: "2025-11-13"
    device: iPad Pro 11-inch, iOS 18.1
```

---

## 🧪 Testing Infrastructure Setup (EXTENSION)

**Status:** 📦 Optional extension

**Location:** `extensions/testing-infra/`

**Purpose:** Autonomous E2E testing infrastructure setup with quality gates

### When to Use

- Project has NO E2E tests yet
- You want to add quality gates (tests block deployment)
- You need automated test cleanup before each run
- You're setting up a new mobile or web project

**Project types supported:**
- React Native (iOS/Android)
- Native mobile (Swift/Kotlin)
- Web applications

### What It Provides

**Autonomous setup (5-10 minutes):**
1. Detects your project type
2. Installs appropriate E2E framework:
   - Mobile: Maestro or Detox
   - Web: Playwright or Cypress
3. Configures build automation (Fastlane for mobile)
4. Adds quality gates (tests block deployment on failure)
5. Creates sample tests to verify setup
6. Generates comprehensive documentation (1,600-2,400 lines across 4 files)

**Documentation generated:**
- `TESTING-WORKFLOW.md` (400-600 lines)
- Testing checklist (500-600 lines)
- Device/browser testing guide (500-600 lines)
- Build verification script (200-400 lines)

### Installation

**Option 1: Use as a skill (recommended)**

```bash
# Copy skill to your project
cp -r extensions/testing-infra/skills/setup-testing-infrastructure .claude/skills/

# In Claude Code session:
# Invoke the skill
```
Say to Claude: "Set up testing infrastructure"

**Option 2: Use as a prompt**

```bash
# Read the master prompt
cat extensions/testing-infra/prompts/master-prompt.md

# Copy contents and paste to Claude Code
```

### What Happens

1. **Detection phase** (autonomous):
   - Claude examines your project files
   - Determines project type
   - Checks for existing tools

2. **Configuration phase** (1-2 questions via AskUserQuestion):
   - Confirms project type
   - Asks about optional features

3. **Setup phase** (autonomous):
   - Installs all tools
   - Configures everything
   - Creates sample tests
   - Verifies it works

4. **Documentation phase** (autonomous):
   - Generates 4 comprehensive guide docs
   - Updates session management docs
   - Commits everything

5. **Verification**:
   - Runs sample test to prove it works
   - You see: "✅ Sample test passed"

### Example Output

```bash
# After running skill:
ls -la
# You'll see:
# - TESTING-WORKFLOW.md
# - .maestro/flows/sample-test.yaml (or similar)
# - Fastfile (for mobile)
# - Test verification script

# All committed to git
git log -1
# "feat: set up E2E testing infrastructure with Maestro + quality gates"
```

### Time Investment

- **Setup:** 5-10 minutes (mostly autonomous)
- **Reading docs:** 15-30 minutes (one time)
- **ROI:** Saves hours debugging test issues later

---

## 📱 Build & Deploy Setup (EXTENSION)

**Status:** 📦 Optional extension

**Location:** `extensions/build-deploy-setup/`

**Purpose:** iOS/Android build and deployment pipeline with quality gates

### When to Use

- You're building a mobile app (iOS or Android)
- You need to deploy to TestFlight or App Store
- You want automated builds with quality gates
- You're setting up CI/CD for mobile

**NOT needed for:**
- Web-only projects
- Projects not deploying to app stores
- Pure backend/API projects

### What It Provides

**Autonomous setup (30-60 minutes) across 5 phases:**

**Phase 1: Environment & Code Signing (10-15 min)**
- Apple Developer account verification
- Code signing setup (API Key, Manual, or Match)
- Certificate and provisioning profiles
- Xcode configuration

**Phase 2: Fastlane Installation (5-10 min)**
- Fastlane installation
- Appfile and Fastfile creation
- Version bumping automation
- Basic lanes (test, build, version)

**Phase 3: Quality Gates (5-10 min)**
- Test framework integration
- Quality gate lanes (block on test failure)
- Build verification
- Automatic rollback on failure

**Phase 4: TestFlight/App Store (10-15 min)**
- TestFlight beta deployment lane
- App Store release lane
- Metadata management
- External tester groups

**Phase 5: CI/CD Integration (10-20 min, optional)**
- Platform selection (GitHub Actions, GitLab CI, Bitrise, etc.)
- Secrets configuration
- Automated builds on push
- Deployment triggers

**Documentation generated:**
- `CODE_SIGNING_GUIDE.md` (200-300 lines)
- `FASTLANE_SETUP_GUIDE.md` (250-350 lines)
- `QUALITY_GATES_GUIDE.md` (200-300 lines)
- `DEPLOYMENT_GUIDE.md` (300-400 lines)
- Optional: `CI_CD_GUIDE.md` (300-500 lines)

### Installation

**Option 1: Use as a skill (recommended)**

```bash
# Copy skill to your project
cp -r extensions/build-deploy-setup/skills/setup-build-deploy .claude/skills/

# In Claude Code session:
# Invoke the skill
```
Say to Claude: "Set up build and deploy pipeline"

**Option 2: Use as a prompt**

```bash
# Read the master prompt
cat extensions/build-deploy-setup/prompts/master-prompt.md

# Copy contents and paste to Claude Code
```

### What Happens

1. **Environment verification**:
   - Checks for Xcode (iOS)
   - Checks for Apple Developer account
   - Verifies project structure

2. **Configuration questions** (3-5 via AskUserQuestion):
   - Deployment targets (TestFlight, App Store, both)
   - Code signing method (API Key recommended)
   - Platform (iOS only, or iOS + Android)
   - CI/CD platform (optional)

3. **Phase-by-phase setup**:
   - Each phase completes independently
   - Can resume if interrupted
   - TodoWrite tracking for each phase

4. **Documentation & verification**:
   - Comprehensive guides generated
   - Fastlane lanes tested
   - Test deployment attempted (if credentials provided)

### Example Output

```bash
# After setup:
ls -la
# You'll see:
# - fastlane/Fastfile
# - fastlane/Appfile
# - CODE_SIGNING_GUIDE.md
# - FASTLANE_SETUP_GUIDE.md
# - QUALITY_GATES_GUIDE.md
# - DEPLOYMENT_GUIDE.md

# Test the setup:
fastlane test
fastlane build
fastlane beta  # Deploy to TestFlight

# All committed to git with clear phase messages
git log -5
```

### Time Investment

- **Setup:** 30-60 minutes (with pauses for credential entry)
- **Learning:** 30-60 minutes reading generated guides
- **ROI:** Saves hours setting up each deployment, prevents broken releases

---

## Decision Tree: Which Extensions Do I Need?

### Start Here: Do you have E2E tests?

**NO** → Use **Testing Infrastructure Setup** extension first
- Sets up testing framework
- Creates quality gates
- Then come back to bug reporting

**YES** → Continue below

### Are you actively developing/testing?

**YES** → Use **Bug Reporting System** (already included!)
- Track bugs systematically
- Convert bugs → E2E tests
- Integrate with TDD workflow

**NO** → Skip for now, enable when needed

### Are you deploying a mobile app?

**YES** → Use **Build & Deploy Setup** extension
- iOS: TestFlight + App Store
- Android: Google Play (optional)
- Quality gates + CI/CD

**NO** (web/API/backend) → Skip this extension

---

## Installation Summary

### All Projects (Core Toolkit)

```bash
# 1. Copy entire toolkit
cp -r /path/to/dev-toolkit/* /path/to/your-project/

# 2. Install validation scripts and hooks
./scripts/install-git-hooks.sh

# 3. Customize for your project
# Follow SETUP.md instructions
```

**Bug reporting already included in core toolkit!**

### Projects Needing E2E Testing

```bash
# Add testing infrastructure skill
cp -r extensions/testing-infra/skills/setup-testing-infrastructure .claude/skills/

# Then in Claude Code:
# "Set up testing infrastructure"
```

### Mobile Apps Deploying to App Stores

```bash
# Add build/deploy skill
cp -r extensions/build-deploy-setup/skills/setup-build-deploy .claude/skills/

# Then in Claude Code:
# "Set up build and deploy pipeline"
```

---

## Combining Extensions

Extensions work well together:

**Typical mobile app workflow:**

1. **Start:** Use core toolkit (HANDOFF.md, BLOCKERS.md, etc.)
2. **Week 1:** Set up testing infrastructure → E2E tests working
3. **Week 2-4:** Development with bug reporting → Track issues systematically
4. **Week 5:** Set up build/deploy → Ready for TestFlight
5. **Ongoing:** Use all three together (session management + bugs + testing + deployment)

**Each extension enhances the others:**
- Bug reporting → generates E2E tests (testing infrastructure)
- Testing infrastructure → blocks bad builds (build/deploy)
- Build/deploy → enforces quality gates (testing infrastructure)

---

## Extension Maintenance

### Bug Reporting System

**Weekly:**
- Review bugs.yaml
- Archive resolved bugs when > 20 open
- Clean up old E2E test files

**Monthly:**
- Archive resolved bugs to docs/bugs/resolved/YYYY-MM/

### Testing Infrastructure

**After setup:** Just use it!
- Tests run automatically
- Quality gates enforce themselves
- Documentation stays current

**Only update when:**
- Upgrading testing framework
- Adding new test types
- Changing quality gate thresholds

### Build & Deploy

**After setup:** Mostly autonomous
- Fastlane handles versioning
- Quality gates block bad builds
- CI/CD runs automatically

**Manual intervention needed:**
- Updating certificates (yearly)
- Changing deployment settings
- Adding new deployment targets

---

## 📋 Feature Management (EXTENSION)

**Status:** 📦 Optional extension

**Location:** `extensions/feature-management/`

**Purpose:** Complete feature and bug lifecycle management with autonomous operation modes

### When to Use

- You're planning features across multiple sprints
- You want structured feature request capture
- You need sprint planning with roadmap tracking
- You're using superpowers workflow and want integration
- You have more features than you can implement immediately

**NOT needed for:**
- Single-feature projects (no backlog needed)
- All features implemented immediately (no triage/scheduling needed)
- Ad-hoc development without sprint structure

### What It Provides

**Skills (7):**
- **skills/reporting-bugs/** - Capture bugs during testing
- **skills/triaging-bugs/** - Triage reported bugs (interactive + autonomous)
- **skills/reporting-features/** - Capture feature requests
- **skills/triaging-features/** - Triage proposed features (interactive + autonomous)
- **skills/scheduling-work-items/** - Schedule bugs + features into sprints (interactive + autonomous)
- **skills/scheduling-features/** - Schedule features-only sprints (interactive + autonomous)
- **skills/scheduling-implementation-plan/** - Schedule implementation plans (interactive + autonomous)
- **skills/completing-sprints/** - Complete sprints systematically (interactive + autonomous)

**Supporting Scripts:**
- **scripts/autonomous-helpers.sh** - Shared autonomous detection and decision functions
- **scripts/validate-sprint-data.sh** - Sprint data consistency validation

**All skills support dual-mode operation:**
- Interactive mode: Full human control (default)
- Autonomous mode: Auto-detection with conservative fallbacks (opt-in)

**Integration with Superpowers:**
- superpowers:brainstorming → Refine feature requirements
- superpowers:writing-plans → Create implementation plans
- **NEW:** scheduling-implementation-plan → Convert plans to sprint tasks with roadmap
- superpowers:executing-plans → Execute from roadmap with task tracking
- superpowers:subagent-driven-development → Fast iteration with quality gates

### Files Created

```
project-root/
├── features.yaml                           # All feature requests
├── ROADMAP.md                              # Auto-generated roadmap
└── docs/
    ├── features/
    │   └── index.yaml                      # Fast lookup index
    └── plans/
        ├── sprints/
        │   ├── SPRINT-001-core-features.md
        │   └── SPRINT-002-ux-polish.md
        └── features/
            ├── FEAT-001-implementation-plan.md
            └── FEAT-003-implementation-plan.md
```

### Installation

**Method 1: Skills (Recommended)**

```bash
# From dev-toolkit root
cp -r extensions/feature-management/skills/* .claude/skills/
```

**Method 2: Global Skills**

```bash
# Install globally for all projects
cp -r extensions/feature-management/skills/reporting-features ~/.config/claude/skills/
cp -r extensions/feature-management/skills/triaging-features ~/.config/claude/skills/
cp -r extensions/feature-management/skills/scheduling-features ~/.config/claude/skills/
cp -r extensions/feature-management/skills/scheduling-implementation-plan ~/.config/claude/skills/
```

### Quick Start

**Step 1: Capture feature request**
```
User: "report a feature"
Claude Code: [Uses reporting-features skill]
- Title: "Add medication tracking"
- Description: "Allow users to track medications..."
- Category: New Functionality
- Priority: Must-Have
→ Creates FEAT-001 with status="proposed"
```

**Step 2: Triage features**
```
User: "triage features"
Claude Code: [Uses triaging-features skill]
- Shows all proposed features
- Filter by priority="must-have"
- Approve 3 features → status="approved"
```

**Step 3: Schedule into sprint**
```
User: "schedule features"
Claude Code: [Uses scheduling-features skill]
- Shows approved features
- Create SPRINT-001: "Core Features Sprint"
- Select 3 features for sprint
- Optional: Create implementation plans
- Optional: Execute features
→ Updates ROADMAP.md, creates sprint document
```

**Step 4: Complete sprint**
```
User: "complete sprint"
Claude Code: [Uses completing-sprints skill]
- Shows active sprints
- User selects SPRINT-001
- Reviews completion status
- Handles incomplete items
- Generates retrospective
→ Updates all files, validates consistency, commits
```

### Common Workflows

**Weekly Triage Cadence:**
1. Monday: Triage all new features from last week
2. Approve Must-Have features immediately
3. Reject out-of-scope features
4. Batch-approve Nice-to-Have for later sprints

**Sprint Planning:**
1. Start of 2-week sprint
2. Filter approved features by priority="must-have"
3. Select 5-7 features for sprint
4. Create implementation plans
5. Execute throughout sprint

**Quick Implementation:**
1. Report feature → Approve → Schedule → Execute
2. Goes from idea to in-progress in single session

### Example Usage

**Scenario: Planning next sprint**

```
User: "We need to plan Sprint 5 focusing on medication management"

Claude Code: "I'm using the scheduling-features skill to plan your sprint."

[Lists all approved features]

You: [Select 5 features for Sprint 5]

Claude Code: "Do you want to create implementation plans now?"

You: "Yes, create plans"

[For each feature:]
Claude Code:
1. Runs superpowers:brainstorming to refine requirements
2. Runs superpowers:writing-plans to create detailed plan
3. Asks: "Execute now?"

You: "No, plan only" [for first 3], "Yes, execute now" [for last 2]

Claude Code:
- Updates features.yaml (5 features scheduled, 2 in-progress)
- Creates docs/plans/sprints/SPRINT-005-medication-management.md
- Creates implementation plans for all 5 features
- Executes last 2 features using superpowers workflow
- Generates ROADMAP.md
- Git commit
```

**Result:**
- Sprint 5 document created with 5 features
- 5 implementation plans ready
- 2 features already in development
- ROADMAP.md updated with current sprint status
- All changes committed to git

### Time Investment

- **Installation:** 1 minute (copy skills)
- **Per feature capture:** ~2 minutes
- **Per feature triage:** ~1-2 minutes
- **Per sprint creation:** ~5-10 minutes (without planning)
- **With implementation planning:** +5-10 minutes per feature
- **With execution:** +30-60+ minutes per feature

**ROI:**
- Zero features lost in verbal discussion (100% capture rate)
- No duplicate features (duplicate detection)
- Clear sprint planning with roadmap
- Optional full lifecycle (idea → implementation in one flow)

### Documentation

**Complete documentation:**
- `extensions/feature-management/README.md` - Full guide
- `extensions/feature-management/DESIGN.md` - System architecture
- `extensions/feature-management/TESTING.md` - Test cases
- `extensions/feature-management/examples/` - Sample files

**Based on:** Health Narrative 2 real-world usage (2+ weeks)

---

## Troubleshooting Extensions

### Testing Infrastructure Issues

**Tests failing after setup?**
1. Check TESTING-WORKFLOW.md troubleshooting section
2. Run build verification script
3. Check RECOVERY.md for test failure scenarios

**Can't find test files?**
- Mobile: `.maestro/flows/` or `e2e/`
- Web: `tests/e2e/` or `playwright/`

### Build & Deploy Issues

**Fastlane errors?**
1. Check CODE_SIGNING_GUIDE.md
2. Verify credentials: `fastlane env`
3. Check DEPLOYMENT_GUIDE.md troubleshooting

**Code signing problems?**
- Check certificate expiration
- Verify provisioning profiles
- Run: `fastlane match nuke development` (nuclear option)

### Bug Reporting Issues

**bugs.yaml not found?**
- Will be created on first bug report
- Check project root directory

**E2E tests not generating?**
- Ensure testing infrastructure is set up
- Check `.maestro/flows/bugs/` directory exists

---

## Contributing Extensions

**Have an extension idea?** Follow this structure:

```
extensions/your-extension/
├── README.md              # What it does, when to use
├── skills/
│   └── your-skill/
│       └── SKILL.md       # Superpowers skill
├── prompts/
│   └── master-prompt.md   # Non-skill version
├── docs/
│   └── design.md          # Design decisions
└── GETTING-STARTED.md     # Quick start guide
```

**Then submit as a pull request or share in toolkit discussions!**

---

## Extension Version History

**v2.1.0 (November 2025)**
- Added bug reporting system (core toolkit)
- Added testing infrastructure extension
- Added build/deploy setup extension

---

## Quick Reference

| Extension | Install Time | Best For | Included? |
|-----------|--------------|----------|-----------|
| **Bug Reporting** | Instant (included) | All projects in development | ✅ Core |
| **Testing Infrastructure** | 5-10 min | Projects without E2E tests | 📦 Optional |
| **Build & Deploy** | 30-60 min | Mobile apps going to production | 📦 Optional |
| **Feature Management** | 1 min | Projects with feature backlogs & sprint planning | 📦 Optional |

---

**Questions?** Check extension-specific READMEs in `extensions/` directory.

**Want more extensions?** Contribute to the toolkit! See CONTRIBUTING.md.
