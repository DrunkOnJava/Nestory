# 🔥 Hot Reload Setup for Nestory

## ✅ What's Already Configured

Great news! Hot reload is now fully configured and working in this project. Here's what we've set up:

### Packages Installed
- **InjectionNext** - The hot reload engine (Swift Package)
- **Inject** - SwiftUI refresh support (Swift Package by Krzysztof Zabłocki)

### Build Settings Configured
- ✅ `-Xlinker -interposable` linker flags (enables function interposing)
- ✅ `EMIT_FRONTEND_COMMAND_LINES: YES` (required for Xcode 16.3+)
- ✅ `INJECTION_DIRECTORIES` environment variable pointing to project root
- ✅ Swift 6 with minimal concurrency checking for Debug builds

### Code Integration
- ✅ `@ObserveInjection` property wrapper in views
- ✅ `.enableInjection()` modifier on views
- ✅ Injection trigger for forcing SwiftUI refresh
- ✅ HotReloadBootstrap for logging injection events

---

## 🚀 Quick Start (Daily Use)

Since everything is already configured, here's all you need to do:

### 1. Launch InjectionNext
```bash
open /Applications/InjectionNext.app
```
Look for the icon in your menu bar (should be blue 🔵)

### 2. Launch Xcode FROM InjectionNext
- Click the InjectionNext menu bar icon
- Select **"Launch Xcode"**
- The icon turns purple 🟣 (means Xcode is supervised)

### 3. Open Project and Run
- Open `Nestory.xcodeproj` in the launched Xcode
- Build and run (⌘+R) on iPhone 16 Plus simulator
- When app connects, icon turns orange 🟠

### 4. Make Changes
- **Open the file you want to edit in Xcode's editor** (CRITICAL!)
- Make your changes (in Xcode or from command line)
- Save the file (⌘+S)
- Watch the magic happen! ✨

---

## 🎯 The Secret Sauce (What Actually Made It Work)

### 1. **InjectionNext Instead of InjectionIII**
We use the newer InjectionNext which is much simpler - no manual bundle loading, just a Swift Package.

### 2. **Critical Build Settings for Xcode 16.3+**
```yaml
# In project.yml
configs:
  Debug:
    EMIT_FRONTEND_COMMAND_LINES: YES  # THIS IS CRITICAL!
    OTHER_LDFLAGS: -Xlinker -interposable
```

### 3. **Environment Variable for Directory Watching**
```yaml
# In project.yml schemes section
environmentVariables:
  INJECTION_DIRECTORIES: /Users/griffin/Projects/Nestory
```

### 4. **SwiftUI Refresh Trigger**
The Inject package's `@ObserveInjection` wasn't enough. We added an explicit trigger:

```swift
struct InventoryListView: View {
    #if DEBUG
    @ObserveInjection var inject
    @State private var injectionTrigger = UUID()  // Force refresh
    #endif
    
    var body: some View {
        NavigationStack {
            // ... your view content ...
        }
        #if DEBUG
        .enableInjection()
        .onReceive(NotificationCenter.default.publisher(for: 
            Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))) { _ in
            injectionTrigger = UUID()  // Force new ID
        }
        .id(injectionTrigger)  // Rebuild view when ID changes
        #endif
    }
}
```

### 5. **File Must Be Open in Xcode**
InjectionNext needs to see the file in Xcode's editor to track compilation commands.

---

## 🛠️ Setup Script (If Starting Fresh)

We have a setup script that handles everything:
```bash
./tools/dev/injection_next_setup.sh
```

---

## 📝 Adding Hot Reload to New Views

For any new SwiftUI view you create:

```swift
import SwiftUI
#if DEBUG
import Inject
#endif

struct MyNewView: View {
    #if DEBUG
    @ObserveInjection var inject
    @State private var injectionTrigger = UUID()
    #endif
    
    var body: some View {
        Text("Hello")
        #if DEBUG
        .enableInjection()
        .onReceive(NotificationCenter.default.publisher(for: 
            Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))) { _ in
            injectionTrigger = UUID()
        }
        .id(injectionTrigger)
        #endif
    }
}
```

---

## 🔍 Troubleshooting

### Icon Colors Mean:
- 🔵 Blue = InjectionNext running
- 🟣 Purple = Xcode launched from app
- 🟠 Orange = App connected (ready for hot reload!)
- 🟢 Green = Recompiling (brief flash during injection)
- 🟡 Yellow = Compile error

### If Hot Reload Stops Working:

1. **Check the console for errors**
   - "Have you viewed it in Xcode?" → Open file in Xcode editor
   - "Injection failed. Was your app connected?" → Restart app
   - "Could not locate command" → Need to rebuild once

2. **Check InjectionNext is watching correct directory**
   ```
   🔥 Watching directory: /Users/griffin/Projects/Nestory
   ```
   If not, restart from step 1

3. **Make sure file is open in Xcode**
   - Click on the file in Xcode's navigator
   - File must be visible in the editor

4. **If all else fails:**
   - Stop app (⌘+.)
   - Clean build folder (⇧⌘+K)
   - Rebuild and run (⌘+R)

---

## ⚡ What You Can Change with Hot Reload

### ✅ CAN Change:
- Function bodies (implementation)
- String literals
- Numeric values
- Colors, spacing, padding
- View modifiers
- Logic inside functions
- SwiftUI view content

### ❌ CANNOT Change:
- Function signatures
- Property types
- Add/remove properties with storage
- Add/remove methods in non-final classes
- Struct/class definitions
- Import statements

---

## 🎉 Success Indicators

You know it's working when:
1. Console shows: `🔥 Recompiling: /path/to/file.swift`
2. Console shows: `💉 [HotReload] Code injected successfully!`
3. UI updates instantly without rebuild
4. InjectionNext icon briefly flashes green

---

## 💡 Pro Tips

1. **Keep files open** - Open all files you're actively working on in Xcode tabs
2. **Watch the console** - It tells you exactly what's happening
3. **Save frequently** - Every save triggers injection
4. **Command line edits work!** - Edit from terminal, VS Code, or any editor - just save and Xcode detects it
5. **Works with Claude!** - I can make changes and you'll see them instantly

---

## 🚨 Remember the Golden Rules

1. **ALWAYS launch Xcode from InjectionNext menu** (not directly)
2. **File MUST be open in Xcode editor**
3. **Save triggers injection** (⌘+S)
4. **Orange icon = Ready for hot reload**

---

## 📦 Dependencies (Already in project.yml)

```yaml
packages:
  Inject:
    url: https://github.com/krzysztofzablocki/Inject
    from: 1.5.2
  InjectionNext:
    url: https://github.com/johnno1962/InjectionNext
    from: 1.0.0
```

---

## 🎯 The Magic Moment

When you change:
```swift
.navigationTitle("Old Title")
```

To:
```swift
.navigationTitle("New Title")
```

And hit ⌘+S... and it just updates instantly... that's when you know you've saved hours of development time! 🚀

---

*Last tested and working: August 12, 2025 with Xcode 16.4, InjectionNext 1.0.0, Swift 6*