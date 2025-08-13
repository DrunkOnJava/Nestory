# Hot Reloading with InjectionNext - Operational Guide

## 🚀 Quick Start (Daily Use)

1. **Open Xcode** with the Nestory project
2. **Build and Run** (⌘+R) targeting iPhone 16 Plus simulator
3. **InjectionNext connects automatically** - Look for:
   ```
   🔥 InjectionNext: iPhoneSimulator connection to app established
   🔥 Watching directory: /Users/griffin/Projects/Nestory
   💉 [HotReload] InjectionNext package integrated
   ```
4. **Edit any Swift file** in Xcode
5. **Save** (⌘+S) to trigger hot reload
6. **Watch changes appear instantly** in the simulator!

## ✅ Setup Verification Checklist

### Project Configuration (project.yml)
```yaml
packages:
  Inject:
    url: https://github.com/krzysztofzablocki/Inject
    from: 1.5.2
  InjectionNext:
    url: https://github.com/johnno1962/InjectionNext
    from: 1.0.0

targets:
  Nestory:
    settings:
      configs:
        Debug:
          EMIT_FRONTEND_COMMAND_LINES: YES
    dependencies:
      - package: Inject
      - package: InjectionNext
    environmentVariables:
      INJECTION_DIRECTORIES: /Users/griffin/Projects/Nestory
```

### Swift Version
```bash
# Verify Swift 6 is active (NOT 5.9!)
swift --version
# Should show: Apple Swift version 6.1.2 or later

# If it shows 5.9, check ~/.zshrc for:
# export TOOLCHAINS=swift-5.9-RELEASE  ← COMMENT THIS OUT!
```

### Required Files

1. **App-Main/HotReloadBootstrap.swift** - Handles injection setup
2. **App-Main/NestoryApp.swift** - Contains `HotReloadBootstrap.setup()`
3. **View files** - Must import Inject and use `@ObserveInjection`

## 🛠 Implementation Pattern

### For SwiftUI Views
```swift
import SwiftUI
import Inject  // Required for hot reload

struct MyView: View {
    #if DEBUG
    @ObserveInjection var inject  // Triggers view refresh
    #endif
    
    var body: some View {
        Text("Your content here")
            #if DEBUG
            .enableInjection()  // Enables hot reload for this view
            #endif
    }
}
```

### For Tab-Based Apps (ContentView.swift)
```swift
#if DEBUG
@ObserveInjection var inject
@State private var injectionTrigger = UUID()
#endif

var body: some View {
    TabView(selection: $selectedTab) {
        // Your tabs here
    }
    #if DEBUG
    .enableInjection()
    .onReceive(NotificationCenter.default.publisher(
        for: Notification.Name("INJECTION_BUNDLE_NOTIFICATION")
    )) { _ in
        injectionTrigger = UUID()  // Force TabView refresh
    }
    .id(injectionTrigger)  // Critical for tab refresh!
    #endif
}
```

## ⚠️ Known Issues & Solutions

### Issue: "Have you viewed it in Xcode?"
**Solution:** 
- Open the file in Xcode editor first
- Make sure `EMIT_FRONTEND_COMMAND_LINES: YES` is set
- Rebuild if necessary

### Issue: App crashes during navigation + hot reload
**Cause:** SwiftUI navigation structure corruption
**Solution:** 
- Stay on the same screen when hot reloading that screen
- Restart app for navigation structure changes
- Safe: Text, colors, padding, modifiers
- Unsafe: Navigation changes, view hierarchy changes

### Issue: CloudKit crashes in Settings tab
**Solution:** Already fixed - CloudKit disabled in DEBUG builds
```swift
#if !DEBUG
CloudBackupSettingsView()
#else
Section("iCloud Backup") {
    Text("iCloud backup is disabled in Debug builds")
        .foregroundColor(.secondary)
}
#endif
```

