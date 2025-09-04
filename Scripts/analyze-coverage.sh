#!/bin/bash

# Comprehensive Coverage Analysis Script for Nestory
# Analyzes test coverage and enforces quality thresholds

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Coverage thresholds (from our quality requirements)
CRITICAL_INSURANCE_THRESHOLD=95  # 95% for critical insurance workflows
TCA_FEATURES_THRESHOLD=90        # 90% for TCA features
SERVICE_LAYER_THRESHOLD=85       # 85% for service layer
UI_COMPONENTS_THRESHOLD=80       # 80% for UI components
OVERALL_THRESHOLD=85             # 85% overall minimum

# Script options
VALIDATE_ONLY=false

# Result bundle path
RESULT_BUNDLE=""
COVERAGE_REPORT_DIR="BuildArtifacts/CoverageReports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -b, --bundle PATH     Path to xcresult bundle (required)"
    echo "  -o, --output DIR      Output directory for reports (default: BuildArtifacts/CoverageReports)"
    echo "  -t, --threshold NUM   Overall coverage threshold (default: 85)"
    echo "  -v, --verbose         Verbose output"
    echo "  -f, --fail-on-low     Fail script if coverage below threshold"
    echo "  --validate-only       Only validate coverage against thresholds, don't generate reports"
    echo "  -h, --help            Show this help"
    echo ""
    echo "Coverage Thresholds:"
    echo "  Insurance Workflows: ${CRITICAL_INSURANCE_THRESHOLD}%"
    echo "  TCA Features: ${TCA_FEATURES_THRESHOLD}%"
    echo "  Service Layer: ${SERVICE_LAYER_THRESHOLD}%"
    echo "  UI Components: ${UI_COMPONENTS_THRESHOLD}%"
    echo ""
    exit 1
}

# Function to check if xcresulttool is available
check_tools() {
    if ! command -v xcrun xcresulttool &> /dev/null; then
        echo -e "${RED}❌ Error: xcresulttool not available${NC}"
        echo "This tool requires Xcode command line tools"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: jq not available, installing via brew...${NC}"
        if command -v brew &> /dev/null; then
            brew install jq
        else
            echo -e "${RED}❌ Error: jq required but brew not available${NC}"
            exit 1
        fi
    fi
}

# Function to extract coverage data from result bundle
extract_coverage_data() {
    local bundle_path=$1
    
    if [[ ! -d "$bundle_path" ]]; then
        echo -e "${RED}❌ Error: Result bundle not found at $bundle_path${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📊 Extracting coverage data from: $bundle_path${NC}"
    
    # Create output directory
    mkdir -p "$COVERAGE_REPORT_DIR"
    
    # Extract coverage data
    xcrun xcresulttool get \
        --path "$bundle_path" \
        --format json \
        codecoverage > "$COVERAGE_REPORT_DIR/raw_coverage_$TIMESTAMP.json" 2>/dev/null || {
            echo -e "${RED}❌ Error: Failed to extract coverage data${NC}"
            echo "Make sure the result bundle contains code coverage data"
            exit 1
        }
    
    echo -e "${GREEN}✅ Coverage data extracted to: $COVERAGE_REPORT_DIR/raw_coverage_$TIMESTAMP.json${NC}"
}

