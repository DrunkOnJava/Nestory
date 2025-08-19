#!/bin/bash

# Upload to TestFlight script
# This uses the App Store Connect API key to upload the existing archive

echo "🚀 Uploading to TestFlight..."

# Set the API key path
export API_KEY_PATH="/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8"
export API_KEY_ID="NWV654RNK3"
export API_ISSUER_ID="f144f0a6-1aff-44f3-974e-183c4c07bc46"

# Use the most recent archive
ARCHIVE_PATH="/Users/griffin/Library/Developer/Xcode/Archives/2025-08-19/Nestory-Dev 2025-08-19 03.31.00.xcarchive"

# Check if archive exists
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Archive not found at: $ARCHIVE_PATH"
    exit 1
fi

echo "📦 Using archive: $ARCHIVE_PATH"

# Use xcrun altool to upload to TestFlight
xcrun altool --upload-app \
    -f "$ARCHIVE_PATH" \
    -t ios \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER_ID" \
    --verbose

echo "✅ Upload complete!"