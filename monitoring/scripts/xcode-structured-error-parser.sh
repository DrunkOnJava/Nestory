#!/bin/bash

#
# Xcode Structured Error Parser
# Uses native xcresulttool API instead of primitive grep-based error detection
# Addresses security and reliability issues with proper Xcode integration
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
ERROR_DB="${PROJECT_ROOT}/monitoring/build-errors.db"
TEXTFILE_DIR="${TEXTFILE_DIR:-$HOME/metrics/textfile}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Initialize enhanced database with proper error categorization
init_database() {
    sqlite3 "$ERROR_DB" <<'EOF'
CREATE TABLE IF NOT EXISTS xcode_build_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    build_id TEXT NOT NULL,
    scheme TEXT,
    configuration TEXT,
    platform TEXT,
    result_bundle_path TEXT,
    build_status TEXT CHECK(build_status IN ('success', 'failure', 'timeout', 'cancelled')),
    exit_code INTEGER,
    duration_seconds REAL,
    total_errors INTEGER DEFAULT 0,
    total_warnings INTEGER DEFAULT 0,
    total_tests INTEGER DEFAULT 0,
    tests_passed INTEGER DEFAULT 0,
    tests_failed INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS xcode_errors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    build_id TEXT NOT NULL,
    error_category TEXT CHECK(error_category IN ('compile', 'link', 'test', 'warning', 'note', 'swift', 'clang', 'other')),
    error_type TEXT,
    severity TEXT CHECK(severity IN ('error', 'warning', 'note')),
    file_path TEXT,
    line_number INTEGER,
    column_number INTEGER,
    message TEXT NOT NULL,
    raw_output TEXT,
    target_name TEXT,
    source_location TEXT,
    FOREIGN KEY (build_id) REFERENCES xcode_build_results(build_id)
);

CREATE TABLE IF NOT EXISTS xcode_test_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    build_id TEXT NOT NULL,
    test_identifier TEXT NOT NULL,
    test_name TEXT,
    test_status TEXT CHECK(test_status IN ('passed', 'failed', 'skipped')),
    duration_seconds REAL,
    failure_message TEXT,
    target_name TEXT,
    device_name TEXT,
    FOREIGN KEY (build_id) REFERENCES xcode_build_results(build_id)
);

CREATE INDEX IF NOT EXISTS idx_build_timestamp ON xcode_build_results(timestamp);
CREATE INDEX IF NOT EXISTS idx_error_category ON xcode_errors(error_category);
CREATE INDEX IF NOT EXISTS idx_error_severity ON xcode_errors(severity);
CREATE INDEX IF NOT EXISTS idx_test_status ON xcode_test_results(test_status);
CREATE INDEX IF NOT EXISTS idx_build_status ON xcode_build_results(build_status);
EOF

    log "Enhanced database schema initialized at $ERROR_DB"
}

