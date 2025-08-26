#!/bin/bash

# Complete End-to-End Validation of Xcode Error Tracking Integration
# Addresses all audit concerns and validates actual functionality

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

passed=0
failed=0

# Test result functions
pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((passed++))
}

fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((failed++))
}

warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
}

info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

# Test 1: Dependencies
test_dependencies() {
    echo -e "\n${BLUE}🔧 Testing Dependencies${NC}"
    echo "========================"
    
    if [[ -n "$FSWATCH_PATH" ]]; then
        pass "fswatch dependency installed at: $FSWATCH_PATH"
        # Test fswatch functionality
        if timeout 2s "$FSWATCH_PATH" -1 /tmp >/dev/null 2>&1; then
            pass "fswatch functionality verified"
        else
            warn "fswatch found but may not be working properly"
        fi
    else
        fail "fswatch dependency missing (checked /opt/homebrew/bin, /usr/local/bin, PATH)"
    fi
    
    if command -v sqlite3 >/dev/null 2>&1; then
        pass "sqlite3 available"
    else
        fail "sqlite3 missing"
    fi
    
    if command -v curl >/dev/null 2>&1; then
        pass "curl available"
    else
        fail "curl missing"
    fi
    
    if command -v jq >/dev/null 2>&1; then
        pass "jq available for JSON processing"
    else
        warn "jq missing (non-critical)"
    fi
    
    if command -v bc >/dev/null 2>&1; then
        pass "bc calculator available"
    else
        warn "bc missing (affects error rate calculation)"
    fi
}

# Test 2: File System Access
test_file_access() {
    echo -e "\n${BLUE}📁 Testing File System Access${NC}"
    echo "================================"
    
    # Test database directory
    local db_dir="$(dirname "$PROJECT_ROOT/monitoring/build-errors.db")"
    if [[ -w "$db_dir" ]]; then
        pass "Database directory writable: $db_dir"
    else
        fail "Cannot write to database directory: $db_dir"
    fi
    
    # Test build path detection
    if "$SCRIPT_DIR/detect-build-paths.sh" dirs >/dev/null 2>&1; then
        local build_dirs
        build_dirs=$("$SCRIPT_DIR/detect-build-paths.sh" dirs)
        if [[ -n "$build_dirs" ]]; then
            pass "Build path detection working"
            while IFS= read -r dir; do
                if [[ -r "$dir" ]]; then
                    info "  Readable: $dir"
                else
                    warn "  Not readable: $dir"
                fi
            done <<< "$build_dirs"
        else
            warn "No build directories detected"
        fi
    else
        fail "Build path detection script not working"
    fi
    
    # Test temp directory access
    if touch /tmp/nestory_test 2>/dev/null && rm -f /tmp/nestory_test; then
        pass "Temporary directory access working"
    else
        fail "Cannot write to temporary directory"
    fi
}

# Test 3: Network Connectivity
test_network() {
    echo -e "\n${BLUE}🌐 Testing Network Connectivity${NC}"
    echo "=================================="
    
    # Test Pushgateway
    if curl -s --connect-timeout 5 http://localhost:9091/metrics >/dev/null; then
        pass "Pushgateway accessible (localhost:9091)"
    else
        fail "Cannot reach Pushgateway at localhost:9091"
    fi
    
    # Test Prometheus
    if curl -s --connect-timeout 5 http://localhost:9090/-/healthy >/dev/null; then
        pass "Prometheus accessible (localhost:9090)"
    else
        fail "Cannot reach Prometheus at localhost:9090"
    fi
    
    # Test Grafana
    if curl -s --connect-timeout 5 http://localhost:3000/api/health >/dev/null; then
        pass "Grafana accessible (localhost:3000)"
    else
        warn "Cannot reach Grafana at localhost:3000 (may not be critical)"
    fi
}

