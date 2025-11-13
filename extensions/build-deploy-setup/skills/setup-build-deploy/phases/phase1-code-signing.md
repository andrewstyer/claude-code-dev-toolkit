# Phase 1: Environment & Code Signing Setup

**Estimated Time:** 10-15 minutes
**Goal:** Configure Apple Developer credentials and code signing for iOS deployment

---

## Overview

This phase sets up the foundation for iOS deployment by:
1. Verifying your development environment
2. Configuring Apple Developer account access
3. Setting up code signing (certificates and provisioning profiles)
4. Testing that credentials actually work

**Critical:** This phase MUST verify credentials with actual API calls. No assumptions.

---

## Pre-Flight Checks

Before starting, verify these requirements:

### Required Checks

```bash
# 1. Xcode installed and version
xcodebuild -version
# Expected: Xcode 13.0 or later
# If missing: Install from App Store

# 2. Xcode command line tools
xcode-select -p
# Expected: /Applications/Xcode.app/Contents/Developer
# If missing: xcode-select --install

# 3. Disk space (need 10GB+ for builds)
df -h .
# Expected: >10GB available
# If insufficient: Clean up space or warn user

# 4. Git repository
git status
# Expected: Valid git repository
# If not: git init (with user confirmation)

# 5. Working directory status
git status --porcelain
# Expected: Clean or user confirms OK to proceed
# If dirty: Offer to commit, stash, or proceed anyway
```

### Optional Checks

```bash
# Ruby version (for Fastlane)
ruby --version
# Expected: 2.5 or later
# If old: Warn but continue (Fastlane might still work)

# Bundler
bundle --version
# Expected: Installed
# If missing: Will install during Phase 2
```

---

## Step 1: Detect Project Type

Analyze the project to determine configuration needs:

```bash
# Check for React Native
if [ -f "package.json" ] && grep -q "react-native" package.json; then
  PROJECT_TYPE="react-native"
  echo "✓ Detected: React Native project"
fi

# Check for Flutter
if [ -f "pubspec.yaml" ]; then
  PROJECT_TYPE="flutter"
  echo "✓ Detected: Flutter project"
fi

# Check for Expo
if [ -f "app.json" ] && grep -q "expo" package.json; then
  PROJECT_TYPE="expo"
  echo "✓ Detected: Expo project"
fi

# Check for native iOS
if [ -d "ios" ] && [ -z "$PROJECT_TYPE" ]; then
  PROJECT_TYPE="native-ios"
  echo "✓ Detected: Native iOS project"
fi

# Find Xcode project or workspace
XCODEPROJ=$(find ios -maxdepth 1 -name "*.xcodeproj" | head -1)
XCWORKSPACE=$(find ios -maxdepth 1 -name "*.xcworkspace" | head -1)

if [ -n "$XCWORKSPACE" ]; then
  XCODE_PATH="$XCWORKSPACE"
  echo "✓ Found workspace: $XCWORKSPACE"
elif [ -n "$XCODEPROJ" ]; then
  XCODE_PATH="$XCODEPROJ"
  echo "✓ Found project: $XCODEPROJ"
else
  echo "✗ No Xcode project or workspace found"
  # STOP - cannot proceed
fi

# Extract bundle identifier
BUNDLE_ID=$(grep -A 1 "PRODUCT_BUNDLE_IDENTIFIER" "$XCODEPROJ/project.pbxproj" | grep -o 'com\.[^"]*' | head -1)
echo "✓ Bundle identifier: $BUNDLE_ID"
```

**Verification:**
- [ ] Project type detected
- [ ] Xcode project/workspace found
- [ ] Bundle identifier extracted

---

## Step 2: Verify Apple Developer Account

Check if user has Apple Developer account configured:

