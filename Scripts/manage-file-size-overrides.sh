#!/bin/bash

# File Size Override Manager for Nestory
# Manages approval overrides for large files

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

OVERRIDE_FILE=".file-size-override"
ERROR_THRESHOLD=600

# Function to display usage
usage() {
    echo "Usage: $0 <command> [file]"
    echo ""
    echo "Commands:"
    echo "  approve <file>    - Approve a large file (requires confirmation)"
    echo "  revoke <file>     - Remove approval for a file"
    echo "  list              - List all approved overrides"
    echo "  check <file>      - Check if a file is approved"
    echo "  audit             - Audit all overrides to see if still needed"
    echo ""
    exit 1
}

# Function to get line count
get_line_count() {
    if [ -f "$1" ]; then
        wc -l < "$1" | tr -d ' '
    else
        echo "0"
    fi
}

# Function to approve a file
approve_file() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File '$file' does not exist${NC}"
        exit 1
    fi
    
    local lines=$(get_line_count "$file")
    
    if [ "$lines" -lt "$ERROR_THRESHOLD" ]; then
        echo -e "${YELLOW}Warning: File has only $lines lines (threshold is $ERROR_THRESHOLD)${NC}"
        echo "This file doesn't need an override yet."
        exit 0
    fi
    
    # Check if already approved
    if [ -f "$OVERRIDE_FILE" ] && grep -q "^$file$" "$OVERRIDE_FILE" 2>/dev/null; then
        echo -e "${YELLOW}File is already approved.${NC}"
        exit 0
    fi
    
    # Show file details and request confirmation
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}⚠️  APPROVAL REQUEST${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "File: $file"
    echo -e "Lines: ${RED}$lines${NC} (exceeds $ERROR_THRESHOLD line threshold)"
    echo ""
    echo "Approving this file will:"
    echo "• Allow builds to proceed despite its size"
    echo "• Add it to the override list"
    echo "• Require future modularization work"
    echo ""
    echo -e "${YELLOW}Please provide a justification for this override:${NC}"
    read -r justification
    
    if [ -z "$justification" ]; then
        echo -e "${RED}Error: Justification is required${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}Are you sure you want to approve this large file? (yes/no):${NC}"
    read -r confirmation
    
    if [ "$confirmation" != "yes" ]; then
        echo "Approval cancelled."
        exit 0
    fi
    
    # Create override file if it doesn't exist
    if [ ! -f "$OVERRIDE_FILE" ]; then
        echo "# File Size Override List" > "$OVERRIDE_FILE"
        echo "# Files listed here are exempted from the 600-line limit" >> "$OVERRIDE_FILE"
        echo "# Format: <file_path> # <date> - <justification>" >> "$OVERRIDE_FILE"
        echo "" >> "$OVERRIDE_FILE"
    fi
    
    # Add the override with metadata
    echo "$file # $(date '+%Y-%m-%d') - $justification" >> "$OVERRIDE_FILE"
    
    echo ""
    echo -e "${GREEN}✅ File approved and added to override list${NC}"
    echo ""
    echo "Note: This override should be temporary. Please plan to modularize this file."
}

# Function to revoke approval
revoke_approval() {
    local file=$1
    
    if [ ! -f "$OVERRIDE_FILE" ]; then
        echo "No overrides exist."
        exit 0
    fi
    
    if grep -q "^$file" "$OVERRIDE_FILE"; then
        # Create temp file without the override
        grep -v "^$file" "$OVERRIDE_FILE" > "$OVERRIDE_FILE.tmp"
        mv "$OVERRIDE_FILE.tmp" "$OVERRIDE_FILE"
        echo -e "${GREEN}✅ Override removed for: $file${NC}"
    else
        echo -e "${YELLOW}File was not in override list: $file${NC}"
    fi
}

# Function to list all overrides
list_overrides() {
    if [ ! -f "$OVERRIDE_FILE" ]; then
        echo "No overrides configured."
        exit 0
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Current File Size Overrides"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^#.*$ ]] || [ -z "$line" ]; then
            continue
        fi
        
        # Extract file and metadata
        file=$(echo "$line" | cut -d'#' -f1 | tr -d ' ')
        metadata=$(echo "$line" | cut -d'#' -f2-)
        
        if [ -f "$file" ]; then
            lines=$(get_line_count "$file")
            echo -e "• ${BLUE}$file${NC} (${RED}$lines lines${NC})"
            echo "  $metadata"
        else
            echo -e "• ${RED}$file${NC} (FILE NOT FOUND)"
            echo "  $metadata"
        fi
        echo ""
    done < "$OVERRIDE_FILE"
}

# Function to check if a file is approved
check_approval() {
    local file=$1
    
    if [ ! -f "$OVERRIDE_FILE" ]; then
        echo -e "${YELLOW}Not approved${NC} (no override file exists)"
        exit 1
    fi
    
    if grep -q "^$file" "$OVERRIDE_FILE"; then
        echo -e "${GREEN}✅ Approved${NC}"
        grep "^$file" "$OVERRIDE_FILE"
        exit 0
    else
        echo -e "${YELLOW}Not approved${NC}"
        exit 1
    fi
}

# Function to audit all overrides
audit_overrides() {
    if [ ! -f "$OVERRIDE_FILE" ]; then
        echo "No overrides to audit."
        exit 0
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Override Audit Report"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    local still_needed=0
    local can_remove=0
    local not_found=0
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^#.*$ ]] || [ -z "$line" ]; then
            continue
        fi
        
        file=$(echo "$line" | cut -d'#' -f1 | tr -d ' ')
        
        if [ ! -f "$file" ]; then
            echo -e "${RED}❌ NOT FOUND:${NC} $file"
            echo "   Can be removed from override list"
            not_found=$((not_found + 1))
        else
            lines=$(get_line_count "$file")
            if [ "$lines" -ge "$ERROR_THRESHOLD" ]; then
                echo -e "${YELLOW}⚠️  STILL NEEDED:${NC} $file ($lines lines)"
                still_needed=$((still_needed + 1))
            else
                echo -e "${GREEN}✅ CAN REMOVE:${NC} $file ($lines lines - now under threshold)"
                can_remove=$((can_remove + 1))
            fi
        fi
    done < "$OVERRIDE_FILE"
    
    echo ""
    echo "Summary:"
    echo "• Still needed: $still_needed"
    echo "• Can be removed: $can_remove"
    echo "• Files not found: $not_found"
    
    if [ $can_remove -gt 0 ] || [ $not_found -gt 0 ]; then
        echo ""
        echo -e "${GREEN}Tip: Run 'make clean-overrides' to remove unnecessary overrides${NC}"
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    approve)
        if [ $# -ne 2 ]; then
            echo "Error: Please specify a file to approve"
            usage
        fi
        approve_file "$2"
        ;;
    revoke)
        if [ $# -ne 2 ]; then
            echo "Error: Please specify a file to revoke"
            usage
        fi
        revoke_approval "$2"
        ;;
    list)
        list_overrides
        ;;
    check)
        if [ $# -ne 2 ]; then
            echo "Error: Please specify a file to check"
            usage
        fi
        check_approval "$2"
        ;;
    audit)
        audit_overrides
        ;;
    *)
        echo "Error: Unknown command '$1'"
        usage
        ;;
esac