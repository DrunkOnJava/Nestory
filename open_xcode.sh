#!/bin/bash
# Minimal working app setup

cd /Users/griffin/Projects/Nestory

echo "🏗️ Setting up minimal working app..."

# Clean
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*
rm -rf Nestory.xcodeproj

# Generate
xcodegen generate

# Open in Xcode
open Nestory.xcodeproj

echo "✅ Project opened in Xcode"
echo ""
echo "📱 To run the app:"
echo "   1. Select 'Nestory-Dev' scheme (top left)"
echo "   2. Select 'iPhone 15' simulator"
echo "   3. Press Cmd+R or click the Play button"
echo ""
echo "The app will show a basic inventory list view."