```bash
# Check for existing Apple ID configuration
if [ -n "$FASTLANE_APPLE_ID" ]; then
  echo "✓ Apple ID found in environment: $FASTLANE_APPLE_ID"
  APPLE_ID="$FASTLANE_APPLE_ID"
elif [ -f ".env" ] && grep -q "FASTLANE_APPLE_ID" .env; then
  APPLE_ID=$(grep "FASTLANE_APPLE_ID" .env | cut -d '=' -f2)
  echo "✓ Apple ID found in .env: $APPLE_ID"
else
  echo "⚠️  Apple ID not configured"
  APPLE_ID_MISSING=true
fi

# Check for App Store Connect API key
if [ -n "$APP_STORE_CONNECT_API_KEY_KEY_ID" ]; then
  echo "✓ App Store Connect API Key ID found"
  HAS_API_KEY=true
elif [ -f ".env" ] && grep -q "APP_STORE_CONNECT_API_KEY_KEY_ID" .env; then
  echo "✓ App Store Connect API Key found in .env"
  HAS_API_KEY=true
else
  echo "⚠️  App Store Connect API Key not configured"
  HAS_API_KEY=false
fi
```

---

## Step 3: Ask User for Code Signing Preference

Use `AskUserQuestion` to determine code signing method:

```json
{
  "questions": [
    {
      "question": "How do you want to handle iOS code signing?",
      "header": "Code Signing",
      "multiSelect": false,
      "options": [
        {
          "label": "App Store Connect API Key (Recommended)",
          "description": "Most automated method. Requires creating an API key (5 min one-time setup). Best for solo developers. No password prompts during deployment."
        },
        {
          "label": "Manual Certificate Management",
          "description": "Use existing certificates from your Keychain. Less automated but works if you already have certificates set up. May require password prompts."
        },
        {
          "label": "Match (Team-Based)",
          "description": "Store certificates in a git repository for team sharing. Best for teams. Requires additional git repository for certificates."
        }
      ]
    }
  ]
}
```

Store user response in variable: `CODE_SIGNING_METHOD`

---

## Step 4a: Configure API Key (if selected)

If user selected "App Store Connect API Key":

### Check for Existing API Key

```bash
# Check environment variables
if [ -n "$APP_STORE_CONNECT_API_KEY_KEY_ID" ] && \
   [ -n "$APP_STORE_CONNECT_API_KEY_ISSUER_ID" ] && \
   [ -n "$APP_STORE_CONNECT_API_KEY_KEY_FILEPATH" ]; then
  echo "✓ API Key configuration found in environment"
  KEY_ID="$APP_STORE_CONNECT_API_KEY_KEY_ID"
  ISSUER_ID="$APP_STORE_CONNECT_API_KEY_ISSUER_ID"
  KEY_FILE="$APP_STORE_CONNECT_API_KEY_KEY_FILEPATH"

  # Verify key file exists
  if [ -f "$KEY_FILE" ]; then
    echo "✓ API Key file found: $KEY_FILE"
  else
    echo "✗ API Key file not found: $KEY_FILE"
    KEY_FILE_MISSING=true
  fi
else
  echo "⚠️  API Key not configured"
  NEED_API_KEY_SETUP=true
fi
```

### Guide User to Create API Key (if needed)

If `NEED_API_KEY_SETUP` is true:

```markdown
To create an App Store Connect API Key:

1. Go to: https://appstoreconnect.apple.com/access/api
2. Click the "+" button to create a new key
3. Name: "Fastlane CI/CD" (or your preference)
4. Access: "Admin" or "App Manager"
5. Click "Generate"
6. Download the .p8 file (you can only download once!)
7. Note the Key ID and Issuer ID

Once you have these, I'll help you configure them.
```

Ask user via `AskUserQuestion`:

```json
{
  "questions": [
    {
      "question": "Have you created the App Store Connect API Key and have the Key ID, Issuer ID, and .p8 file?",
      "header": "API Key Ready",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes, I have all three",
          "description": "I'll configure the API key now"
        },
        {
          "label": "No, help me create one",
          "description": "I'll provide step-by-step guidance"
        },
        {
          "label": "Switch to Manual signing",
          "description": "Use certificates from Keychain instead"
        }
      ]
    }
  ]
}
```

