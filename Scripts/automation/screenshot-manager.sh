#!/bin/bash
#
# Screenshot Manager and Analysis Tool
# Purpose: Manage, organize, and analyze automation screenshots
#

set -euo pipefail

SCREENSHOT_DIR="/Users/griffin/Projects/Nestory/Screenshots"
ANALYSIS_DIR="$SCREENSHOT_DIR/analysis"
ARCHIVE_DIR="$SCREENSHOT_DIR/archive"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Organize screenshots by category
organize_screenshots() {
    log_info "Organizing screenshots by category..."
    
    mkdir -p "$SCREENSHOT_DIR"/{navigation,calibration,coordinate-test,general,archive}
    
    # Move files based on naming pattern
    for file in "$SCREENSHOT_DIR"/*.png; do
        [[ ! -f "$file" ]] && continue
        
        local basename=$(basename "$file")
        local category="general"
        
        case "$basename" in
            *navigation*|*tab*) category="navigation" ;;
            *calibration*) category="calibration" ;;
            *coord-test*|*coordinate*) category="coordinate-test" ;;
            enhanced-*) category="enhanced" ;;
        esac
        
        if [[ "$category" != "general" ]] && [[ "$file" != "$SCREENSHOT_DIR/$category/"* ]]; then
            mkdir -p "$SCREENSHOT_DIR/$category"
            mv "$file" "$SCREENSHOT_DIR/$category/"
            [[ -f "${file}.meta" ]] && mv "${file}.meta" "$SCREENSHOT_DIR/$category/"
            log_success "Moved $(basename "$file") to $category/"
        fi
    done
}

# Generate comparison view of navigation results
generate_comparison() {
    log_info "Generating navigation comparison report..."
    
    local output_file="$ANALYSIS_DIR/navigation-comparison.html"
    mkdir -p "$ANALYSIS_DIR"
    
    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Navigation Comparison Report</title>
    <style>
        body { font-family: -apple-system, sans-serif; margin: 20px; }
        .comparison { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .tab-section { border: 1px solid #ddd; border-radius: 8px; padding: 15px; }
        .tab-section h3 { margin-top: 0; color: #007AFF; }
        .tab-section img { width: 100%; height: auto; border-radius: 4px; }
        .metadata { font-size: 12px; color: #666; margin-top: 10px; }
        .success { border-left: 4px solid #34C759; }
        .warning { border-left: 4px solid #FF9500; }
        .error { border-left: 4px solid #FF3B30; }
    </style>
</head>
<body>
    <h1>📊 Navigation Comparison Report</h1>
    <p>Generated on $(date)</p>
    
    <div class="comparison">
EOF
    
    # Add each tab's results
    local tabs=("inventory" "search" "capture" "analytics" "settings")
    
    for tab in "${tabs[@]}"; do
        local latest_file
        latest_file=$(find "$SCREENSHOT_DIR" -name "*${tab}*" -type f -name "*.png" | sort | tail -1)
        
        if [[ -f "$latest_file" ]]; then
            local status_class="success"
            local basename=$(basename "$latest_file")
            local meta_file="${latest_file}.meta"
            local description="$tab navigation"
            
            if [[ -f "$meta_file" ]]; then
                description=$(jq -r '.description // ""' "$meta_file" 2>/dev/null || echo "$tab navigation")
                local success=$(jq -r '.success // true' "$meta_file" 2>/dev/null || echo "true")
                [[ "$success" == "false" ]] && status_class="error"
            fi
            
            cat >> "$output_file" <<EOF
        <div class="tab-section $status_class">
            <h3>$(echo ${tab^} | sed 's/-/ /')</h3>
            <img src="../$(basename "$latest_file")" alt="$description">
            <div class="metadata">
                File: $basename<br>
                Status: $(echo $status_class | tr '[:lower:]' '[:upper:]')
            </div>
        </div>
EOF
        else
            cat >> "$output_file" <<EOF
        <div class="tab-section error">
            <h3>$(echo ${tab^} | sed 's/-/ /')</h3>
            <p>No screenshot available</p>
            <div class="metadata">Status: MISSING</div>
        </div>
EOF
        fi
    done
    
    cat >> "$output_file" <<EOF
    </div>
</body>
</html>
EOF
    
    log_success "Comparison report generated: file://$output_file"
}

# Clean old screenshots
clean_old_screenshots() {
    local days=${1:-7}
    log_info "Cleaning screenshots older than $days days..."
    
    mkdir -p "$ARCHIVE_DIR"
    
    # Archive old screenshots
    find "$SCREENSHOT_DIR" -name "*.png" -mtime +$days -type f | while read -r file; do
        local archive_date=$(date -r "$file" +%Y-%m)
        local archive_subdir="$ARCHIVE_DIR/$archive_date"
        mkdir -p "$archive_subdir"
        
        mv "$file" "$archive_subdir/"
        [[ -f "${file}.meta" ]] && mv "${file}.meta" "$archive_subdir/"
        log_success "Archived $(basename "$file") to $archive_date/"
    done
    
    # Remove empty directories
    find "$SCREENSHOT_DIR" -type d -empty -delete 2>/dev/null || true
}

# Screenshot statistics
show_statistics() {
    log_info "Screenshot Collection Statistics"
    echo ""
    
    echo "📁 Directory: $SCREENSHOT_DIR"
    echo "📊 Total screenshots: $(find "$SCREENSHOT_DIR" -name "*.png" -type f | wc -l)"
    echo "💾 Total disk usage: $(du -sh "$SCREENSHOT_DIR" 2>/dev/null | cut -f1 || echo "Unknown")"
    echo ""
    
    echo "📂 By Category:"
    for dir in "$SCREENSHOT_DIR"/*/; do
        [[ ! -d "$dir" ]] && continue
        local count=$(find "$dir" -name "*.png" -type f | wc -l)
        local dirname=$(basename "$dir")
        printf "   %-15s %3d screenshots\n" "$dirname:" "$count"
    done
    
    echo ""
    echo "🕐 Recent Activity (last 24 hours):"
    local recent_count
    recent_count=$(find "$SCREENSHOT_DIR" -name "*.png" -type f -newermt "$(date -d '24 hours ago' '+%Y-%m-%d %H:%M:%S')" 2>/dev/null | wc -l || echo "0")
    echo "   Screenshots taken: $recent_count"
    
    echo ""
    echo "🏆 Most Recent Screenshots:"
    find "$SCREENSHOT_DIR" -name "*.png" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -nr | head -5 | while read -r timestamp filepath; do
        local formatted_time=$(date -r "$timestamp" '+%m/%d %H:%M' 2>/dev/null || echo "Unknown")
        local basename=$(basename "$filepath")
        printf "   %s  %s\n" "$formatted_time" "$basename"
    done
}

