#!/usr/bin/env bash

# Sprint Data Validation Script
# Ensures consistency across bugs.yaml, features.yaml, sprint documents, and ROADMAP.md

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

# Flags
VERBOSE=false
FIX=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose)
      VERBOSE=true
      shift
      ;;
    --fix)
      FIX=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--verbose] [--fix]"
      exit 1
      ;;
  esac
done

# Check for required tools
if ! command -v yq &> /dev/null; then
  echo -e "${RED}Error: yq not found. Install with: brew install yq${NC}"
  exit 1
fi

echo "Sprint Data Validation Report"
echo "============================="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check 1: Sprint Document ↔ YAML Consistency
check_sprint_yaml_consistency() {
  echo "Checking Sprint Document ↔ YAML Consistency..."

  local check_errors=0

  # Find all sprint documents
  for sprint_doc in docs/plans/sprints/SPRINT-*.md; do
    [ -e "$sprint_doc" ] || continue

    sprint_id=$(basename "$sprint_doc" | grep -oE 'SPRINT-[0-9]{3}')

    if [ "$VERBOSE" = true ]; then
      echo "  Validating $sprint_id..."
    fi

    # Extract work item IDs from sprint document
    work_items=$(grep -oE '(FEAT|BUG)-[0-9]{3}' "$sprint_doc" | sort -u)

    for item_id in $work_items; do
      item_type=${item_id%%-*}  # FEAT or BUG

      # Check if work item exists in appropriate YAML file
      if [ "$item_type" = "FEAT" ]; then
        yaml_file="features.yaml"
        if ! yq eval ".features[] | select(.id == \"$item_id\")" "$yaml_file" | grep -q "id:"; then
          echo -e "  ${RED}✗${NC} $item_id referenced in $sprint_id but not found in $yaml_file"
          ((check_errors++))
        fi
      elif [ "$item_type" = "BUG" ]; then
        yaml_file="bugs.yaml"
        if ! yq eval ".bugs[] | select(.id == \"$item_id\")" "$yaml_file" | grep -q "id:"; then
          echo -e "  ${RED}✗${NC} $item_id referenced in $sprint_id but not found in $yaml_file"
          ((check_errors++))
        fi
      fi
    done
  done

  # Check reverse: Items in YAML with sprint_id should be in sprint document
  if [ -f features.yaml ]; then
    while IFS= read -r feature_id; do
      feature_sprint=$(yq eval ".features[] | select(.id == \"$feature_id\") | .sprint_id" features.yaml)

      if [ -n "$feature_sprint" ] && [ "$feature_sprint" != "null" ]; then
        sprint_doc_pattern="docs/plans/sprints/${feature_sprint}-*.md"
        sprint_doc_found=$(ls $sprint_doc_pattern 2>/dev/null | head -1)

        if [ -z "$sprint_doc_found" ]; then
          echo -e "  ${RED}✗${NC} $feature_id has sprint_id=$feature_sprint but sprint document not found"
          ((check_errors++))
        elif ! grep -q "$feature_id" "$sprint_doc_found"; then
          echo -e "  ${RED}✗${NC} $feature_id has sprint_id=$feature_sprint but not listed in sprint document"
          ((check_errors++))
        fi
      fi
    done < <(yq eval '.features[].id' features.yaml)
  fi

  if [ -f bugs.yaml ]; then
    while IFS= read -r bug_id; do
      bug_sprint=$(yq eval ".bugs[] | select(.id == \"$bug_id\") | .sprint_id" bugs.yaml)

      if [ -n "$bug_sprint" ] && [ "$bug_sprint" != "null" ]; then
        sprint_doc_pattern="docs/plans/sprints/${bug_sprint}-*.md"
        sprint_doc_found=$(ls $sprint_doc_pattern 2>/dev/null | head -1)

        if [ -z "$sprint_doc_found" ]; then
          echo -e "  ${RED}✗${NC} $bug_id has sprint_id=$bug_sprint but sprint document not found"
          ((check_errors++))
        elif ! grep -q "$bug_id" "$sprint_doc_found"; then
          echo -e "  ${RED}✗${NC} $bug_id has sprint_id=$bug_sprint but not listed in sprint document"
          ((check_errors++))
        fi
      fi
    done < <(yq eval '.bugs[].id' bugs.yaml)
  fi

  if [ $check_errors -eq 0 ]; then
    echo -e "${GREEN}✅ Sprint Document Consistency${NC}"
    echo "   - All work items found in YAML files"
    echo "   - All sprint_id references valid"
  else
    echo -e "${RED}❌ Sprint Document Consistency ($check_errors errors)${NC}"
    ERRORS=$((ERRORS + check_errors))
  fi

  echo ""
}

# Check 2: ROADMAP.md ↔ Sprint Documents
check_roadmap_consistency() {
  echo "Checking ROADMAP.md ↔ Sprint Documents..."

  local check_errors=0
  local check_warnings=0

  if [ ! -f ROADMAP.md ]; then
    echo -e "  ${YELLOW}⚠${NC} ROADMAP.md not found (optional file)"
    ((check_warnings++))
    WARNINGS=$((WARNINGS + check_warnings))
    echo ""
    return
  fi

  # Extract sprint IDs from ROADMAP.md
  roadmap_sprints=$(grep -oE 'SPRINT-[0-9]{3}' ROADMAP.md | sort -u)

  for sprint_id in $roadmap_sprints; do
    # Check if sprint document exists
    sprint_doc_pattern="docs/plans/sprints/${sprint_id}-*.md"
    sprint_doc_found=$(ls $sprint_doc_pattern 2>/dev/null | head -1)

    if [ -z "$sprint_doc_found" ]; then
      echo -e "  ${RED}✗${NC} $sprint_id in ROADMAP.md but sprint document not found"
      ((check_errors++))
      continue
    fi

    # Check status consistency
    roadmap_status=$(grep "$sprint_id" ROADMAP.md | grep -oE '\(([a-z]+)\)' | tr -d '()' | head -1)
    doc_status=$(grep "^\*\*Status:\*\*" "$sprint_doc_found" | sed 's/\*\*Status:\*\* //')

    if [ -n "$roadmap_status" ] && [ -n "$doc_status" ] && [ "$roadmap_status" != "$doc_status" ]; then
      echo -e "  ${YELLOW}⚠${NC} $sprint_id status mismatch: ROADMAP=$roadmap_status, doc=$doc_status"
      ((check_warnings++))
    fi
  done

  if [ $check_errors -eq 0 ] && [ $check_warnings -eq 0 ]; then
    echo -e "${GREEN}✅ ROADMAP.md Consistency${NC}"
    echo "   - All sprints have corresponding documents"
    echo "   - Sprint statuses match"
  elif [ $check_errors -eq 0 ]; then
    echo -e "${YELLOW}⚠️  ROADMAP.md Consistency ($check_warnings warnings)${NC}"
    WARNINGS=$((WARNINGS + check_warnings))
  else
    echo -e "${RED}❌ ROADMAP.md Consistency ($check_errors errors, $check_warnings warnings)${NC}"
    ERRORS=$((ERRORS + check_errors))
    WARNINGS=$((WARNINGS + check_warnings))
  fi

  echo ""
}
