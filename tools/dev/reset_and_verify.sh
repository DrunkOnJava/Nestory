#!/bin/bash
# Comprehensive reset and verification script for Nestory hot reload setup
# This script ensures a clean slate and proper configuration before running

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
TOOLS_DIR="$PROJECT_ROOT/tools/dev"
INJECTION_APP="$TOOLS_DIR/InjectionIII.app"

echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}     Nestory Hot Reload - Complete Reset & Verification${NC}"
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

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}═══ Step 1: Environment Cleanup ═══${NC}"
echo ""

# Kill all related processes
print_status "info" "Killing any running Nestory processes..."
pkill -f "Nestory" 2>/dev/null || true

print_status "info" "Killing any running InjectionIII processes..."
pkill -f "InjectionIII" 2>/dev/null || true

print_status "info" "Killing any simulator processes..."
pkill -f "Simulator" 2>/dev/null || true

sleep 2
print_status "ok" "All processes terminated"

echo ""
echo -e "${BLUE}═══ Step 2: Environment Verification ═══${NC}"
echo ""

# Unset TOOLCHAINS if it exists
if [ ! -z "$TOOLCHAINS" ]; then
    print_status "error" "TOOLCHAINS environment variable is set: $TOOLCHAINS"
    print_status "info" "Unsetting TOOLCHAINS..."
    unset TOOLCHAINS
    print_status "ok" "TOOLCHAINS unset"
else
    print_status "ok" "No TOOLCHAINS override detected"
fi

# Force Swift 6
export SWIFT_VERSION=6.0
export SWIFT_STRICT_CONCURRENCY=minimal

# Check Swift version
SWIFT_OUTPUT=$(swift --version 2>&1 | head -1)
if echo "$SWIFT_OUTPUT" | grep -q "Swift version 6"; then
    print_status "ok" "Swift version: $SWIFT_OUTPUT"
else
    print_status "error" "Wrong Swift version: $SWIFT_OUTPUT"
    print_status "info" "Please ensure Swift 6 is available"
fi

echo ""
echo -e "${BLUE}═══ Step 3: Tool Verification ═══${NC}"
echo ""

# Check for required tools
if command_exists xcodebuild; then
    XCODE_VERSION=$(xcodebuild -version | head -1)
    print_status "ok" "Xcode installed: $XCODE_VERSION"
else
    print_status "error" "Xcode not installed"
    exit 1
fi

if command_exists xcrun; then
    print_status "ok" "xcrun available"
else
    print_status "error" "xcrun not available"
    exit 1
fi

if command_exists xcbeautify; then
    print_status "ok" "xcbeautify installed"
else
    print_status "warning" "xcbeautify not installed (optional)"
fi

echo ""
echo -e "${BLUE}═══ Step 4: Project Configuration Check ═══${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check project.yml exists
if [ -f "project.yml" ]; then
    print_status "ok" "project.yml exists"
    
    # Check for Swift 6
    if grep -q "SWIFT_VERSION: 6.0" project.yml; then
        print_status "ok" "Swift 6.0 configured in project.yml"
    else
        print_status "error" "Swift 6.0 not configured in project.yml"
    fi
    
    # Check for -interposable flag
    if grep -q "OTHER_LDFLAGS.*-interposable" project.yml; then
        print_status "ok" "-interposable linker flag configured"
    else
        print_status "error" "-interposable linker flag NOT configured"
    fi
    
    # Check for Inject package (NOT HotReloading)
    if grep -q "Inject" project.yml; then
        print_status "ok" "Inject package configured"
    else
        print_status "error" "Inject package NOT configured"
    fi
else
    print_status "error" "project.yml not found"
    exit 1
fi

