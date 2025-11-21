# Changelog

All notable changes to the Claude Code Development Toolkit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2025-11-21

### Added

**Autonomous Modes for All Skills:**

**Shared Infrastructure:**
- **scripts/autonomous-helpers.sh** - Reusable detection and decision functions
  - detect_bug_severity() - Auto-detect bug severity from keywords (P0/P1/P2)
  - calculate_sprint_velocity() - Calculate average items per sprint from completed sprints
  - check_item_in_commits() - Scan git commits for work item patterns
  - get_item_status() / update_item_status() - YAML helper functions
  - extract_sprint_themes() - Generate sprint themes from work item titles
  - Eliminates code duplication across skills
  - Single source of truth for detection algorithms

**Wave 1: Triage Skills (Aggressive):**
- **triaging-bugs autonomous mode** - Auto-triage bugs with severity detection
  - Auto-detects P0/P1/P2 from title/description keywords
  - Auto-detects resolved bugs from git commit messages
  - Auto-triages all bugs with clear severity indicators
  - Warns about potential duplicates (>80% similarity)
  - Time: 5-10 seconds per bug (vs 1-2 min interactive)
  - Invocation: "auto-triage bugs"

- **triaging-features autonomous mode** - Auto-approve/reject features
  - Auto-detects in-scope vs out-of-scope from existing approved features
  - Auto-approves must-have and nice-to-have features in existing categories
  - Auto-rejects clear duplicates (>90% similarity)
  - Keeps uncertain cases as proposed for human review
  - Time: 5-10 seconds per feature (vs 1-2 min interactive)
  - Invocation: "auto-triage features"

**Wave 2: Scheduling Skills (Moderate):**
- **scheduling-work-items autonomous mode** - Auto-create sprints from backlog
  - Auto-calculates velocity from completed sprints
  - Auto-selects items by priority (P0→P1→Must-Have→Nice-to-Have)
  - Auto-generates sprint theme from item titles
  - Creates sprint without prompting for execution
  - Time: 2-3 minutes per sprint (vs 5-10 min interactive)
  - Invocation: "auto-schedule work items"

- **scheduling-features autonomous mode** - Auto-create feature sprints
  - Auto-calculates feature-only velocity
  - Auto-groups features by epic (if assigned)
  - Auto-selects features by priority
  - Creates single or multiple sprints based on epic grouping
  - Time: 2-3 minutes per sprint (vs 5-10 min interactive)
  - Invocation: "auto-schedule features"

**Wave 3: Polish Skills (Conservative):**
- **scheduling-implementation-plan autonomous mode** - Auto-schedule plans to sprints
  - Auto-discovers unscheduled plans (if no filename provided)
  - Auto-counts tasks and determines sprint breakdown
  - Auto-splits at natural boundaries (phases, sections)
  - Auto-links to features (if FEAT-XXX in filename)
  - Time: 1-2 minutes per plan (vs 2-7 min interactive)
  - Invocation: "auto-schedule plan [filename]"

- **fixing-bugs autonomous enhancements** - Auto-select bug to fix
  - Auto-selects highest priority unresolved bug
  - Priority: P0 in sprint → P0 triaged → P1 in sprint → P1 triaged → P2
  - Asks for confirmation if multiple P0 bugs (too critical to guess)
  - Prefers bugs with E2E tests (easier to verify)
  - Time: Same as interactive (30-60 min), just auto-selects bug
  - Invocation: "auto-fix bug"

### Changed

**Dual-Mode Operation Pattern:**
- All 6 skills now support both interactive and autonomous modes
- Interactive mode: Full human control with prompts (default)
- Autonomous mode: Auto-detection with conservative fallbacks (opt-in with "auto-" prefix)
- Mode selection: Determined by invocation phrase ("auto-triage" vs "triage")

**Aggressiveness Levels:**
- Aggressive (triaging): Easy to undo, high value (auto-triage all)
- Moderate (scheduling): Medium risk, needs velocity data (auto-schedule with capacity planning)
- Conservative (polish): Low frequency, complex decisions (auto-select but verify)

**Consistency Across Skills:**
- All autonomous modes source shared helpers from scripts/autonomous-helpers.sh
- All autonomous modes display detailed summaries without confirmation prompts
- All autonomous modes create structured git commits with changelogs
- All autonomous modes include conservative fallbacks for ambiguous cases

### Benefits

