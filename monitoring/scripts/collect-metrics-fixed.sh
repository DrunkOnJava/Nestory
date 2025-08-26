#!/bin/bash

#
# Fixed Metrics Collection using Node Exporter Textfile Collector
# Replaces Pushgateway HTTP push with filesystem-based metrics collection
# Follows Prometheus best practices: https://prometheus.io/docs/practices/pushing/
#

set -euo pipefail

# Configuration - Node Exporter textfile directory
TEXTFILE_DIR="${TEXTFILE_DIR:-$HOME/metrics/textfile}"
JOB_NAME="${GITHUB_WORKFLOW:-local}"
INSTANCE="${GITHUB_RUN_ID:-$(date +%s)}"

# Ensure textfile directory exists
mkdir -p "$TEXTFILE_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to write a metric to textfile (atomic operation)
write_metric() {
    local metric_name=$1
    local metric_value=$2
    local metric_type=${3:-gauge}
    local labels=${4:-""}
    local help_text=${5:-"$metric_name metric"}
    local file_name=$6
    
    local temp_file="${TEXTFILE_DIR}/${file_name}.prom.$$"
    
    # Start with HELP and TYPE comments
    echo "# HELP $metric_name $help_text" > "$temp_file"
    echo "# TYPE $metric_name $metric_type" >> "$temp_file"
    
    # Add the metric with labels
    if [ -n "$labels" ]; then
        echo "${metric_name}{${labels}} ${metric_value}" >> "$temp_file"
    else
        echo "${metric_name} ${metric_value}" >> "$temp_file"
    fi
    
    # Atomic move to final location
    mv "$temp_file" "${TEXTFILE_DIR}/${file_name}.prom"
}

# Function to append metrics to existing file (for multiple metrics of same type)
append_metric() {
    local metric_name=$1
    local metric_value=$2
    local labels=${3:-""}
    local file_name=$4
    
    local target_file="${TEXTFILE_DIR}/${file_name}.prom"
    
    # Add the metric line (no HELP/TYPE needed for additional entries)
    if [ -n "$labels" ]; then
        echo "${metric_name}{${labels}} ${metric_value}" >> "$target_file"
    else
        echo "${metric_name} ${metric_value}" >> "$target_file"
    fi
}

# Function to collect build metrics
collect_build_metrics() {
    local build_status=$1
    local build_duration=$2
    local cache_hit=$3
    
    echo -e "${GREEN}📊 Collecting build metrics...${NC}"
    
    # Matrix-aware labels
    local matrix_labels=""
    if [ -n "${SCHEME:-}" ] && [ -n "${CONFIGURATION:-}" ]; then
        matrix_labels="scheme=\"${SCHEME}\",configuration=\"${CONFIGURATION}\""
        
        # Add device label if available
        if [ -n "${DEVICE:-}" ]; then
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
    
    # Create comprehensive build metrics file
    local temp_file="${TEXTFILE_DIR}/nestory_ci_build.prom.$$"
    
    cat <<EOF > "$temp_file"
# HELP nestory_build_duration_seconds Duration of CI build in seconds
# TYPE nestory_build_duration_seconds histogram
nestory_build_duration_seconds{$matrix_labels} $build_duration

# HELP nestory_build_termination_total Build termination reasons for SLO tracking
# TYPE nestory_build_termination_total counter
EOF
    
    # Add termination reason metrics
    if [ "$build_status" = "success" ] || [ "$build_status" = "true" ]; then
        echo "nestory_build_termination_total{reason=\"success\",$matrix_labels} 1" >> "$temp_file"
    else
        echo "nestory_build_termination_total{reason=\"failure\",$matrix_labels} 1" >> "$temp_file"
        if [ -n "${BUILD_FAILURE_REASON:-}" ]; then
            echo "nestory_build_termination_total{reason=\"${BUILD_FAILURE_REASON}\",$matrix_labels} 1" >> "$temp_file"
        fi
    fi
    
    # Add timestamp
    cat <<EOF >> "$temp_file"

# HELP nestory_build_timestamp_seconds Unix timestamp of build completion
# TYPE nestory_build_timestamp_seconds gauge
nestory_build_timestamp_seconds{$matrix_labels} $(date +%s)
EOF
    
    # Atomic move
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_ci_build.prom"
}

