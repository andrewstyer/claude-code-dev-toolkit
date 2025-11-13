# Changelog

All notable changes to the Claude Code Development Toolkit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
