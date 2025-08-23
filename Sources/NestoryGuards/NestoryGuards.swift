// iOS Build System Redirect Helper
// This library exists only to provide helpful guidance when someone runs 'swift build'

import Foundation

#warning("""

🚫 ================================================================ 🚫
   WARNING: 'swift build' is NOT for iOS app development!
🚫 ================================================================ 🚫

📱 For Nestory iOS app, use these commands instead:

🏗️  DEVELOPMENT BUILD:
   make build              # Quick development build
   make run                # Build and run in iPhone 16 Pro Max simulator

🔧 PROJECT MAINTENANCE:
   xcodegen generate       # Regenerate Xcode project
   make clean              # Clean build artifacts
   make doctor             # Verify project setup

🧪 TESTING & VERIFICATION:
   make test               # Run all tests
   make check              # Run architecture compliance checks
   make lint               # Run SwiftLint

📱 MANUAL XCODE BUILD:
   xcodebuild -project Nestory.xcodeproj -scheme Nestory-Dev build

ℹ️  Note: 'swift build' only compiles this tiny architectural guards
   library and ignores the 900+ file iOS app.

🎯 Quick Start:
   make run   # ← Use this to build and run the app!

================================================================

""")

public struct NestoryBuildHelper {
    // Empty struct to satisfy Swift Package Manager requirements
}