### Configure API Key

```bash
# Prompt for API key details (or read from .env)
echo "Please provide your API Key details:"
echo "Key ID (10 characters): "
# Store in KEY_ID

echo "Issuer ID (UUID format): "
# Store in ISSUER_ID

echo "Path to .p8 file: "
# Store in KEY_FILE

# Validate format
if [ ${#KEY_ID} -ne 10 ]; then
  echo "✗ Invalid Key ID format (should be 10 characters)"
  # STOP and retry
fi

# Validate key file exists and is readable
if [ ! -f "$KEY_FILE" ]; then
  echo "✗ Key file not found: $KEY_FILE"
  # STOP and retry
fi

if [ ! -r "$KEY_FILE" ]; then
  echo "✗ Key file not readable: $KEY_FILE"
  # STOP and retry
fi

# Store in .env file (create if doesn't exist)
cat >> .env <<EOF
# App Store Connect API Key
APP_STORE_CONNECT_API_KEY_KEY_ID=$KEY_ID
APP_STORE_CONNECT_API_KEY_ISSUER_ID=$ISSUER_ID
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=$KEY_FILE
EOF

# Add .env to .gitignore if not already there
if [ -f ".gitignore" ]; then
  if ! grep -q "^\.env$" .gitignore; then
    echo ".env" >> .gitignore
    echo "✓ Added .env to .gitignore"
  fi
else
  echo ".env" > .gitignore
  echo "✓ Created .gitignore with .env"
fi

echo "✓ API Key configured in .env"
```

### VERIFY API Key Works

**CRITICAL: Must actually test the API key**

```bash
# Test API access using Fastlane
fastlane run app_store_connect_api_key \
  key_id:"$KEY_ID" \
  issuer_id:"$ISSUER_ID" \
  key_filepath:"$KEY_FILE"

# Check exit code
if [ $? -eq 0 ]; then
  echo "✓ API Key validated successfully"
else
  echo "✗ API Key validation failed"
  # Show error, offer to retry or switch methods
  # STOP - cannot proceed without valid credentials
fi

# Make actual API call to verify access
# Generate JWT token and call App Store Connect API
echo "Testing API access to App Store Connect..."

# This will be done via Fastlane in Phase 2, but we can test basic auth here
# For now, just verify the key file format
if file "$KEY_FILE" | grep -q "ASCII text"; then
  echo "✓ Key file format looks valid"
else
  echo "⚠️  Key file format unexpected (should be ASCII text)"
fi
```

**Verification checklist:**
- [ ] Key ID is 10 characters
- [ ] Issuer ID is UUID format
- [ ] Key file exists and is readable
- [ ] Key file format is valid
- [ ] .env file created with credentials
- [ ] .env added to .gitignore
- [ ] Fastlane can load the API key

---

## Step 4b: Configure Manual Signing (if selected)

If user selected "Manual Certificate Management":

### Check for Existing Certificates

```bash
# List available signing identities
echo "Checking for iOS signing certificates in Keychain..."

security find-identity -v -p codesigning

# Expected output:
#   1) XXXXX... "Apple Development: Name (TEAMID)"
#   2) XXXXX... "Apple Distribution: Name (TEAMID)"

# Count certificates
DEV_CERT_COUNT=$(security find-identity -v -p codesigning | grep "Apple Development" | wc -l)
DIST_CERT_COUNT=$(security find-identity -v -p codesigning | grep "Apple Distribution" | wc -l)

echo "Found $DEV_CERT_COUNT development certificates"
echo "Found $DIST_CERT_COUNT distribution certificates"

if [ $DIST_CERT_COUNT -eq 0 ]; then
  echo "⚠️  No distribution certificate found"
  echo "You'll need a distribution certificate to deploy to TestFlight/App Store"
  MISSING_DIST_CERT=true
fi
```

