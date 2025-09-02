#!/bin/bash

#
# XcodeGen wrapper with automatic build phase injection for metrics
#

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🛠️  XcodeGen with Metrics Integration${NC}"
echo "======================================="

# First, update project.yml to include build phase
PROJECT_YML="${1:-project.yml}"
TEMP_YML="/tmp/project-with-metrics.yml"

# Check if metrics build phase already exists
if ! grep -q "capture-build-metrics" "$PROJECT_YML" 2>/dev/null; then
    echo -e "${YELLOW}Adding metrics build phase to project configuration...${NC}"
    
    # Create temporary project.yml with metrics phase
    cp "$PROJECT_YML" "$TEMP_YML"
    
    # We'll need to inject the build phase into targets
    # This is a simplified approach - in practice you'd parse YAML properly
    cat >> "$TEMP_YML" << 'EOF'

# Metrics collection build phase (auto-injected)
targets:
  Nestory:
    preBuildScripts:
      - name: "📊 Capture Build Metrics"
        script: |
          export BUILD_START_TIME="${BUILD_START_TIME:-$(date +%s)}"
          "${SRCROOT}/Scripts/CI/xcode-build-phase.sh" || true
        shell: /bin/bash
        runOnlyWhenInstalling: false
EOF
    
    # Use modified project.yml
    PROJECT_YML="$TEMP_YML"
fi

# Run xcodegen
echo -e "${BLUE}Generating Xcode project...${NC}"
if xcodegen generate --spec "$PROJECT_YML"; then
    echo -e "${GREEN}✅ Project generated with metrics integration${NC}"
    
    # Clean up temp file if we created one
    [ -f "$TEMP_YML" ] && rm -f "$TEMP_YML"
    
    echo -e "\n${BLUE}Metrics will be automatically collected when you:${NC}"
    echo "  • Build in Xcode GUI"
    echo "  • Use xcodebuild from command line"
    echo "  • Run 'make build'"
    echo ""
    echo "Dashboard: http://localhost:3000/d/nestory-full/"
else
    echo -e "${RED}❌ Failed to generate project${NC}"
    [ -f "$TEMP_YML" ] && rm -f "$TEMP_YML"
    exit 1
fi