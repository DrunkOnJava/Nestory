#!/bin/bash

# Enhanced Architecture Verification for Modularized Nestory
# Validates 6-layer TCA architecture with modular component compliance
# Prevents re-introduction of monolithic patterns

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
ARCH_LOG="${PROJECT_ROOT}/.architecture-verification.log"
VIOLATIONS_FILE="${PROJECT_ROOT}/.architecture-violations.json"

# Layer definitions for 6-layer TCA architecture
declare -A LAYER_RULES=(
    ["Foundation"]="SwiftStdlib"
    ["Infrastructure"]="Foundation,SwiftStdlib"
    ["Services"]="Foundation,Infrastructure,SwiftStdlib"
    ["UI"]="Foundation,SwiftStdlib"
    ["Features"]="Foundation,UI,Services,SwiftStdlib"
    ["App-Main"]="Foundation,Infrastructure,Services,UI,Features,SwiftStdlib"
)

# Allowed system imports for each layer
declare -A SYSTEM_IMPORTS=(
    ["Foundation"]="Swift,Foundation"
    ["Infrastructure"]="Swift,Foundation,Combine,CloudKit,SwiftData"
    ["Services"]="Swift,Foundation,Combine,CloudKit,SwiftData,ComposableArchitecture"
    ["UI"]="Swift,Foundation,SwiftUI,UIKit,Combine"
    ["Features"]="Swift,Foundation,SwiftUI,UIKit,Combine,ComposableArchitecture"
    ["App-Main"]="Swift,Foundation,SwiftUI,UIKit,Combine,ComposableArchitecture,CloudKit,SwiftData"
)

# TCA-specific patterns that must be enforced
declare -A TCA_PATTERNS=(
    ["Features"]="@Reducer,Action,State,Dependency"
    ["Services"]="protocol.*Service,DependencyKey"
    ["UI"]="View,ObservableObject"
)

# Modular component rules
declare -A MODULAR_RULES=(
    ["Components"]="View,Component,Manager,Handler,Helper,Coordinator"
    ["Sections"]="Section,View,Card"
    ["Cards"]="Card,View"
    ["Operations"]="Operation,Manager,Service,Engine"
    ["Types"]="struct,enum,typealias,protocol"
    ["Utils"]="static func,extension"
)

# Counters
total_files=0
violations=0
warnings=0
tca_compliance_issues=0
modular_violations=0

# Arrays for detailed reporting
declare -a critical_violations
declare -a warning_violations
declare -a tca_issues
declare -a modular_issues

log_violation() {
    local level=$1
    local file=$2
    local rule=$3
    local details=$4
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local rel_file="${file#$PROJECT_ROOT/}"
    
    echo "[$timestamp] [$level] $rel_file: $rule - $details" >> "$ARCH_LOG"
    
    case $level in
        "CRITICAL")
            critical_violations+=("$rel_file: $rule - $details")
            violations=$((violations + 1))
            ;;
        "WARNING")
            warning_violations+=("$rel_file: $rule - $details")
            warnings=$((warnings + 1))
            ;;
        "TCA")
            tca_issues+=("$rel_file: $rule - $details")
            tca_compliance_issues=$((tca_compliance_issues + 1))
            ;;
        "MODULAR")
            modular_issues+=("$rel_file: $rule - $details")
            modular_violations=$((modular_violations + 1))
            ;;
    esac
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

