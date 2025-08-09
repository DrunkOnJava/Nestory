#!/bin/bash

# Quick Screenshot Test - Captures screenshots on current simulator

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Quick Screenshot Test${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Get project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_DIR"

# Run the test
echo -e "${YELLOW}Running screenshot tests on current simulator...${NC}"
echo ""

xcodebuild test \
    -project Nestory.xcodeproj \
    -scheme Nestory \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:NestoryUITests/NestoryScreenshotTests/testCaptureAllScreenshots \
    -quiet

echo ""
echo -e "${GREEN}✓ Screenshot test completed!${NC}"
echo ""
echo "Screenshots are attached to the test results in Xcode."
echo "To view: Open Xcode > Product > Test > Right-click latest test > Show in Report Navigator"