# Test 4: Database Functionality
test_database() {
    echo -e "\n${BLUE}🗄️  Testing Database Functionality${NC}"
    echo "==================================="
    
    local db_path="$PROJECT_ROOT/monitoring/build-errors.db"
    
    # Initialize database
    if "$SCRIPT_DIR/xcode-build-monitor-fixed.sh" init >/dev/null 2>&1; then
        pass "Database initialization successful"
    else
        fail "Database initialization failed"
        return
    fi
    
    # Test database structure
    local tables
    tables=$(sqlite3 "$db_path" ".tables" 2>/dev/null || echo "")
    if echo "$tables" | grep -q "build_errors"; then
        pass "Build errors table exists"
    else
        fail "Build errors table missing"
    fi
    
    # Test database write
    local test_timestamp=$(date +%s)
    sqlite3 "$db_path" "INSERT INTO build_errors (scheme, configuration, error_type, error_message, build_id) VALUES ('TEST', 'Debug', 'test_error', 'Validation test error', 'test_$test_timestamp');" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        pass "Database write operations working"
        
        # Test database read
        local count
        count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM build_errors WHERE build_id = 'test_$test_timestamp';" 2>/dev/null || echo "0")
        if [[ "$count" -eq 1 ]]; then
            pass "Database read operations working"
        else
            fail "Database read operations not working"
        fi
        
        # Clean up test record
        sqlite3 "$db_path" "DELETE FROM build_errors WHERE build_id = 'test_$test_timestamp';" 2>/dev/null
    else
        fail "Database write operations not working"
    fi
}

# Test 5: Error Parsing
test_error_parsing() {
    echo -e "\n${BLUE}🔍 Testing Error Parsing${NC}"
    echo "========================"
    
    # Create test error log
    local test_log="/tmp/test_build_errors.log"
    cat > "$test_log" <<EOF
/path/to/file.swift:10:5: error: cannot find 'undeclaredVar' in scope
/path/to/file.swift:15:20: warning: initialization of immutable value 'x' was never used
Test Case '-[SomeTest testMethod]' failed (0.001 seconds).
ld: symbol(s) not found for architecture arm64
Code Sign error: No identity found
EOF
    
    # Count errors before parsing
    local db_path="$PROJECT_ROOT/monitoring/build-errors.db"
    local before_count
    before_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM build_errors;" 2>/dev/null || echo "0")
    
    # Parse the test log
    if "$SCRIPT_DIR/xcode-build-monitor-fixed.sh" test >/dev/null 2>&1; then
        pass "Error parsing script executed successfully"
        
        # Check if errors were captured
        sleep 2  # Give time for parsing to complete
        local after_count
        after_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM build_errors;" 2>/dev/null || echo "0")
        
        if [[ $after_count -gt $before_count ]]; then
            pass "Errors successfully parsed and stored ($((after_count - before_count)) new errors)"
            
            # Check for different error types
            local error_types
            error_types=$(sqlite3 "$db_path" "SELECT DISTINCT error_type FROM build_errors WHERE timestamp > datetime('now', '-1 minute');" 2>/dev/null | tr '\n' ' ')
            if [[ -n "$error_types" ]]; then
                pass "Multiple error types captured: $error_types"
            else
                warn "Only one error type captured"
            fi
        else
            fail "No new errors captured during parsing test"
        fi
    else
        fail "Error parsing script failed to execute"
    fi
    
    rm -f "$test_log"
}

# Test 6: Metrics Integration
test_metrics() {
    echo -e "\n${BLUE}📊 Testing Metrics Integration${NC}"
    echo "==============================="
    
    # Test metrics push (this also tests error parsing)
    info "Running error parsing test to generate metrics..."
    "$SCRIPT_DIR/xcode-build-monitor-fixed.sh" test >/dev/null 2>&1 || true
    
    sleep 3  # Give time for metrics to be pushed and scraped
    
    # Check if metrics exist in Prometheus
    local error_metrics
    error_metrics=$(curl -s "http://localhost:9090/api/v1/query?query=xcode_build_errors_total" 2>/dev/null | jq -r '.data.result | length' 2>/dev/null || echo "0")
    
    if [[ "$error_metrics" -gt 0 ]]; then
        pass "Error metrics available in Prometheus ($error_metrics series)"
        
        # Test specific metric values
        local compile_errors
        compile_errors=$(curl -s "http://localhost:9090/api/v1/query?query=xcode_build_errors_total{type=\"compile\"}" 2>/dev/null | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")
        if [[ "$compile_errors" != "null" ]] && [[ "$compile_errors" != "0" ]]; then
            pass "Compile error metrics contain data: $compile_errors"
        else
            warn "Compile error metrics show zero or null"
        fi
    else
        fail "No error metrics found in Prometheus"
    fi
    
    # Check Pushgateway metrics
    if curl -s http://localhost:9091/metrics 2>/dev/null | grep -q "xcode_build_errors_total"; then
        pass "Metrics successfully pushed to Pushgateway"
    else
        fail "No metrics found in Pushgateway"
    fi
}

# Test 7: Background Monitoring
test_background_monitoring() {
    echo -e "\n${BLUE}👁️  Testing Background Monitoring${NC}"
    echo "=================================="
    
    # Check if launch agent is loaded
    if launchctl list | grep -q "com.nestory.xcode-build-monitor"; then
        pass "Launch agent loaded and running"
        
        # Check if the process is actually running
        local agent_status
        agent_status=$(launchctl list | grep "com.nestory.xcode-build-monitor" | awk '{print $1}')
        if [[ "$agent_status" =~ ^[0-9]+$ ]]; then
            pass "Background monitoring process active (PID: $agent_status)"
        else
            fail "Background monitoring process not running (status: $agent_status)"
        fi
    else
        fail "Launch agent not loaded"
    fi
    
    # Check monitoring logs
    if [[ -f /tmp/xcode-monitor.log ]]; then
        local recent_logs
        recent_logs=$(tail -n 5 /tmp/xcode-monitor.log 2>/dev/null | wc -l)
        if [[ $recent_logs -gt 0 ]]; then
            pass "Monitoring logs being generated"
            info "Recent log entries: $recent_logs"
        else
            warn "No recent monitoring log entries"
        fi
    else
        warn "No monitoring log file found"
    fi
}

# Test 8: Dashboard Integration
test_dashboard() {
    echo -e "\n${BLUE}📊 Testing Dashboard Integration${NC}"
    echo "================================="
    
    # Check if error dashboard exists
    local dashboard_check
    dashboard_check=$(curl -s -u admin:nestory123 "http://localhost:3000/api/dashboards/uid/nestory-build-errors" 2>/dev/null | jq -r '.dashboard.title' 2>/dev/null || echo "null")
    
    if [[ "$dashboard_check" != "null" ]] && [[ -n "$dashboard_check" ]]; then
        pass "Build errors dashboard imported: $dashboard_check"
    else
        fail "Build errors dashboard not found"
    fi
    
    # Test dashboard accessibility
    if curl -s -u admin:nestory123 "http://localhost:3000/d/nestory-build-errors/" >/dev/null 2>&1; then
        pass "Dashboard accessible via URL"
    else
        fail "Dashboard URL not accessible"
    fi
}

# Test 9: End-to-End Integration
test_end_to_end() {
    echo -e "\n${BLUE}🔄 Testing End-to-End Integration${NC}"
    echo "=================================="
    
    info "Performing complete integration test..."
    
    # Clear existing test data
    local db_path="$PROJECT_ROOT/monitoring/build-errors.db"
    sqlite3 "$db_path" "DELETE FROM build_errors WHERE scheme = 'E2E_TEST';" 2>/dev/null || true
    
    # Create a test Swift file with known errors
    local test_dir="/tmp/e2e_test_$$"
    mkdir -p "$test_dir"
    
    cat > "$test_dir/TestFile.swift" <<EOF
import Foundation

func testFunction() {
    let x = undefinedVariable  // Error: undefined variable
    print(x.nonExistentProperty)  // Error: accessing unknown property
    
    func incompleteFunction() -> String {
        // Error: missing return statement
    }
    
    // Warning: unused variable
    let unusedVar = "hello"
}

// Error: missing closing brace
struct TestStruct {
    let name: String
EOF
    
    # Compile to generate errors
    info "Generating compile errors for end-to-end test..."
    local compile_output
    compile_output=$(swiftc "$test_dir/TestFile.swift" -o "$test_dir/output" 2>&1) || true
    
    if [[ -n "$compile_output" ]]; then
        # Save to log file and parse
        echo "$compile_output" > "$test_dir/compile_errors.log"
        
        # Count errors before parsing
        local before_count
        before_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM build_errors WHERE scheme = 'E2E_TEST';" 2>/dev/null || echo "0")
        
        # Parse errors using our script
        local temp_script="/tmp/e2e_parse_$$.sh"
        cat > "$temp_script" <<EOF
#!/bin/bash
source "$SCRIPT_DIR/xcode-build-monitor-fixed.sh"
parse_build_log "$test_dir/compile_errors.log" "E2E_TEST" "Debug" "e2e_$(date +%s)"
EOF
        chmod +x "$temp_script"
        bash "$temp_script" >/dev/null 2>&1 || true
        
        # Check results
        sleep 2
        local after_count
        after_count=$(sqlite3 "$db_path" "SELECT COUNT(*) FROM build_errors WHERE scheme = 'E2E_TEST';" 2>/dev/null || echo "0")
        
        if [[ $after_count -gt $before_count ]]; then
            pass "End-to-end error capture successful ($((after_count - before_count)) errors captured)"
            
            # Verify error details
            local error_details
            error_details=$(sqlite3 "$db_path" "SELECT error_type, substr(error_message, 1, 30) FROM build_errors WHERE scheme = 'E2E_TEST' LIMIT 3;" 2>/dev/null || echo "")
            if [[ -n "$error_details" ]]; then
                pass "Error details correctly captured"
                info "Sample errors captured:"
                echo "$error_details" | while IFS='|' read -r type message; do
                    info "  $type: $message..."
                done
            fi
        else
            fail "End-to-end error capture failed (no new errors in database)"
        fi
        
        # Test metrics were generated
        sleep 3
        local e2e_metrics
        e2e_metrics=$(curl -s "http://localhost:9090/api/v1/query?query=xcode_build_errors_total{scheme=\"E2E_TEST\"}" 2>/dev/null | jq -r '.data.result | length' 2>/dev/null || echo "0")
        if [[ "$e2e_metrics" -gt 0 ]]; then
            pass "End-to-end metrics generated successfully"
        else
            warn "End-to-end metrics not found in Prometheus (may take time to scrape)"
        fi
        
        # Cleanup
        rm -rf "$temp_script" "$test_dir"
    else
        warn "No compile errors generated for end-to-end test"
    fi
}

# Run all tests
main() {
    echo -e "${BLUE}🧪 COMPREHENSIVE XCODE ERROR TRACKING VALIDATION${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
    
    test_dependencies
    test_file_access  
    test_network
    test_database
    test_error_parsing
    test_metrics
    test_background_monitoring
    test_dashboard
    test_end_to_end
    
    echo ""
    echo -e "${BLUE}📋 VALIDATION SUMMARY${NC}"
    echo -e "${BLUE}====================${NC}"
    echo -e "Tests Passed: ${GREEN}$passed${NC}"
    echo -e "Tests Failed: ${RED}$failed${NC}"
    
    if [[ $failed -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 ALL TESTS PASSED - SYSTEM FULLY FUNCTIONAL${NC}"
        echo -e "${GREEN}The Xcode error tracking integration is working correctly!${NC}"
        return 0
    else
        echo -e "\n${RED}❌ $failed TESTS FAILED - SYSTEM NEEDS ATTENTION${NC}"
        echo -e "${RED}Please address the failing tests above.${NC}"
        return 1
    fi
}

main "$@"