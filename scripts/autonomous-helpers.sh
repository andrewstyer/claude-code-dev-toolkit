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
