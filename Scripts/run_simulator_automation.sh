#!/bin/bash

#
# Nestory iOS Simulator Automation Runner
# Comprehensive automation script for iOS Simulator testing
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APPLESCRIPT_PATH="$SCRIPT_DIR/ios_simulator_automation.applescript"
LOG_FILE="$HOME/Desktop/nestory_automation_runner.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE"
            ;;
    esac
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Cleanup function
cleanup() {
    log "INFO" "🧹 Performing cleanup..."
    
    # Kill any hanging simulator processes
    pkill -f "Simulator" 2>/dev/null || true
    
    # Reset simulator if needed
    xcrun simctl shutdown all 2>/dev/null || true
    
    log "SUCCESS" "✅ Cleanup completed"
}

# Trap cleanup on exit
trap cleanup EXIT

# Check prerequisites
check_prerequisites() {
    log "INFO" "🔍 Checking prerequisites..."
    
    # Check if Xcode is installed
    if ! command -v xcrun &> /dev/null; then
        log "ERROR" "❌ Xcode command line tools not found"
        exit 1
    fi
    
    # Check if Simulator is available
    if ! xcrun simctl list runtimes | grep -q "iOS"; then
        log "ERROR" "❌ iOS Simulator runtime not found"
        exit 1
    fi
    
    # Check if AppleScript file exists
    if [[ ! -f "$APPLESCRIPT_PATH" ]]; then
        log "ERROR" "❌ AppleScript file not found: $APPLESCRIPT_PATH"
        exit 1
    fi
    
    log "SUCCESS" "✅ Prerequisites check passed"
}

# Setup simulator environment
setup_simulator() {
    log "INFO" "📱 Setting up iOS Simulator..."
    
    # List available devices
    local devices=$(xcrun simctl list devices available | grep "iPhone 16 Pro Max" | head -1)
    
    if [[ -z "$devices" ]]; then
        log "WARN" "⚠️ iPhone 16 Pro Max not found, using default device"
        DEVICE_ID="booted"
    else
        # Extract device UDID
        DEVICE_ID=$(echo "$devices" | sed 's/.*(\([^)]*\)).*/\1/')
        log "INFO" "📱 Using device: $DEVICE_ID"
    fi
    
    # Boot simulator if not already running
    if ! xcrun simctl list devices | grep -q "Booted"; then
        log "INFO" "🚀 Booting iOS Simulator..."
        xcrun simctl boot "$DEVICE_ID" || {
            log "WARN" "⚠️ Boot failed, trying with 'booted' device"
            DEVICE_ID="booted"
        }
        sleep 5
    fi
    
    # Open Simulator app
    open -a Simulator
    sleep 3
    
    log "SUCCESS" "✅ iOS Simulator ready"
}

# Build and install Nestory app
build_and_install_app() {
    log "INFO" "🔨 Building and installing Nestory app..."
    
    cd "$PROJECT_ROOT"
    
    # Clean build folder
    log "INFO" "🧹 Cleaning build folder..."
    xcodebuild clean \
        -project Nestory.xcodeproj \
        -scheme Nestory-Dev \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
        2>/dev/null || log "WARN" "⚠️ Clean failed, continuing..."
    
    # Build for simulator
    log "INFO" "🔨 Building for simulator..."
    xcodebuild build \
        -project Nestory.xcodeproj \
        -scheme Nestory-Dev \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
        -derivedDataPath build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        | tee build.log
    
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        log "ERROR" "❌ Build failed. Check build.log for details."
        exit 1
    fi
    
    # Find the built app (check both local build and system temp directories)
    local app_path=$(find build -name "Nestory.app" -type d 2>/dev/null | head -1)
    
    if [[ -z "$app_path" ]]; then
        # Check system temp build directory
        app_path=$(find /tmp -name "Nestory.app" -type d 2>/dev/null | head -1)
    fi
    
    if [[ -z "$app_path" ]]; then
        log "ERROR" "❌ Built app not found in build/ or /tmp/"
        exit 1
    fi
    
    log "INFO" "📱 Found app at: $app_path"
    
    # Install app on simulator
    log "INFO" "📲 Installing app on simulator..."
    xcrun simctl install booted "$app_path"
    
    # Launch app to verify installation
    log "INFO" "🚀 Launching Nestory app..."
    xcrun simctl launch booted "${PRODUCT_BUNDLE_IDENTIFIER:-com.drunkonjava.nestory.dev}" || {
        log "WARN" "⚠️ App launch failed, continuing with automation..."
    }
    
    log "SUCCESS" "✅ App built and installed successfully"
}

