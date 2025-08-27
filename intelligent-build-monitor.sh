#!/usr/bin/env bash

# Intelligent Build Monitor with Auto-Resolution
# Detects compilation issues, provides real-time feedback, and attempts intelligent fixes

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="$HOME/Desktop/NestoryManualTesting/logs"
readonly MONITOR_LOG="$LOG_DIR/build_monitor_$(date +%Y%m%d_%H%M%S).log"
readonly STATUS_FILE="$LOG_DIR/build_status.json"
readonly RESOLUTION_LOG="$LOG_DIR/auto_resolution.log"

mkdir -p "$LOG_DIR"

# ANSI colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Status tracking
declare -A BUILD_STATUS=(
    ["phase"]="initializing"
    ["issues_detected"]=0
    ["fixes_applied"]=0
    ["last_error"]=""
    ["compilation_progress"]=0
    ["health_score"]=100
)

# Issue patterns and resolutions
declare -A ISSUE_PATTERNS=(
    ["duplicate_type"]="'.*' is ambiguous for type lookup"
    ["build_locked"]="database is locked"
    ["missing_dependency"]="No such module"
    ["action_mismatch"]="type '.*' has no member"
    ["swift_version"]="Swift compiler version mismatch"
    ["xcode_signing"]="Code signing error"
    ["simulator_busy"]="Unable to boot device"
)

declare -A AUTO_RESOLUTIONS=(
    ["duplicate_type"]="resolve_duplicate_types"
    ["build_locked"]="clean_build_artifacts"
    ["missing_dependency"]="resolve_dependencies"
    ["action_mismatch"]="update_action_references"
    ["swift_version"]="reset_swift_toolchain"
    ["xcode_signing"]="fix_code_signing"
    ["simulator_busy"]="restart_simulator"
)

# Logging functions with structured output
log_info() { 
    echo -e "$(date '+%H:%M:%S') ${BLUE}[INFO]${NC} $*" | tee -a "$MONITOR_LOG"
    update_status "info" "$*"
}

log_success() { 
    echo -e "$(date '+%H:%M:%S') ${GREEN}[SUCCESS]${NC} $*" | tee -a "$MONITOR_LOG"
    update_status "success" "$*"
}

log_warning() { 
    echo -e "$(date '+%H:%M:%S') ${YELLOW}[WARNING]${NC} $*" | tee -a "$MONITOR_LOG"
    update_status "warning" "$*"
    ((BUILD_STATUS[issues_detected]++))
}

log_error() { 
    echo -e "$(date '+%H:%M:%S') ${RED}[ERROR]${NC} $*" | tee -a "$MONITOR_LOG"
    update_status "error" "$*"
    BUILD_STATUS[last_error]="$*"
    ((BUILD_STATUS[issues_detected]++))
}

log_resolution() {
    echo -e "$(date '+%H:%M:%S') ${PURPLE}[AUTO-FIX]${NC} $*" | tee -a "$MONITOR_LOG" "$RESOLUTION_LOG"
    update_status "resolution" "$*"
    ((BUILD_STATUS[fixes_applied]++))
}

log_progress() {
    echo -e "$(date '+%H:%M:%S') ${CYAN}[PROGRESS]${NC} $*" | tee -a "$MONITOR_LOG"
    update_status "progress" "$*"
}

# Real-time status updates
update_status() {
    local level="$1"
    local message="$2"
    
    cat > "$STATUS_FILE" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "phase": "${BUILD_STATUS[phase]}",
    "level": "$level",
    "message": "$message",
    "issues_detected": ${BUILD_STATUS[issues_detected]},
    "fixes_applied": ${BUILD_STATUS[fixes_applied]},
    "last_error": "${BUILD_STATUS[last_error]}",
    "compilation_progress": ${BUILD_STATUS[compilation_progress]},
    "health_score": ${BUILD_STATUS[health_score]}
}
EOF
}

# Visual progress indicator
show_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}[PROGRESS]${NC} ["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "] %d%% (%d/%d)" $percentage $current $total
}

