#!/bin/bash
# Boot iPhone 16 Plus simulator
# Part of the hot reload development setup

set -e

echo "🚀 Booting iPhone 16 Plus simulator..."

# Get the device ID for iPhone 16 Plus
DEVICE_ID=$(xcrun simctl list devices | grep "iPhone 16 Plus" | grep -v unavailable | head -n 1 | awk -F '[()]' '{print $2}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ iPhone 16 Plus simulator not found"
    echo "Creating iPhone 16 Plus simulator..."
    DEVICE_ID=$(xcrun simctl create "iPhone 16 Plus" "iPhone 16 Plus" iOS17.0)
fi

# Boot the device if not already booted
STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | awk '{print $NF}')
if [ "$STATE" != "(Booted)" ]; then
    xcrun simctl boot "$DEVICE_ID"
    echo "✅ Simulator booted: $DEVICE_ID"
    
    # Wait for boot to complete
    sleep 3
else
    echo "✅ Simulator already booted: $DEVICE_ID"
fi

# Open Simulator app
open -a Simulator

echo "📱 iPhone 16 Plus ready for development"
echo "Device ID: $DEVICE_ID"