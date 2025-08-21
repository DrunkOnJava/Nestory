#!/bin/bash

# Nestory Architecture Analysis Script
# Based on 6-layer architecture: App → Features → UI → Services → Infrastructure → Foundation

echo "🏗️  Nestory Architecture Analysis"
echo "================================="
echo "Architecture: App → Features → UI → Services → Infrastructure → Foundation"
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Count files by layer
echo "📊 Layer Distribution:"
echo "-------------------"
for layer in "App-Main" "Features" "UI" "Services" "Infrastructure" "Foundation"; do
    if [ -d "$layer" ]; then
        count=$(find "$layer" -name "*.swift" | wc -l | tr -d ' ')
        echo -e "${BLUE}$layer${NC}: $count Swift files"
    fi
done
echo

# Check for architecture violations
echo "🔍 Architecture Compliance Check:"
echo "--------------------------------"

violations=0

# Check UI → Services violations
echo "Checking UI → Services violations..."
ui_service_violations=$(find UI/ -name "*.swift" -exec grep -l "import.*Service" {} \; 2>/dev/null | wc -l | tr -d ' ')
if [ "$ui_service_violations" -gt 0 ]; then
    echo -e "${RED}❌ Found $ui_service_violations UI files importing Services${NC}"
    find UI/ -name "*.swift" -exec grep -l "import.*Service" {} \; 2>/dev/null | head -3
    violations=$((violations + ui_service_violations))
else
    echo -e "${GREEN}✅ No UI → Services violations${NC}"
fi

# Check Features → Infrastructure violations
echo "Checking Features → Infrastructure violations..."
features_infra_violations=$(find Features/ -name "*.swift" -exec grep -l "import.*Infrastructure\|import.*Network\|import.*Cache" {} \; 2>/dev/null | wc -l | tr -d ' ')
if [ "$features_infra_violations" -gt 0 ]; then
    echo -e "${RED}❌ Found $features_infra_violations Features files importing Infrastructure${NC}"
    find Features/ -name "*.swift" -exec grep -l "import.*Infrastructure\|import.*Network\|import.*Cache" {} \; 2>/dev/null | head -3
    violations=$((violations + features_infra_violations))
else
    echo -e "${GREEN}✅ No Features → Infrastructure violations${NC}"
fi

# Check for business inventory violations (should be insurance-focused)
echo "Checking for inappropriate inventory references..."
inventory_violations=$(find . -name "*.swift" -exec grep -l "stock\|inventory level\|low stock\|out of stock\|reorder" {} \; 2>/dev/null | grep -v analyze_architecture.sh | wc -l | tr -d ' ')
if [ "$inventory_violations" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $inventory_violations files with business inventory references${NC}"
    find . -name "*.swift" -exec grep -l "stock\|inventory level\|low stock\|out of stock\|reorder" {} \; 2>/dev/null | head -3
else
    echo -e "${GREEN}✅ No inappropriate inventory references found${NC}"
fi

echo

# TCA Analysis
echo "🧩 TCA (The Composable Architecture) Analysis:"
echo "--------------------------------------------"

reducers=$(find . -name "*.swift" -exec grep -l "@Reducer" {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "Reducers found: $reducers"

dependencies=$(find . -name "*.swift" -exec grep -l "@Dependency" {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "Dependencies found: $dependencies"

observable_states=$(find . -name "*.swift" -exec grep -l "@ObservableState" {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "ObservableState structs: $observable_states"

if [ -d "Features" ]; then
    echo
    echo "Feature modules:"
    find Features/ -name "*Feature.swift" 2>/dev/null | sed 's|Features/||g' | sed 's|/.*||g' | sort | uniq | while read feature; do
        echo "  • $feature"
    done
fi

echo

# Service wiring analysis
echo "🔌 Service Wiring Analysis:"
echo "-------------------------"
services=$(find Services/ -name "*.swift" -exec basename {} .swift \; 2>/dev/null | sort | uniq)
echo "Available services:"
for service in $services; do
    echo "  • $service"
done

echo
echo "Services used in views:"
view_service_usage=$(find . -name "*View.swift" -exec grep -l "@StateObject.*Service\|@ObservedObject.*Service\|@Dependency.*Service" {} \; 2>/dev/null | wc -l | tr -d ' ')
echo "Views using services: $view_service_usage"

echo

# Summary
echo "📋 Summary:"
echo "----------"
if [ "$violations" -eq 0 ]; then
    echo -e "${GREEN}✅ Architecture compliance: PASSED${NC}"
else
    echo -e "${RED}❌ Architecture compliance: FAILED ($violations violations)${NC}"
fi

echo -e "${BLUE}Total Swift files: $(find . -name "*.swift" | wc -l | tr -d ' ')${NC}"
echo -e "${BLUE}TCA Features: $reducers${NC}"
echo -e "${BLUE}Service dependencies: $dependencies${NC}"

echo
echo "💡 Next steps:"
echo "-------------"
echo "1. Fix any architecture violations shown above"
echo "2. Ensure all services are properly wired in views"
echo "3. Run 'make verify-arch' for detailed compliance check"
echo "4. Use 'make verify-wiring' to ensure UI accessibility"

echo
echo "🔧 Quick commands:"
echo "make run     # Build and run on iPhone 16 Pro Max"
echo "make check   # Run all verification checks"
echo "make test    # Run test suite"