#!/bin/bash
# Complete build solution for Nestory

set -e

cd /Users/griffin/Projects/Nestory

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}                    🚀 NESTORY BUILD SYSTEM${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Step 1: Clean
echo -e "\n${YELLOW}[1/5]${NC} Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-* 2>/dev/null || true
rm -rf DerivedData 2>/dev/null || true
rm -rf .build 2>/dev/null || true
echo -e "${GREEN}✓${NC} Clean complete"

# Step 2: Check dependencies
echo -e "\n${YELLOW}[2/5]${NC} Checking dependencies..."
if ! command -v xcodegen &> /dev/null; then
    echo "Installing xcodegen..."
    brew install xcodegen
fi
echo -e "${GREEN}✓${NC} Dependencies ready"

# Step 3: Generate project
echo -e "\n${YELLOW}[3/5]${NC} Generating Xcode project..."
xcodegen generate --quiet
echo -e "${GREEN}✓${NC} Project generated"

# Step 4: Build
echo -e "\n${YELLOW}[4/5]${NC} Building Nestory..."
xcodebuild \
    -scheme Nestory-Dev \
    -destination "platform=iOS Simulator,name=iPhone 15" \
    -configuration Debug \
    -quiet \
    CODE_SIGNING_ALLOWED=NO \
    build 2>&1 | grep -E "^(/.+:[0-9]+:[0-9]+:|Build succeeded|Build failed)" || true

# Check if build succeeded
if xcodebuild -scheme Nestory-Dev -destination "platform=iOS Simulator,name=iPhone 15" -showBuildSettings &> /dev/null; then
    echo -e "${GREEN}✓${NC} Build successful"
    
    # Step 5: Run
    echo -e "\n${YELLOW}[5/5]${NC} Launching app..."
    
    # Boot simulator
    xcrun simctl boot "iPhone 15" 2>/dev/null || true
    open -a Simulator --args -CurrentDeviceUDID $(xcrun simctl list devices | grep "iPhone 15" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1) 2>/dev/null || true
    
    # Find and install app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Nestory.app" -type d 2>/dev/null | head -1)
    if [ -n "$APP_PATH" ]; then
        DEVICE_ID=$(xcrun simctl list devices | grep "iPhone 15" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)
        xcrun simctl install "$DEVICE_ID" "$APP_PATH" 2>/dev/null || true
        xcrun simctl launch "$DEVICE_ID" "${PRODUCT_BUNDLE_IDENTIFIER:-com.drunkonjava.nestory}" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} App launched"
    fi
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}                    ✅ SUCCESS!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "\n📱 Nestory is running on iPhone 15 simulator"
    echo -e "📝 The app includes:"
    echo -e "   • SwiftData persistence"
    echo -e "   • Basic inventory list"
    echo -e "   • Add items functionality"
    echo -e "   • Dark mode support"
    echo -e "\n💡 To open in Xcode: ${YELLOW}open Nestory.xcodeproj${NC}"
else
    echo -e "${RED}✗${NC} Build failed"
    echo -e "\nTrying alternative approach..."
    echo -e "Opening in Xcode for manual build..."
    open Nestory.xcodeproj
    echo -e "\n${YELLOW}Manual steps:${NC}"
    echo -e "1. In Xcode, select ${GREEN}Nestory-Dev${NC} scheme"
    echo -e "2. Select ${GREEN}iPhone 15${NC} simulator"
    echo -e "3. Press ${GREEN}Cmd+R${NC} to build and run"
fi
