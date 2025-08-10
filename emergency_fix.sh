#!/bin/bash
# Emergency build fix script

set -e

echo "🔧 Emergency Build Fix for Nestory"
echo "===================================="

# Clean everything
echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*
rm -rf DerivedData
rm -rf .build
rm -rf Nestory.xcodeproj

# Generate fresh project
echo "📐 Generating fresh Xcode project..."
xcodegen generate

# Try to build
echo "🔨 Attempting build..."
xcodebuild \
    -scheme Nestory-Dev \
    -destination "platform=iOS Simulator,name=iPhone 15" \
    -configuration Debug \
    -skipPackagePluginValidation \
    -skipMacroValidation \
    clean build

echo "✅ Build completed!"
