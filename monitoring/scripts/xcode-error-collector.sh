#!/bin/bash

# Enhanced Xcode Error Collector for Dashboard Integration
# Works with both GUI and command-line builds

set -euo pipefail

# Configuration
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://localhost:9091}"
LOKI_URL="${LOKI_URL:-http://localhost:3100}"
BUILD_LOG="${BUILD_LOG:-}"
SCHEME="${SCHEME_NAME:-Nestory-Dev}"
CONFIGURATION="${CONFIGURATION:-Debug}"
INSTANCE="${HOSTNAME:-$(hostname)}"

# Parse build log for detailed error information
parse_and_push_errors() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        echo "Warning: Build log not found: $log_file"
        return 1
    fi
    
    # Initialize counters
    local compile_errors=0
    local warnings=0
    local test_failures=0
    local linker_errors=0
    local codesign_errors=0
    
    # Parse different error types
    while IFS= read -r line; do
        # Compile errors
        if echo "$line" | grep -q "error:"; then
            ((compile_errors++))
            
            # Extract error details
            local file=$(echo "$line" | sed -n 's/^\([^:]*\):[0-9]*:[0-9]*: error:.*/\1/p')
            local line_num=$(echo "$line" | sed -n 's/^[^:]*:\([0-9]*\):[0-9]*: error:.*/\1/p')
            local error_msg=$(echo "$line" | sed -n 's/^.*error: \(.*\)/\1/p' | head -c 100)
            
            # Push specific error info as a metric with labels
            if [[ -n "$error_msg" ]]; then
                cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/xcode_errors/instance/${INSTANCE}"
# TYPE xcode_build_error_info gauge
xcode_build_error_info{scheme="$SCHEME",configuration="$CONFIGURATION",file="$file",line="$line_num",error_message="$error_msg"} 1
EOF
            fi
            
            # Send to Loki for log aggregation
            send_to_loki "error" "$line"
        fi
        
        # Warnings
        if echo "$line" | grep -q "warning:"; then
            ((warnings++))
            send_to_loki "warning" "$line"
        fi
        
        # Test failures
        if echo "$line" | grep -qE "(Test Case .* failed|XCTAssert.*failed|failed .* test)"; then
            ((test_failures++))
            send_to_loki "test_failure" "$line"
        fi
        
        # Linker errors
        if echo "$line" | grep -qE "(Undefined symbols|duplicate symbol|ld: )"; then
            ((linker_errors++))
            send_to_loki "linker_error" "$line"
        fi
        
        # Code signing errors
        if echo "$line" | grep -qi "code sign"; then
            ((codesign_errors++))
            send_to_loki "codesign_error" "$line"
        fi
    done < "$log_file"
    
    # Push aggregated metrics to Prometheus
    cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/xcode_build/instance/${INSTANCE}"
# TYPE xcode_build_errors_total gauge
xcode_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION",type="compile"} $compile_errors
xcode_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION",type="warning"} $warnings
xcode_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION",type="test"} $test_failures
xcode_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION",type="linker"} $linker_errors
xcode_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION",type="codesign"} $codesign_errors

# Total error count
xcode_build_error_count{scheme="$SCHEME",configuration="$CONFIGURATION"} $((compile_errors + linker_errors + codesign_errors))
EOF
    
    echo "📊 Pushed error metrics: Errors=$compile_errors, Warnings=$warnings, Tests=$test_failures"
    
    # Return error code if build had errors
    [[ $compile_errors -eq 0 && $linker_errors -eq 0 && $codesign_errors -eq 0 ]]
}

# Send log entry to Loki
send_to_loki() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +%s%N)
    
    # Escape special characters in message
    message=$(echo "$message" | sed 's/"/\\"/g')
    
    # Create Loki push request
    local json_payload=$(cat <<EOF
{
  "streams": [
    {
      "stream": {
        "job": "xcode-build",
        "scheme": "$SCHEME",
        "configuration": "$CONFIGURATION",
        "level": "$level"
      },
      "values": [
        ["$timestamp", "$message"]
      ]
    }
  ]
}
EOF
)
    
    # Push to Loki (non-blocking)
    curl -s -X POST "${LOKI_URL}/loki/api/v1/push" \
        -H "Content-Type: application/json" \
        -d "$json_payload" 2>/dev/null &
}

