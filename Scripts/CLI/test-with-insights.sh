#!/bin/bash

# test-with-insights.sh
# Reliable xcodebuild CLI workflow with coverage and result bundles
# Usage: ./Scripts/CLI/test-with-insights.sh [--open-results]

set -euo pipefail

# Configuration
PROJECT="Nestory.xcodeproj"
SCHEME="Nestory-Dev"
CONFIG="Debug"
ARTIFACTS_DIR="./BuildArtifacts"
SIMULATOR="iPhone 16 Pro Max"
OS_VERSION="18.6"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Clean up function
cleanup() {
    if [ -n "${TEMP_DD:-}" ] && [ -d "$TEMP_DD" ]; then
        log_info "Cleaning up temporary DerivedData: $TEMP_DD"
        rm -rf "$TEMP_DD"
    fi
}

trap cleanup EXIT

# Parse arguments
OPEN_RESULTS=false
for arg in "$@"; do
    case $arg in
        --open-results)
            OPEN_RESULTS=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--open-results]"
            echo "  --open-results: Open the .xcresult bundle in Xcode after completion"
            exit 0
            ;;
    esac
done

# Ensure simulator exists
log_info "Verifying simulator availability..."
if xcrun simctl list devices | grep -q "$SIMULATOR"; then
    log_success "Simulator '$SIMULATOR' found"
    DEST="platform=iOS Simulator,name=$SIMULATOR"
else
    log_error "Simulator '$SIMULATOR' not found. Available simulators:"
    xcrun simctl list devices | grep "iPhone" | head -5
    exit 1
fi

log_success "Using destination: $DEST"

# Create artifacts directory
mkdir -p "$ARTIFACTS_DIR"

# Generate unique result bundle path with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_BUNDLE="$ARTIFACTS_DIR/NestoryTests_$TIMESTAMP.xcresult"

log_info "Result bundle will be saved to: $RESULT_BUNDLE"

# Boot simulator if needed
log_info "Ensuring simulator is booted..."
SIMULATOR_ID=$(xcrun simctl list devices | grep "$SIMULATOR" | grep -v "unavailable" | head -1 | grep -o '[A-F0-9-]*')
if [ -n "$SIMULATOR_ID" ]; then
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
fi

# Run tests with comprehensive options
log_info "Running tests with coverage and performance metrics..."

# Use temporary DerivedData to avoid conflicts
TEMP_DD="$HOME/tmp/NestoryDD_$TIMESTAMP"
mkdir -p "$TEMP_DD"

xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -destination "$DEST" \
    -derivedDataPath "$TEMP_DD" \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULT_BUNDLE" \
    -parallel-testing-enabled NO \
    -maximum-concurrent-test-simulator-destinations 1 \
    -test-timeouts-enabled YES \
    -only-testing:NestoryTests \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    | tee "$ARTIFACTS_DIR/test_output_$TIMESTAMP.log"