# Function to collect test metrics
collect_test_metrics() {
    local tests_passed=$1
    local tests_failed=$2
    local test_duration=$3
    local coverage=$4
    
    echo -e "${GREEN}📊 Collecting test metrics...${NC}"
    
    # Matrix-aware test labels
    local test_labels="test_suite=\"${TEST_SUITE:-Unit}\""
    if [ -n "${SCHEME:-}" ]; then
        test_labels="${test_labels},scheme=\"${SCHEME}\""
    fi
    if [ -n "${CONFIGURATION:-}" ]; then
        test_labels="${test_labels},configuration=\"${CONFIGURATION}\""
    fi
    if [ -n "${DEVICE_TYPE:-}" ]; then
        test_labels="${test_labels},device_type=\"${DEVICE_TYPE:-Simulator}\""
    fi
    if [ -n "${DEVICE:-}" ]; then
        test_labels="${test_labels},device=\"${DEVICE}\""
    fi
    
    local temp_file="${TEXTFILE_DIR}/nestory_ci_tests.prom.$$"
    
    cat <<EOF > "$temp_file"
# HELP nestory_tests_passed_total Number of tests passed
# TYPE nestory_tests_passed_total counter
nestory_tests_passed_total{$test_labels} $tests_passed

# HELP nestory_tests_failed_total Number of tests failed
# TYPE nestory_tests_failed_total counter
nestory_tests_failed_total{$test_labels} $tests_failed

# HELP nestory_test_duration_seconds Duration of test execution
# TYPE nestory_test_duration_seconds gauge
nestory_test_duration_seconds{$test_labels} $test_duration
EOF
    
    # Add coverage if available
    if [ -n "$coverage" ] && [ "$coverage" != "0" ]; then
        local coverage_labels="module=\"${MODULE:-Overall}\""
        if [ -n "${SCHEME:-}" ]; then
            coverage_labels="${coverage_labels},scheme=\"${SCHEME}\""
        fi
        
        cat <<EOF >> "$temp_file"

# HELP nestory_test_coverage_percent Test coverage percentage
# TYPE nestory_test_coverage_percent gauge
nestory_test_coverage_percent{$coverage_labels} $coverage
EOF
    fi
    
    # Add success rate calculation
    if [ -n "$tests_passed" ] && [ -n "$tests_failed" ]; then
        local total_tests=$((tests_passed + tests_failed))
        if [ "$total_tests" -gt 0 ]; then
            local success_rate=$(echo "scale=2; ($tests_passed / $total_tests) * 100" | bc -l 2>/dev/null || echo 0)
            cat <<EOF >> "$temp_file"

# HELP nestory_test_success_rate_percent Test success rate
# TYPE nestory_test_success_rate_percent gauge
nestory_test_success_rate_percent{$test_labels} $success_rate
EOF
        fi
    fi
    
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_ci_tests.prom"
}

# Function to collect parallel test metrics
collect_parallel_test_metrics() {
    local simulator_type=$1
    local device_name=$2
    local tests_passed=$3
    local tests_failed=$4
    local duration=$5
    local estimated_duration=$6
    
    echo -e "${GREEN}📊 Collecting parallel test metrics for $simulator_type...${NC}"
    
    # Parallel test labels
    local parallel_labels="simulator_type=\"${simulator_type}\",device=\"${device_name}\",parallel=\"true\""
    
    local temp_file="${TEXTFILE_DIR}/nestory_ci_parallel_tests.prom.$$"
    
    cat <<EOF > "$temp_file"
# HELP nestory_parallel_test_duration_seconds Duration of parallel test execution
# TYPE nestory_parallel_test_duration_seconds gauge
nestory_parallel_test_duration_seconds{$parallel_labels} $duration

# HELP nestory_parallel_tests_passed_total Number of parallel tests passed
# TYPE nestory_parallel_tests_passed_total counter
nestory_parallel_tests_passed_total{$parallel_labels} $tests_passed

# HELP nestory_parallel_tests_failed_total Number of parallel tests failed
# TYPE nestory_parallel_tests_failed_total counter
nestory_parallel_tests_failed_total{$parallel_labels} $tests_failed
EOF
    
    # Add estimation accuracy if available
    if [ -n "$estimated_duration" ] && [ "$estimated_duration" -gt 0 ]; then
        cat <<EOF >> "$temp_file"

# HELP nestory_parallel_test_estimated_seconds Estimated duration of parallel tests
# TYPE nestory_parallel_test_estimated_seconds gauge
nestory_parallel_test_estimated_seconds{$parallel_labels} $estimated_duration
EOF
        
        # Calculate accuracy
        if [ -n "$duration" ]; then
            local accuracy=$(echo "scale=2; (1 - (($duration - $estimated_duration) / $estimated_duration)) * 100" | bc -l 2>/dev/null || echo 0)
            cat <<EOF >> "$temp_file"

# HELP nestory_parallel_test_estimation_accuracy_percent Accuracy of test duration estimation
# TYPE nestory_parallel_test_estimation_accuracy_percent gauge
nestory_parallel_test_estimation_accuracy_percent{$parallel_labels} $accuracy
EOF
        fi
    fi
    
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_ci_parallel_tests.prom"
}

