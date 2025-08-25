#!/bin/bash

# Modularization Progress Monitoring System for Nestory
# Tracks file sizes, modularization metrics, and prevents architectural regression
# Part of comprehensive automation suite

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
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METRICS_DIR="${PROJECT_ROOT}/.metrics"
HISTORICAL_DATA="${METRICS_DIR}/modularization-history.json"
CURRENT_METRICS="${METRICS_DIR}/current-metrics.json"
ALERTS_FILE="${METRICS_DIR}/alerts.log"
BASELINE_FILE="${METRICS_DIR}/modularization-baseline.json"

# Thresholds
COMPONENT_MAX_LINES=200
SECTION_MAX_LINES=150
CARD_MAX_LINES=100
MONOLITH_THRESHOLD=600
WARNING_THRESHOLD=400
CRITICAL_THRESHOLD=500

# Metrics tracking
declare -A metrics
declare -a alerts
declare -a recommendations

# Ensure metrics directory exists
mkdir -p "$METRICS_DIR"

log_metric() {
    local category=$1
    local name=$2
    local value=$3
    local threshold=${4:-""}
    
    metrics["${category}.${name}"]=$value
    
    if [ -n "$threshold" ] && [ "$value" -gt "$threshold" ]; then
        alerts+=("$category.$name exceeds threshold: $value > $threshold")
    fi
}

log_alert() {
    local level=$1
    local message=$2
    alerts+=("[$level] $message")
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$ALERTS_FILE"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

analyze_file_size_distribution() {
    print_header "📏 File Size Distribution Analysis"
    
    local tiny_files=0       # < 50 lines
    local small_files=0      # 50-199 lines
    local medium_files=0     # 200-399 lines
    local large_files=0      # 400-599 lines
    local huge_files=0       # 600+ lines
    local total_files=0
    local total_lines=0
    
    declare -a huge_file_list
    declare -a large_file_list
    
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local lines=$(wc -l < "$file" | tr -d ' ')
            total_files=$((total_files + 1))
            total_lines=$((total_lines + lines))
            
            local rel_file="${file#$PROJECT_ROOT/}"
            
            if [ "$lines" -lt 50 ]; then
                tiny_files=$((tiny_files + 1))
            elif [ "$lines" -lt 200 ]; then
                small_files=$((small_files + 1))
            elif [ "$lines" -lt 400 ]; then
                medium_files=$((medium_files + 1))
            elif [ "$lines" -lt 600 ]; then
                large_files=$((large_files + 1))
                large_file_list+=("$rel_file:$lines")
            else
                huge_files=$((huge_files + 1))
                huge_file_list+=("$rel_file:$lines")
            fi
        fi
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -not -path "*/build/*" \
        -not -path "*/.build/*" \
        -not -path "*/DerivedData/*" \
        -not -path "*/Pods/*" \
        -not -path "*/DevTools/*")
    
    # Log metrics
    log_metric "files" "total" $total_files
    log_metric "files" "tiny" $tiny_files
    log_metric "files" "small" $small_files
    log_metric "files" "medium" $medium_files
    log_metric "files" "large" $large_files $large_files
    log_metric "files" "huge" $huge_files 0  # Any huge file triggers alert
    log_metric "lines" "total" $total_lines
    log_metric "lines" "average" $((total_lines / total_files))
    
    # Display results
    echo "File Size Distribution:"
    echo -e "  Tiny (<50 lines):     ${GREEN}$tiny_files${NC} files"
    echo -e "  Small (50-199):       ${GREEN}$small_files${NC} files"
    echo -e "  Medium (200-399):     ${YELLOW}$medium_files${NC} files"
    echo -e "  Large (400-599):      ${RED}$large_files${NC} files"
    echo -e "  Huge (600+ lines):    ${BOLD_RED}$huge_files${NC} files"
    echo ""
    echo -e "Total: ${BLUE}$total_files${NC} Swift files, ${BLUE}$total_lines${NC} lines"
    echo -e "Average: ${CYAN}$((total_lines / total_files))${NC} lines per file"
    
    # Alert on problematic files
    if [ $huge_files -gt 0 ]; then
        log_alert "CRITICAL" "$huge_files files exceed 600 lines (monolith threshold)"
        echo ""
        echo -e "${BOLD_RED}🚨 Monolithic files (600+ lines):${NC}"
        for file_info in "${huge_file_list[@]}"; do
            IFS=':' read -r file lines <<< "$file_info"
            echo -e "  • ${RED}$file${NC} (${BOLD_RED}$lines lines${NC})"
        done
        recommendations+=("Consider modularizing files over 600 lines")
    fi
    
    if [ $large_files -gt 5 ]; then
        log_alert "WARNING" "$large_files files are large (400-599 lines)"
        recommendations+=("Monitor large files for potential modularization")
    fi
    
    # Calculate modularization health score
    local good_files=$((tiny_files + small_files))
    local health_score=$((good_files * 100 / total_files))
    log_metric "health" "file_size_score" $health_score
    
    echo ""
    if [ $health_score -ge 80 ]; then
        echo -e "File Size Health: ${BOLD_GREEN}$health_score%${NC} - Excellent modularization!"
    elif [ $health_score -ge 60 ]; then
        echo -e "File Size Health: ${YELLOW}$health_score%${NC} - Good, but room for improvement"
    else
        echo -e "File Size Health: ${RED}$health_score%${NC} - Needs significant modularization"
    fi
}

