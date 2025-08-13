# Nestory Screenshot Automation Guide

## 📸 Overview

This document describes the automated screenshot generation system for the Nestory iOS app using Fastlane Snapshot. The system captures 20+ screenshots across all major app screens for iPhone 16 Pro Max.

## 🚀 Quick Start

### Generate Screenshots
```bash
# Recommended: Use the convenience script
./Scripts/run_fastlane_screenshots.sh

# Alternative: Direct fastlane command
fastlane screenshots
```

### View Results
- HTML Report opens automatically after generation
- Screenshots saved to: `fastlane/screenshots/`
- Archived copies in: `fastlane/screenshots_archive/`

## 📋 Prerequisites

### Required Tools
- Xcode 16.4+
- Fastlane (`gem install fastlane` or `brew install fastlane`)
- iPhone 16 Pro Max Simulator
- macOS 14.0+

### Setup Verification
```bash
# Check fastlane installation
fastlane --version

# Verify simulator availability
xcrun simctl list devices | grep "iPhone 16 Pro Max"
```

## 🏗 Project Structure

```
Nestory/
├── fastlane/
│   ├── Fastfile                # Fastlane configuration
│   ├── Snapfile                # Snapshot settings
│   └── screenshots/            # Generated screenshots (gitignored)
├── NestoryUITests/
│   ├── NestorySnapshotTests.swift    # Main test file
│   ├── SnapshotHelper.swift          # Fastlane helper
│   ├── Extensions/
│   │   └── XCUIElement+Helpers.swift # UI test helpers
│   └── Helpers/
│       └── NavigationHelpers.swift   # Navigation utilities
└── Scripts/
    └── run_fastlane_screenshots.sh   # Automation script
```

## 📱 Screenshot Coverage

### Current Screenshots (24 total)

1. **Inventory Views**
   - `01_Inventory_Empty` - Empty state
   - `01_Inventory_List` - Populated list
   - `02_Inventory_Scrolled` - Scrolled view

2. **Add Item Flow**
   - `03_AddItem_Empty` - Blank form
   - `04_AddItem_Filled` - Completed form
   - `05_AddItem_Saved` - After saving

3. **Item Details**
   - `06_ItemDetail_Top` - Upper section
   - `07_ItemDetail_Bottom` - Lower section
   - `08_ItemDetail_Edit` - Edit mode

4. **Search**
   - `09_Search_Empty` - Initial state
   - `10_Search_Results` - With results

5. **Categories**
   - `11_Categories_List` - Category list
   - `12_Category_Items` - Items in category
   - `13_Category_Add` - Add category

6. **Analytics**
   - `14_Analytics_Dashboard` - Main dashboard
   - `15_Analytics_Charts` - Chart views

7. **Settings**
   - `16_Settings_Main` - Main settings
   - `17_Settings_Appearance` - Theme options
   - `18_Settings_DarkMode` - Dark theme
   - `19_Settings_More` - Additional settings
   - `20_Settings_About` - About screen

8. **Special Features**
   - `21_Photo_Options` - Photo selection
   - `22_Barcode_Scanner` - Scanner view
   - `23_Export_Options` - Export settings
   - `24_Insurance_Report` - Insurance features

## 🔧 Configuration

### Snapfile Settings
```ruby
devices(["iPhone 16 Pro Max"])
languages(["en-US"])
output_directory "./fastlane/screenshots"
clear_previous_screenshots true
override_status_bar true
```

### Status Bar Overrides
- Time: 9:41
- Battery: 100% (Charged)
- WiFi: Full bars
- Cellular: Full bars

## 🎯 Adding New Screenshots

### 1. Add Test Function
Add a new capture function in `NestorySnapshotTests.swift`:

