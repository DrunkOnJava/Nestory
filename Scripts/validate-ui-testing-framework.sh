#!/bin/bash

# UI Testing Framework Configuration Validator
# Validates and monitors the enterprise UI testing framework configuration
# for the Nestory iOS app

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Validation counters
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_PASSED=0

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}ℹ️  [INFO]${NC} ${message}" ;;
        "WARN")  echo -e "${YELLOW}⚠️  [WARN]${NC} ${message}"; ((VALIDATION_WARNINGS++)) ;;
        "ERROR") echo -e "${RED}❌ [ERROR]${NC} ${message}"; ((VALIDATION_ERRORS++)) ;;
        "SUCCESS") echo -e "${GREEN}✅ [SUCCESS]${NC} ${message}"; ((VALIDATION_PASSED++)) ;;
    esac
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

validate_project_configuration() {
    log "INFO" "Validating project configuration files..."
    
    # Check project.yml
    if [ -f "${PROJECT_ROOT}/project.yml" ]; then
        log "SUCCESS" "project.yml found"
        
        # Validate UI testing targets in project.yml
        if grep -q "NestoryUITests:" "${PROJECT_ROOT}/project.yml"; then
            log "SUCCESS" "NestoryUITests target found in project.yml"
        else
            log "ERROR" "NestoryUITests target missing from project.yml"
        fi
        
        if grep -q "NestoryPerformanceUITests:" "${PROJECT_ROOT}/project.yml"; then
            log "SUCCESS" "NestoryPerformanceUITests target found in project.yml"
        else
            log "WARN" "NestoryPerformanceUITests target missing from project.yml"
        fi
        
        if grep -q "NestoryAccessibilityUITests:" "${PROJECT_ROOT}/project.yml"; then
            log "SUCCESS" "NestoryAccessibilityUITests target found in project.yml"
        else
            log "WARN" "NestoryAccessibilityUITests target missing from project.yml"
        fi
        
        # Check for testing framework dependencies
        if grep -q "swift-snapshot-testing:" "${PROJECT_ROOT}/project.yml"; then
            log "SUCCESS" "swift-snapshot-testing dependency found"
        else
            log "ERROR" "swift-snapshot-testing dependency missing"
        fi
        
        if grep -q "swift-collections:" "${PROJECT_ROOT}/project.yml"; then
            log "SUCCESS" "swift-collections dependency found"
        else
            log "ERROR" "swift-collections dependency missing"
        fi
        
    else
        log "ERROR" "project.yml not found"
    fi
    
    # Check Makefile
    if [ -f "${PROJECT_ROOT}/Makefile" ]; then
        log "SUCCESS" "Makefile found"
        
        # Check for UI testing commands
        if grep -q "test-framework:" "${PROJECT_ROOT}/Makefile"; then
            log "SUCCESS" "test-framework command found in Makefile"
        else
            log "ERROR" "test-framework command missing from Makefile"
        fi
        
        if grep -q "test-performance:" "${PROJECT_ROOT}/Makefile"; then
            log "SUCCESS" "test-performance command found in Makefile"
        else
            log "ERROR" "test-performance command missing from Makefile"
        fi
        
        if grep -q "test-accessibility:" "${PROJECT_ROOT}/Makefile"; then
            log "SUCCESS" "test-accessibility command found in Makefile"
        else
            log "ERROR" "test-accessibility command missing from Makefile"
        fi
        
    else
        log "ERROR" "Makefile not found"
    fi
}

validate_xcconfig_files() {
    log "INFO" "Validating xcconfig files..."
    
    local config_files=(
        "Config/UITesting.xcconfig"
        "Config/PerformanceTesting.xcconfig" 
        "Config/AccessibilityTesting.xcconfig"
    )
    
    for config_file in "${config_files[@]}"; do
        local full_path="${PROJECT_ROOT}/${config_file}"
        if [ -f "$full_path" ]; then
            log "SUCCESS" "$config_file found"
            
            # Validate specific settings
            if grep -q "UI_TEST_FRAMEWORK_ENABLED = YES" "$full_path"; then
                log "SUCCESS" "UI_TEST_FRAMEWORK_ENABLED setting found in $config_file"
            else
                log "ERROR" "UI_TEST_FRAMEWORK_ENABLED setting missing from $config_file"
            fi
        else
            log "ERROR" "$config_file not found"
        fi
    done
    
    # Check Debug.xcconfig for UI testing support
    if [ -f "${PROJECT_ROOT}/Config/Debug.xcconfig" ]; then
        if grep -q "UI_TESTING_SUPPORT_ENABLED = YES" "${PROJECT_ROOT}/Config/Debug.xcconfig"; then
            log "SUCCESS" "UI testing support enabled in Debug.xcconfig"
        else
            log "ERROR" "UI testing support not enabled in Debug.xcconfig"
        fi
    else
        log "ERROR" "Config/Debug.xcconfig not found"
    fi
}

