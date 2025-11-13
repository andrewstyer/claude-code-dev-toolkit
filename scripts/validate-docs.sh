#!/bin/bash
# Documentation System Validation Script
# Validates HANDOFF.md, BLOCKERS.md, and RECOVERY.md constraints

set -e

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# File paths
HANDOFF="HANDOFF.md"
BLOCKERS="BLOCKERS.md"
RECOVERY="../RECOVERY.md"

# Limits
HANDOFF_MAX=100
BLOCKERS_WARN=400
RECOVERY_WARN=1000

echo -e "${BLUE}🔍 Validating documentation system...${NC}"
echo ""

VALIDATION_FAILED=0

# =============================================================================
# HANDOFF.md Validation
# =============================================================================

echo -e "${BLUE}📋 HANDOFF.md${NC}"

if [ ! -f "$HANDOFF" ]; then
  echo -e "${RED}❌ HANDOFF.md not found${NC}"
  VALIDATION_FAILED=1
else
  HANDOFF_LINES=$(wc -l < "$HANDOFF" | tr -d ' ')

  if [ "$HANDOFF_LINES" -gt "$HANDOFF_MAX" ]; then
    echo -e "${RED}❌ HANDOFF.md is $HANDOFF_LINES lines (max: $HANDOFF_MAX)${NC}"
    echo -e "${YELLOW}   Required actions:${NC}"
    echo "   1. Archive old sessions: mkdir -p archive/handoff && cp $HANDOFF archive/handoff/\$(date +%Y-%m-%d)-session.md"
    echo "   2. Rewrite HANDOFF.md using template in ../END-SESSION.md"
    echo ""
    VALIDATION_FAILED=1
  else
    echo -e "${GREEN}✅ Size: $HANDOFF_LINES lines (under $HANDOFF_MAX limit)${NC}"
  fi

  # Check for common bloat patterns
  SESSION_COUNT=$(grep -c "^### Session [0-9]" "$HANDOFF" 2>/dev/null || echo "0")
  if [ "$SESSION_COUNT" -gt 2 ]; then
    echo -e "${YELLOW}⚠️  Warning: $SESSION_COUNT session summaries found (recommend max 2)${NC}"
    echo "   Consider archiving older sessions to archive/handoff/"
    echo ""
  fi

  # Check Quick Start section exists
  if ! grep -q "^## Quick Start" "$HANDOFF"; then
    echo -e "${YELLOW}⚠️  Warning: 'Quick Start' section not found${NC}"
    echo "   HANDOFF.md should follow the template structure"
    echo ""
  fi
fi

# =============================================================================
# BLOCKERS.md Validation
# =============================================================================

echo -e "${BLUE}🚧 BLOCKERS.md${NC}"

if [ ! -f "$BLOCKERS" ]; then
  echo -e "${YELLOW}⚠️  BLOCKERS.md not found (create if you have known issues)${NC}"
else
  BLOCKERS_LINES=$(wc -l < "$BLOCKERS" | tr -d ' ')

  if [ "$BLOCKERS_LINES" -gt "$BLOCKERS_WARN" ]; then
    echo -e "${YELLOW}⚠️  BLOCKERS.md is $BLOCKERS_LINES lines (recommend < $BLOCKERS_WARN)${NC}"
    echo "   Consider archiving resolved issues to archive/resolved-blockers.md"
    echo ""
  else
    echo -e "${GREEN}✅ Size: $BLOCKERS_LINES lines${NC}"
  fi

  # Count resolved vs active issues
  RESOLVED_COUNT=$(grep -c "^## ✅ RESOLVED:" "$BLOCKERS" 2>/dev/null || echo "0")
  ACTIVE_COUNT=$(grep -c "^## ⚠️ ACTIVE:" "$BLOCKERS" 2>/dev/null || echo "0")
  REPORTED_COUNT=$(grep -c "^## 📋 REPORTED:" "$BLOCKERS" 2>/dev/null || echo "0")

  echo -e "${GREEN}   Issues: $RESOLVED_COUNT resolved, $ACTIVE_COUNT active, $REPORTED_COUNT reported${NC}"

  if [ "$RESOLVED_COUNT" -gt 10 ]; then
    echo -e "${YELLOW}⚠️  Warning: $RESOLVED_COUNT resolved issues (consider archiving old ones)${NC}"
    echo ""
  fi
fi

# =============================================================================
# RECOVERY.md Validation
# =============================================================================

echo -e "${BLUE}🆘 RECOVERY.md${NC}"

if [ ! -f "$RECOVERY" ]; then
  echo -e "${YELLOW}⚠️  RECOVERY.md not found at $RECOVERY${NC}"
else
  RECOVERY_LINES=$(wc -l < "$RECOVERY" | tr -d ' ')

  if [ "$RECOVERY_LINES" -gt "$RECOVERY_WARN" ]; then
    echo -e "${YELLOW}⚠️  RECOVERY.md is $RECOVERY_LINES lines (recommend < $RECOVERY_WARN)${NC}"
    echo "   Consider:"
    echo "   - Consolidating similar scenarios"
    echo "   - Moving project-specific content to BLOCKERS.md"
    echo "   - Archiving obsolete scenarios to archive/recovery-scenarios.md"
    echo ""
  else
    echo -e "${GREEN}✅ Size: $RECOVERY_LINES lines${NC}"
  fi

  # Count scenarios
  SCENARIO_COUNT=$(grep -c "^### Scenario [0-9]" "$RECOVERY" 2>/dev/null || echo "0")
  echo -e "${GREEN}   Scenarios: $SCENARIO_COUNT${NC}"
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $VALIDATION_FAILED -eq 1 ]; then
  echo -e "${RED}❌ Documentation validation FAILED${NC}"
  echo ""
  echo "Please fix the issues above before committing."
  exit 1
else
  echo -e "${GREEN}✅ Documentation validation PASSED${NC}"
  echo ""
  echo "All documentation files are within recommended limits."
  exit 0
fi
