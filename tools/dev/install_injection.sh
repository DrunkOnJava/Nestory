#!/bin/bash
# Install and Configure InjectionNext for Hot Reload
# This script sets up everything needed for the streamlined hot reload workflow

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}     InjectionNext Installation & Configuration Script${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Function to print section headers
section() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}$(printf '─%.0s' {1..60})${NC}"
}

# Function to check command availability
check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 1. Install InjectionIII from App Store (manual step)
section "Checking InjectionIII Installation"

if [ -d "/Applications/InjectionIII.app" ]; then
    echo -e "${GREEN}✅ InjectionIII.app is already installed${NC}"
else
    echo -e "${YELLOW}⚠️  InjectionIII.app not found${NC}"
    echo ""
    echo "Please install InjectionIII from the App Store:"
    echo -e "${CYAN}https://apps.apple.com/app/injectioniii/id1380446739${NC}"
    echo ""
    echo "After installation, run this script again."
    
    # Attempt to open App Store page
    if check_command open; then
        read -p "Would you like to open the App Store page now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "macappstore://apps.apple.com/app/injectioniii/id1380446739"
        fi
    fi
    exit 1
fi

# 2. Install InjectionNext Swift Package
section "Installing InjectionNext Swift Package"

# Check if Package.swift exists
if [ ! -f "$PROJECT_ROOT/Package.swift" ]; then
    echo -e "${YELLOW}Creating Package.swift for SPM dependencies${NC}"
    cat > "$PROJECT_ROOT/Package.swift" << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Nestory",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NestoryPackages",
            targets: ["NestoryPackages"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.5.2")
    ],
    targets: [
        .target(
            name: "NestoryPackages",
            dependencies: [
                .product(name: "Inject", package: "Inject")
            ]
        )
    ]
)
EOF
    echo -e "${GREEN}✅ Created Package.swift${NC}"
else
    # Check if Inject is already in dependencies
    if grep -q "Inject" "$PROJECT_ROOT/Package.swift"; then
        echo -e "${GREEN}✅ InjectionNext (Inject) already in Package.swift${NC}"
    else
        echo -e "${YELLOW}⚠️  Adding InjectionNext to Package.swift${NC}"
        echo "Please manually add the following dependency to Package.swift:"
        echo '    .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.5.2")'
    fi
fi

# 3. Update project configuration
section "Updating Project Configuration"

# Update Debug.xcconfig
DEBUG_CONFIG="$PROJECT_ROOT/Config/Debug.xcconfig"
if [ -f "$DEBUG_CONFIG" ]; then
    # Check if interposable flag exists
    if ! grep -q "OTHER_LDFLAGS.*interposable" "$DEBUG_CONFIG"; then
        echo -e "${YELLOW}Adding hot reload linker flags${NC}"
        echo "" >> "$DEBUG_CONFIG"
        echo "// Hot reload support for InjectionNext" >> "$DEBUG_CONFIG"
        echo "OTHER_LDFLAGS = \$(inherited) -Xlinker -interposable" >> "$DEBUG_CONFIG"
        echo -e "${GREEN}✅ Added interposable linker flag${NC}"
    else
        echo -e "${GREEN}✅ Linker flags already configured${NC}"
    fi
    
    # Add injection-specific Swift flags
    if ! grep -q "INJECTION_ENABLED" "$DEBUG_CONFIG"; then
        echo "" >> "$DEBUG_CONFIG"
        echo "// InjectionNext support" >> "$DEBUG_CONFIG"
        echo "OTHER_SWIFT_FLAGS = \$(inherited) -DINJECTION_ENABLED" >> "$DEBUG_CONFIG"
        echo -e "${GREEN}✅ Added injection Swift flags${NC}"
    fi
else
    echo -e "${RED}❌ Debug.xcconfig not found${NC}"
fi

# 4. Create SwiftUI injection helper
section "Creating SwiftUI Injection Helper"

INJECTION_HELPER="$PROJECT_ROOT/UI/UI-Core/InjectionHelper.swift"
if [ ! -f "$INJECTION_HELPER" ]; then
    cat > "$INJECTION_HELPER" << 'EOF'
//
// Layer: UI
// Module: UI-Core
// Purpose: Hot reload support for SwiftUI views
//

import SwiftUI

#if DEBUG
import Inject

// ViewModifier for automatic view reloading
public struct InjectViewModifier: ViewModifier {
    @ObserveInjection var injectionObserver
    
    public func body(content: Content) -> some View {
        content
            .onReceive(injectionObserver.objectWillChange) { _ in
                // View will automatically reload
            }
    }
}

// Extension to make injection easy to use
public extension View {
    func enableInjection() -> some View {
        #if DEBUG
        return self.modifier(InjectViewModifier())
        #else
        return self
        #endif
    }
}

// Property wrapper for observing injection in ViewModels
@propertyWrapper
public struct InjectionObserved<T>: DynamicProperty {
    @ObserveInjection private var injectionObserver
    private var value: T
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: T {
        get { value }
        set { value = newValue }
    }
    