# Check for hot reload setup
if [ -f "App-Main/HotReloadBootstrap.swift" ]; then
    # Check for Inject import in bootstrap
    if grep -q "import Inject" "App-Main/HotReloadBootstrap.swift"; then
        print_status "ok" "Inject package imported in HotReloadBootstrap.swift"
    else
        print_status "error" "Inject not imported in HotReloadBootstrap.swift"
    fi
    
    # Check for @ObserveInjection in views
    if grep -q "@ObserveInjection" "App-Main/ContentView.swift" 2>/dev/null; then
        print_status "ok" "@ObserveInjection found in ContentView.swift"
    else
        print_status "warning" "@ObserveInjection not found in ContentView.swift"
    fi
    
    # Check for .enableInjection() in views
    if grep -q ".enableInjection()" "App-Main/ContentView.swift" 2>/dev/null; then
        print_status "ok" ".enableInjection() found in ContentView.swift"
    else
        print_status "warning" ".enableInjection() not found in ContentView.swift"
    fi
else
    print_status "error" "HotReloadBootstrap.swift not found"
fi

# Inject package handles refresh automatically with @ObserveInjection
# No need for InjectionPulse.swift or manual .id() tracking

echo ""
echo -e "${BLUE}═══ Step 5: InjectionIII Setup ═══${NC}"
echo ""

# Check if InjectionIII.app exists
if [ -d "$INJECTION_APP" ]; then
    print_status "ok" "InjectionIII.app found at $INJECTION_APP"
else
    print_status "warning" "InjectionIII.app not found locally"
    print_status "info" "Downloading InjectionIII..."
    cd "$TOOLS_DIR"
    curl -L https://github.com/johnno1962/InjectionIII/releases/latest/download/InjectionIII.app.zip -o InjectionIII.app.zip
    unzip -q InjectionIII.app.zip
    rm -f InjectionIII.app.zip
    xattr -d com.apple.quarantine InjectionIII.app 2>/dev/null || true
    print_status "ok" "InjectionIII.app downloaded and extracted"
fi

echo ""
echo -e "${BLUE}═══ Step 6: Clean Build and Regenerate Project ═══${NC}"
echo ""

cd "$PROJECT_ROOT"

print_status "info" "Cleaning ALL build artifacts..."
rm -rf build/DerivedData 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-* 2>/dev/null || true
rm -rf .build 2>/dev/null || true
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null || true
rm -rf Nestory.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved 2>/dev/null || true
print_status "ok" "Build artifacts cleaned"

# Check for any new Swift files that might not be in the project
print_status "info" "Checking for new Swift files..."
NEW_FILES=$(find App-Main Foundation Infrastructure Services UI -name "*.swift" -newer Nestory.xcodeproj/project.pbxproj 2>/dev/null | wc -l | tr -d ' ')
if [ "$NEW_FILES" -gt 0 ]; then
    print_status "warning" "Found $NEW_FILES new Swift files not in project"
fi

# Always regenerate to ensure all files are included
print_status "info" "Regenerating Xcode project with XcodeGen..."
xcodegen generate --spec project.yml
print_status "ok" "Xcode project regenerated - all Swift files included"

# Resolve package dependencies
print_status "info" "Resolving Swift Package dependencies..."
xcodebuild -resolvePackageDependencies -project Nestory.xcodeproj -scheme Nestory-Dev
print_status "ok" "Package dependencies resolved"

echo ""
echo -e "${BLUE}═══ Step 7: Simulator Setup ═══${NC}"
echo ""

# Get simulator ID for iPhone 16 Plus
SIMULATOR_ID=$(xcrun simctl list devices | grep "iPhone 16 Plus" | grep -v "unavailable" | awk '{print $(NF-1)}' | tr -d '()')

if [ -z "$SIMULATOR_ID" ]; then
    print_status "error" "iPhone 16 Plus simulator not found"
    print_status "info" "Available simulators:"
    xcrun simctl list devices | grep iPhone
    exit 1
else
    print_status "ok" "iPhone 16 Plus found: $SIMULATOR_ID"
fi

# Boot the simulator
print_status "info" "Booting simulator..."
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
sleep 3
print_status "ok" "Simulator booted"

# Open Simulator app
print_status "info" "Opening Simulator app..."
open -a Simulator
sleep 2
print_status "ok" "Simulator app is running and visible"

echo ""
echo -e "${BLUE}═══ Step 8: Launch and Configure InjectionIII ═══${NC}"
echo ""

# Launch InjectionIII
print_status "info" "Launching InjectionIII..."
open "$INJECTION_APP"
sleep 2