# Function to collect performance metrics
collect_performance_metrics() {
    local cold_start_ms=$1
    local memory_mb=$2
    local scroll_jank=$3
    
    echo -e "${GREEN}📊 Collecting performance metrics...${NC}"
    
    local temp_file="${TEXTFILE_DIR}/nestory_ci_performance.prom.$$"
    
    cat <<EOF > "$temp_file"
# HELP nestory_app_cold_start_ms Application cold start time in milliseconds
# TYPE nestory_app_cold_start_ms gauge
nestory_app_cold_start_ms{device="${DEVICE:-iPhone 16 Pro Max}",ios_version="${IOS_VERSION:-18.0}"} $cold_start_ms

# HELP nestory_app_memory_mb Application memory usage in megabytes
# TYPE nestory_app_memory_mb gauge
nestory_app_memory_mb{scenario="${SCENARIO:-default}",device="${DEVICE:-iPhone 16 Pro Max}"} $memory_mb

# HELP nestory_scroll_jank_percent Scroll jank percentage
# TYPE nestory_scroll_jank_percent gauge
nestory_scroll_jank_percent{view="${VIEW:-InventoryView}",device="${DEVICE:-iPhone 16 Pro Max}"} $scroll_jank
EOF
    
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_ci_performance.prom"
}

# Function to collect cache metrics
collect_cache_metrics() {
    local cache_size=${1:-}
    local cache_hit_rate=${2:-}
    local cache_age_hours=${3:-}
    
    echo -e "${GREEN}📊 Collecting cache metrics...${NC}"
    
    local temp_file="${TEXTFILE_DIR}/nestory_ci_cache.prom.$$"
    
    cat <<EOF > "$temp_file"
# HELP nestory_cache_size_bytes Cache size in bytes
# TYPE nestory_cache_size_bytes gauge
EOF
    
    if [ -n "$cache_size" ]; then
        echo "nestory_cache_size_bytes{cache_type=\"${CACHE_TYPE:-DerivedData}\"} $cache_size" >> "$temp_file"
    fi
    
    if [ -n "$cache_hit_rate" ]; then
        cat <<EOF >> "$temp_file"

# HELP nestory_cache_hit_rate Cache hit rate (0-1)
# TYPE nestory_cache_hit_rate gauge
nestory_cache_hit_rate{cache_type="${CACHE_TYPE:-Overall}"} $cache_hit_rate
EOF
    fi
    
    if [ -n "$cache_age_hours" ]; then
        cat <<EOF >> "$temp_file"

# HELP nestory_cache_age_hours Age of cache in hours
# TYPE nestory_cache_age_hours gauge
nestory_cache_age_hours{cache_type="${CACHE_TYPE:-DerivedData}"} $cache_age_hours
EOF
    fi
    
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_ci_cache.prom"
}

# Function to collect pipeline metrics
collect_pipeline_metrics() {
    local pipeline_duration=$1
    local queue_time=$2
    local artifact_size=$3
    
    echo -e "${GREEN}📊 Collecting pipeline metrics...${NC}"
    
    local temp_file="${TEXTFILE_DIR}/nestory_ci_pipeline.prom.$$"
    
    cat <<EOF > "$temp_file"
# HELP nestory_pipeline_duration_seconds Total pipeline duration
# TYPE nestory_pipeline_duration_seconds gauge
nestory_pipeline_duration_seconds{workflow="${GITHUB_WORKFLOW:-unknown}",trigger="${GITHUB_EVENT_NAME:-unknown}"} $pipeline_duration

# HELP nestory_pipeline_queue_seconds Time spent in queue before execution
# TYPE nestory_pipeline_queue_seconds gauge
nestory_pipeline_queue_seconds{runner="${RUNNER_NAME:-unknown}"} $queue_time

# HELP nestory_artifact_size_bytes Size of build artifacts
# TYPE nestory_artifact_size_bytes gauge
nestory_artifact_size_bytes{artifact_type="${ARTIFACT_TYPE:-unknown}"} $artifact_size
EOF
    
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_ci_pipeline.prom"
}

# Function to extract metrics from Xcode test results
extract_xcode_metrics() {
    local xcresult_path=$1
    
    if [ -f "$xcresult_path" ]; then
        echo -e "${GREEN}📊 Extracting metrics from ${xcresult_path}...${NC}"
        
        # Extract test metrics using xcresulttool
        if command -v xcrun >/dev/null 2>&1; then
            xcrun xcresulttool get --path "$xcresult_path" --format json > /tmp/test_results.json 2>/dev/null || {
                echo -e "${YELLOW}Warning: Failed to extract test results${NC}"
                return
            }
            
            # Parse results with error handling
            local tests_passed
            local tests_failed
            local test_duration
            
            tests_passed=$(jq '.metrics.testsCount - .metrics.testsFailedCount' /tmp/test_results.json 2>/dev/null || echo 0)
            tests_failed=$(jq '.metrics.testsFailedCount' /tmp/test_results.json 2>/dev/null || echo 0)
            test_duration=$(jq '.metrics.duration' /tmp/test_results.json 2>/dev/null || echo 0)
            
            # Collect metrics
            collect_test_metrics "$tests_passed" "$tests_failed" "$test_duration" ""
            
            rm -f /tmp/test_results.json
        else
            echo -e "${YELLOW}Warning: xcrun not available, skipping xcresult extraction${NC}"
        fi
    else
        echo -e "${RED}Error: xcresult file not found: $xcresult_path${NC}"
    fi
}