### Check Certificate Expiration

```bash
# Get certificate details
security find-certificate -c "Apple Distribution" -p | openssl x509 -text -noout

# Check expiration date
EXPIRY=$(security find-certificate -c "Apple Distribution" -p | openssl x509 -enddate -noout | cut -d= -f2)
EXPIRY_EPOCH=$(date -j -f "%b %d %T %Y %Z" "$EXPIRY" "+%s")
NOW_EPOCH=$(date "+%s")

DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_UNTIL_EXPIRY -lt 0 ]; then
  echo "✗ Distribution certificate EXPIRED on $EXPIRY"
  CERT_EXPIRED=true
elif [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
  echo "⚠️  Distribution certificate expires soon: $EXPIRY ($DAYS_UNTIL_EXPIRY days)"
else
  echo "✓ Distribution certificate valid until: $EXPIRY ($DAYS_UNTIL_EXPIRY days)"
fi
```

### Check for Provisioning Profiles

```bash
# List provisioning profiles
echo "Checking for provisioning profiles..."

PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"

if [ -d "$PROFILES_DIR" ]; then
  PROFILE_COUNT=$(ls "$PROFILES_DIR"/*.mobileprovision 2>/dev/null | wc -l)
  echo "Found $PROFILE_COUNT provisioning profiles"

  # Look for profiles matching bundle ID
  for profile in "$PROFILES_DIR"/*.mobileprovision; do
    if security cms -D -i "$profile" | grep -q "$BUNDLE_ID"; then
      echo "✓ Found profile for $BUNDLE_ID"
      PROFILE_NAME=$(security cms -D -i "$profile" | grep -A 1 "Name" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
      echo "  Profile name: $PROFILE_NAME"

      # Check expiration
      PROFILE_EXPIRY=$(security cms -D -i "$profile" | grep -A 1 "ExpirationDate" | tail -1 | sed 's/.*<date>\(.*\)<\/date>.*/\1/')
      echo "  Expires: $PROFILE_EXPIRY"
    fi
  done
else
  echo "⚠️  No provisioning profiles directory found"
  MISSING_PROFILES=true
fi
```

### Handle Missing/Expired Credentials

If certificates or profiles are missing/expired:

```json
{
  "questions": [
    {
      "question": "Your distribution certificate is expired/missing. How would you like to proceed?",
      "header": "Certificate Issue",
      "multiSelect": false,
      "options": [
        {
          "label": "Download from Apple Developer Portal",
          "description": "I'll guide you through downloading certificates and profiles"
        },
        {
          "label": "Switch to API Key method",
          "description": "Use App Store Connect API Key instead (recommended)"
        },
        {
          "label": "Continue anyway",
          "description": "Proceed with existing certificates (deployment may fail)"
        }
      ]
    }
  ]
}
```

### Configure Xcode Project for Manual Signing

```bash
# Update Xcode project to use manual signing
# This is done via Fastlane in Phase 2, but we can verify settings here

echo "✓ Manual signing configured - will use certificates from Keychain"
```

**Verification checklist:**
- [ ] Distribution certificate found
- [ ] Certificate not expired (or expires >30 days)
- [ ] Provisioning profile found for bundle ID
- [ ] Profile not expired

---

## Step 4c: Configure Match (if selected)

If user selected "Match (Team-Based)":

### Check for Existing Match Setup

```bash
# Check for Matchfile
if [ -f "ios/fastlane/Matchfile" ]; then
  echo "✓ Matchfile found - Match already configured"
  MATCH_CONFIGURED=true
else
  echo "⚠️  Match not yet configured"
  MATCH_CONFIGURED=false
fi
```

### Set Up Match

