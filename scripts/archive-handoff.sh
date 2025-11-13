#!/bin/bash
# Archive HANDOFF.md to prepare for rewriting with template
# Preserves full history while keeping current HANDOFF.md lean

set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files
HANDOFF="HANDOFF.md"
ARCHIVE_DIR="archive/handoff"
TIMESTAMP=$(date +%Y-%m-%d)
ARCHIVE_FILE="$ARCHIVE_DIR/$TIMESTAMP-session.md"

echo -e "${BLUE}📦 Archiving HANDOFF.md...${NC}"
echo ""

# Check if HANDOFF.md exists
if [ ! -f "$HANDOFF" ]; then
  echo -e "${RED}❌ HANDOFF.md not found${NC}"
  echo "   Make sure you're in the healthnarrative directory"
  exit 1
fi

# Get current line count
LINES=$(wc -l < "$HANDOFF" | tr -d ' ')
echo "Current HANDOFF.md size: $LINES lines"

# Check if archival is needed
if [ "$LINES" -le 80 ]; then
  echo -e "${GREEN}✅ HANDOFF.md is only $LINES lines${NC}"
  echo "   Archival not needed (recommended when > 80 lines)"
  echo ""
  read -p "Archive anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Archival cancelled"
    exit 0
  fi
fi

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Check if archive file already exists
if [ -f "$ARCHIVE_FILE" ]; then
  # Add counter to filename
  COUNTER=1
  while [ -f "$ARCHIVE_DIR/$TIMESTAMP-session-$COUNTER.md" ]; do
    ((COUNTER++))
  done
  ARCHIVE_FILE="$ARCHIVE_DIR/$TIMESTAMP-session-$COUNTER.md"
  echo -e "${YELLOW}⚠️  Archive for today already exists${NC}"
  echo "   Using filename: $(basename $ARCHIVE_FILE)"
fi

# Copy HANDOFF.md to archive
cp "$HANDOFF" "$ARCHIVE_FILE"

echo ""
echo -e "${GREEN}✅ Archived successfully${NC}"
echo "   Location: $ARCHIVE_FILE"
echo "   Size: $LINES lines"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "   1. Rewrite HANDOFF.md using template from END-SESSION.md"
echo "   2. Keep only current + 1 previous session (delete older)"
echo "   3. Use links instead of embedded content"
echo "   4. Run: ./scripts/validate-docs.sh"
echo ""
echo -e "${BLUE}Template reminder:${NC}"
echo "   • Quick Start: MAX 10 lines"
echo "   • State Check: MAX 5 lines"
echo "   • Active Blockers: MAX 10 lines"
echo "   • Recent Session Summary: MAX 40 lines (2 sessions only)"
echo "   • Context You Might Need: MAX 15 lines (5 links)"
echo "   • If Something's Wrong: MAX 10 lines"
echo "   • Total budget: 90 lines (10 line buffer)"
echo ""
echo "Archive preserved at: $ARCHIVE_FILE"
