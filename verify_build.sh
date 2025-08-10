#!/bin/bash
# Build verification script

set -e

cd /Users/griffin/Projects/Nestory

echo "🔨 Building Nestory with concurrency fix..."
echo "=========================================="

# Clean first
echo "🧹 Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*

# Generate project if needed
if [ ! -d "Nestory.xcodeproj" ]; then
    echo "📐 Generating Xcode project..."
    xcodegen generate
fi

# Build with explicit settings
echo "🏗️ Building for iPhone 15..."
xcodebuild \
    -scheme Nestory-Dev \
    -destination "platform=iOS Simulator,name=iPhone 15" \
    -configuration Debug \
    -quiet \
    clean build | xcpretty

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo "==================="
    echo ""
    echo "The app is now ready to run!"
    echo ""
    echo "To run in Xcode:"
    echo "  1. Open: open Nestory.xcodeproj"
    echo "  2. Select iPhone 15 simulator"
    echo "  3. Press Cmd+R"
    echo ""
    echo "Or run directly:"
    echo "  xcodebuild -scheme Nestory-Dev -destination 'platform=iOS Simulator,name=iPhone 15' run"
else
    echo ""
    echo "❌ Build failed. See errors above."
fi
