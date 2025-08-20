#!/bin/bash
# Nestory Build & Run Script
# Purpose: Generate, build, and run the app on iPhone 16 Pro Max

set -e  # Exit on error

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }
log_info() { echo -e "${YELLOW}➜${NC} $1"; }

# Change to project directory
cd "$(dirname "$0")"

log_info "Starting Nestory build process..."

# Check for xcodegen
if ! command -v xcodegen &> /dev/null; then
    log_error "xcodegen not found. Installing..."
    brew install xcodegen
fi

# Clean previous builds
log_info "Cleaning previous builds..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-*
rm -rf DerivedData
rm -rf .build

# Generate Xcode project
log_info "Generating Xcode project with XcodeGen..."
xcodegen generate

if [ ! -d "Nestory.xcodeproj" ]; then
    log_error "Failed to generate Xcode project"
    exit 1
fi

log_success "Xcode project generated"

# Build the app
log_info "Building for iPhone 16 Pro Max..."

# First, list available devices to help debug
log_info "Available simulators:"
xcrun simctl list devices available | grep iPhone

# Try to build with iPhone 16 Pro Max, fallback to iPhone 15 Pro Max if not available
DEVICE="iPhone 16 Pro Max"
if ! xcrun simctl list devices available | grep -q "iPhone 16 Pro Max"; then
    log_info "iPhone 16 Pro Max not found, trying iPhone 15 Pro Max..."
    DEVICE="iPhone 15 Pro Max"
fi

if ! xcrun simctl list devices available | grep -q "$DEVICE"; then
    log_info "$DEVICE not found, using generic iOS Simulator..."
    DEVICE="iPhone 15"
fi

log_info "Building for: $DEVICE"

xcodebuild \
    -scheme Nestory-Dev \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -configuration Debug \
    -derivedDataPath DerivedData \
    build

if [ $? -eq 0 ]; then
    log_success "Build successful!"
else
    log_error "Build failed!"
    exit 1
fi

# Find the app bundle
APP_PATH=$(find DerivedData -name "Nestory.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    log_error "Could not find built app"
    exit 1
fi

log_success "App found at: $APP_PATH"

# Boot the simulator
log_info "Booting simulator..."
DEVICE_ID=$(xcrun simctl list devices available | grep "$DEVICE" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)

if [ -z "$DEVICE_ID" ]; then
    log_error "Could not find device ID"
    exit 1
fi

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator

# Wait for simulator to boot
log_info "Waiting for simulator to boot..."
xcrun simctl bootstatus "$DEVICE_ID"

# Install the app
log_info "Installing app on simulator..."
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

# Launch the app
log_info "Launching Nestory..."
xcrun simctl launch "$DEVICE_ID" "${PRODUCT_BUNDLE_IDENTIFIER:-com.drunkonjava.nestory}"

log_success "Nestory is now running on $DEVICE!"
log_info "Simulator should be visible. If not, check the Simulator app."

# Keep script running to see logs
log_info "Streaming device logs (Ctrl+C to stop)..."
xcrun simctl spawn "$DEVICE_ID" log stream --predicate "subsystem == \"${BUNDLE_IDENTIFIER:-com.drunkonjava.nestory}\"" --level debug
