#!/bin/bash
# Quick build and run script
cd "$(dirname "$0")"

echo "🚀 Nestory Quick Build & Run"
echo "=============================="

# Generate project
echo "📐 Generating Xcode project..."
xcodegen generate || { echo "❌ Failed to generate project"; exit 1; }

# Build
echo "🔨 Building app..."
xcodebuild \
    -scheme Nestory-Dev \
    -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
    -configuration Debug \
    clean build || { echo "❌ Build failed"; exit 1; }

echo "✅ Build successful!"
echo ""
echo "📱 To run the app:"
echo "   1. Open Xcode: open Nestory.xcodeproj"
echo "   2. Select iPhone 16 Pro Max simulator"
echo "   3. Press Cmd+R to run"
echo ""
echo "Or use: make run"
