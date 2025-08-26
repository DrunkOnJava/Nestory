#!/bin/bash

# Enterprise UI Testing Framework - CI/CD Integration Script
# Provides comprehensive UI testing capabilities for the Nestory iOS app
# with enterprise-grade reporting and failure handling

set -euo pipefail

# ============================================================================
# CONFIGURATION AND CONSTANTS
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
readonly TEST_RESULTS_DIR="${HOME}/Desktop/NestoryEnterpriseTestResults_${TIMESTAMP}"
readonly LOG_FILE="${TEST_RESULTS_DIR}/test_execution.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m' # No Color

# Test configuration
readonly SIMULATOR_NAME="iPhone 16 Pro Max"
readonly DESTINATION="platform=iOS Simulator,name=${SIMULATOR_NAME}"
readonly PROJECT_FILE="Nestory.xcodeproj"
readonly TIMEOUT_SECONDS=600

# Test suite configuration
declare -A TEST_SUITES=(
    ["ui"]="Nestory-UIWiring:NestoryUITests:180"
    ["performance"]="Nestory-Performance:NestoryPerformanceUITests:300"
    ["accessibility"]="Nestory-Accessibility:NestoryAccessibilityUITests:240"
    ["smoke"]="Nestory-Smoke:NestoryUITests/SmokeTests:90"
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}[INFO]${NC} ${message}" | tee -a "${LOG_FILE}" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} ${message}" | tee -a "${LOG_FILE}" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} ${message}" | tee -a "${LOG_FILE}" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} ${message}" | tee -a "${LOG_FILE}" ;;
        "DEBUG") echo -e "${PURPLE}[DEBUG]${NC} ${message}" | tee -a "${LOG_FILE}" ;;
    esac
    
    echo "${timestamp} [${level}] ${message}" >> "${LOG_FILE}"
}

cleanup() {
    local exit_code=$?
    log "INFO" "Cleaning up test environment..."
    
    # Kill any remaining simulators
    xcrun simctl shutdown all 2>/dev/null || true
    
    # Generate final report
    generate_final_report
    
    if [ $exit_code -eq 0 ]; then
        log "SUCCESS" "Enterprise UI testing completed successfully"
    else
        log "ERROR" "Enterprise UI testing failed with exit code $exit_code"
    fi
    
    exit $exit_code
}

trap cleanup EXIT INT TERM

# ============================================================================
# SETUP AND VALIDATION FUNCTIONS
# ============================================================================

setup_environment() {
    log "INFO" "Setting up enterprise UI testing environment..."
    
    # Create results directory
    mkdir -p "${TEST_RESULTS_DIR}"/{logs,reports,screenshots,xcresults}
    
    # Initialize log file
    echo "=== Nestory Enterprise UI Testing Framework ===" > "${LOG_FILE}"
    echo "Timestamp: $(date)" >> "${LOG_FILE}"
    echo "Test Results Directory: ${TEST_RESULTS_DIR}" >> "${LOG_FILE}"
    echo "================================================" >> "${LOG_FILE}"
    
    # Change to project root
    cd "${PROJECT_ROOT}"
    
    # Validate environment
    validate_environment
}

validate_environment() {
    log "INFO" "Validating test environment..."
    
    # Check required tools
    local required_tools=("xcodebuild" "xcrun" "xcodegen")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log "ERROR" "Required tool '$tool' not found"
            exit 1
        fi
    done
    
    # Check simulator availability
    if ! xcrun simctl list devices | grep -q "${SIMULATOR_NAME}"; then
        log "ERROR" "Simulator '${SIMULATOR_NAME}' not available"
        exit 1
    fi
    
    # Check project file
    if [ ! -f "${PROJECT_FILE}/project.pbxproj" ]; then
        log "WARN" "Project file not found, generating..."
        xcodegen generate || {
            log "ERROR" "Failed to generate project file"
            exit 1
        }
    fi
    
    # Validate UI testing framework
    validate_ui_testing_framework
    
    log "SUCCESS" "Environment validation completed"
}