# Find screenshots by pattern
search_screenshots() {
    local pattern="$1"
    log_info "Searching screenshots matching: $pattern"
    
    find "$SCREENSHOT_DIR" -name "*${pattern}*" -type f | sort | while read -r file; do
        local basename=$(basename "$file")
        local meta_file="${file}.meta"
        local description=""
        
        if [[ -f "$meta_file" ]]; then
            description=$(jq -r '.description // ""' "$meta_file" 2>/dev/null || echo "")
        fi
        
        printf "%-50s %s\n" "$basename" "$description"
    done
}

# Create animated GIF from screenshot sequence
create_animation() {
    local pattern="$1"
    local output="${2:-animation.gif}"
    
    if ! command -v ffmpeg &> /dev/null; then
        log_warning "ffmpeg not found - cannot create animation"
        return 1
    fi
    
    log_info "Creating animation from pattern: $pattern"
    
    # Find matching screenshots in chronological order
    local temp_list="/tmp/screenshot_list.txt"
    find "$SCREENSHOT_DIR" -name "*${pattern}*" -type f -name "*.png" | sort > "$temp_list"
    
    local count=$(wc -l < "$temp_list")
    if [[ $count -eq 0 ]]; then
        log_warning "No screenshots found matching pattern: $pattern"
        return 1
    fi
    
    log_info "Found $count screenshots for animation"
    
    # Create animation using ffmpeg
    ffmpeg -y -f concat -safe 0 -i <(sed 's/^/file /' "$temp_list") -vf "scale=400:-1" -r 1 "$ANALYSIS_DIR/$output" &>/dev/null
    
    if [[ -f "$ANALYSIS_DIR/$output" ]]; then
        log_success "Animation created: $ANALYSIS_DIR/$output"
    else
        log_warning "Animation creation failed"
    fi
    
    rm -f "$temp_list"
}

# Usage information
usage() {
    cat <<EOF
📸 Screenshot Manager and Analysis Tool

USAGE: $0 [command] [options]

COMMANDS:
  organize             Organize screenshots by category
  compare              Generate navigation comparison report  
  stats                Show screenshot statistics
  search PATTERN       Find screenshots matching pattern
  clean [DAYS]         Archive screenshots older than DAYS (default: 7)
  animate PATTERN      Create GIF animation from screenshot sequence
  
EXAMPLES:
  $0 organize                    # Organize all screenshots by type
  $0 stats                       # Show collection statistics  
  $0 search "settings"           # Find all settings screenshots
  $0 clean 14                    # Archive screenshots older than 2 weeks
  $0 animate "navigation"        # Create navigation sequence animation

DIRECTORIES:
  Screenshots: $SCREENSHOT_DIR
  Analysis:    $ANALYSIS_DIR  
  Archive:     $ARCHIVE_DIR
EOF
}

# Main execution
main() {
    case "${1:-}" in
        "organize")
            organize_screenshots
            ;;
        "compare")
            generate_comparison
            ;;
        "stats") 
            show_statistics
            ;;
        "search")
            if [[ -z "${2:-}" ]]; then
                log_warning "Search pattern required"
                usage
                exit 1
            fi
            search_screenshots "$2"
            ;;
        "clean")
            clean_old_screenshots "${2:-7}"
            ;;
        "animate")
            if [[ -z "${2:-}" ]]; then
                log_warning "Pattern required for animation"
                usage
                exit 1
            fi
            create_animation "$2" "${3:-navigation-sequence.gif}"
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"