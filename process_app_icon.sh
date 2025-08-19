#!/bin/bash

# Process App Icon - Remove white background and/or crop
# Usage: ./process_app_icon.sh input.png output.png [zoom_percentage]

set -e

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input.png> <output.png> [zoom_percentage]"
    echo "Example: $0 nestoryappicon1.png nestory_icon_clean.png 120"
    echo ""
    echo "zoom_percentage: Optional, crops and zooms the icon (e.g., 120 for 120%)"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"
ZOOM="${3:-100}"  # Default to 100% (no zoom)

# Check if input exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file not found: $INPUT"
    exit 1
fi

echo "🎨 Processing app icon..."
echo "📄 Input: $INPUT"
echo "📤 Output: $OUTPUT"
echo "🔍 Zoom: ${ZOOM}%"

# Create a temporary file for intermediate processing
TEMP_FILE="/tmp/icon_temp_$$.png"

# Step 1: Remove white background (make transparent)
# Using fuzz to catch near-white pixels too
echo "➤ Removing white background..."
magick "$INPUT" \
    -fuzz 5% \
    -transparent white \
    "$TEMP_FILE"

# Step 2: Apply zoom/crop if requested
if [ "$ZOOM" != "100" ]; then
    echo "➤ Applying ${ZOOM}% zoom..."
    
    # Get current dimensions
    WIDTH=$(magick identify -format "%w" "$TEMP_FILE")
    HEIGHT=$(magick identify -format "%h" "$TEMP_FILE")
    
    # Calculate crop dimensions (zoom in by cropping edges)
    CROP_FACTOR=$(echo "scale=4; 100 / $ZOOM" | bc)
    NEW_WIDTH=$(echo "$WIDTH * $CROP_FACTOR" | bc | cut -d. -f1)
    NEW_HEIGHT=$(echo "$HEIGHT * $CROP_FACTOR" | bc | cut -d. -f1)
    
    # Crop from center and resize back to original dimensions
    magick "$TEMP_FILE" \
        -gravity center \
        -crop "${NEW_WIDTH}x${NEW_HEIGHT}+0+0" \
        -resize "${WIDTH}x${HEIGHT}" \
        "$OUTPUT"
else
    cp "$TEMP_FILE" "$OUTPUT"
fi

# Clean up
rm -f "$TEMP_FILE"

echo "✅ Icon processed successfully!"
echo ""
echo "Preview the result:"
echo "  open '$OUTPUT'"
echo ""
echo "To generate app icons with the processed image:"
echo "  ./generate_app_icons.sh '$OUTPUT'"