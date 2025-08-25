#!/bin/bash
set -euo pipefail

# Require jq early
command -v jq >/dev/null || { echo "Install jq (brew install jq)"; exit 1; }

# === Config ===
PROJECT_NAME="Nestory"
SCHEME_NAME="Nestory-Dev"
SIMULATOR="iPhone 16 Pro Max"  # Using the simulator from the project
TIMESTAMP=$(date +%s)
RESULT_BUNDLE="/tmp/${PROJECT_NAME}_uitest_${TIMESTAMP}.xcresult"
OUTPUT_DIR="$HOME/Desktop/NestoryUIWiringScreenshots"
EXTRACTED_DIR="${OUTPUT_DIR}/extracted_${TIMESTAMP}"
BUNDLE_ID="com.drunkonjava.nestory.dev"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${YELLOW}▶ Starting UI Test Screenshot Pipeline${NC}"
echo "Result Bundle: ${RESULT_BUNDLE}"

# Clean old extractions
rm -rf "${OUTPUT_DIR}/extracted_"* 2>/dev/null || true
mkdir -p "${OUTPUT_DIR}"

# Resolve target simulator (multi-sim safe)
UDID=$(xcrun simctl list devices | awk '/'"${SIMULATOR//\ /\\ }"'.*Booted/ {gsub(/[()]/,"",$NF); print $NF; exit}')
TARGET=${UDID:-booted}

# Boot simulator if needed
if [ -z "$UDID" ]; then
    echo -e "${YELLOW}▶ Booting simulator...${NC}"
    xcrun simctl boot "${SIMULATOR}" 2>/dev/null || true
    sleep 5
    TARGET="booted"
fi

# Stabilize status bar + appearance
echo -e "${YELLOW}▶ Stabilizing simulator environment...${NC}"
xcrun simctl status_bar "$TARGET" override \
  --time 9:41 --wifiBars 3 --cellularMode active --batteryState charged --batteryLevel 100 || true
xcrun simctl ui "$TARGET" appearance light || true

# Pre-grant permissions to avoid alerts
echo -e "${YELLOW}▶ Pre-granting permissions...${NC}"
xcrun simctl privacy "$TARGET" grant photos      "$BUNDLE_ID" || true
xcrun simctl privacy "$TARGET" grant photos-add  "$BUNDLE_ID" || true
xcrun simctl privacy "$TARGET" grant camera      "$BUNDLE_ID" || true
xcrun simctl privacy "$TARGET" grant location    "$BUNDLE_ID" || true

# Run tests deterministically
echo -e "${YELLOW}▶ Running UI tests...${NC}"
xcodebuild test \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME_NAME}" \
  -destination "platform=iOS Simulator,name=${SIMULATOR}" \
  -only-testing:NestoryUITests/ComprehensiveScreenshotTest/testCompleteAppScreenshotCatalog \
  -resultBundlePath "${RESULT_BUNDLE}" \
  -resultBundleVersion 3 \
  -derivedDataPath "/tmp/DerivedData-${PROJECT_NAME}" \
  -parallel-testing-enabled NO \
  -maximum-concurrent-test-simulator-destinations 1 \
  -disable-concurrent-destination-testing \
  -quiet 2>&1 | grep -E "(Test Case|✅|📸|passed|failed|Executed)" || true

echo -e "${GREEN}✔ Tests finished${NC}"

# Check if result bundle exists
if [ ! -d "$RESULT_BUNDLE" ]; then
    echo -e "${RED}✗ Result bundle not created - tests may have failed to compile${NC}"
    xcrun simctl status_bar "$TARGET" clear || true
    exit 1
fi

# Extract PNG attachments (via JSON walk)
echo -e "${YELLOW}▶ Extracting screenshots from result bundle...${NC}"
mkdir -p "${EXTRACTED_DIR}"
xcrun xcresulttool get --legacy --path "$RESULT_BUNDLE" --format json > /tmp/xc_${TIMESTAMP}.json

# Export all PNG attachments
PNG_COUNT=0
for id in $(jq -r '..|objects?|to_entries[]|select(.key=="payloadRef")|.value.id' /tmp/xc_${TIMESTAMP}.json); do
  uti=$(jq -r --arg id "$id" '..|objects?|to_entries[]|select(.value.id==$id)|.value.typeIdentifier? // empty' /tmp/xc_${TIMESTAMP}.json)
  if [ "$uti" = "public.png" ]; then
    xcrun xcresulttool export --type file --id "$id" --path "$RESULT_BUNDLE" --output-path "${EXTRACTED_DIR}" >/dev/null 2>&1
    # Try to get the attachment name and rename the file
    name=$(jq -r --arg id "$id" '..|objects?|select(.payloadRef?.id==$id)|.name? // empty' /tmp/xc_${TIMESTAMP}.json | head -1)
    if [ -n "$name" ] && [ -f "${EXTRACTED_DIR}/${id}.png" ]; then
      mv "${EXTRACTED_DIR}/${id}.png" "${EXTRACTED_DIR}/${name}.png" 2>/dev/null || true
      PNG_COUNT=$((PNG_COUNT + 1))
    elif [ -f "${EXTRACTED_DIR}/${id}.png" ]; then
      # If no name found, use a sequential name
      mv "${EXTRACTED_DIR}/${id}.png" "${EXTRACTED_DIR}/screenshot_${PNG_COUNT}.png" 2>/dev/null || true
      PNG_COUNT=$((PNG_COUNT + 1))
    fi
  fi
done

# Zero-screenshot guard
cd "${EXTRACTED_DIR}"
count=$(ls -1 *.png 2>/dev/null | wc -l | xargs)
if [ "${count:-0}" -eq 0 ]; then
  echo -e "${RED}✗ No screenshots found in ${EXTRACTED_DIR}${NC}"
  echo -e "${YELLOW}This could mean:${NC}"
  echo "  - Test didn't run (check compilation)"
  echo "  - Attachments weren't persisted (check .keepAlways)"
  echo "  - Export failed (check result bundle)"
  xcrun simctl status_bar "$TARGET" clear || true
  rm -f /tmp/xc_${TIMESTAMP}.json
  exit 1
fi

# Uniqueness check (content-based)
echo -e "${YELLOW}▶ Verifying screenshot uniqueness...${NC}"
declare -A seen
dup=false
while read -r sum file; do
  if [[ -n "${seen[$sum]:-}" ]]; then
    echo -e "${RED}✗ Duplicate: $(basename "$file") matches $(basename "${seen[$sum]}")${NC}"
    dup=true
  else
    seen[$sum]="$file"
    echo -e "${GREEN}✔ Unique: $(basename "$file")${NC}"
  fi
done < <(shasum -a 256 *.png)

echo ""
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo -e "${YELLOW}▶ Summary${NC}"
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo "Total screenshots: $count"
echo "Unique screenshots: ${#seen[@]}"
echo "Output directory: ${EXTRACTED_DIR}"
echo ""

if $dup; then
  echo -e "${RED}✗ Pipeline failed: duplicates detected${NC}"
  echo -e "${YELLOW}This usually means tab navigation isn't working.${NC}"
  echo -e "${YELLOW}Check that UITEST_MODE prevents tab reset in the app.${NC}"
  xcrun simctl status_bar "$TARGET" clear || true
  rm -f /tmp/xc_${TIMESTAMP}.json
  exit 1
fi

echo -e "${GREEN}✔ Pipeline succeeded: all screenshots unique!${NC}"
open "${EXTRACTED_DIR}" || true

# Reset status bar and cleanup
xcrun simctl status_bar "$TARGET" clear || true
rm -f /tmp/xc_${TIMESTAMP}.json