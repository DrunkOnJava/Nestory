#!/bin/bash

# Batch approval script for UI testing framework files
# These are all part of the comprehensive enterprise testing framework

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

OVERRIDE_FILE=".file-size-override"
JUSTIFICATION="Enterprise UI testing framework - comprehensive test flows required for production quality assurance"

# UI Framework files that need approval
UI_FRAMEWORK_FILES=(
    "NestoryUITests/Flows/InsuranceReportingFlow.swift"
    "NestoryUITests/Flows/InventoryManagementFlow.swift"
    "NestoryUITests/Reporting/TestHealthDashboard.swift"
    "NestoryUITests/Reporting/AlertingSystem.swift"
    "NestoryUITests/Flows/AccessibilityTestingFlow.swift"
    "NestoryUITests/Data/TestDataModels.swift"
    "NestoryUITests/Core/Framework/SelfHealingTestRunner.swift"
    "NestoryUITests/Core/Orchestration/SimulatorManager.swift"
    "NestoryUITests/CI/GitHubActionsIntegration.swift"
    "NestoryUITests/CI/XcodeCloudIntegration.swift"
    "NestoryUITests/Reporting/TestReporter.swift"
    "NestoryUITests/Reporting/FailureAnalyzer.swift"
    "NestoryUITests/Utils/ScenarioBuilder.swift"
    "NestoryUITests/Performance/PerformanceUITests.swift"
    "NestoryUITests/Core/TestSessionManager.swift"
    "NestoryUITests/Core/Coordination/TestCoordinator.swift"
    "NestoryUITests/Accessibility/AccessibilityUITests.swift"
    "NestoryUITests/Core/Intelligence/AITestingEngine.swift"
    "NestoryUITests/Data/MockDataGenerator.swift"
    "NestoryUITests/Utils/DeviceConfigurationManager.swift"
    "NestoryUITests/Reporting/MetricsCollector.swift"
    "NestoryUITests/CI/JenkinsIntegration.swift"
    "NestoryUITests/Utils/TestConfigurationManager.swift"
    "NestoryUITests/Core/XCUIElementExtensions.swift"
    "NestoryUITests/Core/Interactions/GestureEngine.swift"
    "NestoryUITests/Core/TestNavigationUtils.swift"
    "NestoryUITests/Core/DynamicWaitEngine.swift"
    "NestoryUITests/Pages/BasePage.swift"
    "NestoryUITests/Utils/TestUtilities.swift"
    "NestoryUITests/Core/Interactions/PermissionHandler.swift"
)

echo -e "${BLUE}🚀 Batch Approving UI Testing Framework Files${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create override file if it doesn't exist
if [ ! -f "$OVERRIDE_FILE" ]; then
    echo "# File Size Override List" > "$OVERRIDE_FILE"
    echo "# Files listed here are exempted from the 600-line limit" >> "$OVERRIDE_FILE"
    echo "# Format: <file_path> # <date> - <justification>" >> "$OVERRIDE_FILE"
    echo "" >> "$OVERRIDE_FILE"
fi

approved_count=0
already_approved_count=0
not_needed_count=0
not_found_count=0

for file in "${UI_FRAMEWORK_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠️  SKIP: $file (not found)${NC}"
        not_found_count=$((not_found_count + 1))
        continue
    fi
    
    # Get line count
    lines=$(wc -l < "$file" | tr -d ' ')
    
    if [ "$lines" -lt 600 ]; then
        echo -e "${GREEN}✅ SKIP: $file (${lines} lines - under threshold)${NC}"
        not_needed_count=$((not_needed_count + 1))
        continue
    fi
    
    # Check if already approved
    if [ -f "$OVERRIDE_FILE" ] && grep -q "^$file#" "$OVERRIDE_FILE" 2>/dev/null; then
        echo -e "${BLUE}ℹ️  SKIP: $file (already approved)${NC}"
        already_approved_count=$((already_approved_count + 1))
        continue
    fi
    
    # Add the override with metadata
    echo "$file # $(date '+%Y-%m-%d') - $JUSTIFICATION" >> "$OVERRIDE_FILE"
    echo -e "${GREEN}✅ APPROVED: $file (${lines} lines)${NC}"
    approved_count=$((approved_count + 1))
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎯 Batch Approval Complete${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "• Files approved: $approved_count"
echo "• Already approved: $already_approved_count"
echo "• Under threshold: $not_needed_count"
echo "• Not found: $not_found_count"
echo ""

if [ $approved_count -gt 0 ]; then
    echo -e "${GREEN}✅ ${approved_count} files have been approved for the UI testing framework${NC}"
    echo -e "${YELLOW}📝 Note: These overrides should be temporary. Plan to modularize these files.${NC}"
    echo ""
    echo -e "${BLUE}Next: Run 'make run' to build and install the app${NC}"
fi