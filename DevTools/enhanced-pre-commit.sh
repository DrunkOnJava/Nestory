#!/bin/bash

# Enhanced Pre-commit Hooks for Modularized Nestory
# Comprehensive validation system that prevents configuration drift and ensures modular compliance
# Part of modularization automation suite

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
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_LOG="${PROJECT_ROOT}/.pre-commit.log"
TEMP_DIR="${PROJECT_ROOT}/.pre-commit-temp"

# Counters for summary
total_checks=0
passed_checks=0
failed_checks=0
warnings=0

# Arrays for detailed reporting
declare -a failed_tests
declare -a warning_messages
declare -a staged_files

# Create temp directory
mkdir -p "$TEMP_DIR"

log_check() {
    local status=$1
    local test_name=$2
    local message=$3
    local duration=${4:-""}
    
    total_checks=$((total_checks + 1))
    
    local timestamp=$(date '+%H:%M:%S')
    local log_entry="[$timestamp] [$status] $test_name: $message"
    
    if [ -n "$duration" ]; then
        log_entry+=" (${duration}ms)"
    fi
    
    echo "$log_entry" >> "$HOOKS_LOG"
    
    case $status in
        "PASS")
            passed_checks=$((passed_checks + 1))
            echo -e "  ${GREEN}✓${NC} $test_name: $message"
            ;;
        "FAIL")
            failed_checks=$((failed_checks + 1))
            failed_tests+=("$test_name: $message")
            echo -e "  ${RED}✗${NC} $test_name: $message"
            ;;
        "WARN")
            warnings=$((warnings + 1))
            warning_messages+=("$test_name: $message")
            echo -e "  ${YELLOW}⚠${NC} $test_name: $message"
            ;;
        "INFO")
            echo -e "  ${BLUE}ℹ${NC} $test_name: $message"
            ;;
    esac
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