validate_entitlements() {
    log "INFO" "Validating entitlements..."
    
    # Check main app entitlements
    if [ -f "${PROJECT_ROOT}/App-Main/Nestory.entitlements" ]; then
        log "SUCCESS" "Main app entitlements found"
        
        if grep -q "com.apple.developer.testing.accessibility" "${PROJECT_ROOT}/App-Main/Nestory.entitlements"; then
            log "SUCCESS" "Accessibility testing entitlement found"
        else
            log "ERROR" "Accessibility testing entitlement missing from main app"
        fi
        
        if grep -q "com.apple.developer.testing.automation" "${PROJECT_ROOT}/App-Main/Nestory.entitlements"; then
            log "SUCCESS" "Automation testing entitlement found"
        else
            log "ERROR" "Automation testing entitlement missing from main app"
        fi
    else
        log "ERROR" "App-Main/Nestory.entitlements not found"
    fi
    
    # Check UI test entitlements
    if [ -f "${PROJECT_ROOT}/NestoryUITests/NestoryUITests.entitlements" ]; then
        log "SUCCESS" "UI test entitlements found"
    else
        log "ERROR" "NestoryUITests/NestoryUITests.entitlements not found"
    fi
}

validate_info_plist() {
    log "INFO" "Validating Info.plist configuration..."
    
    if [ -f "${PROJECT_ROOT}/App-Main/Info.plist" ]; then
        log "SUCCESS" "Info.plist found"
        
        # Check for UI testing configuration
        if grep -q "UITestingEnabled" "${PROJECT_ROOT}/App-Main/Info.plist"; then
            log "SUCCESS" "UITestingEnabled found in Info.plist"
        else
            log "ERROR" "UITestingEnabled missing from Info.plist"
        fi
        
        if grep -q "UIAccessibilityIdentifiersEnabled" "${PROJECT_ROOT}/App-Main/Info.plist"; then
            log "SUCCESS" "UIAccessibilityIdentifiersEnabled found in Info.plist"
        else
            log "ERROR" "UIAccessibilityIdentifiersEnabled missing from Info.plist"
        fi
        
        # Check privacy descriptions for testing
        if grep -q "NSCameraUsageDescription" "${PROJECT_ROOT}/App-Main/Info.plist"; then
            log "SUCCESS" "Camera usage description found"
        else
            log "ERROR" "Camera usage description missing"
        fi
        
        if grep -q "NSPhotoLibraryUsageDescription" "${PROJECT_ROOT}/App-Main/Info.plist"; then
            log "SUCCESS" "Photo library usage description found"
        else
            log "ERROR" "Photo library usage description missing"
        fi
        
    else
        log "ERROR" "App-Main/Info.plist not found"
    fi
}

validate_test_schemes() {
    log "INFO" "Validating test schemes..."
    
    local schemes_dir="${PROJECT_ROOT}/Nestory.xcodeproj/xcshareddata/xcschemes"
    
    if [ ! -d "$schemes_dir" ]; then
        log "ERROR" "Schemes directory not found: $schemes_dir"
        return
    fi
    
    local test_schemes=(
        "Nestory-UIWiring.xcscheme"
        "Nestory-Performance.xcscheme"
        "Nestory-Accessibility.xcscheme"
        "Nestory-Smoke.xcscheme"
    )
    
    for scheme in "${test_schemes[@]}"; do
        local scheme_path="${schemes_dir}/${scheme}"
        if [ -f "$scheme_path" ]; then
            log "SUCCESS" "$scheme found"
            
            # Validate scheme contains test configuration
            if grep -q "TestAction" "$scheme_path"; then
                log "SUCCESS" "$scheme contains TestAction configuration"
            else
                log "ERROR" "$scheme missing TestAction configuration"
            fi
        else
            log "ERROR" "$scheme not found"
        fi
    done
}

validate_ui_testing_framework_structure() {
    log "INFO" "Validating UI testing framework structure..."
    
    local required_directories=(
        "NestoryUITests"
        "NestoryUITests/Core"
        "NestoryUITests/Core/Framework"
        "NestoryUITests/PageObjects"
        "NestoryUITests/Flows"
        "NestoryUITests/Helpers"
        "NestoryUITests/Extensions"
    )
    
    for dir in "${required_directories[@]}"; do
        local full_path="${PROJECT_ROOT}/${dir}"
        if [ -d "$full_path" ]; then
            log "SUCCESS" "$dir directory found"
        else
            log "ERROR" "$dir directory missing"
        fi
    done
    
    local required_files=(
        "NestoryUITests/Core/Framework/NestoryUITestFramework.swift"
        "NestoryUITests/PageObjects/BasePage.swift"
        "NestoryUITests/Extensions/XCTestCase+Helpers.swift"
        "NestoryUITests/Extensions/XCUIElement+Helpers.swift"
    )
    
    for file in "${required_files[@]}"; do
        local full_path="${PROJECT_ROOT}/${file}"
        if [ -f "$full_path" ]; then
            log "SUCCESS" "$file found"
        else
            log "ERROR" "$file missing"
        fi
    done
}