get_layer_for_file() {
    local file=$1
    local rel_file="${file#$PROJECT_ROOT/}"
    
    if [[ "$rel_file" == Foundation/* ]]; then
        echo "Foundation"
    elif [[ "$rel_file" == Infrastructure/* ]]; then
        echo "Infrastructure"
    elif [[ "$rel_file" == Services/* ]]; then
        echo "Services"
    elif [[ "$rel_file" == UI/* ]]; then
        echo "UI"
    elif [[ "$rel_file" == Features/* ]]; then
        echo "Features"
    elif [[ "$rel_file" == App-Main/* ]]; then
        echo "App-Main"
    else
        echo "Unknown"
    fi
}

is_system_import() {
    local import=$1
    local system_modules="Swift Foundation SwiftUI UIKit Combine CloudKit SwiftData ComposableArchitecture AVFoundation Vision VisionKit Network Security CryptoKit OSLog MetricKit BackgroundTasks UserNotifications StoreKit"
    
    for module in $system_modules; do
        if [[ "$import" == "$module" ]]; then
            return 0
        fi
    done
    return 1
}

validate_layer_imports() {
    print_header "🏗️ Layer Import Validation"
    
    local layer_files_checked=0
    local layer_violations_found=0
    
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            total_files=$((total_files + 1))
            layer_files_checked=$((layer_files_checked + 1))
            
            local layer=$(get_layer_for_file "$file")
            local rel_file="${file#$PROJECT_ROOT/}"
            
            if [ "$layer" == "Unknown" ]; then
                log_violation "WARNING" "$file" "UnknownLayer" "File not in recognized architecture layer"
                continue
            fi
            
            # Get allowed imports for this layer
            local allowed_layers="${LAYER_RULES[$layer]}"
            local allowed_systems="${SYSTEM_IMPORTS[$layer]}"
            
            # Check each import
            while IFS= read -r import_line; do
                if [[ "$import_line" =~ ^import[[:space:]]+([^[:space:]]+) ]]; then
                    local imported_module="${BASH_REMATCH[1]}"
                    
                    # Skip if it's a system import
                    if is_system_import "$imported_module"; then
                        # Check if system import is allowed for this layer
                        if [[ ",$allowed_systems," == *",$imported_module,"* ]]; then
                            continue
                        else
                            log_violation "WARNING" "$file" "UnauthorizedSystemImport" "Layer $layer should not import $imported_module"
                            layer_violations_found=$((layer_violations_found + 1))
                        fi
                        continue
                    fi
                    
                    # Check if importing from an allowed layer
                    local import_allowed=false
                    for allowed_layer in ${allowed_layers//,/ }; do
                        if [[ "$imported_module" == "$allowed_layer"* ]] || [[ "$imported_module" == "$allowed_layer" ]]; then
                            import_allowed=true
                            break
                        fi
                    done
                    
                    if [ "$import_allowed" = false ]; then
                        log_violation "CRITICAL" "$file" "IllegalLayerImport" "Layer $layer cannot import $imported_module (allowed: $allowed_layers)"
                        layer_violations_found=$((layer_violations_found + 1))
                    fi
                fi
            done < <(grep "^import " "$file" 2>/dev/null || true)
        fi
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -not -path "*/build/*" \
        -not -path "*/.build/*" \
        -not -path "*/DerivedData/*" \
        -not -path "*/DevTools/*" \
        -not -path "*/Archive/*")
    
    echo "Checked $layer_files_checked files across all layers"
    if [ $layer_violations_found -eq 0 ]; then
        echo -e "${GREEN}✓ All imports comply with 6-layer architecture${NC}"
    else
        echo -e "${RED}✗ Found $layer_violations_found layer import violations${NC}"
    fi
}

validate_tca_compliance() {
    print_header "🎯 TCA Architecture Compliance"
    
    local tca_files_checked=0
    local tca_violations_found=0
    
    # Check Features layer for TCA compliance
    if [ -d "$PROJECT_ROOT/Features" ]; then
        echo "Validating TCA patterns in Features layer..."
        
        while IFS= read -r file; do
            tca_files_checked=$((tca_files_checked + 1))
            local rel_file="${file#$PROJECT_ROOT/}"
            local basename=$(basename "$file" .swift)
            
            # Feature files should use TCA patterns
            if [[ "$basename" == *"Feature" ]]; then
                # Check for required TCA elements
                local has_reducer=false
                local has_state=false
                local has_action=false
                local has_dependency=false
                
                while IFS= read -r line; do
                    if [[ "$line" =~ @Reducer ]]; then
                        has_reducer=true
                    elif [[ "$line" =~ (struct|enum)[[:space:]]+.*State ]]; then
                        has_state=true
                    elif [[ "$line" =~ (enum)[[:space:]]+.*Action ]]; then
                        has_action=true
                    elif [[ "$line" =~ @Dependency ]]; then
                        has_dependency=true
                    fi
                done < "$file"
                
                if [ "$has_reducer" = false ]; then
                    log_violation "TCA" "$file" "MissingReducer" "Feature file should use @Reducer"
                    tca_violations_found=$((tca_violations_found + 1))
                fi
                
                if [ "$has_state" = false ]; then
                    log_violation "TCA" "$file" "MissingState" "Feature file should define State"
                    tca_violations_found=$((tca_violations_found + 1))
                fi
                
                if [ "$has_action" = false ]; then
                    log_violation "TCA" "$file" "MissingAction" "Feature file should define Action enum"
                    tca_violations_found=$((tca_violations_found + 1))
                fi
            fi
            
            # View files should use proper TCA integration
            if [[ "$basename" == *"View" ]] && [[ "$rel_file" == Features/* ]]; then
                local has_store=false
                local has_with_viewstore=false
                
                while IFS= read -r line; do
                    if [[ "$line" =~ Store.*Of|StoreOf ]]; then
                        has_store=true
                    elif [[ "$line" =~ WithViewStore|@ObservedObject.*store ]]; then
                        has_with_viewstore=true
                    fi
                done < "$file"
                
                if [ "$has_store" = false ]; then
                    log_violation "TCA" "$file" "MissingStore" "Feature view should use TCA Store"
                    tca_violations_found=$((tca_violations_found + 1))
                fi
            fi
            
        done < <(find "$PROJECT_ROOT/Features" -name "*.swift" -type f)
        
        echo "Checked $tca_files_checked Feature files"
    fi
    
    # Check Services layer for proper dependency injection
    if [ -d "$PROJECT_ROOT/Services" ]; then
        echo "Validating service dependency patterns..."
        
        while IFS= read -r file; do
            local rel_file="${file#$PROJECT_ROOT/}"
            local basename=$(basename "$file" .swift)
            
            # Service files should follow dependency injection patterns
            if [[ "$basename" == *"Service" ]] && [[ ! "$basename" == "Mock"* ]]; then
                local has_protocol=false
                local has_dependency_key=false
                
                # Check if there's a corresponding protocol
                if grep -q "protocol.*$basename" "$file" 2>/dev/null; then
                    has_protocol=true
                fi
                
                # Check for dependency key (could be in separate file)
                local service_name="${basename%Service}"
                if grep -r "DependencyKey" "$PROJECT_ROOT/Services" | grep -q "$service_name" 2>/dev/null; then
                    has_dependency_key=true
                fi
                
                if [ "$has_protocol" = false ]; then
                    log_violation "TCA" "$file" "MissingServiceProtocol" "Service should define or implement a protocol"
                    tca_violations_found=$((tca_violations_found + 1))
                fi
            fi
            
        done < <(find "$PROJECT_ROOT/Services" -name "*.swift" -type f -not -path "*/Mock*")
    fi
    
    if [ $tca_violations_found -eq 0 ]; then
        echo -e "${GREEN}✓ TCA architecture patterns properly implemented${NC}"
    else
        echo -e "${RED}✗ Found $tca_violations_found TCA compliance issues${NC}"
    fi
}

validate_modular_architecture() {
    print_header "🧩 Modular Component Architecture"
    
    local modular_files_checked=0
    local modular_violations_found=0
    
    # Define modular directory patterns
    local modular_patterns=(
        "*/Components:Component"
        "*/Sections:Section"
        "*/Cards:Card"
        "*/Operations:Operation"
        "*/Types:Type"
        "*/Utils:Utility"
    )
    
    for pattern_info in "${modular_patterns[@]}"; do
        IFS=':' read -r pattern expected_type <<< "$pattern_info"
        
        echo ""
        echo -e "${CYAN}Validating $expected_type files...${NC}"
        
        local pattern_files=0
        local pattern_violations=0
        
        for dir in $PROJECT_ROOT/$pattern; do
            if [ -d "$dir" ]; then
                while IFS= read -r file; do
                    modular_files_checked=$((modular_files_checked + 1))
                    pattern_files=$((pattern_files + 1))
                    
                    local rel_file="${file#$PROJECT_ROOT/}"
                    local basename=$(basename "$file" .swift)
                    local lines=$(wc -l < "$file" | tr -d ' ')
                    
                    # Check naming conventions
                    local naming_valid=false
                    case "$expected_type" in
                        "Component")
                            if [[ "$basename" =~ (View|Component|Manager|Handler|Helper|Coordinator)$ ]]; then
                                naming_valid=true
                            fi
                            ;;
                        "Section")
                            if [[ "$basename" =~ (Section|View|Card)$ ]]; then
                                naming_valid=true
                            fi
                            ;;
                        "Card")
                            if [[ "$basename" =~ (Card|View)$ ]]; then
                                naming_valid=true
                            fi
                            ;;
                        "Operation")
                            if [[ "$basename" =~ (Operation|Manager|Service|Engine)$ ]]; then
                                naming_valid=true
                            fi
                            ;;
                        "Type"|"Utility")
                            # More flexible naming for types and utilities
                            naming_valid=true
                            ;;
                    esac
                    
                    if [ "$naming_valid" = false ]; then
                        log_violation "MODULAR" "$file" "InvalidNaming" "$expected_type should follow naming convention"
                        pattern_violations=$((pattern_violations + 1))
                        modular_violations_found=$((modular_violations_found + 1))
                    fi
                    
                    # Check file size for modular components
                    local max_lines=200
                    case "$expected_type" in
                        "Card") max_lines=100 ;;
                        "Section") max_lines=150 ;;
                        "Component") max_lines=200 ;;
                        "Operation") max_lines=250 ;;
                    esac
                    
                    if [ "$lines" -gt "$max_lines" ]; then
                        log_violation "MODULAR" "$file" "OversizedComponent" "$expected_type exceeds $max_lines lines ($lines lines)"
                        pattern_violations=$((pattern_violations + 1))
                        modular_violations_found=$((modular_violations_found + 1))
                    fi
                    
                    # Check for Single Responsibility Principle
                    local struct_count=$(grep -c "^struct " "$file" 2>/dev/null || echo "0")
                    local class_count=$(grep -c "^class " "$file" 2>/dev/null || echo "0")
                    local total_types=$((struct_count + class_count))
                    
                    if [ "$total_types" -gt 2 ] && [[ "$expected_type" != "Type" ]]; then
                        log_violation "MODULAR" "$file" "MultipleResponsibilities" "$expected_type contains $total_types types (should be 1-2)"
                        pattern_violations=$((pattern_violations + 1))
                        modular_violations_found=$((modular_violations_found + 1))
                    fi
                    
                    # Check for prohibited patterns in modular components
                    if [[ "$expected_type" == "Component" ]] || [[ "$expected_type" == "Card" ]]; then
                        if grep -q "class.*ObservableObject\|@StateObject\|@EnvironmentObject" "$file" 2>/dev/null; then
                            log_violation "MODULAR" "$file" "StatefulComponent" "Components/Cards should be stateless views"
                            pattern_violations=$((pattern_violations + 1))
                            modular_violations_found=$((modular_violations_found + 1))
                        fi
                    fi
                    
                done < <(find "$dir" -name "*.swift" -type f)
            fi
        done
        
        if [ $pattern_files -gt 0 ]; then
            echo "  Checked $pattern_files $expected_type files"
            if [ $pattern_violations -eq 0 ]; then
                echo -e "  ${GREEN}✓ All $expected_type files comply with modular architecture${NC}"
            else
                echo -e "  ${RED}✗ Found $pattern_violations violations in $expected_type files${NC}"
            fi
        else
            echo -e "  ${YELLOW}⚠ No $expected_type directories found${NC}"
        fi
    done
    
    echo ""
    echo "Total modular files checked: $modular_files_checked"
    if [ $modular_violations_found -eq 0 ]; then
        echo -e "${GREEN}✓ All modular components follow architectural guidelines${NC}"
    else
        echo -e "${RED}✗ Found $modular_violations_found modular architecture violations${NC}"
    fi
}