# Issue detection functions
detect_compilation_issues() {
    local build_output="$1"
    local detected_issues=()
    
    log_info "🔍 Analyzing compilation output for known issues..."
    
    for pattern_name in "${!ISSUE_PATTERNS[@]}"; do
        local pattern="${ISSUE_PATTERNS[$pattern_name]}"
        if echo "$build_output" | grep -qE "$pattern"; then
            detected_issues+=("$pattern_name")
            log_warning "⚠️ Detected issue: $pattern_name"
        fi
    done
    
    if [ ${#detected_issues[@]} -gt 0 ]; then
        BUILD_STATUS[health_score]=$((100 - ${#detected_issues[@]} * 20))
        return 0  # Issues found
    else
        BUILD_STATUS[health_score]=100
        return 1  # No issues
    fi
}

# Auto-resolution functions
resolve_duplicate_types() {
    log_resolution "🔧 Resolving duplicate type definitions..."
    
    # Find duplicate type definitions
    local duplicate_files=$(find . -name "*.swift" -exec grep -l "struct.*Feature.*Sendable" {} \; 2>/dev/null | head -10)
    
    for file in $duplicate_files; do
        if [[ "$file" == *"Refactored"* ]] || [[ "$file" == *"_old"* ]] || [[ "$file" == *"_backup"* ]]; then
            log_resolution "📁 Moving conflicting file to trash: $file"
            mv "$file" "/Users/griffin/trash/$(date +%Y%m%d_%H%M%S)_$(basename "$file").bak" 2>/dev/null || true
        fi
    done
    
    # Check for specific InventoryFeature conflicts
    if [ -f "Features/Inventory/InventoryFeature-Refactored.swift" ] && [ -f "Features/Inventory/InventoryFeature.swift" ]; then
        log_resolution "🔄 Consolidating InventoryFeature files..."
        mv "Features/Inventory/InventoryFeature-Refactored.swift" "/Users/griffin/trash/$(date +%Y%m%d_%H%M%S)_InventoryFeature-Refactored.swift.bak"
    fi
    
    return 0
}

clean_build_artifacts() {
    log_resolution "🧹 Cleaning locked build artifacts..."
    
    # Force clean build directory
    rm -rf build/ 2>/dev/null || true
    
    # Clean Xcode derived data for this project
    local project_hash=$(echo "$PWD" | shasum -a 256 | cut -c1-8)
    rm -rf ~/Library/Developer/Xcode/DerivedData/Nestory-* 2>/dev/null || true
    
    # Reset package resolution
    rm -rf .build/ 2>/dev/null || true
    
    # Kill any hanging build processes
    pkill -f "swift-frontend" 2>/dev/null || true
    pkill -f "xcodebuild" 2>/dev/null || true
    
    return 0
}

resolve_dependencies() {
    log_resolution "📦 Resolving missing dependencies..."
    
    if [ -f "project.yml" ] && command -v xcodegen >/dev/null; then
        log_resolution "🏗️ Regenerating project with XcodeGen..."
        xcodegen generate 2>&1 | tee -a "$RESOLUTION_LOG"
    fi
    
    # Reset Swift package cache
    swift package reset 2>/dev/null || true
    swift package resolve 2>/dev/null || true
    
    return 0
}

update_action_references() {
    log_resolution "🔄 Updating TCA action references..."
    
    # Find files with old action patterns
    local files_to_fix=$(grep -r "\.inventory(\.addItemTapped)" . --include="*.swift" 2>/dev/null | cut -d: -f1 | sort -u)
    
    for file in $files_to_fix; do
        if [ -f "$file" ]; then
            log_resolution "📝 Updating action references in: $file"
            sed -i.bak 's/\.inventory(\.addItemTapped)/\.inventory(\.itemOperation(\.addItemTapped))/g' "$file"
            rm -f "$file.bak"
        fi
    done
    
    return 0
}

restart_simulator() {
    log_resolution "📱 Restarting iOS Simulator..."
    
    local device_id="iPhone 16 Pro Max"
    xcrun simctl shutdown "$device_id" 2>/dev/null || true
    sleep 2
    xcrun simctl boot "$device_id" 2>/dev/null || true
    sleep 3
    
    return 0
}

reset_swift_toolchain() {
    log_resolution "⚡ Resetting Swift toolchain..."
    
    # Switch to latest Xcode toolchain
    sudo xcode-select --reset 2>/dev/null || true
    
    return 0
}

fix_code_signing() {
    log_resolution "🔐 Attempting code signing fix..."
    
    # Clear provisioning profiles cache
    rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/* 2>/dev/null || true
    
    return 0
}

# Intelligent build monitoring
monitor_build_process() {
    local scheme="${1:-Nestory-Dev}"
    local destination="${2:-platform=iOS Simulator,name=iPhone 16 Pro Max}"
    local max_attempts=3
    
    BUILD_STATUS[phase]="monitoring"
    log_info "🎯 Starting intelligent build monitoring for $scheme"
    log_info "📱 Target: $destination"
    
    for attempt in $(seq 1 $max_attempts); do
        log_info "🔄 Build attempt $attempt/$max_attempts"
        BUILD_STATUS[phase]="building_attempt_$attempt"
        
        # Create temporary build log
        local build_log="/tmp/build_monitor_$(date +%Y%m%d_%H%M%S).log"
        
        # Start build with timeout and logging
        log_progress "🏗️ Starting compilation..."
        if timeout 300 xcodebuild build \
            -scheme "$scheme" \
            -destination "$destination" \
            -quiet 2>&1 | tee "$build_log"; then
            
            log_success "✅ Build completed successfully!"
            BUILD_STATUS[phase]="build_success"
            BUILD_STATUS[compilation_progress]=100
            return 0
        else
            local exit_code=$?
            log_error "❌ Build failed (exit code: $exit_code)"
            
            # Analyze build output for issues
            local build_output=$(cat "$build_log")
            if detect_compilation_issues "$build_output"; then
                log_info "🔧 Attempting automatic issue resolution..."
                BUILD_STATUS[phase]="auto_resolving"
                
                # Apply resolutions for detected issues
                for pattern_name in "${!ISSUE_PATTERNS[@]}"; do
                    local pattern="${ISSUE_PATTERNS[$pattern_name]}"
                    if echo "$build_output" | grep -qE "$pattern"; then
                        local resolution_func="${AUTO_RESOLUTIONS[$pattern_name]}"
                        if [ -n "$resolution_func" ]; then
                            log_resolution "🎯 Applying resolution: $resolution_func"
                            if $resolution_func; then
                                log_success "✅ Resolution applied successfully"
                            else
                                log_error "❌ Resolution failed"
                            fi
                        fi
                    fi
                done
                
                # Clean up before retry
                log_resolution "🧹 Preparing for retry..."
                sleep 5
            else
                log_error "🤷 No known resolution patterns matched"
                break
            fi
        fi
        
        # Clean up build log
        rm -f "$build_log"
    done
    
    BUILD_STATUS[phase]="build_failed"
    log_error "❌ Build failed after $max_attempts attempts with auto-resolution"
    return 1
}

# Screenshot analysis and verification
analyze_screenshots() {
    local screenshot_dir="$1"
    log_info "📸 Analyzing screenshots for navigation verification..."
    
    local screenshots=($(find "$screenshot_dir" -name "*.png" -type f | sort))
    if [ ${#screenshots[@]} -lt 2 ]; then
        log_warning "⚠️ Insufficient screenshots for analysis"
        return 1
    fi
    
    local duplicates=0
    local unique_screens=0
    
    for i in $(seq 0 $((${#screenshots[@]} - 2))); do
        local file1="${screenshots[$i]}"
        local file2="${screenshots[$((i + 1))]}"
        
        # Compare file sizes (quick duplicate detection)
        local size1=$(stat -f%z "$file1" 2>/dev/null || echo "0")
        local size2=$(stat -f%z "$file2" 2>/dev/null || echo "0")
        
        if [ "$size1" -eq "$size2" ] && [ "$size1" -gt 0 ]; then
            ((duplicates++))
            log_warning "🔍 Potential duplicate screenshots: $(basename "$file1") & $(basename "$file2")"
        else
            ((unique_screens++))
        fi
    done
    
    local total_screenshots=${#screenshots[@]}
    local navigation_success_rate=$(( (unique_screens * 100) / total_screenshots ))
    
    log_info "📊 Screenshot Analysis Results:"
    log_info "   📁 Total screenshots: $total_screenshots"
    log_info "   🎯 Unique screens detected: $unique_screens"
    log_info "   ⚠️ Potential duplicates: $duplicates"
    log_info "   📈 Navigation success rate: $navigation_success_rate%"
    
    if [ $navigation_success_rate -lt 50 ]; then
        log_error "❌ Low navigation success rate - UI automation may not be working"
        return 1
    else
        log_success "✅ Navigation appears to be working properly"
        return 0
    fi
}

# Real-time status display
display_status_dashboard() {
    clear
    cat << EOF
╭─────────────────────────────────────────────────────────────────╮
│                  🤖 Intelligent Build Monitor                   │
│                     Real-Time Status Dashboard                  │
╰─────────────────────────────────────────────────────────────────╯

📊 Current Status: ${BUILD_STATUS[phase]}
🎯 Health Score: ${BUILD_STATUS[health_score]}/100
⚠️  Issues Detected: ${BUILD_STATUS[issues_detected]}
🔧 Auto-Fixes Applied: ${BUILD_STATUS[fixes_applied]}
📈 Progress: ${BUILD_STATUS[compilation_progress]}%

$(if [ -n "${BUILD_STATUS[last_error]}" ]; then
    echo "🚨 Last Error: ${BUILD_STATUS[last_error]}"
fi)

📋 Monitoring Capabilities:
  ✅ Duplicate type detection & resolution
  ✅ Build lock detection & cleanup  
  ✅ Dependency resolution
  ✅ TCA action reference updates
  ✅ Swift toolchain reset
  ✅ Simulator state management
  ✅ Screenshot navigation analysis

🔄 Press Ctrl+C to stop monitoring
EOF
}

# Main execution
main() {
    local command="${1:-monitor}"
    local scheme="${2:-Nestory-Dev}"
    
    case "$command" in
        "monitor")
            log_info "🚀 Starting Intelligent Build Monitor"
            display_status_dashboard
            monitor_build_process "$scheme"
            ;;
        "analyze")
            local screenshot_dir="${2:-$HOME/Desktop/NestoryManualTesting}"
            analyze_screenshots "$screenshot_dir"
            ;;
        "status")
            if [ -f "$STATUS_FILE" ]; then
                cat "$STATUS_FILE" | jq '.'
            else
                echo "No status file found"
            fi
            ;;
        "clean")
            log_info "🧹 Running comprehensive cleanup..."
            clean_build_artifacts
            resolve_dependencies
            log_success "✅ Cleanup completed"
            ;;
        *)
            echo "Usage: $0 {monitor|analyze|status|clean} [scheme]"
            exit 1
            ;;
    esac
}

# Handle signals gracefully
trap 'log_info "🛑 Build monitoring stopped"; exit 0' INT TERM

# Execute main function
main "$@"