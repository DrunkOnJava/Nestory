#!/bin/bash

# File Size Monitor for Nestory
# Enforces modularization by warning about large files
# Thresholds: 400 lines (warning), 500 lines (critical), 600 lines (error)

set -e

# Color codes for output
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD_RED='\033[1;31m'
NC='\033[0m' # No Color

# Configuration
WARNING_THRESHOLD=400
CRITICAL_THRESHOLD=500
ERROR_THRESHOLD=600
OVERRIDE_FILE=".file-size-override"

# Counters
warning_count=0
critical_count=0
error_count=0
total_files=0

# Arrays to store problematic files
declare -a warning_files
declare -a critical_files
declare -a error_files

# Function to check if a file is overridden
is_overridden() {
    local file=$1
    if [ -f "$OVERRIDE_FILE" ]; then
        grep -q "^$file$" "$OVERRIDE_FILE" 2>/dev/null && return 0
    fi
    return 1
}

# Function to get line count
get_line_count() {
    wc -l < "$1" | tr -d ' '
}

# Header
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📏 Nestory File Size Monitor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Checking Swift files for size violations..."
echo "Thresholds: ⚠️  $WARNING_THRESHOLD lines | 🚨 $CRITICAL_THRESHOLD lines | ❌ $ERROR_THRESHOLD lines"
echo ""

# Find all Swift files excluding generated and third-party code
while IFS= read -r file; do
    # Skip if file doesn't exist (edge case)
    [ ! -f "$file" ] && continue
    
    total_files=$((total_files + 1))
    lines=$(get_line_count "$file")
    
    # Get relative path for cleaner output
    rel_file="${file#./}"
    
    if [ "$lines" -ge "$ERROR_THRESHOLD" ]; then
        if is_overridden "$rel_file"; then
            echo -e "${ORANGE}⚠️  OVERRIDDEN:${NC} $rel_file (${BOLD_RED}$lines lines${NC}) - Exceeds error threshold but approved"
        else
            error_files+=("$rel_file:$lines")
            error_count=$((error_count + 1))
            echo -e "${BOLD_RED}❌ ERROR:${NC} $rel_file (${BOLD_RED}$lines lines${NC}) - MUST be modularized!"
        fi
    elif [ "$lines" -ge "$CRITICAL_THRESHOLD" ]; then
        critical_files+=("$rel_file:$lines")
        critical_count=$((critical_count + 1))
        echo -e "${RED}🚨 CRITICAL:${NC} $rel_file (${RED}$lines lines${NC}) - Should be modularized soon"
    elif [ "$lines" -ge "$WARNING_THRESHOLD" ]; then
        warning_files+=("$rel_file:$lines")
        warning_count=$((warning_count + 1))
        echo -e "${YELLOW}⚠️  WARNING:${NC} $rel_file (${YELLOW}$lines lines${NC}) - Consider modularizing"
    fi
done < <(find . -name "*.swift" \
    -not -path "./build/*" \
    -not -path "./.build/*" \
    -not -path "./DerivedData/*" \
    -not -path "./Pods/*" \
    -not -path "./Carthage/*" \
    -not -path "./vendor/*" \
    -not -path "./.swiftpm/*" \
    -not -path "./DevTools/*" \
    -not -path "*/.build/*" \
    -not -name "*.generated.swift" \
    -not -name "*.gen.swift" \
    -type f)

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total Swift files scanned: $total_files"
echo ""

# Display detailed summary if issues found
if [ $warning_count -gt 0 ] || [ $critical_count -gt 0 ] || [ $error_count -gt 0 ]; then
    if [ $warning_count -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Warnings: $warning_count files (400-499 lines)${NC}"
        for file_info in "${warning_files[@]}"; do
            IFS=':' read -r file lines <<< "$file_info"
            echo "   • $file ($lines lines)"
        done
        echo ""
    fi
    
    if [ $critical_count -gt 0 ]; then
        echo -e "${RED}🚨 Critical: $critical_count files (500-599 lines)${NC}"
        for file_info in "${critical_files[@]}"; do
            IFS=':' read -r file lines <<< "$file_info"
            echo "   • $file ($lines lines)"
        done
        echo ""
    fi
    
    if [ $error_count -gt 0 ]; then
        echo -e "${BOLD_RED}❌ Errors: $error_count files (600+ lines)${NC}"
        for file_info in "${error_files[@]}"; do
            IFS=':' read -r file lines <<< "$file_info"
            echo "   • $file ($lines lines)"
        done
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${BOLD_RED}🛑 BUILD BLOCKED:${NC} Files exceeding 600 lines detected!"
        echo ""
        echo "Options:"
        echo "1. Modularize the file(s) into smaller components"
        echo "2. Request override approval by running:"
        echo "   ${YELLOW}make approve-large-file FILE=path/to/file.swift${NC}"
        echo ""
        echo "Overrides are tracked in: $OVERRIDE_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
else
    echo -e "${GREEN}✅ All files are within acceptable size limits!${NC}"
    echo "   No files exceed $WARNING_THRESHOLD lines."
fi

echo ""

# Exit codes
if [ $error_count -gt 0 ]; then
    exit 1  # Block build
elif [ $critical_count -gt 0 ]; then
    exit 0  # Allow build but with critical warnings
else
    exit 0  # All good or only warnings
fi