```swift
func captureNewFeatureScreenshots() {
    XCTContext.runActivity(named: "Capture New Feature") { _ in
        // Navigate to feature
        NavigationHelpers.navigateToTab(named: "TabName")
        
        // Wait for loading
        NavigationHelpers.waitForLoadingToComplete()
        
        // Take screenshot
        snapshot("25_NewFeature_Main")
        
        // Interact and capture more states
        // ...
    }
}
```

### 2. Call from Main Test
Add to `testGenerateAllScreenshots()`:

```swift
func testGenerateAllScreenshots() throws {
    // Existing captures...
    
    // Add your new capture
    captureNewFeatureScreenshots()
}
```

### 3. Naming Convention
- Format: `XX_Feature_State`
- Examples:
  - `25_Profile_View`
  - `26_Backup_Progress`
  - `27_Receipt_Scan`

## 🐛 Troubleshooting

### Common Issues

#### "Scheme not found"
```bash
# Regenerate Xcode project
xcodegen
# Open Xcode and ensure scheme exists
open Nestory.xcodeproj
```

#### "Simulator not available"
```bash
# Download simulator
xcodebuild -downloadPlatform iOS
# Reset simulators
fastlane snapshot reset_simulators
```

#### "Test failures"
```bash
# Run tests directly in Xcode first
xcodebuild test \
  -project Nestory.xcodeproj \
  -scheme Nestory \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max"
```

#### "Screenshots not appearing"
- Check console output for errors
- Verify `snapshot()` calls are reached
- Ensure SnapshotHelper is properly integrated
- Check file permissions in output directory

### Clean Slate
```bash
# Full reset
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*
rm -rf fastlane/screenshots/*
fastlane snapshot reset_simulators
```

## 📊 CI/CD Integration

### GitHub Actions Example
```yaml
- name: Generate Screenshots
  run: |
    bundle install
    bundle exec fastlane screenshots
  
- name: Upload Screenshots
  uses: actions/upload-artifact@v2
  with:
    name: screenshots
    path: fastlane/screenshots/
```

### Jenkins Pipeline
```groovy
stage('Screenshots') {
    steps {
        sh 'fastlane screenshots'
        archiveArtifacts 'fastlane/screenshots/**/*.png'
    }
}
```

## 🎨 Best Practices

### UI Test Writing
1. **Use Accessibility Identifiers** - More reliable than text
2. **Add Waits** - Not just `sleep()`, use `waitForExistence()`
3. **Handle Optional Elements** - Use `tapIfExists()`
4. **Clean State** - Each test should be independent
5. **Descriptive Names** - Clear screenshot naming

### Performance Tips
- Run on fastest Mac available
- Close other apps
- Use wired internet connection
- Disable Spotlight indexing during runs
- Consider parallel execution for multiple devices

### Maintenance
- Review screenshots after UI changes
- Update tests when adding features
- Archive important screenshot sets
- Document significant UI changes

## 📝 Screenshot Usage

### App Store Submission
1. Select best screenshots from each category
2. Edit if needed (add device frames, text)
3. Upload via App Store Connect
4. Ensure all required sizes are covered

### Documentation
- Include in README.md
- Add to user guides
- Use in release notes
- Share with stakeholders

### Testing
- Visual regression testing
- UI review process
- Accessibility verification
- Localization checking

## 🔄 Continuous Improvement

### Metrics to Track
- Generation time
- Success rate
- Screenshot count
- File sizes

### Future Enhancements
- [ ] Add iPad support
- [ ] Multiple language support
- [ ] Dark mode variants
- [ ] Landscape orientations
- [ ] Video recordings
- [ ] Automated upload to cloud

## 📚 Resources

- [Fastlane Snapshot Documentation](https://docs.fastlane.tools/actions/snapshot/)
- [XCUITest Documentation](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [App Store Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)

## 🤝 Contributing

When adding new features:
1. Add corresponding screenshot captures
2. Update this documentation
3. Test on clean simulator
4. Verify HTML report generates correctly

---

*Last Updated: December 2024*
*Fastlane Version: 2.217.0+*
*Xcode Version: 16.4+*