validate_anti_patterns() {
    print_header "🚫 Anti-Pattern Detection"
    
    local anti_pattern_violations=0
    
    echo "Scanning for architectural anti-patterns..."
    
    # Check for monolithic patterns
    echo ""
    echo -e "${CYAN}Checking for monolithic anti-patterns...${NC}"
    
    while IFS= read -r file; do
        local lines=$(wc -l < "$file" | tr -d ' ')
        local rel_file="${file#$PROJECT_ROOT/}"
        
        # Files over 1000 lines are definitely monolithic
        if [ "$lines" -gt 1000 ]; then
            log_violation "CRITICAL" "$file" "MonolithicFile" "File is extremely large ($lines lines) - requires immediate modularization"
            anti_pattern_violations=$((anti_pattern_violations + 1))
        fi
        
        # Check for god objects (too many responsibilities)
        local struct_count=$(grep -c "^struct " "$file" 2>/dev/null || echo "0")
        local class_count=$(grep -c "^class " "$file" 2>/dev/null || echo "0")
        local protocol_count=$(grep -c "^protocol " "$file" 2>/dev/null || echo "0")
        local total_types=$((struct_count + class_count + protocol_count))
        
        if [ "$total_types" -gt 5 ]; then
            log_violation "WARNING" "$file" "GodObject" "File contains too many types ($total_types) - consider splitting"
            anti_pattern_violations=$((anti_pattern_violations + 1))
        fi
        
        # Check for circular dependencies (basic detection)
        local filename=$(basename "$file" .swift)
        if grep -q "import.*$filename" "$file" 2>/dev/null; then
            log_violation "CRITICAL" "$file" "SelfImport" "File appears to import itself"
            anti_pattern_violations=$((anti_pattern_violations + 1))
        fi
        
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -not -path "*/build/*" \
        -not -path "*/.build/*" \
        -not -path "*/DevTools/*" \
        -not -path "*/Archive/*")
    
    # Check for inappropriate cross-layer access
    echo ""
    echo -e "${CYAN}Checking for layer violations...${NC}"
    
    # Features should not directly import Infrastructure
    if grep -r "import Infrastructure" "$PROJECT_ROOT/Features" 2>/dev/null; then
        log_violation "CRITICAL" "Features" "DirectInfrastructureAccess" "Features layer should not directly import Infrastructure"
        anti_pattern_violations=$((anti_pattern_violations + 1))
    fi
    
    # UI should not import Services
    if grep -r "import.*Service" "$PROJECT_ROOT/UI" 2>/dev/null | grep -v "//"; then
        log_violation "CRITICAL" "UI" "ServiceDependency" "UI layer should not import Services"
        anti_pattern_violations=$((anti_pattern_violations + 1))
    fi
    
    # Foundation should not import anything non-system
    local foundation_violations=$(grep -r "import " "$PROJECT_ROOT/Foundation" 2>/dev/null | grep -v -E "(Swift|Foundation)" | wc -l | tr -d ' ')
    if [ "$foundation_violations" -gt 0 ]; then
        log_violation "CRITICAL" "Foundation" "ExternalDependencies" "Foundation layer has $foundation_violations non-system imports"
        anti_pattern_violations=$((anti_pattern_violations + 1))
    fi
    
    echo ""
    if [ $anti_pattern_violations -eq 0 ]; then
        echo -e "${GREEN}✓ No architectural anti-patterns detected${NC}"
    else
        echo -e "${RED}✗ Found $anti_pattern_violations anti-pattern violations${NC}"
    fi
}