analyze_modular_components() {
    print_header "🧩 Modular Components Analysis"
    
    local component_dirs=0
    local total_components=0
    local oversized_components=0
    local empty_components=0
    
    declare -a component_violations
    
    # Analyze different types of modular directories
    local modular_patterns=(
        "*/Components:Component"
        "*/Sections:Section" 
        "*/Cards:Card"
        "*/Operations:Operation"
        "*/Types:Type"
        "*/Utils:Utility"
    )
    
    for pattern_info in "${modular_patterns[@]}"; do
        IFS=':' read -r pattern type <<< "$pattern_info"
        
        echo ""
        echo -e "${CYAN}$type directories:${NC}"
        
        local pattern_count=0
        local pattern_files=0
        local pattern_violations=0
        
        for dir in $PROJECT_ROOT/$pattern; do
            if [ -d "$dir" ]; then
                component_dirs=$((component_dirs + 1))
                pattern_count=$((pattern_count + 1))
                
                local rel_dir="${dir#$PROJECT_ROOT/}"
                local file_count=$(find "$dir" -name "*.swift" -type f | wc -l | tr -d ' ')
                
                if [ "$file_count" -eq 0 ]; then
                    echo -e "  ${YELLOW}⚠${NC} Empty: $rel_dir"
                    empty_components=$((empty_components + 1))
                else
                    pattern_files=$((pattern_files + file_count))
                    total_components=$((total_components + file_count))
                    
                    # Check file sizes within component
                    local oversized_in_dir=0
                    while IFS= read -r file; do
                        local lines=$(wc -l < "$file" | tr -d ' ')
                        local rel_file="${file#$PROJECT_ROOT/}"
                        
                        local threshold=$COMPONENT_MAX_LINES
                        if [[ "$type" == "Section" ]]; then
                            threshold=$SECTION_MAX_LINES
                        elif [[ "$type" == "Card" ]]; then
                            threshold=$CARD_MAX_LINES
                        fi
                        
                        if [ "$lines" -gt "$threshold" ]; then
                            echo -e "  ${RED}✗${NC} Oversized: $rel_file (${RED}$lines lines${NC} > $threshold)"
                            oversized_components=$((oversized_components + 1))
                            oversized_in_dir=$((oversized_in_dir + 1))
                            pattern_violations=$((pattern_violations + 1))
                            component_violations+=("$rel_file:$lines:$threshold")
                        fi
                    done < <(find "$dir" -name "*.swift" -type f)
                    
                    if [ $oversized_in_dir -eq 0 ]; then
                        echo -e "  ${GREEN}✓${NC} Good: $rel_dir ($file_count files)"
                    fi
                fi
            fi
        done
        
        if [ $pattern_count -gt 0 ]; then
            echo -e "  Summary: ${BLUE}$pattern_count${NC} directories, ${BLUE}$pattern_files${NC} files"
            if [ $pattern_violations -eq 0 ]; then
                echo -e "  ${GREEN}All $type components are appropriately sized${NC}"
            else
                echo -e "  ${RED}$pattern_violations violations found${NC}"
            fi
        else
            echo -e "  ${YELLOW}No $type directories found${NC}"
        fi
    done
    
    # Log metrics
    log_metric "components" "directories" $component_dirs
    log_metric "components" "total_files" $total_components
    log_metric "components" "oversized" $oversized_components 0
    log_metric "components" "empty_dirs" $empty_components 0
    
    # Calculate component health score
    if [ $total_components -gt 0 ]; then
        local good_components=$((total_components - oversized_components))
        local component_health=$((good_components * 100 / total_components))
        log_metric "health" "component_score" $component_health
        
        echo ""
        echo -e "Component Health: ${BLUE}$component_health%${NC}"
        
        if [ $component_health -ge 90 ]; then
            echo -e "${BOLD_GREEN}Excellent modular design!${NC}"
        elif [ $component_health -ge 75 ]; then
            echo -e "${YELLOW}Good modularization with room for improvement${NC}"
        else
            echo -e "${RED}Components need significant size reduction${NC}"
            recommendations+=("Break down oversized components into smaller units")
        fi
    fi
    
    if [ $empty_components -gt 0 ]; then
        log_alert "WARNING" "$empty_components empty component directories found"
        recommendations+=("Remove or populate empty component directories")
    fi
}