validate_ui_testing_framework() {
    log "INFO" "Validating UI testing framework structure..."
    
    local required_files=(
        "NestoryUITests/Core/Framework/NestoryUITestFramework.swift"
        "NestoryUITests/NestoryUITests.entitlements"
        "Config/UITesting.xcconfig"
        "Config/PerformanceTesting.xcconfig"
        "Config/AccessibilityTesting.xcconfig"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log "WARN" "Missing UI testing framework files:"
        for file in "${missing_files[@]}"; do
            log "WARN" "  - $file"
        done
        log "WARN" "Some tests may not work as expected"
    else
        log "SUCCESS" "UI testing framework validation completed"
    fi
}

# ============================================================================
# TEST EXECUTION FUNCTIONS
# ============================================================================

boot_simulator() {
    log "INFO" "Booting simulator: ${SIMULATOR_NAME}"
    
    xcrun simctl boot "${SIMULATOR_NAME}" 2>/dev/null || true
    sleep 3
    
    # Wait for simulator to be ready
    local max_wait=30
    local count=0
    while [ $count -lt $max_wait ]; do
        if xcrun simctl list devices | grep "${SIMULATOR_NAME}" | grep -q "Booted"; then
            log "SUCCESS" "Simulator booted successfully"
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    log "ERROR" "Simulator failed to boot within ${max_wait} seconds"
    return 1
}

run_test_suite() {
    local suite_name="$1"
    local suite_config="${TEST_SUITES[$suite_name]}"
    
    if [ -z "$suite_config" ]; then
        log "ERROR" "Unknown test suite: $suite_name"
        return 1
    fi
    
    IFS=':' read -r scheme target timeout <<< "$suite_config"
    
    log "INFO" "Running ${suite_name} test suite..."
    log "INFO" "Scheme: $scheme, Target: $target, Timeout: ${timeout}s"
    
    local result_bundle="${TEST_RESULTS_DIR}/xcresults/${suite_name}_results.xcresult"
    local test_log="${TEST_RESULTS_DIR}/logs/${suite_name}_test.log"
    
    # Ensure simulator is ready
    boot_simulator || return 1
    
    # Build command
    local build_cmd=(
        timeout "${timeout}"
        xcodebuild test
        -scheme "$scheme"
        -destination "$DESTINATION"
        -only-testing "$target"
        -resultBundlePath "$result_bundle"
        -quiet
        -parallelizeTargets
        -showBuildTimingSummary
    )
    
    log "INFO" "Executing: ${build_cmd[*]}"
    
    local start_time=$(date +%s)
    
    if "${build_cmd[@]}" 2>&1 | tee "$test_log"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log "SUCCESS" "${suite_name} test suite completed in ${duration}s"
        
        # Extract screenshots
        extract_screenshots "$result_bundle" "$suite_name"
        
        return 0
    else
        local exit_code=${PIPESTATUS[0]}
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log "ERROR" "${suite_name} test suite failed in ${duration}s (exit code: $exit_code)"
        
        # Still extract screenshots for failure analysis
        extract_screenshots "$result_bundle" "$suite_name"
        
        return 1
    fi
}

extract_screenshots() {
    local result_bundle="$1"
    local suite_name="$2"
    
    if [ ! -d "$result_bundle" ]; then
        log "WARN" "Result bundle not found: $result_bundle"
        return 1
    fi
    
    local screenshot_dir="${TEST_RESULTS_DIR}/screenshots/${suite_name}"
    mkdir -p "$screenshot_dir"
    
    log "INFO" "Extracting screenshots for ${suite_name}..."
    
    # Use the project's screenshot extraction script
    if [ -f "${PROJECT_ROOT}/Scripts/extract-ui-test-screenshots.sh" ]; then
        "${PROJECT_ROOT}/Scripts/extract-ui-test-screenshots.sh" "$result_bundle" "$screenshot_dir" || {
            log "WARN" "Failed to extract screenshots using project script"
        }
    else
        log "WARN" "Screenshot extraction script not found"
    fi
    
    local screenshot_count=$(find "$screenshot_dir" -name "*.png" | wc -l)
    log "INFO" "Extracted $screenshot_count screenshots for ${suite_name}"
}

# ============================================================================
# REPORTING FUNCTIONS
# ============================================================================

generate_test_report() {
    local suite_name="$1"
    local success="$2"
    
    local report_file="${TEST_RESULTS_DIR}/reports/${suite_name}_report.json"
    
    cat > "$report_file" <<EOF
{
    "suite": "$suite_name",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "success": $success,
    "simulator": "$SIMULATOR_NAME",
    "scheme": "$(echo "${TEST_SUITES[$suite_name]}" | cut -d':' -f1)",
    "target": "$(echo "${TEST_SUITES[$suite_name]}" | cut -d':' -f2)",
    "timeout": "$(echo "${TEST_SUITES[$suite_name]}" | cut -d':' -f3)",
    "results_location": "${TEST_RESULTS_DIR}"
}
EOF
    
    log "INFO" "Generated test report for ${suite_name}: $report_file"
}

generate_final_report() {
    log "INFO" "Generating final test report..."
    
    local final_report="${TEST_RESULTS_DIR}/final_report.html"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    cat > "$final_report" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nestory Enterprise UI Testing Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; background: #f8f9fa; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #007AFF; border-bottom: 3px solid #007AFF; padding-bottom: 15px; margin-bottom: 30px; }
        .header h1 { margin: 0; font-size: 2.5em; }
        .timestamp { color: #6c757d; font-size: 0.9em; margin-top: 5px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 30px 0; }
        .metric-card { padding: 20px; border-radius: 8px; text-align: center; }
        .metric-card h3 { margin: 0 0 10px 0; font-size: 2em; }
        .metric-card p { margin: 0; color: #6c757d; }
        .success { background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%); border-left: 5px solid #28a745; }
        .warning { background: linear-gradient(135deg, #fff3cd 0%, #fdeaa7 100%); border-left: 5px solid #ffc107; }
        .error { background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%); border-left: 5px solid #dc3545; }
        .info { background: linear-gradient(135deg, #d1ecf1 0%, #b8daff 100%); border-left: 5px solid #007AFF; }
        .section { margin: 30px 0; padding: 25px; border-radius: 8px; background: #f8f9fa; }
        .section h2 { color: #495057; margin-top: 0; }
        .test-suite { margin: 15px 0; padding: 15px; border-radius: 5px; background: white; border-left: 4px solid #007AFF; }
        .test-suite.success { border-left-color: #28a745; }
        .test-suite.failed { border-left-color: #dc3545; }
        .file-list { list-style: none; padding: 0; }
        .file-list li { padding: 8px 0; border-bottom: 1px solid #e9ecef; }
        .file-list li:last-child { border-bottom: none; }
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; color: white; }
        .badge.success { background: #28a745; }
        .badge.failed { background: #dc3545; }
        .framework-info { background: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏢 Nestory Enterprise UI Testing Report</h1>
            <p class="timestamp">Generated: $timestamp</p>
        </div>
        
        <div class="framework-info">
            <h2>🔧 Enterprise UI Testing Framework</h2>
            <p>Comprehensive UI testing with enterprise-grade validation, performance monitoring, and accessibility compliance.</p>
            <p><strong>Test Results Location:</strong> $TEST_RESULTS_DIR</p>
        </div>
        
        <div class="summary">
EOF

    # Add test suite results
    local total_suites=0
    local successful_suites=0
    local total_screenshots=0
    
    for suite in "${!TEST_SUITES[@]}"; do
        ((total_suites++))
        local report_file="${TEST_RESULTS_DIR}/reports/${suite}_report.json"
        if [ -f "$report_file" ]; then
            if grep -q '"success": true' "$report_file" 2>/dev/null; then
                ((successful_suites++))
            fi
        fi
        
        local screenshot_count=$(find "${TEST_RESULTS_DIR}/screenshots/${suite}" -name "*.png" 2>/dev/null | wc -l || echo 0)
        ((total_screenshots += screenshot_count))
    done
    
    cat >> "$final_report" <<EOF
            <div class="metric-card success">
                <h3>$successful_suites/$total_suites</h3>
                <p>Test Suites Passed</p>
            </div>
            <div class="metric-card info">
                <h3>$total_screenshots</h3>
                <p>Screenshots Captured</p>
            </div>
            <div class="metric-card info">
                <h3>$(find "${TEST_RESULTS_DIR}/xcresults" -name "*.xcresult" 2>/dev/null | wc -l || echo 0)</h3>
                <p>Result Bundles</p>
            </div>
        </div>
        
        <div class="section">
            <h2>📊 Test Suite Results</h2>
EOF

    # Add individual test suite results
    for suite in "${!TEST_SUITES[@]}"; do
        local success_class="failed"
        local badge_class="failed"
        local status="FAILED"
        
        local report_file="${TEST_RESULTS_DIR}/reports/${suite}_report.json"
        if [ -f "$report_file" ] && grep -q '"success": true' "$report_file" 2>/dev/null; then
            success_class="success"
            badge_class="success"
            status="PASSED"
        fi
        
        local screenshot_count=$(find "${TEST_RESULTS_DIR}/screenshots/${suite}" -name "*.png" 2>/dev/null | wc -l || echo 0)
        
        cat >> "$final_report" <<EOF
            <div class="test-suite $success_class">
                <strong>$(echo "$suite" | tr '[:lower:]' '[:upper:]') Test Suite</strong>
                <span class="badge $badge_class">$status</span>
                <p>Screenshots: $screenshot_count | Scheme: $(echo "${TEST_SUITES[$suite]}" | cut -d':' -f1)</p>
            </div>
EOF
    done
    
    cat >> "$final_report" <<EOF
        </div>
        
        <div class="section">
            <h2>📁 Generated Files</h2>
            <ul class="file-list">
                <li><strong>Test Logs:</strong> ${TEST_RESULTS_DIR}/logs/</li>
                <li><strong>Screenshots:</strong> ${TEST_RESULTS_DIR}/screenshots/</li>
                <li><strong>Result Bundles:</strong> ${TEST_RESULTS_DIR}/xcresults/</li>
                <li><strong>Reports:</strong> ${TEST_RESULTS_DIR}/reports/</li>
            </ul>
        </div>
        
        <div class="section">
            <h2>🛠 Framework Configuration</h2>
            <p><strong>Simulator:</strong> $SIMULATOR_NAME</p>
            <p><strong>Project:</strong> $PROJECT_FILE</p>
            <p><strong>Test Timeout:</strong> $TIMEOUT_SECONDS seconds</p>
            <p><strong>Framework Version:</strong> Enterprise UI Testing Framework v1.0</p>
        </div>
    </div>
</body>
</html>
EOF
    
    log "SUCCESS" "Final report generated: $final_report"
    
    # Open report if running in interactive mode
    if [ -t 1 ] && command -v open &> /dev/null; then
        open "$final_report"
    fi
}

# ============================================================================
# MAIN EXECUTION FUNCTION
# ============================================================================

main() {
    local suites_to_run=()
    local run_all=false
    local continue_on_failure=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                run_all=true
                shift
                ;;
            --suite)
                suites_to_run+=("$2")
                shift 2
                ;;
            --continue-on-failure)
                continue_on_failure=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Setup environment
    setup_environment
    
    # Determine which suites to run
    if [ "$run_all" = true ]; then
        suites_to_run=($(printf '%s\n' "${!TEST_SUITES[@]}" | sort))
    elif [ ${#suites_to_run[@]} -eq 0 ]; then
        # Default to running all suites
        suites_to_run=($(printf '%s\n' "${!TEST_SUITES[@]}" | sort))
    fi
    
    log "INFO" "Starting enterprise UI testing with suites: ${suites_to_run[*]}"
    
    local overall_success=true
    
    # Run test suites
    for suite in "${suites_to_run[@]}"; do
        log "INFO" "========================================="
        log "INFO" "Running test suite: $suite"
        log "INFO" "========================================="
        
        local suite_start_time=$(date +%s)
        
        if run_test_suite "$suite"; then
            local suite_end_time=$(date +%s)
            local suite_duration=$((suite_end_time - suite_start_time))
            log "SUCCESS" "✅ $suite test suite completed successfully in ${suite_duration}s"
            generate_test_report "$suite" true
        else
            local suite_end_time=$(date +%s)
            local suite_duration=$((suite_end_time - suite_start_time))
            log "ERROR" "❌ $suite test suite failed in ${suite_duration}s"
            generate_test_report "$suite" false
            overall_success=false
            
            if [ "$continue_on_failure" = false ]; then
                log "ERROR" "Stopping execution due to test failure"
                break
            else
                log "WARN" "Continuing with next test suite despite failure"
            fi
        fi
    done
    
    # Final results
    if [ "$overall_success" = true ]; then
        log "SUCCESS" "🎉 All test suites completed successfully!"
        exit 0
    else
        log "ERROR" "💥 One or more test suites failed"
        exit 1
    fi
}

show_usage() {
    cat <<EOF
Nestory Enterprise UI Testing Framework

Usage: $0 [OPTIONS]

Options:
    --all                    Run all test suites
    --suite SUITE_NAME       Run specific test suite (ui, performance, accessibility, smoke)
    --continue-on-failure    Continue running other suites even if one fails
    --help                   Show this help message

Examples:
    $0 --all                           # Run all test suites
    $0 --suite ui                      # Run only UI tests
    $0 --suite ui --suite smoke        # Run UI and smoke tests
    $0 --all --continue-on-failure     # Run all tests, don't stop on failure

Available test suites:
$(for suite in "${!TEST_SUITES[@]}"; do
    echo "    - $suite"
done | sort)

EOF
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi