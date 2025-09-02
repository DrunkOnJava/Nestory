#!/bin/bash

# Configuration Validation System for Nestory
# Validates that project.yml includes all modularized source paths and maintains consistency
# Part of modularization automation suite

set -e

# Color codes for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_YML="${PROJECT_ROOT}/project.yml"
CONFIG_JSON="${PROJECT_ROOT}/Config/ProjectConfiguration.json"
MAKEFILE="${PROJECT_ROOT}/Makefile"
VALIDATION_LOG="${PROJECT_ROOT}/.validation.log"

# Counters for summary
total_checks=0
passed_checks=0
warnings=0
errors=0

# Arrays to store issues
declare -a warning_messages
declare -a error_messages
declare -a missing_paths
declare -a orphaned_paths

log_check() {
    local status=$1
    local message=$2
    total_checks=$((total_checks + 1))
    
    case $status in
        "PASS")
            passed_checks=$((passed_checks + 1))
            echo -e "  ${GREEN}✓${NC} $message"
            ;;
        "WARN")
            warnings=$((warnings + 1))
            warning_messages+=("$message")
            echo -e "  ${YELLOW}⚠${NC} $message"
            ;;
        "FAIL")
            errors=$((errors + 1))
            error_messages+=("$message")
            echo -e "  ${RED}✗${NC} $message"
            ;;
        "INFO")
            echo -e "  ${BLUE}ℹ${NC} $message"
            ;;
    esac
    
    # Log to file
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$status] $message" >> "$VALIDATION_LOG"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if required files exist
check_required_files() {
    print_header "📋 Required Files Check"
    
    if [ -f "$PROJECT_YML" ]; then
        log_check "PASS" "project.yml exists"
    else
        log_check "FAIL" "project.yml not found"
        return 1
    fi
    
    if [ -f "$CONFIG_JSON" ]; then
        log_check "PASS" "ProjectConfiguration.json exists"
    else
        log_check "FAIL" "ProjectConfiguration.json not found"
    fi
    
    if [ -f "$MAKEFILE" ]; then
        log_check "PASS" "Makefile exists"
    else
        log_check "FAIL" "Makefile not found"
    fi
    
    # Check JSON validity
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$CONFIG_JSON" >/dev/null 2>&1; then
            log_check "PASS" "ProjectConfiguration.json is valid JSON"
        else
            log_check "FAIL" "ProjectConfiguration.json contains invalid JSON"
        fi
    else
        log_check "WARN" "jq not available - skipping JSON validation"
    fi
}

# Validate that all source directories exist and are referenced in project.yml
validate_source_paths() {
    print_header "📁 Source Path Validation"
    
    # Extract source paths from project.yml using YAML->JSON parsing for accuracy
    local declared_paths=()
    
    if command -v yq >/dev/null 2>&1; then
        # Use yq to convert YAML to JSON, then parse with jq
        log_check "INFO" "Using yq/jq for accurate YAML parsing"
        while IFS= read -r path; do
            [ -n "$path" ] && declared_paths+=("$path")
        done < <(yq eval '.targets[].sources[].path' "$PROJECT_YML" 2>/dev/null | grep -v "null" || true)
        
        # Also check if sources are defined at root level
        while IFS= read -r path; do
            [ -n "$path" ] && declared_paths+=("$path")
        done < <(yq eval '.sources[].path' "$PROJECT_YML" 2>/dev/null | grep -v "null" || true)
    elif command -v python3 >/dev/null 2>&1; then
        # Fallback to Python YAML parsing
        log_check "INFO" "Using Python YAML parsing (yq not available)"
        python3 -c "
import yaml
import json
import sys
try:
    with open('$PROJECT_YML', 'r') as f:
        data = yaml.safe_load(f)
    paths = []
    if 'targets' in data:
        for target in data['targets'].values():
            if 'sources' in target:
                for source in target['sources']:
                    if isinstance(source, dict) and 'path' in source:
                        paths.append(source['path'])
                    elif isinstance(source, str):
                        paths.append(source)
    if 'sources' in data:
        for source in data['sources']:
            if isinstance(source, dict) and 'path' in source:
                paths.append(source['path'])
            elif isinstance(source, str):
                paths.append(source)
    for path in paths:
        print(path)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" | while IFS= read -r path; do
            [ -n "$path" ] && declared_paths+=("$path")
        done
    else
        # Fallback to regex-based parsing (original method)
        log_check "WARN" "Using regex parsing (yq and python3 not available)"
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path:[[:space:]]*(.+)$ ]]; then
                path="${BASH_REMATCH[1]}"
                # Remove quotes if present
                path=$(echo "$path" | sed 's/^["'\'']*//;s/["'\'']*$//')
                declared_paths+=("$path")
            fi
        done < <(awk '/sources:/,/^[[:space:]]*[a-zA-Z]/ {print}' "$PROJECT_YML" | head -n -1)
    fi
    
    log_check "INFO" "Found ${#declared_paths[@]} declared source paths"
    
    # Check that all declared paths exist
    for path in "${declared_paths[@]}"; do
        if [ -d "$PROJECT_ROOT/$path" ] || [ -f "$PROJECT_ROOT/$path" ]; then
            log_check "PASS" "Source path exists: $path"
        else
            log_check "FAIL" "Declared source path not found: $path"
            missing_paths+=("$path")
        fi
    done
    
    # Check for common modularized directories that might be missing from project.yml
    local expected_modular_dirs=(
        "App-Main/DamageAssessmentViews/RepairCostEstimation/Cards"
        "App-Main/DamageAssessmentViews/RepairCostEstimation/Components"
        "App-Main/DamageAssessmentViews/RepairCostEstimation/Sections"
        "App-Main/DamageAssessmentViews/PhotoComparison/Components"
        "App-Main/WarrantyViews/WarrantyTracking/Sheets"
        "Features/Search/Components"
        "Features/Settings/Components"
        "Services/WarrantyTrackingService"
        "Services/ClaimTracking"
    )
    
    for dir in "${expected_modular_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            # Check if this directory is declared in project.yml
            local found=false
            for declared_path in "${declared_paths[@]}"; do
                if [[ "$declared_path" == "$dir" ]]; then
                    found=true
                    break
                fi
            done
            
            if [ "$found" = true ]; then
                log_check "PASS" "Modular directory properly declared: $dir"
            else
                log_check "WARN" "Modular directory exists but not declared: $dir"
                orphaned_paths+=("$dir")
            fi
        fi
    done
}

# Validate Makefile consistency with project structure
validate_makefile_consistency() {
    print_header "🔧 Makefile Consistency Check"
    
    # Check if Makefile references the correct scheme names from config
    if command -v jq >/dev/null 2>&1; then
        local dev_scheme=$(jq -r '.derivedValues.schemes.development' "$CONFIG_JSON")
        local staging_scheme=$(jq -r '.derivedValues.schemes.staging' "$CONFIG_JSON")
        local prod_scheme=$(jq -r '.derivedValues.schemes.production' "$CONFIG_JSON")
        
        if grep -q "$dev_scheme" "$MAKEFILE"; then
            log_check "PASS" "Makefile references development scheme: $dev_scheme"
        else
            log_check "WARN" "Makefile missing development scheme reference: $dev_scheme"
        fi
        
        if grep -q "$staging_scheme" "$MAKEFILE"; then
            log_check "PASS" "Makefile references staging scheme: $staging_scheme"
        else
            log_check "WARN" "Makefile missing staging scheme reference: $staging_scheme"
        fi
        
        if grep -q "$prod_scheme" "$MAKEFILE"; then
            log_check "PASS" "Makefile references production scheme: $prod_scheme"
        else
            log_check "WARN" "Makefile missing production scheme reference: $prod_scheme"
        fi
        
        # Check simulator configuration
        local simulator_name=$(jq -r '.derivedValues.simulator.name' "$CONFIG_JSON")
        if grep -q "$simulator_name" "$MAKEFILE"; then
            log_check "PASS" "Makefile references correct simulator: $simulator_name"
        else
            log_check "WARN" "Makefile simulator mismatch. Expected: $simulator_name"
        fi
        
        # Check build timeouts
        local build_timeout=$(jq -r '.derivedValues.buildTimeouts.build' "$CONFIG_JSON")
        local test_timeout=$(jq -r '.derivedValues.buildTimeouts.test' "$CONFIG_JSON")
        
        if grep -q "BUILD_TIMEOUT.*$build_timeout" "$MAKEFILE" || grep -q "timeout $build_timeout" "$MAKEFILE"; then
            log_check "PASS" "Makefile uses correct build timeout: ${build_timeout}s"
        else
            log_check "WARN" "Makefile build timeout may not match config: ${build_timeout}s"
        fi
    else
        log_check "WARN" "jq not available - skipping detailed Makefile consistency checks"
    fi
    
    # Check for modularization-related targets
    local required_targets=(
        "verify-wiring"
        "verify-no-stock"
        "check-file-sizes"
        "verify-arch"
    )
    
    for target in "${required_targets[@]}"; do
        if grep -q "^$target:" "$MAKEFILE"; then
            log_check "PASS" "Makefile includes modularization target: $target"
        else
            log_check "FAIL" "Makefile missing required target: $target"
        fi
    done
}

