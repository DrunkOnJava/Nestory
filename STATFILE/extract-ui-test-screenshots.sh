#!/bin/bash

# Extract UI Test Screenshots Script
# Automatically extracts screenshots from XCTest result bundles and organizes them

set -e

# Configuration
RESULT_BUNDLE_PATH=${1:-"/tmp/nestory_wiring_test_results.xcresult"}
OUTPUT_DIR=${2:-"~/Desktop/NestoryUIWiringScreenshots"}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔍 UI Test Screenshot Extraction"
echo "=================================="
echo "📁 Result Bundle: $RESULT_BUNDLE_PATH"
echo "📁 Output Directory: $OUTPUT_DIR" 
echo "⏰ Timestamp: $TIMESTAMP"
echo ""

# Expand tilde in OUTPUT_DIR
OUTPUT_DIR=$(eval echo "$OUTPUT_DIR")

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if result bundle exists
if [ ! -d "$RESULT_BUNDLE_PATH" ]; then
    echo "❌ Error: Result bundle not found at $RESULT_BUNDLE_PATH"
    exit 1
fi

echo "📸 Extracting screenshots from test results..."

# Create timestamped subdirectory
EXTRACTION_DIR="$OUTPUT_DIR/ui_wiring_$TIMESTAMP"
mkdir -p "$EXTRACTION_DIR"

# Export attachments using xcresulttool
if command -v xcrun >/dev/null 2>&1; then
    echo "🔧 Using xcresulttool to extract test attachments..."
    
    # Try to extract using xcresulttool export
    xcrun xcresulttool export \
        --path "$RESULT_BUNDLE_PATH" \
        --output-path "$EXTRACTION_DIR" \
        --type directory 2>/dev/null || {
        echo "⚠️  Direct export failed, trying alternative extraction..."
        
        # Alternative: Find and copy screenshot files directly
        find "$RESULT_BUNDLE_PATH" -name "*.png" -exec cp {} "$EXTRACTION_DIR/" \; 2>/dev/null || {
            echo "⚠️  PNG files not found, searching for compressed attachments..."
            
            # Look for compressed data files
            ATTACHMENT_COUNT=0
            if [ -d "$RESULT_BUNDLE_PATH/Data" ]; then
                for data_file in "$RESULT_BUNDLE_PATH/Data"/data.*; do
                    if [ -f "$data_file" ]; then
                        # Check if it's compressed
                        if file "$data_file" | grep -q "Zstandard"; then
                            # Try to decompress and check for PNG
                            TEMP_FILE=$(mktemp)
                            if zstd -d "$data_file" -o "$TEMP_FILE" 2>/dev/null; then
                                if file "$TEMP_FILE" | grep -q "PNG"; then
                                    cp "$TEMP_FILE" "$EXTRACTION_DIR/screenshot_$ATTACHMENT_COUNT.png"
                                    ATTACHMENT_COUNT=$((ATTACHMENT_COUNT + 1))
                                fi
                            fi
                            rm -f "$TEMP_FILE"
                        fi
                    fi
                done
            fi
            
            if [ $ATTACHMENT_COUNT -eq 0 ]; then
                echo "⚠️  No screenshots found in result bundle (test may not have captured screenshots)"
                echo "ℹ️  This can happen if:"
                echo "   - Test completed too quickly"
                echo "   - No screenshot capture calls were made"
                echo "   - Test failed before reaching screenshot code"
                exit 0  # Don't fail the build for missing screenshots
            else
                echo "✅ Extracted $ATTACHMENT_COUNT screenshots from compressed data"
            fi
        }
    }
    
    # Count extracted files
    EXTRACTED_COUNT=$(find "$EXTRACTION_DIR" -name "*.png" | wc -l | tr -d ' ')
    
    if [ "$EXTRACTED_COUNT" -gt 0 ]; then
        echo "✅ Successfully extracted $EXTRACTED_COUNT screenshots"
        echo "📁 Screenshots saved to: $EXTRACTION_DIR"
        
        # List extracted files
        echo ""
        echo "📋 Extracted files:"
        ls -la "$EXTRACTION_DIR"/*.png 2>/dev/null || echo "No PNG files found"
        
        # Create a summary report
        SUMMARY_FILE="$EXTRACTION_DIR/extraction_summary.txt"
        cat > "$SUMMARY_FILE" << EOF
UI Test Screenshot Extraction Summary
====================================
Extraction Time: $(date)
Result Bundle: $RESULT_BUNDLE_PATH
Output Directory: $EXTRACTION_DIR
Screenshots Extracted: $EXTRACTED_COUNT

Test Files:
$(ls -la "$EXTRACTION_DIR"/*.png 2>/dev/null || echo "No PNG files found")

Result Bundle Info:
$(find "$RESULT_BUNDLE_PATH" -name "*.xcresult" -exec du -h {} \; 2>/dev/null || echo "Bundle size unknown")
EOF
        
        echo "📄 Summary saved to: $SUMMARY_FILE"
        
        # Open directory if on macOS
        if command -v open >/dev/null 2>&1; then
            echo "🔍 Opening screenshots directory..."
            open "$EXTRACTION_DIR"
        fi
        
    else
        echo "ℹ️  No screenshots were extracted - this is normal for some test runs"
        echo "📄 Creating summary report anyway..."
        
        # Create a summary report even without screenshots
        SUMMARY_FILE="$EXTRACTION_DIR/extraction_summary.txt"
        cat > "$SUMMARY_FILE" << EOF
UI Test Screenshot Extraction Summary
====================================
Extraction Time: $(date)
Result Bundle: $RESULT_BUNDLE_PATH
Output Directory: $EXTRACTION_DIR
Screenshots Extracted: 0

Note: No screenshots were found in this test run.
This can happen if the test completed without capturing screenshots.

Result Bundle Info:
$(find "$RESULT_BUNDLE_PATH" -name "*.xcresult" -exec du -h {} \; 2>/dev/null || echo "Bundle size unknown")
EOF
        
        echo "📄 Summary saved to: $SUMMARY_FILE"
        exit 0  # Don't fail the build
    fi
    
else
    echo "❌ Error: xcrun not found. This script requires Xcode command line tools."
    exit 1
fi

echo ""
echo "🎯 UI Test Screenshot extraction completed!"
echo "📁 Check $EXTRACTION_DIR for your screenshots"