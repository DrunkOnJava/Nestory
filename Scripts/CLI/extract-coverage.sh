#!/bin/bash

# extract-coverage.sh
# Standalone coverage extraction from .xcresult bundles
# Usage: ./Scripts/CLI/extract-coverage.sh [path/to/result.xcresult] [output-directory]

set -euo pipefail

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

# Usage function
usage() {
    echo "Usage: $0 [RESULT_BUNDLE] [OUTPUT_DIR]"
    echo ""
    echo "Extract comprehensive coverage reports from Xcode result bundles"
    echo ""
    echo "Arguments:"
    echo "  RESULT_BUNDLE  Path to .xcresult bundle (optional - will find latest)"
    echo "  OUTPUT_DIR     Output directory (optional - default: ./BuildArtifacts)"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                                           # Extract from latest result"
    echo "  $0 BuildArtifacts/NestoryTests_*.xcresult   # Extract from specific bundle"
    echo "  $0 result.xcresult /tmp/coverage             # Extract to custom directory"
    echo ""
    exit 0
}

# Parse arguments
RESULT_BUNDLE=""
OUTPUT_DIR="./BuildArtifacts"

for arg in "$@"; do
    case $arg in
        --help|-h)
            usage
            ;;
        *)
            if [ -z "$RESULT_BUNDLE" ]; then
                RESULT_BUNDLE="$arg"
            elif [ "$OUTPUT_DIR" = "./BuildArtifacts" ]; then
                OUTPUT_DIR="$arg"
            fi
            ;;
    esac
done

# Find result bundle if not specified
if [ -z "$RESULT_BUNDLE" ]; then
    log_info "Looking for latest .xcresult bundle..."
    
    # Find the most recent .xcresult bundle
    LATEST_BUNDLE=$(find ./BuildArtifacts -name "*.xcresult" -type d 2>/dev/null | head -1)
    
    if [ -z "$LATEST_BUNDLE" ]; then
        log_error "No .xcresult bundles found in ./BuildArtifacts"
        echo "Run tests first with: ./Scripts/CLI/test-with-insights.sh"
        exit 1
    fi
    
    RESULT_BUNDLE="$LATEST_BUNDLE"
fi

# Validate inputs
if [ ! -d "$RESULT_BUNDLE" ]; then
    log_error "Result bundle not found: $RESULT_BUNDLE"
    echo "Make sure to run tests first or provide a valid .xcresult path"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    log_info "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# Generate timestamp for output files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUNDLE_NAME=$(basename "$RESULT_BUNDLE" .xcresult)

log_info "Extracting coverage from: $(basename "$RESULT_BUNDLE")"
log_info "Output directory: $OUTPUT_DIR"

# Verify xccov is available
if ! command -v xcrun >/dev/null 2>&1; then
    log_error "xcrun command not found. Make sure Xcode command line tools are installed."
    exit 1
fi

# Extract coverage reports
log_info "Generating coverage reports..."

# Basic coverage summary (human-readable)
SUMMARY_FILE="$OUTPUT_DIR/${BUNDLE_NAME}_coverage_summary_$TIMESTAMP.txt"
if xcrun xccov view --report "$RESULT_BUNDLE" > "$SUMMARY_FILE" 2>/dev/null; then
    log_success "Coverage summary: $(basename "$SUMMARY_FILE")"
else
    log_warning "Failed to generate coverage summary"
fi

# Detailed coverage report (JSON)
JSON_FILE="$OUTPUT_DIR/${BUNDLE_NAME}_coverage_detailed_$TIMESTAMP.json"
if xcrun xccov view --report --json "$RESULT_BUNDLE" > "$JSON_FILE" 2>/dev/null; then
    log_success "Detailed JSON: $(basename "$JSON_FILE")"
else
    log_warning "Failed to generate detailed JSON report"
fi

# File-by-file coverage breakdown
FILES_FILE="$OUTPUT_DIR/${BUNDLE_NAME}_coverage_files_$TIMESTAMP.txt"
if xcrun xccov view --file-list "$RESULT_BUNDLE" > "$FILES_FILE" 2>/dev/null; then
    log_success "File list: $(basename "$FILES_FILE")"
else
    log_warning "Failed to generate file list"
fi

# Extract overall coverage percentage
if [ -f "$SUMMARY_FILE" ]; then
    COVERAGE_PERCENT=$(grep -E "^\s*[0-9]+\.[0-9]+%" "$SUMMARY_FILE" | head -1 | grep -o "[0-9]\+\.[0-9]\+")
    if [ -n "$COVERAGE_PERCENT" ]; then
        PERCENT_FILE="$OUTPUT_DIR/${BUNDLE_NAME}_coverage_percentage_$TIMESTAMP.txt"
        echo "$COVERAGE_PERCENT" > "$PERCENT_FILE"
        log_success "Coverage percentage: ${COVERAGE_PERCENT}% (saved to $(basename "$PERCENT_FILE"))"
        
        # Show coverage assessment
        if (( $(echo "$COVERAGE_PERCENT >= 80" | bc -l) )); then
            log_success "✨ Excellent coverage: ${COVERAGE_PERCENT}% ≥ 80%"
        elif (( $(echo "$COVERAGE_PERCENT >= 60" | bc -l) )); then
            log_warning "⚡ Moderate coverage: ${COVERAGE_PERCENT}% (target: 80%)"
        else
            log_warning "🔥 Coverage needs improvement: ${COVERAGE_PERCENT}% (target: 80%)"
        fi
    fi