# Parse Xcode result bundle using structured xcresulttool API
parse_result_bundle() {
    local result_bundle_path="$1"
    local build_id="$2"
    local scheme="${3:-Unknown}"
    local configuration="${4:-Debug}"
    local platform="${5:-iphonesimulator}"
    
    if [[ ! -d "$result_bundle_path" ]]; then
        error "Result bundle not found: $result_bundle_path"
        return 1
    fi
    
    log "Parsing result bundle: $result_bundle_path"
    
    # Use new xcresulttool API (Xcode 16+)
    local temp_dir="/tmp/xcode_analysis_$$"
    mkdir -p "$temp_dir"
    
    # Extract build summary using structured API
    if ! xcrun xcresulttool get test-results --path "$result_bundle_path" --format json > "$temp_dir/test_results.json" 2>/dev/null; then
        # Fall back to legacy mode for older Xcode versions
        warning "New API failed, attempting legacy mode"
        if ! xcrun xcresulttool get object --path "$result_bundle_path" --id root --format json --legacy > "$temp_dir/root_object.json" 2>/dev/null; then
            error "Failed to extract data from result bundle"
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    # Parse build actions and results
    local build_status="success"
    local exit_code=0
    local duration_seconds=0
    local total_errors=0
    local total_warnings=0
    local total_tests=0
    local tests_passed=0
    local tests_failed=0
    
    # Extract build information from JSON
    if [[ -f "$temp_dir/test_results.json" ]]; then
        # Use jq to parse structured test results
        if command -v jq >/dev/null 2>&1; then
            total_tests=$(jq -r '.testResults[] | .tests[] | length' "$temp_dir/test_results.json" 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
            tests_failed=$(jq -r '.testResults[] | .tests[] | .[] | select(.testStatus == "Failure") | 1' "$temp_dir/test_results.json" 2>/dev/null | wc -l | tr -d ' ')
            tests_passed=$((total_tests - tests_failed))
            
            # Determine build status from test results
            if [[ $tests_failed -gt 0 ]]; then
                build_status="failure"
            fi
        fi
    fi
    
    # Store build result in database
    sqlite3 "$ERROR_DB" <<EOF
INSERT INTO xcode_build_results (
    build_id, scheme, configuration, platform, 
    result_bundle_path, build_status, exit_code, 
    duration_seconds, total_errors, total_warnings,
    total_tests, tests_passed, tests_failed
) VALUES (
    '$build_id', '$scheme', '$configuration', '$platform',
    '$result_bundle_path', '$build_status', $exit_code,
    $duration_seconds, $total_errors, $total_warnings,
    $total_tests, $tests_passed, $tests_failed
);
EOF
    
    # Parse individual errors and test failures
    parse_errors_from_bundle "$result_bundle_path" "$build_id" "$temp_dir"
    parse_test_failures_from_bundle "$result_bundle_path" "$build_id" "$temp_dir"
    
    # Generate metrics for textfile collector
    generate_structured_metrics "$build_id" "$scheme" "$configuration" "$platform"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    success "Parsed result bundle successfully: $build_id"
    return 0
}

# Parse errors using structured Xcode output
parse_errors_from_bundle() {
    local result_bundle_path="$1"
    local build_id="$2"
    local temp_dir="$3"
    
    log "Extracting structured error information..."
    
    # Extract build issues using xcresulttool
    if xcrun xcresulttool get issues --path "$result_bundle_path" --format json > "$temp_dir/issues.json" 2>/dev/null; then
        # Parse structured issues
        if command -v jq >/dev/null 2>&1 && [[ -s "$temp_dir/issues.json" ]]; then
            jq -r '.issues[] | @base64' "$temp_dir/issues.json" 2>/dev/null | while read -r issue_data; do
                local issue_json
                issue_json=$(echo "$issue_data" | base64 -d 2>/dev/null || echo '{}')
                
                # Extract error details
                local error_category="other"
                local error_type
                local severity
                local file_path
                local line_number
                local column_number
                local message
                local target_name
                
                error_type=$(echo "$issue_json" | jq -r '.type // "unknown"')
                severity=$(echo "$issue_json" | jq -r '.severity // "error"')
                file_path=$(echo "$issue_json" | jq -r '.documentLocationInCreatingWorkspace.url // ""' | sed 's|file://||')
                line_number=$(echo "$issue_json" | jq -r '.documentLocationInCreatingWorkspace.concreteLocation.line // 0')
                column_number=$(echo "$issue_json" | jq -r '.documentLocationInCreatingWorkspace.concreteLocation.column // 0')
                message=$(echo "$issue_json" | jq -r '.message // ""' | tr -d '\n\r' | head -c 500)
                target_name=$(echo "$issue_json" | jq -r '.targetName // ""')
                
                # Categorize error based on type and context
                case "$error_type" in
                    *"Swift"*|*"swift"*) error_category="swift" ;;
                    *"Clang"*|*"clang"*) error_category="clang" ;;
                    *"Link"*|*"link"*|*"ld"*) error_category="link" ;;
                    *"Test"*|*"test"*) error_category="test" ;;
                    *"Compile"*|*"compile"*) error_category="compile" ;;
                    *) 
                        # Try to categorize by file extension
                        case "$file_path" in
                            *.swift) error_category="swift" ;;
                            *.m|*.mm|*.c|*.cpp|*.h|*.hpp) error_category="clang" ;;
                            *) error_category="other" ;;
                        esac
                        ;;
                esac
                
                # Insert error into database with proper escaping
                sqlite3 "$ERROR_DB" <<EOF