# Monitor Xcode's live build output (for GUI builds)
monitor_xcode_logs() {
    echo "👁️ Monitoring Xcode build logs..."
    
    # Find the most recent build log
    local derived_data="${HOME}/Library/Developer/Xcode/DerivedData"
    
    # Watch for new activity logs
    while true; do
        # Find logs modified in the last minute
        local recent_log=$(find "$derived_data" \
            -name "*.xcactivitylog" \
            -mmin -1 \
            2>/dev/null | head -1)
        
        if [[ -n "$recent_log" ]]; then
            echo "📝 Found new build log: $recent_log"
            
            # Decompress and parse (xcactivitylog files are gzipped)
            local temp_log="/tmp/xcode_build_$(date +%s).log"
            gunzip -c "$recent_log" > "$temp_log" 2>/dev/null || true
            
            # Parse errors
            parse_and_push_errors "$temp_log"
            
            # Clean up
            rm -f "$temp_log"
        fi
        
        sleep 5
    done
}

# Extract errors from xcresult bundle
parse_xcresult() {
    local xcresult_path="$1"
    
    if [[ ! -d "$xcresult_path" ]]; then
        echo "Warning: xcresult bundle not found: $xcresult_path"
        return 1
    fi
    
    echo "📦 Parsing xcresult bundle: $xcresult_path"
    
    # Export diagnostics
    xcrun xcresulttool get --path "$xcresult_path" \
        --format json 2>/dev/null | \
        jq -r '.issues._values[]? | 
            "\(.message._value // "Unknown error"): \(.documentLocationInCreatingWorkspace.url._value // "Unknown file"):\(.documentLocationInCreatingWorkspace.concreteTypeName._value // "")"' | \
        while IFS= read -r error; do
            send_to_loki "xcresult_error" "$error"
        done
    
    # Get test results
    xcrun xcresulttool get --path "$xcresult_path" \
        --format json 2>/dev/null | \
        jq -r '.metrics.testsCount._value // 0' | \
        while read count; do
            cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/xcode_tests/instance/${INSTANCE}"
# TYPE xcode_test_count gauge
xcode_test_count{scheme="$SCHEME",configuration="$CONFIGURATION"} $count
EOF
        done
}

# Main execution
main() {
    case "${1:-monitor}" in
        parse)
            # Parse a specific log file
            if [[ -n "${2:-}" ]]; then
                parse_and_push_errors "$2"
            else
                echo "Usage: $0 parse <log_file>"
                exit 1
            fi
            ;;
        
        xcresult)
            # Parse xcresult bundle
            if [[ -n "${2:-}" ]]; then
                parse_xcresult "$2"
            else
                echo "Usage: $0 xcresult <path_to.xcresult>"
                exit 1
            fi
            ;;
        
        monitor)
            # Monitor live Xcode builds
            monitor_xcode_logs
            ;;
        
        push-test)
            # Push test metrics for dashboard testing
            cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/xcode_build/instance/test"
xcode_build_errors_total{scheme="Nestory-Dev",configuration="Debug",type="compile"} 3
xcode_build_errors_total{scheme="Nestory-Dev",configuration="Debug",type="warning"} 12
xcode_build_errors_total{scheme="Nestory-Dev",configuration="Debug",type="test"} 1
xcode_build_result{scheme="Nestory-Dev",configuration="Debug"} 1
xcode_build_duration_seconds{scheme="Nestory-Dev",configuration="Debug"} 45.2
EOF
            echo "✅ Test metrics pushed"
            ;;
        
        *)
            echo "Xcode Error Collector for Dashboard"
            echo ""
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  parse <log>    Parse specific build log file"
            echo "  xcresult <path> Parse xcresult bundle"
            echo "  monitor        Monitor live Xcode builds (default)"
            echo "  push-test      Push test metrics"
            echo ""
            echo "Environment Variables:"
            echo "  PUSHGATEWAY_URL  Prometheus Pushgateway (default: http://localhost:9091)"
            echo "  LOKI_URL         Loki server (default: http://localhost:3100)"
            echo "  SCHEME_NAME      Xcode scheme (default: Nestory-Dev)"
            echo "  CONFIGURATION    Build configuration (default: Debug)"
            ;;
    esac
}

# Handle script being sourced vs executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi