#!/bin/bash
# Quick test script for Nestory development

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 Running quick tests..."

# Run unit tests only (faster than full test suite)
xcodebuild test \
    -project Nestory.xcodeproj \
    -scheme Nestory-Dev \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
    -derivedDataPath build \
    -only-testing:NestoryTests \
    -configuration Debug

echo "✅ Quick tests completed!"
