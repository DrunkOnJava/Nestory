#!/bin/bash
# Build script that ensures Swift 6 is used regardless of environment

echo "🚀 Building Nestory with Swift 6..."

# Force unset TOOLCHAINS to ensure Swift 6
unset TOOLCHAINS
export TOOLCHAINS=""

# Verify Swift version
SWIFT_VERSION=$(swift --version 2>/dev/null | head -n 1)
echo "Using: $SWIFT_VERSION"

if [[ "$SWIFT_VERSION" != *"6."* ]]; then
    echo "❌ Error: Swift 6 not detected!"
    echo "Please ensure Swift 6 is installed and available"
    exit 1
fi

# Clean build directory
echo "Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*

# Build the app
echo "Building..."
xcodebuild -scheme Nestory-Dev \
    -destination 'platform=iOS Simulator,name=iPhone 16 Plus' \
    -configuration Debug \
    build \
    SWIFT_VERSION=6.0 \
    2>&1 | xcbeautify || true

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Build succeeded with Swift 6!"
else
    echo "❌ Build failed"
    exit 1
fi