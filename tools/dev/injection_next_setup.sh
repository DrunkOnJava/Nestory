#!/bin/bash
# Setup script for InjectionNext hot reload
# Much simpler than InjectionIII - just need to add package and launch Xcode from app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Project paths
PROJECT_ROOT="$(dirname $(dirname $(dirname "$0")))"

echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}     Nestory Hot Reload with InjectionNext Setup${NC}"
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "ok" ]; then
        echo -e "${GREEN}✅${NC} $message"
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}⚠️${NC}  $message"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}❌${NC} $message"
    else
        echo -e "${BLUE}ℹ️${NC}  $message"
    fi
}

echo -e "${BLUE}═══ Step 1: Environment Cleanup ═══${NC}"
echo ""

# Kill all related processes
print_status "info" "Closing Xcode and simulators..."
pkill -f "Xcode" 2>/dev/null || true
pkill -f "Simulator" 2>/dev/null || true
pkill -f "Nestory" 2>/dev/null || true

sleep 2
print_status "ok" "All processes terminated"

echo ""
echo -e "${BLUE}═══ Step 2: Check InjectionNext Installation ═══${NC}"
echo ""

if [ -d "/Applications/InjectionNext.app" ]; then
    print_status "ok" "InjectionNext.app found in /Applications"
else
    print_status "error" "InjectionNext.app not found in /Applications"
    print_status "info" "Please download from: https://github.com/johnno1962/InjectionNext/releases"
    print_status "info" "And move it to /Applications folder"
    exit 1
fi

echo ""
echo -e "${BLUE}═══ Step 3: Project Configuration ═══${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check project.yml has InjectionNext package
if grep -q "InjectionNext" project.yml; then
    print_status "ok" "InjectionNext package configured in project.yml"
else
    print_status "error" "InjectionNext package NOT configured"
    print_status "info" "Add to project.yml packages section:"
    echo "  InjectionNext:"
    echo "    url: https://github.com/johnno1962/InjectionNext"
    echo "    from: 1.0.0"
fi

# Check for Inject package (for SwiftUI refresh)
if grep -q "Inject" project.yml; then
    print_status "ok" "Inject package configured (for SwiftUI refresh)"
else
    print_status "warning" "Inject package not configured"
    print_status "info" "Recommended for SwiftUI hot reload"
fi

# Check -interposable flag
if grep -q "OTHER_LDFLAGS.*-interposable" project.yml; then
    print_status "ok" "-interposable linker flag configured"
else
    print_status "error" "-interposable flag NOT configured"
    print_status "info" "Add to project.yml target settings:"
    echo "  OTHER_LDFLAGS: -Xlinker -interposable"
fi

echo ""
echo -e "${BLUE}═══ Step 4: Clean and Regenerate Project ═══${NC}"
echo ""

print_status "info" "Cleaning build artifacts..."
rm -rf build/DerivedData 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-* 2>/dev/null || true
rm -rf Nestory.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved 2>/dev/null || true
print_status "ok" "Build artifacts cleaned"

print_status "info" "Regenerating Xcode project..."
xcodegen generate --spec project.yml
print_status "ok" "Xcode project regenerated"

echo ""
echo -e "${BLUE}═══ Step 5: Launch InjectionNext ═══${NC}"
echo ""

print_status "info" "Launching InjectionNext..."
open /Applications/InjectionNext.app

sleep 2

if pgrep -f "InjectionNext" > /dev/null; then
    print_status "ok" "InjectionNext is running"
else
    print_status "error" "Failed to launch InjectionNext"
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo ""
echo -e "${BLUE}1. In InjectionNext menu bar (icon should be blue):${NC}"
echo -e "   • Click 'Launch Xcode' to open Xcode supervised"
echo -e "   • The icon should turn ${PURPLE}PURPLE${NC}"
echo ""
echo -e "${BLUE}2. In Xcode:${NC}"
echo -e "   • Open the Nestory project"
echo -e "   • Build and run (⌘+R) on iPhone 16 Plus simulator"
echo -e "   • When app connects, icon turns ${YELLOW}ORANGE${NC}"
echo ""
echo -e "${BLUE}3. Test hot reload:${NC}"
echo -e "   • Edit App-Main/InventoryListView.swift"
echo -e "   • Change navigationTitle text"
echo -e "   • Save (⌘+S)"
echo -e "   • See instant update in simulator!"
echo ""
echo -e "${GREEN}Icon colors:${NC}"
echo -e "   🔵 Blue = InjectionNext running"
echo -e "   🟣 Purple = Xcode launched from app"
echo -e "   🟠 Orange = App connected"
echo -e "   🟢 Green = Recompiling"
echo -e "   🟡 Yellow = Compile error"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo -e "   • Always launch Xcode from InjectionNext menu"
echo -e "   • Don't launch Xcode directly"
echo -e "   • @ObserveInjection in views for SwiftUI refresh"
echo ""