#!/bin/bash

# Push CI/CD metrics to Prometheus Pushgateway
# Called from GitHub Actions workflows

set -e

# Configuration
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://192.168.1.5:9091}"
JOB_NAME="${GITHUB_WORKFLOW:-local}"
INSTANCE="${GITHUB_RUN_ID:-$(date +%s)}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to push a metric
push_metric() {
    local metric_name=$1
    local metric_value=$2
    local metric_type=${3:-gauge}
    local labels=${4:-""}
    
    local data="# TYPE ${metric_name} ${metric_type}\n"
    
    if [ -n "$labels" ]; then
        data+="${metric_name}{${labels}} ${metric_value}"
    else
        data+="${metric_name} ${metric_value}"
    fi
    
    echo -e "$data" | curl -s --data-binary @- \
        "${PUSHGATEWAY_URL}/metrics/job/${JOB_NAME}/instance/${INSTANCE}" \
        || echo -e "${YELLOW}Warning: Failed to push metric ${metric_name}${NC}"
}

# Function to push build metrics
push_build_metrics() {
    local build_status=$1
    local build_duration=$2
    local cache_hit=$3
    
    echo -e "${GREEN}📊 Pushing build metrics...${NC}"
    
    # Matrix-aware labels
    local matrix_labels=""
    if [ -n "$SCHEME" ] && [ -n "$CONFIGURATION" ]; then
        matrix_labels="scheme=\"${SCHEME}\",configuration=\"${CONFIGURATION}\""
        
        # Add device label if available
        if [ -n "$DEVICE" ]; then
            matrix_labels="${matrix_labels},device=\"${DEVICE}\""
        fi
        
        # Add cache information
        matrix_labels="${matrix_labels},cached=\"${cache_hit:-false}\""
        
        # Add matrix build indicator
        matrix_labels="${matrix_labels},matrix_build=\"true\""
    else
        # Legacy single build format
        matrix_labels="scheme=\"${SCHEME:-Nestory-Dev}\",configuration=\"${CONFIGURATION:-Debug}\",cached=\"${cache_hit:-false}\",matrix_build=\"false\""
    fi
    
    # Build duration
    if [ -n "$build_duration" ]; then
        push_metric "nestory_build_duration_seconds" "$build_duration" "gauge" "$matrix_labels"
    fi
    
    # Build result
    if [ "$build_status" = "success" ] || [ "$build_status" = "true" ]; then
        push_metric "nestory_build_success_total" "1" "counter" "$matrix_labels"
    else
        local failure_labels="${matrix_labels},reason=\"${BUILD_FAILURE_REASON:-unknown}\""
        push_metric "nestory_build_failure_total" "1" "counter" "$failure_labels"
    fi
}

# Function to push test metrics
push_test_metrics() {
    local tests_passed=$1
    local tests_failed=$2
    local test_duration=$3
    local coverage=$4
    
    echo -e "${GREEN}📊 Pushing test metrics...${NC}"
    
    # Matrix-aware test labels
    local test_labels="test_suite=\"${TEST_SUITE:-Unit}\""
    if [ -n "$SCHEME" ]; then
        test_labels="${test_labels},scheme=\"${SCHEME}\""
    fi
    if [ -n "$CONFIGURATION" ]; then
        test_labels="${test_labels},configuration=\"${CONFIGURATION}\""
    fi
    if [ -n "$DEVICE_TYPE" ]; then
        test_labels="${test_labels},device_type=\"${DEVICE_TYPE:-Simulator}\""
    fi
    if [ -n "$DEVICE" ]; then
        test_labels="${test_labels},device=\"${DEVICE}\""
    fi
    
    # Test results
    if [ -n "$tests_passed" ]; then
        push_metric "nestory_tests_passed_total" "$tests_passed" "counter" "$test_labels"
    fi
    
    if [ -n "$tests_failed" ] && [ "$tests_failed" -gt 0 ]; then
        local failure_labels="${test_labels},reason=\"${TEST_FAILURE_REASON:-assertion}\""
        push_metric "nestory_tests_failed_total" "$tests_failed" "counter" "$failure_labels"
    fi
    
    # Test duration
    if [ -n "$test_duration" ]; then
        push_metric "nestory_test_duration_seconds" "$test_duration" "gauge" "$test_labels"
    fi
    
    # Coverage (matrix-aware)
    if [ -n "$coverage" ]; then
        local coverage_labels="module=\"${MODULE:-Overall}\""
        if [ -n "$SCHEME" ]; then
            coverage_labels="${coverage_labels},scheme=\"${SCHEME}\""
        fi
        push_metric "nestory_test_coverage_percent" "$coverage" "gauge" "$coverage_labels"
    fi
}

