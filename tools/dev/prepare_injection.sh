#!/bin/bash
# Prepare InjectionNext Environment
# Ensures the app and environment are ready for hot reload

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Preparing InjectionNext environment...${NC}"

# 1. Check if InjectionIII is installed
if [ -d "/Applications/InjectionIII.app" ]; then
    echo -e "${GREEN}✅ InjectionIII.app found${NC}"
else
    echo -e "${YELLOW}⚠️  InjectionIII.app not found${NC}"
    echo "Please install InjectionIII from the App Store:"
    echo "https://apps.apple.com/app/injectioniii/id1380446739"
    exit 1
fi

# 2. Ensure Debug configuration has proper linker flags
if grep -q "OTHER_LDFLAGS.*-Xlinker -interposable" "$PROJECT_ROOT/Config/Debug.xcconfig" 2>/dev/null; then
    echo -e "${GREEN}✅ Debug linker flags configured${NC}"
else
    echo -e "${YELLOW}⚠️  Adding interposable linker flag to Debug configuration${NC}"
    echo "" >> "$PROJECT_ROOT/Config/Debug.xcconfig"
    echo "// Hot reload support" >> "$PROJECT_ROOT/Config/Debug.xcconfig"
    echo "OTHER_LDFLAGS = \$(inherited) -Xlinker -interposable" >> "$PROJECT_ROOT/Config/Debug.xcconfig"
fi

# 3. Check if the app has injection loading code
APP_FILE="$PROJECT_ROOT/App-Main/NestoryApp.swift"
if grep -q "InjectionBundle.load()" "$APP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Injection loading code present${NC}"
else
    echo -e "${YELLOW}⚠️  Injection loading code not found in app${NC}"
    echo "Add the following to NestoryApp.swift in the init() method:"
    echo ""
    echo "#if DEBUG"
    echo "    Bundle(path: \"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle\")?.load()"
    echo "#endif"
fi

# 4. Create injection configuration file
INJECTION_CONFIG="$PROJECT_ROOT/.injection.conf"
cat > "$INJECTION_CONFIG" << EOF
# InjectionNext Configuration for Nestory
PROJECT_ROOT=$PROJECT_ROOT
INJECTION_ENABLED=true
WATCH_DIRECTORIES=App-Main,UI,Services,Infrastructure,Foundation
EXCLUDE_PATTERNS=Tests,UITests,*.generated.swift
AUTO_INJECT=true
SHOW_NOTIFICATIONS=true
EOF
echo -e "${GREEN}✅ Created injection configuration${NC}"

# 5. Ensure build directory exists
mkdir -p "$PROJECT_ROOT/.build"

# 6. Start InjectionIII in background if not running
if ! pgrep -x "InjectionIII" > /dev/null; then
    echo -e "${BLUE}Starting InjectionIII...${NC}"
    open -g "/Applications/InjectionIII.app"
    sleep 2
fi

echo -e "${GREEN}✅ InjectionNext environment ready${NC}"
echo ""
echo "Next steps:"
echo "1. Run your app in the simulator"
echo "2. Make changes to Swift files"
echo "3. Changes will auto-inject via Claude Code hooks"