#!/bin/bash
#
# iOS Simulator Navigation & Screenshot Automation
# Purpose: Command-line automation for Nestory app testing and documentation
# Usage: ./simulator-navigator.sh [action] [options]
#

set -euo pipefail

# Configuration
DEVICE_ID="0CFB3C64-CDE6-4F18-894D-F99C0D7D9A23"  # iPhone 16 Pro Max iOS 18.6
BUNDLE_ID="com.drunkonjava.nestory.dev"
SCREENSHOT_DIR="/Users/griffin/Projects/Nestory/Screenshots"
DELAY_BETWEEN_ACTIONS=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Ensure simulator is ready
ensure_simulator() {
    log_info "Checking simulator status..."
    
    # Check if device exists
    if ! xcrun simctl list devices | grep -q "$DEVICE_ID"; then
        log_error "Device $DEVICE_ID not found"
        exit 1
    fi
    
    # Boot if not booted
    local boot_status
    boot_status=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted\|Shutdown")
    
    if [[ "$boot_status" != "Booted" ]]; then
        log_info "Booting simulator..."
        xcrun simctl boot "$DEVICE_ID"
        sleep 5
    fi
    
    log_success "Simulator is ready"
}

# Launch app
launch_app() {
    log_info "Launching $BUNDLE_ID..."
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
    sleep 3
    log_success "App launched"
}

# Take screenshot with timestamp
take_screenshot() {
    local name="$1"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local filename="${name}-${timestamp}.png"
    local filepath="${SCREENSHOT_DIR}/${filename}"
    
    mkdir -p "$SCREENSHOT_DIR"
    
    if xcrun simctl io "$DEVICE_ID" screenshot "$filepath"; then
        log_success "Screenshot saved: $filename"
        echo "$filepath"  # Return filepath for other scripts
    else
        log_error "Failed to take screenshot: $name"
        return 1
    fi
}

# Send touch events using coordinates (iPhone 16 Pro Max dimensions: 430x932 points)
simulate_touch() {
    local x="$1"
    local y="$2"
    local description="${3:-touch}"
    
    log_info "Simulating $description at ($x, $y)"
    
    # Use AppleScript for precise touch simulation
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
            set {winWidth, winHeight} to size of simulatorWindow
            
            -- Calculate actual touch position within simulator screen area
            -- Simulator has chrome around the actual screen
            set screenOffsetX to 30  -- Approximate offset from window edge to screen
            set screenOffsetY to 100 -- Approximate offset for top chrome
            
            set touchX to winX + screenOffsetX + $x
            set touchY to winY + screenOffsetY + $y
            
            click at {touchX, touchY}
            
        on error errMsg
            log "Touch simulation failed: " & errMsg
        end try
    end tell
end tell
EOF
    
    sleep "$DELAY_BETWEEN_ACTIONS"
}

# Simulate swipe gesture
simulate_swipe() {
    local start_x="$1"
    local start_y="$2" 
    local end_x="$3"
    local end_y="$4"
    local description="${5:-swipe}"
    
    log_info "Simulating $description from ($start_x, $start_y) to ($end_x, $end_y)"
    
    # Use multiple touch points to simulate swipe
    local steps=10
    local dx=$(( (end_x - start_x) / steps ))
    local dy=$(( (end_y - start_y) / steps ))
    
    for i in $(seq 0 $steps); do
        local current_x=$((start_x + i * dx))
        local current_y=$((start_y + i * dy))
        
        osascript <<EOF
tell application "System Events"
    tell process "Simulator"
        try
            set simulatorWindow to first window
            set {winX, winY} to position of simulatorWindow
            set screenOffsetX to 30
            set screenOffsetY to 100
            set touchX to winX + screenOffsetX + $current_x
            set touchY to winY + screenOffsetY + $current_y
            click at {touchX, touchY}
        end try
    end tell
end tell
EOF
        sleep 0.1
    done
    
    sleep "$DELAY_BETWEEN_ACTIONS"
}

# Navigate to specific tab (bottom tab bar)
navigate_to_tab() {
    local tab_name="$1"
    log_info "Navigating to $tab_name tab"
    
    # Tab bar coordinates (approximate for iPhone 16 Pro Max)
    case "$tab_name" in
        "inventory")
            simulate_touch 86 878 "inventory tab"
            ;;
        "search")
            simulate_touch 215 878 "search tab"
            ;;
        "analytics")
            simulate_touch 344 878 "analytics tab"
            ;;
        "settings")
            simulate_touch 473 878 "settings tab"
            ;;
        *)
            log_warning "Unknown tab: $tab_name"
            return 1
            ;;
    esac
}

# Take screenshot of current view
screenshot_current_view() {
    local view_name="${1:-current-view}"
    take_screenshot "$view_name"
}

# Comprehensive app navigation
navigate_all_views() {
    log_info "Starting comprehensive app navigation..."
    
    ensure_simulator
    launch_app
    
    # Main inventory view
    take_screenshot "01-inventory-main"
    
    # Navigate to first item if available
    simulate_touch 215 300 "first item tap"
    take_screenshot "02-item-detail"
    
    # Go back
    simulate_touch 50 100 "back button"
    
    # Try add item button (top right)
    simulate_touch 380 100 "add item button"
    take_screenshot "03-add-item-sheet"
    
    # Cancel add item
    simulate_touch 50 100 "cancel button"
    
    # Navigate to search
    navigate_to_tab "search"
    take_screenshot "04-search-view"
    
    # Activate search field
    simulate_touch 215 150 "search field"
    take_screenshot "05-search-active"
    
    # Navigate to analytics
    navigate_to_tab "analytics"
    take_screenshot "06-analytics-view"
    
    # Navigate to settings
    navigate_to_tab "settings"
    take_screenshot "07-settings-view"
    
    # Scroll down in settings
    simulate_swipe 215 400 215 200 "scroll down"
    take_screenshot "08-settings-scrolled"
    
    log_success "Navigation completed!"
}

# Interactive mode for manual control
interactive_mode() {
    log_info "Starting interactive mode. Type 'help' for commands."
    
    ensure_simulator
    launch_app
    
    while true; do
        echo -n "simulator> "
        read -r command
        
        case "$command" in
            "help")
                echo "Available commands:"
                echo "  screenshot [name]     - Take screenshot"
                echo "  touch <x> <y>         - Simulate touch at coordinates"
                echo "  swipe <x1> <y1> <x2> <y2> - Simulate swipe gesture"
                echo "  tab <name>            - Navigate to tab (inventory/search/analytics/settings)"
                echo "  launch                - Launch app"
                echo "  status                - Show simulator status"
                echo "  exit                  - Exit interactive mode"
                ;;
            "screenshot"*)
                local name
                name=$(echo "$command" | cut -d' ' -f2-)
                if [[ -z "$name" ]]; then
                    name="manual-capture"
                fi
                take_screenshot "$name"
                ;;
            "touch "*)
                local coords
                coords=$(echo "$command" | cut -d' ' -f2-)
                local x y
                x=$(echo "$coords" | cut -d' ' -f1)
                y=$(echo "$coords" | cut -d' ' -f2)
                simulate_touch "$x" "$y" "manual touch"
                ;;
            "swipe "*)
                local coords
                coords=$(echo "$command" | cut -d' ' -f2-)
                local x1 y1 x2 y2
                x1=$(echo "$coords" | cut -d' ' -f1)
                y1=$(echo "$coords" | cut -d' ' -f2)
                x2=$(echo "$coords" | cut -d' ' -f3)
                y2=$(echo "$coords" | cut -d' ' -f4)
                simulate_swipe "$x1" "$y1" "$x2" "$y2" "manual swipe"
                ;;
            "tab "*)
                local tab_name
                tab_name=$(echo "$command" | cut -d' ' -f2)
                navigate_to_tab "$tab_name"
                ;;
            "launch")
                launch_app
                ;;
            "status")
                xcrun simctl list devices | grep "$DEVICE_ID"
                ;;
            "exit"|"quit")
                log_info "Exiting interactive mode"
                break
                ;;
            "")
                ;;
            *)
                log_warning "Unknown command: $command (type 'help' for available commands)"
                ;;
        esac
    done
}

# Usage information
usage() {
    echo "iOS Simulator Navigator for Nestory"
    echo
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  navigate         - Run full app navigation with screenshots"
    echo "  screenshot [name] - Take single screenshot"
    echo "  interactive      - Start interactive mode"
    echo "  launch           - Launch app only"
    echo "  status           - Show simulator status"
    echo
    echo "Examples:"
    echo "  $0 navigate"
    echo "  $0 screenshot home-view"
    echo "  $0 interactive"
}

# Main execution
main() {
    case "${1:-}" in
        "navigate")
            navigate_all_views
            ;;
        "screenshot")
            ensure_simulator
            launch_app
            local name="${2:-manual-screenshot}"
            take_screenshot "$name"
            ;;
        "interactive")
            interactive_mode
            ;;
        "launch")
            ensure_simulator
            launch_app
            ;;
        "status")
            xcrun simctl list devices | grep "$DEVICE_ID"
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