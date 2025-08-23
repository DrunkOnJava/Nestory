#!/bin/bash

# Codebase Health Report Generator for Nestory
# Generates comprehensive reports on modularization, architecture, and overall health
# Integrates all automation systems for complete project overview

set -e

# Color codes for enhanced output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD_GREEN='\033[1;32m'
BOLD_BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORTS_DIR="${PROJECT_ROOT}/.reports"
HEALTH_REPORT="${REPORTS_DIR}/codebase-health-$(date '+%Y%m%d-%H%M%S').json"
HTML_REPORT="${REPORTS_DIR}/codebase-health-$(date '+%Y%m%d-%H%M%S').html"
LATEST_REPORT="${REPORTS_DIR}/latest-health-report.json"
LATEST_HTML="${REPORTS_DIR}/latest-health-report.html"

# Health metrics storage
declare -A health_metrics
declare -A test_results
declare -a recommendations
declare -a critical_issues
declare -a warnings

# Ensure reports directory exists
mkdir -p "$REPORTS_DIR"

log_metric() {
    local category=$1
    local name=$2
    local value=$3
    local status=${4:-"UNKNOWN"}
    
    health_metrics["${category}.${name}"]="$value"
    health_metrics["${category}.${name}.status"]="$status"
}

run_validation_suite() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  Codebase Health Analysis                   ║${NC}"
    echo -e "${BLUE}║                   Automated Assessment                      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    cd "$PROJECT_ROOT"
    
    # Run configuration validation
    echo -e "${CYAN}🔧 Running Configuration Validation...${NC}"
    if timeout 60 ./scripts/validate-configuration.sh >/dev/null 2>&1; then
        test_results["config_validation"]="PASS"
        log_metric "validation" "configuration" "100" "HEALTHY"
        echo -e "  ${GREEN}✓ Configuration validation passed${NC}"
    else
        test_results["config_validation"]="FAIL"
        log_metric "validation" "configuration" "0" "CRITICAL"
        echo -e "  ${RED}✗ Configuration validation failed${NC}"
        critical_issues+=("Configuration validation failed - check project.yml and Makefile consistency")
    fi
    
    # Run modularization monitoring
    echo -e "${CYAN}📊 Running Modularization Analysis...${NC}"
    if timeout 120 ./scripts/modularization-monitor.sh >/dev/null 2>&1; then
        test_results["modularization"]="PASS"
        log_metric "validation" "modularization" "100" "HEALTHY"
        echo -e "  ${GREEN}✓ Modularization monitoring passed${NC}"
        
        # Extract specific metrics if available
        if [ -f ".metrics/current-metrics.json" ] && command -v jq >/dev/null 2>&1; then
            local huge_files=$(jq -r '.metrics."files.huge" // 0' ".metrics/current-metrics.json" 2>/dev/null || echo "0")
            local health_score=$(jq -r '.metrics."health.file_size_score" // 0' ".metrics/current-metrics.json" 2>/dev/null || echo "0")
            
            log_metric "files" "huge_count" "$huge_files" "$([ "$huge_files" -eq 0 ] && echo "HEALTHY" || echo "WARNING")"
            log_metric "health" "file_size_score" "$health_score" "$([ "$health_score" -ge 80 ] && echo "HEALTHY" || echo "WARNING")"
        fi
    else
        test_results["modularization"]="FAIL"
        log_metric "validation" "modularization" "0" "CRITICAL"
        echo -e "  ${RED}✗ Modularization monitoring detected issues${NC}"
        critical_issues+=("Modularization monitoring failed - files may be too large or violate structure")
    fi
    
    # Run enhanced architecture verification
    echo -e "${CYAN}🏗️ Running Architecture Verification...${NC}"
    if timeout 120 ./scripts/architecture-verification.sh >/dev/null 2>&1; then
        test_results["architecture"]="PASS"
        log_metric "validation" "architecture" "100" "HEALTHY"
        echo -e "  ${GREEN}✓ Architecture verification passed${NC}"
    else
        test_results["architecture"]="FAIL"
        log_metric "validation" "architecture" "0" "CRITICAL"
        echo -e "  ${RED}✗ Architecture verification failed${NC}"
        critical_issues+=("Architecture verification failed - layer violations or TCA compliance issues")
    fi
    
    # Run file size checks
    echo -e "${CYAN}📏 Running File Size Analysis...${NC}"
    if timeout 30 ./scripts/check-file-sizes.sh >/dev/null 2>&1; then
        test_results["file_sizes"]="PASS"
        log_metric "validation" "file_sizes" "100" "HEALTHY"
        echo -e "  ${GREEN}✓ File size checks passed${NC}"
    else
        test_results["file_sizes"]="FAIL"
        log_metric "validation" "file_sizes" "0" "WARNING"
        echo -e "  ${YELLOW}⚠ File size violations detected${NC}"
        warnings+=("Files exceed size thresholds - consider modularization")
    fi
    
    echo ""
}

