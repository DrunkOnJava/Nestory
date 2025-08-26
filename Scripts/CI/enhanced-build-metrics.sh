#!/bin/bash

#
# Enhanced Xcode build metrics with Issues Navigator error capture
# Captures real build errors, warnings, and diagnostics from Xcode
#

set -euo pipefail

# Configuration
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://localhost:9091}"
PROJECT_NAME="${TARGET_NAME:-${PRODUCT_NAME:-Nestory}}"
SCHEME="${SCHEME_NAME:-${TARGETNAME:-Unknown}}"
CONFIGURATION="${CONFIGURATION:-Debug}"

echo "🔧 Enhanced Build Metrics Capture Starting..."
echo "  Project: $PROJECT_NAME"
echo "  Scheme: $SCHEME"
echo "  Configuration: $CONFIGURATION"

# Build timing
BUILD_START="${BUILD_START_TIME:-$(date +%s)}"
BUILD_END="$(date +%s)"
BUILD_DURATION=$((BUILD_END - BUILD_START))

# Initialize counters
BUILD_ERRORS=0
BUILD_WARNINGS=0
BUILD_SUCCESS="true"

# Method 1: Check Xcode build log via DerivedData
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
PROJECT_BUILD_LOG=""

if [ -d "$DERIVED_DATA_PATH" ]; then
    # Find the most recent build log
    PROJECT_BUILD_LOG=$(find "$DERIVED_DATA_PATH" -name "*$PROJECT_NAME*" -type d 2>/dev/null | head -1)
    if [ -n "$PROJECT_BUILD_LOG" ]; then
        # Look for build logs in the project's DerivedData
        LOG_FILES=$(find "$PROJECT_BUILD_LOG" -name "*.txt" -o -name "*.log" 2>/dev/null | head -5)
        for log_file in $LOG_FILES; do
            if [ -f "$log_file" ]; then
                ERRORS_IN_FILE=$(grep -c "error:" "$log_file" 2>/dev/null || echo 0)
                WARNINGS_IN_FILE=$(grep -c "warning:" "$log_file" 2>/dev/null || echo 0)
                BUILD_ERRORS=$((BUILD_ERRORS + ERRORS_IN_FILE))
                BUILD_WARNINGS=$((BUILD_WARNINGS + WARNINGS_IN_FILE))
                
                echo "  📄 Found log: $log_file ($ERRORS_IN_FILE errors, $WARNINGS_IN_FILE warnings)"
            fi
        done
    fi
fi

# Method 2: Check environment variables from Xcode
if [ "${XCODEBUILD_EXIT_CODE:-0}" -ne 0 ]; then
    BUILD_SUCCESS="false"
    BUILD_ERRORS=$((BUILD_ERRORS + 1))
    echo "  ❌ Build failed with exit code: ${XCODEBUILD_EXIT_CODE:-0}"
fi

# Method 3: Parse recent system logs for Xcode build errors
RECENT_ERRORS=$(log show --last 5m --predicate 'process == "Xcode" AND messageType == "Error"' 2>/dev/null | grep -c "error" || echo 0)
if [ "$RECENT_ERRORS" -gt 0 ]; then
    BUILD_ERRORS=$((BUILD_ERRORS + RECENT_ERRORS))
    echo "  🔍 Found $RECENT_ERRORS recent Xcode errors in system logs"
fi

# Method 4: Check if build actually succeeded by looking for products
BUILT_PRODUCTS_DIR="${BUILT_PRODUCTS_DIR:-}"
if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -d "$BUILT_PRODUCTS_DIR" ]; then
    PRODUCTS_COUNT=$(ls -1 "$BUILT_PRODUCTS_DIR" 2>/dev/null | wc -l)
    if [ "$PRODUCTS_COUNT" -eq 0 ]; then
        BUILD_SUCCESS="false"
        BUILD_ERRORS=$((BUILD_ERRORS + 1))
        echo "  ⚠️ No build products found - marking as failed"
    else
        echo "  ✅ Found $PRODUCTS_COUNT build products"
    fi
fi