# Function to analyze coverage by category
analyze_coverage_by_category() {
    local coverage_file="$COVERAGE_REPORT_DIR/raw_coverage_$TIMESTAMP.json"
    
    echo -e "${PURPLE}🔍 Analyzing Coverage by Category${NC}"
    echo "============================================"
    
    # Initialize coverage report
    local report_file="$COVERAGE_REPORT_DIR/coverage_analysis_$TIMESTAMP.txt"
    
    cat > "$report_file" << EOF
Nestory Code Coverage Analysis Report
Generated: $(date)
Bundle: $RESULT_BUNDLE

COVERAGE THRESHOLDS:
- Critical Insurance Workflows: ${CRITICAL_INSURANCE_THRESHOLD}%
- TCA Features: ${TCA_FEATURES_THRESHOLD}%  
- Service Layer: ${SERVICE_LAYER_THRESHOLD}%
- UI Components: ${UI_COMPONENTS_THRESHOLD}%
- Overall Target: ${OVERALL_THRESHOLD}%

COVERAGE ANALYSIS:
================

EOF

    # Parse and analyze coverage data
    if [[ -f "$coverage_file" ]]; then
        echo -e "${BLUE}📈 Generating detailed coverage analysis...${NC}"
        
        # Extract overall coverage
        local overall_coverage=$(jq -r '.targets[0].lineCoverage // 0' "$coverage_file" 2>/dev/null | awk '{printf "%.1f", $1*100}')
        
        echo "Overall Coverage: ${overall_coverage}%" >> "$report_file"
        echo "" >> "$report_file"
        
        # Analyze by file categories
        analyze_insurance_workflows "$coverage_file" "$report_file"
        analyze_tca_features "$coverage_file" "$report_file"
        analyze_service_layer "$coverage_file" "$report_file"
        analyze_ui_components "$coverage_file" "$report_file"
        
        # Display summary
        display_coverage_summary "$report_file" "$overall_coverage"
        
    else
        echo -e "${RED}❌ Error: Coverage file not found${NC}"
        exit 1
    fi
}