# Check for architectural compliance in modular components
validate_modular_architecture() {
    print_header "🏗️ Modular Architecture Validation"
    
    # Check that modular components follow naming conventions
    local component_dirs=(
        "App-Main/*/Components"
        "App-Main/*/Sections"
        "App-Main/*/Cards"
        "Features/*/Components"
        "Services/*/Operations"
    )
    
    for pattern in "${component_dirs[@]}"; do
        for dir in $PROJECT_ROOT/$pattern; do
            if [ -d "$dir" ]; then
                local rel_dir="${dir#$PROJECT_ROOT/}"
                
                # Check if directory has Swift files
                if find "$dir" -name "*.swift" -type f | head -1 | read; then
                    log_check "PASS" "Modular component directory found: $rel_dir"
                    
                    # Check if files follow naming conventions
                    local invalid_files=0
                    while IFS= read -r file; do
                        local basename=$(basename "$file" .swift)
                        # Component files should end with appropriate suffixes
                        if [[ "$rel_dir" == *"/Components" ]]; then
                            if [[ ! "$basename" =~ (View|Component|Manager|Handler|Helper)$ ]]; then
                                log_check "WARN" "Component file doesn't follow naming convention: $file"
                                invalid_files=$((invalid_files + 1))
                            fi
                        elif [[ "$rel_dir" == *"/Sections" ]]; then
                            if [[ ! "$basename" =~ (Section|View|Card)$ ]]; then
                                log_check "WARN" "Section file doesn't follow naming convention: $file"
                                invalid_files=$((invalid_files + 1))
                            fi
                        fi
                    done < <(find "$dir" -name "*.swift" -type f)
                    
                    if [ $invalid_files -eq 0 ]; then
                        log_check "PASS" "All files in $rel_dir follow naming conventions"
                    fi
                else
                    log_check "WARN" "Empty modular directory: $rel_dir"
                fi
            fi
        done
    done
    
    # Check for Single Responsibility Principle violations
    local large_modular_files=0
    while IFS= read -r file; do
        if [[ "$file" == *"/Components/"* ]] || [[ "$file" == *"/Sections/"* ]] || [[ "$file" == *"/Cards/"* ]]; then
            local lines=$(wc -l < "$file" | tr -d ' ')
            if [ "$lines" -gt 200 ]; then
                log_check "WARN" "Large modular component ($lines lines): ${file#$PROJECT_ROOT/}"
                large_modular_files=$((large_modular_files + 1))
            fi
        fi
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -not -path "*/build/*" \
        -not -path "*/.build/*" \
        -not -path "*/DerivedData/*")
    
    if [ $large_modular_files -eq 0 ]; then
        log_check "PASS" "All modular components are appropriately sized"
    else
        log_check "WARN" "$large_modular_files modular components exceed 200 lines"
    fi
}

# Check for orphaned files and circular dependencies
validate_dependencies() {
    print_header "🔗 Dependency Validation"
    
    # Check for import cycles in modular components
    local potential_cycles=0
    
    # Check Components don't import from parent modules
    while IFS= read -r file; do
        if [[ "$file" == *"/Components/"* ]]; then
            local parent_module=$(dirname "$(dirname "$file")")
            local parent_name=$(basename "$parent_module")
            
            if grep -q "import.*$parent_name" "$file" 2>/dev/null; then
                log_check "WARN" "Component may have circular import: ${file#$PROJECT_ROOT/}"
                potential_cycles=$((potential_cycles + 1))
            fi
        fi
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -path "*/Components/*" \
        -not -path "*/build/*" \
        -not -path "*/.build/*")
    
    if [ $potential_cycles -eq 0 ]; then
        log_check "PASS" "No obvious circular imports detected in components"
    fi
    
    # Check for unused modular components
    local unused_components=0
    while IFS= read -r file; do
        local basename=$(basename "$file" .swift)
        
        # Search for usage of this component in other files
        if ! grep -r --include="*.swift" "$basename" "$PROJECT_ROOT" \
            --exclude="$(basename "$file")" \
            --exclude-dir=build \
            --exclude-dir=.build \
            --exclude-dir=DerivedData >/dev/null 2>&1; then
            
            log_check "WARN" "Potentially unused component: ${file#$PROJECT_ROOT/}"
            unused_components=$((unused_components + 1))
        fi
    done < <(find "$PROJECT_ROOT" -name "*.swift" -type f \
        -path "*/Components/*" \
        -not -path "*/build/*" \
        -not -path "*/.build/*")
    
    if [ $unused_components -eq 0 ]; then
        log_check "PASS" "All modular components appear to be used"
    fi
}

