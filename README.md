# Claude Code Session Management Toolkit

**Reusable session management and workflow system for Claude Code projects**

**Current Version:** v2.1.3 (November 2025) - Complete sprint lifecycle with retrospectives!

---

## ⚡ What's New

### v2.1.3 (November 2025) - Sprint Completion

**NEW: Complete sprints with retrospectives and validation!**
- **completing-sprints skill** - Systematic sprint completion workflow
  - Interactive mode (human-led) and Autonomous mode (Claude-led)
  - Auto-detect completion from project state (yaml, roadmap, plans, git)
  - Handle incomplete items (backlog/next sprint/keep)
  - Generate retrospectives with statistics and notes
  - Track velocity and completion rates
- **validate-sprint-data.sh script** - Data consistency validation
  - Validates sprint docs ↔ YAML ↔ ROADMAP.md consistency
  - Auto-fix mode for correctable issues
  - Integrated into completing-sprints workflow
- **Complete sprint lifecycle:** create → work → complete → retrospect → repeat

**[See CHANGELOG.md for full details →](CHANGELOG.md)**

### v2.1.2 (November 2025) - Unified Sprint Planning

**NEW: Schedule bugs AND features together in sprints!**
- **scheduling-work-items skill** - Unified sprint planning with bugs and features
  - Prioritize across bugs vs features (P0 bug vs Must-Have feature)
  - Capacity planning with total work items
  - ROADMAP.md shows unified bugs + features view
- **triaging-bugs updated** - Now supports sprint assignment
  - Three workflows: Assign to Sprint, Fix Immediately, or Mark Triaged
  - Quick bug-only sprint assignment during triage
- **Bug status lifecycle** - Extended schema with `scheduled` status and `sprint_id`

**[See CHANGELOG.md for full details →](CHANGELOG.md)**

### v2.1.1 (November 2025) - Feature Management

- **Feature management extension** - Feature request workflow with sprint planning
- **scheduling-implementation-plan** - Bridge standalone plans into sprints

### v2.1 (November 2025) - Skills & Extensions

**Core skills:**
- **Bug reporting skills** (included) - Report bugs, triage, fix autonomously
- **Testing infrastructure extension** - Set up E2E tests in 5-10 minutes
- **Build/deploy extension** - iOS/Android deployment pipelines

**[See EXTENSIONS.md for details →](EXTENSIONS.md)**

### v2.0 (November 2025) - Documentation System

**Major improvements based on 2+ weeks of real-world usage:**

- **HANDOFF.md system** - Replaces SESSION-STATUS.md with < 100 line hard limit
- **Automated validation** - Scripts enforce documentation constraints (no more bloat!)
- **BLOCKERS.md** - "What NOT to try" knowledge base prevents duplicate work
- **Git hooks** - Pre-commit validation catches issues before they commit
- **Archive automation** - Preserve history without documentation bloat
- **86% size reduction** in session handoff docs (485 → 65 lines in HN2 project)

**[See full case study →](case-studies/healthnarrative2-documentation-system.md)**

---

## 🎯 What Is This?

This toolkit provides a complete session management system for working with Claude Code as your development partner. It ensures:

- **Seamless handoffs** between sessions (even when context is lost)
- **Quality gates** enforced at every step
- **Recovery procedures** when things go wrong
- **Consistent workflow** across all sessions
- **Progress tracking** that survives context loss
- **Documentation that stays lean** through automation (v2.0)
- **Bug tracking & testing automation** through skills and extensions (v2.1)

---

## 📦 What's Included

### Core Workflow Documents (v2.0)

| File | Purpose | When to Use |
|------|---------|-------------|
| `START-HERE.md` | First session comprehensive onboarding | Once, at project start |
| `CONTINUE-SESSION.md` | Quick context loading with pre-flight checks | Every continuing session |
| `END-SESSION.md` | Mandatory handoff checklist with structured templates | Before ending ANY session |
| `HANDOFF.md` | **NEW** Session-to-session handoff (< 100 lines) | Created in project dir, updated every session |
| `BLOCKERS.md` | **NEW** Known issues & failed approaches | Created in project dir, updated as needed |
| `RECOVERY.md` | Comprehensive troubleshooting guide (9 scenarios) | When stuck or broken |
| `PROMPTS.md` | Copy-paste prompts for each session type | Reference for starting sessions |
| `USER-GUIDE.md` | **NEW** Maintenance guide for humans | Weekly/monthly maintenance |

**Note:** `SESSION-STATUS.md` is deprecated in v2.0 (replaced by HANDOFF.md + BLOCKERS.md)

### Automation & Validation (v2.0)

| File | Purpose |
|------|---------|
| `scripts/validate-docs.sh` | **NEW** Validates documentation size limits |
| `scripts/archive-handoff.sh` | **NEW** Archives old handoff versions |
| `scripts/pre-commit` | **NEW** Git hook for automatic validation |
| `scripts/install-git-hooks.sh` | **NEW** One-command hook installation |
| `git-hooks/pre-commit` | Legacy git hook (v1.0, still functional) |
| `git-hooks/setup-git-hooks.sh` | Legacy hook installer (v1.0) |

### Setup & Configuration

| File | Purpose |
|------|---------|
| `SETUP.md` | How to adapt this toolkit to your project |
| `PROJECT-CONFIG.md` | Template for project-specific configuration |
| `QUICK-START.md` | 15-minute quick start guide |
| `PLACEHOLDER-REFERENCE.md` | Complete list of all placeholders to customize |

### Case Studies & Examples

| File | Purpose |
|------|---------|
| `case-studies/README.md` | **NEW** Index of real-world implementations |
| `case-studies/healthnarrative2-documentation-system.md` | **NEW** HN2 case study with metrics |

### Skills & Extensions (v2.1)

**Core Skills (Included):**
| Skill | Purpose |
|-------|---------|
| `skills/reporting-bugs/` | **NEW** Interactive bug capture during testing |
| `skills/triaging-bugs/` | **NEW** Batch bug review and prioritization |
| `skills/fixing-bugs/` | **NEW** Autonomous bug fixing with TDD |

**Optional Extensions:**
| Extension | Purpose | When to Use |
|-----------|---------|-------------|
| `extensions/testing-infra/` | E2E testing setup | Projects without automated tests |
| `extensions/build-deploy-setup/` | Mobile deployment pipeline | iOS/Android apps going to production |
| `extensions/feature-management/` | Feature request workflow & sprint planning | Projects with feature backlogs |

**See [EXTENSIONS.md](EXTENSIONS.md) for installation and usage guide.**

---

## 🚀 Quick Start

### For New Projects

1. **Copy toolkit to your project:**
   ```bash
   cp -r /Users/andrewstyer/dev/dev-toolkit/* /path/to/your-project/
   ```

2. **Customize for your project:**
   ```bash
   cd /path/to/your-project
   # Edit PROJECT-CONFIG.md with your project details
   # Follow SETUP.md instructions
   ```

3. **Install validation scripts and git hooks:**
   ```bash
   ./scripts/install-git-hooks.sh
   ```

4. **Start first session:**
   ```bash
   # Give Claude Code the "First Session Prompt" from PROMPTS.md
   # Claude will read START-HERE.md and begin implementation
   ```

---

## 📋 How It Works

### Session Lifecycle

```
┌─────────────────────────────────────────────────┐
│  START: First Session Prompt                    │
│  • Claude reads START-HERE.md                   │
│  • Comprehensive onboarding (30-60 min)         │
│  • Begins implementation                        │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│  CONTINUE: Continuing Session Prompt            │
│  • Claude reads CONTINUE-SESSION.md (2 min)     │
│  • Claude reads HANDOFF.md (< 100 lines)        │
│  • Checks BLOCKERS.md if needed                 │
│  • Picks up where last session left off        │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│  WORK: Implementation                           │
│  • Follow TDD workflow                          │
│  • Run quality checks frequently                │
│  • If stuck → RECOVERY.md                       │
│  • Update TodoWrite as you go                   │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│  END: End Session Prompt                        │
│  • Claude reads END-SESSION.md                  │
│  • Runs quality checks (mandatory)              │
│  • Updates HANDOFF.md (structured template)     │
│  • Runs validation script                       │
│  • Commits everything                           │
│  • Provides session summary                     │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓ (loop back to CONTINUE)
```

### When Things Go Wrong

```
Problem Detected
    ↓
Read RECOVERY.md
    ↓
Find Your Scenario (9 common scenarios covered)
    ↓
Follow Recovery Steps
    ↓
Verify Quality Checks Pass
    ↓
Document in BLOCKERS.md (if recurring)
    ↓
Update HANDOFF.md
    ↓
Continue Normal Workflow
```

---

## 🎯 Key Benefits

### 1. Survives Context Loss
- Claude Code loses context between sessions
- HANDOFF.md acts as external memory (< 100 lines, quick to read)
- Continuing sessions load context in < 5 minutes
- **NEW:** Automated archival preserves history without bloat

### 2. Enforces Quality
- Mandatory quality checks before moving forward
- TDD workflow enforced
- **NEW:** Git pre-commit hook validates documentation constraints
- **NEW:** Validation scripts catch drift before it happens

### 3. Provides Recovery Paths
- 9 common failure scenarios documented
- Step-by-step recovery procedures
- **NEW:** BLOCKERS.md prevents duplicate investigations
- Prevention tips to avoid problems

### 4. Maintains Momentum
- Clear "next steps" always documented in HANDOFF.md
- No time wasted figuring out what to do
- Consistent workflow across sessions
- **NEW:** Lightweight mid-session updates keep handoff current

---

## 📚 Document Overview

### START-HERE.md (First Session Only)
**Purpose:** Comprehensive onboarding for Claude Code

**Contains:**
- Project overview and mission
- Required reading list
- Architecture overview
- Critical rules (TDD, quality gates, etc.)
- Quick start instructions
- Session handoff instructions

**Customize with:** Your project name, tech stack, architecture decisions, quality gates

---

### CONTINUE-SESSION.md (Every Continuing Session) - **UPDATED v2.0**
**Purpose:** Quick context loading with pre-flight checklist

**Contains:**
- **NEW:** Mandatory pre-flight checklist (check for urgent overrides, read HANDOFF.md, check BLOCKERS.md)
- Session start checklist (git log, git status)
- Critical rules reminder
- Quick reference to key docs
- **NEW:** Mid-session update guidance (lightweight HANDOFF.md updates)
- TDD workflow refresher
- Quality gate commands

**Customize with:** Your project's key documentation paths, quality commands

---

### END-SESSION.md (Before Ending ANY Session) - **UPDATED v2.0**
**Purpose:** Mandatory session handoff checklist with structured templates