BUILD_EXIT_CODE=${PIPESTATUS[0]}

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    log_success "Tests completed successfully!"
    
    # Verify result bundle was created
    if [ -d "$RESULT_BUNDLE" ]; then
        BUNDLE_SIZE=$(du -sh "$RESULT_BUNDLE" | cut -f1)
        log_success "Result bundle created: $BUNDLE_SIZE"
        
        # Extract comprehensive coverage reports
        if command -v xcrun >/dev/null 2>&1; then
            log_info "Extracting comprehensive coverage reports..."
            
            # Basic coverage summary (human-readable)
            xcrun xccov view --report "$RESULT_BUNDLE" > "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt" 2>/dev/null || true
            
            # Detailed coverage report with line-by-line info
            xcrun xccov view --report --json "$RESULT_BUNDLE" > "$ARTIFACTS_DIR/coverage_detailed_$TIMESTAMP.json" 2>/dev/null || true
            
            # File-by-file coverage breakdown
            xcrun xccov view --file-list "$RESULT_BUNDLE" > "$ARTIFACTS_DIR/coverage_files_$TIMESTAMP.txt" 2>/dev/null || true
            
            # Coverage percentage extraction for CI/dashboard
            if [ -f "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt" ]; then
                COVERAGE_PERCENT=$(grep -E "^\s*[0-9]+\.[0-9]+%" "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt" | head -1 | grep -o "[0-9]\+\.[0-9]\+")
                if [ -n "$COVERAGE_PERCENT" ]; then
                    echo "$COVERAGE_PERCENT" > "$ARTIFACTS_DIR/coverage_percentage_$TIMESTAMP.txt"
                    log_success "Overall coverage: ${COVERAGE_PERCENT}%"
                fi
            fi
            
            # Generate human-friendly HTML report (if possible)
            if [ -f "$ARTIFACTS_DIR/coverage_detailed_$TIMESTAMP.json" ]; then
                log_info "Generating HTML coverage report..."
                
                # Create a simple HTML report from JSON data
                cat > "$ARTIFACTS_DIR/coverage_report_$TIMESTAMP.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Nestory Test Coverage Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
        .header { color: #007AFF; border-bottom: 2px solid #007AFF; padding-bottom: 10px; }
        .summary { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .file-list { margin-top: 20px; }
        .file { margin: 10px 0; padding: 10px; background: white; border: 1px solid #ddd; border-radius: 4px; }
        .coverage-high { color: #34c759; }
        .coverage-medium { color: #ff9500; }
        .coverage-low { color: #ff3b30; }
        pre { background: #f6f8fa; padding: 15px; border-radius: 6px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 Nestory Test Coverage Report</h1>
        <p>Generated: $(date)</p>
        <p>Result Bundle: $(basename "$RESULT_BUNDLE")</p>
    </div>
    
    <div class="summary">
        <h2>📊 Coverage Summary</h2>
        <div id="coverage-data">
            <!-- Coverage data will be populated -->
        </div>
    </div>
    
    <div class="file-list">
        <h2>📁 File Coverage</h2>
        <p><em>Detailed file-by-file coverage analysis will be shown here when JSON parsing is enhanced.</em></p>
        
        <h3>Raw Coverage Data</h3>
        <pre>$(head -30 "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt" 2>/dev/null || echo "Coverage data not available")</pre>
    </div>
    
    <div>
        <h2>🔧 Technical Details</h2>
        <p><strong>Test Bundle:</strong> $(basename "$RESULT_BUNDLE")</p>
        <p><strong>Timestamp:</strong> $TIMESTAMP</p>
        <p><strong>Simulator:</strong> $SIMULATOR ($OS_VERSION)</p>
        <p><strong>Configuration:</strong> $CONFIG</p>
    </div>
</body>
</html>
EOF
                log_success "HTML report generated: coverage_report_$TIMESTAMP.html"
            fi
            
            # Show coverage summary
            if [ -f "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt" ]; then
                log_success "Coverage reports generated successfully!"
                echo ""
                echo "📊 Coverage Summary:"
                head -20 "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt"
                echo ""
                
                if [ -n "$COVERAGE_PERCENT" ]; then
                    if (( $(echo "$COVERAGE_PERCENT >= 80" | bc -l) )); then
                        log_success "Coverage target met: ${COVERAGE_PERCENT}% ≥ 80%"
                    elif (( $(echo "$COVERAGE_PERCENT >= 60" | bc -l) )); then
                        log_warning "Coverage moderate: ${COVERAGE_PERCENT}% (target: 80%)"
                    else
                        log_warning "Coverage low: ${COVERAGE_PERCENT}% (target: 80%)"
                    fi
                fi
            fi
        fi
        
        # Open results if requested
        if [ "$OPEN_RESULTS" = true ]; then
            log_info "Opening result bundle in Xcode..."
            open "$RESULT_BUNDLE"
        fi
    else
        log_warning "Result bundle not found at expected location"
    fi
    
    # Show next steps
    echo ""
    log_success "🎉 Test run completed successfully!"
    echo ""
    echo "📁 Artifacts created:"
    echo "   • Result bundle: $(basename "$RESULT_BUNDLE")"
    echo "   • Test log: test_output_$TIMESTAMP.log"
    if [ -f "$ARTIFACTS_DIR/coverage_summary_$TIMESTAMP.txt" ]; then
        echo "   • Coverage summary: coverage_summary_$TIMESTAMP.txt"
    fi
    if [ -f "$ARTIFACTS_DIR/coverage_detailed_$TIMESTAMP.json" ]; then
        echo "   • Coverage JSON: coverage_detailed_$TIMESTAMP.json"
    fi
    if [ -f "$ARTIFACTS_DIR/coverage_files_$TIMESTAMP.txt" ]; then
        echo "   • File list: coverage_files_$TIMESTAMP.txt"
    fi
    if [ -f "$ARTIFACTS_DIR/coverage_percentage_$TIMESTAMP.txt" ]; then
        echo "   • Coverage %: coverage_percentage_$TIMESTAMP.txt"
    fi
    if [ -f "$ARTIFACTS_DIR/coverage_report_$TIMESTAMP.html" ]; then
        echo "   • HTML report: coverage_report_$TIMESTAMP.html"
    fi
    echo ""
    echo "🔍 To explore results:"
    echo "   • Open in Xcode: open '$RESULT_BUNDLE'"
    echo "   • HTML report: open '$ARTIFACTS_DIR/coverage_report_$TIMESTAMP.html'"
    echo "   • Coverage CLI: xcrun xccov view --report '$RESULT_BUNDLE'"
    echo "   • Coverage JSON: xcrun xccov view --report --json '$RESULT_BUNDLE'"
    echo "   • File coverage: xcrun xccov view --file-list '$RESULT_BUNDLE'"
    echo ""
    
else
    log_error "Tests failed with exit code: $BUILD_EXIT_CODE"
    echo ""
    echo "🔍 Check the test log for details:"
    echo "   tail -50 '$ARTIFACTS_DIR/test_output_$TIMESTAMP.log'"
    echo ""
    exit $BUILD_EXIT_CODE
fi