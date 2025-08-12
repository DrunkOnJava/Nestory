#!/bin/bash
# Launch InjectionIII for hot reload development
# Part of the hot reload development setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INJECTION_APP="$SCRIPT_DIR/InjectionIII.app"
PROJECT_ROOT="$(dirname $(dirname "$SCRIPT_DIR"))"

if [ ! -d "$INJECTION_APP" ]; then
    echo "❌ InjectionIII.app not found at $INJECTION_APP"
    echo "Downloading InjectionIII..."
    cd "$SCRIPT_DIR"
    curl -L https://github.com/johnno1962/InjectionIII/releases/latest/download/InjectionIII.app.zip -o InjectionIII.app.zip
    unzip -q InjectionIII.app.zip
    rm -f InjectionIII.app.zip
    xattr -d com.apple.quarantine InjectionIII.app 2>/dev/null || true
fi

echo "🚀 Launching InjectionIII..."
open "$INJECTION_APP"

# Wait for app to launch
sleep 2

echo "✅ InjectionIII is running"
echo ""
echo "📝 Setup Instructions:"
echo "1. In InjectionIII menu bar, select 'Open Project'"
echo "2. Navigate to: $PROJECT_ROOT"
echo "3. Click 'Select Project Directory'"
echo "4. InjectionIII will now watch for file changes"
echo ""
echo "💡 Hot Reload will be active when you run the app with:"
echo "   ./tools/dev/build_install_run.sh"
echo ""
echo "🔥 Save any Swift file to trigger hot reload!"