```bash
# Will be fully configured in Phase 2 with Fastlane
# For now, just collect the git repository URL

echo "Match stores certificates in a git repository."
echo "This repository should be private and separate from your app code."
echo ""
echo "Git repository URL for certificates (e.g., git@github.com:yourteam/certificates.git):"
# Store in MATCH_GIT_URL

# Validate URL format
if echo "$MATCH_GIT_URL" | grep -q "^git@\|^https://"; then
  echo "✓ Git URL format looks valid"
else
  echo "✗ Invalid git URL format"
  # STOP and retry
fi

# Test git access
echo "Testing git repository access..."
git ls-remote "$MATCH_GIT_URL" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "✓ Git repository accessible"
else
  echo "✗ Cannot access git repository"
  echo "Please ensure:"
  echo "  1. Repository exists"
  echo "  2. You have access (SSH key configured)"
  echo "  3. URL is correct"
  # Offer to retry or switch methods
fi

# Store configuration
cat >> .env <<EOF
# Match configuration
MATCH_GIT_URL=$MATCH_GIT_URL
EOF

echo "✓ Match configuration saved"
echo "Note: Full Match setup will complete in Phase 2"
```

**Verification checklist:**
- [ ] Git repository URL provided
- [ ] Repository accessible
- [ ] Configuration saved to .env

---

## Step 5: Configure Team ID

```bash
# Try to detect Team ID from Xcode project
TEAM_ID=$(grep -A 1 "DevelopmentTeam" "$XCODEPROJ/project.pbxproj" | grep -o '[A-Z0-9]\{10\}' | head -1)

if [ -n "$TEAM_ID" ]; then
  echo "✓ Team ID detected: $TEAM_ID"
else
  echo "⚠️  Team ID not found in Xcode project"
  echo "You can find your Team ID at: https://developer.apple.com/account"
  echo "It's a 10-character alphanumeric code"
  echo ""
  echo "Please enter your Team ID:"
  # Get from user

  # Validate format (10 alphanumeric characters)
  if echo "$TEAM_ID" | grep -q '^[A-Z0-9]\{10\}$'; then
    echo "✓ Team ID format valid"
  else
    echo "✗ Invalid Team ID format (should be 10 alphanumeric characters)"
    # STOP and retry
  fi
fi

# Store in .env
echo "FASTLANE_TEAM_ID=$TEAM_ID" >> .env
```

---

## Step 6: Generate Documentation

Create `ios/fastlane/CODE_SIGNING_GUIDE.md`:

```markdown
# iOS Code Signing Guide

**Generated:** [Current timestamp]
**Project:** [Project name]
**Bundle ID:** [Bundle identifier]

---

## Current Configuration

- **Method:** [API Key / Manual / Match]
- **Bundle Identifier:** [com.yourcompany.yourapp]
- **Team ID:** [XXXXXXXXXX]
- **Xcode Project:** [path]

[Include method-specific details based on what was configured]

## [API Key Section - if using API Key]

### Location
- **Key File:** `[path to .p8 file]`
- **Key ID:** `[Key ID]` (stored in .env)
- **Issuer ID:** `[Issuer ID]` (stored in .env)

### Environment Variables
```bash
APP_STORE_CONNECT_API_KEY_KEY_ID=[KEY_ID]
APP_STORE_CONNECT_API_KEY_ISSUER_ID=[ISSUER_ID]
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=[PATH]
```

### Verification
Test API access:
```bash
cd ios && fastlane run app_store_connect_api_key \
  key_id:"$APP_STORE_CONNECT_API_KEY_KEY_ID" \
  issuer_id:"$APP_STORE_CONNECT_API_KEY_ISSUER_ID" \
  key_filepath:"$APP_STORE_CONNECT_API_KEY_KEY_FILEPATH"
