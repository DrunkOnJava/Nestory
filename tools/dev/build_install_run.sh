#!/bin/bash
# Build, install and run Nestory app with hot reload
# Part of the hot reload development setup

set -e

# Ensure we're using Swift 6, not any override
unset TOOLCHAINS

PROJECT_ROOT="$(dirname $(dirname $(dirname "$0")))"
cd "$PROJECT_ROOT"

# Check if InjectionIII is running
if ! pgrep -x "InjectionIII" > /dev/null; then
    echo "🔥 Launching InjectionIII for hot reload..."
    ./tools/dev/launch_injection.sh
    sleep 3
fi

echo "🏗️  Building Nestory with hot reload support..."

# Ensure simulator is booted
./tools/dev/boot_sim.sh

# Get the device ID for iPhone 16 Plus
DEVICE_ID=$(xcrun simctl list devices | grep "iPhone 16 Plus" | grep -v unavailable | head -n 1 | awk -F '[()]' '{print $2}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Failed to get iPhone 16 Plus device ID"
    exit 1
fi

# Build the app
echo "📦 Building for iOS Simulator..."
xcodebuild \
    -project Nestory.xcodeproj \
    -scheme Nestory-Dev \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -derivedDataPath build/DerivedData \
    build | xcbeautify

# Get the app path
APP_PATH="$(find build/DerivedData/Build/Products -name "*.app" -type d | head -n 1)"

if [ -z "$APP_PATH" ]; then
    echo "❌ Failed to find built app"
    exit 1
fi

echo "📲 Installing app to simulator..."
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

# Launch the app
echo "🚀 Launching Nestory..."
# Use environment variable or default for development
BUNDLE_ID="${PRODUCT_BUNDLE_IDENTIFIER:-com.drunkonjava.nestory.dev}"
xcrun simctl launch --console "$DEVICE_ID" "$BUNDLE_ID"

echo "✅ Nestory is running with hot reload enabled!"
echo ""
echo "📝 Hot Reload Instructions:"
echo "1. InjectionIII should be running in the menu bar"
echo "2. Select File > Watch Project and choose the Nestory folder"
echo "3. Edit any Swift file and save - changes will reload instantly"
echo "4. Use Cmd+S to trigger reload after changes"
echo ""
echo "💡 Tips:"
echo "- Keep console open to see reload logs"
echo "- If reload fails, rebuild with this script"
echo "- Run ./tools/dev/tail_logs.sh in another terminal for detailed logs"