generate_violations_report() {
    print_header "📋 Architecture Violations Report"
    
    # Create JSON report
    local violations_json=$(cat << EOF
{
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "summary": {
    "total_files_checked": $total_files,
    "critical_violations": ${#critical_violations[@]},
    "warnings": ${#warning_violations[@]},
    "tca_issues": ${#tca_issues[@]},
    "modular_violations": ${#modular_issues[@]},
    "overall_health": "$([ $violations -eq 0 ] && echo "HEALTHY" || echo "VIOLATIONS_FOUND")"
  },
  "violations": {
    "critical": [
EOF
    
    # Add critical violations
    for i in "${!critical_violations[@]}"; do
        if [ $i -gt 0 ]; then
            violations_json+=","
        fi
        violations_json+="\n      \"${critical_violations[$i]}\""
    done
    
    violations_json+="\n    ],\n    \"warnings\": ["
    
    # Add warnings (limit to first 10)
    for i in "${!warning_violations[@]}"; do
        if [ $i -ge 10 ]; then
            break
        fi
        if [ $i -gt 0 ]; then
            violations_json+=","
        fi
        violations_json+="\n      \"${warning_violations[$i]}\""
    done
    
    violations_json+="\n    ],\n    \"tca_issues\": ["
    
    # Add TCA issues
    for i in "${!tca_issues[@]}"; do
        if [ $i -gt 0 ]; then
            violations_json+=","
        fi
        violations_json+="\n      \"${tca_issues[$i]}\""
    done
    
    violations_json+="\n    ],\n    \"modular_issues\": ["
    
    # Add modular issues
    for i in "${!modular_issues[@]}"; do
        if [ $i -gt 0 ]; then
            violations_json+=","
        fi
        violations_json+="\n      \"${modular_issues[$i]}\""
    done
    
    violations_json+="\n    ]\n  }\n}"
    
    echo -e "$violations_json" > "$VIOLATIONS_FILE"
    
    # Display summary
    echo "Architecture Verification Summary:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Files checked: ${BLUE}$total_files${NC}"
    echo -e "Critical violations: ${RED}${#critical_violations[@]}${NC}"
    echo -e "Warnings: ${YELLOW}${#warning_violations[@]}${NC}"
    echo -e "TCA compliance issues: ${PURPLE}${#tca_issues[@]}${NC}"
    echo -e "Modular violations: ${CYAN}${#modular_issues[@]}${NC}"
    
    # Show critical violations
    if [ ${#critical_violations[@]} -gt 0 ]; then
        echo ""
        echo -e "${BOLD_RED}Critical Violations (must be fixed):${NC}"
        for violation in "${critical_violations[@]}"; do
            echo -e "  ${RED}•${NC} $violation"
        done
    fi
    
    # Show TCA issues
    if [ ${#tca_issues[@]} -gt 0 ]; then
        echo ""
        echo -e "${PURPLE}TCA Compliance Issues:${NC}"
        for issue in "${tca_issues[@]}"; do
            echo -e "  ${PURPLE}•${NC} $issue"
        done
    fi
    
    # Show modular issues (first 5)
    if [ ${#modular_issues[@]} -gt 0 ]; then
        echo ""
        echo -e "${CYAN}Modular Architecture Issues (showing first 5):${NC}"
        for i in "${!modular_issues[@]}"; do
            if [ $i -ge 5 ]; then
                echo -e "  ${CYAN}... and $((${#modular_issues[@]} - 5)) more${NC}"
                break
            fi
            echo -e "  ${CYAN}•${NC} ${modular_issues[$i]}"
        done
    fi
    
    echo ""
    echo -e "Detailed report saved to: ${BLUE}$VIOLATIONS_FILE${NC}"
    echo -e "Full log available at: ${BLUE}$ARCH_LOG${NC}"
}

# Main execution
main() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║             Enhanced Architecture Verification               ║${NC}"
    echo -e "${PURPLE}║           6-Layer TCA + Modular Components                   ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    # Clear previous logs
    > "$ARCH_LOG"
    
    cd "$PROJECT_ROOT"
    
    validate_layer_imports
    validate_tca_compliance
    validate_modular_architecture
    validate_anti_patterns
    generate_violations_report
    
    # Determine exit code
    local total_critical=$((violations + tca_compliance_issues + modular_violations))
    
    echo ""
    if [ $total_critical -eq 0 ]; then
        echo -e "${BOLD_GREEN}✅ Architecture verification passed - no critical issues${NC}"
        if [ $warnings -gt 0 ]; then
            echo -e "${YELLOW}Note: $warnings warnings found - consider addressing them${NC}"
        fi
        exit 0
    else
        echo -e "${BOLD_RED}❌ Architecture verification failed with $total_critical critical issues${NC}"
        echo -e "${YELLOW}Please fix critical violations before proceeding${NC}"
        exit 1
    fi
}

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Enhanced Architecture Verification for Nestory"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  --layers-only   Check only layer compliance"
    echo "  --tca-only      Check only TCA compliance"
    echo "  --modular-only  Check only modular component compliance"
    echo ""
    echo "This script enforces:"
    echo "  • 6-layer TCA architecture (Foundation→Infrastructure→Services→UI→Features→App-Main)"
    echo "  • TCA patterns in Features layer"
    echo "  • Modular component architecture"
    echo "  • Prevention of anti-patterns"
    echo ""
    exit 0
fi

# Handle specific validation modes
case "${1:-}" in
    "--layers-only")
        validate_layer_imports
        exit $?
        ;;
    "--tca-only")
        validate_tca_compliance
        exit $?
        ;;
    "--modular-only")
        validate_modular_architecture
        exit $?
        ;;
esac

# Run full verification
main "$@"