get_staged_files() {
    print_header "📋 Analyzing Staged Changes"
    
    # Get list of staged files
    while IFS= read -r file; do
        staged_files+=("$file")
    done < <(git diff --cached --name-only --diff-filter=ACM)
    
    echo "Staged files: ${#staged_files[@]}"
    
    # Categorize staged files
    local swift_files=0
    local config_files=0
    local critical_files=0
    
    for file in "${staged_files[@]}"; do
        echo "  • $file"
        
        case "$file" in
            *.swift) swift_files=$((swift_files + 1)) ;;
            project.yml|Makefile|Config/*) config_files=$((config_files + 1)) ;;
            SPEC.json|CLAUDE.md|DECISIONS.md) critical_files=$((critical_files + 1)) ;;
        esac
    done
    
    echo ""
    echo "File breakdown:"
    echo -e "  Swift files: ${BLUE}$swift_files${NC}"
    echo -e "  Config files: ${BLUE}$config_files${NC}"
    echo -e "  Critical files: ${BLUE}$critical_files${NC}"
    
    # Early exit if no relevant files
    if [ ${#staged_files[@]} -eq 0 ]; then
        log_check "INFO" "NoChanges" "No files staged for commit"
        echo -e "${GREEN}✅ No files to validate${NC}"
        exit 0
    fi
}

validate_file_sizes() {
    print_header "📏 File Size Validation"
    
    local start_time=$(date +%s%3N)
    local oversized_files=0
    local new_large_files=0
    
    for file in "${staged_files[@]}"; do
        if [[ "$file" == *.swift ]] && [ -f "$file" ]; then
            local lines=$(wc -l < "$file" | tr -d ' ')
            
            if [ "$lines" -gt 600 ]; then
                # Check if file is approved for override
                if [ -f ".file-size-override" ] && grep -q "^$file" ".file-size-override" 2>/dev/null; then
                    log_check "WARN" "FileSizeOverride" "$file has $lines lines (approved override)"
                else
                    log_check "FAIL" "FileSizeViolation" "$file exceeds 600 lines ($lines) - blocks commit"
                    oversized_files=$((oversized_files + 1))
                fi
            elif [ "$lines" -gt 400 ]; then
                # Check if this is a new large file
                if git show HEAD:"$file" >/dev/null 2>&1; then
                    local prev_lines=$(git show HEAD:"$file" | wc -l | tr -d ' ')
                    if [ "$lines" -gt "$prev_lines" ] && [ "$prev_lines" -le 400 ]; then
                        log_check "WARN" "FileSizeIncrease" "$file grew from $prev_lines to $lines lines"
                        new_large_files=$((new_large_files + 1))
                    fi
                else
                    log_check "WARN" "NewLargeFile" "New file $file has $lines lines"
                    new_large_files=$((new_large_files + 1))
                fi
            fi
        fi
    done
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [ $oversized_files -eq 0 ]; then
        log_check "PASS" "FileSizeCheck" "All files within size limits" "$duration"
    else
        log_check "FAIL" "FileSizeCheck" "$oversized_files files exceed 600-line limit" "$duration"
    fi
    
    if [ $new_large_files -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Consider modularizing these large files:${NC}"
        echo "  • Run: make file-report"
        echo "  • Or approve with: make approve-large-file FILE=path/to/file.swift"
    fi
}

validate_modular_structure() {
    print_header "🧩 Modular Structure Validation"
    
    local start_time=$(date +%s%3N)
    local modular_violations=0
    
    # Check if modular files follow proper structure
    for file in "${staged_files[@]}"; do
        if [[ "$file" == *.swift ]]; then
            # Check if file is in a modular directory
            if [[ "$file" == */Components/* ]] || [[ "$file" == */Sections/* ]] || [[ "$file" == */Cards/* ]]; then
                local basename=$(basename "$file" .swift)
                local dir_type=""
                
                if [[ "$file" == */Components/* ]]; then
                    dir_type="Component"
                    if [[ ! "$basename" =~ (View|Component|Manager|Handler|Helper|Coordinator)$ ]]; then
                        log_check "FAIL" "ModularNaming" "$file doesn't follow Component naming convention"
                        modular_violations=$((modular_violations + 1))
                    fi
                elif [[ "$file" == */Sections/* ]]; then
                    dir_type="Section"
                    if [[ ! "$basename" =~ (Section|View|Card)$ ]]; then
                        log_check "FAIL" "ModularNaming" "$file doesn't follow Section naming convention"
                        modular_violations=$((modular_violations + 1))
                    fi
                elif [[ "$file" == */Cards/* ]]; then
                    dir_type="Card"
                    if [[ ! "$basename" =~ (Card|View)$ ]]; then
                        log_check "FAIL" "ModularNaming" "$file doesn't follow Card naming convention"
                        modular_violations=$((modular_violations + 1))
                    fi
                fi
                
                # Check if modular file has appropriate content
                if [ -f "$file" ]; then
                    local lines=$(wc -l < "$file" | tr -d ' ')
                    local max_lines=200
                    
                    case "$dir_type" in
                        "Card") max_lines=100 ;;
                        "Section") max_lines=150 ;;
                        "Component") max_lines=200 ;;
                    esac
                    
                    if [ "$lines" -gt "$max_lines" ]; then
                        log_check "FAIL" "ModularSize" "$file ($dir_type) exceeds $max_lines lines ($lines)"
                        modular_violations=$((modular_violations + 1))
                    fi
                    
                    # Check for stateful components in stateless directories
                    if [[ "$dir_type" == "Component" ]] || [[ "$dir_type" == "Card" ]]; then
                        if grep -q "@StateObject\|@ObservedObject\|@EnvironmentObject" "$file" 2>/dev/null; then
                            log_check "WARN" "StatefulComponent" "$file should be stateless"
                        fi
                    fi
                fi
            fi
        fi
    done
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [ $modular_violations -eq 0 ]; then
        log_check "PASS" "ModularStructure" "All modular files follow conventions" "$duration"
    else
        log_check "FAIL" "ModularStructure" "$modular_violations modular violations found" "$duration"
    fi
}

validate_architecture_compliance() {
    print_header "🏗️ Architecture Compliance Check"
    
    local start_time=$(date +%s%3N)
    local arch_violations=0
    
    # Quick architecture check for staged Swift files
    for file in "${staged_files[@]}"; do
        if [[ "$file" == *.swift ]] && [ -f "$file" ]; then
            local layer=""
            
            # Determine layer
            if [[ "$file" == Foundation/* ]]; then
                layer="Foundation"
            elif [[ "$file" == Infrastructure/* ]]; then
                layer="Infrastructure"
            elif [[ "$file" == Services/* ]]; then
                layer="Services"
            elif [[ "$file" == UI/* ]]; then
                layer="UI"
            elif [[ "$file" == Features/* ]]; then
                layer="Features"
            elif [[ "$file" == App-Main/* ]]; then
                layer="App-Main"
            fi
            
            if [ -n "$layer" ]; then
                # Quick import validation
                case "$layer" in
                    "Foundation")
                        if grep -E "^import (Services|Infrastructure|UI|Features|App-Main)" "$file" >/dev/null 2>&1; then
                            log_check "FAIL" "ArchitectureViolation" "$file (Foundation) imports higher-layer modules"
                            arch_violations=$((arch_violations + 1))
                        fi
                        ;;
                    "Infrastructure")
                        if grep -E "^import (Services|UI|Features|App-Main)" "$file" >/dev/null 2>&1; then
                            log_check "FAIL" "ArchitectureViolation" "$file (Infrastructure) imports higher-layer modules"
                            arch_violations=$((arch_violations + 1))
                        fi
                        ;;
                    "UI")
                        if grep -E "^import (Services|Features|App-Main)" "$file" >/dev/null 2>&1; then
                            log_check "FAIL" "ArchitectureViolation" "$file (UI) imports business logic layers"
                            arch_violations=$((arch_violations + 1))
                        fi
                        ;;
                esac
            fi
        fi
    done
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [ $arch_violations -eq 0 ]; then
        log_check "PASS" "ArchitectureCheck" "No obvious architecture violations" "$duration"
    else
        log_check "FAIL" "ArchitectureCheck" "$arch_violations architecture violations found" "$duration"
    fi
}

validate_configuration_files() {
    print_header "⚙️ Configuration File Validation"
    
    local start_time=$(date +%s%3N)
    local config_issues=0
    
    # Check if critical config files are modified
    for file in "${staged_files[@]}"; do
        case "$file" in
            "project.yml")
                log_check "INFO" "ConfigChange" "project.yml modified - validating syntax"
                
                # Quick YAML syntax check
                if command -v python3 >/dev/null 2>&1; then
                    if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                        log_check "PASS" "YAMLSyntax" "project.yml syntax is valid"
                    else
                        log_check "FAIL" "YAMLSyntax" "project.yml has syntax errors"
                        config_issues=$((config_issues + 1))
                    fi
                fi
                
                # Check if all modular paths are included
                local missing_paths=0
                declare -a expected_paths=(
                    "App-Main/DamageAssessmentViews/RepairCostEstimation/Cards"
                    "App-Main/DamageAssessmentViews/RepairCostEstimation/Components"
                    "App-Main/DamageAssessmentViews/RepairCostEstimation/Sections"
                    "Features/Search/Components"
                    "Features/Settings/Components"
                )
                
                for expected_path in "${expected_paths[@]}"; do
                    if [ -d "$expected_path" ] && ! grep -q "path: $expected_path" "$file"; then
                        log_check "WARN" "MissingPath" "$expected_path directory exists but not in project.yml"
                        missing_paths=$((missing_paths + 1))
                    fi
                done
                
                if [ $missing_paths -eq 0 ]; then
                    log_check "PASS" "ProjectPaths" "All modular paths properly declared"
                else
                    log_check "WARN" "ProjectPaths" "$missing_paths modular paths may be missing"
                fi
                ;;
                
            "Config/ProjectConfiguration.json")
                log_check "INFO" "ConfigChange" "Master configuration modified - validating JSON"
                
                # JSON syntax check
                if command -v jq >/dev/null 2>&1; then
                    if jq empty "$file" >/dev/null 2>&1; then
                        log_check "PASS" "JSONSyntax" "ProjectConfiguration.json syntax is valid"
                    else
                        log_check "FAIL" "JSONSyntax" "ProjectConfiguration.json has syntax errors"
                        config_issues=$((config_issues + 1))
                    fi
                fi
                ;;
                
            "Makefile")
                log_check "INFO" "ConfigChange" "Makefile modified - checking targets"
                
                # Check for required targets
                local required_targets=("verify-wiring" "verify-no-stock" "check-file-sizes" "verify-arch")
                local missing_targets=0
                
                for target in "${required_targets[@]}"; do
                    if ! grep -q "^$target:" "$file"; then
                        log_check "WARN" "MissingTarget" "Makefile missing required target: $target"
                        missing_targets=$((missing_targets + 1))
                    fi
                done
                
                if [ $missing_targets -eq 0 ]; then
                    log_check "PASS" "MakefileTargets" "All required targets present"
                fi
                ;;
                
            "SPEC.json")
                log_check "WARN" "SpecChange" "SPEC.json modified - ensure DECISIONS.md is updated"
                
                # Check if DECISIONS.md is also staged
                local decisions_staged=false
                for staged_file in "${staged_files[@]}"; do
                    if [[ "$staged_file" == "DECISIONS.md" ]]; then
                        decisions_staged=true
                        break
                    fi
                done
                
                if [ "$decisions_staged" = false ]; then
                    log_check "FAIL" "SpecChange" "SPEC.json modified but DECISIONS.md not staged"
                    config_issues=$((config_issues + 1))
                fi
                ;;
        esac
    done
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [ $config_issues -eq 0 ]; then
        log_check "PASS" "ConfigValidation" "Configuration files validated" "$duration"
    else
        log_check "FAIL" "ConfigValidation" "$config_issues configuration issues found" "$duration"
    fi
}

run_code_quality_checks() {
    print_header "🔍 Code Quality Checks"
    
    local start_time=$(date +%s%3N)
    local quality_issues=0
    
    # Run SwiftLint if available
    if command -v swiftlint >/dev/null 2>&1; then
        echo "Running SwiftLint on staged files..."
        
        # Create temporary file list for SwiftLint
        local swift_files_list="$TEMP_DIR/swift_files.txt"
        for file in "${staged_files[@]}"; do
            if [[ "$file" == *.swift ]]; then
                echo "$file" >> "$swift_files_list"
            fi
        done
        
        if [ -s "$swift_files_list" ]; then
            if swiftlint lint --use-stdin --quiet < "$swift_files_list" 2>/dev/null; then
                log_check "PASS" "SwiftLint" "No linting violations found"
            else
                log_check "FAIL" "SwiftLint" "Linting violations found"
                quality_issues=$((quality_issues + 1))
            fi
        fi
    else
        log_check "WARN" "SwiftLint" "SwiftLint not available - skipping lint check"
    fi
    
    # Check for bare TODOs without ADR references
    local bare_todos=0
    for file in "${staged_files[@]}"; do
        if [[ "$file" == *.swift ]] || [[ "$file" == *.md ]]; then
            if [ -f "$file" ]; then
                while IFS= read -r line_num; do
                    local line_content=$(sed -n "${line_num}p" "$file")
                    if [[ "$line_content" =~ (TODO|FIXME) ]] && [[ ! "$line_content" =~ ADR-[0-9]+ ]]; then
                        log_check "FAIL" "BareReference" "$file:$line_num has TODO/FIXME without ADR reference"
                        bare_todos=$((bare_todos + 1))
                        quality_issues=$((quality_issues + 1))
                    fi
                done < <(grep -n -E "(TODO|FIXME)" "$file" 2>/dev/null | cut -d: -f1 || true)
            fi
        fi
    done
    
    if [ $bare_todos -eq 0 ]; then
        log_check "PASS" "ADRReferences" "All TODO/FIXME items reference ADRs"
    fi
    
    # Check for debugging statements
    local debug_statements=0
    for file in "${staged_files[@]}"; do
        if [[ "$file" == *.swift ]] && [ -f "$file" ]; then
            if grep -E "(print\(|NSLog\(|debugPrint\()" "$file" >/dev/null 2>&1; then
                log_check "WARN" "DebugStatements" "$file contains debug print statements"
                debug_statements=$((debug_statements + 1))
            fi
        fi
    done
    
    if [ $debug_statements -eq 0 ]; then
        log_check "PASS" "DebugStatements" "No debug print statements found"
    fi
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [ $quality_issues -eq 0 ]; then
        log_check "PASS" "CodeQuality" "All quality checks passed" "$duration"
    else
        log_check "FAIL" "CodeQuality" "$quality_issues quality issues found" "$duration"
    fi
}

run_build_validation() {
    print_header "🔨 Build Validation"
    
    local start_time=$(date +%s%3N)
    
    # Quick syntax check by attempting to parse staged Swift files
    local syntax_errors=0
    
    for file in "${staged_files[@]}"; do
        if [[ "$file" == *.swift ]] && [ -f "$file" ]; then
            # Basic syntax check using swift frontend
            if command -v swift >/dev/null 2>&1; then
                if ! swift -frontend -parse "$file" >/dev/null 2>&1; then
                    log_check "FAIL" "SyntaxError" "$file has syntax errors"
                    syntax_errors=$((syntax_errors + 1))
                fi
            fi
        fi
    done
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [ $syntax_errors -eq 0 ]; then
        log_check "PASS" "BuildValidation" "No syntax errors detected" "$duration"
    else
        log_check "FAIL" "BuildValidation" "$syntax_errors files have syntax errors" "$duration"
    fi
}

generate_summary() {
    print_header "📊 Pre-commit Summary"
    
    echo "Validation Results:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Total checks: ${BLUE}$total_checks${NC}"
    echo -e "Passed: ${GREEN}$passed_checks${NC}"
    echo -e "Failed: ${RED}$failed_checks${NC}"
    echo -e "Warnings: ${YELLOW}$warnings${NC}"
    
    local success_rate=0
    if [ $total_checks -gt 0 ]; then
        success_rate=$((passed_checks * 100 / total_checks))
    fi
    
    echo ""
    if [ $success_rate -ge 90 ]; then
        echo -e "Success rate: ${BOLD_GREEN}$success_rate%${NC} - Excellent!"
    elif [ $success_rate -ge 75 ]; then
        echo -e "Success rate: ${YELLOW}$success_rate%${NC} - Good"
    else
        echo -e "Success rate: ${RED}$success_rate%${NC} - Needs attention"
    fi
    
    # Show critical failures
    if [ ${#failed_tests[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}Critical failures that must be fixed:${NC}"
        for failure in "${failed_tests[@]}"; do
            echo -e "  ${RED}•${NC} $failure"
        done
        echo ""
        echo -e "${YELLOW}Fix these issues and try again, or use --no-verify to bypass (not recommended)${NC}"
    fi
    
    # Show warnings
    if [ ${#warning_messages[@]} -gt 0 ] && [ ${#warning_messages[@]} -le 3 ]; then
        echo ""
        echo -e "${YELLOW}Warnings (consider addressing):${NC}"
        for warning in "${warning_messages[@]}"; do
            echo -e "  ${YELLOW}•${NC} $warning"
        done
    elif [ ${#warning_messages[@]} -gt 3 ]; then
        echo ""
        echo -e "${YELLOW}${{#warning_messages[@]} warnings found (showing first 3):${NC}"
        for i in "${!warning_messages[@]}"; do
            if [ $i -lt 3 ]; then
                echo -e "  ${YELLOW}•${NC} ${warning_messages[$i]}"
            fi
        done
        echo -e "  ${YELLOW}... and $((${#warning_messages[@]} - 3)) more warnings${NC}"
    fi
    
    echo ""
    echo -e "Detailed log: ${BLUE}$HOOKS_LOG${NC}"
}

cleanup() {
    # Clean up temporary files
    rm -rf "$TEMP_DIR"
}

# Set up cleanup trap
trap cleanup EXIT

# Main execution
main() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                Enhanced Pre-commit Validation               ║${NC}"
    echo -e "${PURPLE}║              Modularization Protection Suite                ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    # Clear previous log
    > "$HOOKS_LOG"
    
    cd "$PROJECT_ROOT"
    
    get_staged_files
    validate_file_sizes
    validate_modular_structure
    validate_architecture_compliance
    validate_configuration_files
    run_code_quality_checks
    run_build_validation
    
    generate_summary
    
    # Determine exit code
    if [ $failed_checks -gt 0 ]; then
        echo ""
        echo -e "${BOLD_RED}❌ Pre-commit validation failed${NC}"
        echo -e "${YELLOW}Fix the issues above and try again${NC}"
        exit 1
    elif [ $warnings -gt 5 ]; then
        echo ""
        echo -e "${YELLOW}⚠️ Pre-commit completed with many warnings ($warnings)${NC}"
        echo -e "${YELLOW}Consider addressing warnings before committing${NC}"
        # Allow commit but with warning
        exit 0
    else
        echo ""
        echo -e "${BOLD_GREEN}✅ Pre-commit validation passed${NC}"
        if [ $warnings -gt 0 ]; then
            echo -e "${YELLOW}Note: $warnings warnings found${NC}"
        fi
        exit 0
    fi
}

# Show help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Enhanced Pre-commit Hooks for Nestory"
    echo ""
    echo "This script runs comprehensive validation on staged files:"
    echo ""
    echo "Validations performed:"
    echo "  • File size limits (prevents monolithic files)"
    echo "  • Modular structure compliance"
    echo "  • Architecture layer violations"
    echo "  • Configuration file syntax"
    echo "  • Code quality (SwiftLint, TODOs, debug statements)"
    echo "  • Basic build validation"
    echo ""
    echo "Integration:"
    echo "  This script is automatically installed as a git pre-commit hook"
    echo "  Run 'make install-hooks' to set up git integration"
    echo ""
    echo "Bypass (emergency only):"
    echo "  git commit --no-verify"
    echo ""
    exit 0
fi

# Run main function
main "$@"