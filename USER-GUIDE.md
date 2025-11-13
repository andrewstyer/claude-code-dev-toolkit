# User Guide - Maintaining Your Claude Code Development Toolkit

**Audience:** Human developers maintaining projects using this toolkit
**Purpose:** Keep the documentation system healthy and productive
**Time commitment:** 5-15 minutes per week

---

## 🎯 Quick Start

**Your role:** Monitor the documentation system to ensure it stays useful for Claude Code

**Key principle:** The toolkit is self-maintaining IF Claude Code follows the checklists. Your job is to catch when the system degrades and course-correct.

---

## 📅 Weekly Maintenance (5 minutes)

**Every Friday (or end of week):**

### 1. Check Documentation Size

```bash
wc -l HANDOFF.md BLOCKERS.md RECOVERY.md
```

**Expected:**
- HANDOFF.md: < 100 lines (hard limit)
- BLOCKERS.md: < 400 lines (soft limit)
- RECOVERY.md: < 1000 lines (soft limit)

**If over limits:**
- Run validation: `./scripts/validate-docs.sh`
- Follow suggestions in output
- Archive or trim as needed

### 2. Review Recent Commits

```bash
git log --oneline -20
```

**Look for:**
- ✅ Regular "docs: update handoff" commits (good - system being used)
- ❌ Multiple "fix:" or "revert:" commits (red flag - something's wrong)
- ❌ No doc commits for 3+ sessions (red flag - handoff not happening)

### 3. Scan HANDOFF.md

```bash
cat HANDOFF.md
```

**Check:**
- [ ] "Next task" is clear and specific?
- [ ] "Active Blockers" section updated?
- [ ] Recent session summary is < 1 week old?

**If anything unclear:**
- Ask Claude Code to update HANDOFF.md with current status
- Review END-SESSION.md checklist compliance

---

## 🗓️ Monthly Maintenance (15 minutes)

**First of each month:**

### 1. Archive Old Handoffs

```bash
ls -lh archive/handoff/
```

**If > 20 archived files:**
- Create monthly archive: `archive/handoff/2025-11/`
- Move that month's files into subdirectory
- Keep structure navigable

### 2. Review BLOCKERS.md

```bash
cat BLOCKERS.md
```

**Archive resolved issues if:**
- More than 10 resolved issues listed
- Oldest resolved issue is > 6 months old
- File approaching 400 lines

**Process:**
```bash
# Create/append to resolved issues archive
cat >> archive/resolved-blockers.md <<EOF

## [Date] - Archived Issues
[paste resolved issues here]
EOF

# Remove from BLOCKERS.md
# Keep only recent (< 6 months) resolved issues for reference
```

### 3. Check Investigation Index

```bash
cat docs/investigations/INDEX.md
```

**Ensure:**
- All investigation docs are listed
- Status tags are current (RESOLVED/ACTIVE)
- No orphaned investigation files

### 4. Validate Scripts Still Work

```bash
./scripts/validate-docs.sh
./scripts/archive-handoff.sh --dry-run  # if available
```

**Should pass without errors.**

---

## 🚨 Warning Signs - System Is Degrading

**Watch for these red flags:**

### Critical (Fix Immediately)

❌ **HANDOFF.md > 200 lines**
- System has failed completely
- Claude Code not following END-SESSION.md
- **Fix:** Manually rewrite using template, archive old version

❌ **No doc commits for 5+ sessions**
- Handoff system abandoned
- Next Claude Code session will have no context
- **Fix:** Review last 5 sessions, write HANDOFF.md manually

❌ **Tests failing for 2+ sessions**
- Quality gates being ignored
- Technical debt accumulating
- **Fix:** Stop new work, fix tests, review RECOVERY.md usage

### Warning (Fix Soon)

⚠️ **HANDOFF.md 100-150 lines**
- Approaching limit, needs cleanup
- **Fix:** Run `./scripts/archive-handoff.sh`, rewrite

⚠️ **Same issue in BLOCKERS.md for 4+ weeks**
- Either not actually being worked, or blocker is incorrect
- **Fix:** Review with Claude Code, update status or remove

⚠️ **Multiple git hooks not installed**
- Automation not running
- **Fix:** Run `./scripts/install-git-hooks.sh`

### Info (Monitor)

ℹ️ **BLOCKERS.md > 300 lines**
- Growing but still manageable
- **Action:** Plan archival for next monthly review

ℹ️ **New investigation docs without INDEX.md updates**
- Investigations not being cataloged
- **Action:** Remind Claude Code to update INDEX.md

---

## 🛠️ Emergency Procedures

### Emergency 1: HANDOFF.md Is Completely Wrong

**Symptom:** Claude Code starts session with wrong context

**Fix (5 minutes):**

1. Review last 3 commits:
   ```bash
   git log -3 --stat
   ```

2. Create accurate HANDOFF.md:
   ```bash
   # Use template from HANDOFF.md
   # Fill in from git log + your knowledge
   ```

3. Tell Claude Code:
   > "I've manually updated HANDOFF.md. Please read it and continue from the 'Next task' listed."

### Emergency 2: All Tests Failing, System Broken

**Symptom:** Can't run anything, multiple failures

**Fix (15 minutes):**

1. Find last working commit:
   ```bash
   git log --oneline --all
   # Look for last "tests passing" commit
   ```

2. Reset to that commit:
   ```bash
   git reset --hard <commit-hash>
   # OR create new branch from that point
   git checkout -b recovery/<issue-name> <commit-hash>
   ```

3. Document what went wrong:
   - Add to BLOCKERS.md
   - Create investigation doc if complex

4. Tell Claude Code to fix forward from working state

### Emergency 3: Documentation Chaos (Multiple Conflicting Docs)

**Symptom:** Duplicate HANDOFF.md, conflicting BLOCKERS.md, confusion

**Fix (30 minutes):**

1. Identify authoritative versions:
   ```bash
   # Check git log to see which is most recent
   git log --all -- HANDOFF.md BLOCKERS.md
   ```

2. Archive everything:
   ```bash
   mkdir -p archive/emergency-$(date +%Y-%m-%d)
   cp HANDOFF.md BLOCKERS.md archive/emergency-$(date +%Y-%m-%d)/
   ```

3. Recreate from scratch using templates:
   - Use HANDOFF.md template
   - Use BLOCKERS.md template
   - Pull info from git log + your knowledge

4. Document the chaos in BLOCKERS.md:
   ```markdown
   ## ⚠️ ACTIVE: Documentation Sync Issues

   **Symptom:** Multiple conflicting doc versions

   **Root Cause:** [What went wrong]

   **Resolution:** Emergency rebuild on [date]

   **Prevention:** [What to do differently]
   ```

---

## 🎓 How to Intervene During Sessions

### When Claude Code Asks for Help

**Good signs:**
- "I'm stuck on X, checked RECOVERY.md scenario Y, still not working"
- "Should I add this to BLOCKERS.md?"
- "HANDOFF.md unclear - what should I prioritize?"

**Response pattern:**
1. Validate they checked BLOCKERS.md and RECOVERY.md first ✅
2. Provide specific guidance
3. Ask them to update docs with decision

### When Claude Code Doesn't Ask (But Should)

**Red flags:**
- Retrying same failed approach 3+ times
- Not checking BLOCKERS.md for known issue
- Not updating HANDOFF.md after completing tasks

**Intervention:**
> "Stop. Have you checked BLOCKERS.md for this issue? Let's look at RECOVERY.md scenario X."

> "Before continuing, please update HANDOFF.md with current status so we have a checkpoint."

### When to Override HANDOFF.md

**Common scenarios:**

**Urgent bug in production:**
> "Ignore HANDOFF.md for now. Priority is fixing [bug]. After fix, update HANDOFF.md with new 'Next task'."

**Direction change:**
> "Let's shift focus from [old task] to [new task]. Update HANDOFF.md Quick Start section with the new priority."

**HANDOFF.md is stale:**
> "HANDOFF.md is out of date. Based on git log, please rewrite it using the template in END-SESSION.md."

---

## 📊 Success Metrics

**You'll know the system is working when:**

✅ **Session handoff is smooth** (< 5 minutes for Claude Code to get context)
✅ **No duplicate work** (issues investigated once, documented, not repeated)
✅ **HANDOFF.md stays lean** (< 100 lines, readable in 2 minutes)
✅ **You spend < 10 min/week** on maintenance (system is self-maintaining)
✅ **Claude Code autonomy is high** (works for hours without intervention)

**If these aren't true:**
- Review "Warning Signs" section above
- Check if END-SESSION.md checklist being followed
- Validate scripts are installed and running

---

## 🔧 Common Maintenance Tasks

### Task: Manually Archive HANDOFF.md

```bash
# Check current size
wc -l HANDOFF.md

# If > 80 lines, archive:
./scripts/archive-handoff.sh

# OR manually:
mkdir -p archive/handoff
cp HANDOFF.md archive/handoff/$(date +%Y-%m-%d)-session.md

# Rewrite HANDOFF.md using template from END-SESSION.md
```

### Task: Update BLOCKERS.md

```bash
# Edit file
vim BLOCKERS.md  # or your editor

# Follow template in file
# Mark resolved issues with ✅
# Archive old resolved issues if file > 400 lines

# Validate
./scripts/validate-docs.sh

# Commit
git add BLOCKERS.md
git commit -m "docs: update BLOCKERS.md - mark issue X as resolved"
```

### Task: Add New Recovery Scenario

```bash
# Edit RECOVERY.md
vim RECOVERY.md

# Use scenario template at end of file
# Add to Table of Contents
# Test with Claude Code

# Validate
./scripts/validate-docs.sh

# Commit
git add RECOVERY.md
git commit -m "docs: add RECOVERY scenario for [issue type]"
```

---

## 🤝 Working with Claude Code

### Starting a New Session

**Your message:**
> "Read CONTINUE-SESSION.md and continue from where we left off"

**Claude Code will:**
1. Read HANDOFF.md for context (2 min)
2. Check BLOCKERS.md if relevant (2 min)
3. Continue from "Next task"

**You do:**
- Nothing, unless HANDOFF.md override needed

### Ending a Session

**Your message:**
> "Read END-SESSION.md and complete the session handoff"

**Claude Code will:**
1. Run quality checks
2. Update HANDOFF.md with structured template
3. Commit all changes
4. Provide session summary

**You do:**
- Review session summary
- Verify HANDOFF.md makes sense for next session

### When Things Go Wrong

**Your message:**
> "Read RECOVERY.md and follow scenario X to fix this"

**Claude Code will:**
1. Find appropriate scenario
2. Follow recovery steps
3. Document in BLOCKERS.md if recurring issue
4. Update HANDOFF.md with current state

**You do:**
- Provide additional context if Claude Code stuck
- Validate fix actually works

---

## 📚 Reference

### Key Files (Read These)

- **END-SESSION.md** - What Claude Code should do at end of session
- **CONTINUE-SESSION.md** - What Claude Code should do at start
- **RECOVERY.md** - Troubleshooting scenarios
- **HANDOFF.md** - Current session status (project directory)
- **BLOCKERS.md** - Known issues (project directory)

### Key Scripts

- **scripts/validate-docs.sh** - Check doc sizes, detect bloat
- **scripts/archive-handoff.sh** - Archive old HANDOFF.md versions
- **scripts/install-git-hooks.sh** - Install pre-commit hooks
- **scripts/pre-commit** - Git hook for validation

### Templates

All documents have templates embedded:
- HANDOFF.md template: in END-SESSION.md Step 2.5
- BLOCKERS.md template: in BLOCKERS.md itself
- Recovery scenario template: at end of RECOVERY.md

---

## 🎉 Tips for Success

1. **Trust but verify** - Claude Code follows checklists well, but check weekly
2. **Intervene early** - Small course corrections prevent big problems
3. **Keep docs lean** - Ruthlessly archive old information
4. **Document patterns** - Add to RECOVERY.md when you solve something 3+ times
5. **Use git** - Every doc change should commit, makes rollback easy

---

## 📞 Getting Help

**If this guide doesn't cover your situation:**

1. Check RECOVERY.md for troubleshooting scenarios
2. Review git log for similar past situations
3. Create investigation doc in docs/investigations/
4. Update this guide with new procedure (then commit)

---

**System Version:** 2.0 (November 2025)
**Based on:** Health Narrative 2 real-world usage (2+ weeks)
**Maintenance burden:** < 10 minutes/week (when system healthy)
**Last updated:** [Your date here]

---

**Remember:** The toolkit is designed to be self-maintaining through Claude Code following checklists. Your role is to monitor and course-correct when the system drifts. Most weeks you'll spend < 5 minutes just verifying everything is on track.
