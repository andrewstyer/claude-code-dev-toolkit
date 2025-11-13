# Path 3: Native Mobile Testing Infrastructure Setup

This path sets up E2E testing infrastructure for native iOS (Swift) or Android (Kotlin) projects.

---

## Phase 1: Environment Detection

### For iOS Projects

Look for:
- `.xcodeproj` or `.xcworkspace` file
- Swift source files in project
- Existing XCTest targets
- Existing Fastlane setup

### For Android Projects

Look for:
- `build.gradle` with Android plugin
- Kotlin/Java source files
- Existing Espresso/Instrumentation tests
- Existing Gradle test tasks

### Show Summary

```
🔍 Current setup detected:
- Platform: iOS (Swift) / Android (Kotlin)
- Unit tests: XCTest / JUnit found
- E2E tests: [Present/Not found]
- Build automation: [Fastlane/Gradle configured]
```

---

## Phase 2: Minimal Questions

### Question 1: Platform

```
Question: "Which platform are you targeting?"
Options:
  - "iOS only"
  - "Android only"
  - "Both platforms (separate codebases)"
```

### Question 2: E2E Framework

**For iOS:**
```
Options:
  - "XCUITest (native)"
    Description: "Apple's native UI testing framework. Best integration with Xcode. Fast execution."

  - "Maestro"
    Description: "Cross-platform option. Easier test writing. No app rebuild needed."
```

**For Android:**
```
Options:
  - "Espresso (native)"
    Description: "Google's native testing framework. Best integration with Android Studio. Fast and reliable."

  - "Maestro"
    Description: "Cross-platform option. Easier test writing. Works well with Kotlin."
```

### Question 3: Quality Gates

Same as Path 1

### Question 4: Sample Test

Same as Path 1

---

## Phase 3: Implementation

### For iOS with XCUITest

**Step 1: Create UI Test Target**

```bash
# If no UI test target exists
# Guide user to create in Xcode:
# File -> New -> Target -> iOS UI Testing Bundle
```

**Step 2: Configure Fastlane**

```ruby
lane :test do
  # Unit tests
  run_tests(
    workspace: "YourApp.xcworkspace",
    scheme: "YourApp",
    devices: ["iPhone 16 Pro"]
  )

  # UI tests
  run_tests(
    workspace: "YourApp.xcworkspace",
    scheme: "YourApp",
    devices: ["iPhone 16 Pro"],
    only_testing: ["YourAppUITests"]
  )
end
```

**Step 3: Sample UI Test**

```swift
import XCTest

class AppLaunchTests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["HomeScreen"].exists)
    }
}
```

### For iOS with Maestro

Same as Path 1 (React Native + iOS)

### For Android with Espresso

**Step 1: Add Espresso Dependencies**

```gradle
dependencies {
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
    androidTestImplementation 'androidx.test:runner:1.5.2'
    androidTestImplementation 'androidx.test:rules:1.5.0'
}
```

**Step 2: Configure Gradle**

```gradle
task testAll {
    dependsOn 'test'  // Unit tests
    dependsOn 'connectedAndroidTest'  // UI tests
}

task deployBeta {
    dependsOn 'testAll'  // Quality gate
    doLast {
        // Deploy logic
    }
}
```

**Step 3: Sample Espresso Test**

```kotlin
@RunWith(AndroidJUnit4::class)
class AppLaunchTest {
    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun appLaunches() {
        onView(withId(R.id.main_content)).check(matches(isDisplayed()))
    }
}
```

### For Android with Maestro

Same as Path 2 (React Native + Cross-Platform) Android setup

---

## Phase 4: Verification

### For iOS

```bash
# Run tests via Fastlane
cd ios && fastlane test

# Or via xcodebuild
xcodebuild test \
  -workspace YourApp.xcworkspace \
  -scheme YourApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### For Android

```bash
# Run tests via Gradle
./gradlew testAll

# Or individual
./gradlew test  # Unit tests
./gradlew connectedAndroidTest  # UI tests
```

---

## Phase 5: Documentation

Generate platform-specific documentation:

**For iOS:**
- TESTING-WORKFLOW.md (Fastlane + XCTest/Maestro)
- SIMULATOR-TESTING-CHECKLIST.md
- PHYSICAL-DEVICE-TESTING.md (provisioning, etc.)
- scripts/verify-build.sh

**For Android:**
- TESTING-WORKFLOW.md (Gradle + Espresso/Maestro)
- EMULATOR-TESTING-CHECKLIST.md
- PHYSICAL-DEVICE-TESTING.md (ADB, device setup)
- scripts/verify-build.sh

---

## Summary

```
✅ Testing Infrastructure Setup Complete!

📦 What was set up:
- XCUITest/Espresso E2E testing
- Quality gates in Fastlane/Gradle
- Sample UI test
- Platform-specific documentation

🚀 Quick Start:

iOS:
$ cd ios && fastlane test

Android:
$ ./gradlew testAll
```