### Issue: Changes not appearing
**Check:**
1. Is InjectionNext connected? (check console)
2. Did you save the file? (⌘+S)
3. Is the file in the watched directory?
4. Try adding a space and saving again

## 🔧 Troubleshooting Commands

```bash
# Check Swift version
swift --version

# Verify no Swift 5.9 override
echo $TOOLCHAINS  # Should be empty

# Check project dependencies
xcodebuild -list

# Clean and rebuild if needed
rm -rf .build DerivedData
xcodebuild -scheme Nestory-Dev -destination "platform=iOS Simulator,name=iPhone 16 Plus" build

# Monitor InjectionNext logs
tail -f ~/Library/Logs/InjectionNext/*.log
```

## 📋 What Works with Hot Reload

### ✅ Safe to Hot Reload
- Text content changes
- Colors, fonts, sizes
- Padding, spacing, margins
- Adding/removing modifiers
- Changing computed properties
- Minor logic changes in views
- @State variable changes

### ⚠️ Requires Rebuild
- Navigation structure changes
- Adding/removing NavigationStack
- Major view hierarchy changes
- SwiftData model changes
- New dependencies
- Build settings changes

## 🎯 Best Practices

1. **Keep InjectionNext Running** - It starts automatically with the app
2. **One Change at a Time** - Easier to identify issues
3. **Save Frequently** - ⌘+S triggers reload
4. **Watch Console** - Shows injection success/failure
5. **Stay on Screen** - Don't navigate while hot reloading that screen
6. **Use #if DEBUG** - Keep injection code out of production

## 🔄 Recovery Procedures

### If Hot Reload Stops Working:
1. **Check connection** in console for 🔥 messages
2. **Restart the app** (not just rebuild)
3. **Clean build folder** (Shift+⌘+K)
4. **Verify Swift 6** with `swift --version`
5. **Check INJECTION_DIRECTORIES** environment variable

### If App Crashes:
1. **Stop the app** in Xcode
2. **Check crash log** for navigation issues
3. **Rebuild and run** fresh
4. **Avoid the action** that caused the crash

## 📝 Daily Workflow

### Morning Setup
1. Open Xcode
2. Select iPhone 16 Plus simulator
3. Build and Run (⌘+R)
4. Verify InjectionNext connected in console
5. Start developing with instant feedback!

### During Development
- Edit → Save (⌘+S) → See changes
- Stay on the screen you're editing
- Rebuild only for structural changes
- Use console for debugging injection

### End of Day
- Commit working code frequently
- Document any hot reload issues
- Keep hot reload code in #if DEBUG blocks

## 🚨 Emergency Fixes

### Swift Reverts to 5.9
```bash
# Fix immediately:
unset TOOLCHAINS
sed -i '' 's/export TOOLCHAINS=swift-5.9-RELEASE/# export TOOLCHAINS=swift-5.9-RELEASE/' ~/.zshrc
source ~/.zshrc
```

### Build Errors After Changes
```bash
# Reset to last known good state:
git stash
git checkout main
git pull
xcodebuild -scheme Nestory-Dev -destination "platform=iOS Simulator,name=iPhone 16 Plus" build
```

### Complete Reset
```bash
# Nuclear option - full reset:
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build
git clean -fdx
xcodegen
open Nestory.xcodeproj
# Then rebuild
```

## 📚 Resources

- [InjectionNext GitHub](https://github.com/johnno1962/InjectionNext)
- [Inject Package](https://github.com/krzysztofzablocki/Inject)
- [SwiftUI Hot Reload Guide](https://www.hackingwithswift.com/articles/255/hot-reloading-in-swiftui)

## 🎉 Success Indicators

You know it's working when:
- 🔥 messages appear in console
- 💉 "Code injected successfully!" appears
- Changes appear instantly without rebuild
- No more waiting for builds!
- Development speed increases 10x!

---

*Last Updated: August 2025*
*Swift 6 Compatible | InjectionNext 1.0.0+ | Xcode 16.4+*