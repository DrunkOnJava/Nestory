# iOS Simulator Automation for Nestory

This directory contains comprehensive automation tools for navigating through the Nestory app and capturing screenshots for documentation purposes.

## 🛠️ Available Tools

### 1. AppleScript Automation (`ios-simulator-automation.applescript`)
**Best for**: Reliable UI element interaction using macOS accessibility APIs

```bash
# Run in Script Editor or from command line
osascript ios-simulator-automation.applescript
```

**Features**:
- Native macOS integration
- Reliable button/element detection
- Automatic tab navigation
- Error handling and recovery
- Comprehensive screenshot capture

### 2. Shell Script Navigator (`simulator-navigator.sh`)
**Best for**: Command-line automation with coordinate-based controls

```bash
# Make executable
chmod +x simulator-navigator.sh

# Full app navigation
./simulator-navigator.sh navigate

# Interactive mode
./simulator-navigator.sh interactive

# Single screenshot  
./simulator-navigator.sh screenshot home-view
```

**Features**:
- Coordinate-based touch simulation
- Swipe gesture support
- Interactive command mode
- Tab navigation shortcuts
- Comprehensive logging

### 3. Advanced Swift UI Testing (`ui-automation-advanced.swift`)
**Best for**: XCTest-based automation with accessibility support

```bash
# Run directly
swift ui-automation-advanced.swift

# Or compile and run
swiftc ui-automation-advanced.swift -o ui-automation
./ui-automation
```

**Features**:
- XCTest framework integration
- Accessibility element detection
- Performance measurements
- Wait conditions and timeouts
- Element verification

### 4. Python Controller (`ios_simulator_controller.py`)
**Best for**: Advanced scripting with JSON APIs and system integration

```bash
# Make executable
chmod +x ios_simulator_controller.py

# Full navigation
python3 ios_simulator_controller.py navigate

# Interactive mode
python3 ios_simulator_controller.py interactive

# App information
python3 ios_simulator_controller.py info
```

**Features**:
- JSON API integration with simctl
- Advanced gesture simulation
- App state monitoring
- Comprehensive logging
- Device management

## 🎯 Quick Start

### 1. Automated Screenshot Collection
```bash
# Option A: Shell script (coordinate-based)
./simulator-navigator.sh navigate

# Option B: Python script (API-based)  
python3 ios_simulator_controller.py navigate

# Option C: AppleScript (UI-based)
osascript ios-simulator-automation.applescript
```

### 2. Interactive Testing
```bash
# Start interactive mode
./simulator-navigator.sh interactive

# Available commands:
simulator> screenshot main-view
simulator> touch 215 300
simulator> tab settings
simulator> exit
```

### 3. Single Operations
```bash
# Take one screenshot
./simulator-navigator.sh screenshot current-state

# Launch app only
./simulator-navigator.sh launch

# Check status
./simulator-navigator.sh status
```

## 📱 Coordinate Reference (iPhone 16 Pro Max)

### Screen Dimensions
- **Width**: 430 points
- **Height**: 932 points

### Common UI Elements
```bash
# Tab Bar (bottom)
Inventory Tab:  (86, 878)
Search Tab:     (215, 878) 
Analytics Tab:  (344, 878)
Settings Tab:   (473, 878)

# Navigation
Back Button:    (50, 100)
Add Button:     (380, 100)
Search Field:   (215, 150)

# Content Area
Item Row:       (215, 300)  # First item
Center Screen:  (215, 466)  # Middle of screen
```

### Gesture Examples
```bash
# Scroll down
simulator> swipe 215 400 215 200

# Scroll up  
simulator> swipe 215 200 215 400

# Navigate tabs
simulator> touch 344 878  # Analytics tab
```

## 🔧 Configuration

### Device Settings
- **Device ID**: `0CFB3C64-CDE6-4F18-894D-F99C0D7D9A23` (iPhone 16 Pro Max iOS 18.6)
- **Bundle ID**: `com.drunkonjava.nestory.dev`
- **Screenshot Dir**: `/Users/griffin/Projects/Nestory/Screenshots/`

