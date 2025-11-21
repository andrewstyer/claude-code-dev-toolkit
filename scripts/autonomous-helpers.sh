#!/usr/bin/env bash

# Autonomous Helpers - Shared Utilities for Autonomous Skill Modes
# Provides reusable detection and decision functions

set -euo pipefail

# Check for required tools
if ! command -v yq &> /dev/null; then
  echo "Error: yq not found. Install with: brew install yq" >&2
  exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect bug severity from title and description
# Usage: detect_bug_severity "title" "description"
# Returns: P0, P1, or P2
detect_bug_severity() {
  local bug_title="$1"
  local bug_description="${2:-}"

  # Convert to lowercase for matching
  local text=$(echo "$bug_title $bug_description" | tr '[:upper:]' '[:lower:]')

  # P0 patterns (critical)
  if echo "$text" | grep -qE "crash|data loss|corruption|unusable|breaks app|critical|cannot start|fatal"; then
    echo "P0"
    return 0
  fi

  # P1 patterns (high)
  if echo "$text" | grep -qE "broken|fails|error|doesn't work|not working|blocks|regression|broken feature"; then
    echo "P1"
    return 0
  fi

  # P2 patterns (low)
  if echo "$text" | grep -qE "alignment|styling|minor|cosmetic|polish|typo|ui.*issue|layout|spacing"; then
    echo "P2"
    return 0
  fi

  # Default fallback
  echo "P1"
}