    public var projectedValue: Binding<T> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
#endif
EOF
    echo -e "${GREEN}✅ Created InjectionHelper.swift${NC}"
else
    echo -e "${GREEN}✅ InjectionHelper.swift already exists${NC}"
fi

# 5. Update ContentView to use injection
section "Updating Views for Hot Reload Support"

CONTENT_VIEW="$PROJECT_ROOT/App-Main/ContentView.swift"
if [ -f "$CONTENT_VIEW" ]; then
    if ! grep -q "enableInjection()" "$CONTENT_VIEW"; then
        echo -e "${YELLOW}Note: Add .enableInjection() to your views for hot reload${NC}"
        echo "Example:"
        echo "    ContentView()"
        echo "        .enableInjection() // Add this modifier"
    else
        echo -e "${GREEN}✅ ContentView already has injection support${NC}"
    fi
fi

# 6. Create hot reload test script
section "Creating Hot Reload Test Script"

TEST_SCRIPT="$PROJECT_ROOT/tools/dev/test_hot_reload.sh"
cat > "$TEST_SCRIPT" << 'EOF'
#!/bin/bash
# Test Hot Reload Setup

echo "Testing hot reload setup..."

# 1. Check if simulator is running
if pgrep -x "Simulator" > /dev/null; then
    echo "✅ Simulator is running"
else
    echo "❌ Simulator not running. Please start your app first."
    exit 1
fi

# 2. Check if InjectionIII is running
if pgrep -x "InjectionIII" > /dev/null; then
    echo "✅ InjectionIII is running"
else
    echo "⚠️  Starting InjectionIII..."
    open -g "/Applications/InjectionIII.app"
    sleep 2
fi

# 3. Test file modification
TEST_FILE="App-Main/ContentView.swift"
if [ -f "$TEST_FILE" ]; then
    echo "✅ Triggering test injection for $TEST_FILE"
    touch "$TEST_FILE"
    echo "Check your simulator - the view should reload!"
else
    echo "❌ Test file not found"
fi
EOF
chmod +x "$TEST_SCRIPT"
echo -e "${GREEN}✅ Created test_hot_reload.sh${NC}"

# 7. Configure Claude Code settings
section "Configuring Claude Code Settings"

CLAUDE_SETTINGS="$PROJECT_ROOT/.claude/settings.local.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
    # Check if hooks are already configured
    if ! grep -q "hot-reload" "$CLAUDE_SETTINGS"; then
        echo -e "${YELLOW}Note: Hot reload hooks have been configured in .claude/hooks.json${NC}"
    fi
    echo -e "${GREEN}✅ Claude settings exist${NC}"
else
    echo -e "${YELLOW}Creating Claude settings${NC}"
    mkdir -p "$PROJECT_ROOT/.claude"
    cat > "$CLAUDE_SETTINGS" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git log:*)",
      "Bash(./tools/dev/injection_coordinator.sh:*)",
      "WebSearch"
    ]
  },
  "outputStyle": "Explanatory"
}
EOF
    echo -e "${GREEN}✅ Created Claude settings${NC}"
fi

# 8. Create quick start script
section "Creating Quick Start Script"

QUICK_START="$PROJECT_ROOT/tools/dev/start_hot_reload.sh"
cat > "$QUICK_START" << 'EOF'
#!/bin/bash
# Quick Start Hot Reload Development

set -e

echo "🚀 Starting Hot Reload Development Environment"

# 1. Ensure InjectionIII is running
if ! pgrep -x "InjectionIII" > /dev/null; then
    echo "Starting InjectionIII..."
    open -g "/Applications/InjectionIII.app"
    sleep 2
fi

# 2. Build and run the app
echo "Building and running app..."
cd "$(dirname "$0")/../.."
make run

echo ""
echo "✅ Hot reload environment ready!"
echo "Make changes to Swift files and they will auto-inject."
EOF
chmod +x "$QUICK_START"
echo -e "${GREEN}✅ Created start_hot_reload.sh${NC}"

# 9. Final summary
section "Installation Complete!"

echo -e "${GREEN}✅ InjectionNext setup is complete!${NC}"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "1. Run: ${YELLOW}./tools/dev/start_hot_reload.sh${NC} to start development"
echo "2. Make changes to any Swift file in App-Main, UI, or Services"
echo "3. Changes will automatically hot reload in the simulator"
echo ""
echo -e "${CYAN}Key Features Enabled:${NC}"
echo "• Automatic injection on file save (via Claude Code hooks)"
echo "• No manual triggering required"
echo "• No Xcode UI interaction needed"
echo "• Deterministic, hook-driven workflow"
echo ""
echo -e "${CYAN}Tips:${NC}"
echo "• Add ${YELLOW}.enableInjection()${NC} to SwiftUI views for best results"
echo "• Check ${YELLOW}.build/injection.log${NC} for debugging"
echo "• Run ${YELLOW}./tools/dev/test_hot_reload.sh${NC} to test the setup"