# Function to push parallel test execution metrics
push_parallel_test_metrics() {
    local simulator_type=$1
    local device_name=$2
    local tests_passed=$3
    local tests_failed=$4
    local duration=$5
    local estimated_duration=$6
    
    echo -e "${GREEN}📊 Pushing parallel test metrics for $simulator_type...${NC}"
    
    # Parallel test labels
    local parallel_labels="simulator_type=\"${simulator_type}\",device=\"${device_name}\",parallel=\"true\""
    
    # Test execution metrics
    if [ -n "$duration" ]; then
        push_metric "nestory_parallel_test_duration_seconds" "$duration" "gauge" "$parallel_labels"
    fi
    
    if [ -n "$estimated_duration" ]; then
        push_metric "nestory_parallel_test_estimated_seconds" "$estimated_duration" "gauge" "$parallel_labels"
        
        # Calculate accuracy of estimation
        if [ -n "$duration" ] && [ "$estimated_duration" -gt 0 ]; then
            local accuracy=$(echo "scale=2; (1 - (($duration - $estimated_duration) / $estimated_duration)) * 100" | bc -l 2>/dev/null || echo 0)
            push_metric "nestory_parallel_test_estimation_accuracy_percent" "$accuracy" "gauge" "$parallel_labels"
        fi
    fi
    
    # Test results
    if [ -n "$tests_passed" ]; then
        push_metric "nestory_parallel_tests_passed_total" "$tests_passed" "counter" "$parallel_labels"
    fi
    
    if [ -n "$tests_failed" ] && [ "$tests_failed" -gt 0 ]; then
        push_metric "nestory_parallel_tests_failed_total" "$tests_failed" "counter" "$parallel_labels"
    fi
    
    # Success rate
    if [ -n "$tests_passed" ] && [ -n "$tests_failed" ]; then
        local total_tests=$((tests_passed + tests_failed))
        if [ "$total_tests" -gt 0 ]; then
            local success_rate=$(echo "scale=2; ($tests_passed / $total_tests) * 100" | bc -l 2>/dev/null || echo 0)
            push_metric "nestory_parallel_test_success_rate_percent" "$success_rate" "gauge" "$parallel_labels"
        fi
    fi
}

# Function to push performance metrics
push_performance_metrics() {
    local cold_start_ms=$1
    local memory_mb=$2
    local scroll_jank=$3
    
    echo -e "${GREEN}📊 Pushing performance metrics...${NC}"
    
    if [ -n "$cold_start_ms" ]; then
        push_metric "nestory_app_cold_start_ms" "$cold_start_ms" "gauge" \
            "device=\"${DEVICE:-iPhone 16 Pro Max}\",ios_version=\"${IOS_VERSION:-18.0}\""
    fi
    
    if [ -n "$memory_mb" ]; then
        push_metric "nestory_app_memory_mb" "$memory_mb" "gauge" \
            "scenario=\"${SCENARIO:-default}\",device=\"${DEVICE:-iPhone 16 Pro Max}\""
    fi
    
    if [ -n "$scroll_jank" ]; then
        push_metric "nestory_scroll_jank_percent" "$scroll_jank" "gauge" \
            "view=\"${VIEW:-InventoryView}\",device=\"${DEVICE:-iPhone 16 Pro Max}\""
    fi
}

# Function to push cache metrics
push_cache_metrics() {
    local cache_size=$1
    local cache_hit_rate=$2
    local cache_age_hours=$3
    
    echo -e "${GREEN}📊 Pushing cache metrics...${NC}"
    
    if [ -n "$cache_size" ]; then
        push_metric "nestory_cache_size_bytes" "$cache_size" "gauge" "cache_type=\"${CACHE_TYPE:-DerivedData}\""
    fi
    
    if [ -n "$cache_hit_rate" ]; then
        push_metric "nestory_cache_hit_rate" "$cache_hit_rate" "gauge" "cache_type=\"${CACHE_TYPE:-Overall}\""
    fi
    
    if [ -n "$cache_age_hours" ]; then
        push_metric "nestory_cache_age_hours" "$cache_age_hours" "gauge" "cache_type=\"${CACHE_TYPE:-DerivedData}\""
    fi
}

