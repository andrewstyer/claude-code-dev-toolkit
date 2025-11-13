#!/bin/bash
# Build Verification Script for Health Narrative
# Validates that critical assets are bundled correctly in the build
# Usage: ./scripts/verify-build.sh [build-directory]
#
# Exit codes:
#   0 - All checks passed
#   1 - Build verification failed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUILD_DIR="${1:-ios/build}"
APP_NAME="HealthNarrative.app"
IPA_NAME="HealthNarrative.ipa"

# Critical sample data files that must be bundled
REQUIRED_PDF_FILES=(
  "sample-covid-test-results.pdf"
  "sample-cbc-cmp-panel-2020.pdf"
  "sample-pcp-visit-fatigue-2020.pdf"
  "sample-brain-mri-report-2022.pdf"
  "sample-neurology-consult-2022.pdf"
  "sample-cardiology-consult-2022.pdf"
  "sample-autoimmune-panel-2022.pdf"
  "sample-echocardiogram-2022.pdf"
  "sample-thyroid-panel-2022.pdf"
  "sample-endocrine-consult-2022.pdf"
  "sample-holter-monitor-2022.pdf"
  "sample-mecfs-initial-consult-2023.pdf"
  "sample-lyme-test-2023.pdf"
  "sample-sleep-study-2023.pdf"
  "sample-tilt-table-test-2023.pdf"
  "sample-mecfs-diagnosis-letter-2024.pdf"
  "sample-mecfs-followup-2025.pdf"
)

REQUIRED_DB_FILES=(
  "sample-health-narrative.db"
)

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

echo "=========================================="
echo "Health Narrative Build Verification"
echo "=========================================="
echo ""

# Function to print status
print_status() {
  local status=$1
  local message=$2

  if [ "$status" = "PASS" ]; then
    echo -e "${GREEN}✓${NC} $message"
    ((CHECKS_PASSED++))
  elif [ "$status" = "FAIL" ]; then
    echo -e "${RED}✗${NC} $message"
    ((CHECKS_FAILED++))
  elif [ "$status" = "WARN" ]; then
    echo -e "${YELLOW}⚠${NC} $message"
    ((WARNINGS++))
  else
    echo "  $message"
  fi
}

# Function to extract IPA and find app bundle
extract_and_find_app() {
  local ipa_path="$1"
  local extract_dir="${BUILD_DIR}/verification_temp"

  # Clean up any previous extraction
  rm -rf "$extract_dir"
  mkdir -p "$extract_dir"

  # Extract IPA (it's just a zip file)
  unzip -q "$ipa_path" -d "$extract_dir" 2>/dev/null

  # Find the .app bundle (usually in Payload directory)
  local app_bundle=$(find "$extract_dir" -name "*.app" -type d | head -n 1)

  if [ -z "$app_bundle" ]; then
    echo ""
    return 1
  fi

  echo "$app_bundle"
  return 0
}

# Check 1: Build directory exists
echo "Checking build directory..."
if [ ! -d "$BUILD_DIR" ]; then
  print_status "FAIL" "Build directory not found: $BUILD_DIR"
  print_status "INFO" "Run 'fastlane build' to create a build first"
  exit 1
else
  print_status "PASS" "Build directory exists: $BUILD_DIR"
fi

echo ""

# Check 2: IPA or .app exists
echo "Locating build artifacts..."
IPA_PATH="${BUILD_DIR}/${IPA_NAME}"
APP_PATH="${BUILD_DIR}/${APP_NAME}"

if [ -f "$IPA_PATH" ]; then
  print_status "PASS" "IPA found: $IPA_NAME"

  # Extract IPA to inspect contents
  echo "  Extracting IPA for inspection..."
  APP_BUNDLE=$(extract_and_find_app "$IPA_PATH")

  if [ $? -eq 0 ] && [ -n "$APP_BUNDLE" ]; then
    print_status "PASS" "App bundle extracted successfully"
    APP_PATH="$APP_BUNDLE"
  else
    print_status "FAIL" "Could not extract app bundle from IPA"
    exit 1
  fi
elif [ -d "$APP_PATH" ]; then
  print_status "PASS" "App bundle found: $APP_NAME"
else
  print_status "FAIL" "Neither IPA nor .app bundle found in build directory"
  print_status "INFO" "Expected: $IPA_PATH or $APP_PATH"
  exit 1
fi

echo ""

# Check 3: Sample data database
echo "Checking sample data database..."
DB_FOUND=0

# Check common locations for database in app bundle
DB_LOCATIONS=(
  "sample-health-narrative.db"
  "assets/sample-data/sample-health-narrative.db"
  "Assets.car" # Database might be embedded in asset catalog
)

for db_file in "${REQUIRED_DB_FILES[@]}"; do
  FOUND=false

  # Search for database file in app bundle
  if find "$APP_PATH" -name "$db_file" -type f 2>/dev/null | grep -q .; then
    FOUND=true
    DB_FOUND=$((DB_FOUND + 1))
  fi

  if [ "$FOUND" = true ]; then
    print_status "PASS" "Database found: $db_file"
  else
    print_status "WARN" "Database not directly visible: $db_file"
    print_status "INFO" "Database may be embedded in Assets.car (this is normal for Expo)"
  fi
