// swift-tools-version: 6.0

// 🚫 ================================================================ 🚫
//    ERROR: 'swift build' is NOT for iOS app development!
// 🚫 ================================================================ 🚫
//
// 📱 For Nestory iOS app, use these commands instead:
//
// 🏗️  DEVELOPMENT BUILD:
//    make build              # Quick development build
//    make run                # Build and run in iPhone 16 Pro Max simulator
//
// 🔧 PROJECT MAINTENANCE:
//    xcodegen generate       # Regenerate Xcode project
//    make clean              # Clean build artifacts
//    make doctor             # Verify project setup
//
// 🧪 TESTING & VERIFICATION:
//    make test               # Run all tests
//    make check              # Run architecture compliance checks
//    make lint               # Run SwiftLint
//
// 📱 MANUAL XCODE BUILD:
//    xcodebuild -project Nestory.xcodeproj -scheme Nestory-Dev build
//
// ℹ️  Note: This Package.swift intentionally causes 'swift build' to fail
//    because it's wrong for iOS development.
//
// 🎯 Quick Start:
//    make run   # ← Use this to build and run the app!
//
// ================================================================

import PackageDescription

#error("""

🚫 STOP! 'swift build' is NOT for iOS app development! 🚫

Use these proper commands instead:
  make run    # Build and run the iOS app
  make build  # Build the iOS app only
  make check  # Full verification (build + test + lint)

This Package.swift intentionally fails to prevent confusion.
The real iOS app build system is Xcode + project.yml.

Quick start: make run

""")

// This Package.swift intentionally causes compilation failure
// to prevent developers from accidentally using 'swift build'
let package = Package(
    name: "iOS_BUILD_PREVENTION_ERROR",
    platforms: [.iOS(.v17)],
    products: [],
    dependencies: [],
    targets: []
)