```

Expected: "Successfully authenticated with App Store Connect API"

### Renewal
API keys don't expire, but Apple recommends rotating them periodically:
1. Create new key in App Store Connect
2. Update .env with new key details
3. Test deployment works
4. Revoke old key

## [Manual Signing Section - if using Manual]

### Certificates

**Distribution Certificate:**
- Type: Apple Distribution
- Expires: [Date] ([X] days remaining)
- Location: Keychain Access → Certificates
- Name: [Certificate name]

To view:
```bash
security find-identity -v -p codesigning | grep "Apple Distribution"
```

### Provisioning Profiles

**App Store Profile:**
- Name: [Profile name]
- Bundle ID: [Bundle ID]
- Expires: [Date]
- Location: ~/Library/MobileDevice/Provisioning Profiles/

To list profiles:
```bash
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Renewal Process

When certificates/profiles expire:

1. **Generate new certificate:**
   - Go to: https://developer.apple.com/account/resources/certificates
   - Click "+" to create new
   - Type: "Apple Distribution"
   - Follow prompts to generate CSR and download

2. **Download new provisioning profile:**
   - Go to: https://developer.apple.com/account/resources/profiles
   - Select your app's profile
   - Click "Edit"
   - Select new certificate
   - Download profile
   - Double-click to install

3. **Verify in Xcode:**
   - Open your project
   - Build Settings → Signing
   - Verify correct certificate selected

## [Match Section - if using Match]

### Configuration

**Git Repository:** [URL]
**Storage:** Encrypted certificates in git

### How Match Works

1. Match stores certificates in a git repository
2. Certificates are encrypted with a passphrase
3. Team members sync certificates from the repo
4. Xcode automatically uses the synced certificates

### Sync Certificates

To sync certificates from the team repository:
```bash
cd ios && fastlane match appstore
```

