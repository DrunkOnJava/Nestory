#!/bin/bash
# Ensure Swift 6 is used for all build commands

# Force unset TOOLCHAINS
unset TOOLCHAINS
export TOOLCHAINS=""

# Verify Swift 6
SWIFT_VERSION=$(swift --version 2>/dev/null | head -n 1)
if [[ "$SWIFT_VERSION" == *"6."* ]]; then
    echo "✅ Using Swift 6: $SWIFT_VERSION"
else
    echo "❌ Wrong Swift version: $SWIFT_VERSION"
    echo "Attempting to fix..."
    # Try to use xcrun's Swift
    export PATH="/usr/bin:$PATH"
fi

# Execute the command passed as arguments
exec "$@"