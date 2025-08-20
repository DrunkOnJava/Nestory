#!/bin/bash
# Complete development cycle automation

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Starting complete development cycle..."

# 1. Quick build
echo "📋 Step 1: Building..."
./Scripts/quick_build.sh

# 2. Run unit tests
echo "📋 Step 2: Testing..."
./Scripts/quick_test.sh

# 3. Run UI automation
echo "📋 Step 3: UI Testing..."
./Scripts/run_simulator_automation.sh --test-only

echo "✅ Development cycle completed successfully!"
