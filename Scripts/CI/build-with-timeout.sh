#!/bin/bash

#
# Best-practice build wrapper using GNU timeout and proper signal handling
# Follows industry standards for CI/CD build management
#

set -euo pipefail

# Default configuration
DEFAULT_TIMEOUT=${BUILD_TIMEOUT:-600}  # 10 minutes default
DEFAULT_KILL_TIMEOUT=${BUILD_KILL_TIMEOUT:-30}  # 30s grace period before SIGKILL

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to show usage
usage() {
    cat <<EOF
Usage: $0 [OPTIONS] -- [XCODEBUILD_ARGS]

Best-practice build wrapper with timeout and metrics.

Options:
    -t SECONDS    Build timeout in seconds (default: $DEFAULT_TIMEOUT)
    -k SECONDS    Kill timeout after SIGTERM (default: $DEFAULT_KILL_TIMEOUT)
    -m            Enable metrics collection
    -h            Show this help message

Examples:
    $0 -t 300 -- -scheme Nestory-Dev build
    $0 -m -- -workspace Nestory.xcworkspace -scheme Nestory-Dev test

Environment Variables:
    BUILD_TIMEOUT       Default timeout in seconds
    BUILD_KILL_TIMEOUT  Grace period before SIGKILL
    METRICS_ENDPOINT    Prometheus pushgateway URL (default: http://localhost:9091)
EOF
    exit 0
}

# Parse arguments
TIMEOUT=$DEFAULT_TIMEOUT
KILL_TIMEOUT=$DEFAULT_KILL_TIMEOUT
ENABLE_METRICS=false

while getopts "t:k:mh" opt; do
    case $opt in
        t) TIMEOUT="$OPTARG" ;;
        k) KILL_TIMEOUT="$OPTARG" ;;
        m) ENABLE_METRICS=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No xcodebuild arguments provided${NC}"
    usage
fi

# Setup
BUILD_START_TIME=$(date +%s)
BUILD_ID="build-$(date +%Y%m%d-%H%M%S)-$$"
BUILD_LOG="/tmp/${BUILD_ID}.log"
METRICS_FILE="/tmp/${BUILD_ID}.metrics"

# Parse xcodebuild args for scheme/configuration
SCHEME="Unknown"
CONFIGURATION="Debug"
prev_arg=""
for arg in "$@"; do
    if [[ "$prev_arg" == "-scheme" ]]; then
        SCHEME="$arg"
    elif [[ "$prev_arg" == "-configuration" ]]; then
        CONFIGURATION="$arg"
    fi
    prev_arg="$arg"
done

echo -e "${BLUE}🏗️  Build with Timeout Protection${NC}"
echo "====================================="
echo "Build ID: $BUILD_ID"
echo "Scheme: $SCHEME"
echo "Configuration: $CONFIGURATION"
echo "Timeout: ${TIMEOUT}s (kill after +${KILL_TIMEOUT}s)"
echo "Log: $BUILD_LOG"
echo ""

# Signal handler for cleanup
cleanup() {
    local signal=$1
    local exit_code=$2
    
    echo -e "\n${YELLOW}Cleanup triggered by: $signal${NC}"
    
    # Calculate metrics
    local duration=$(($(date +%s) - BUILD_START_TIME))
    local errors=$(grep -c "error:" "$BUILD_LOG" 2>/dev/null || echo 0)
    local warnings=$(grep -c "warning:" "$BUILD_LOG" 2>/dev/null || echo 0)
    
    # Push metrics if enabled
    if [ "$ENABLE_METRICS" = true ]; then
        push_metrics "$exit_code" "$duration" "$errors" "$warnings" "$signal"
    fi
    
    # Display summary
    echo -e "\n${BLUE}Build Summary:${NC}"
    echo "  Duration: ${duration}s"
    echo "  Errors: $errors"
    echo "  Warnings: $warnings"
    echo "  Exit: $exit_code ($signal)"
    
    # Show errors if any
    if [ "$errors" -gt 0 ]; then
        echo -e "\n${RED}First 5 errors:${NC}"
        grep "error:" "$BUILD_LOG" 2>/dev/null | head -5 || true
    fi
    
    exit "$exit_code"
}

# Function to push metrics
push_metrics() {
    local exit_code=$1
    local duration=$2
    local errors=$3
    local warnings=$4
    local termination_reason=$5
    local endpoint="${METRICS_ENDPOINT:-http://localhost:9091}"
    
    echo -e "${YELLOW}📊 Pushing metrics to $endpoint${NC}"
    
    cat <<EOF > "$METRICS_FILE"
# Build metrics for $BUILD_ID
nestory_build_duration_seconds{scheme="$SCHEME",configuration="$CONFIGURATION",status="$([ $exit_code -eq 0 ] && echo success || echo failed)"} $duration
nestory_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION"} $errors
nestory_build_warnings_total{scheme="$SCHEME",configuration="$CONFIGURATION"} $warnings
nestory_build_exit_code{scheme="$SCHEME",configuration="$CONFIGURATION"} $exit_code
nestory_build_termination_total{scheme="$SCHEME",reason="$termination_reason"} 1
EOF
    
    if curl -s --data-binary @"$METRICS_FILE" "$endpoint/metrics/job/nestory_build/instance/$HOSTNAME" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Metrics pushed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Failed to push metrics (non-critical)${NC}"
    fi
    
    rm -f "$METRICS_FILE"
}

# Trap signals for proper cleanup
trap 'cleanup "SIGINT" 130' INT
trap 'cleanup "SIGTERM" 143' TERM
trap 'cleanup "SIGQUIT" 131' QUIT

# Use GNU timeout with proper signal handling
# -k: send SIGKILL after additional timeout
# --preserve-status: exit with same code as command
# --foreground: run in foreground to allow interaction
echo -e "${GREEN}Starting build with timeout protection...${NC}\n"

if command -v gtimeout &> /dev/null; then
    # macOS with GNU coreutils installed
    TIMEOUT_CMD="gtimeout"
elif command -v timeout &> /dev/null; then
    # Linux or macOS with timeout available
    TIMEOUT_CMD="timeout"
else
    echo -e "${RED}Error: 'timeout' command not found. Install GNU coreutils.${NC}"
    echo "Run: brew install coreutils"
    exit 1
fi

# Execute build with timeout
set +e
$TIMEOUT_CMD \
    --kill-after="$KILL_TIMEOUT" \
    --preserve-status \
    --foreground \
    "$TIMEOUT" \
    xcodebuild "$@" 2>&1 | tee "$BUILD_LOG"

EXIT_CODE=${PIPESTATUS[0]}
set -e

# Determine termination reason
if [ $EXIT_CODE -eq 124 ]; then
    echo -e "\n${RED}⏱️  Build timed out after ${TIMEOUT}s${NC}"
    cleanup "timeout" $EXIT_CODE
elif [ $EXIT_CODE -eq 137 ]; then
    echo -e "\n${RED}☠️  Build killed (SIGKILL) after timeout + ${KILL_TIMEOUT}s${NC}"
    cleanup "killed" $EXIT_CODE
elif [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}✅ Build completed successfully${NC}"
    cleanup "success" 0
else
    echo -e "\n${RED}❌ Build failed with exit code: $EXIT_CODE${NC}"
    cleanup "failed" $EXIT_CODE
fi