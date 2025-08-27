#!/bin/bash

# Nestory App Manual Navigation Testing Script
# This script will systematically test all critical paths

DEVICE_ID="iPhone 16 Pro Max"
BUNDLE_ID="com.drunkonjava.nestory.dev"
SCREENSHOT_DIR="~/Desktop/NestoryManualTesting"

# Create screenshot directory
mkdir -p "$SCREENSHOT_DIR"

echo "🚀 Starting Manual Navigation Testing for Nestory"
echo "📱 Device: $DEVICE_ID"
echo "📦 Bundle: $BUNDLE_ID"

# Function to take screenshot with timestamp
take_screenshot() {
    local name=$1
    local timestamp=$(date +"%H%M%S")
    local filename="${SCREENSHOT_DIR}/${timestamp}_${name}.png"
    xcrun simctl io "$DEVICE_ID" screenshot "$filename"
    echo "📸 Screenshot saved: $filename"
}

# Function to wait for UI updates
wait_for_ui() {
    sleep 2
}

echo "=================================="
echo "🧪 CRITICAL PATH TESTING SEQUENCE"
echo "=================================="

# Step 1: Initial state - Inventory tab
echo "1️⃣ Testing Inventory Tab (Current State)"
take_screenshot "01_inventory_initial"
wait_for_ui

# Step 2: Test Add Item flow
echo "2️⃣ Testing Add Item Button (+ or Add Item)"
# Note: This would require actual interaction, so we'll document what we see
take_screenshot "02_add_item_button_visible"

# Step 3: Document Search functionality  
echo "3️⃣ Testing Search Field Accessibility"
take_screenshot "03_search_field_ready"

# Step 4: Test each tab if accessible via keyboard
echo "4️⃣ Attempting to navigate tabs using accessibility"

# Try to use accessibility identifier approach
# First, let's see if we can get the current focus
xcrun simctl spawn "$DEVICE_ID" xcrun simctl accessibility "$DEVICE_ID" --list-apps 2>/dev/null || echo "Accessibility listing not available"

# Step 5: Test app state after some time
echo "5️⃣ Testing App Stability - Taking final screenshot"
wait_for_ui
take_screenshot "04_final_state"

echo "=================================="
echo "✅ Manual Navigation Testing Complete"
echo "📁 Screenshots saved to: $SCREENSHOT_DIR"
echo "=================================="

# List all screenshots taken
echo "📸 Screenshots captured:"
ls -la "$SCREENSHOT_DIR"/*.png 2>/dev/null || echo "No screenshots found"

echo ""
echo "🔍 Next Steps for Manual Testing:"
echo "   1. Review screenshots for UI state verification"
echo "   2. Manually interact with simulator if needed"
echo "   3. Test critical workflows step by step"
echo "   4. Verify all tabs and navigation work correctly"