### Timing Settings
- **Action Delay**: 2 seconds between operations
- **App Launch Wait**: 3 seconds  
- **Animation Wait**: 1 second
- **Touch Response**: 0.5 seconds

### Customization
Edit the configuration section in each script:
```bash
# simulator-navigator.sh
DEVICE_ID="your-device-id"
BUNDLE_ID="your-bundle-id" 
SCREENSHOT_DIR="your-screenshot-path"
```

## 🎬 Automation Workflows

### Complete App Documentation
1. **Launch app** → Screenshot main view
2. **Navigate inventory** → Capture item list, detail view, add item
3. **Test search** → Capture search field, results, filters  
4. **Review analytics** → Capture charts, scroll views
5. **Explore settings** → Capture preferences, export options

### Debug Workflows
1. **Reproduce issue** → Navigate to problematic view
2. **Capture state** → Screenshot before/after actions
3. **Test variations** → Try different input sequences
4. **Document results** → Automated screenshot collection

### Performance Testing
1. **Launch timing** → Measure cold start performance
2. **Navigation speed** → Time between view transitions
3. **Animation smoothness** → Capture frame rates
4. **Memory usage** → Monitor during automation

## 🛡️ Best Practices

### 1. Reliable Automation
- **Always check simulator status** before operations
- **Use appropriate delays** for animation completion
- **Handle errors gracefully** with fallback strategies
- **Verify element existence** before interaction

### 2. Screenshot Organization
- **Use descriptive names** with timestamps
- **Organize by feature area** (inventory, settings, etc.)
- **Include state information** in filenames
- **Maintain version history** for comparisons

### 3. Coordinate Accuracy
- **Test coordinates** on your specific device/simulator
- **Account for simulator chrome** (30px x-offset, 100px y-offset)
- **Use relative positioning** where possible
- **Validate touch targets** with visual feedback

### 4. Error Handling
- **Log all operations** with timestamps
- **Capture failure screenshots** for debugging
- **Implement retry logic** for flaky operations
- **Provide clear error messages** with context

## 🚀 Advanced Usage

### Custom Gestures
```bash
# Complex swipe patterns
./simulator-navigator.sh interactive
simulator> swipe 100 300 330 300    # Horizontal swipe
simulator> swipe 215 200 215 500    # Long vertical swipe
simulator> touch 215 300             # Precise tap
```

### Batch Operations
```bash
# Multiple screenshots with delays
./simulator-navigator.sh screenshot view-1
sleep 5
./simulator-navigator.sh screenshot view-2
sleep 5
./simulator-navigator.sh screenshot view-3
```

### Integration with CI/CD
```bash
# In build script
./Scripts/automation/simulator-navigator.sh navigate
if [ $? -eq 0 ]; then
    echo "✅ UI automation successful"
else
    echo "❌ UI automation failed"
    exit 1
fi
```

## 🐛 Troubleshooting

### Common Issues

1. **"Device not found"**
   - Check device ID with `xcrun simctl list devices`
   - Ensure iOS 18.6 simulator is installed

2. **"App failed to launch"**  
   - Verify bundle ID: `xcrun simctl listapps booted`
   - Check app is installed: `xcrun simctl install <device> <app.app>`

3. **"Touch not working"**
   - Verify simulator window is active
   - Check coordinate calculations
   - Ensure simulator chrome offsets are correct

4. **"Screenshots not saving"**
   - Check directory permissions
   - Ensure path exists: `mkdir -p /path/to/screenshots`
   - Verify disk space availability

### Debug Mode
```bash
# Enable debug logging
export DEBUG=1
./simulator-navigator.sh navigate

# Verbose simctl output
xcrun simctl --verbose io booted screenshot test.png
```

## 📚 Resources

- [Apple simctl Documentation](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device)
- [XCTest UI Testing](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/)
- [iOS Simulator Release Notes](https://developer.apple.com/documentation/xcode-release-notes/)

---

**Note**: All automation tools are designed for the Nestory personal inventory app. Coordinates and element references are specific to iPhone 16 Pro Max running iOS 18.6.