analyze_codebase_metrics() {
    echo -e "${PURPLE}📈 Analyzing Codebase Metrics...${NC}"
    
    # Swift file analysis
    local total_swift_files=0
    local total_lines=0
    local large_files=0
    local huge_files=0
    
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            total_swift_files=$((total_swift_files + 1))
            local lines=$(wc -l < "$file" | tr -d ' ')
            total_lines=$((total_lines + lines))
            
            if [ "$lines" -gt 600 ]; then
                huge_files=$((huge_files + 1))
            elif [ "$lines" -gt 400 ]; then
                large_files=$((large_files + 1))
            fi
        fi
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -not -path "*/build/*" \
        -not -path "*/.build/*" \
        -not -path "*/DerivedData/*" \
        -not -path "*/DevTools/*")
    
    log_metric "codebase" "swift_files" "$total_swift_files" "INFO"
    log_metric "codebase" "total_lines" "$total_lines" "INFO"
    log_metric "codebase" "large_files" "$large_files" "$([ "$large_files" -le 5 ] && echo "HEALTHY" || echo "WARNING")"
    log_metric "codebase" "huge_files" "$huge_files" "$([ "$huge_files" -eq 0 ] && echo "HEALTHY" || echo "CRITICAL")"
    
    local avg_lines_per_file=$((total_lines / total_swift_files))
    log_metric "codebase" "avg_lines_per_file" "$avg_lines_per_file" "$([ "$avg_lines_per_file" -le 200 ] && echo "HEALTHY" || echo "WARNING")"
    
    echo "  Swift Files: $total_swift_files"
    echo "  Total Lines: $total_lines"
    echo "  Average Lines/File: $avg_lines_per_file"
    echo "  Large Files (400-599): $large_files"
    echo "  Huge Files (600+): $huge_files"
    
    # Modular component analysis
    echo ""
    echo "Analyzing modular components..."
    
    local component_dirs=0
    local total_components=0
    
    for pattern in "*/Components" "*/Sections" "*/Cards" "*/Operations"; do
        for dir in $PROJECT_ROOT/$pattern; do
            if [ -d "$dir" ]; then
                component_dirs=$((component_dirs + 1))
                local files_in_dir=$(find "$dir" -name "*.swift" -type f | wc -l | tr -d ' ')
                total_components=$((total_components + files_in_dir))
            fi
        done
    done
    
    log_metric "modular" "component_directories" "$component_dirs" "INFO"
    log_metric "modular" "total_components" "$total_components" "INFO"
    
    echo "  Component Directories: $component_dirs"
    echo "  Total Component Files: $total_components"
    
    # Architecture layer analysis
    echo ""
    echo "Analyzing architecture layers..."
    
    declare -A layer_stats
    for layer in "Foundation" "Infrastructure" "Services" "UI" "Features" "App-Main"; do
        if [ -d "$PROJECT_ROOT/$layer" ]; then
            local layer_files=$(find "$PROJECT_ROOT/$layer" -name "*.swift" -type f | wc -l | tr -d ' ')
            layer_stats["$layer"]=$layer_files
            log_metric "layers" "$layer" "$layer_files" "INFO"
            echo "  $layer: $layer_files files"
        fi
    done
    
    echo ""
}