# Function to push pipeline metrics
push_pipeline_metrics() {
    local pipeline_duration=$1
    local queue_time=$2
    local artifact_size=$3
    
    echo -e "${GREEN}📊 Pushing pipeline metrics...${NC}"
    
    if [ -n "$pipeline_duration" ]; then
        push_metric "nestory_pipeline_duration_seconds" "$pipeline_duration" "gauge" \
            "workflow=\"${GITHUB_WORKFLOW:-unknown}\",trigger=\"${GITHUB_EVENT_NAME:-unknown}\""
    fi
    
    if [ -n "$queue_time" ]; then
        push_metric "nestory_pipeline_queue_seconds" "$queue_time" "gauge" "runner=\"${RUNNER_NAME:-unknown}\""
    fi
    
    if [ -n "$artifact_size" ]; then
        push_metric "nestory_artifact_size_bytes" "$artifact_size" "gauge" "artifact_type=\"${ARTIFACT_TYPE:-unknown}\""
    fi
}

# Function to extract metrics from Xcode test results
extract_xcode_metrics() {
    local xcresult_path=$1
    
    if [ -f "$xcresult_path" ]; then
        echo -e "${GREEN}📊 Extracting metrics from ${xcresult_path}...${NC}"
        
        # Extract test metrics
        xcrun xcresulttool get --path "$xcresult_path" --format json > /tmp/test_results.json
        
        # Parse results
        local tests_passed=$(jq '.metrics.testsCount - .metrics.testsFailedCount' /tmp/test_results.json 2>/dev/null || echo 0)
        local tests_failed=$(jq '.metrics.testsFailedCount' /tmp/test_results.json 2>/dev/null || echo 0)
        local test_duration=$(jq '.metrics.duration' /tmp/test_results.json 2>/dev/null || echo 0)
        
        # Push metrics
        push_test_metrics "$tests_passed" "$tests_failed" "$test_duration" ""
        
        rm -f /tmp/test_results.json
    fi
}

# Function to calculate cache metrics
calculate_cache_metrics() {
    local derived_data="$HOME/Library/Developer/Xcode/DerivedData"
    
    echo -e "${GREEN}📊 Calculating cache metrics...${NC}"
    
    # Cache size
    if [ -d "$derived_data" ]; then
        local cache_size=$(du -sb "$derived_data" 2>/dev/null | cut -f1 || echo 0)
        push_cache_metrics "$cache_size" "" ""
    fi
    
    # Cache age
    local nestory_cache=$(find "$derived_data" -name "Nestory-*" -maxdepth 1 -type d 2>/dev/null | head -1)
    if [ -n "$nestory_cache" ]; then
        local modification_time=$(stat -f %m "$nestory_cache" 2>/dev/null || date +%s)
        local current_time=$(date +%s)
        local age_hours=$(( ($current_time - $modification_time) / 3600 ))
        push_cache_metrics "" "" "$age_hours"
    fi
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Nestory Metrics Push Script${NC}"
    echo "================================"
    echo "Pushgateway: $PUSHGATEWAY_URL"
    echo "Job: $JOB_NAME"
    echo "Instance: $INSTANCE"
    echo ""
    
    # Parse command line arguments
    case "${1:-all}" in
        build)
            push_build_metrics "${2:-success}" "${3:-0}" "${4:-false}"
            ;;
        test)
            push_test_metrics "${2:-0}" "${3:-0}" "${4:-0}" "${5:-0}"
            ;;
        parallel)
            push_parallel_test_metrics "${2}" "${3}" "${4:-0}" "${5:-0}" "${6:-0}" "${7:-0}"
            ;;
        performance)
            push_performance_metrics "${2:-0}" "${3:-0}" "${4:-0}"
            ;;
        cache)
            calculate_cache_metrics
            ;;
        pipeline)
            push_pipeline_metrics "${2:-0}" "${3:-0}" "${4:-0}"
            ;;
        xcresult)
            extract_xcode_metrics "${2}"
            ;;
        all)
            # Push all available metrics
            calculate_cache_metrics
            ;;
        *)
            echo "Usage: $0 [build|test|parallel|performance|cache|pipeline|xcresult|all] [args...]"
            echo ""
            echo "Commands:"
            echo "  build <status> <duration> <cache_hit>            Push build metrics"
            echo "  test <passed> <failed> <duration> <coverage>     Push test metrics"  
            echo "  parallel <type> <device> <passed> <failed> <duration> <estimated>  Push parallel test metrics"
            echo "  performance <cold_start> <memory> <jank>         Push performance metrics"
            echo "  cache                                             Calculate and push cache metrics"
            echo "  pipeline <duration> <queue_time> <artifact_size> Push pipeline metrics"
            echo "  xcresult <path>                                   Extract metrics from xcresult"
            echo "  all                                               Push all available metrics"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Metrics pushed successfully${NC}"
}

# Run main function
main "$@"