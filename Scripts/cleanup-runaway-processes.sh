#!/bin/bash

#
# Comprehensive Process Cleanup Script
# Prevents and cleans up runaway Ruby/fastlane processes
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
MAX_RUBY_PROCESSES=${MAX_RUBY_PROCESSES:-5}
MAX_XCODEBUILD_PROCESSES=${MAX_XCODEBUILD_PROCESSES:-3}
PID_DIR="/tmp"

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
}

success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] SUCCESS:${NC} $1"
}

# Check if process is running
is_process_running() {
    local pid=$1
    kill -0 "$pid" 2>/dev/null
}

# Get process count for a pattern
count_processes() {
    local pattern=$1
    pgrep -f "$pattern" | wc -l
}

# Kill processes with grace period
kill_processes_gracefully() {
    local pattern=$1
    local description=$2
    
    local pids
    pids=$(pgrep -f "$pattern" 2>/dev/null || true)
    
    if [[ -z "$pids" ]]; then
        log "No $description processes found"
        return 0
    fi
    
    log "Found $description processes: $(echo $pids | wc -w)"
    
    # Send SIGTERM first
    for pid in $pids; do
        if is_process_running "$pid"; then
            log "  Sending SIGTERM to PID $pid"
            kill -TERM "$pid" 2>/dev/null || true
        fi
    done
    
    # Wait 5 seconds
    sleep 5
    
    # Send SIGKILL to any remaining processes
    for pid in $pids; do
        if is_process_running "$pid"; then
            warn "  Process $pid still running, sending SIGKILL"
            kill -KILL "$pid" 2>/dev/null || true
        fi
    done
    
    # Verify cleanup
    local remaining
    remaining=$(pgrep -f "$pattern" 2>/dev/null || true)
    if [[ -z "$remaining" ]]; then
        success "All $description processes cleaned up"
    else
        error "Some $description processes still running: $remaining"
        return 1
    fi
}

# Clean up specific runaway processes
cleanup_runaway_ruby_processes() {
    log "🧹 Cleaning up runaway Ruby processes..."
    
    local ruby_count
    ruby_count=$(count_processes "ruby.*fastlane")
    
    if [[ $ruby_count -gt $MAX_RUBY_PROCESSES ]]; then
        warn "Found $ruby_count Ruby/fastlane processes (max: $MAX_RUBY_PROCESSES)"
        kill_processes_gracefully "ruby.*fastlane" "Ruby/fastlane"
    else
        log "Ruby process count OK: $ruby_count (max: $MAX_RUBY_PROCESSES)"
    fi
}

cleanup_runaway_xcodebuild_processes() {
    log "🧹 Cleaning up runaway xcodebuild processes..."
    
    local xcodebuild_count
    xcodebuild_count=$(count_processes "xcodebuild")
    
    if [[ $xcodebuild_count -gt $MAX_XCODEBUILD_PROCESSES ]]; then
        warn "Found $xcodebuild_count xcodebuild processes (max: $MAX_XCODEBUILD_PROCESSES)"
        kill_processes_gracefully "xcodebuild" "xcodebuild"
    else
        log "xcodebuild process count OK: $xcodebuild_count (max: $MAX_XCODEBUILD_PROCESSES)"
    fi
}

cleanup_ios_simulator_processes() {
    log "🧹 Cleaning up iOS Simulator processes..."
    
    # Clean up stuck simulator processes
    kill_processes_gracefully "iOS.*simruntime" "iOS simruntime"
    kill_processes_gracefully "com\.apple\.CoreSimulator" "CoreSimulator"
    
    # Shutdown all simulators
    log "Shutting down all iOS simulators..."
    xcrun simctl shutdown all 2>/dev/null || true
}

cleanup_monitoring_processes() {
    log "🧹 Cleaning up monitoring processes..."
    
    # Kill any stuck monitoring scripts
    kill_processes_gracefully "xcode-build-monitor" "build monitor"
    kill_processes_gracefully "fswatch" "fswatch"
}

cleanup_pid_files() {
    log "🧹 Cleaning up PID files..."
    
    # Remove stale PID files
    find "$PID_DIR" -name "fastlane_*.pid" -type f -delete 2>/dev/null || true
    find "$PID_DIR" -name "xcode-monitor-*.pid" -type f -delete 2>/dev/null || true
    
    success "PID files cleaned up"
}

# Install cleanup as a scheduled job
install_cleanup_cron() {
    log "📅 Installing cleanup cron job..."
    
    local cron_command="*/30 * * * * $PWD/$0 --auto >/dev/null 2>&1"
    
    # Check if already installed
    if crontab -l 2>/dev/null | grep -q "cleanup-runaway-processes"; then
        log "Cleanup cron job already installed"
        return 0
    fi
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$cron_command") | crontab -
    success "Cleanup cron job installed (runs every 30 minutes)"
}

# Show process summary
show_process_summary() {
    log "📊 Current Process Summary:"
    echo "  Ruby/fastlane: $(count_processes 'ruby.*fastlane')"
    echo "  xcodebuild: $(count_processes 'xcodebuild')"
    echo "  iOS simulators: $(count_processes 'iOS.*simruntime')"
    echo "  Build monitors: $(count_processes 'xcode-build-monitor')"
    echo "  fswatch: $(count_processes 'fswatch')"
}

# Emergency cleanup - kill everything aggressively
emergency_cleanup() {
    warn "🚨 EMERGENCY CLEANUP - Killing all development processes!"
    
    # Kill all Ruby processes
    killall -9 ruby 2>/dev/null || true
    
    # Kill all xcodebuild processes
    killall -9 xcodebuild 2>/dev/null || true
    
    # Kill all simulators
    killall -9 "iOS Simulator" 2>/dev/null || true
    killall -9 "Simulator" 2>/dev/null || true
    xcrun simctl shutdown all 2>/dev/null || true
    
    # Kill monitoring processes
    killall -9 fswatch 2>/dev/null || true
    pkill -9 -f "xcode-build-monitor" 2>/dev/null || true
    
    # Clean up PID files
    cleanup_pid_files
    
    success "Emergency cleanup completed"
}

# Main function
main() {
    case "${1:-cleanup}" in
        "cleanup"|"--auto")
            log "🧹 Starting automatic process cleanup..."
            cleanup_runaway_ruby_processes
            cleanup_runaway_xcodebuild_processes
            cleanup_ios_simulator_processes
            cleanup_monitoring_processes
            cleanup_pid_files
            show_process_summary
            success "Process cleanup completed"
            ;;
        "emergency")
            emergency_cleanup
            ;;
        "status")
            show_process_summary
            ;;
        "install-cron")
            install_cleanup_cron
            ;;
        "help"|"-h"|"--help")
            echo "Runaway Process Cleanup Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  cleanup     - Normal cleanup (default)"
            echo "  emergency   - Emergency cleanup (kills everything)"
            echo "  status      - Show process summary"
            echo "  install-cron- Install as cron job"
            echo "  help        - Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  MAX_RUBY_PROCESSES      - Max Ruby processes before cleanup (default: 5)"
            echo "  MAX_XCODEBUILD_PROCESSES- Max xcodebuild processes before cleanup (default: 3)"
            ;;
        *)
            error "Unknown command: $1"
            $0 help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"