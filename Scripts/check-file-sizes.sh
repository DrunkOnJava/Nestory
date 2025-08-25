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
# Higher thresholds for dependency/vendor code
DEPENDENCY_WARNING_THRESHOLD=800
DEPENDENCY_CRITICAL_THRESHOLD=1500
DEPENDENCY_ERROR_THRESHOLD=3000
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

# Function to check if a file is a dependency/vendor file
is_dependency_file() {
    local file=$1
    case "$file" in
        # Third-party dependencies and package sources
        tca-composer/*|swift-composable-architecture/*|vendor/*|Pods/*|Carthage/*|\.swiftpm/*|*/.build/*)
            return 0
            ;;
        # Generated or external code
        *.generated.swift|*.gen.swift)
            return 0
            ;;
        # Package manager files
        *Package.swift)
            return 0
            ;;
        # Any third-party Swift package
        */Sources/*|*/Tests/*)
            # Check if it's in a subdirectory that looks like a package
            if [[ "$file" =~ ^[^/]+/(Sources|Tests)/ ]]; then
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to check if a file is overridden
is_overridden() {
    local file=$1
    if [ -f "$OVERRIDE_FILE" ]; then
        # Check for exact match or match at beginning of line (before comments)
        grep -q "^$file\(\$\|[[:space:]]*#\)" "$OVERRIDE_FILE" 2>/dev/null && return 0
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
echo "Project code thresholds: ⚠️  $WARNING_THRESHOLD lines | 🚨 $CRITICAL_THRESHOLD lines | ❌ $ERROR_THRESHOLD lines"
echo "Dependency code thresholds: ⚠️  $DEPENDENCY_WARNING_THRESHOLD lines | 🚨 $DEPENDENCY_CRITICAL_THRESHOLD lines | ❌ $DEPENDENCY_ERROR_THRESHOLD lines"
echo ""

# Find all Swift files excluding generated and third-party code
while IFS= read -r file; do
    # Skip if file doesn't exist (edge case)
    [ ! -f "$file" ] && continue
    
    total_files=$((total_files + 1))
    lines=$(get_line_count "$file")
    
    # Get relative path for cleaner output
    rel_file="${file#./}"
    
    # Determine if this is a dependency file and set appropriate thresholds
    if is_dependency_file "$rel_file"; then
        local_warning_threshold=$DEPENDENCY_WARNING_THRESHOLD
        local_critical_threshold=$DEPENDENCY_CRITICAL_THRESHOLD
        local_error_threshold=$DEPENDENCY_ERROR_THRESHOLD
        file_type="dependency"
    else
        local_warning_threshold=$WARNING_THRESHOLD
        local_critical_threshold=$CRITICAL_THRESHOLD
        local_error_threshold=$ERROR_THRESHOLD
        file_type="project"
    fi
    
    if [ "$lines" -ge "$local_error_threshold" ]; then
        if is_overridden "$rel_file"; then
            echo -e "${ORANGE}⚠️  OVERRIDDEN:${NC} $rel_file (${BOLD_RED}$lines lines${NC}) - Exceeds $file_type error threshold but approved"
        else
            error_files+=("$rel_file:$lines:$file_type")
            error_count=$((error_count + 1))
            echo -e "${BOLD_RED}❌ ERROR:${NC} $rel_file (${BOLD_RED}$lines lines${NC}) - $file_type file MUST be modularized!"
        fi
    elif [ "$lines" -ge "$local_critical_threshold" ]; then
        critical_files+=("$rel_file:$lines:$file_type")
        critical_count=$((critical_count + 1))
        echo -e "${RED}🚨 CRITICAL:${NC} $rel_file (${RED}$lines lines${NC}) - $file_type file should be modularized soon"
    elif [ "$lines" -ge "$local_warning_threshold" ]; then
        warning_files+=("$rel_file:$lines:$file_type")
        warning_count=$((warning_count + 1))
        echo -e "${YELLOW}⚠️  WARNING:${NC} $rel_file (${YELLOW}$lines lines${NC}) - $file_type file consider modularizing"
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
        echo -e "${YELLOW}⚠️  Warnings: $warning_count files${NC}"
        for file_info in "${warning_files[@]}"; do
            IFS=':' read -r file lines file_type <<< "$file_info"
            echo "   • $file ($lines lines, $file_type)"
        done
        echo ""
    fi
    
    if [ $critical_count -gt 0 ]; then
        echo -e "${RED}🚨 Critical: $critical_count files${NC}"
        for file_info in "${critical_files[@]}"; do
            IFS=':' read -r file lines file_type <<< "$file_info"
            echo "   • $file ($lines lines, $file_type)"
        done
        echo ""
    fi
    
    if [ $error_count -gt 0 ]; then
        echo -e "${BOLD_RED}❌ Errors: $error_count files${NC}"
        for file_info in "${error_files[@]}"; do
            IFS=':' read -r file lines file_type <<< "$file_info"
            echo "   • $file ($lines lines, $file_type)"
        done
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${BOLD_RED}🛑 BUILD BLOCKED:${NC} Files exceeding size thresholds detected!"
        echo ""
        echo "Thresholds: Project files: 600 lines | Dependency files: 3000 lines"
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