INSERT INTO xcode_errors (
    build_id, error_category, error_type, severity,
    file_path, line_number, column_number, message,
    target_name
) VALUES (
    '$build_id', '$error_category', '$(echo "$error_type" | sed "s/'/''/g")', '$severity',
    '$(echo "$file_path" | sed "s/'/''/g")', $line_number, $column_number, 
    '$(echo "$message" | sed "s/'/''/g")', '$(echo "$target_name" | sed "s/'/''/g")'
);
EOF
                
                log "Recorded $severity: $error_category in $target_name"
            done
        fi
    else
        warning "Could not extract structured issues from result bundle"
    fi
}

# Parse test failures with detailed information
parse_test_failures_from_bundle() {
    local result_bundle_path="$1"
    local build_id="$2"
    local temp_dir="$3"
    
    log "Extracting test failure details..."
    
    # Extract test results using new API
    if [[ -f "$temp_dir/test_results.json" ]] && command -v jq >/dev/null 2>&1; then
        jq -r '.testResults[]? | .tests[]? | .[]? | @base64' "$temp_dir/test_results.json" 2>/dev/null | while read -r test_data; do
            local test_json
            test_json=$(echo "$test_data" | base64 -d 2>/dev/null || echo '{}')
            
            local test_identifier
            local test_name
            local test_status
            local duration_seconds
            local failure_message
            local target_name
            local device_name
            
            test_identifier=$(echo "$test_json" | jq -r '.identifier // ""')
            test_name=$(echo "$test_json" | jq -r '.name // ""')
            test_status=$(echo "$test_json" | jq -r '.testStatus // "unknown"' | tr '[:upper:]' '[:lower:]')
            duration_seconds=$(echo "$test_json" | jq -r '.duration // 0')
            failure_message=$(echo "$test_json" | jq -r '.failureMessage // ""' | tr -d '\n\r' | head -c 1000)
            target_name=$(echo "$test_json" | jq -r '.targetName // ""')
            device_name=$(echo "$test_json" | jq -r '.deviceName // ""')
            
            # Only insert if we have valid test data
            if [[ -n "$test_identifier" ]]; then
                sqlite3 "$ERROR_DB" <<EOF
INSERT INTO xcode_test_results (
    build_id, test_identifier, test_name, test_status,
    duration_seconds, failure_message, target_name, device_name
) VALUES (
    '$build_id', '$(echo "$test_identifier" | sed "s/'/''/g")', 
    '$(echo "$test_name" | sed "s/'/''/g")', '$test_status',
    $duration_seconds, '$(echo "$failure_message" | sed "s/'/''/g")',
    '$(echo "$target_name" | sed "s/'/''/g")', '$(echo "$device_name" | sed "s/'/''/g")'
);
EOF
            fi
        done
    fi
}

