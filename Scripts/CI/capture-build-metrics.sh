#!/bin/bash

#
# Capture and push Xcode build metrics to monitoring dashboard
# Works with both Xcode GUI and command-line builds
#

set -euo pipefail

# Configuration
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://localhost:9091}"
PROJECT_NAME="${TARGET_NAME:-Nestory}"
SCHEME="${SCHEME_NAME:-Unknown}"
CONFIGURATION="${CONFIGURATION:-Debug}"
PLATFORM="${PLATFORM_NAME:-iphonesimulator}"

# Build information from Xcode environment
BUILD_START="${BUILD_START_TIME:-$(date +%s)}"
BUILD_END="$(date +%s)"
BUILD_DURATION=$((BUILD_END - BUILD_START))

# Build result detection
BUILD_SUCCESS="true"
BUILD_ERRORS=0
BUILD_WARNINGS=0

# Parse build log if available, prefer JSON parsing for accuracy
if [ -n "${BUILD_LOG_PATH:-}" ] && [ -f "$BUILD_LOG_PATH" ]; then
    # Try JSON parsing first if xcbeautify is available
    JSON_LOG="${BUILD_LOG_PATH%.log}.json"
    
    if command -v xcbeautify >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        # Generate JSON output for parsing
        cat "$BUILD_LOG_PATH" | xcbeautify --reporter json > "$JSON_LOG" 2>/dev/null || true
        
        if [ -f "$JSON_LOG" ] && [ -s "$JSON_LOG" ]; then
            # Parse JSON for accurate counts
            BUILD_ERRORS=$(jq '[.[] | select(.type == "error")] | length' "$JSON_LOG" 2>/dev/null || echo 0)
            BUILD_WARNINGS=$(jq '[.[] | select(.type == "warning")] | length' "$JSON_LOG" 2>/dev/null || echo 0)
            
            # Clean up temp JSON file
            rm -f "$JSON_LOG"
        else
            # Fallback to text parsing
            BUILD_ERRORS=$(grep -c "error:" "$BUILD_LOG_PATH" 2>/dev/null || echo 0)
            BUILD_WARNINGS=$(grep -c "warning:" "$BUILD_LOG_PATH" 2>/dev/null || echo 0)
        fi
    else
        # Use text parsing if tools aren't available
        BUILD_ERRORS=$(grep -c "error:" "$BUILD_LOG_PATH" 2>/dev/null || echo 0)
        BUILD_WARNINGS=$(grep -c "warning:" "$BUILD_LOG_PATH" 2>/dev/null || echo 0)
    fi
    
    if [ "$BUILD_ERRORS" -gt 0 ]; then
        BUILD_SUCCESS="false"
    fi
fi

# Check for xcodebuild exit code
if [ "${XCODEBUILD_EXIT_CODE:-0}" -ne 0 ]; then
    BUILD_SUCCESS="false"
    BUILD_ERRORS=$((BUILD_ERRORS + 1))
fi

# Cache detection
CACHE_HIT="false"
if [ -d "$HOME/Library/Developer/Xcode/DerivedData/$PROJECT_NAME-*" ]; then
    # Check if build was incremental
    if [ "$BUILD_DURATION" -lt 30 ]; then
        CACHE_HIT="true"
    fi
fi

# Generate metrics timestamp
TIMESTAMP=$(date +%s)

# Prepare metrics
cat <<EOF > /tmp/build_metrics.txt
# Build metrics from Xcode
nestory_build_total{project="$PROJECT_NAME"} $(cat /tmp/nestory_build_count 2>/dev/null || echo 1)
nestory_build_duration_seconds{scheme="$SCHEME",configuration="$CONFIGURATION",cached="$CACHE_HIT"} $BUILD_DURATION
nestory_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION"} $BUILD_ERRORS
nestory_build_warnings_total{scheme="$SCHEME",configuration="$CONFIGURATION"} $BUILD_WARNINGS
nestory_build_timestamp{scheme="$SCHEME"} $TIMESTAMP
EOF

# Add success/failure metrics
if [ "$BUILD_SUCCESS" = "true" ]; then
    echo "nestory_build_success_total{project=\"$PROJECT_NAME\"} 1" >> /tmp/build_metrics.txt
else
    echo "nestory_build_failure_total{project=\"$PROJECT_NAME\"} 1" >> /tmp/build_metrics.txt
    
    # Capture error details
    if [ "$BUILD_ERRORS" -gt 0 ] && [ -n "${BUILD_LOG_PATH:-}" ]; then
        # Extract first error for tracking
        FIRST_ERROR=$(grep "error:" "$BUILD_LOG_PATH" 2>/dev/null | head -1 | sed 's/.*error: //' | tr -d '\n' | cut -c1-100)
        echo "nestory_build_error_info{error=\"$FIRST_ERROR\",scheme=\"$SCHEME\"} 1" >> /tmp/build_metrics.txt
    fi
fi

# Code metrics if available
if [ -n "${LOC_COUNT:-}" ]; then
    echo "nestory_code_lines_total $LOC_COUNT" >> /tmp/build_metrics.txt
fi

if [ -n "${FILE_COUNT:-}" ]; then
    echo "nestory_code_files_total $FILE_COUNT" >> /tmp/build_metrics.txt
fi

# Module compilation metrics
if [ -n "${MODULES_BUILT:-}" ]; then
    echo "nestory_modules_compiled_total $MODULES_BUILT" >> /tmp/build_metrics.txt
fi

# Push metrics to Pushgateway
if curl -s --data-binary @/tmp/build_metrics.txt "$PUSHGATEWAY_URL/metrics/job/xcode_build/instance/$HOSTNAME" > /dev/null 2>&1; then
    echo "✅ Build metrics pushed to dashboard"
else
    echo "⚠️ Failed to push metrics (Pushgateway may be offline)"
fi

# Increment build counter
CURRENT_COUNT=$(cat /tmp/nestory_build_count 2>/dev/null || echo 0)
echo $((CURRENT_COUNT + 1)) > /tmp/nestory_build_count

# Clean up
rm -f /tmp/build_metrics.txt

# Log summary
echo "📊 Build Metrics Summary:"
echo "  Duration: ${BUILD_DURATION}s"
echo "  Errors: $BUILD_ERRORS"
echo "  Warnings: $BUILD_WARNINGS"
echo "  Cache Hit: $CACHE_HIT"
echo "  Success: $BUILD_SUCCESS"