analyze_architectural_compliance() {
    print_header "🏗️ Architectural Compliance Analysis"
    
    local layer_violations=0
    local import_violations=0
    local naming_violations=0
    
    # Check import compliance for each layer
    declare -A layer_rules=(
        ["Foundation"]="Swift only"
        ["Infrastructure"]="Foundation only"
        ["Services"]="Foundation, Infrastructure"
        ["UI"]="Foundation only"
        ["Features"]="Foundation, UI, Services"
        ["App-Main"]="All layers"
    )
    
    for layer in "${!layer_rules[@]}"; do
        if [ -d "$PROJECT_ROOT/$layer" ]; then
            echo ""
            echo -e "${CYAN}$layer layer:${NC}"
            
            local layer_files=0
            local layer_violations_count=0
            
            while IFS= read -r file; do
                layer_files=$((layer_files + 1))
                local rel_file="${file#$PROJECT_ROOT/}"
                
                # Check imports
                local invalid_imports=()
                while IFS= read -r import_line; do
                    local imported_module=$(echo "$import_line" | sed 's/import[[:space:]]*//g' | cut -d' ' -f1)
                    
                    # Skip system imports
                    if [[ "$imported_module" =~ ^(Swift|Foundation|UIKit|SwiftUI|Combine|CloudKit|SwiftData|ComposableArchitecture)$ ]]; then
                        continue
                    fi
                    
                    # Check layer compliance
                    case "$layer" in
                        "Foundation")
                            if [[ ! "$imported_module" =~ ^(Swift|Foundation)$ ]]; then
                                invalid_imports+=("$imported_module")
                            fi
                            ;;
                        "Infrastructure")
                            if [[ ! "$imported_module" =~ ^(Swift|Foundation)$ ]] && [ "$imported_module" != "Foundation" ]; then
                                invalid_imports+=("$imported_module")
                            fi
                            ;;
                        "UI")
                            if [[ ! "$imported_module" =~ ^(Swift|Foundation|UIKit|SwiftUI)$ ]] && [ "$imported_module" != "Foundation" ]; then
                                invalid_imports+=("$imported_module")
                            fi
                            ;;
                    esac
                done < <(grep "^import " "$file" 2>/dev/null || true)
                
                if [ ${#invalid_imports[@]} -gt 0 ]; then
                    echo -e "  ${RED}✗${NC} Import violations in $rel_file:"
                    for invalid_import in "${invalid_imports[@]}"; do
                        echo -e "    • ${RED}$invalid_import${NC}"
                    done
                    layer_violations_count=$((layer_violations_count + 1))
                    import_violations=$((import_violations + 1))
                fi
                
            done < <(find "$PROJECT_ROOT/$layer" -name "*.swift" -type f \
                -not -path "*/build/*" \
                -not -path "*/.build/*")
            
            if [ $layer_violations_count -eq 0 ]; then
                echo -e "  ${GREEN}✓${NC} All $layer_files files comply with layer rules"
            else
                echo -e "  ${RED}$layer_violations_count/$layer_files files have violations${NC}"
            fi
            
            log_metric "architecture" "${layer}_files" $layer_files
            log_metric "architecture" "${layer}_violations" $layer_violations_count
        fi
    done
    
    # Check naming conventions for modular components
    echo ""
    echo -e "${CYAN}Naming Convention Analysis:${NC}"
    
    local naming_checks=0
    local naming_violations_count=0
    
    while IFS= read -r file; do
        naming_checks=$((naming_checks + 1))
        local basename=$(basename "$file" .swift)
        local rel_file="${file#$PROJECT_ROOT/}"
        
        local violations=()
        
        # Component naming rules
        if [[ "$rel_file" == *"/Components/"* ]]; then
            if [[ ! "$basename" =~ (View|Component|Manager|Handler|Helper|Coordinator)$ ]]; then
                violations+=("Component should end with View/Component/Manager/Handler/Helper/Coordinator")
            fi
        elif [[ "$rel_file" == *"/Sections/"* ]]; then
            if [[ ! "$basename" =~ (Section|View|Card)$ ]]; then
                violations+=("Section should end with Section/View/Card")
            fi
        elif [[ "$rel_file" == *"/Cards/"* ]]; then
            if [[ ! "$basename" =~ (Card|View)$ ]]; then
                violations+=("Card should end with Card/View")
            fi
        elif [[ "$rel_file" == *"/Operations/"* ]]; then
            if [[ ! "$basename" =~ (Operation|Manager|Service|Engine)$ ]]; then
                violations+=("Operation should end with Operation/Manager/Service/Engine")
            fi
        elif [[ "$rel_file" == *"/Types/"* ]]; then
            if [[ "$basename" =~ (View|Manager|Service)$ ]]; then
                violations+=("Type files should not end with View/Manager/Service")
            fi
        fi
        
        if [ ${#violations[@]} -gt 0 ]; then
            echo -e "  ${YELLOW}⚠${NC} Naming issue in $rel_file:"
            for violation in "${violations[@]}"; do
                echo -e "    • $violation"
            done
            naming_violations_count=$((naming_violations_count + 1))
            naming_violations=$((naming_violations + 1))
        fi
        
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -path "*/Components/*" -o -path "*/Sections/*" -o -path "*/Cards/*" -o -path "*/Operations/*" -o -path "*/Types/*" \
        -not -path "*/build/*" \
        -not -path "*/.build/*")
    
    if [ $naming_violations_count -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} All $naming_checks modular files follow naming conventions"
    else
        echo -e "  ${YELLOW}$naming_violations_count/$naming_checks files have naming issues${NC}"
    fi
    
    # Log overall architecture metrics
    log_metric "architecture" "layer_violations" $layer_violations 0
    log_metric "architecture" "import_violations" $import_violations 0
    log_metric "architecture" "naming_violations" $naming_violations 5
    
    # Calculate architecture health score
    local total_violations=$((layer_violations + import_violations + naming_violations))
    if [ $total_violations -eq 0 ]; then
        log_metric "health" "architecture_score" 100
        echo ""
        echo -e "Architecture Health: ${BOLD_GREEN}100%${NC} - Perfect compliance!"
    else
        local architecture_health=$((100 - total_violations * 5))  # Each violation costs 5%
        if [ $architecture_health -lt 0 ]; then
            architecture_health=0
        fi
        log_metric "health" "architecture_score" $architecture_health
        
        echo ""
        echo -e "Architecture Health: ${YELLOW}$architecture_health%${NC}"
        
        if [ $total_violations -gt 0 ]; then
            log_alert "WARNING" "$total_violations architectural violations found"
            recommendations+=("Address architectural violations to improve code maintainability")
        fi
    fi
}

track_modularization_progress() {
    print_header "📈 Modularization Progress Tracking"
    
    # Save current metrics
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local current_data=$(cat << EOF
{
  "timestamp": "$timestamp",
  "metrics": {
EOF
    
    local first=true
    for key in "${!metrics[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            current_data+=","
        fi
        current_data+="\n    \"$key\": ${metrics[$key]}"
    done
    
    current_data+="\n  }"
    current_data+="\n}"
    
    echo -e "$current_data" > "$CURRENT_METRICS"
    
    # Load historical data if it exists
    if [ -f "$HISTORICAL_DATA" ]; then
        # Append to historical data
        local historical=$(cat "$HISTORICAL_DATA")
        if [[ "$historical" == "[]" ]] || [[ "$historical" == "" ]]; then
            echo "[$current_data]" > "$HISTORICAL_DATA"
        else
            # Remove closing bracket, add comma and new data, close bracket
            echo "${historical%]}, $current_data]" > "$HISTORICAL_DATA"
        fi
    else
        echo "[$current_data]" > "$HISTORICAL_DATA"
    fi
    
    # Calculate trends if we have historical data
    if command -v jq >/dev/null 2>&1 && [ -f "$HISTORICAL_DATA" ]; then
        echo "Progress tracking enabled with jq support"
        
        # Get previous metrics if available
        local prev_huge_files=$(jq -r '.[-2].metrics."files.huge" // "N/A"' "$HISTORICAL_DATA" 2>/dev/null || echo "N/A")
        local curr_huge_files=${metrics["files.huge"]}
        
        if [ "$prev_huge_files" != "N/A" ] && [ "$prev_huge_files" != "null" ]; then
            local huge_change=$((curr_huge_files - prev_huge_files))
            if [ $huge_change -lt 0 ]; then
                echo -e "  ${GREEN}✓${NC} Huge files reduced by ${GREEN}${huge_change#-}${NC} since last check"
            elif [ $huge_change -gt 0 ]; then
                echo -e "  ${RED}⚠${NC} Huge files increased by ${RED}$huge_change${NC} since last check"
                log_alert "WARNING" "Regression: $huge_change new files over 600 lines"
            else
                echo -e "  ${BLUE}==${NC} No change in huge files count"
            fi
        fi
        
        # Component health trend
        local prev_component_score=$(jq -r '.[-2].metrics."health.component_score" // "N/A"' "$HISTORICAL_DATA" 2>/dev/null || echo "N/A")
        local curr_component_score=${metrics["health.component_score"]:-"N/A"}
        
        if [ "$prev_component_score" != "N/A" ] && [ "$curr_component_score" != "N/A" ] && [ "$prev_component_score" != "null" ]; then
            local score_change=$((curr_component_score - prev_component_score))
            if [ $score_change -gt 0 ]; then
                echo -e "  ${GREEN}↗${NC} Component health improved by ${GREEN}+$score_change%${NC}"
            elif [ $score_change -lt 0 ]; then
                echo -e "  ${RED}↘${NC} Component health decreased by ${RED}$score_change%${NC}"
            fi
        fi
    else
        echo "Progress tracking (basic mode - install jq for trend analysis)"
    fi
    
    echo ""
    echo -e "Metrics saved to: ${BLUE}$CURRENT_METRICS${NC}"
    echo -e "Historical data: ${BLUE}$HISTORICAL_DATA${NC}"
}

generate_recommendations() {
    print_header "💡 Modularization Recommendations"
    
    if [ ${#recommendations[@]} -eq 0 ]; then
        echo -e "${BOLD_GREEN}🎉 No recommendations - excellent modularization!${NC}"
        return
    fi
    
    echo "Based on the analysis, here are specific recommendations:"
    echo ""
    
    for i in "${!recommendations[@]}"; do
        echo -e "${CYAN}$((i + 1)).${NC} ${recommendations[$i]}"
    done
    
    # Add specific action items based on metrics
    echo ""
    echo -e "${YELLOW}Immediate Actions:${NC}"
    
    if [ "${metrics['files.huge']}" -gt 0 ]; then
        echo "  • Run 'make file-report' to see detailed file size breakdown"
        echo "  • Consider breaking down files over 600 lines into modular components"
    fi
    
    if [ "${metrics['components.oversized']}" -gt 0 ]; then
        echo "  • Review oversized components and split into smaller, focused units"
    fi
    
    if [ "${metrics['components.empty_dirs']}" -gt 0 ]; then
        echo "  • Remove empty component directories or add appropriate files"
    fi
    
    if [ "${metrics['architecture.import_violations']}" -gt 0 ]; then
        echo "  • Review and fix import violations to maintain layer separation"
    fi
    
    echo ""
    echo "Run this script regularly to track modularization progress."
}

generate_alerts_summary() {
    print_header "🚨 Alerts Summary"
    
    if [ ${#alerts[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ No alerts - all metrics within acceptable ranges${NC}"
        return
    fi
    
    echo -e "${YELLOW}Active alerts (${#alerts[@]}):${NC}"
    echo ""
    
    for alert in "${alerts[@]}"; do
        if [[ "$alert" == *"CRITICAL"* ]]; then
            echo -e "  ${BOLD_RED}🚨${NC} $alert"
        else
            echo -e "  ${YELLOW}⚠${NC} $alert"
        fi
    done
    
    echo ""
    echo -e "Alert log: ${BLUE}$ALERTS_FILE${NC}"
}

# Create baseline if it doesn't exist
create_baseline() {
    if [ ! -f "$BASELINE_FILE" ]; then
        echo "Creating modularization baseline..."
        
        local baseline_data=$(cat << EOF
{
  "created": "$(date '+%Y-%m-%d %H:%M:%S')",
  "target_metrics": {
    "files.huge": 0,
    "files.large": 5,
    "health.file_size_score": 85,
    "health.component_score": 90,
    "health.architecture_score": 95,
    "components.oversized": 0,
    "architecture.import_violations": 0
  },
  "notes": "Baseline established during modularization automation setup"
}
EOF
        )
        
        echo "$baseline_data" > "$BASELINE_FILE"
        echo -e "Baseline saved to: ${BLUE}$BASELINE_FILE${NC}"
    fi
}

# Main execution
main() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║              Modularization Progress Monitor                 ║${NC}"
    echo -e "${PURPLE}║                Nestory Automation Suite                     ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    cd "$PROJECT_ROOT"
    
    create_baseline
    analyze_file_size_distribution
    analyze_modular_components
    analyze_architectural_compliance
    track_modularization_progress
    generate_recommendations
    generate_alerts_summary
    
    # Exit with appropriate code based on alerts
    local critical_alerts=0
    for alert in "${alerts[@]}"; do
        if [[ "$alert" == *"CRITICAL"* ]]; then
            critical_alerts=$((critical_alerts + 1))
        fi
    done
    
    echo ""
    if [ $critical_alerts -gt 0 ]; then
        echo -e "${BOLD_RED}❌ Monitoring detected $critical_alerts critical issues${NC}"
        exit 1
    elif [ ${#alerts[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️ Monitoring completed with ${#alerts[@]} warnings${NC}"
        exit 2
    else
        echo -e "${BOLD_GREEN}✅ All modularization metrics are healthy${NC}"
        exit 0
    fi
}

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Modularization Progress Monitor for Nestory"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --baseline     Show current baseline targets"
    echo "  --history      Show historical metrics (requires jq)"
    echo "  --alerts       Show only alert summary"
    echo ""
    echo "This script monitors:"
    echo "  • File size distribution and trends"
    echo "  • Modular component health"
    echo "  • Architectural compliance"
    echo "  • Progress toward modularization goals"
    echo ""
    exit 0
fi

# Handle special options
case "${1:-}" in
    "--baseline")
        if [ -f "$BASELINE_FILE" ]; then
            echo "Current modularization baseline:"
            cat "$BASELINE_FILE"
        else
            echo "No baseline file found. Run without options to create one."
        fi
        exit 0
        ;;
    "--history")
        if [ -f "$HISTORICAL_DATA" ] && command -v jq >/dev/null 2>&1; then
            echo "Modularization history:"
            jq -r '.[] | "\(.timestamp): \(.metrics."files.huge" // "N/A") huge files, \(.metrics."health.file_size_score" // "N/A")% health"' "$HISTORICAL_DATA"
        else
            echo "No historical data available or jq not installed"
        fi
        exit 0
        ;;
    "--alerts")
        generate_alerts_summary
        exit 0
        ;;
esac

# Run main function
main "$@"