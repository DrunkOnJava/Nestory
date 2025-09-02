#!/bin/bash
#
# iOS Simulator Coordinate Calibration Tool
# Purpose: Test and calibrate exact coordinates for UI elements
#

DEVICE_ID="0CFB3C64-CDE6-4F18-894D-F99C0D7D9A23"
BUNDLE_ID="com.drunkonjava.nestory.dev"
SCREENSHOT_DIR="/Users/griffin/Projects/Nestory/Screenshots"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +%H:%M:%S)] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Take screenshot with description
screenshot() {
    local name="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local filepath="${SCREENSHOT_DIR}/calibration-${name}-${timestamp}.png"
    
    xcrun simctl io "$DEVICE_ID" screenshot "$filepath"
    success "Screenshot: calibration-${name}-${timestamp}.png"
    echo "$filepath"
}

# Test tap at specific coordinate
test_tap() {
    local x="$1"
    local y="$2"
    local description="$3"
    
    log "Testing tap at ($x, $y) - $description"
    
    osascript <<EOF
tell application "Simulator"
    activate
end tell
delay 0.5
tell application "System Events"
    tell process "Simulator"
        try
            set simulatorWindow to first window
            set {winX, winY} to position of simulatorWindow
            set screenOffsetX to 30
            set screenOffsetY to 100
            set touchX to winX + screenOffsetX + $x
            set touchY to winY + screenOffsetY + $y
            click at {touchX, touchY}
        end try
    end tell
end tell
EOF
    
    sleep 2
    screenshot "$description"
}

# Launch app
log "Launching app..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
sleep 3

# Initial screenshot
screenshot "initial"

# Test corrected tab coordinates
log "Testing CORRECTED tab coordinates based on 5-tab layout..."

# iPhone 16 Pro Max: 430 points wide, 5 tabs = 86 points per tab
# Tab centers at: 43, 129, 215, 301, 387

echo "Tab coordinate analysis:"
echo "Screen width: 430 points"
echo "5 tabs = 86 points per tab"
echo "Centers should be at:"
echo "  Inventory: 43"
echo "  Search: 129" 
echo "  Capture: 215"
echo "  Analytics: 301"
echo "  Settings: 387"

# Test each tab with corrected coordinates
test_tap 43 878 "inventory-tab-corrected"
test_tap 129 878 "search-tab-corrected"  
test_tap 215 878 "capture-tab-corrected"
test_tap 301 878 "analytics-tab-corrected"
test_tap 387 878 "settings-tab-corrected"

log "Calibration test completed!"
log "Check screenshots in $SCREENSHOT_DIR to verify correct navigation"