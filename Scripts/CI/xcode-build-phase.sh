#!/bin/bash

#
# Xcode Build Phase Script - Metrics Collection
# Add this as a Run Script Build Phase in Xcode
#

# Export build environment for metrics script
export BUILD_START_TIME="${BUILD_START_TIME:-$(date +%s)}"
export BUILD_LOG_PATH="${BUILD_ROOT}/build.log"
export SCHEME_NAME="${SCHEME_NAME}"
export CONFIGURATION="${CONFIGURATION}"
export TARGET_NAME="${TARGET_NAME}"
export PLATFORM_NAME="${PLATFORM_NAME}"

# Capture build output
exec > >(tee -a "$BUILD_LOG_PATH")
exec 2>&1

# Count code metrics
export LOC_COUNT=$(find "${SRCROOT}" -name "*.swift" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
export FILE_COUNT=$(find "${SRCROOT}" -name "*.swift" 2>/dev/null | wc -l)
export MODULES_BUILT=$(find "${BUILD_ROOT}" -name "*.swiftmodule" 2>/dev/null | wc -l)

# Run metrics capture (non-blocking to not slow down build)
"${SRCROOT}/Scripts/CI/capture-build-metrics.sh" &

# Continue with normal build
exit 0