# Run AppleScript automation
run_applescript_automation() {
    log "INFO" "🤖 Running AppleScript automation..."
    
    # Make sure AppleScript is executable
    chmod +x "$APPLESCRIPT_PATH"
    
    # Run the AppleScript
    if osascript "$APPLESCRIPT_PATH"; then
        log "SUCCESS" "✅ AppleScript automation completed successfully"
    else
        log "ERROR" "❌ AppleScript automation failed"
        return 1
    fi
}

# Generate test report
generate_report() {
    log "INFO" "📊 Generating test report..."
    
    local report_file="$HOME/Desktop/nestory_automation_report.html"
    local screenshot_dir="$HOME/Desktop/Nestory Screenshots"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Nestory iOS Simulator Automation Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
        .header { background: #007AFF; color: white; padding: 20px; border-radius: 8px; }
        .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        .success { background: #D4F6D4; border-color: #28a745; }
        .warning { background: #FFF3CD; border-color: #ffc107; }
        .error { background: #F8D7DA; border-color: #dc3545; }
        .screenshot { margin: 10px; display: inline-block; }
        .screenshot img { max-width: 200px; border: 1px solid #ddd; border-radius: 4px; }
        .screenshot p { text-align: center; margin: 5px 0; font-size: 12px; }
        .log-entry { font-family: monospace; font-size: 12px; margin: 2px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Nestory iOS Simulator Automation Report</h1>
        <p>Generated on: $(date)</p>
    </div>
    
    <div class="section success">
        <h2>✅ Test Summary</h2>
        <p>Automated testing completed for Nestory iOS app</p>
        <ul>
            <li>Simulator setup and app installation</li>
            <li>Navigation flow testing</li>
            <li>Feature interaction testing</li>
            <li>Screenshot capture and documentation</li>
        </ul>
    </div>
EOF

    # Add screenshots if they exist
    if [[ -d "$screenshot_dir" ]]; then
        echo '<div class="section">' >> "$report_file"
        echo '<h2>📸 Screenshots</h2>' >> "$report_file"
        echo '<div class="screenshots">' >> "$report_file"
        
        for screenshot in "$screenshot_dir"/*.png; do
            if [[ -f "$screenshot" ]]; then
                local filename=$(basename "$screenshot")
                echo '<div class="screenshot">' >> "$report_file"
                echo "<img src=\"file://$screenshot\" alt=\"$filename\">" >> "$report_file"
                echo "<p>$filename</p>" >> "$report_file"
                echo '</div>' >> "$report_file"
            fi
        done
        
        echo '</div>' >> "$report_file"
        echo '</div>' >> "$report_file"
    fi
    
    # Add log entries
    if [[ -f "$LOG_FILE" ]]; then
        echo '<div class="section">' >> "$report_file"
        echo '<h2>📋 Automation Log</h2>' >> "$report_file"
        echo '<div class="log">' >> "$report_file"
        
        while IFS= read -r line; do
            echo "<div class=\"log-entry\">$line</div>" >> "$report_file"
        done < "$LOG_FILE"
        
        echo '</div>' >> "$report_file"
        echo '</div>' >> "$report_file"
    fi
    
    echo '</body></html>' >> "$report_file"
    
    log "SUCCESS" "✅ Report generated: $report_file"
    
    # Open report in browser
    open "$report_file"
}

# Main execution
main() {
    log "INFO" "🚀 Starting Nestory iOS Simulator Automation"
    
    # Initialize log file
    echo "=== Nestory iOS Simulator Automation Started at $(date) ===" > "$LOG_FILE"
    
    # Check prerequisites
    check_prerequisites
    
    # Setup simulator
    setup_simulator
    
    # Build and install app
    build_and_install_app
    
    # Run automation
    if run_applescript_automation; then
        log "SUCCESS" "✅ All automation tasks completed successfully"
        generate_report
    else
        log "ERROR" "❌ Automation failed"
        exit 1
    fi
    
    log "INFO" "🎉 Nestory iOS Simulator Automation completed!"
}

# Script options
case "${1:-}" in
    "--help"|"-h")
        echo "Nestory iOS Simulator Automation Runner"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --setup-only   Only setup simulator, don't run automation"
        echo "  --test-only    Only run automation, skip build"
        echo ""
        exit 0
        ;;
    "--setup-only")
        check_prerequisites
        setup_simulator
        log "SUCCESS" "✅ Setup completed"
        exit 0
        ;;
    "--test-only")
        check_prerequisites
        run_applescript_automation
        generate_report
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log "ERROR" "❌ Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac