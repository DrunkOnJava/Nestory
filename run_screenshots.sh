#!/bin/bash

# Simple Screenshot Capture Script

echo "📸 Capturing Nestory Screenshots..."
echo ""

# Run the simple screenshot test
xcodebuild test \
    -project Nestory.xcodeproj \
    -scheme Nestory \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:NestoryUITests/SimpleScreenshotTests/testTakeAppScreenshots \
    2>&1 | grep -E "📸|✅|Test Suite|passed|failed"

echo ""
echo "✅ Done! Screenshots are saved in the test results."
echo ""
echo "To view screenshots:"
echo "1. Open Xcode"
echo "2. Go to Report Navigator (⌘9)"
echo "3. Select the latest test run"
echo "4. Click on the test to see attached screenshots"