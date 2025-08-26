#!/bin/bash

#
# Test script for stuck build detection and auto-recovery
# Simulates a hung build to verify the monitoring system works
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Stuck Build Detection System${NC}"
echo "======================================"

# Function to simulate a stuck build
simulate_stuck_build() {
    echo -e "${YELLOW}Simulating stuck build process...${NC}"
    
    # Create a fake xcodebuild process that will hang
    cat <<'EOF' > /tmp/fake_xcodebuild.sh
#!/bin/bash
echo "Started fake xcodebuild process (PID: $$)"
echo "Scheme: TestStuckBuild"
# Create a fake build log that stops updating
echo "Build started..." > /tmp/fake_build.log
sleep 10
echo "Some build output..." >> /tmp/fake_build.log
sleep 10
echo "Last output before hang..." >> /tmp/fake_build.log
# Now hang indefinitely without writing to log
while true; do sleep 60; done
EOF
    chmod +x /tmp/fake_xcodebuild.sh
    
    # Start the fake process in background
    nohup /tmp/fake_xcodebuild.sh > /dev/null 2>&1 &
    FAKE_PID=$!
    echo "Started fake stuck build process: PID $FAKE_PID"
    
    # Rename the process to look like xcodebuild
    # (This is a simulation - in real scenarios it would be actual xcodebuild)
    echo "$FAKE_PID" > /tmp/test_stuck_build.pid
    
    return $FAKE_PID
}

# Function to check if stuck detection works
check_stuck_detection() {
    local test_duration=180  # 3 minutes
    local check_interval=30  # Check every 30 seconds
    local checks_performed=0
    local max_checks=$((test_duration / check_interval))
    
    echo -e "${BLUE}Monitoring for stuck build detection...${NC}"
    echo "Test duration: ${test_duration}s"
    echo "Will perform ${max_checks} checks"
    
    while [ $checks_performed -lt $max_checks ]; do
        sleep $check_interval
        checks_performed=$((checks_performed + 1))
        
        echo -e "${YELLOW}Check $checks_performed/$max_checks${NC}"
        
        # Check if stuck build metrics were generated
        local stuck_metrics=$(curl -s http://localhost:9091/metrics | grep "nestory_build_stuck_detected" | wc -l)
        local recovery_metrics=$(curl -s http://localhost:9091/metrics | grep "nestory_build_auto_recovery_total" | wc -l)
        
        echo "  Stuck metrics: $stuck_metrics"
        echo "  Recovery metrics: $recovery_metrics"
        
        if [ "$stuck_metrics" -gt 0 ]; then
            echo -e "${GREEN}✅ Stuck build detection metrics found!${NC}"
            return 0
        fi
        
        # Check health monitor logs for stuck detection
        if tail -50 /tmp/build-health-monitor.log 2>/dev/null | grep -q "stuck build"; then
            echo -e "${GREEN}✅ Stuck build detection logged!${NC}"
            return 0
        fi
    done
    
    echo -e "${RED}❌ No stuck build detection after ${test_duration}s${NC}"
    return 1
}

# Function to cleanup test
cleanup_test() {
    echo -e "${BLUE}Cleaning up test...${NC}"
    
    # Kill fake process if still running
    if [ -f /tmp/test_stuck_build.pid ]; then
        local fake_pid=$(cat /tmp/test_stuck_build.pid)
        kill -TERM "$fake_pid" 2>/dev/null || true
        kill -KILL "$fake_pid" 2>/dev/null || true
        rm -f /tmp/test_stuck_build.pid
    fi
    
    # Cleanup test files
    rm -f /tmp/fake_xcodebuild.sh /tmp/fake_build.log
    
    echo "✅ Cleanup completed"
}

# Trap to ensure cleanup on exit
trap cleanup_test EXIT

# Main test sequence
echo -e "${YELLOW}Starting stuck build detection test...${NC}"

# Verify health monitor is running
if ! ps aux | grep -E "build-health-monitor.*monitor" | grep -v grep > /dev/null; then
    echo -e "${RED}❌ Health monitor is not running!${NC}"
    echo "Start it with: Scripts/CI/build-health-monitor.sh monitor &"
    exit 1
fi

echo -e "${GREEN}✅ Health monitor is running${NC}"

# Show current metrics baseline
echo -e "${BLUE}Current metrics baseline:${NC}"
curl -s http://localhost:9091/metrics | grep -E "(stuck|recovery|concurrent)" | head -5

# Start the test
simulate_stuck_build
FAKE_PID=$?

# Monitor for detection
if check_stuck_detection; then
    echo -e "${GREEN}🎉 STUCK BUILD DETECTION TEST PASSED!${NC}"
    echo -e "${GREEN}The monitoring system successfully detected the stuck build${NC}"
    
    # Show final metrics
    echo -e "${BLUE}Final metrics:${NC}"
    curl -s http://localhost:9091/metrics | grep -E "(stuck|recovery|concurrent)"
    
    exit 0
else
    echo -e "${RED}❌ STUCK BUILD DETECTION TEST FAILED${NC}"
    echo -e "${RED}The monitoring system did not detect the stuck build${NC}"
    
    # Show diagnostic info
    echo -e "${YELLOW}Diagnostic information:${NC}"
    echo "Health monitor status:"
    ps aux | grep build-health-monitor | grep -v grep || echo "Not running"
    
    echo "Recent health monitor logs:"
    tail -20 /tmp/build-health-monitor.log 2>/dev/null || echo "No logs found"
    
    exit 1
fi