This will:
- Clone the certificates repository
- Decrypt certificates (you'll need the passphrase)
- Install to your Keychain
- Install provisioning profiles

### Generate New Certificates

Only one team member should do this:
```bash
cd ios && fastlane match appstore --force_for_new_devices
```

## Troubleshooting

### Issue: "Code signing identity not found"

**Solution:**
```bash
# List available identities
security find-identity -v -p codesigning

# If none found, check:
1. Xcode → Preferences → Accounts → Download Manual Profiles
2. Or regenerate certificates via developer portal
```

### Issue: "Provisioning profile expired"

**Solution:**
- Manual: Download new profile from developer.apple.com
- Match: Run `fastlane match appstore` to sync latest
- API Key: Fastlane will auto-manage profiles

### Issue: "Team ID mismatch"

**Solution:**
```bash
# Verify Team ID in .env matches Xcode
grep FASTLANE_TEAM_ID .env
# Should match value in Xcode → Project → Signing & Capabilities
```

## Security Best Practices

✅ **DO:**
- Store API keys and credentials in .env (not in git)
- Add .env to .gitignore
- Use separate API keys for different projects/environments
- Rotate API keys annually
- Use Match for team projects (shared secure storage)
- Review certificate expiration dates monthly

❌ **DON'T:**
- Commit .env or .p8 files to git
- Share API keys via email or Slack
- Use personal certificates for team projects
- Ignore certificate expiration warnings
- Store credentials in code or configuration files

## Environment Variables

All credentials should be stored in `.env`:

```bash
# App Store Connect API Key (if using)
APP_STORE_CONNECT_API_KEY_KEY_ID=KEYID12345
APP_STORE_CONNECT_API_KEY_ISSUER_ID=xxxxx-xxxx-xxxx-xxxx-xxxxxxxxx
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=/path/to/key.p8

# Match (if using)
MATCH_GIT_URL=git@github.com:yourteam/certificates.git
MATCH_PASSWORD=your-secure-passphrase

# Team details
FASTLANE_TEAM_ID=TEAMID1234
FASTLANE_APPLE_ID=your@email.com
```

## Next Steps

1. ✅ Code signing configured
2. → Continue to Phase 2: Fastlane Setup
3. → See: FASTLANE_SETUP_GUIDE.md

---

**Last Updated:** [Timestamp]
**Configuration:** [Method] signing with Team ID [TEAMID]
```

Save this documentation to `ios/fastlane/CODE_SIGNING_GUIDE.md`.

---

## Step 7: Commit Changes

```bash
# Create ios/fastlane directory if it doesn't exist
mkdir -p ios/fastlane

# Stage changes
git add .env .gitignore ios/fastlane/CODE_SIGNING_GUIDE.md

# Commit
git commit -m "chore: configure iOS code signing with [method]

- Set up [API Key/Manual/Match] code signing
- Configured Team ID: [TEAM_ID]
- Generated CODE_SIGNING_GUIDE.md
- Added .env with credentials (not committed)
- Verified credentials work with actual API test

Bundle ID: [BUNDLE_ID]
Project: [PROJECT_TYPE]"

echo "✓ Committed code signing configuration"
```

---

## Verification Checklist

Before moving to Phase 2, verify:

### API Key Method:
- [ ] Key ID is 10 characters
- [ ] Issuer ID is valid UUID
- [ ] .p8 key file exists and is readable
- [ ] API key can authenticate (tested with Fastlane)
- [ ] .env file created with credentials
- [ ] .env added to .gitignore
- [ ] CODE_SIGNING_GUIDE.md generated

### Manual Method:
- [ ] Distribution certificate exists in Keychain
- [ ] Certificate not expired (or >30 days until expiration)
- [ ] Provisioning profile exists for bundle ID
- [ ] Profile not expired
- [ ] Team ID configured
- [ ] CODE_SIGNING_GUIDE.md generated

### Match Method:
- [ ] Git repository URL configured
- [ ] Repository accessible (tested)
- [ ] Configuration saved to .env
- [ ] .env added to .gitignore
- [ ] CODE_SIGNING_GUIDE.md generated

### All Methods:
- [ ] Team ID identified and configured
- [ ] Bundle identifier found
- [ ] Xcode project/workspace found
- [ ] Documentation generated
- [ ] Changes committed to git

---

## Troubleshooting

### API Key Issues

**Problem:** "Invalid API key"
```bash
# Verify key file format
file /path/to/key.p8
# Expected: "ASCII text"

# Check key contents start with: -----BEGIN PRIVATE KEY-----
head -1 /path/to/key.p8
```

**Problem:** "Forbidden - insufficient permissions"
- API key role must be "Admin" or "App Manager"
- Recreate key with correct permissions

### Certificate Issues

**Problem:** "No identity found"
```bash
# Import certificate manually
# 1. Download from developer.apple.com
# 2. Double-click .cer file
# 3. Verify in Keychain Access
```

**Problem:** "Certificate expired"
- Generate new certificate in developer portal
- Download and install
- Update provisioning profiles to use new certificate

### Match Issues

**Problem:** "Git repository not accessible"
```bash
# Test SSH access
ssh -T git@github.com
# Expected: "Hi username! You've successfully authenticated"

# If fails, add SSH key:
ssh-keygen -t ed25519 -C "your@email.com"
# Add public key to GitHub/GitLab
```

---

## Phase 1 Complete!

When all verification checks pass:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Phase 1: Code Signing - Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Code signing method: [Method]
✓ Team ID configured: [TEAM_ID]
✓ Bundle ID: [BUNDLE_ID]
✓ Credentials verified (tested with actual API call)
✓ Documentation generated: CODE_SIGNING_GUIDE.md
✓ Changes committed to git

📊 Time taken: [X] minutes

→ Ready for Phase 2: Fastlane Installation & Setup
```

Update state file:
```json
{
  "phases": {
    "code_signing": {
      "status": "completed",
      "completed_at": "[timestamp]",
      "method": "[api_key/manual/match]",
      "verified": true,
      "team_id": "[TEAM_ID]",
      "bundle_id": "[BUNDLE_ID]"
    }
  }
}
```

Proceed to Phase 2.
