#!/bin/bash

# Generate App Icons for Nestory
# Usage: ./generate_app_icons.sh path/to/source-icon.png

set -e

# Check if source image is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-source-icon.png>"
    echo "Source icon should be 1024x1024 PNG for best results"
    exit 1
fi

SOURCE_ICON="$1"

# Check if source file exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon file not found: $SOURCE_ICON"
    exit 1
fi

# Define the output path
OUTPUT_PATH="App-Main/Assets.xcassets/AppIcon.appiconset"

echo "🎨 Generating iOS app icons from: $SOURCE_ICON"
echo "📁 Output directory: $OUTPUT_PATH"

# Generate icons with appicon tool
# This will create all required iOS icon sizes
appicon "$SOURCE_ICON" \
    --icon-name AppIcon \
    --output-path "$OUTPUT_PATH" \
    --ipad

echo "✅ App icons generated successfully!"
echo ""
echo "Generated icon sizes:"
ls -la "$OUTPUT_PATH"/*.png 2>/dev/null | awk '{print $9}' | xargs -I {} basename {} | sort

echo ""
echo "🎉 Done! The icons have been added to your Xcode project."
echo "Open Xcode and verify the icons appear correctly in Assets.xcassets"