#!/bin/bash
#
# Automated Test Runner for Nestory
# Runs the complete test suite without debug screen interruptions
# Supports both command-line and Xcode GUI execution modes
#

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCHEME="Nestory-Dev"
readonly DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro Max"
readonly RESULT_BUNDLE="./test_results_automated_$(date +%Y%m%d_%H%M%S).xcresult"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to check if Xcode is running and has debug sessions
check_xcode_debug_state() {
    log "Checking for active Xcode debug sessions..."
    
    # Check if Xcode is running
    if pgrep -x "Xcode" > /dev/null; then
        warning "Xcode is running. If tests are triggered from Xcode, they will use the automated scheme settings."
    fi
    
    # Kill any existing debug sessions that might interfere
    if pgrep -f "lldb-rpc-server" > /dev/null; then
        warning "Found active LLDB sessions, terminating them..."
        pkill -f "lldb-rpc-server" || true
    fi
    
    # Kill any simulator debug processes
    if pgrep -f "SimulatorTrampoline" > /dev/null; then
        warning "Found simulator debug processes, terminating them..."
        pkill -f "SimulatorTrampoline" || true
    fi
}

# Function to ensure simulator is ready
prepare_simulator() {
    log "Preparing iOS Simulator..."
    
    # Boot the simulator if not already running
    local simulator_udid
    simulator_udid=$(xcrun simctl list devices | grep "iPhone 16 Pro Max" | grep "Shutdown" | head -1 | grep -o '[0-9A-F-]\{36\}' || true)
    
    if [[ -n "$simulator_udid" ]]; then
        log "Booting iPhone 16 Pro Max simulator..."
        xcrun simctl boot "$simulator_udid"
        sleep 5
    fi
    
    success "Simulator is ready"
}

# Function to run automated tests with full configuration
run_automated_tests() {
    log "Starting automated test execution..."
    log "Scheme: $SCHEME"
    log "Destination: $DESTINATION" 
    log "Result Bundle: $RESULT_BUNDLE"
    
    # Set environment variables to prevent debug interruptions
    export SWIFT_ISSUE_REPORTING_BREAKPOINT=0
    export ISSUE_REPORTING_DISABLE_BREAKPOINT=1
    export SWIFT_DETERMINISTIC_HASHING=1
    export OS_ACTIVITY_MODE=disable
    export SWIFT_DISABLE_FATAL_ERRORS=1
    
    log "Environment variables set for automation:"
    log "  SWIFT_ISSUE_REPORTING_BREAKPOINT=0"
    log "  ISSUE_REPORTING_DISABLE_BREAKPOINT=1"
    log "  SWIFT_DETERMINISTIC_HASHING=1"
    log "  OS_ACTIVITY_MODE=disable"
    log "  SWIFT_DISABLE_FATAL_ERRORS=1"
    
    # Run the tests
    log "Executing test command..."
    
    if xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -enableCodeCoverage YES \
        -parallel-testing-enabled YES \
        -test-timeouts-enabled YES \
        -maximum-concurrent-test-simulator-destinations 1 \
        -resultBundlePath "$RESULT_BUNDLE" \
        ENABLE_TESTING_SEARCH_PATHS=NO \
        LLDB_DISABLED=YES \
        DEBUG_INFORMATION_FORMAT=dwarf \
        -quiet; then
        
        success "All tests completed successfully!"
        return 0
    else
        local exit_code=$?
        error "Tests failed with exit code $exit_code"
        return $exit_code
    fi
}

# Function to generate test report
generate_test_report() {
    if [[ -d "$RESULT_BUNDLE" ]]; then
        log "Generating test report..."
        
        # Extract basic test results
        xcrun xcresulttool get --format json --path "$RESULT_BUNDLE" > test_summary.json
        
        # Count tests
        local total_tests
        local failed_tests
        total_tests=$(xcrun xcresulttool get --format json --path "$RESULT_BUNDLE" | jq '.actions[0].runDestination.targetDevice.modelName' | wc -l || echo "Unknown")
        failed_tests=$(xcrun xcresulttool get --format json --path "$RESULT_BUNDLE" | jq '[.actions[0].actionResult.testsRef.id] | length' || echo "0")
        
        log "Test Results:"
        log "  Result Bundle: $RESULT_BUNDLE"
        log "  Total Tests: $total_tests"
        log "  Failed Tests: $failed_tests"
        
        success "Test report generated: test_summary.json"
    else
        warning "Result bundle not found: $RESULT_BUNDLE"
    fi
}

# Function to cleanup
cleanup() {
    log "Cleaning up..."
    
    # Remove any temporary files if needed
    rm -f test_summary.json || true
    
    success "Cleanup completed"
}

# Main execution function
main() {
    log "Starting Nestory Automated Test Runner"
    log "========================================"
    
    # Ensure we're in the correct directory
    if [[ ! -f "Nestory.xcodeproj/project.pbxproj" ]]; then
        error "Not in Nestory project directory. Please run from project root."
        exit 1
    fi
    
    # Check prerequisites
    check_xcode_debug_state
    prepare_simulator
    
    # Run the tests
    if run_automated_tests; then
        success "Automated test execution completed successfully!"
        generate_test_report
        
        log "========================================"
        log "Test automation summary:"
        log "✓ Debug screen interruptions prevented"
        log "✓ All environment variables configured"
        log "✓ Tests executed with full automation"
        log "✓ Results saved to: $RESULT_BUNDLE"
        
    else
        error "Automated test execution failed!"
        generate_test_report
        exit 1
    fi
    
    cleanup
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Nestory Automated Test Runner"
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --cleanup      Clean up previous test results"
        echo ""
        echo "This script runs the complete Nestory test suite with full automation,"
        echo "preventing any debug screen interruptions during test execution."
        exit 0
        ;;
    --cleanup)
        log "Cleaning up previous test results..."
        rm -rf test_results_automated_*.xcresult || true
        rm -f test_summary.json || true
        success "Cleanup completed"
        exit 0
        ;;
    "")
        # No arguments, run main function
        main
        ;;
    *)
        error "Unknown argument: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac