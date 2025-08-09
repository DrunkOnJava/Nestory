#!/bin/bash

# Nestory Screenshot Capture Script
# This script runs UI tests to capture screenshots for all supported devices

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_PATH="$(dirname "$0")/../../Nestory.xcodeproj"
SCHEME="Nestory"
OUTPUT_DIR="$HOME/Desktop/NestoryScreenshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_DIR="$OUTPUT_DIR/$TIMESTAMP"

# Create output directory
mkdir -p "$RESULTS_DIR"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Nestory Screenshot Capture${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Output directory: $RESULTS_DIR"
echo ""

# Function to capture screenshots for a device
capture_device_screenshots() {
    local device_name="$1"
    local safe_name=$(echo "$device_name" | sed 's/ /_/g' | sed 's/[()]//g')
    
    echo -e "${YELLOW}Capturing screenshots for: $device_name${NC}"
    
    # Build and test
    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,name=$device_name" \
        -only-testing:NestoryUITests/NestoryDeviceScreenshotTests/testCaptureAllScreensForCurrentDevice \
        -resultBundlePath "$RESULTS_DIR/${safe_name}_Results.xcresult" \
        2>&1 | grep -E "Test (Suite|Case|Succeeded|Failed)|error:" || true
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $device_name completed${NC}"
        
        # Extract screenshots from xcresult
        xcparse screenshots "$RESULTS_DIR/${safe_name}_Results.xcresult" "$RESULTS_DIR/$safe_name" 2>/dev/null || true
    else
        echo -e "${RED}✗ $device_name failed${NC}"
    fi
    
    echo ""
}

# iPhone devices to test
IPHONE_DEVICES=(
    "iPhone 16 Pro Max"
    "iPhone 16 Pro"
    "iPhone 15 Pro"
    "iPhone SE (3rd generation)"
)

# iPad devices to test (optional)
IPAD_DEVICES=(
    "iPad Pro (13-inch) (M4)"
    "iPad Air (6th generation)"
    "iPad mini (6th generation)"
)

# Capture screenshots for iPhones
echo -e "${GREEN}Starting iPhone screenshots...${NC}"
echo ""

for device in "${IPHONE_DEVICES[@]}"; do
    capture_device_screenshots "$device"
done

# Ask if user wants iPad screenshots
read -p "Do you want to capture iPad screenshots? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Starting iPad screenshots...${NC}"
    echo ""
    
    for device in "${IPAD_DEVICES[@]}"; do
        capture_device_screenshots "$device"
    done
fi

# Summary
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Screenshot Capture Complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Results saved to: $RESULTS_DIR"
echo ""

# Open results folder
open "$RESULTS_DIR"

# Generate HTML preview (optional)
echo "Generating HTML preview..."
cat > "$RESULTS_DIR/preview.html" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Nestory Screenshots</title>
    <style>
        body { font-family: -apple-system, system-ui; margin: 20px; background: #f5f5f5; }
        h1 { color: #333; }
        .device-section { margin: 30px 0; background: white; padding: 20px; border-radius: 10px; }
        .device-title { font-size: 24px; font-weight: bold; margin-bottom: 20px; }
        .screenshot-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .screenshot { border: 1px solid #ddd; border-radius: 8px; overflow: hidden; }
        .screenshot img { width: 100%; height: auto; display: block; }
        .screenshot-label { padding: 10px; background: #f9f9f9; font-size: 14px; text-align: center; }
    </style>
</head>
<body>
    <h1>Nestory App Screenshots</h1>
    <p>Generated: $(date)</p>
EOF

# Add screenshots to HTML
for dir in "$RESULTS_DIR"/*; do
    if [ -d "$dir" ]; then
        device_name=$(basename "$dir")
        echo "<div class='device-section'>" >> "$RESULTS_DIR/preview.html"
        echo "<div class='device-title'>$device_name</div>" >> "$RESULTS_DIR/preview.html"
        echo "<div class='screenshot-grid'>" >> "$RESULTS_DIR/preview.html"
        
        for img in "$dir"/*.png; do
            if [ -f "$img" ]; then
                img_name=$(basename "$img")
                echo "<div class='screenshot'>" >> "$RESULTS_DIR/preview.html"
                echo "<img src='$device_name/$img_name' />" >> "$RESULTS_DIR/preview.html"
                echo "<div class='screenshot-label'>$img_name</div>" >> "$RESULTS_DIR/preview.html"
                echo "</div>" >> "$RESULTS_DIR/preview.html"
            fi
        done
        
        echo "</div></div>" >> "$RESULTS_DIR/preview.html"
    fi
done

echo "</body></html>" >> "$RESULTS_DIR/preview.html"

echo -e "${GREEN}HTML preview generated: $RESULTS_DIR/preview.html${NC}"