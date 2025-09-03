#!/bin/bash

# Fixed Xcode Build Error Monitor with Proper Path Detection
# Addresses all critical audit findings

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ERROR_DB="${PROJECT_ROOT}/build-errors.db"
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://localhost:9091}"
LOKI_URL="${LOKI_URL:-http://localhost:3100}"

# Detect fswatch path (disable strict mode temporarily for loop)
set +u
FSWATCH_PATH=""
for fswatch_path in "/opt/homebrew/bin/fswatch" "/usr/local/bin/fswatch" "fswatch"; do
    if command -v "$fswatch_path" >/dev/null 2>&1; then
        FSWATCH_PATH="$fswatch_path"
        break
    fi
done
set -u

# Source path detection
source "${SCRIPT_DIR}/detect-build-paths.sh" 2>/dev/null || true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a /tmp/xcode-monitor.log
}

# Initialize database with enhanced schema
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
    resolved BOOLEAN DEFAULT 0,
    source_log TEXT
);

CREATE INDEX IF NOT EXISTS idx_timestamp ON build_errors(timestamp);
CREATE INDEX IF NOT EXISTS idx_error_type ON build_errors(error_type);
CREATE INDEX IF NOT EXISTS idx_resolved ON build_errors(resolved);
CREATE INDEX IF NOT EXISTS idx_build_id ON build_errors(build_id);

-- Add audit table for tracking
CREATE TABLE IF NOT EXISTS build_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    total_errors INTEGER DEFAULT 0,
    scheme TEXT,
    configuration TEXT
);
EOF
    log "✅ Enhanced database initialized at $ERROR_DB"
}

# Enhanced error parsing with better regex patterns
parse_build_log() {
    local log_file="$1"
    local scheme="${2:-Unknown}"
    local configuration="${3:-Unknown}"
    local build_id="${4:-$(date +%s)}"
    
    if [[ ! -f "$log_file" ]]; then
        log "❌ Log file not found: $log_file"
        return 1
    fi
    
    log "📊 Parsing build log: $(basename "$log_file")"
    
    local errors_found=0
    local warnings_found=0
    local tests_failed=0
    
    # Parse different error types with improved patterns
    while IFS= read -r line; do
        # Swift compilation errors
        if echo "$line" | grep -qE "error:|fatal error:"; then
            local file_path=$(echo "$line" | sed -n 's/^\([^:]*\):[0-9]*:[0-9]*:.*error:.*/\1/p')
            local line_num=$(echo "$line" | sed -n 's/^[^:]*:\([0-9]*\):[0-9]*:.*error:.*/\1/p')
            local col_num=$(echo "$line" | sed -n 's/^[^:]*:[0-9]*:\([0-9]*\):.*error:.*/\1/p')
            local error_msg=$(echo "$line" | sed -n 's/^.*error: \(.*\)/\1/p' | head -c 200)
            
            if [[ -n "$error_msg" ]]; then
                store_error "$scheme" "$configuration" "compile_error" "$error_msg" \
                           "$file_path" "$line_num" "$col_num" "" "$line" "$build_id" "$log_file"
                ((errors_found++))
            fi
        fi
        
        # Warnings
        if echo "$line" | grep -qE "warning:"; then
            local warning_msg=$(echo "$line" | sed -n 's/^.*warning: \(.*\)/\1/p' | head -c 200)
            if [[ -n "$warning_msg" ]]; then
                store_error "$scheme" "$configuration" "warning" "$warning_msg" \
                           "" "" "" "" "$line" "$build_id" "$log_file"
                ((warnings_found++))
            fi
        fi
        
        # Test failures
        if echo "$line" | grep -qE "Test Case.*failed|XCTAssert.*failed|Test.*FAILED"; then
            local test_msg=$(echo "$line" | sed 's/.*failed.*(\(.*\)).*/\1/' | head -c 200)
            store_error "$scheme" "$configuration" "test_failure" "$test_msg" \
                       "" "" "" "" "$line" "$build_id" "$log_file"
            ((tests_failed++))
        fi
        
        # Linker errors
        if echo "$line" | grep -qE "Undefined symbols|duplicate symbol|ld:.*error"; then
            local linker_msg=$(echo "$line" | head -c 200)
            store_error "$scheme" "$configuration" "linker_error" "$linker_msg" \
                       "" "" "" "" "$line" "$build_id" "$log_file"
            ((errors_found++))
        fi
        
        # Code signing errors
        if echo "$line" | grep -qi "code sign"; then
            local codesign_msg=$(echo "$line" | sed 's/.*[Cc]ode [Ss]ign[^:]*: //' | head -c 200)
            store_error "$scheme" "$configuration" "codesign_error" "$codesign_msg" \
                       "" "" "" "" "$line" "$build_id" "$log_file"
            ((errors_found++))
        fi
        
    done < "$log_file"
    
    # Push metrics to Prometheus
    push_metrics "$scheme" "$configuration" "$errors_found" "$warnings_found" "$tests_failed" "$build_id"
    
    log "📊 Found: $errors_found errors, $warnings_found warnings, $tests_failed test failures"
    
    # Return success if no critical errors
    return $([[ $errors_found -eq 0 ]])
}