# Generate structured metrics for textfile collector
generate_structured_metrics() {
    local build_id="$1"
    local scheme="$2"
    local configuration="$3"
    local platform="$4"
    
    log "Generating structured metrics for build: $build_id"
    
    # Create textfile directory if it doesn't exist
    mkdir -p "$TEXTFILE_DIR"
    
    local temp_file="${TEXTFILE_DIR}/nestory_xcode_structured.prom.$$"
    
    # Query database for metrics
    local build_status
    local total_errors
    local total_warnings
    local total_tests
    local tests_passed
    local tests_failed
    
    read -r build_status total_errors total_warnings total_tests tests_passed tests_failed <<< $(sqlite3 "$ERROR_DB" "
        SELECT build_status, total_errors, total_warnings, total_tests, tests_passed, tests_failed
        FROM xcode_build_results 
        WHERE build_id = '$build_id'
    " | tr '|' ' ')
    
    # Generate comprehensive metrics
    cat <<EOF > "$temp_file"
# HELP nestory_xcode_build_result Build result from structured Xcode analysis
# TYPE nestory_xcode_build_result gauge
nestory_xcode_build_result{build_id="$build_id",scheme="$scheme",configuration="$configuration",platform="$platform",status="$build_status"} 1

# HELP nestory_xcode_errors_total Total errors by category from structured analysis
# TYPE nestory_xcode_errors_total counter
EOF
    
    # Add error category metrics
    sqlite3 "$ERROR_DB" "
        SELECT error_category, COUNT(*) 
        FROM xcode_errors 
        WHERE build_id = '$build_id' 
        GROUP BY error_category
    " | while IFS='|' read -r category count; do
        echo "nestory_xcode_errors_total{build_id=\"$build_id\",category=\"$category\",scheme=\"$scheme\"} $count" >> "$temp_file"
    done
    
    # Add test metrics
    cat <<EOF >> "$temp_file"

# HELP nestory_xcode_tests_total Total tests from structured analysis
# TYPE nestory_xcode_tests_total counter
nestory_xcode_tests_total{build_id="$build_id",scheme="$scheme",result="passed"} ${tests_passed:-0}
nestory_xcode_tests_total{build_id="$build_id",scheme="$scheme",result="failed"} ${tests_failed:-0}

# HELP nestory_xcode_build_termination_total Build termination tracking for SLO
# TYPE nestory_xcode_build_termination_total counter
nestory_xcode_build_termination_total{reason="$build_status",scheme="$scheme",configuration="$configuration"} 1
EOF
    
    # Atomic move to final location
    mv "$temp_file" "${TEXTFILE_DIR}/nestory_xcode_structured.prom"
    
    success "Structured metrics generated: ${TEXTFILE_DIR}/nestory_xcode_structured.prom"
}

# Main function to process Xcode result bundle
main() {
    case "${1:-help}" in
        parse)
            local result_bundle_path="${2:-}"
            local build_id="${3:-$(date +%Y%m%d_%H%M%S)_$$}"
            local scheme="${4:-Unknown}"
            local configuration="${5:-Debug}"
            local platform="${6:-iphonesimulator}"
            
            if [[ -z "$result_bundle_path" ]]; then
                error "Result bundle path required"
                echo "Usage: $0 parse <result_bundle_path> [build_id] [scheme] [configuration] [platform]"
                exit 1
            fi
            
            init_database
            parse_result_bundle "$result_bundle_path" "$build_id" "$scheme" "$configuration" "$platform"
            ;;
        init)
            init_database
            ;;
        status)
            if [[ -f "$ERROR_DB" ]]; then
                echo "Database: $ERROR_DB"
                echo "Recent builds:"
                sqlite3 "$ERROR_DB" "
                    SELECT build_id, scheme, build_status, total_errors, total_tests, timestamp
                    FROM xcode_build_results 
                    ORDER BY timestamp DESC 
                    LIMIT 10
                " | column -t -s '|'
            else
                warning "Database not found: $ERROR_DB"
            fi
            ;;
        *)
            echo "Xcode Structured Error Parser"
            echo "Uses native xcresulttool API instead of grep-based detection"
            echo ""
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  parse <bundle_path> [build_id] [scheme] [config] [platform]"
            echo "                          Parse Xcode result bundle with structured API"
            echo "  init                    Initialize database schema"
            echo "  status                  Show recent build results"
            echo ""
            echo "Environment Variables:"
            echo "  TEXTFILE_DIR           Directory for Node Exporter textfiles (default: ~/metrics/textfile)"
            ;;
    esac
}

# Run main function
main "$@"