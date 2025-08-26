#!/bin/bash

#
# Safe xcodebuild wrapper with stuck detection and auto-recovery
# Features:
# - Timeout handling with configurable limits
# - Stuck build detection (no output for X seconds)
# - Automatic process termination and cleanup
# - Metrics collection for stuck/timeout events
# - Graceful degradation and recovery
#

set -euo pipefail

# Configuration
MAX_BUILD_TIME=${MAX_BUILD_TIME:-600}  # 10 minutes default
STUCK_THRESHOLD=${STUCK_THRESHOLD:-60}  # 60 seconds without output = stuck
CHECK_INTERVAL=5  # Check every 5 seconds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🛡️  Safe Xcode Build with Stuck Detection${NC}"
echo "============================================"
echo "Max build time: ${MAX_BUILD_TIME}s"
echo "Stuck threshold: ${STUCK_THRESHOLD}s without output"
echo ""

# Parse arguments
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

# Setup
export BUILD_START_TIME=$(date +%s)
BUILD_LOG="/tmp/xcodebuild-$(date +%Y%m%d-%H%M%S).log"
MONITOR_LOG="/tmp/xcodebuild-monitor-$(date +%Y%m%d-%H%M%S).log"
PID_FILE="/tmp/xcodebuild-$(date +%Y%m%d-%H%M%S).pid"
LAST_OUTPUT_FILE="/tmp/xcodebuild-last-output.timestamp"

# Export for metrics
export SCHEME_NAME="${SCHEME:-Nestory-Dev}"
export CONFIGURATION
export BUILD_LOG_PATH="$BUILD_LOG"

echo -e "${YELLOW}Building: $SCHEME_NAME ($CONFIGURATION)${NC}"
echo "Build log: $BUILD_LOG"
echo "Monitor log: $MONITOR_LOG"
echo ""

# Function to cleanup
cleanup() {
    local exit_code=$1
    local reason=$2
    
    echo -e "\n${MAGENTA}🧹 Cleanup: $reason${NC}" | tee -a "$MONITOR_LOG"
    
    # Kill xcodebuild if still running
    if [ -f "$PID_FILE" ]; then
        local xcode_pid=$(cat "$PID_FILE")
        if kill -0 "$xcode_pid" 2>/dev/null; then
            echo "Terminating xcodebuild (PID: $xcode_pid)..." | tee -a "$MONITOR_LOG"
            kill -TERM "$xcode_pid" 2>/dev/null || true
            sleep 2
            kill -KILL "$xcode_pid" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    fi
    
    # Kill any orphaned xcodebuild processes
    pkill -f "xcodebuild.*$SCHEME_NAME" 2>/dev/null || true
    
    # Calculate duration
    local duration=$(($(date +%s) - BUILD_START_TIME))
    
    # Push metrics about the stuck/timeout event
    if [[ "$reason" == *"stuck"* ]] || [[ "$reason" == *"timeout"* ]]; then
        echo -e "${YELLOW}📊 Pushing stuck/timeout metrics...${NC}"
        cat <<EOF | curl -s --data-binary @- http://localhost:9091/metrics/job/nestory_build/instance/stuck_detection
# HELP nestory_build_stuck_total Number of stuck builds detected
# TYPE nestory_build_stuck_total counter
nestory_build_stuck_total{scheme="$SCHEME_NAME",configuration="$CONFIGURATION",reason="$reason"} 1

# HELP nestory_build_timeout_total Number of build timeouts
# TYPE nestory_build_timeout_total counter
nestory_build_timeout_total{scheme="$SCHEME_NAME",configuration="$CONFIGURATION"} 1

# HELP nestory_build_stuck_duration_seconds Duration before stuck detection
# TYPE nestory_build_stuck_duration_seconds gauge
nestory_build_stuck_duration_seconds{scheme="$SCHEME_NAME"} $duration
EOF
    fi
    
    # Cleanup temp files
    rm -f "$LAST_OUTPUT_FILE"
    
    exit $exit_code
}

# Function to monitor build progress
monitor_build() {
    local xcode_pid=$1
    local last_output_time=$(date +%s)
    local last_line_count=0
    
    echo "$(date +%s)" > "$LAST_OUTPUT_FILE"
    
    echo "Starting build monitor for PID: $xcode_pid" >> "$MONITOR_LOG"
    
    while kill -0 "$xcode_pid" 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - BUILD_START_TIME))
        local current_line_count=$(wc -l < "$BUILD_LOG" 2>/dev/null || echo 0)
        
        # Check if build log is growing
        if [ "$current_line_count" -gt "$last_line_count" ]; then
            last_output_time=$current_time
            echo "$current_time" > "$LAST_OUTPUT_FILE"
            last_line_count=$current_line_count
            echo "[$(date)] Build active - lines: $current_line_count, elapsed: ${elapsed}s" >> "$MONITOR_LOG"
        fi
        
        local time_since_output=$((current_time - last_output_time))
        
        # Check for stuck build
        if [ "$time_since_output" -gt "$STUCK_THRESHOLD" ]; then
            echo -e "\n${RED}⚠️  Build appears stuck! No output for ${time_since_output}s${NC}"
            echo "[$(date)] STUCK DETECTED - no output for ${time_since_output}s" >> "$MONITOR_LOG"
            
            # Try to diagnose the issue
            echo -e "${YELLOW}Diagnosing stuck build...${NC}"
            
            # Check system resources
            echo "System load: $(uptime)" >> "$MONITOR_LOG"
            echo "Disk space: $(df -h /)" >> "$MONITOR_LOG"
            
            # Check what xcodebuild is doing
            if command -v sample &> /dev/null; then
                echo "Sampling xcodebuild process..." >> "$MONITOR_LOG"
                sample "$xcode_pid" 3 2>&1 >> "$MONITOR_LOG" || true
            fi
            
            # Get last 10 lines of build log
            echo "Last build output:" >> "$MONITOR_LOG"
            tail -10 "$BUILD_LOG" >> "$MONITOR_LOG" 2>/dev/null || true
            
            cleanup 1 "stuck_detected_${time_since_output}s"
        fi
        
        # Check for timeout
        if [ "$elapsed" -gt "$MAX_BUILD_TIME" ]; then
            echo -e "\n${RED}⏱️  Build timeout! Exceeded ${MAX_BUILD_TIME}s${NC}"
            echo "[$(date)] TIMEOUT - exceeded ${MAX_BUILD_TIME}s" >> "$MONITOR_LOG"
            cleanup 1 "timeout_${elapsed}s"
        fi
        
        # Progress indicator
        if [ $((elapsed % 30)) -eq 0 ]; then
            echo -e "${BLUE}⏳ Build in progress... (${elapsed}s elapsed, ${current_line_count} lines)${NC}"
        fi
        
        sleep "$CHECK_INTERVAL"
    done
    
    echo "[$(date)] Build process completed" >> "$MONITOR_LOG"
}

# Start xcodebuild in background
echo -e "${GREEN}Starting xcodebuild...${NC}"
xcodebuild "$@" > "$BUILD_LOG" 2>&1 &
XCODE_PID=$!
echo "$XCODE_PID" > "$PID_FILE"

echo "xcodebuild PID: $XCODE_PID"

# Start monitoring in background
monitor_build "$XCODE_PID" &
MONITOR_PID=$!

echo "Monitor PID: $MONITOR_PID"
echo ""

# Tail the build log for user visibility
echo -e "${BLUE}Build output:${NC}"
echo "----------------------------------------"
tail -f "$BUILD_LOG" 2>/dev/null &
TAIL_PID=$!

# Wait for xcodebuild to complete
if wait "$XCODE_PID"; then
    XCODEBUILD_EXIT_CODE=0
    echo -e "\n${GREEN}✅ Build Successful${NC}"
else
    XCODEBUILD_EXIT_CODE=$?
    echo -e "\n${RED}❌ Build Failed (exit code: $XCODEBUILD_EXIT_CODE)${NC}"
fi

# Stop monitor and tail
kill "$MONITOR_PID" 2>/dev/null || true
kill "$TAIL_PID" 2>/dev/null || true

# Export exit code for metrics
export XCODEBUILD_EXIT_CODE

# Capture metrics
echo -e "\n${BLUE}📊 Capturing build metrics...${NC}"
"$(dirname "$0")/capture-build-metrics.sh"

# Parse and display summary
if [ -f "$BUILD_LOG" ]; then
    ERRORS=$(grep -c "error:" "$BUILD_LOG" 2>/dev/null || echo 0)
    WARNINGS=$(grep -c "warning:" "$BUILD_LOG" 2>/dev/null || echo 0)
    DURATION=$(($(date +%s) - BUILD_START_TIME))
    
    echo -e "\n${BLUE}Build Summary:${NC}"
    echo "  Errors: $ERRORS"
    echo "  Warnings: $WARNINGS"
    echo "  Duration: ${DURATION}s"
    echo "  Exit Code: $XCODEBUILD_EXIT_CODE"
    
    # Show errors if any
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "\n${RED}Build Errors:${NC}"
        grep "error:" "$BUILD_LOG" | head -10
    fi
fi

# Clean up
rm -f "$PID_FILE" "$LAST_OUTPUT_FILE"

# Clean up old logs (keep last 10)
find /tmp -name "xcodebuild-*.log" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true
find /tmp -name "xcodebuild-monitor-*.log" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true

echo -e "\n${GREEN}Monitor log saved to: $MONITOR_LOG${NC}"

exit $XCODEBUILD_EXIT_CODE