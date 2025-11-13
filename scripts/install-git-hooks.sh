#!/bin/bash
# Install git hooks for documentation validation

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Installing git hooks...${NC}"
echo ""

# Find git root directory
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$GIT_ROOT" ]; then
  echo -e "${YELLOW}❌ Not in a git repository${NC}"
  exit 1
fi

echo "Git root: $GIT_ROOT"

# Check if .git directory exists
if [ ! -d "$GIT_ROOT/.git" ]; then
  echo -e "${YELLOW}❌ .git directory not found${NC}"
  exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_ROOT/.git/hooks"

# Install pre-commit hook
HOOK_SOURCE="$(pwd)/pre-commit"
HOOK_DEST="$GIT_ROOT/.git/hooks/pre-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
  echo -e "${YELLOW}❌ pre-commit script not found at: $HOOK_SOURCE${NC}"
  echo "   Make sure you're running this from the scripts directory"
  exit 1
fi

# Backup existing hook if present
if [ -f "$HOOK_DEST" ]; then
  echo -e "${YELLOW}⚠️  Existing pre-commit hook found${NC}"
  BACKUP="$HOOK_DEST.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$HOOK_DEST" "$BACKUP"
  echo "   Backed up to: $BACKUP"
fi

# Copy hook
cp "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo ""
echo -e "${GREEN}✅ Git hooks installed successfully${NC}"
echo ""
echo "Installed hooks:"
echo "  • pre-commit → Documentation validation"
echo ""
echo "The hook will run automatically before each commit."
echo "To bypass (not recommended): git commit --no-verify"
echo ""
