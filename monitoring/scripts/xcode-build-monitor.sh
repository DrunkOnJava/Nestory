#!/bin/bash

# Xcode Build Error Monitor
# Automatically captures and tracks build errors from Xcode

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="${PROJECT_ROOT}/build-logs"
ERROR_DB="${PROJECT_ROOT}/build-errors.db"
PUSHGATEWAY_URL="http://localhost:9091"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Initialize SQLite database for error tracking
init_database() {
    sqlite3 "$ERROR_DB" <<EOF
CREATE TABLE IF NOT EXISTS build_errors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    scheme TEXT,
    configuration TEXT,
    error_type TEXT,
    error_message TEXT,
    file_path TEXT,
    line_number INTEGER,
    column_number INTEGER,
    error_code TEXT,
    full_error TEXT,
    build_id TEXT,
    resolved BOOLEAN DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_timestamp ON build_errors(timestamp);
CREATE INDEX IF NOT EXISTS idx_error_type ON build_errors(error_type);
CREATE INDEX IF NOT EXISTS idx_resolved ON build_errors(resolved);
EOF
    echo "✅ Database initialized at $ERROR_DB"
}

# Parse xcodebuild output for errors
parse_build_output() {
    local build_log="$1"
    local scheme="$2"
    local configuration="$3"
    local build_id="$4"
    
    echo "📊 Parsing build log for errors..."
    
    # Extract compilation errors
    grep -E "(error:|warning:|note:|fatal error:)" "$build_log" | while IFS= read -r line; do
        # Parse Swift compiler errors
        if echo "$line" | grep -q "error:"; then
            local error_type="compile_error"
            local file_path=$(echo "$line" | sed -n 's/^\([^:]*\):[0-9]*:[0-9]*: error:.*/\1/p')
            local line_num=$(echo "$line" | sed -n 's/^[^:]*:\([0-9]*\):[0-9]*: error:.*/\1/p')
            local col_num=$(echo "$line" | sed -n 's/^[^:]*:[0-9]*:\([0-9]*\): error:.*/\1/p')
            local error_msg=$(echo "$line" | sed -n 's/^.*error: \(.*\)/\1/p')
            
            if [[ -n "$error_msg" ]]; then
                store_error "$scheme" "$configuration" "$error_type" "$error_msg" \
                           "$file_path" "$line_num" "$col_num" "" "$line" "$build_id"
            fi
        fi
        
        # Parse linker errors
        if echo "$line" | grep -q "Undefined symbols"; then
            local error_type="linker_error"
            local error_msg="Undefined symbols"
            store_error "$scheme" "$configuration" "$error_type" "$error_msg" \
                       "" "" "" "" "$line" "$build_id"
        fi
        
        # Parse code signing errors
        if echo "$line" | grep -q "Code Sign error"; then
            local error_type="codesign_error"
            local error_msg=$(echo "$line" | sed 's/.*Code Sign error: //')
            store_error "$scheme" "$configuration" "$error_type" "$error_msg" \
                       "" "" "" "" "$line" "$build_id"
        fi
    done
    
    # Extract test failures
    grep -E "(Test Case .* failed|XCTAssert.*failed)" "$build_log" | while IFS= read -r line; do
        local error_type="test_failure"
        local error_msg=$(echo "$line" | sed 's/.*Test Case.*failed.*(\(.*\)).*/\1/')
        store_error "$scheme" "$configuration" "$error_type" "$error_msg" \
                   "" "" "" "" "$line" "$build_id"
    done
}

# Store error in database
store_error() {
    local scheme="$1"
    local configuration="$2"
    local error_type="$3"
    local error_message="$4"
    local file_path="$5"
    local line_number="$6"
    local column_number="$7"
    local error_code="$8"
    local full_error="$9"
    local build_id="${10}"
    
    sqlite3 "$ERROR_DB" <<EOF
INSERT INTO build_errors (
    scheme, configuration, error_type, error_message,
    file_path, line_number, column_number, error_code,
    full_error, build_id
) VALUES (
    '$scheme', '$configuration', '$error_type', '$error_message',
    '$file_path', '$line_number', '$column_number', '$error_code',
    '$full_error', '$build_id'
);
EOF
    
    echo "  ❌ Stored: $error_type - $error_message"
}

