#!/bin/bash
# Final build and run script for Nestory

set -e

cd /Users/griffin/Projects/Nestory

echo "🚀 Nestory Build & Run"
echo "====================="

# Clean
echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*
rm -rf DerivedData

# Generate project if needed
if [ ! -d "Nestory.xcodeproj" ]; then
    echo "📐 Generating Xcode project..."
    xcodegen generate
fi

# Build
echo "🔨 Building app..."
xcodebuild \
    -scheme Nestory-Dev \
    -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
    -configuration Debug \
    CODE_SIGNING_ALLOWED=NO \
    COMPILER_INDEX_STORE_ENABLE=NO \
    build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    
    # Find the app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Nestory-*/Build/Products/Debug-iphonesimulator -name "Nestory.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📱 Installing and running app..."
        
        # Boot simulator
        xcrun simctl boot "iPhone 16 Pro Max" 2>/dev/null || true
        open -a Simulator
        
        # Wait for boot
        sleep 2
        
        # Install and launch
        DEVICE_ID=$(xcrun simctl list devices | grep "iPhone 16 Pro Max" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)
        
        xcrun simctl install "$DEVICE_ID" "$APP_PATH"
        xcrun simctl launch "$DEVICE_ID" "${PRODUCT_BUNDLE_IDENTIFIER:-com.drunkonjava.nestory}"
        
        echo ""
        echo "🎉 Nestory is now running!"
        echo ""
        echo "The app shows:"
        echo "  • A simple inventory list"
        echo "  • Add items with the + button"
        echo "  • SwiftData persistence"
        echo "  • Dark mode support"
    fi
else
    echo "❌ Build failed"
    exit 1
fi
