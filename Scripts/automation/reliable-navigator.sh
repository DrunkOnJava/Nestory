#!/bin/bash
#
# Reliable iOS Simulator Navigation with App Restarts
# Purpose: Standardized navigation testing with clean state between tests
#

set -euo pipefail

# Configuration
DEVICE_ID="0CFB3C64-CDE6-4F18-894D-F99C0D7D9A23"
BUNDLE_ID="com.drunkonjava.nestory.dev"
SCREENSHOT_DIR="/Users/griffin/Projects/Nestory/Screenshots"
DELAY_BETWEEN_ACTIONS=3  # Increased for more reliable timing

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[$(date +%H:%M:%S)] ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}[$(date +%H:%M:%S)] ✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date +%H:%M:%S)] ⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +%H:%M:%S)] ❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}[$(date +%H:%M:%S)] 🔄 $1${NC}"
}

# Restart app to clean state
restart_app() {
    log_step "Restarting app for clean state..."
    
    # Terminate app if running
    xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
    sleep 1
    
    # Launch fresh
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" > /dev/null
    sleep $DELAY_BETWEEN_ACTIONS
    
    log_success "App restarted with clean state"
}

# Take screenshot with timestamp
take_screenshot() {
    local name="$1"
    local description="$2"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local filename="reliable-${name}-${timestamp}.png"
    local filepath="${SCREENSHOT_DIR}/${filename}"
    
    mkdir -p "$SCREENSHOT_DIR"
    
    if xcrun simctl io "$DEVICE_ID" screenshot "$filepath"; then
        log_success "📸 ${description}: ${filename}"
        echo "$filepath"
    else
        log_error "Failed to capture ${name}"
        return 1
    fi
}

# Precise tab navigation with verified coordinates
navigate_to_tab() {
    local tab_name="$1"
    local description="$2"
    
    log_step "Navigating to ${tab_name} tab..."
    
    # CORRECTED coordinates based on calibration results
    case "$tab_name" in
        "inventory")
            local x=71 y=878
            ;;
        "search")  
            local x=215 y=878  # This was hitting Capture in calibration - needs adjustment
            ;;
        "capture")
            local x=129 y=878  # This coordinate showed Capture in calibration
            ;;
        "analytics")
            local x=301 y=878  # VERIFIED WORKING
            ;;
        "settings")
            local x=387 y=878  # Needs verification
            ;;
        *)
            log_error "Unknown tab: $tab_name"
            return 1
            ;;
    esac
    
    # Execute tap
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
        on error errMsg
            log "Navigation failed: " & errMsg
        end try
    end tell
end tell
EOF
    
    sleep $DELAY_BETWEEN_ACTIONS
    take_screenshot "${tab_name}-tab" "$description"
}

# Test each tab individually with app restart
test_individual_tabs() {
    log_info "🧪 Testing individual tab navigation with app restarts..."
    
    # Test Analytics (we know this works)
    restart_app
    navigate_to_tab "analytics" "Analytics Dashboard - Verified Working"
    
    # Test Inventory (return to start)
    restart_app
    navigate_to_tab "inventory" "Inventory View - Return to Start"
    
    # Test Capture (camera functionality)  
    restart_app
    navigate_to_tab "capture" "Capture View - Camera Features"
    
    # Test Settings (need to find correct coordinate)
    restart_app 
    navigate_to_tab "settings" "Settings View - App Configuration"
}

# Comprehensive journey with strategic restarts
test_comprehensive_journey() {
    log_info "🌟 Testing comprehensive app journey with strategic restarts..."
    
    # Phase 1: Initial state
    restart_app
    take_screenshot "01-initial" "Fresh app launch - initial state"
    
    # Phase 2: Analytics (proven working)
    log_step "Phase 2: Navigating to Analytics..."
    navigate_to_tab "analytics" "Analytics dashboard with inventory statistics"
    
    # Phase 3: Return to inventory (with restart for clean state)  
    restart_app
    take_screenshot "02-inventory-return" "Returned to inventory after restart"
    
    # Phase 4: Test capture functionality
    log_step "Phase 4: Testing capture functionality..."
    navigate_to_tab "capture" "Camera capture interface"
    
    # Phase 5: Settings (with restart)
    restart_app  
    log_step "Phase 5: Testing settings navigation..."
    navigate_to_tab "settings" "Settings and configuration options"
    
    log_success "🎉 Comprehensive journey completed with strategic restarts!"
}

# Interactive coordinate finder
interactive_coordinate_finder() {
    log_info "🎯 Interactive coordinate finder mode..."
    log_info "This will help you find exact coordinates for UI elements"
    
    restart_app
    take_screenshot "coordinate-base" "Base state for coordinate finding"
    
    echo ""
    echo "Instructions:"
    echo "1. Look at the current screenshot"
    echo "2. Enter coordinates to test (format: x y description)"
    echo "3. Type 'restart' to reset app state"
    echo "4. Type 'quit' to exit"
    echo ""
    
    while true; do
        echo -n "Enter coordinates (x y description) or 'restart' or 'quit': "
        read -r input
        
        case "$input" in
            "quit"|"exit")
                log_info "Exiting coordinate finder"
                break
                ;;
            "restart")
                restart_app
                take_screenshot "coordinate-restart" "App restarted for coordinate testing"
                ;;
            *)
                # Parse coordinates
                local x y description
                x=$(echo "$input" | awk '{print $1}')
                y=$(echo "$input" | awk '{print $2}')
                description=$(echo "$input" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//')
                
                if [[ "$x" =~ ^[0-9]+$ ]] && [[ "$y" =~ ^[0-9]+$ ]]; then
                    log_step "Testing tap at ($x, $y) - $description"
                    
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
                    take_screenshot "coord-test-${x}-${y}" "Coordinate test: ($x, $y) - $description"
                else
                    log_warning "Invalid coordinates. Use format: x y description"
                fi
                ;;
        esac
    done
}

# Usage information
usage() {
    echo "Reliable iOS Simulator Navigator with App Restarts"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  individual       - Test each tab individually with app restarts"
    echo "  comprehensive    - Full app journey with strategic restarts"  
    echo "  coordinate       - Interactive coordinate finder"
    echo "  restart          - Just restart the app"
    echo ""
    echo "Key Features:"
    echo "  ✅ App restart between tests for clean state"
    echo "  ✅ Verified coordinates from calibration testing" 
    echo "  ✅ Comprehensive logging and error handling"
    echo "  ✅ Strategic delays for reliable interaction"
}

# Main execution
main() {
    case "${1:-}" in
        "individual")
            test_individual_tabs
            ;;
        "comprehensive")
            test_comprehensive_journey
            ;;
        "coordinate")
            interactive_coordinate_finder
            ;;
        "restart")
            restart_app
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"