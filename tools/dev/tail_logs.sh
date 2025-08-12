#!/bin/bash
# Tail logs from running Nestory app
# Part of the hot reload development setup

set -e

echo "📋 Tailing logs for Nestory app..."
echo "Press Ctrl+C to stop"
echo ""

# Get the device ID for iPhone 16 Plus
DEVICE_ID=$(xcrun simctl list devices | grep "iPhone 16 Plus" | grep -v unavailable | head -n 1 | awk -F '[()]' '{print $2}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ iPhone 16 Plus simulator not found"
    exit 1
fi

# Stream logs with color coding
xcrun simctl spawn "$DEVICE_ID" log stream \
    --predicate 'processImagePath CONTAINS "Nestory" OR subsystem CONTAINS "com.nestory"' \
    --info \
    --debug \
    --color always \
    --style compact | while IFS= read -r line; do
        # Color code different log types
        if [[ "$line" == *"[ERROR]"* ]] || [[ "$line" == *"error"* ]]; then
            echo -e "\033[31m$line\033[0m"  # Red for errors
        elif [[ "$line" == *"[WARNING]"* ]] || [[ "$line" == *"warning"* ]]; then
            echo -e "\033[33m$line\033[0m"  # Yellow for warnings
        elif [[ "$line" == *"[HOT RELOAD]"* ]] || [[ "$line" == *"Injection"* ]]; then
            echo -e "\033[32m$line\033[0m"  # Green for hot reload
        elif [[ "$line" == *"[DEBUG]"* ]]; then
            echo -e "\033[36m$line\033[0m"  # Cyan for debug
        else
            echo "$line"
        fi
    done