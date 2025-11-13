# Active Blockers & Known Issues - {{PROJECT_NAME}}

**Last Updated:** [DATE]
**Purpose:** What NOT to try - failed approaches to avoid

**Scope:** {{PROJECT_NAME}}-specific issues
**For general troubleshooting:** See `../RECOVERY.md`
**For deep investigations:** See `docs/investigations/INDEX.md`

---

## ✅ RESOLVED: [Issue Name] ([Date Resolved])

**Symptom:** [What you'll see when you hit this]

**Failed Approaches:**
- ❌ [Approach 1] - [Why it failed]
  - Investigation: [link to docs/investigations/YYYY-MM-DD-issue.md]
- ❌ [Approach 2] - [Why it failed]
  - Investigation: [link]

**Approved Solution:**
✅ [What works] - [Investigation link or explanation]

**Steps to Resolve:**
```bash
# Specific commands that fix it
```

**Status:** RESOLVED in [Build X / Version X]
**Key Lesson:** [One sentence takeaway]

---

## ⚠️ ACTIVE: [Issue Name]

**Symptom:** [What you'll see when you hit this]

**Failed Approaches:**
- ❌ [Approach] - [Why it failed] - [Investigation link]

**Current Workaround:**
[If any - temporary solution while investigating]

**Status:** [P0/P1/P2] - [Blocking/Non-blocking]
**Investigation:** [Link to docs/investigations/ or TBD]
**Next Step:** [What to try next or what's needed]

---

## 📋 REPORTED: [Issue Name]

**Symptom:** [What was observed]

**Status:** [P0/P1/P2] - Reported but not yet investigated
**Next Step:** Create investigation doc in docs/investigations/

---

## Adding New Issues

**When you discover a new issue that wastes time, add it here immediately.**

**Template:**
```markdown
## ❌ [Issue Name] - [Status: ACTIVE/RESOLVED]

**Symptom:** [What you'll see when you hit this]

**Failed Approaches:**
- ❌ [What was tried] - [Why it failed] - [Investigation doc link]

**Approved Solution:**
✅ [What works] - [Investigation doc link]

**Status:** [P0/P1/P2] - [Blocking/Non-blocking]
**Last Updated:** [Date]
```

**After adding:**
1. Update "Last Updated" date at top
2. Link to investigation doc in `docs/investigations/`
3. Run validation: `./scripts/validate-docs.sh`
4. Commit with message: `docs: add blocker for [issue name]`

---

## Archiving Resolved Issues

**When BLOCKERS.md > 400 lines:**
1. Move oldest RESOLVED issues to `archive/resolved-blockers.md`
2. Keep recent resolved issues for reference (last 3-6 months)
3. Update "Last Updated" date
4. Commit changes

---

**System Version:** 2.0 (November 2025)
**Based on:** Health Narrative 2 documentation system
**Maintenance:** Review weekly, archive resolved issues when file > 400 lines
**See also:** `../USER-GUIDE.md` for maintenance procedures