**Speed Improvements:**
- Triaging: 10-20x faster (1-2 min → 5-10 sec per item)
- Scheduling: 2-5x faster (5-10 min → 2-3 min per sprint)
- Bug fixing: Same speed (just auto-selects bug)

**Workflow Automation:**
Enables fully autonomous workflows:
```
auto-triage bugs → auto-schedule work items → auto-fix bug → auto-complete sprint
```

**Code Quality:**
- Shared utilities eliminate duplication
- Single source of truth for detection algorithms
- Easy to improve algorithms (update one file affects all skills)
- Testable independently

### Integration

**With Existing Skills:**
- completing-sprints already had autonomous mode (reference implementation)
- All 6 new autonomous modes follow the same pattern
- Backward compatible: interactive mode unchanged, autonomous opt-in

**With Workflow:**
- Autonomous modes integrate seamlessly with existing workflows
- Can mix interactive and autonomous (e.g., auto-triage, then manual schedule)
- Conservative fallbacks ensure safe operation

### Notes

**Use autonomous modes when:**
- Processing many items quickly (batch operations)
- Clear priority indicators exist (P0/P1, must-have)
- Trust auto-detection algorithms
- Want fast iteration without prompts

**Use interactive modes when:**
- Uncertain about decisions (new categories, ambiguous severity)
- Want full control over every decision
- Complex edge cases that need human judgment
- Prefer explicit confirmation at each step

**Future enhancements:**
- Add --dry-run flags for autonomous modes (preview before commit)
- Add configurable aggressiveness levels (strict/moderate/aggressive)
- Add machine learning for improved duplicate detection
- Add integration with CI/CD for automated triaging

## [2.1.3] - 2025-11-21

### Added

