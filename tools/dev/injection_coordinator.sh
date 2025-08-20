#!/bin/bash
# Injection Coordinator for Claude Code Hot Reload
# This script bridges Claude's file writes to our custom InjectionNext implementation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="$PROJECT_ROOT/.build/injection.log"
INJECTION_SERVER_PORT=8899
INJECTION_SERVER_HOST="localhost"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize log
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Injection coordinator started" >> "$LOG_FILE"

# Function to print colored output
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%H:%M:%S')
    
    case $level in
        INFO)
            echo -e "${BLUE}[$timestamp]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[$timestamp]${NC} ✅ $message"
            ;;
        WARNING)
            echo -e "${YELLOW}[$timestamp]${NC} ⚠️  $message"
            ;;
        ERROR)
            echo -e "${RED}[$timestamp]${NC} ❌ $message"
            ;;
    esac
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] $message" >> "$LOG_FILE"
}

# Function to check if simulator is running
check_simulator() {
    if pgrep -x "Simulator" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to get active simulator device
get_active_simulator() {
    xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(\([^)]*\)).*/\1/'
}

# Function to check if InjectionNext server is running
check_injection_server() {
    if lsof -i :$INJECTION_SERVER_PORT > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to send command to injection server
send_injection_command() {
    local command="$1"
    
    # Use netcat to send command to our custom injection server
    echo "$command" | nc -w 1 $INJECTION_SERVER_HOST $INJECTION_SERVER_PORT 2>/dev/null
    
    if [ $? -eq 0 ]; then
        return 0
    else
        log ERROR "Failed to send command to injection server"
        return 1
    fi
}

# Function to ensure injection server is running
ensure_injection_server() {
    if ! check_injection_server; then
        log WARNING "InjectionNext server not running on port $INJECTION_SERVER_PORT"
        log INFO "The app should start the injection server automatically when running in DEBUG mode"
        return 1
    fi
    return 0
}

# Function to trigger injection for modified files
trigger_injection() {
    local file_path="$1"
    local relative_path="${file_path#$PROJECT_ROOT/}"
    
    log INFO "Triggering injection for: $relative_path"
    
    # Validate it's a Swift file
    if [[ ! "$file_path" =~ \.swift$ ]]; then
        log WARNING "Skipping non-Swift file: $relative_path"
        return 0
    fi
    
    # Check if file is in an injectable location
    if [[ "$relative_path" =~ ^(App-Main|UI|Services|Infrastructure|Foundation)/ ]]; then
        log INFO "File is in injectable location"
    else
        log WARNING "File not in injectable location: $relative_path"
        return 0
    fi
    
    # Ensure simulator is running
    if ! check_simulator; then
        log ERROR "Simulator not running. Please start the app first."
        return 1
    fi
    
    # Get active simulator device
    local device_id=$(get_active_simulator)
    if [ -z "$device_id" ]; then
        log ERROR "No booted simulator found"
        return 1
    fi
    
    log INFO "Active simulator: $device_id"
    
    # Ensure injection server is running
    if ! ensure_injection_server; then
        return 1
    fi
    
    # Send injection command to our server
    log INFO "Sending injection signal..."
    
    if send_injection_command "INJECT:$file_path"; then
        log SUCCESS "Injection triggered for $relative_path"
    else
        log ERROR "Failed to trigger injection for $relative_path"
        return 1
    fi
    
    # Send system notification (optional)
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"Hot reload triggered for ${relative_path##*/}\" with title \"Claude Code Injection\" sound name \"Pop\""
    fi
    
    return 0
}

# Function to process batch of files
process_files() {
    local files=("$@")
    local success_count=0
    local fail_count=0
    
    for file in "${files[@]}"; do
        if trigger_injection "$file"; then
            success_count=$((success_count + 1))
        else
            fail_count=$((fail_count + 1))
        fi
    done
    
    log INFO "Batch complete: $success_count succeeded, $fail_count failed"
}

# Main execution
main() {
    log INFO "Injection Coordinator v1.0"
    log INFO "Project root: $PROJECT_ROOT"
    
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        log ERROR "No files specified"
        echo "Usage: $0 <file1> [file2] [file3] ..."
        echo "Example: $0 /path/to/ContentView.swift"
        exit 1
    fi
    
    # Check prerequisites
    if ! command -v xcrun &> /dev/null; then
        log ERROR "Xcode command line tools not installed"
        exit 1
    fi
    
    # Process all provided files
    process_files "$@"
    
    log INFO "Injection coordinator completed"
}

# Handle script termination
trap 'log INFO "Injection coordinator terminated"' EXIT

# Run main function
main "$@"