fi

# Generate HTML report
HTML_FILE="$OUTPUT_DIR/${BUNDLE_NAME}_coverage_report_$TIMESTAMP.html"
if [ -f "$SUMMARY_FILE" ]; then
    log_info "Generating HTML coverage report..."
    
    cat > "$HTML_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Nestory Coverage Report - $(basename "$RESULT_BUNDLE")</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: #f8f9fa;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { 
            background: linear-gradient(135deg, #007AFF, #5856D6); 
            color: white; 
            padding: 30px; 
            border-radius: 12px; 
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0,122,255,0.3);
        }
        .header h1 { margin: 0 0 10px 0; font-size: 2.5rem; }
        .header p { margin: 5px 0; opacity: 0.9; }
        .summary { 
            background: white; 
            padding: 30px; 
            border-radius: 12px; 
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .coverage-badge {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            font-size: 1.2rem;
            margin: 10px 0;
        }
        .coverage-high { background: #34c759; color: white; }
        .coverage-medium { background: #ff9500; color: white; }
        .coverage-low { background: #ff3b30; color: white; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .card { 
            background: white; 
            padding: 20px; 
            border-radius: 8px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .card h3 { margin-top: 0; color: #007AFF; }
        pre { 
            background: #f6f8fa; 
            padding: 20px; 
            border-radius: 8px; 
            overflow-x: auto; 
            font-size: 0.9rem;
            border: 1px solid #e1e5e9;
        }
        .meta { font-size: 0.9rem; color: #666; }
        .footer { text-align: center; margin-top: 40px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧪 Test Coverage Report</h1>
            <p><strong>Project:</strong> Nestory</p>
            <p><strong>Generated:</strong> $(date)</p>
            <p><strong>Bundle:</strong> $(basename "$RESULT_BUNDLE")</p>
        </div>
        
        <div class="summary">
            <h2>📊 Coverage Overview</h2>
EOF

    # Add coverage badge if percentage is available
    if [ -n "$COVERAGE_PERCENT" ]; then
        if (( $(echo "$COVERAGE_PERCENT >= 80" | bc -l) )); then
            echo "            <div class=\"coverage-badge coverage-high\">${COVERAGE_PERCENT}% Coverage</div>" >> "$HTML_FILE"
        elif (( $(echo "$COVERAGE_PERCENT >= 60" | bc -l) )); then
            echo "            <div class=\"coverage-badge coverage-medium\">${COVERAGE_PERCENT}% Coverage</div>" >> "$HTML_FILE"
        else
            echo "            <div class=\"coverage-badge coverage-low\">${COVERAGE_PERCENT}% Coverage</div>" >> "$HTML_FILE"
        fi
    fi

    cat >> "$HTML_FILE" << EOF
            <p>This report shows code coverage data from the latest test run. Coverage data helps identify untested code paths and areas that may need additional testing.</p>
        </div>
        
        <div class="grid">
            <div class="card">
                <h3>📈 Coverage Summary</h3>
                <pre>$(head -20 "$SUMMARY_FILE" 2>/dev/null || echo "Coverage data not available")</pre>
            </div>
            
            <div class="card">
                <h3>📁 Available Reports</h3>
                <p><strong>Files Generated:</strong></p>
                <ul>
EOF

    # List generated files
    [ -f "$SUMMARY_FILE" ] && echo "                    <li>Coverage Summary: $(basename "$SUMMARY_FILE")</li>" >> "$HTML_FILE"
    [ -f "$JSON_FILE" ] && echo "                    <li>Detailed JSON: $(basename "$JSON_FILE")</li>" >> "$HTML_FILE"
    [ -f "$FILES_FILE" ] && echo "                    <li>File List: $(basename "$FILES_FILE")</li>" >> "$HTML_FILE"
    [ -f "$PERCENT_FILE" ] && echo "                    <li>Coverage %: $(basename "$PERCENT_FILE")</li>" >> "$HTML_FILE"

    cat >> "$HTML_FILE" << EOF
                </ul>
                
                <p><strong>CLI Commands:</strong></p>
                <pre>
# View in Xcode
open "$RESULT_BUNDLE"

# Command line reports
xcrun xccov view --report "$RESULT_BUNDLE"
xcrun xccov view --file-list "$RESULT_BUNDLE"
                </pre>
            </div>
        </div>
        
        <div class="footer">
            <p class="meta">Generated by Nestory Coverage Extractor • $(date)</p>
        </div>
    </div>
</body>
</html>
EOF

    log_success "HTML report: $(basename "$HTML_FILE")"
fi

# Final summary
echo ""
log_success "🎉 Coverage extraction completed!"
echo ""
echo "📁 Generated files:"
[ -f "$SUMMARY_FILE" ] && echo "   • $(basename "$SUMMARY_FILE")"
[ -f "$JSON_FILE" ] && echo "   • $(basename "$JSON_FILE")"  
[ -f "$FILES_FILE" ] && echo "   • $(basename "$FILES_FILE")"
[ -f "$PERCENT_FILE" ] && echo "   • $(basename "$PERCENT_FILE")"
[ -f "$HTML_FILE" ] && echo "   • $(basename "$HTML_FILE")"

echo ""
echo "🔍 Next steps:"
echo "   • View HTML report: open '$HTML_FILE'"
echo "   • Open in Xcode: open '$RESULT_BUNDLE'"
echo "   • View raw data: cat '$SUMMARY_FILE'"

echo ""