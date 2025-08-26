#!/bin/bash

# Dynamic Build Path Detection
# Automatically detects where Xcode stores build logs for this project

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="Nestory.xcodeproj"

# Function to detect build paths dynamically
detect_build_paths() {
    local scheme="${1:-Nestory-Dev}"
    
    echo "🔍 Detecting build paths for scheme: $scheme"
    
    # Get build settings from xcodebuild
    local build_settings=$(xcodebuild -project "$PROJECT_FILE" -scheme "$scheme" -showBuildSettings 2>/dev/null | grep -E "BUILD_ROOT|BUILD_DIR|DERIVED_DATA|OBJROOT")
    
    # Extract actual paths
    local build_root=$(echo "$build_settings" | grep "BUILD_ROOT" | head -1 | sed 's/.*= //')
    local build_dir=$(echo "$build_settings" | grep "BUILD_DIR" | head -1 | sed 's/.*= //')
    local objroot=$(echo "$build_settings" | grep "OBJROOT" | head -1 | sed 's/.*= //')
    
    echo "BUILD_ROOT: $build_root"
    echo "BUILD_DIR: $build_dir"
    echo "OBJROOT: $objroot"
    
    # Find potential log locations
    echo ""
    echo "🔍 Searching for existing build logs..."
    
    # Search in build directory
    if [[ -n "$build_root" ]] && [[ -d "$build_root" ]]; then
        echo "Searching in BUILD_ROOT: $build_root"
        find "$build_root" -name "*.xcactivitylog" -o -name "*.xcresult" 2>/dev/null | head -5 || true
    fi
    
    # Search in project build directory
    if [[ -d "$PROJECT_ROOT/build" ]]; then
        echo "Searching in project build: $PROJECT_ROOT/build"
        find "$PROJECT_ROOT/build" -name "*.xcactivitylog" -o -name "*.xcresult" 2>/dev/null | head -5 || true
    fi
    
    # Search in standard DerivedData
    if [[ -d "$HOME/Library/Developer/Xcode/DerivedData" ]]; then
        echo "Searching in DerivedData: $HOME/Library/Developer/Xcode/DerivedData"
        find "$HOME/Library/Developer/Xcode/DerivedData" -name "*.xcactivitylog" -o -name "*.xcresult" 2>/dev/null | head -5 || true
    fi
    
    # Output in format suitable for sourcing
    echo ""
    echo "🎯 Detected paths (export format):"
    echo "export PROJECT_BUILD_ROOT='$build_root'"
    echo "export PROJECT_BUILD_DIR='$build_dir'"
    echo "export PROJECT_ROOT='$PROJECT_ROOT'"
}

# Function to get all possible log directories
get_log_directories() {
    local scheme="${1:-Nestory-Dev}"
    
    # Get build settings
    local build_settings=$(xcodebuild -project "$PROJECT_FILE" -scheme "$scheme" -showBuildSettings 2>/dev/null)
    local build_root=$(echo "$build_settings" | grep "BUILD_ROOT" | head -1 | sed 's/.*= //')
    
    # Return array of potential log directories
    local log_dirs=()
    
    if [[ -n "$build_root" ]] && [[ -d "$build_root" ]]; then
        log_dirs+=("$build_root/../..")
        log_dirs+=("$(dirname "$build_root")")
    fi
    
    log_dirs+=("$PROJECT_ROOT/build")
    log_dirs+=("$PROJECT_ROOT/.build")
    log_dirs+=("$HOME/Library/Developer/Xcode/DerivedData")
    
    # Print unique directories that exist
    printf '%s\n' "${log_dirs[@]}" | sort -u | while read dir; do
        if [[ -d "$dir" ]]; then
            echo "$dir"
        fi
    done
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cd "$PROJECT_ROOT"
    
    case "${1:-detect}" in
        detect)
            detect_build_paths "${2:-Nestory-Dev}"
            ;;
        dirs)
            get_log_directories "${2:-Nestory-Dev}"
            ;;
        *)
            echo "Usage: $0 [detect|dirs] [scheme]"
            echo "  detect: Show detailed build path detection"
            echo "  dirs:   List directories to monitor for logs"
            ;;
    esac
fi