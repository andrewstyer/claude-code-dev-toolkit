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

# Calculate sprint velocity from completed sprints
# Usage: calculate_sprint_velocity [roadmap_file]
# Returns: Average items per sprint, or 0 if no data
calculate_sprint_velocity() {
  local roadmap_file="${1:-ROADMAP.md}"

  if [ ! -f "$roadmap_file" ]; then
    echo "0"
    return 1
  fi

  # Extract completed sprint stats from ROADMAP.md
  # Format: "Completion: 43% (3/7 items)"
  local total_items=0
  local completed_items=0
  local sprint_count=0

  while IFS= read -r line; do
    if echo "$line" | grep -q "completed -"; then
      ((sprint_count++))

      # Extract item counts
      if echo "$line" | grep -qE '\([0-9]+/[0-9]+ items\)'; then
        completed=$(echo "$line" | grep -oE '[0-9]+/[0-9]+ items' | cut -d'/' -f1)
        total=$(echo "$line" | grep -oE '[0-9]+/[0-9]+ items' | cut -d'/' -f2 | cut -d' ' -f1)

        completed_items=$((completed_items + completed))
        total_items=$((total_items + total))
      fi
    fi
  done < "$roadmap_file"

  if [ $sprint_count -eq 0 ]; then
    echo "0"
    return 1
  fi

  # Calculate average velocity
  local avg_velocity=$((completed_items / sprint_count))
  echo "$avg_velocity"
}
