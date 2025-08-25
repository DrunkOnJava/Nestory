#!/bin/bash
# setup-simulator-permissions.sh
# Grant all necessary permissions to the simulator for deterministic testing

set -e

# Configuration
BUNDLE_ID="com.drunkonjava.nestory"
SIMULATOR_NAME="${1:-iPhone 16 Pro Max}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "📱 Setting up Simulator Permissions"
echo "==================================="
echo ""

# Find simulator device ID
echo -e "${BLUE}Finding simulator: $SIMULATOR_NAME${NC}"
DEVICE_ID=$(xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep -E '\([A-F0-9\-]+\)' | head -1 | sed -E 's/.*\(([A-F0-9\-]+)\).*/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Simulator '$SIMULATOR_NAME' not found"
    echo "Available simulators:"
    xcrun simctl list devices | grep -E "iPhone|iPad" | head -10
    exit 1
fi

echo -e "${GREEN}✓ Found simulator: $DEVICE_ID${NC}"

# Boot simulator if needed
echo -e "${BLUE}Checking simulator state...${NC}"
STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | sed -E 's/.*\((.*)\).*/\1/')

if [ "$STATE" != "Booted" ]; then
    echo "Booting simulator..."
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    sleep 5
fi
echo -e "${GREEN}✓ Simulator is booted${NC}"

# Grant permissions
echo ""
echo -e "${BLUE}Granting permissions...${NC}"

# Camera permission
echo "  📷 Camera..."
xcrun simctl privacy "$DEVICE_ID" grant camera "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant camera "$BUNDLE_ID.dev" 2>/dev/null || true

# Photo Library permission
echo "  🖼️  Photo Library..."
xcrun simctl privacy "$DEVICE_ID" grant photos "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant photos "$BUNDLE_ID.dev" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant photos-add "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant photos-add "$BUNDLE_ID.dev" 2>/dev/null || true

# Notifications permission
echo "  🔔 Notifications..."
xcrun simctl privacy "$DEVICE_ID" grant notifications "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant notifications "$BUNDLE_ID.dev" 2>/dev/null || true

# Location permission (if needed)
echo "  📍 Location..."
xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant location "$BUNDLE_ID.dev" 2>/dev/null || true

# Contacts permission (for emergency contacts feature)
echo "  👥 Contacts..."
xcrun simctl privacy "$DEVICE_ID" grant contacts "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant contacts "$BUNDLE_ID.dev" 2>/dev/null || true

# Calendar permission (for warranty reminders)
echo "  📅 Calendar..."
xcrun simctl privacy "$DEVICE_ID" grant calendar "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant calendar "$BUNDLE_ID.dev" 2>/dev/null || true

# Reminders permission
echo "  ⏰ Reminders..."
xcrun simctl privacy "$DEVICE_ID" grant reminders "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant reminders "$BUNDLE_ID.dev" 2>/dev/null || true

# Media Library (for potential future features)
echo "  🎵 Media Library..."
xcrun simctl privacy "$DEVICE_ID" grant media-library "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl privacy "$DEVICE_ID" grant media-library "$BUNDLE_ID.dev" 2>/dev/null || true

echo -e "${GREEN}✓ All permissions granted${NC}"

# Configure simulator settings for testing
echo ""
echo -e "${BLUE}Configuring simulator settings...${NC}"

# Set status bar for consistent screenshots
echo "  📶 Status bar..."
xcrun simctl status_bar "$DEVICE_ID" override \
    --time "9:41" \
    --dataNetwork "5G" \
    --wifiMode "active" \
    --wifiBars 3 \
    --cellularMode "active" \
    --cellularBars 4 \
    --batteryState "charged" \
    --batteryLevel 100 2>/dev/null || true

# Set appearance mode (light mode for consistency)
echo "  🌞 Appearance..."
xcrun simctl ui "$DEVICE_ID" appearance light 2>/dev/null || true

# Disable keyboard autocorrection (for text input tests)
echo "  ⌨️  Keyboard..."
defaults write com.apple.iphonesimulator KeyboardAutocorrection -bool false 2>/dev/null || true
defaults write com.apple.iphonesimulator KeyboardPrediction -bool false 2>/dev/null || true

echo -e "${GREEN}✓ Simulator configured${NC}"

# Clear app data for clean state
echo ""
echo -e "${BLUE}Clearing app data...${NC}"

# Uninstall app if it exists (to ensure clean state)
xcrun simctl uninstall "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl uninstall "$DEVICE_ID" "$BUNDLE_ID.dev" 2>/dev/null || true

echo -e "${GREEN}✓ App data cleared${NC}"

# Summary
echo ""
echo "===================================="
echo -e "${GREEN}✅ Simulator Setup Complete${NC}"
echo ""
echo "Device: $SIMULATOR_NAME"
echo "ID: $DEVICE_ID"
echo "Bundle: $BUNDLE_ID"
echo ""
echo "Permissions granted:"
echo "  ✓ Camera"
echo "  ✓ Photo Library"
echo "  ✓ Notifications"
echo "  ✓ Location"
echo "  ✓ Contacts"
echo "  ✓ Calendar"
echo "  ✓ Reminders"
echo "  ✓ Media Library"
echo ""
echo "Ready for deterministic testing! 🚀"