# Build with error capture
build_with_monitoring() {
    local scheme="${1:-Nestory-Dev}"
    local configuration="${2:-Debug}"
    local build_id="build_$(date +%Y%m%d_%H%M%S)"
    local log_file="${LOG_DIR}/${build_id}.log"
    local json_file="${LOG_DIR}/${build_id}.json"
    
    echo "🔨 Starting monitored build..."
    echo "  Scheme: $scheme"
    echo "  Configuration: $configuration"
    echo "  Build ID: $build_id"
    echo "  Log: $log_file"
    
    # Run xcodebuild and capture output
    local start_time=$(date +%s)
    local build_result=0
    
    xcodebuild \
        -scheme "$scheme" \
        -configuration "$configuration" \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
        -derivedDataPath "${PROJECT_ROOT}/DerivedData" \
        -resultBundlePath "${LOG_DIR}/${build_id}.xcresult" \
        build 2>&1 | tee "$log_file" || build_result=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Parse errors from log
    parse_build_output "$log_file" "$scheme" "$configuration" "$build_id"
    
    # Get error counts
    local error_count=$(sqlite3 "$ERROR_DB" "SELECT COUNT(*) FROM build_errors WHERE build_id='$build_id' AND error_type='compile_error';")
    local warning_count=$(grep -c "warning:" "$log_file" || true)
    local test_failures=$(sqlite3 "$ERROR_DB" "SELECT COUNT(*) FROM build_errors WHERE build_id='$build_id' AND error_type='test_failure';")
    
    # Send metrics to Prometheus
    send_metrics "$scheme" "$configuration" "$build_result" "$duration" "$error_count" "$warning_count" "$test_failures"
    
    # Generate JSON report
    generate_json_report "$build_id" "$scheme" "$configuration" "$build_result" "$duration" "$error_count" "$warning_count" > "$json_file"
    
    # Display summary
    echo ""
    if [[ $build_result -eq 0 ]]; then
        echo -e "${GREEN}✅ Build Successful!${NC}"
    else
        echo -e "${RED}❌ Build Failed!${NC}"
    fi
    echo "  Duration: ${duration}s"
    echo "  Errors: $error_count"
    echo "  Warnings: $warning_count"
    echo "  Test Failures: $test_failures"
    
    # Send notification if configured
    if [[ $build_result -ne 0 ]] && [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        send_slack_notification "$build_id" "$scheme" "$error_count"
    fi
    
    return $build_result
}

# Send metrics to Prometheus via Pushgateway
send_metrics() {
    local scheme="$1"
    local configuration="$2"
    local result="$3"
    local duration="$4"
    local errors="$5"
    local warnings="$6"
    local test_failures="$7"
    
    cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/xcode_build/instance/$(hostname)"
# Build result (0 = success, 1 = failure)
xcode_build_result{scheme="$scheme",configuration="$configuration"} $result

# Build duration in seconds
xcode_build_duration_seconds{scheme="$scheme",configuration="$configuration"} $duration

# Error counts
xcode_build_errors_total{scheme="$scheme",configuration="$configuration",type="compile"} $errors
xcode_build_errors_total{scheme="$scheme",configuration="$configuration",type="warning"} $warnings
xcode_build_errors_total{scheme="$scheme",configuration="$configuration",type="test"} $test_failures

# Timestamp
xcode_build_timestamp{scheme="$scheme",configuration="$configuration"} $(date +%s)
EOF
    
    echo "📊 Metrics sent to Prometheus"
}

# Generate JSON report
generate_json_report() {
    local build_id="$1"
    local scheme="$2"
    local configuration="$3"
    local result="$4"
    local duration="$5"
    local errors="$6"
    local warnings="$7"
    
    # Get recent errors from database
    local errors_json=$(sqlite3 -json "$ERROR_DB" "SELECT * FROM build_errors WHERE build_id='$build_id' LIMIT 10;")
    
    cat <<EOF
{
  "build_id": "$build_id",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "scheme": "$scheme",
  "configuration": "$configuration",
  "success": $([ $result -eq 0 ] && echo "true" || echo "false"),
  "duration_seconds": $duration,
  "statistics": {
    "errors": $errors,
    "warnings": $warnings,
    "test_failures": $(sqlite3 "$ERROR_DB" "SELECT COUNT(*) FROM build_errors WHERE build_id='$build_id' AND error_type='test_failure';")
  },
  "errors": $errors_json
}
EOF
}

# Send Slack notification
send_slack_notification() {
    local build_id="$1"
    local scheme="$2"
    local error_count="$3"
    
    local message="Build Failed: $scheme\nErrors: $error_count\nBuild ID: $build_id"
    
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$message\"}" \
        "$SLACK_WEBHOOK_URL" 2>/dev/null || true
}

# Watch for Xcode builds (polling-based, no fswatch dependency)
watch_for_builds() {
    echo "👁️  Watching for Xcode builds..."
    echo "  This will automatically capture errors when you build in Xcode"
    
    local last_check=$(date +%s)
    
    while true; do
        # Check for new build logs every 5 seconds
        local current_time=$(date +%s)
        
        # Find logs modified since last check - use project's custom DerivedData path
        local project_derived_data="/Users/griffin/Projects/Nestory/.build"
        local system_derived_data="${HOME}/Library/Developer/Xcode/DerivedData"
        
        # Check both project-specific and system DerivedData locations
        local new_logs=""
        if [[ -d "$project_derived_data" ]]; then
            new_logs+=$(find "$project_derived_data" \
                -name "*.xcactivitylog" \
                -newer /tmp/nestory_build_monitor_timestamp 2>/dev/null || true)
        fi
        if [[ -d "$system_derived_data" ]]; then
            new_logs+=" "$(find "$system_derived_data" \
                -name "*.xcactivitylog" \
                -newer /tmp/nestory_build_monitor_timestamp 2>/dev/null || true)
        fi
        
        if [[ -n "$new_logs" ]]; then
            echo "$new_logs" | while IFS= read -r log; do
                if [[ -f "$log" ]]; then
                    echo "🔍 New build detected: $(basename "$log")"
                    
                    # Extract build ID from log name
                    local build_id="xcode_$(date +%Y%m%d_%H%M%S)"
                    
                    # Decompress and parse the log (xcactivitylog files are gzipped)
                    local temp_log="/tmp/xcode_build_${build_id}.log"
                    gunzip -c "$log" > "$temp_log" 2>/dev/null || true
                    
                    if [[ -s "$temp_log" ]]; then
                        parse_build_output "$temp_log" "Xcode" "Unknown" "$build_id"
                    fi
                    
                    rm -f "$temp_log"
                fi
            done
        fi
        
        # Update timestamp for next check
        touch /tmp/nestory_build_monitor_timestamp
        
        # Wait before next check
        sleep 5
    done
}

# Query recent errors
query_errors() {
    local limit="${1:-10}"
    echo "📋 Recent Build Errors (limit: $limit)"
    echo ""
    
    sqlite3 -column -header "$ERROR_DB" <<EOF
SELECT 
    datetime(timestamp, 'localtime') as time,
    scheme,
    configuration,
    error_type,
    substr(error_message, 1, 50) as error_message,
    file_path
FROM build_errors
WHERE resolved = 0
ORDER BY timestamp DESC
LIMIT $limit;
EOF
}

# Mark errors as resolved
mark_resolved() {
    local build_id="$1"
    if [[ -n "$build_id" ]]; then
        sqlite3 "$ERROR_DB" "UPDATE build_errors SET resolved = 1 WHERE build_id = '$build_id';"
        echo "✅ Marked errors from build $build_id as resolved"
    else
        sqlite3 "$ERROR_DB" "UPDATE build_errors SET resolved = 1 WHERE resolved = 0;"
        echo "✅ Marked all unresolved errors as resolved"
    fi
}

# Generate error report
generate_report() {
    echo "📊 Build Error Report"
    echo "===================="
    echo ""
    
    echo "Error Summary by Type:"
    sqlite3 -column -header "$ERROR_DB" <<EOF
SELECT 
    error_type,
    COUNT(*) as count,
    COUNT(DISTINCT build_id) as affected_builds
FROM build_errors
WHERE timestamp > datetime('now', '-7 days')
GROUP BY error_type
ORDER BY count DESC;
EOF
    
    echo ""
    echo "Most Common Errors:"
    sqlite3 -column -header "$ERROR_DB" <<EOF
SELECT 
    error_message,
    COUNT(*) as occurrences
FROM build_errors
WHERE timestamp > datetime('now', '-7 days')
GROUP BY error_message
ORDER BY occurrences DESC
LIMIT 5;
EOF
    
    echo ""
    echo "Files with Most Errors:"
    sqlite3 -column -header "$ERROR_DB" <<EOF
SELECT 
    file_path,
    COUNT(*) as error_count
FROM build_errors
WHERE timestamp > datetime('now', '-7 days')
    AND file_path != ''
GROUP BY file_path
ORDER BY error_count DESC
LIMIT 5;
EOF
}

# Main command handler
main() {
    case "${1:-build}" in
        init)
            init_database
            ;;
        build)
            init_database
            build_with_monitoring "${2:-Nestory-Dev}" "${3:-Debug}"
            ;;
        watch)
            init_database
            watch_for_builds
            ;;
        query)
            query_errors "${2:-10}"
            ;;
        resolve)
            mark_resolved "${2:-}"
            ;;
        report)
            generate_report
            ;;
        help)
            cat <<EOF
Xcode Build Error Monitor

Usage: $0 [command] [options]

Commands:
  init              Initialize the error database
  build [scheme]    Build project and capture errors (default: Nestory-Dev)
  watch            Watch for Xcode builds and auto-capture errors
  query [limit]    Query recent errors (default: 10)
  resolve [id]     Mark errors as resolved
  report           Generate error report
  help             Show this help message

Examples:
  $0 build Nestory-Dev Debug    # Build with error tracking
  $0 watch                       # Auto-monitor Xcode builds
  $0 query 20                    # Show last 20 errors
  $0 resolve                     # Mark all errors as resolved
  $0 report                      # Generate error statistics

Environment Variables:
  SLACK_WEBHOOK_URL   Slack webhook for notifications (optional)
EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"