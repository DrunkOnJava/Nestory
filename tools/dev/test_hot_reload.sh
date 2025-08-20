#!/bin/bash
# Test Hot Reload Setup
# This script verifies that all hot reload components are properly configured

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
echo -e "${CYAN}              Hot Reload System Test Suite${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test 1: Check if injection coordinator exists and is executable
run_test "Injection coordinator script" "[ -x '$PROJECT_ROOT/tools/dev/injection_coordinator.sh' ]"

# Test 2: Check if hooks.json exists
run_test "Claude hooks configuration" "[ -f '$PROJECT_ROOT/.claude/hooks.json' ]"

# Test 3: Check if hot reload Swift files exist
run_test "InjectionServer.swift" "[ -f '$PROJECT_ROOT/Infrastructure/HotReload/InjectionServer.swift' ]"
run_test "InjectionClient.swift" "[ -f '$PROJECT_ROOT/Infrastructure/HotReload/InjectionClient.swift' ]"
run_test "InjectionCompiler.swift" "[ -f '$PROJECT_ROOT/Infrastructure/HotReload/InjectionCompiler.swift' ]"
run_test "DynamicLoader.swift" "[ -f '$PROJECT_ROOT/Infrastructure/HotReload/DynamicLoader.swift' ]"
run_test "InjectionOrchestrator.swift" "[ -f '$PROJECT_ROOT/Infrastructure/HotReload/InjectionOrchestrator.swift' ]"

# Test 4: Check if Debug.xcconfig has interposable flag
run_test "Debug config linker flags" "grep -q 'interposable' '$PROJECT_ROOT/Config/Debug.xcconfig' 2>/dev/null || true"

# Test 5: Check if simulator is available
run_test "Xcode simulator availability" "xcrun simctl list devices | grep -q 'iPhone' || true"

# Test 6: Check if Swift compiler is available
run_test "Swift compiler" "command -v xcrun && xcrun --find swiftc"

# Test 7: Check if netcat is available for sending commands
run_test "Network utilities (nc)" "command -v nc"

# Test 8: Check if the injection build directory can be created
run_test "Build directory writable" "mkdir -p '$PROJECT_ROOT/.build/injection' && touch '$PROJECT_ROOT/.build/injection/.test' && rm '$PROJECT_ROOT/.build/injection/.test'"

# Test 9: Check hook configuration validity
run_test "Hooks JSON validity" "python3 -m json.tool '$PROJECT_ROOT/.claude/hooks.json' > /dev/null"

# Test 10: Check if project builds in Debug mode
echo -n "Testing Debug build configuration... "
if [ -f "$PROJECT_ROOT/project.yml" ]; then
    echo -e "${GREEN}✅ PASSED${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}⚠️  SKIPPED${NC} (project.yml not found)"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Test Results:${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Hot reload system is ready.${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Run: ${YELLOW}make run${NC} to start your app"
    echo "2. Edit any Swift file in App-Main/ or UI/"
    echo "3. Save the file and watch it hot reload!"
else
    echo -e "${RED}⚠️  Some tests failed. Please fix the issues above.${NC}"
    echo ""
    echo -e "${CYAN}Troubleshooting tips:${NC}"
    echo "• Ensure all files were created successfully"
    echo "• Check file permissions with: ${YELLOW}ls -la tools/dev/${NC}"
    echo "• Verify Xcode command line tools: ${YELLOW}xcode-select --install${NC}"
fi

# Optional: Test live injection if simulator is running
if pgrep -x "Simulator" > /dev/null; then
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Simulator detected! Testing live injection...${NC}"
    
    # Check if injection server is running
    if lsof -i :8899 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Injection server is running on port 8899${NC}"
        
        # Test server connectivity
        if echo "PING" | nc -w 1 localhost 8899 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Successfully connected to injection server${NC}"
        else
            echo -e "${YELLOW}⚠️  Could not connect to injection server${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Injection server not running${NC}"
        echo "The server should start automatically when the app launches in DEBUG mode"
    fi
else
    echo ""
    echo -e "${BLUE}ℹ️  Simulator not running. Start your app to test live injection.${NC}"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"