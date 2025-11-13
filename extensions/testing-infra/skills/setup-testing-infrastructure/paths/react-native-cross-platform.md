# Path 2: React Native + Cross-Platform Testing Infrastructure Setup

This path sets up E2E testing infrastructure for React Native projects with both iOS and Android.

---

## Overview

Same structure as Path 1 (React Native + iOS), but with these additions:

### Additional Environment Detection

- Check for `android/` directory
- Check for Android SDK installation
- Check for Android emulators
- Identify existing Android build configuration (Gradle)

### Additional Questions

**Question 2 becomes:**
```
Question: "Which E2E framework should we use?"
Options:
  - "Maestro (both platforms)"
    Description: "Single framework for iOS and Android. Consistent tests across platforms. Easiest to maintain."

  - "Platform-specific (Detox for iOS, Espresso for Android)"
    Description: "Native frameworks for each platform. More control but separate test suites to maintain."

  - "Maestro + platform helpers"
    Description: "Maestro for main tests, platform-specific for edge cases. Balanced approach."
```

**Question 3 becomes:**
```
Question: "What testing targets do you need?"
Options:
  - "Simulators/Emulators only"
  - "Physical devices only"
  - "Both simulators and devices"
  - "iOS simulator + Android emulator (fastest)"
```

### Additional Implementation Steps

**After Step 1 (Install E2E Framework):**

Add Step 1b: Configure Android

```bash
# Install Android tools if needed
if [ -d "android/" ]; then
  cd android
  ./gradlew --version
  cd ..

  # Create Fastlane for Android (if using)
  cd android
  bundle init
  bundle add fastlane
  fastlane init
  cd ..
fi
```

**Step 3 expands to include Android Gradle configuration:**

Create `android/fastlane/Fastfile` or modify `android/app/build.gradle`:

```gradle
task testAll(dependsOn: ['test', 'testE2E']) {
    description 'Run all tests (unit + E2E)'
}

task testE2E {
    description 'Run Maestro E2E tests'
    doLast {
        exec {
            commandLine 'maestro', 'test', '../../.maestro/flows/features/'
        }
    }
}
```

**Additional Documentation:**

- IOS-SIMULATOR-TESTING-CHECKLIST.md
- ANDROID-EMULATOR-TESTING-CHECKLIST.md
- scripts/verify-ios-build.sh
- scripts/verify-android-build.sh

### Quality Gates for Both Platforms

**iOS:** Same as Path 1

**Android via Gradle:**

```gradle
task deployBeta {
    dependsOn 'testAll'  // Blocks if tests fail
    doLast {
        // Build and upload logic
    }
}
```

**Or Android via Fastlane:**

```ruby
lane :test do
  gradle(task: "test")  # Unit tests

  sh("xcrun simctl uninstall booted #{app_identifier}")  # iOS cleanup
  sh("adb uninstall #{app_identifier}")  # Android cleanup

  sh("cd ../.. && maestro test .maestro/flows/features/")  # E2E tests both platforms
end
```

### Final Summary

Show both platforms:

```
✅ Testing Infrastructure Setup Complete!

📦 What was set up:
- Maestro E2E testing (iOS + Android)
- Quality gates for both platforms
- Automatic app cleanup (iOS + Android)
- Sample E2E test (works on both)
- Documentation (6 files, 3,200 lines)

🚀 Quick Start:

iOS:
$ cd ios && fastlane test
$ cd ios && fastlane beta

Android:
$ cd android && ./gradlew testAll
$ cd android && ./gradlew deployBeta

Both:
$ npm test  # Unit tests
$ maestro test .maestro/flows/features/  # E2E both platforms
```

---

## Complete Implementation

Follow all steps from Path 1, then add Android-specific steps above. Verify both platforms independently and together.