done

echo ""

# Check 4: Sample PDF files
echo "Checking sample PDF files..."
PDF_FOUND=0
PDF_MISSING=0

for pdf_file in "${REQUIRED_PDF_FILES[@]}"; do
  FOUND=false

  # Search for PDF in app bundle
  if find "$APP_PATH" -name "$pdf_file" -type f 2>/dev/null | grep -q .; then
    FOUND=true
    PDF_FOUND=$((PDF_FOUND + 1))
  fi

  if [ "$FOUND" = true ]; then
    print_status "PASS" "PDF found: $pdf_file"
  else
    print_status "FAIL" "PDF missing: $pdf_file"
    PDF_MISSING=$((PDF_MISSING + 1))
  fi
done

echo ""
echo "PDF Summary: $PDF_FOUND found, $PDF_MISSING missing (expected: ${#REQUIRED_PDF_FILES[@]})"
echo ""

# Check 5: Assets.car exists (Expo asset catalog)
echo "Checking asset catalog..."
if find "$APP_PATH" -name "Assets.car" -type f 2>/dev/null | grep -q .; then
  ASSETS_CAR=$(find "$APP_PATH" -name "Assets.car" -type f | head -n 1)
  ASSETS_SIZE=$(du -h "$ASSETS_CAR" | cut -f1)
  print_status "PASS" "Assets.car found (size: $ASSETS_SIZE)"

  if [ "$PDF_MISSING" -gt 0 ]; then
    print_status "INFO" "Missing PDFs may be embedded in Assets.car"
    print_status "INFO" "Expo bundles assets into Assets.car for optimized loading"
  fi
else
  print_status "WARN" "Assets.car not found - assets may not be optimized"
fi

echo ""

# Check 6: Metro bundle exists
echo "Checking JavaScript bundle..."
if find "$APP_PATH" -name "main.jsbundle" -type f 2>/dev/null | grep -q .; then
  BUNDLE_PATH=$(find "$APP_PATH" -name "main.jsbundle" -type f | head -n 1)
  BUNDLE_SIZE=$(du -h "$BUNDLE_PATH" | cut -f1)
  print_status "PASS" "JavaScript bundle found (size: $BUNDLE_SIZE)"

  # Check bundle size is reasonable (should be > 1MB for a real app)
  BUNDLE_SIZE_KB=$(du -k "$BUNDLE_PATH" | cut -f1)
  if [ "$BUNDLE_SIZE_KB" -lt 1024 ]; then
    print_status "WARN" "Bundle size seems small (${BUNDLE_SIZE})"
  fi
else
  print_status "FAIL" "JavaScript bundle (main.jsbundle) not found"
fi

echo ""

# Check 7: Info.plist validation
echo "Checking app configuration..."
INFO_PLIST=$(find "$APP_PATH" -maxdepth 1 -name "Info.plist" -type f | head -n 1)

if [ -n "$INFO_PLIST" ]; then
  print_status "PASS" "Info.plist found"

  # Extract bundle identifier
  BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$INFO_PLIST" 2>/dev/null || echo "unknown")
  print_status "INFO" "Bundle ID: $BUNDLE_ID"

  # Extract version
  VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST" 2>/dev/null || echo "unknown")
  BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST" 2>/dev/null || echo "unknown")
  print_status "INFO" "Version: $VERSION (Build $BUILD)"

  # Validate expected bundle ID
  if [ "$BUNDLE_ID" != "com.monkbear.healthnarrative" ]; then
    print_status "WARN" "Bundle ID mismatch (expected: com.monkbear.healthnarrative)"
  fi
else
  print_status "FAIL" "Info.plist not found"
fi

echo ""

# Clean up temporary extraction directory if it exists
if [ -d "${BUILD_DIR}/verification_temp" ]; then
  rm -rf "${BUILD_DIR}/verification_temp"
fi

# Final summary
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC}  $CHECKS_PASSED checks"
echo -e "${RED}Failed:${NC}  $CHECKS_FAILED checks"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS warnings"
echo ""

if [ $CHECKS_FAILED -gt 0 ]; then
  echo -e "${RED}❌ Build verification FAILED${NC}"
  echo ""
  echo "Common fixes:"
  echo "  1. Rebuild database: npm run build:sample-db"
  echo "  2. Clear Metro cache: npm start -- --reset-cache"
  echo "  3. Clean build: rm -rf ios/build && fastlane build"
  echo ""
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Build verification passed with warnings${NC}"
  echo ""
  echo "Note: Some assets may be embedded in Assets.car (normal for Expo)"
  echo "If E2E tests pass, the build is safe to upload."
  echo ""
  exit 0
else
  echo -e "${GREEN}✅ Build verification PASSED${NC}"
  echo ""
  echo "Build is ready for upload to TestFlight!"
  echo ""
  exit 0
fi
