#!/bin/bash

#
# xcodebuild wrapper that automatically captures metrics
# Use this instead of direct xcodebuild for metric collection
#

set -Eeuo pipefail
IFS=$'\n\t'
trap 'echo "❌ ${BASH_SOURCE[0]} failed at line $LINENO: $BASH_COMMAND" >&2' ERR

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔨 Xcode Build with Metrics Collection${NC}"
echo "========================================="

# Start timer
export BUILD_START_TIME=$(date +%s)
BUILD_LOG="/tmp/xcodebuild-$(date +%Y%m%d-%H%M%S).log"

# Parse xcodebuild arguments to extract scheme and configuration
SCHEME=""
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

# Export for metrics script
export SCHEME_NAME="${SCHEME:-Nestory-Dev}"
export CONFIGURATION
export BUILD_LOG_PATH="$BUILD_LOG"

echo -e "${YELLOW}Building: $SCHEME_NAME ($CONFIGURATION)${NC}"
echo "Log: $BUILD_LOG"
echo ""

# Run xcodebuild and capture output
if xcodebuild "$@" 2>&1 | tee "$BUILD_LOG"; then
    XCODEBUILD_EXIT_CODE=0
    echo -e "\n${GREEN}✅ Build Successful${NC}"
else
    XCODEBUILD_EXIT_CODE=$?
    echo -e "\n${RED}❌ Build Failed (exit code: $XCODEBUILD_EXIT_CODE)${NC}"
    
    # Extract and display errors
    echo -e "\n${RED}Build Errors:${NC}"
    grep "error:" "$BUILD_LOG" | head -10 || echo "No specific errors captured"
fi

# Export exit code for metrics
export XCODEBUILD_EXIT_CODE

# Capture metrics
echo -e "\n${BLUE}📊 Capturing build metrics...${NC}"
"$(dirname "$0")/capture-build-metrics.sh"

# Parse and display summary
if [ -f "$BUILD_LOG" ]; then
    ERRORS=$(grep -c "error:" "$BUILD_LOG" 2>/dev/null || echo 0)
    WARNINGS=$(grep -c "warning:" "$BUILD_LOG" 2>/dev/null || echo 0)
    
    echo -e "\n${BLUE}Build Summary:${NC}"
    echo "  Errors: $ERRORS"
    echo "  Warnings: $WARNINGS"
    echo "  Duration: $(($(date +%s) - BUILD_START_TIME))s"
fi

# Clean up old logs (keep last 10)
find /tmp -name "xcodebuild-*.log" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true

exit $XCODEBUILD_EXIT_CODE