**Sprint Completion System:**
- **skills/completing-sprints/** - Systematic sprint completion with retrospectives and validation
  - Dual-mode operation: Interactive (human-led) and Autonomous (Claude-led)
  - Interactive mode: ~5-10 minutes per sprint with AskUserQuestion prompts
  - Autonomous mode: ~2-3 minutes per sprint with auto-detection
  - Four-phase workflow:
    1. Select Sprint & Review Completion
    2. Handle Incomplete Items
    3. Sprint Completion Details
    4. Update Files and Commit
  - Auto-detection from project state (bugs.yaml, features.yaml, ROADMAP.md, plans, git)
  - Marks bugs as resolved/unresolved, features as completed/partial/incomplete
  - Incomplete item handling: return to backlog, move to next sprint, or keep in current sprint
  - Sets completion type: successful (≥80%), partial (50-79%), pivoted (<50%)
  - Optional retrospective generation (with stats and manual notes, or stats only)
  - Updates all files: bugs.yaml, features.yaml, sprint docs, ROADMAP.md, index files
  - Creates retrospective documents: docs/plans/sprints/retrospectives/SPRINT-XXX-retrospective.md
  - Git commit with detailed statistics and changelog

**Data Validation:**
- **scripts/validate-sprint-data.sh** - Sprint data consistency validation
  - Check 1: Sprint Document ↔ YAML consistency (work items, checkboxes, statuses)
  - Check 2: ROADMAP.md ↔ Sprint Documents consistency (status, item counts)
  - Check 3: Status lifecycle validation (valid status transitions for completed sprints)
  - Check 4: Completion integrity (completion_type, completed_at, duration_days fields)
  - Catches orphaned references and data inconsistencies
  - Auto-fix mode for correctable issues (--fix flag)
  - Verbose mode for detailed explanations (--verbose flag)
  - Integrated into completing-sprints workflow (runs before commit)
  - Exit codes: 0 (pass), 1 (errors), 2 (warnings only)

**Data Schema Extensions:**
- **Feature partial completion:** Added completion_percentage field (0-100) to features.yaml
- **Work item move tracking:** Added moved_from field to track items moved between sprints
- **Sprint completion metadata:** Added completed, duration, completion_type fields to sprint documents

### Changed

**Extension Documentation:**
- extensions/feature-management/README.md updated to v1.1
  - Added completing-sprints as 6th skill
  - Added Workflow 4: Sprint Completion example
  - Updated workflow description: "capture → triage → schedule → implement → complete"
- EXTENSIONS.md updated with completing-sprints skill details
  - Added to six-skill workflow description
  - Added Step 4: Complete sprint to Quick Start

**Feature Management Extension:**
- Now provides complete sprint lifecycle: create → work → complete → retrospect → repeat
- Works with sprints created by scheduling-work-items, scheduling-features, or scheduling-implementation-plan
- Handles both unified (bugs + features) and feature-only sprints

### Integration

**Complete sprint lifecycle workflow:**
```
scheduling-work-items → creates sprint with bugs + features
   ↓
[Work during sprint, update statuses]
   ↓
completing-sprints → completes sprint, generates retrospective
   ↓
Sprint document updated, ROADMAP.md updated, data validated
```

**Validation integration:**
```
completing-sprints skill (Phase 4, Step 7)
   ↓
scripts/validate-sprint-data.sh
   ↓
If validation passes → git commit
If validation fails → abort, show errors
```

### Notes

**Why sprint completion matters:**
- Provides closure to sprint work
- Generates retrospectives for learning and improvement
- Maintains data consistency across all files
- Handles incomplete work systematically
- Tracks velocity and completion rates
- Prevents data drift through validation

**Use completing-sprints when:**
- End of sprint cycle (2 weeks typical)
- Want to review sprint progress systematically
- Need to generate sprint retrospective
- Moving incomplete work to next sprint or backlog
- Want to ensure data consistency

**Interactive vs Autonomous mode:**
- Interactive: Human reviews and approves each step (recommended for important sprints)
- Autonomous: Claude auto-detects and completes based on project state (for routine completions)

### Design

Based on: docs/plans/2025-11-21-completing-sprints-design.md

**Key design decisions:**
- Dual-mode operation for flexibility (human-led vs autonomous)
- Auto-detection from multiple sources (yaml, roadmap, plans, git)
- Structured retrospectives with statistics
- Validation script ensures ongoing data integrity
- Conservative defaults in autonomous mode
- Comprehensive error handling for all edge cases

## [2.1.2] - 2025-11-14

### Added

**Unified Bug + Feature Sprint Planning:**
- **skills/scheduling-work-items/** - Unified sprint planning with bugs AND features
  - Displays both triaged bugs and approved features in one view
  - Unified prioritization across bugs vs features (P0 vs Must-Have)
  - Capacity planning showing total items before committing
  - Creates sprints with mixed bugs and features
  - Updates both bugs.yaml and features.yaml with sprint_id
  - Generates sprint documents with separate bugs and features sections
  - Updates ROADMAP.md with unified bugs + features view
  - ~3-5 minutes per sprint (+ 5-10 min per feature if creating implementation plans)

**Bug Status Lifecycle:**
- Extended bugs.yaml schema to support sprint assignment
  - New status: `scheduled` (bug assigned to sprint, not yet started)
  - New field: `sprint_id` (e.g., "SPRINT-001")
  - New field: `scheduled_at` (ISO 8601 timestamp)
- Status lifecycle: reported → triaged → scheduled → in_progress → resolved

### Changed

**skills/triaging-bugs:** Major update for sprint integration
- Added Phase 3: Sprint Assignment with three workflow options:
  1. **Assign to Sprint** - Schedule bugs into sprint (new workflow)
     - List existing sprints or create new sprint
     - Update bugs.yaml with sprint_id and status="scheduled"
     - Update sprint document with bugs section
     - Update ROADMAP.md with bugs
     - Git commit
  2. **Fix Immediately** - Create worktree and fix now (original workflow)
  3. **Mark Triaged Only** - Mark as triaged for later scheduling
- Updated bug status transitions to support sprint workflow
- Added documentation for bug status lifecycle
- Updated success criteria and files modified sections

**ROADMAP.md Format:**
- Now shows bugs AND features together in sprint sections
- Separate subsections for features and bugs within each sprint
- Unified progress tracking across both work item types

**Sprint Document Format:**
- Added "Bugs" section with P0/P1/P2 grouping
- Shows bug severity, status, E2E test links
- Unified progress tracking (features + bugs)

### Integration

**New unified workflow:**
```
triaging-bugs → status="triaged" (bugs.yaml)
triaging-features → status="approved" (features.yaml)
   ↓
scheduling-work-items → unified sprint planning
   ↓
Sprint document + ROADMAP.md with bugs AND features
```

**Alternative workflows:**
1. Quick bug assignment: triaging-bugs "Assign to Sprint" → sprint document
2. Feature-only: scheduling-features (unchanged)
3. Plan bridging: scheduling-implementation-plan (unchanged)

### Notes

**Why both bugs and features in sprints?**
- Real-world sprint planning includes both bug fixes and new features
- Prioritize across types (P0 bug vs Must-Have feature)
- Capacity planning with total work items
- Unified progress tracking

**Use scheduling-work-items when:**
- Planning sprint with both bugs and features
- Want unified view of all schedulable work
- Need to prioritize across bugs vs features

**Use triaging-bugs "Assign to Sprint" when:**
- Quick bug-only sprint assignment during triage
- Adding bugs to existing sprint

**Use scheduling-features when:**
- Feature-only sprint planning
- Don't have bugs to schedule

## [2.1.1] - 2025-11-14

### Added

**Feature Management Extension:**
- **extensions/feature-management/** - Complete feature request workflow
  - **skills/reporting-features/** - Interactive feature capture with auto-IDs (FEAT-001, etc.)
    - Structured prompting (title, description, category, priority, user value)
    - Duplicate detection with fuzzy matching
    - Stores in features.yaml with status="proposed"
    - ~2 minutes per feature capture
  - **skills/triaging-features/** - Batch review and prioritization
    - Smart filtering (by category, priority, date)
    - Actions: approve, reject, reprioritize, assign to epic
    - Updates status to "approved" or "rejected"
    - ~1-2 minutes per feature review
  - **skills/scheduling-features/** - Sprint planning with superpowers integration
    - Schedule approved features into sprints
    - Creates sprint documents in docs/plans/sprints/
    - Optional: Create implementation plans (superpowers:brainstorming + writing-plans)
    - Optional: Execute features immediately (superpowers:executing-plans or subagent-driven-development)
    - Auto-generates ROADMAP.md
    - Updates status to "scheduled" or "in-progress"
  - **skills/scheduling-implementation-plan/** - Convert existing plans to sprint tasks (NEW)
    - Bridges standalone implementation plans into sprint system
    - Parses tasks, dependencies, and estimates from any plan
    - Single sprint or multi-sprint breakdown with intelligent suggestions
    - Updates ROADMAP.md with task-level detail and dependencies
    - Links implementation plan to sprints (adds metadata)
    - Works with superpowers:writing-plans output or manual plans
    - If FEAT-XXX plan: Updates features.yaml with sprint_id
    - ~2-7 minutes depending on plan complexity
  - **README.md** - Complete usage guide with workflows and examples
  - **DESIGN.md** - System architecture from HN2 production use
  - **TESTING.md** - Test cases and validation procedures
  - **examples/** - Sample features.yaml, sprint document, and roadmap

**Storage Format:**
- features.yaml - All feature requests with auto-incrementing IDs
- docs/features/index.yaml - Fast lookup index
- docs/plans/sprints/ - Sprint documents
- docs/plans/features/ - Implementation plans (optional)
- ROADMAP.md - Auto-generated project roadmap

**Integration:**
- Full superpowers workflow integration
- **NEW:** Bridge standalone plans to sprint system (scheduling-implementation-plan)
- superpowers:writing-plans → scheduling-implementation-plan → ROADMAP.md with tasks
- superpowers:executing-plans can read ROADMAP.md for task-level execution
- Optional implementation planning
- Optional immediate execution
- Flexible workflows (schedule only, plan later, bridge standalone plans, or full lifecycle)

### Changed

**EXTENSIONS.md:**
- Added comprehensive Feature Management section
- Updated Quick Reference table with feature-management extension
- Added example workflows for feature request → sprint planning
- Updated with scheduling-implementation-plan skill (4 skills total now)
- Added superpowers integration notes for bridging standalone plans

**README.md:**
- Added feature-management to Optional Extensions table
- Updated "What's New" section for v2.1.1

### Notes

**Based on:** Health Narrative 2 feature request system (real-world usage, 2+ weeks)

**When to use:**
- Projects with feature backlogs
- Sprint planning workflows
- Superpowers workflow integration
- Need for roadmap visibility

**Results from HN2:**
- 100% feature capture rate (zero lost in discussion)
- 0 duplicate features after adding duplicate detection
- Clear sprint planning with auto-generated roadmap
- Optional full lifecycle (idea → implementation in one flow)

## [2.1.0] - 2025-11-13

### Added

**Core Skills (Bug Reporting System):**
- **skills/reporting-bugs/** - Interactive bug capture during manual testing
  - Structured prompting for bug details (title, repro steps, severity)
  - Optional E2E test generation (Maestro flows)
  - Stores in bugs.yaml with metadata
- **skills/triaging-bugs/** - Batch bug review and prioritization
  - Review all active bugs
  - Select bugs to fix
  - Create worktree and generate plan
- **skills/fixing-bugs/** - Autonomous bug fixing with TDD
  - Uses systematic-debugging skill
  - Follows RED-GREEN-REFACTOR cycle
  - Updates bugs.yaml on completion

**Optional Extensions:**
- **extensions/testing-infra/** - E2E testing infrastructure setup
  - Autonomous setup in 5-10 minutes
  - Supports React Native (iOS/Android), native mobile, web apps
  - Installs Maestro/Detox/Playwright/Cypress
  - Creates quality gates and sample tests
  - Generates 1,600-2,400 lines of documentation
- **extensions/build-deploy-setup/** - iOS/Android deployment pipelines
  - 30-60 minute autonomous setup across 5 phases
  - Fastlane automation with quality gates
  - TestFlight + App Store configuration
  - Code signing setup (API Key, Manual, Match)
  - Optional CI/CD integration (GitHub Actions, GitLab, etc.)

**New Documentation:**
- **EXTENSIONS.md** - Comprehensive guide for skills and extensions
  - When to use each extension
  - Installation instructions (skill vs prompt)
  - Decision tree for which extensions you need
  - Troubleshooting and maintenance
  - Contributing new extensions

### Changed

**README.md:**
- Added "What's New" section with v2.1 and v2.0 highlights
- Added Skills & Extensions section to "What's Included"
- Updated version to v2.1

### Design Rationale

**Problem:** Core toolkit provides excellent session management, but projects still need:
1. Structured bug tracking during development
2. E2E testing infrastructure setup
3. Build/deploy automation for mobile apps

**Solution:**
- **Bug reporting as core skill** - Universal need across all projects
- **Testing/build as extensions** - Project-type specific, optional install
- Clear decision tree in EXTENSIONS.md for when to use each

**Benefits:**
- Bug reporting integrated with TDD workflow
- Testing setup saves hours of configuration
- Build/deploy setup handles complex iOS/Android pipelines
- All work together: bugs → tests → builds → deployment

### Migration from v2.0

No breaking changes. All v2.0 functionality intact.

**To add bug reporting:**
- Already included! Skills are in `skills/` directory
- Just start using: "I found a bug - [describe it]"

**To add extensions:**
```bash
# Testing infrastructure
cp -r extensions/testing-infra/skills/setup-testing-infrastructure .claude/skills/
# Then: "Set up testing infrastructure"

# Build/deploy
cp -r extensions/build-deploy-setup/skills/setup-build-deploy .claude/skills/
# Then: "Set up build and deploy pipeline"
```

---

## [2.0.0] - 2025-11-13

### Added

**New Documentation System:**
- **HANDOFF.md template** - Session-to-session handoff with < 100 line hard limit
- **BLOCKERS.md template** - Project-specific "what NOT to try" knowledge base
- **USER-GUIDE.md** - Maintenance guide for humans (weekly/monthly checklists)
- **case-studies/** directory with Health Narrative 2 implementation story

**Automation & Validation:**
- **scripts/validate-docs.sh** - Validates HANDOFF.md < 100, BLOCKERS.md < 400, RECOVERY.md < 1000 lines
- **scripts/archive-handoff.sh** - One-command archival of old handoff versions
- **scripts/pre-commit** - Git hook for automatic documentation validation
- **scripts/install-git-hooks.sh** - One-command hook installation
- **scripts/build-sample-database.ts** - Sample database builder from HN2 project
- **scripts/verify-build.sh** - Build verification script

**Enhanced Documentation:**
- CONTINUE-SESSION.md: Added pre-flight checklist, mid-session update guidance, HANDOFF.md workflow
- END-SESSION.md: Added Step 2.5 (structured HANDOFF.md template), Step 2.6 (knowledge base workflow)
- RECOVERY.md: Added navigation header, table of contents, scenario template, HANDOFF.md references

### Changed

**Breaking Changes:**
- **SESSION-STATUS.md deprecated** - Replaced by HANDOFF.md + BLOCKERS.md system
- Project structure now expects `HANDOFF.md` and `BLOCKERS.md` in project directory
- END-SESSION.md workflow now uses structured templates with line budgets

**Improvements:**
- Session handoff time reduced from 30+ minutes to < 5 minutes
- Documentation size reduced by 86% (485 → 65 lines in HN2 project)
- Eliminated documentation drift through automated constraints
- Knowledge base now split: BLOCKERS.md (project-specific) + RECOVERY.md (general)

### Deprecated

- **SESSION-STATUS.md** - Use HANDOFF.md + BLOCKERS.md instead (see UPDATE-NOTES.md for migration)
- **git-hooks/** directory - Use scripts/ directory instead (both remain functional for compatibility)

### Design Rationale

**Problem:** v1.0 SESSION-STATUS.md grew uncontrollably (200 → 1,559 lines over 3 weeks), causing:
- 40-60% reduction in development velocity
- Duplicate investigations (same issue 3-4 times)
- 30+ minute session handoffs
- Information overload

**Solution:** Treat documentation like code with hard limits, validation, and automation:
- HANDOFF.md < 100 lines enforced by validation script
- Structured templates with per-section line budgets
- Automated archival preserves history without bloat
- Git hooks catch drift before it happens

**Results from Health Narrative 2 (2+ weeks production use):**
- 86% documentation size reduction
- < 5 minute session handoffs
- Zero documentation drift
- 87% reduction in duplicate work
- System self-maintains through checklists + automation

**[Full case study →](case-studies/healthnarrative2-documentation-system.md)**

### Migration from v1.0

**For existing projects using v1.0:**

1. Archive current SESSION-STATUS.md:
   ```bash
   mkdir -p archive/handoff
   cp SESSION-STATUS.md archive/handoff/$(date +%Y-%m-%d)-full-history.md
   ```

2. Create HANDOFF.md from template in END-SESSION.md

3. Extract "Known Issues" from SESSION-STATUS.md → BLOCKERS.md template

4. Install new scripts:
   ```bash
   cp -r /path/to/dev-toolkit/scripts ./
   chmod +x scripts/*.sh
   ./scripts/install-git-hooks.sh
   ```

5. Update workflow to use HANDOFF.md instead of SESSION-STATUS.md

**See UPDATE-NOTES.md for detailed migration guide.**

---

## [1.0.0] - 2025-01-31

### Added
- Initial release of Claude Code Development Toolkit
- Complete session management system for Claude Code projects
- Core workflow documents:
  - START-HERE.md - First session onboarding template
  - CONTINUE-SESSION.md - Continuing session brief
  - END-SESSION.md - Mandatory session handoff checklist
  - SESSION-STATUS.md - Living progress tracker template
  - RECOVERY.md - Troubleshooting guide with 9 common scenarios
  - PROMPTS.md - Copy-paste prompts for all session types
- Setup and configuration:
  - PROJECT-CONFIG.md - Project-specific configuration template
  - SETUP.md - Step-by-step customization guide
  - QUICK-START.md - 15-minute quick start guide
  - PLACEHOLDER-REFERENCE.md - Complete placeholder documentation (~50 placeholders)
- Git automation:
  - pre-commit hook that reminds to update SESSION-STATUS.md
  - setup-git-hooks.sh installation script
- Documentation:
  - README.md - Complete toolkit overview
  - LICENSE - MIT License
  - CHANGELOG.md - This file
- Project-agnostic design supporting any tech stack (Node, Python, Go, Rust, etc.)
- ~50 placeholders for complete customization
- Quality gate enforcement (tests, coverage, type checking, build)
- TDD workflow templates
- Recovery procedures for common failure scenarios

### Design Decisions
- Template-based approach with placeholders for maximum flexibility
- Separate documents for different session types to minimize cognitive load
- Mandatory session handoff to preserve context between sessions
- Git hooks for automated reminders
- Recovery guide based on real troubleshooting scenarios

### Example Projects
- Health Narrative - Patient health record app (React Native + Expo, TypeScript, SQLite)
  - First production use of this toolkit
  - Demonstrated 5-week MVP workflow with autonomous Claude Code development

## [Unreleased]

### Planned
- Script to automate placeholder replacement
- Additional tech stack examples (Rust, Java, Ruby)
- VS Code extension for quick toolkit setup
- Template variants for different project types (CLI, API, library, web app, mobile app)
- Integration with popular CI/CD platforms (GitHub Actions, GitLab CI)

---

## Version History

**1.0.0** - Initial public release (2025-01-31)