# Enhanced error storage with source tracking
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
    local source_log="${11:-}"
    
    # Escape single quotes for SQL
    error_message=$(echo "$error_message" | sed "s/'/''/g")
    full_error=$(echo "$full_error" | sed "s/'/''/g")
    file_path=$(echo "$file_path" | sed "s/'/''/g")
    
    sqlite3 "$ERROR_DB" <<EOF
INSERT INTO build_errors (
    scheme, configuration, error_type, error_message,
    file_path, line_number, column_number, error_code,
    full_error, build_id, source_log
) VALUES (
    '$scheme', '$configuration', '$error_type', '$error_message',
    '$file_path', '$line_number', '$column_number', '$error_code',
    '$full_error', '$build_id', '$source_log'
);
EOF
    
    log "  📝 Stored: $error_type - ${error_message:0:50}..."
}

# Enhanced metrics pushing
push_metrics() {
    local scheme="$1"
    local configuration="$2"
    local errors="$3"
    local warnings="$4"
    local test_failures="$5"
    local build_id="$6"
    
    local timestamp=$(date +%s)
    local instance=$(hostname)
    
    # Clear existing metrics first to avoid type conflicts
    curl -s -X DELETE "${PUSHGATEWAY_URL}/metrics/job/xcode_build_errors/instance/${instance}" 2>/dev/null || true
    
    # Push fresh metrics to Pushgateway
    cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/xcode_build_errors/instance/${instance}"
# TYPE xcode_build_errors_total gauge
# HELP xcode_build_errors_total Number of build errors by type
xcode_build_errors_total{scheme="$scheme",configuration="$configuration",type="compile"} $errors
xcode_build_errors_total{scheme="$scheme",configuration="$configuration",type="warning"} $warnings  
xcode_build_errors_total{scheme="$scheme",configuration="$configuration",type="test"} $test_failures

# TYPE xcode_build_session_timestamp gauge
# HELP xcode_build_session_timestamp Timestamp of build session
xcode_build_session_timestamp{scheme="$scheme",configuration="$configuration",build_id="$build_id"} $timestamp

# TYPE xcode_build_error_rate gauge
# HELP xcode_build_error_rate Error rate for build session
xcode_build_error_rate{scheme="$scheme",configuration="$configuration"} $(echo "scale=2; $errors / ($errors + $warnings + 1)" | bc -l 2>/dev/null || echo "0")
EOF
    
    log "📊 Metrics pushed to Prometheus: errors=$errors, warnings=$warnings, tests=$test_failures"
}

# Real-time file monitoring using fswatch
monitor_with_fswatch() {
    log "👁️ Starting fswatch-based monitoring..."
    
    # Create PID file for monitoring process
    local pid_file="/tmp/xcode-monitor-${$}.pid"
    echo $$ > "$pid_file"
    log "📝 Monitor PID file created: $pid_file"
    
    # Set up signal handler for graceful shutdown
    trap 'log "🛑 Stopping monitor (signal received)"; rm -f "$pid_file"; exit 0' INT TERM QUIT
    
    # Maximum runtime: 2 hours to prevent infinite monitoring
    local max_runtime=7200
    local start_time=$(date +%s)
    log "⏰ Monitor will auto-stop after $max_runtime seconds"
    
    # Get directories to monitor
    local monitor_dirs=()
    while IFS= read -r dir; do
        if [[ -d "$dir" ]]; then
            monitor_dirs+=("$dir")
            log "📁 Monitoring: $dir"
        fi
    done < <("${SCRIPT_DIR}/detect-build-paths.sh" dirs 2>/dev/null || echo "$PROJECT_ROOT/build")
    
    if [[ ${#monitor_dirs[@]} -eq 0 ]]; then
        log "❌ No directories to monitor found!"
        rm -f "$pid_file"
        return 1
    fi
    
    # Use fswatch to monitor for new/modified files
    if [[ -z "$FSWATCH_PATH" ]]; then
        log "❌ fswatch not found in PATH or standard locations"
        rm -f "$pid_file"
        return 1
    fi
    
    log "📱 Using fswatch at: $FSWATCH_PATH"
    
    # Use timeout to prevent infinite fswatch
    timeout $max_runtime "$FSWATCH_PATH" -o "${monitor_dirs[@]}" | while read changes; do
        # Check if we should stop monitoring
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $elapsed -gt $max_runtime ]]; then
            log "⏰ Maximum monitoring time reached ($max_runtime seconds)"
            break
        fi
        
        log "🔍 Detected $changes file system changes (${elapsed}s elapsed)"
        
        # Find recently modified log files
        for dir in "${monitor_dirs[@]}"; do
            # Look for activity logs modified in last 2 minutes
            find "$dir" -name "*.xcactivitylog" -mmin -2 2>/dev/null | while IFS= read -r log_file; do
                if [[ -f "$log_file" ]]; then
                    log "🆕 Processing new build log: $(basename "$log_file")"
                    
                    local build_id="fswatch_$(date +%Y%m%d_%H%M%S)_$$"
                    local temp_log="/tmp/xcode_monitor_${build_id}.log"
                    
                    # Decompress if needed
                    if file "$log_file" | grep -q "gzip"; then
                        gunzip -c "$log_file" > "$temp_log" 2>/dev/null || continue
                    else
                        cp "$log_file" "$temp_log"
                    fi
                    
                    # Parse errors
                    if [[ -s "$temp_log" ]]; then
                        parse_build_log "$temp_log" "Xcode" "Unknown" "$build_id"
                    fi
                    
                    rm -f "$temp_log"
                fi
            done
            
            # Also look for xcresult bundles
            find "$dir" -name "*.xcresult" -mmin -2 -type d 2>/dev/null | while IFS= read -r result_bundle; do
                if [[ -d "$result_bundle" ]]; then
                    log "📦 Processing xcresult bundle: $(basename "$result_bundle")"
                    process_xcresult "$result_bundle"
                fi
            done
        done
        
        # Prevent excessive processing
        sleep 2
    done
    
    # Cleanup
    log "🧹 Monitor shutting down, cleaning up PID file"
    rm -f "$pid_file"
}

# Process xcresult bundle
process_xcresult() {
    local xcresult_path="$1"
    
    if command -v xcrun >/dev/null 2>&1; then
        local build_id="xcresult_$(date +%Y%m%d_%H%M%S)"
        
        # Extract issues from xcresult
        xcrun xcresulttool get --path "$xcresult_path" --format json 2>/dev/null | \
        jq -r '.issues._values[]? | "\(.message._value // "Unknown error"): \(.documentLocationInCreatingWorkspace.url._value // "")"' 2>/dev/null | \
        while IFS=': ' read -r error_msg file_path; do
            if [[ -n "$error_msg" ]]; then
                store_error "XCResult" "Unknown" "xcresult_issue" "$error_msg" \
                           "$file_path" "" "" "" "$error_msg: $file_path" "$build_id" "$xcresult_path"
            fi
        done || true
    fi
}

# Test error capture with a sample build
test_error_capture() {
    log "🧪 Testing error capture pipeline..."
    
    # Create a temporary Swift file with errors
    local test_dir="/tmp/xcode_error_test"
    local test_file="$test_dir/TestErrors.swift"
    
    mkdir -p "$test_dir"
    cat > "$test_file" <<EOF
import Foundation

// This will cause compile errors for testing
func testFunction() {
    let undeclaredVariable = nonExistentVariable  // Error: undeclared variable
    print(undeclaredVariable.someProperty)       // Error: accessing property on unknown type
    
    // Missing return statement
    func returningFunction() -> String {
        // Error: missing return
    }
}

// Syntax error
struct TestStruct {
    let property: String
    // Missing closing brace will cause error
EOF
    
    log "📄 Created test file with intentional errors: $test_file"
    
    # Try to compile it to generate errors
    local error_output
    error_output=$(swiftc "$test_file" -o "$test_dir/test_output" 2>&1) || true
    
    # Parse the compiler output
    if [[ -n "$error_output" ]]; then
        echo "$error_output" > "$test_dir/compiler_errors.log"
        parse_build_log "$test_dir/compiler_errors.log" "TestBuild" "Debug" "test_$(date +%s)"
        log "✅ Test error parsing completed"
    else
        log "⚠️ No compiler errors generated"
    fi
    
    # Clean up
    rm -rf "$test_dir"
}

# Query and display recent errors
query_errors() {
    local limit="${1:-10}"
    
    if [[ ! -f "$ERROR_DB" ]]; then
        log "❌ Database not found: $ERROR_DB"
        return 1
    fi
    
    log "📋 Recent Build Errors (limit: $limit)"
    
    sqlite3 -column -header "$ERROR_DB" <<EOF
SELECT 
    datetime(timestamp, 'localtime') as time,
    scheme,
    configuration,
    error_type,
    substr(error_message, 1, 60) as error_summary,
    substr(file_path, -30) as file
FROM build_errors
WHERE resolved = 0
ORDER BY timestamp DESC
LIMIT $limit;
EOF

    # Show summary statistics
    echo ""
    log "📊 Error Statistics:"
    sqlite3 "$ERROR_DB" <<EOF
SELECT 'Total Errors: ' || COUNT(*) FROM build_errors;
SELECT 'Unresolved: ' || COUNT(*) FROM build_errors WHERE resolved = 0;
SELECT 'Last 24h: ' || COUNT(*) FROM build_errors WHERE timestamp > datetime('now', '-24 hours');
EOF
}

# Main command handler
main() {
    case "${1:-monitor}" in
        init)
            init_database
            ;;
        monitor)
            init_database
            monitor_with_fswatch
            ;;
        test)
            init_database
            test_error_capture
            query_errors 5
            ;;
        query)
            query_errors "${2:-10}"
            ;;
        validate)
            log "🔍 Validating system..."
            
            # Check dependencies
            if [[ -z "$FSWATCH_PATH" ]]; then
                log "❌ fswatch not found in standard locations (/opt/homebrew/bin, /usr/local/bin, PATH)"
                exit 1
            else
                log "✅ fswatch found at: $FSWATCH_PATH"
            fi
            command -v sqlite3 >/dev/null || (log "❌ sqlite3 not installed"; exit 1)
            command -v curl >/dev/null || (log "❌ curl not installed"; exit 1)
            
            # Check database
            init_database
            
            # Check network
            curl -s --connect-timeout 3 "$PUSHGATEWAY_URL/metrics" >/dev/null || \
                (log "❌ Cannot reach Pushgateway at $PUSHGATEWAY_URL"; exit 1)
            
            # Check paths
            "${SCRIPT_DIR}/detect-build-paths.sh" dirs >/dev/null || \
                (log "❌ Cannot detect build paths"; exit 1)
            
            log "✅ System validation passed"
            ;;
        *)
            echo "Enhanced Xcode Build Error Monitor"
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  init       Initialize database"
            echo "  monitor    Start real-time monitoring (default)"
            echo "  test       Test error capture with sample errors"
            echo "  query [N]  Show recent errors"
            echo "  validate   Validate system setup"
            echo ""
            echo "Environment Variables:"
            echo "  PUSHGATEWAY_URL  Prometheus Pushgateway URL"
            echo "  LOKI_URL         Loki server URL"
            ;;
    esac
}

# Execute main function
main "$@"