# Determine if build used cache
CACHE_HIT="false"
if [ "$BUILD_DURATION" -lt 10 ]; then
    CACHE_HIT="true"
    echo "  ⚡ Fast build detected - likely used cache"
elif [ -n "${SWIFT_INCREMENTAL_BUILDS:-}" ]; then
    CACHE_HIT="true"
    echo "  🔄 Incremental build detected"
fi

# Set build success based on errors
if [ "$BUILD_ERRORS" -gt 0 ]; then
    BUILD_SUCCESS="false"
fi

# Generate timestamp
TIMESTAMP=$(date +%s)

echo "📊 Build Summary:"
echo "  Duration: ${BUILD_DURATION}s"
echo "  Errors: $BUILD_ERRORS"
echo "  Warnings: $BUILD_WARNINGS"
echo "  Success: $BUILD_SUCCESS"
echo "  Cache Hit: $CACHE_HIT"

# Prepare enhanced metrics
cat <<EOF > /tmp/enhanced_build_metrics.txt
# Enhanced Xcode build metrics with real error tracking
nestory_build_total{project="$PROJECT_NAME",scheme="$SCHEME"} 1
nestory_build_duration_seconds{scheme="$SCHEME",configuration="$CONFIGURATION",cached="$CACHE_HIT"} $BUILD_DURATION
nestory_build_errors_total{scheme="$SCHEME",configuration="$CONFIGURATION"} $BUILD_ERRORS
nestory_build_warnings_total{scheme="$SCHEME",configuration="$CONFIGURATION"} $BUILD_WARNINGS
nestory_build_timestamp{scheme="$SCHEME",configuration="$CONFIGURATION"} $TIMESTAMP
EOF

# Success/failure metrics
if [ "$BUILD_SUCCESS" = "true" ]; then
    echo "nestory_build_success_total{project=\"$PROJECT_NAME\",scheme=\"$SCHEME\"} 1" >> /tmp/enhanced_build_metrics.txt
    echo "  ✅ Recording successful build"
else
    echo "nestory_build_failure_total{project=\"$PROJECT_NAME\",scheme=\"$SCHEME\"} 1" >> /tmp/enhanced_build_metrics.txt
    echo "  ❌ Recording failed build"
    
    # Capture specific error details for troubleshooting
    if [ "$BUILD_ERRORS" -gt 0 ]; then
        echo "nestory_build_error_details{project=\"$PROJECT_NAME\",type=\"compile_error\"} $BUILD_ERRORS" >> /tmp/enhanced_build_metrics.txt
    fi
fi

# Real-time performance metrics
LOAD_AVERAGE=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | tr -d ',')
if [ -n "$LOAD_AVERAGE" ]; then
    echo "nestory_system_load_average $LOAD_AVERAGE" >> /tmp/enhanced_build_metrics.txt
fi

# Memory usage during build
MEMORY_USAGE=$(ps aux | awk '/Xcode/ {sum += $6} END {print sum/1024}' 2>/dev/null || echo 0)
if [ "$MEMORY_USAGE" != "0" ]; then
    echo "nestory_xcode_memory_usage_mb $MEMORY_USAGE" >> /tmp/enhanced_build_metrics.txt
fi

# Push metrics to Pushgateway with better error handling
echo "🚀 Pushing metrics to dashboard..."
if curl -s --max-time 5 --data-binary @/tmp/enhanced_build_metrics.txt "$PUSHGATEWAY_URL/metrics/job/xcode_build/instance/$HOSTNAME" > /tmp/push_result.txt 2>&1; then
    echo "  ✅ Build metrics successfully pushed to dashboard"
else
    echo "  ⚠️ Failed to push metrics:"
    cat /tmp/push_result.txt
    echo "  Pushgateway URL: $PUSHGATEWAY_URL"
fi

# Show what we're pushing for debugging
echo "📤 Metrics being pushed:"
cat /tmp/enhanced_build_metrics.txt | head -10

# Clean up
rm -f /tmp/enhanced_build_metrics.txt /tmp/push_result.txt

echo "🎯 Enhanced build metrics capture complete!"