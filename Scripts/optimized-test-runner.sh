#!/bin/bash

#
# Scripts/optimized-test-runner.sh
# Purpose: Parallelized test execution with performance optimizations
# Part of Testing Optimization Report - Cycle 4 Implementation
#

set -euo pipefail

# Configuration
SCHEME="Nestory-Dev"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro Max,OS=18.6"
TIMEOUT_PER_BATCH=120  # 2 minutes per batch instead of 27 minutes total
MAX_PARALLEL=3         # Run 3 test batches in parallel
RESULT_DIR="./test_results_optimized"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Optimized Test Runner - Cycle 4${NC}"
echo -e "${YELLOW}Target: Reduce 27-minute execution to under 8 minutes${NC}"

# Create results directory
mkdir -p "$RESULT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Define test batches for parallelization
UNIT_TESTS=(
    "NestoryTests/CategoryModelTests"
    "NestoryTests/ItemModelTests" 
    "NestoryTests/WarrantyModelTests"
    "NestoryTests/CloudKitSyncTests"
    "NestoryTests/DataMigrationTests"
)

FEATURE_TESTS=(
    "NestoryTests/SearchFeatureTests"
    "NestoryTests/ItemDetailFeatureTests"
    "NestoryTests/ItemEditFeatureTests"
    "NestoryTests/DamageAssessmentFeatureTests"
)

PERFORMANCE_TESTS=(
    "NestoryTests/XPerformanceTests"
    "NestoryTests/OCRPerformanceTests"
    "NestoryTests/InsuranceReportPerformanceTests"
    "NestoryTests/UIResponsivenessTests"
    "NestoryTests/PerformanceTests"
)

INTEGRATION_TESTS=(
    "NestoryTests/InsuranceWorkflowIntegrationTests"
    "NestoryTests/CrossPlatformTests"
    "NestoryTests/ErrorRecoveryTests"
    "NestoryTests/UserJourneyTests"
    "NestoryTests/InsuranceTestScenarios"
    "NestoryTests/NetworkTests"
)

# Function to run a test batch with timeout and error handling
run_test_batch() {
    local batch_name=$1
    local tests_array_name=$2[@]
    local tests=("${!tests_array_name}")
    local batch_result_file="$RESULT_DIR/${batch_name}_${TIMESTAMP}.xcresult"
    local batch_log_file="$RESULT_DIR/${batch_name}_${TIMESTAMP}.log"
    
    echo -e "${BLUE}📋 Starting $batch_name batch (${#tests[@]} test targets)${NC}"
    
    # Build test list for only-testing flags
    local test_flags=""
    for test in "${tests[@]}"; do
        test_flags+=" -only-testing:$test"
    done
    
    # Run the batch with timeout protection
    local start_time=$(date +%s)
    
    if timeout ${TIMEOUT_PER_BATCH}s xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -enableCodeCoverage NO \
        -resultBundlePath "$batch_result_file" \
        -quiet \
        $test_flags \
        2>&1 > "$batch_log_file"; then
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo -e "${GREEN}✅ $batch_name completed successfully in ${duration}s${NC}"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo -e "${RED}❌ $batch_name failed or timed out after ${duration}s${NC}"
        
        # Log the last few lines of output for debugging
        echo -e "${YELLOW}Last 5 lines of $batch_name output:${NC}"
        tail -5 "$batch_log_file" 2>/dev/null || echo "No output available"
        return 1
    fi
}

# Function to run batches in parallel
run_parallel_batches() {
    local pids=()
    local results=()
    
    # Start all batches in background
    echo -e "${BLUE}🔄 Starting parallel test execution...${NC}"
    
    # Unit tests - fastest, run first
    run_test_batch "unit" UNIT_TESTS &
    pids[0]=$!
    
    # Feature tests - medium complexity
    run_test_batch "features" FEATURE_TESTS &
    pids[1]=$!
    
    # Performance tests - known bottleneck, run separately with extended timeout
    echo -e "${YELLOW}⚡ Starting performance tests with extended timeout...${NC}"
    TIMEOUT_PER_BATCH=180 run_test_batch "performance" PERFORMANCE_TESTS &
    pids[2]=$!
    
    # Integration tests - longest running, start early
    run_test_batch "integration" INTEGRATION_TESTS &
    pids[3]=$!
    
    # Wait for all batches to complete
    echo -e "${BLUE}⏳ Waiting for all test batches to complete...${NC}"
    
    local overall_success=0
    for i in "${!pids[@]}"; do
        local pid=${pids[$i]}
        if wait $pid; then
            results[$i]="SUCCESS"
            echo -e "${GREEN}✅ Batch $i completed successfully${NC}"
        else
            results[$i]="FAILED"
            echo -e "${RED}❌ Batch $i failed${NC}"
            overall_success=1
        fi
    done
    
    return $overall_success
}

# Function to analyze results and generate report
analyze_results() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - script_start_time))
    
    echo -e "${BLUE}📊 Test Execution Analysis${NC}"
    echo "==============================="
    echo "Total execution time: ${total_duration}s ($(echo "scale=2; $total_duration/60" | bc)m)"
    echo "Target was: < 8 minutes (480s)"
    
    if [ $total_duration -lt 480 ]; then
        echo -e "${GREEN}🎯 SUCCESS: Achieved performance target!${NC}"
        PERFORMANCE_IMPROVEMENT="SUCCESS"
    else
        echo -e "${YELLOW}⚠️  Still above target, but improved from 27 minutes${NC}"
        PERFORMANCE_IMPROVEMENT="PARTIAL"
    fi
    
    # Count result files
    local result_files=$(find "$RESULT_DIR" -name "*.xcresult" | wc -l)
    echo "Generated result bundles: $result_files"
    
    # Log file analysis
    echo -e "\n${BLUE}📋 Batch Results Summary:${NC}"
    for log_file in "$RESULT_DIR"/*.log; do
        if [[ -f "$log_file" ]]; then
            local batch_name=$(basename "$log_file" | cut -d'_' -f1)
            local file_size=$(wc -l < "$log_file" 2>/dev/null || echo "0")
            echo "  $batch_name: $file_size lines of output"
        fi
    done
}

# Main execution
main() {
    local script_start_time=$(date +%s)
    
    echo -e "${BLUE}🏁 Starting optimized test execution at $(date)${NC}"
    
    # Pre-flight check
    if ! xcrun simctl list devices | grep -q "iPhone 16 Pro Max.*Booted"; then
        echo -e "${YELLOW}📱 Booting iPhone 16 Pro Max simulator...${NC}"
        xcrun simctl boot "iPhone 16 Pro Max" 2>/dev/null || true
        sleep 5
    fi
    
    # Run parallel test batches
    if run_parallel_batches; then
        echo -e "${GREEN}🎉 All test batches completed!${NC}"
        analyze_results
        exit 0
    else
        echo -e "${RED}💥 Some test batches failed${NC}"
        analyze_results
        exit 1
    fi
}

# Export variables for use in analyze_results
script_start_time=$(date +%s)

# Run main function
main "$@"