# Generate summary report
generate_summary() {
    print_header "📊 Validation Summary"
    
    echo -e "Total checks: ${BLUE}$total_checks${NC}"
    echo -e "Passed: ${GREEN}$passed_checks${NC}"
    echo -e "Warnings: ${YELLOW}$warnings${NC}"
    echo -e "Errors: ${RED}$errors${NC}"
    echo ""
    
    local success_rate=$((passed_checks * 100 / total_checks))
    if [ $success_rate -ge 90 ]; then
        echo -e "Success rate: ${GREEN}$success_rate%${NC} - Excellent!"
    elif [ $success_rate -ge 75 ]; then
        echo -e "Success rate: ${YELLOW}$success_rate%${NC} - Good"
    else
        echo -e "Success rate: ${RED}$success_rate%${NC} - Needs attention"
    fi
    
    if [ ${#missing_paths[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}Missing paths that need to be added to project.yml:${NC}"
        for path in "${missing_paths[@]}"; do
            echo "  - path: $path"
        done
    fi
    
    if [ ${#orphaned_paths[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Modular directories not declared in project.yml:${NC}"
        for path in "${orphaned_paths[@]}"; do
            echo "  - path: $path"
        done
        echo ""
        echo -e "${YELLOW}Consider adding these paths to project.yml sources section${NC}"
    fi
    
    if [ ${#error_messages[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}Critical errors that must be addressed:${NC}"
        for message in "${error_messages[@]}"; do
            echo "  • $message"
        done
    fi
    
    if [ ${#warning_messages[@]} -gt 0 ] && [ ${#warning_messages[@]} -le 5 ]; then
        echo ""
        echo -e "${YELLOW}Warnings (showing up to 5):${NC}"
        for i in "${!warning_messages[@]}"; do
            if [ $i -lt 5 ]; then
                echo "  • ${warning_messages[$i]}"
            fi
        done
        
        if [ ${#warning_messages[@]} -gt 5 ]; then
            echo "  ... and $((${#warning_messages[@]} - 5)) more warnings"
        fi
    fi
}

# Main execution
main() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                Configuration Validation System               ║${NC}"
    echo -e "${PURPLE}║                  Nestory Modularization Suite                ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    # Clear previous log
    > "$VALIDATION_LOG"
    
    cd "$PROJECT_ROOT"
    
    check_required_files || exit 1
    validate_source_paths
    validate_makefile_consistency
    validate_modular_architecture
    validate_dependencies
    
    echo ""
    generate_summary
    
    echo ""
    echo -e "${BLUE}Validation log saved to: $VALIDATION_LOG${NC}"
    
    # Exit with appropriate code
    if [ $errors -gt 0 ]; then
        echo ""
        echo -e "${RED}❌ Validation failed with $errors errors${NC}"
        exit 1
    elif [ $warnings -gt 10 ]; then
        echo ""
        echo -e "${YELLOW}⚠️ Validation completed with many warnings ($warnings)${NC}"
        exit 2
    else
        echo ""
        echo -e "${GREEN}✅ Configuration validation passed${NC}"
        exit 0
    fi
}

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Configuration Validation System for Nestory"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  --quiet       Suppress INFO messages"
    echo "  --verbose     Show detailed progress"
    echo ""
    echo "This script validates:"
    echo "  • project.yml source paths exist and are complete"
    echo "  • Makefile consistency with project configuration"
    echo "  • Modular architecture compliance"
    echo "  • Component dependencies and circular imports"
    echo ""
    exit 0
fi

# Run main function
main "$@"