#!/bin/bash

# Extract real metrics from Nestory project data
# This script analyzes actual build logs, test results, and project files
# to populate monitoring dashboards with authentic data

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$0")")"
NESTORY_ROOT="$(dirname "$PROJECT_ROOT")"
PUSH_GATEWAY="http://localhost:9091"
JOB_NAME="nestory_real_data"
INSTANCE="$(date +%s)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📊 Extracting Real Nestory Project Metrics${NC}"
echo "==========================================="
echo "Project Root: $NESTORY_ROOT"
echo "Pushgateway: $PUSH_GATEWAY"
echo ""

# Function to push metric to Prometheus
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
        "${PUSH_GATEWAY}/metrics/job/${JOB_NAME}/instance/${INSTANCE}" \
        || echo -e "${YELLOW}Warning: Failed to push ${metric_name}${NC}"
}

# Extract project statistics
echo -e "${GREEN}📈 Extracting Project Statistics${NC}"

# Swift files count
swift_files=$(find "$NESTORY_ROOT" -name "*.swift" -not -path "*/build/*" -not -path "*/.build/*" | wc -l | tr -d ' ')
echo "Swift files: $swift_files"
push_metric "nestory_swift_files_total" "$swift_files" "gauge" "project=\"nestory\""

# Lines of code
total_loc=$(find "$NESTORY_ROOT" -name "*.swift" -not -path "*/build/*" -not -path "*/.build/*" -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "Lines of code: $total_loc"
push_metric "nestory_lines_of_code_total" "$total_loc" "gauge" "project=\"nestory\""

# Analyze build logs
echo -e "${GREEN}🔨 Analyzing Build History${NC}"

build_logs=($(find "$NESTORY_ROOT" -name "Build*.txt" -type f))
successful_builds=0
failed_builds=0
total_builds=${#build_logs[@]}

for log in "${build_logs[@]}"; do
    if grep -q "Build succeeded" "$log" 2>/dev/null; then
        ((successful_builds++))
    elif grep -q "Build failed" "$log" 2>/dev/null; then
        ((failed_builds++))
    fi
done

echo "Total builds: $total_builds"
echo "Successful: $successful_builds"
echo "Failed: $failed_builds"

if [ "$total_builds" -gt 0 ]; then
    build_success_rate=$(echo "scale=2; $successful_builds / $total_builds * 100" | bc -l)
    echo "Build success rate: ${build_success_rate}%"
    push_metric "nestory_build_success_rate" "$build_success_rate" "gauge" "project=\"nestory\""
fi

push_metric "nestory_builds_total" "$total_builds" "counter" "project=\"nestory\""
push_metric "nestory_builds_successful_total" "$successful_builds" "counter" "project=\"nestory\""
push_metric "nestory_builds_failed_total" "$failed_builds" "counter" "project=\"nestory\""

# Extract build durations from logs
echo -e "${GREEN}⏱️  Analyzing Build Performance${NC}"

latest_log=$(find "$NESTORY_ROOT" -name "Build*.txt" -type f -exec stat -f "%m %N" {} + | sort -nr | head -1 | cut -d' ' -f2-)
if [ -n "$latest_log" ]; then
    # Extract duration from build log
    duration_line=$(grep -E "Build.*[0-9]+\.[0-9]+ seconds" "$latest_log" 2>/dev/null | tail -1 || echo "")
    if [ -n "$duration_line" ]; then
        duration=$(echo "$duration_line" | grep -oE "[0-9]+\.[0-9]+" | tail -1)
        if [ -n "$duration" ]; then
            echo "Latest build duration: ${duration}s"
            push_metric "nestory_build_duration_seconds" "$duration" "gauge" "project=\"nestory\",type=\"latest\""
        fi
    fi
fi

# Analyze test results
echo -e "${GREEN}🧪 Analyzing Test Results${NC}"

xcresult_files=($(find "$NESTORY_ROOT" -path "*/Nestory/*" -name "*.xcresult" -type d))
echo "Found ${#xcresult_files[@]} test result bundles"

# Get the most recent xcresult
if [ ${#xcresult_files[@]} -gt 0 ]; then
    latest_xcresult=$(printf '%s\n' "${xcresult_files[@]}" | xargs stat -f "%m %N" | sort -nr | head -1 | cut -d' ' -f2-)
    echo "Latest test results: $(basename "$latest_xcresult")"
    
    # Extract basic info from xcresult
    if [ -d "$latest_xcresult" ]; then
        xcresult_size=$(du -s "$latest_xcresult" | cut -f1)
        push_metric "nestory_test_results_size_kb" "$xcresult_size" "gauge" "project=\"nestory\""
        
        # Check Info.plist for basic metadata
        if [ -f "$latest_xcresult/Info.plist" ]; then
            echo "Test results bundle verified with Info.plist"
            push_metric "nestory_test_results_available" "1" "gauge" "project=\"nestory\""
        fi
    fi
fi

# Analyze project structure
echo -e "${GREEN}🏗️  Analyzing Project Structure${NC}"

# Count directories by type
features_count=$(find "$NESTORY_ROOT/Features" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$features_count" -gt 0 ]; then
    ((features_count--))  # Remove Features directory itself
    echo "Features modules: $features_count"
    push_metric "nestory_features_modules_total" "$features_count" "gauge" "project=\"nestory\""
fi

services_count=$(find "$NESTORY_ROOT/Services" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$services_count" -gt 0 ]; then
    ((services_count--))  # Remove Services directory itself
    echo "Services modules: $services_count"
    push_metric "nestory_services_modules_total" "$services_count" "gauge" "project=\"nestory\""
fi

ui_count=$(find "$NESTORY_ROOT/UI" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$ui_count" -gt 0 ]; then
    ((ui_count--))  # Remove UI directory itself
    echo "UI modules: $ui_count"
    push_metric "nestory_ui_modules_total" "$ui_count" "gauge" "project=\"nestory\""
fi

# Analyze build artifacts
echo -e "${GREEN}🔧 Analyzing Build Artifacts${NC}"

if [ -d "$NESTORY_ROOT/build" ]; then
    build_size=$(du -s "$NESTORY_ROOT/build" | cut -f1)
    echo "Build directory size: ${build_size}KB"
    push_metric "nestory_build_artifacts_size_kb" "$build_size" "gauge" "project=\"nestory\""
fi

# Check cache size
derived_data="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$derived_data" ]; then
    nestory_caches=$(find "$derived_data" -name "*Nestory*" -type d 2>/dev/null)
    if [ -n "$nestory_caches" ]; then
        total_cache_size=0
        while IFS= read -r cache_dir; do
            cache_size=$(du -s "$cache_dir" 2>/dev/null | cut -f1 || echo 0)
            total_cache_size=$((total_cache_size + cache_size))
        done <<< "$nestory_caches"
        
        echo "Total cache size: ${total_cache_size}KB"
        push_metric "nestory_cache_size_kb" "$total_cache_size" "gauge" "project=\"nestory\",cache_type=\"derived_data\""
    fi
fi

# Check for recent build activity
build_start_time_file="/tmp/nestory_build_start_time"
if [ -f "$build_start_time_file" ]; then
    build_start=$(cat "$build_start_time_file")
    current_time=$(date +%s)
    if [ -n "$build_start" ] && [ "$build_start" -gt 0 ]; then
        last_build_age=$((current_time - build_start))
        echo "Last build activity: ${last_build_age}s ago"
        push_metric "nestory_last_build_age_seconds" "$last_build_age" "gauge" "project=\"nestory\""
    fi
fi

# Check monitoring infrastructure
echo -e "${GREEN}📊 Checking Monitoring Infrastructure${NC}"

# Check if Prometheus is accessible
if curl -s "http://localhost:9090/-/healthy" >/dev/null 2>&1; then
    push_metric "nestory_prometheus_up" "1" "gauge" "service=\"prometheus\""
else
    push_metric "nestory_prometheus_up" "0" "gauge" "service=\"prometheus\""
fi

# Check if Pushgateway is accessible  
if curl -s "http://localhost:9091/metrics" >/dev/null 2>&1; then
    push_metric "nestory_pushgateway_up" "1" "gauge" "service=\"pushgateway\""
else
    push_metric "nestory_pushgateway_up" "0" "gauge" "service=\"pushgateway\""
fi

# Check if Grafana is accessible
if curl -s "http://localhost:3000/api/health" >/dev/null 2>&1; then
    push_metric "nestory_grafana_up" "1" "gauge" "service=\"grafana\""
else  
    push_metric "nestory_grafana_up" "0" "gauge" "service=\"grafana\""
fi

echo -e "${GREEN}✅ Real metrics extraction completed${NC}"
echo "Check Grafana dashboard at: http://localhost:3000/d/nry-unified-dev/"