# Function to calculate cache metrics from filesystem
calculate_cache_metrics() {
    local derived_data="$HOME/Library/Developer/Xcode/DerivedData"
    
    echo -e "${GREEN}📊 Calculating cache metrics...${NC}"
    
    local cache_size=0
    local cache_age_hours=0
    
    # Cache size
    if [ -d "$derived_data" ]; then
        cache_size=$(du -sb "$derived_data" 2>/dev/null | cut -f1 || echo 0)
    fi
    
    # Cache age for Nestory project
    local nestory_cache
    nestory_cache=$(find "$derived_data" -name "Nestory-*" -maxdepth 1 -type d 2>/dev/null | head -1)
    if [ -n "$nestory_cache" ]; then
        local modification_time
        modification_time=$(stat -f %m "$nestory_cache" 2>/dev/null || date +%s)
        local current_time
        current_time=$(date +%s)
        cache_age_hours=$(( (current_time - modification_time) / 3600 ))
    fi
    
    collect_cache_metrics "$cache_size" "" "$cache_age_hours"
}

# Function to cleanup old metric files (lifecycle management)
cleanup_old_metrics() {
    echo -e "${BLUE}🧹 Cleaning up old metric files...${NC}"
    
    # Remove metric files older than 1 hour (they should be scraped by now)
    find "$TEXTFILE_DIR" -name "*.prom" -mmin +60 -type f -delete 2>/dev/null || true
    
    # Remove any temporary files
    find "$TEXTFILE_DIR" -name "*.prom.*" -type f -delete 2>/dev/null || true
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Nestory Metrics Collection (Textfile Collector)${NC}"
    echo "================================================="
    echo "Textfile Directory: $TEXTFILE_DIR"
    echo "Job: $JOB_NAME"
    echo "Instance: $INSTANCE"
    echo ""
    
    # Parse command line arguments
    case "${1:-all}" in
        build)
            collect_build_metrics "${2:-success}" "${3:-0}" "${4:-false}"
            ;;
        test)
            collect_test_metrics "${2:-0}" "${3:-0}" "${4:-0}" "${5:-0}"
            ;;
        parallel)
            collect_parallel_test_metrics "${2}" "${3}" "${4:-0}" "${5:-0}" "${6:-0}" "${7:-0}"
            ;;
        performance)
            collect_performance_metrics "${2:-0}" "${3:-0}" "${4:-0}"
            ;;
        cache)
            calculate_cache_metrics
            ;;
        pipeline)
            collect_pipeline_metrics "${2:-0}" "${3:-0}" "${4:-0}"
            ;;
        xcresult)
            extract_xcode_metrics "${2}"
            ;;
        cleanup)
            cleanup_old_metrics
            ;;
        all)
            # Collect all available metrics
            calculate_cache_metrics
            cleanup_old_metrics
            ;;
        *)
            echo "Usage: $0 [build|test|parallel|performance|cache|pipeline|xcresult|cleanup|all] [args...]"
            echo ""
            echo "Commands:"
            echo "  build <status> <duration> <cache_hit>            Collect build metrics"
            echo "  test <passed> <failed> <duration> <coverage>     Collect test metrics"  
            echo "  parallel <type> <device> <passed> <failed> <duration> <estimated>  Collect parallel test metrics"
            echo "  performance <cold_start> <memory> <jank>         Collect performance metrics"
            echo "  cache                                             Calculate and collect cache metrics"
            echo "  pipeline <duration> <queue_time> <artifact_size> Collect pipeline metrics"
            echo "  xcresult <path>                                   Extract metrics from xcresult"
            echo "  cleanup                                           Remove old metric files"
            echo "  all                                               Collect all available metrics"
            echo ""
            echo "Configure Node Exporter with: --collector.textfile.directory=$TEXTFILE_DIR"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Metrics collected to textfile directory${NC}"
    echo -e "${BLUE}📁 Files created in: $TEXTFILE_DIR${NC}"
    ls -la "$TEXTFILE_DIR"/*.prom 2>/dev/null || echo "No .prom files found"
}

# Run main function
main "$@"