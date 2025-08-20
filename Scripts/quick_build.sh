#!/bin/bash
# Quick build script for Nestory development

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔨 Quick building Nestory..."

xcodebuild build \
    -project Nestory.xcodeproj \
    -scheme Nestory-Dev \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
    -derivedDataPath build \
    -configuration Debug \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=YES

echo "✅ Quick build completed!"