**Contains:**
- Step 1: Run quality checks (tests, TypeScript, build, git)
- **NEW:** Step 2.5: Update HANDOFF.md using structured template with line budgets
- **NEW:** Step 2.6: Update knowledge base (BLOCKERS.md or RECOVERY.md decision tree)
- Step 3: Commit everything (code + status doc)
- **NEW:** Run validation script before committing
- Step 4: Provide session summary (what done, what's next, blockers, test status)

**Customize with:** Your project's specific quality checks

---

### HANDOFF.md (Updated Every Session) - **NEW in v2.0**
**Purpose:** Session-to-session handoff that stays < 100 lines

**Contains:**
- Quick Start section (next task, why, estimated time) - MAX 10 lines
- State Check (test/TypeScript/git status) - MAX 5 lines
- Active Blockers (link to BLOCKERS.md or "None") - MAX 10 lines
- Recent Session Summary (current + 1 previous ONLY) - MAX 40 lines
- Context You Might Need (MAX 5 links) - MAX 15 lines
- If Something's Wrong (navigation) - MAX 10 lines
- **Total budget: 90 lines (10 line buffer)**

**Created in:** Project directory (e.g., `your-project/HANDOFF.md`)
**Archived when:** > 80 lines (use `scripts/archive-handoff.sh`)

---

### BLOCKERS.md (Updated As Needed) - **NEW in v2.0**
**Purpose:** "What NOT to try" - project-specific known issues

**Contains:**
- Active blockers with failed approaches documented
- Resolved issues (recent 3-6 months for reference)
- Links to deep investigation docs
- Current workarounds
- Priority levels (P0/P1/P2)

**Created in:** Project directory (e.g., `your-project/BLOCKERS.md`)
**Max size:** 400 lines (soft limit, archive old resolved issues when over)

---

### SESSION-STATUS.md (**DEPRECATED in v2.0**)
**Note:** This file is deprecated. Use HANDOFF.md + BLOCKERS.md instead.

**Migration:** See UPDATE-NOTES.md for migration guide from v1.0 to v2.0

---

### RECOVERY.md (When Stuck or Broken) - **UPDATED v2.0**
**Purpose:** Comprehensive troubleshooting guide for general issues

**Contains:**
- **NEW:** Navigation header (links to BLOCKERS.md, HANDOFF.md, investigations)
- **NEW:** Table of contents for all 9 scenarios
- Quick diagnosis commands
- 9 common failure scenarios:
  1. Tests failing
  2. TypeScript errors
  3. App won't build
  4. E2E tests failing
  5. Coverage dropped
  6. Git messy state
  7. Lost track of tasks
  8. Stuck too long
  9. **UPDATED:** HANDOFF.md out of date (was SESSION-STATUS.md)
- Emergency procedures (reset to last good state)
- **NEW:** Scenario template for adding new scenarios
- When to ask for help
- Prevention tips

**Scope:** General Expo/React Native/TypeScript issues (cross-project)
**For project-specific issues:** See BLOCKERS.md

**Customize with:** Your project's tech stack, testing tools, build commands

---

### PROMPTS.md (Reference for Starting Sessions)
**Purpose:** Copy-paste prompts for each session type

**Contains:**
- First Session Prompt (starting from scratch)
- Continuing Session Prompt (picking up previous work)
- End Session Prompt (mandatory handoff)
- Recovery Prompt (when things go wrong)
- Decision tree (which prompt to use?)
- Customization tips

**Customize with:** Your project name, tech stack, timeline, specific rules

---

### USER-GUIDE.md (Maintenance for Humans) - **NEW in v2.0**
**Purpose:** Keep the documentation system healthy

**Contains:**
- Weekly maintenance checklist (5 minutes)
- Monthly maintenance checklist (15 minutes)
- Warning signs that system is degrading
- Emergency procedures (HANDOFF.md wrong, tests failing, documentation chaos)
- How to intervene during sessions
- Success metrics

**Audience:** Human developers maintaining the project
**Time commitment:** < 10 minutes/week when system healthy

---

## 🔧 Customization Guide

### Essential Customizations

**1. Project Information:**
- Project name
- Tech stack
- Architecture pattern
- Development timeline

**2. Quality Gates:**
- Test commands
- Coverage thresholds
- Linting/type checking commands
- Build commands

**3. Documentation Paths:**
- Where are planning docs?
- Where are architecture docs?
- Where are component specs?
- Where is sample data?

**4. Workflow Specifics:**
- TDD approach (E2E first? Unit first?)
- Testing tools (Jest, Vitest, Playwright, Maestro?)
- Deployment process
- Code review process

### Optional Customizations

- Add project-specific red flags
- Add custom recovery scenarios
- Add team conventions
- Add deployment checklists

---

## 🏗️ Project Structure

**Where to put these files in your project:**

```
your-project/
├── README.md                    ← Project overview
├── START-HERE.md                ← First session onboarding
├── CONTINUE-SESSION.md          ← Continuing session brief
├── END-SESSION.md               ← End session checklist
├── SESSION-STATUS.md            ← Progress tracker
├── RECOVERY.md                  ← Troubleshooting guide
├── PROMPTS.md                   ← Session prompts reference
│
├── PROJECT-CONFIG.md            ← Your project configuration
│
├── git-hooks/
│   ├── pre-commit               ← Git hook
│   └── setup-git-hooks.sh       ← Installation script
│
├── docs/
│   ├── architecture/            ← Your architecture docs
│   ├── planning/                ← Your planning docs
│   └── guides/                  ← Your how-to guides
│
└── src/                         ← Your source code
```

**These files live at the root** for easy access by Claude Code.

---

## 🎓 Best Practices

### For Humans (You)

**Starting a new project:**
1. Copy this toolkit to your project root
2. Customize PROJECT-CONFIG.md with your details
3. Run through SETUP.md to adapt all documents
4. Install git hooks
5. Give Claude Code the First Session Prompt

**Between sessions:**
1. Review HANDOFF.md to see progress (< 100 lines, quick read)
2. Use Continuing Session Prompt to start next session
3. Use End Session Prompt when stopping
4. **NEW:** Run `./scripts/validate-docs.sh` weekly to check for drift

**When things go wrong:**
1. Give Claude Code the Recovery Prompt
2. Claude will check BLOCKERS.md first (project-specific issues)
3. Claude will use RECOVERY.md to troubleshoot (general issues)
4. Review the documented blocker in HANDOFF.md or BLOCKERS.md
5. Provide guidance if needed

### For Claude Code

**First session:**
1. Read START-HERE.md completely
2. Read project architecture docs
3. Create TodoWrite todos for all phases
4. Begin implementation with TDD

**Continuing sessions:**
1. Read CONTINUE-SESSION.md (2 min)
2. **NEW:** Complete pre-flight checklist (check for overrides, read HANDOFF.md, check BLOCKERS.md)
3. Run verification checks
4. Continue from "Next task" in HANDOFF.md

**Before ending:**
1. Read END-SESSION.md
2. Run all quality checks
3. **NEW:** Update HANDOFF.md using structured template with line budgets
4. **NEW:** Update BLOCKERS.md if recurring issues discovered
5. **NEW:** Run validation script (`./scripts/validate-docs.sh`)
6. Commit everything
7. Provide session summary

**If stuck:**
1. **NEW:** Check BLOCKERS.md first (known project-specific issues)
2. Read RECOVERY.md for general troubleshooting
3. Find your scenario
4. Follow recovery steps
5. **NEW:** Document in BLOCKERS.md if issue recurs 2+ times
6. Update HANDOFF.md with current state

---

## 🚨 Common Pitfalls

### Don't Skip Session Handoff
**Problem:** Claude Code starts next session with no context
**Solution:** Use END-SESSION.md checklist every time (git hook helps)

### Don't Let HANDOFF.md Get Stale or Bloated
**Problem:** Progress is lost, or document grows too large to be useful
**Solution v2.0:**
- Update HANDOFF.md immediately after completing tasks (mid-session updates)
- Follow structured template with line budgets (END-SESSION.md Step 2.5)
- Archive when > 80 lines (`./scripts/archive-handoff.sh`)
- Run validation before committing (`./scripts/validate-docs.sh`)

### Don't Skip Quality Checks
**Problem:** Broken code accumulates, becomes hard to fix
**Solution:** Run checks after every small change, fix immediately

### Don't Rationalize Around TDD
**Problem:** Tests written after code (or not at all)
**Solution:** Follow RED-GREEN-REFACTOR religiously

---

## 📊 Success Metrics

**You'll know this toolkit is working when:**

- ✅ Each session starts with clear context (< 5 minutes)
- ✅ No time wasted figuring out what to do next
- ✅ Quality gates pass consistently
- ✅ Problems are caught early (tests fail immediately)
- ✅ Recovery from issues is quick (< 30 minutes)
- ✅ Progress is never lost between sessions
- ✅ Claude Code works autonomously for hours

**If these aren't true, check:**
- Is HANDOFF.md being updated every session?
- **NEW:** Is HANDOFF.md staying < 100 lines? Run `./scripts/validate-docs.sh`
- Are quality checks being run frequently?
- Is TDD being followed?
- **NEW:** Is BLOCKERS.md being consulted to avoid duplicate work?
- Are recovery procedures being used when stuck?

---

## 🤝 Contributing

**Found an improvement to this toolkit?**

Common improvements:
- Additional recovery scenarios
- Better prompts
- Clearer customization instructions
- New quality gate examples
- Better workflow diagrams

---

## 📞 Support

**Questions about using this toolkit?**

1. Read SETUP.md for customization instructions
2. Check PROMPTS.md for session prompt templates
3. Review RECOVERY.md if something's not working

---

## 🎉 Example Projects Using This Toolkit

### Health Narrative 2 (v2.0 Reference Implementation)

**Project Type:** Patient health record mobile app
**Tech Stack:** React Native + Expo, TypeScript, SQLite
**Toolkit Version:** v1.0 → v2.0 (drove v2.0 improvements)
**Location:** `/Users/andrewstyer/dev/healthnarrative2`

**Results:**
- 86% reduction in handoff doc size (485 → 65 lines)
- < 5 minute session handoffs (down from 30+ minutes)
- Zero documentation drift over 2+ weeks
- 87% reduction in duplicate investigation work

**[Full case study →](case-studies/healthnarrative2-documentation-system.md)**

---

*(Add your projects here as you use this toolkit - contributions welcome!)*

---

## 📄 License

This toolkit is free to use for any project. Customize as needed.

---

**Let's build better software with Claude Code!** 🚀