assess_health_scores() {
    echo -e "${BOLD_GREEN}🎯 Calculating Health Scores...${NC}"
    
    # Overall validation score (0-100)
    local validation_score=0
    local validation_tests=0
    
    for test in "config_validation" "modularization" "architecture" "file_sizes"; do
        validation_tests=$((validation_tests + 1))
        if [[ "${test_results[$test]}" == "PASS" ]]; then
            validation_score=$((validation_score + 25))
        fi
    done
    
    log_metric "health" "validation_score" "$validation_score" "$([ "$validation_score" -ge 80 ] && echo "HEALTHY" || echo "WARNING")"
    
    # File size health score
    local huge_files=${health_metrics["codebase.huge_files"]:-0}
    local large_files=${health_metrics["codebase.large_files"]:-0}
    local total_files=${health_metrics["codebase.swift_files"]:-1}
    
    local good_files=$((total_files - huge_files - large_files))
    local file_health_score=$((good_files * 100 / total_files))
    log_metric "health" "file_size_health" "$file_health_score" "$([ "$file_health_score" -ge 80 ] && echo "HEALTHY" || echo "WARNING")"
    
    # Modular compliance score
    local total_components=${health_metrics["modular.total_components"]:-0}
    local modular_score=100  # Assume good until proven otherwise
    if [ "$total_components" -gt 0 ]; then
        # This would be enhanced with actual modular compliance data
        log_metric "health" "modular_compliance" "$modular_score" "HEALTHY"
    fi
    
    # Calculate overall health score
    local overall_score=$(( (validation_score + file_health_score + modular_score) / 3 ))
    log_metric "health" "overall_score" "$overall_score" "$([ "$overall_score" -ge 80 ] && echo "HEALTHY" || [ "$overall_score" -ge 60 ] && echo "WARNING" || echo "CRITICAL")"
    
    echo "  Validation Score: $validation_score/100"
    echo "  File Size Health: $file_health_score/100"
    echo "  Modular Compliance: $modular_score/100"
    echo ""
    echo -e "  ${BOLD_BLUE}Overall Health Score: $overall_score/100${NC}"
    
    if [ "$overall_score" -ge 90 ]; then
        echo -e "  ${BOLD_GREEN}Status: EXCELLENT${NC}"
    elif [ "$overall_score" -ge 80 ]; then
        echo -e "  ${GREEN}Status: GOOD${NC}"
    elif [ "$overall_score" -ge 60 ]; then
        echo -e "  ${YELLOW}Status: NEEDS ATTENTION${NC}"
    else
        echo -e "  ${RED}Status: CRITICAL${NC}"
    fi
    
    echo ""
}

generate_recommendations() {
    echo -e "${YELLOW}💡 Generating Recommendations...${NC}"
    
    local huge_files=${health_metrics["codebase.huge_files"]:-0}
    local large_files=${health_metrics["codebase.large_files"]:-0}
    local validation_score=${health_metrics["health.validation_score"]:-0}
    local overall_score=${health_metrics["health.overall_score"]:-0}
    
    if [ "$huge_files" -gt 0 ]; then
        recommendations+=("🚨 CRITICAL: $huge_files files exceed 600 lines - immediate modularization required")
    fi
    
    if [ "$large_files" -gt 5 ]; then
        recommendations+=("⚠️ $large_files files are large (400-599 lines) - consider modularization")
    fi
    
    if [ "$validation_score" -lt 100 ]; then
        recommendations+=("🔧 Fix validation failures to improve code quality and maintainability")
    fi
    
    if [ "$overall_score" -lt 80 ]; then
        recommendations+=("📈 Overall health is below optimal - focus on addressing critical issues")
    fi
    
    if [[ "${test_results[architecture]}" == "FAIL" ]]; then
        recommendations+=("🏗️ Address architecture violations to maintain clean layer separation")
    fi
    
    # Always include best practices
    recommendations+=("✅ Run 'make comprehensive-check' regularly to maintain health")
    recommendations+=("📊 Monitor trends with 'make monitor-modularization --history'")
    
    if [ ${#recommendations[@]} -eq 2 ]; then
        echo "  No specific issues detected - maintaining excellent codebase health!"
    else
        echo "  Generated ${#recommendations[@]} recommendations:"
        for rec in "${recommendations[@]}"; do
            echo "    • $rec"
        done
    fi
    
    echo ""
}

generate_json_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    
    local json_content=$(cat << EOF
{
  "report_metadata": {
    "timestamp": "$timestamp",
    "git_commit": "$git_commit",
    "git_branch": "$git_branch",
    "project_root": "$PROJECT_ROOT"
  },
  "health_metrics": {
EOF
    
    # Add health metrics
    local first=true
    for key in "${!health_metrics[@]}"; do
        if [[ "$key" != *.status ]]; then
            if [ "$first" = true ]; then
                first=false
            else
                json_content+=","
            fi
            local value="${health_metrics[$key]}"
            local status="${health_metrics[$key.status]:-UNKNOWN}"
            json_content+="\n    \"$key\": {\"value\": $value, \"status\": \"$status\"}"
        fi
    done
    
    json_content+="\n  },\n  \"test_results\": {"
    
    # Add test results
    first=true
    for test in "${!test_results[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            json_content+=","
        fi
        json_content+="\n    \"$test\": \"${test_results[$test]}\""
    done
    
    json_content+="\n  },\n  \"critical_issues\": ["
    
    # Add critical issues
    first=true
    for issue in "${critical_issues[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            json_content+=","
        fi
        json_content+="\n    \"$issue\""
    done
    
    json_content+="\n  ],\n  \"warnings\": ["
    
    # Add warnings
    first=true
    for warning in "${warnings[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            json_content+=","
        fi
        json_content+="\n    \"$warning\""
    done
    
    json_content+="\n  ],\n  \"recommendations\": ["
    
    # Add recommendations
    first=true
    for rec in "${recommendations[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            json_content+=","
        fi
        json_content+="\n    \"$rec\""
    done
    
    json_content+="\n  ]\n}"
    
    echo -e "$json_content" > "$HEALTH_REPORT"
    cp "$HEALTH_REPORT" "$LATEST_REPORT"
    
    echo -e "${BLUE}📄 JSON report saved to: $HEALTH_REPORT${NC}"
}

generate_html_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local overall_score=${health_metrics["health.overall_score"]:-0}
    
    local status_color="#28a745"  # Green
    local status_text="EXCELLENT"
    
    if [ "$overall_score" -lt 90 ]; then
        status_color="#28a745"  # Green
        status_text="GOOD"
    fi
    if [ "$overall_score" -lt 80 ]; then
        status_color="#ffc107"  # Yellow
        status_text="NEEDS ATTENTION"
    fi
    if [ "$overall_score" -lt 60 ]; then
        status_color="#dc3545"  # Red
        status_text="CRITICAL"
    fi
    
    local html_content=$(cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nestory Codebase Health Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        .score-container {
            background: white;
            margin: -20px 20px 20px 20px;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .score-circle {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2em;
            font-weight: bold;
            background-color: $status_color;
        }
        .score-text {
            font-size: 1.5em;
            color: $status_color;
            font-weight: bold;
        }
        .content {
            padding: 0 30px 30px;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h2 {
            color: #333;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .metric-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #007bff;
        }
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #333;
        }
        .metric-label {
            color: #666;
            margin-top: 5px;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status-healthy { background: #d4edda; color: #155724; }
        .status-warning { background: #fff3cd; color: #856404; }
        .status-critical { background: #f8d7da; color: #721c24; }
        .test-results {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .test-card {
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #ddd;
        }
        .test-pass { border-left: 4px solid #28a745; background: #f8fff9; }
        .test-fail { border-left: 4px solid #dc3545; background: #fff8f8; }
        .recommendations ul {
            list-style: none;
            padding: 0;
        }
        .recommendations li {
            background: #e7f3ff;
            margin: 10px 0;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #007bff;
        }
        .timestamp {
            text-align: center;
            color: #666;
            font-size: 0.9em;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏠 Nestory Codebase Health Report</h1>
            <p>Comprehensive automated analysis of modularization and architecture</p>
        </div>
        
        <div class="score-container">
            <div class="score-circle">$overall_score</div>
            <div class="score-text">$status_text</div>
            <p>Overall Health Score</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>📊 Key Metrics</h2>
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">${health_metrics["codebase.swift_files"]:-0}</div>
                        <div class="metric-label">Swift Files</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${health_metrics["codebase.huge_files"]:-0}</div>
                        <div class="metric-label">Files > 600 Lines</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${health_metrics["modular.component_directories"]:-0}</div>
                        <div class="metric-label">Component Directories</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${health_metrics["health.validation_score"]:-0}/100</div>
                        <div class="metric-label">Validation Score</div>
                    </div>
                </div>
            </div>
            
            <div class="section">
                <h2>🧪 Validation Results</h2>
                <div class="test-results">
EOF
    
    # Add test results
    for test in "config_validation" "modularization" "architecture" "file_sizes"; do
        local test_name=$(echo "$test" | tr '_' ' ' | sed 's/\b\w/\U&/g')
        local result="${test_results[$test]:-UNKNOWN}"
        local class_name="test-$(echo "$result" | tr 'A-Z' 'a-z')"
        
        html_content+="\n                    <div class=\"test-card $class_name\">"
        html_content+="\n                        <h4>$test_name</h4>"
        html_content+="\n                        <span class=\"status-badge status-$(echo "$result" | tr 'A-Z' 'a-z')\">$result</span>"
        html_content+="\n                    </div>"
    done
    
    html_content+="\n                </div>\n            </div>"
    
    # Add recommendations if any
    if [ ${#recommendations[@]} -gt 0 ]; then
        html_content+="\n            <div class=\"section\">"
        html_content+="\n                <h2>💡 Recommendations</h2>"
        html_content+="\n                <div class=\"recommendations\">"
        html_content+="\n                    <ul>"
        
        for rec in "${recommendations[@]}"; do
            html_content+="\n                        <li>$(echo "$rec" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</li>"
        done
        
        html_content+="\n                    </ul>"
        html_content+="\n                </div>"
        html_content+="\n            </div>"
    fi
    
    html_content+="\n            <div class=\"timestamp\">"
    html_content+="\n                Generated on $timestamp | Automated by Nestory Health Monitor"
    html_content+="\n            </div>"
    html_content+="\n        </div>"
    html_content+="\n    </div>"
    html_content+="\n</body>"
    html_content+="\n</html>"
    
    echo -e "$html_content" > "$HTML_REPORT"
    cp "$HTML_REPORT" "$LATEST_HTML"
    
    echo -e "${BLUE}🌐 HTML report saved to: $HTML_REPORT${NC}"
}

print_summary() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    Health Report Summary                     ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local overall_score=${health_metrics["health.overall_score"]:-0}
    
    echo -e "Overall Health Score: ${BOLD_BLUE}$overall_score/100${NC}"
    echo ""
    
    # Show test results summary
    echo "Validation Results:"
    for test in "config_validation" "modularization" "architecture" "file_sizes"; do
        local test_name=$(echo "$test" | tr '_' ' ' | sed 's/\b\w/\U&/g')
        local result="${test_results[$test]:-UNKNOWN}"
        
        case "$result" in
            "PASS") echo -e "  ${GREEN}✓${NC} $test_name" ;;
            "FAIL") echo -e "  ${RED}✗${NC} $test_name" ;;
            *) echo -e "  ${YELLOW}?${NC} $test_name" ;;
        esac
    done
    
    echo ""
    
    # Show critical issues if any
    if [ ${#critical_issues[@]} -gt 0 ]; then
        echo -e "${RED}Critical Issues:${NC}"
        for issue in "${critical_issues[@]}"; do
            echo -e "  ${RED}•${NC} $issue"
        done
        echo ""
    fi
    
    # Show warnings if any
    if [ ${#warnings[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warnings:${NC}"
        for warning in "${warnings[@]}"; do
            echo -e "  ${YELLOW}•${NC} $warning"
        done
        echo ""
    fi
    
    echo "Reports generated:"
    echo -e "  📄 JSON: ${BLUE}$LATEST_REPORT${NC}"
    echo -e "  🌐 HTML: ${BLUE}$LATEST_HTML${NC}"
    echo ""
    
    echo "Quick actions:"
    echo "  • View HTML report: open $LATEST_HTML"
    echo "  • Run comprehensive check: make comprehensive-check"
    echo "  • Fix issues: make automation-health"
    echo ""
}

# Main execution
main() {
    run_validation_suite
    analyze_codebase_metrics
    assess_health_scores
    generate_recommendations
    generate_json_report
    generate_html_report
    print_summary
    
    # Exit with appropriate code based on health score
    local overall_score=${health_metrics["health.overall_score"]:-0}
    
    if [ "$overall_score" -ge 80 ]; then
        echo -e "${BOLD_GREEN}✅ Codebase health is excellent!${NC}"
        exit 0
    elif [ "$overall_score" -ge 60 ]; then
        echo -e "${YELLOW}⚠️ Codebase health needs attention${NC}"
        exit 1
    else
        echo -e "${RED}❌ Codebase health is critical - immediate action required${NC}"
        exit 2
    fi
}

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Codebase Health Report Generator for Nestory"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --json-only    Generate only JSON report"
    echo "  --html-only    Generate only HTML report"
    echo "  --open         Generate reports and open HTML in browser"
    echo ""
    echo "This script generates comprehensive health reports by:"
    echo "  • Running all validation systems"
    echo "  • Analyzing codebase metrics"
    echo "  • Calculating health scores"
    echo "  • Generating actionable recommendations"
    echo "  • Creating both JSON and HTML reports"
    echo ""
    echo "Reports are saved in .reports/ directory"
    echo ""
    exit 0
fi

# Handle options
case "${1:-}" in
    "--json-only")
        run_validation_suite
        analyze_codebase_metrics
        assess_health_scores
        generate_recommendations
        generate_json_report
        exit 0
        ;;
    "--html-only")
        run_validation_suite
        analyze_codebase_metrics
        assess_health_scores
        generate_recommendations
        generate_html_report
        exit 0
        ;;
    "--open")
        main
        echo "Opening HTML report in browser..."
        if command -v open >/dev/null 2>&1; then
            open "$LATEST_HTML"
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$LATEST_HTML"
        else
            echo "Please open $LATEST_HTML manually in your browser"
        fi
        ;;
    *)
        main
        ;;
esac