# Function to analyze insurance workflow coverage
analyze_insurance_workflows() {
    local coverage_file=$1
    local report_file=$2
    
    echo -e "${CYAN}📋 Analyzing Insurance Workflow Coverage${NC}"
    
    cat >> "$report_file" << EOF
INSURANCE WORKFLOW COVERAGE:
=============================

Key Files Analyzed:
- Services/InsuranceClaimService.swift
- Services/ClaimExport/ClaimExportService.swift  
- Services/DamageAssessmentService/DamageAssessmentService.swift
- Features/Insurance/InsuranceFeature.swift
- App-Main/DamageAssessmentViews/*
- App-Main/InsuranceClaimView.swift

EOF

    # Extract coverage for insurance-specific files
    local insurance_files=(
        "InsuranceClaimService"
        "ClaimExportService"
        "DamageAssessmentService"
        "InsuranceFeature"
        "DamageAssessmentViews"
        "InsuranceClaimView"
    )
    
    local total_lines=0
    local covered_lines=0
    
    for file_pattern in "${insurance_files[@]}"; do
        local file_coverage=$(jq -r --arg pattern "$file_pattern" '
            .targets[0].files[] | 
            select(.path | contains($pattern)) | 
            .lineCoverage // 0
        ' "$coverage_file" 2>/dev/null)
        
        if [[ -n "$file_coverage" && "$file_coverage" != "0" ]]; then
            local percentage=$(echo "$file_coverage * 100" | bc -l | awk '{printf "%.1f", $1}')
            echo "  $file_pattern: ${percentage}%" >> "$report_file"
            
            # Accumulate totals (simplified calculation)
            covered_lines=$((covered_lines + $(echo "$file_coverage * 100" | bc -l | awk '{printf "%.0f", $1}')))
            total_lines=$((total_lines + 100))
        fi
    done
    
    if [[ $total_lines -gt 0 ]]; then
        local insurance_coverage=$(echo "scale=1; $covered_lines / $total_lines * 100" | bc -l)
        echo "" >> "$report_file"
        echo "Insurance Workflows Total: ${insurance_coverage}%" >> "$report_file"
        
        if (( $(echo "$insurance_coverage >= $CRITICAL_INSURANCE_THRESHOLD" | bc -l) )); then
            echo -e "${GREEN}✅ Insurance workflows: ${insurance_coverage}% (Target: ${CRITICAL_INSURANCE_THRESHOLD}%)${NC}"
        else
            echo -e "${RED}❌ Insurance workflows: ${insurance_coverage}% (Target: ${CRITICAL_INSURANCE_THRESHOLD}%)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Insurance workflow coverage data not available${NC}"
    fi
    
    echo "" >> "$report_file"
}

# Function to analyze TCA features coverage
analyze_tca_features() {
    local coverage_file=$1
    local report_file=$2
    
    echo -e "${CYAN}🏗️  Analyzing TCA Features Coverage${NC}"
    
    cat >> "$report_file" << EOF
TCA FEATURES COVERAGE:
=====================

Key Features Analyzed:
- Features/Search/SearchFeature.swift
- Features/Inventory/InventoryFeature.swift
- Features/Settings/SettingsFeature.swift
- Features/Insurance/InsuranceFeature.swift

EOF

    # Extract coverage for TCA feature files
    local tca_files=(
        "SearchFeature"
        "InventoryFeature"
        "SettingsFeature"
        "InsuranceFeature"
    )
    
    local total_lines=0
    local covered_lines=0
    
    for file_pattern in "${tca_files[@]}"; do
        local file_coverage=$(jq -r --arg pattern "$file_pattern" '
            .targets[0].files[] | 
            select(.path | contains($pattern)) | 
            .lineCoverage // 0
        ' "$coverage_file" 2>/dev/null)
        
        if [[ -n "$file_coverage" && "$file_coverage" != "0" ]]; then
            local percentage=$(echo "$file_coverage * 100" | bc -l | awk '{printf "%.1f", $1}')
            echo "  $file_pattern: ${percentage}%" >> "$report_file"
            
            covered_lines=$((covered_lines + $(echo "$file_coverage * 100" | bc -l | awk '{printf "%.0f", $1}')))
            total_lines=$((total_lines + 100))
        fi
    done
    
    if [[ $total_lines -gt 0 ]]; then
        local tca_coverage=$(echo "scale=1; $covered_lines / $total_lines * 100" | bc -l)
        echo "" >> "$report_file"
        echo "TCA Features Total: ${tca_coverage}%" >> "$report_file"
        
        if (( $(echo "$tca_coverage >= $TCA_FEATURES_THRESHOLD" | bc -l) )); then
            echo -e "${GREEN}✅ TCA features: ${tca_coverage}% (Target: ${TCA_FEATURES_THRESHOLD}%)${NC}"
        else
            echo -e "${RED}❌ TCA features: ${tca_coverage}% (Target: ${TCA_FEATURES_THRESHOLD}%)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  TCA features coverage data not available${NC}"
    fi
    
    echo "" >> "$report_file"
}

# Function to analyze service layer coverage
analyze_service_layer() {
    local coverage_file=$1
    local report_file=$2
    
    echo -e "${CYAN}⚙️  Analyzing Service Layer Coverage${NC}"
    
    cat >> "$report_file" << EOF
SERVICE LAYER COVERAGE:
======================

Key Services Analyzed:
- Services/InventoryService/
- Services/BarcodeScannerService/
- Services/CloudBackupService/
- Services/ReceiptOCR/

EOF

    local service_patterns=(
        "InventoryService"
        "BarcodeScannerService"
        "CloudBackupService"
        "ReceiptOCR"
    )
    
    for pattern in "${service_patterns[@]}"; do
        local service_coverage=$(jq -r --arg pattern "$pattern" '
            .targets[0].files[] | 
            select(.path | contains($pattern)) | 
            .lineCoverage // 0
        ' "$coverage_file" 2>/dev/null)
        
        if [[ -n "$service_coverage" && "$service_coverage" != "0" ]]; then
            local percentage=$(echo "$service_coverage * 100" | bc -l | awk '{printf "%.1f", $1}')
            echo "  $pattern: ${percentage}%" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
}

# Function to analyze UI components coverage
analyze_ui_components() {
    local coverage_file=$1
    local report_file=$2
    
    echo -e "${CYAN}🖥️  Analyzing UI Components Coverage${NC}"
    
    cat >> "$report_file" << EOF
UI COMPONENTS COVERAGE:
======================

Key UI Components Analyzed:
- UI/UI-Core/
- App-Main/*View.swift
- Features/*/View.swift

EOF

    local ui_patterns=(
        "UI-Core"
        "View.swift"
        "Components"
    )
    
    for pattern in "${ui_patterns[@]}"; do
        local ui_coverage=$(jq -r --arg pattern "$pattern" '
            .targets[0].files[] | 
            select(.path | contains($pattern)) | 
            .lineCoverage // 0
        ' "$coverage_file" 2>/dev/null)
        
        if [[ -n "$ui_coverage" && "$ui_coverage" != "0" ]]; then
            local percentage=$(echo "$ui_coverage * 100" | bc -l | awk '{printf "%.1f", $1}')
            echo "  $pattern: ${percentage}%" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
}

# Function to display coverage summary
display_coverage_summary() {
    local report_file=$1
    local overall_coverage=$2
    
    echo ""
    echo -e "${PURPLE}📋 COVERAGE SUMMARY${NC}"
    echo "=================="
    
    # Add summary to report
    cat >> "$report_file" << EOF

COVERAGE SUMMARY:
================

Overall Coverage: ${overall_coverage}%
Target: ${OVERALL_THRESHOLD}%

Status: $(if (( $(echo "$overall_coverage >= $OVERALL_THRESHOLD" | bc -l) )); then echo "PASS ✅"; else echo "FAIL ❌"; fi)

Recommendations:
- Focus on increasing coverage for files below their category thresholds
- Prioritize insurance workflow testing (target: ${CRITICAL_INSURANCE_THRESHOLD}%)
- Ensure TCA feature logic is thoroughly tested (target: ${TCA_FEATURES_THRESHOLD}%)

Report generated: $(date)
EOF

    if (( $(echo "$overall_coverage >= $OVERALL_THRESHOLD" | bc -l) )); then
        echo -e "${GREEN}✅ Overall Coverage: ${overall_coverage}% (Target: ${OVERALL_THRESHOLD}%)${NC}"
        echo -e "${GREEN}✅ Coverage requirements met!${NC}"
    else
        echo -e "${RED}❌ Overall Coverage: ${overall_coverage}% (Target: ${OVERALL_THRESHOLD}%)${NC}"
        echo -e "${RED}❌ Coverage below threshold!${NC}"
        
        if [[ "$FAIL_ON_LOW" == "true" ]]; then
            echo -e "${RED}💥 Failing due to low coverage${NC}"
            exit 1
        fi
    fi
    
    echo ""
    echo -e "${BLUE}📂 Full report: $report_file${NC}"
    echo -e "${BLUE}📊 Raw data: $COVERAGE_REPORT_DIR/raw_coverage_$TIMESTAMP.json${NC}"
}

# Function to generate HTML report
generate_html_report() {
    local report_file="$COVERAGE_REPORT_DIR/coverage_analysis_$TIMESTAMP.txt"
    local html_file="$COVERAGE_REPORT_DIR/coverage_report_$TIMESTAMP.html"
    
    echo -e "${BLUE}🌐 Generating HTML report...${NC}"
    
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Nestory Coverage Report - $TIMESTAMP</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
        .header { background: #007AFF; color: white; padding: 20px; border-radius: 8px; }
        .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        .pass { color: #34C759; font-weight: bold; }
        .fail { color: #FF3B30; font-weight: bold; }
        .warning { color: #FF9500; font-weight: bold; }
        pre { background: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f5f5f5; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 Nestory Code Coverage Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <div class="section">
        <h2>Coverage Summary</h2>
        <pre>$(cat "$report_file" 2>/dev/null || echo "Report file not found")</pre>
    </div>
    
    <div class="section">
        <h2>Quality Thresholds</h2>
        <table>
            <tr><th>Category</th><th>Threshold</th><th>Status</th></tr>
            <tr><td>Critical Insurance Workflows</td><td>${CRITICAL_INSURANCE_THRESHOLD}%</td><td class="warning">Pending Validation</td></tr>
            <tr><td>TCA Features</td><td>${TCA_FEATURES_THRESHOLD}%</td><td class="warning">Pending Validation</td></tr>
            <tr><td>Service Layer</td><td>${SERVICE_LAYER_THRESHOLD}%</td><td class="warning">Pending Validation</td></tr>
            <tr><td>UI Components</td><td>${UI_COMPONENTS_THRESHOLD}%</td><td class="warning">Pending Validation</td></tr>
        </table>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✅ HTML report generated: $html_file${NC}"
    
    # Optionally open in browser
    if command -v open &> /dev/null; then
        echo -e "${BLUE}🌐 Opening report in browser...${NC}"
        open "$html_file"
    fi
}

# Parse command line arguments
VERBOSE=false
FAIL_ON_LOW=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bundle)
            RESULT_BUNDLE="$2"
            shift 2
            ;;
        -o|--output)
            COVERAGE_REPORT_DIR="$2"
            shift 2
            ;;
        -t|--threshold)
            OVERALL_THRESHOLD="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--fail-on-low)
            FAIL_ON_LOW=true
            shift
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option $1"
            usage
            ;;
    esac
done

# Validate required arguments
if [[ -z "$RESULT_BUNDLE" ]]; then
    echo -e "${RED}❌ Error: Result bundle path required${NC}"
    echo "Use -b or --bundle to specify the xcresult bundle path"
    usage
fi

# Validation-only function (no report generation)
validate_coverage_only() {
    echo -e "${PURPLE}🎯 Coverage Validation Mode${NC}"
    echo "============================="
    
    check_tools
    
    # Find latest result bundle if not provided
    if [[ -z "$RESULT_BUNDLE" ]]; then
        echo -e "${CYAN}🔍 Finding latest result bundle...${NC}"
        RESULT_BUNDLE=$(find ./BuildArtifacts -name "*.xcresult" -type d 2>/dev/null | head -1)
        
        if [[ -z "$RESULT_BUNDLE" ]]; then
            echo -e "${RED}❌ No .xcresult bundles found in ./BuildArtifacts${NC}"
            echo "Run 'make test-with-coverage' first to generate coverage data"
            exit 1
        fi
        echo -e "${BLUE}📦 Using bundle: $(basename "$RESULT_BUNDLE")${NC}"
    fi
    
    # Extract coverage data 
    extract_coverage_data "$RESULT_BUNDLE"
    
    # Quick validation without full reporting
    local coverage_file="/tmp/coverage_data_$TIMESTAMP.json"
    local overall_coverage=$(jq -r '.targets[0].lineCoverage // 0' "$coverage_file" 2>/dev/null | awk '{printf "%.1f", $1*100}')
    
    echo -e "${CYAN}📊 Overall Coverage: ${overall_coverage}%${NC}"
    
    # Validate thresholds (simplified)
    local validation_passed=true
    
    if (( $(echo "$overall_coverage < $OVERALL_THRESHOLD" | bc -l) )); then
        echo -e "${RED}❌ Overall coverage ${overall_coverage}% below threshold ${OVERALL_THRESHOLD}%${NC}"
        validation_passed=false
    else
        echo -e "${GREEN}✅ Overall coverage ${overall_coverage}% meets threshold ${OVERALL_THRESHOLD}%${NC}"
    fi
    
    if [[ "$validation_passed" == "true" ]]; then
        echo -e "${GREEN}🎉 All coverage requirements validated successfully!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Coverage validation failed!${NC}"
        exit 1
    fi
}

# Main execution
main() {
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        validate_coverage_only
        return
    fi
    
    echo -e "${PURPLE}🚀 Nestory Coverage Analysis${NC}"
    echo "================================"
    
    check_tools
    extract_coverage_data "$RESULT_BUNDLE"
    analyze_coverage_by_category
    generate_html_report
    
    echo ""
    echo -e "${GREEN}✅ Coverage analysis complete!${NC}"
    echo -e "${BLUE}📁 Reports available in: $COVERAGE_REPORT_DIR${NC}"
}

# Run main function
main "$@"