validate_fastlane_configuration() {
    log "INFO" "Validating Fastlane configuration..."
    
    if [ -f "${PROJECT_ROOT}/fastlane/Fastfile" ]; then
        log "SUCCESS" "Fastfile found"
        
        # Check for UI testing lanes
        if grep -q "lane :ui_tests" "${PROJECT_ROOT}/fastlane/Fastfile"; then
            log "SUCCESS" "ui_tests lane found in Fastfile"
        else
            log "ERROR" "ui_tests lane missing from Fastfile"
        fi
        
        if grep -q "lane :performance_tests" "${PROJECT_ROOT}/fastlane/Fastfile"; then
            log "SUCCESS" "performance_tests lane found in Fastfile"
        else
            log "ERROR" "performance_tests lane missing from Fastfile"
        fi
        
        if grep -q "lane :accessibility_tests" "${PROJECT_ROOT}/fastlane/Fastfile"; then
            log "SUCCESS" "accessibility_tests lane found in Fastfile"
        else
            log "ERROR" "accessibility_tests lane missing from Fastfile"
        fi
        
        if grep -q "lane :enterprise_test_suite" "${PROJECT_ROOT}/fastlane/Fastfile"; then
            log "SUCCESS" "enterprise_test_suite lane found in Fastfile"
        else
            log "ERROR" "enterprise_test_suite lane missing from Fastfile"
        fi
        
    else
        log "ERROR" "fastlane/Fastfile not found"
    fi
}

validate_ci_scripts() {
    log "INFO" "Validating CI/CD scripts..."
    
    local ci_scripts=(
        "Scripts/CI/enterprise-ui-testing.sh"
        "Scripts/extract-ui-test-screenshots.sh"
    )
    
    for script in "${ci_scripts[@]}"; do
        local full_path="${PROJECT_ROOT}/${script}"
        if [ -f "$full_path" ]; then
            log "SUCCESS" "$script found"
            
            if [ -x "$full_path" ]; then
                log "SUCCESS" "$script is executable"
            else
                log "WARN" "$script is not executable"
            fi
        else
            log "ERROR" "$script missing"
        fi
    done
}

validate_dependencies() {
    log "INFO" "Validating system dependencies..."
    
    local required_tools=(
        "xcodebuild"
        "xcrun"
        "xcodegen"
    )
    
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log "SUCCESS" "$tool is available"
        else
            log "ERROR" "$tool is not available"
        fi
    done
    
    # Check for iPhone 16 Pro Max simulator
    if xcrun simctl list devices 2>/dev/null | grep -q "iPhone 16 Pro Max"; then
        log "SUCCESS" "iPhone 16 Pro Max simulator available"
    else
        log "ERROR" "iPhone 16 Pro Max simulator not available"
    fi
}

# ============================================================================
# MAIN VALIDATION FUNCTION
# ============================================================================

main() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Nestory Enterprise UI Testing Framework Validation${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Change to project root
    cd "${PROJECT_ROOT}"
    
    # Run all validations
    validate_dependencies
    echo ""
    validate_project_configuration
    echo ""
    validate_xcconfig_files
    echo ""
    validate_entitlements
    echo ""
    validate_info_plist
    echo ""
    validate_test_schemes
    echo ""
    validate_ui_testing_framework_structure
    echo ""
    validate_fastlane_configuration
    echo ""
    validate_ci_scripts
    echo ""
    
    # Print summary
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                        Validation Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}✅ Passed:${NC} $VALIDATION_PASSED"
    echo -e "${YELLOW}⚠️  Warnings:${NC} $VALIDATION_WARNINGS"  
    echo -e "${RED}❌ Errors:${NC} $VALIDATION_ERRORS"
    echo ""
    
    if [ $VALIDATION_ERRORS -eq 0 ]; then
        if [ $VALIDATION_WARNINGS -eq 0 ]; then
            echo -e "${GREEN}🎉 All validations passed! Enterprise UI Testing Framework is ready.${NC}"
            exit 0
        else
            echo -e "${YELLOW}⚠️  Validation completed with warnings. Framework should work but may have issues.${NC}"
            exit 0
        fi
    else
        echo -e "${RED}💥 Validation failed with $VALIDATION_ERRORS error(s). Please fix these issues before using the framework.${NC}"
        echo ""
        echo "Common fixes:"
        echo "  1. Run 'make generate-config' to regenerate configuration files"
        echo "  2. Run 'xcodegen generate' to regenerate project files"
        echo "  3. Ensure all required UI testing framework files are present"
        echo "  4. Check that all schemes are properly configured"
        exit 1
    fi
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi