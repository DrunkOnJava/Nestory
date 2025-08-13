#!/bin/bash

#
# run_fastlane_screenshots.sh
# Automated screenshot generation script for Nestory app
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCREENSHOTS_DIR="$PROJECT_ROOT/fastlane/screenshots"
ARCHIVE_DIR="$PROJECT_ROOT/fastlane/screenshots_archive"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Nestory Screenshot Generation${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check for fastlane installation
echo -e "${YELLOW}Checking dependencies...${NC}"
if ! command -v fastlane &> /dev/null; then
    echo -e "${RED}Error: Fastlane is not installed${NC}"
    echo "Please install fastlane using one of these methods:"
    echo "  gem install fastlane"
    echo "  brew install fastlane"
    exit 1
fi

echo -e "${GREEN}✓ Fastlane found${NC}"

# Navigate to project directory
cd "$PROJECT_ROOT"

# Clean previous screenshots
echo -e "${YELLOW}Cleaning previous screenshots...${NC}"
if [ -d "$SCREENSHOTS_DIR" ]; then
    # Archive existing screenshots
    if [ "$(ls -A $SCREENSHOTS_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}Archiving existing screenshots...${NC}"
        mkdir -p "$ARCHIVE_DIR"
        ARCHIVE_PATH="$ARCHIVE_DIR/screenshots_$TIMESTAMP"
        cp -r "$SCREENSHOTS_DIR" "$ARCHIVE_PATH"
        echo -e "${GREEN}✓ Screenshots archived to: $ARCHIVE_PATH${NC}"
    fi
    
    # Clean screenshots directory
    rm -rf "$SCREENSHOTS_DIR"/*
    echo -e "${GREEN}✓ Previous screenshots cleaned${NC}"
fi

# Clean derived data for fresh build
echo -e "${YELLOW}Cleaning derived data...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*
echo -e "${GREEN}✓ Derived data cleaned${NC}"

# Update Xcode project if needed
if command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}Regenerating Xcode project...${NC}"
    xcodegen
    echo -e "${GREEN}✓ Xcode project regenerated${NC}"
fi

# Run fastlane snapshot
echo ""
echo -e "${YELLOW}Starting screenshot generation...${NC}"
echo -e "${YELLOW}This will take several minutes...${NC}"
echo ""

# Run fastlane with error handling
if fastlane screenshots; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Screenshots generated successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # Count screenshots
    if [ -d "$SCREENSHOTS_DIR/en-US" ]; then
        SCREENSHOT_COUNT=$(find "$SCREENSHOTS_DIR/en-US" -name "*.png" | wc -l | tr -d ' ')
        echo -e "${GREEN}Generated $SCREENSHOT_COUNT screenshots${NC}"
    fi
    
    # Open HTML report
    HTML_FILE="$SCREENSHOTS_DIR/screenshots.html"
    if [ -f "$HTML_FILE" ]; then
        echo -e "${YELLOW}Opening HTML report...${NC}"
        open "$HTML_FILE"
    fi
    
    # Open screenshots directory
    echo -e "${YELLOW}Opening screenshots directory...${NC}"
    open "$SCREENSHOTS_DIR"
    
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ Screenshot generation failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo "Troubleshooting tips:"
    echo "1. Make sure the simulator is not already running"
    echo "2. Check that the scheme 'NestoryUITests' exists"
    echo "3. Ensure UI test files are added to the correct target"
    echo "4. Try running: fastlane snapshot reset_simulators"
    echo ""
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}Screenshot locations:${NC}"
echo "  Current: $SCREENSHOTS_DIR"
if [ -n "${ARCHIVE_PATH:-}" ]; then
    echo "  Archive: $ARCHIVE_PATH"
fi
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Review screenshots in the HTML report"
echo "  2. Use screenshots for App Store submission"
echo "  3. Share with team for review"
echo ""