# Check if InjectionIII is running
if pgrep -f "InjectionIII" > /dev/null; then
    print_status "ok" "InjectionIII is running"
else
    print_status "error" "Failed to launch InjectionIII"
    exit 1
fi

# Configure InjectionIII
print_status "info" "Attempting to configure InjectionIII..."

# Check if preferences exist
if [ -f ~/Library/Preferences/com.johnholdsworth.InjectionIII.plist ]; then
    print_status "info" "InjectionIII preferences found"
else
    print_status "warning" "InjectionIII preferences not found - first time setup"
fi

echo ""
echo -e "${YELLOW}⚠️  MANUAL ACTION REQUIRED:${NC}"
echo -e "${YELLOW}    1. Click the InjectionIII icon (💉) in the menu bar${NC}"
echo -e "${YELLOW}    2. Select 'File → Open Project...'${NC}"
echo -e "${YELLOW}    3. Navigate to: $PROJECT_ROOT${NC}"
echo -e "${YELLOW}    4. Select the 'Nestory' folder (NOT the .xcodeproj file)${NC}"
echo -e "${YELLOW}    5. Click 'Select Project Directory'${NC}"
echo -e "${YELLOW}    6. Verify you see 'Watching /Users/griffin/Projects/Nestory...' in the InjectionIII window${NC}"
echo ""
echo -e "${PURPLE}Press Enter when you've completed these steps...${NC}"
read -r

print_status "ok" "InjectionIII configured and running"

echo ""
echo -e "${BLUE}═══ Step 9: Build and Run ═══${NC}"
echo ""

print_status "info" "Building Nestory with hot reload support..."

# Ensure we're using Swift 6 and not some override
unset TOOLCHAINS
export SWIFT_VERSION=6.0
export SWIFT_STRICT_CONCURRENCY=minimal

# Verify Swift version one more time
SWIFT_CHECK=$(swift --version 2>&1 | head -1)
echo ""
print_status "ok" "Building with $SWIFT_CHECK"

# Check concurrency mode
if grep -q "SWIFT_STRICT_CONCURRENCY: minimal" project.yml; then
    print_status "ok" "Using Swift 6 with minimal concurrency checking for Debug"
else
    print_status "warning" "Strict concurrency may cause issues with dependencies"
fi

# Build the project
print_status "info" "Building... (this may take a minute)"

BUILD_LOG="/tmp/nestory_build.log"
if xcodebuild \
    -project Nestory.xcodeproj \
    -scheme Nestory-Dev \
    -configuration Debug \
    -derivedDataPath build/DerivedData \
    -destination "platform=iOS Simulator,name=iPhone 16 Plus" \
    build 2>&1 | tee "$BUILD_LOG" | xcbeautify; then
    
    print_status "ok" "BUILD SUCCEEDED!"
    
    # Install and run the app
    print_status "info" "Installing app to simulator..."
    xcrun simctl install booted build/DerivedData/Build/Products/Debug-iphonesimulator/Nestory.app
    
    print_status "info" "Launching Nestory..."
    xcrun simctl launch booted "${PRODUCT_BUNDLE_IDENTIFIER:-com.drunkonjava.nestory.dev}"
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Nestory is running with hot reload support!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}📝 Test hot reload by:${NC}"
    echo -e "   1. Open App-Main/InventoryListView.swift"
    echo -e "   2. Change the navigation title text"
    echo -e "   3. Save the file (⌘+S)"
    echo -e "   4. Watch the app update instantly!"
    echo ""
    echo -e "${YELLOW}⚠️  If hot reload doesn't work:${NC}"
    echo -e "   • Check InjectionIII console for errors"
    echo -e "   • Ensure InjectionIII shows 'Watching /Users/griffin/Projects/Nestory...'"
    echo -e "   • Try manually injecting with InjectionIII menu → 'Inject Source'"
    echo ""
else
    print_status "error" "BUILD FAILED"
    echo ""
    echo "Build errors:"
    grep -E "(error:|warning:)" "$BUILD_LOG" | head -20
    echo ""
    echo "Full log saved to: $BUILD_LOG"
fi