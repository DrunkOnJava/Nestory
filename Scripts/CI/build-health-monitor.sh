#!/bin/bash

#
# Build Health Monitoring System
# Complements the error tracking system with health and performance monitoring
# Detects stuck builds, performance degradation, and system issues
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../../monitoring/config/build-health.conf"
METRICS_ENDPOINT="${METRICS_ENDPOINT:-http://localhost:9091}"
LOG_FILE="/tmp/build-health-monitor.log"

# Configuration defaults
CHECK_INTERVAL=30        # Check every 30 seconds
STUCK_THRESHOLD=120      # Consider stuck after 2 minutes without progress
PERFORMANCE_THRESHOLD=300 # Warn if build takes more than 5 minutes
MAX_CONCURRENT_BUILDS=3   # Maximum allowed concurrent builds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Function to send metrics to Pushgateway
send_metric() {
    local metric_name="$1"
    local metric_value="$2"
    local labels="$3"
    local help_text="$4"
    
    cat <<EOF | curl -s --data-binary @- "$METRICS_ENDPOINT/metrics/job/nestory_build_health/instance/$HOSTNAME" || true
# HELP $metric_name $help_text
# TYPE $metric_name gauge
${metric_name}${labels} $metric_value
EOF
}

# Function to check for stuck builds
check_stuck_builds() {
    local stuck_builds=0
    local total_builds=0
    
    # Check for running xcodebuild processes
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            total_builds=$((total_builds + 1))
            
            # Extract PID and start time
            local pid=$(echo "$line" | awk '{print $2}')
            local start_time=$(ps -o lstart= -p "$pid" 2>/dev/null || echo "")
            
            if [[ -n "$start_time" ]]; then
                # Convert to seconds since epoch (macOS compatible)
                local start_epoch=$(date -j -f "%a %b %d %H:%M:%S %Y" "$start_time" +%s 2>/dev/null || echo 0)
                local current_epoch=$(date +%s)
                local duration=$((current_epoch - start_epoch))
                
                # Check if build is stuck (no recent log activity)
                local build_log=$(lsof -p "$pid" 2>/dev/null | grep -E "\.(log|xcactivitylog)" | awk '{print $NF}' | head -1)
                
                if [[ -n "$build_log" && -f "$build_log" ]]; then
                    # Check last modification time of build log
                    local log_mod_time=$(stat -f %m "$build_log" 2>/dev/null || echo 0)
                    local time_since_log_update=$((current_epoch - log_mod_time))
                    
                    if [[ $time_since_log_update -gt $STUCK_THRESHOLD ]]; then
                        stuck_builds=$((stuck_builds + 1))
                        log "${YELLOW}⚠️  Potential stuck build detected: PID $pid (${duration}s running, ${time_since_log_update}s since log update)${NC}"
                        
                        # Send stuck build metric
                        send_metric "nestory_build_stuck_detected" 1 "{pid=\"$pid\",duration=\"$duration\"}" "Stuck build detected"
                        
                        # Optional: Auto-recovery (only if enabled in config)
                        if [[ "${AUTO_RECOVERY_ENABLED:-false}" == "true" && $duration -gt $((STUCK_THRESHOLD * 3)) ]]; then
                            log "${RED}🔄 Auto-recovery: Terminating stuck build PID $pid${NC}"
                            kill -TERM "$pid" 2>/dev/null || true
                            sleep 5
                            kill -KILL "$pid" 2>/dev/null || true
                            
                            send_metric "nestory_build_auto_recovery_total" 1 "{action=\"terminated\",pid=\"$pid\"}" "Auto-recovery actions taken"
                        fi
                    fi
                    
                    # Check for performance issues
                    if [[ $duration -gt $PERFORMANCE_THRESHOLD ]]; then
                        log "${YELLOW}⏱️  Long-running build: PID $pid (${duration}s)${NC}"
                        send_metric "nestory_build_performance_warning" 1 "{pid=\"$pid\",duration=\"$duration\"}" "Long-running build warning"
                    fi
                fi
            fi
        fi
    done < <(ps aux | grep -E "[x]codebuild.*-scheme" | grep -v grep)
    
    # Send overall metrics
    send_metric "nestory_build_concurrent_count" "$total_builds" "{}" "Number of concurrent builds"
    send_metric "nestory_build_stuck_count" "$stuck_builds" "{}" "Number of potentially stuck builds"
    
    # Check for too many concurrent builds
    if [[ $total_builds -gt $MAX_CONCURRENT_BUILDS ]]; then
        log "${RED}⚠️  Too many concurrent builds: $total_builds (max: $MAX_CONCURRENT_BUILDS)${NC}"
        send_metric "nestory_build_concurrent_overload" 1 "{count=\"$total_builds\"}" "Too many concurrent builds"
    fi
}

# Function to check system health
check_system_health() {
    # Check disk space
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    send_metric "nestory_system_disk_usage_percent" "$disk_usage" "{mount=\"/\"}" "Disk usage percentage"
    
    if [[ $disk_usage -gt 85 ]]; then
        log "${YELLOW}⚠️  High disk usage: ${disk_usage}%${NC}"
    fi
    
    # Check memory usage
    local memory_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    if [[ -n "$memory_pressure" ]]; then
        send_metric "nestory_system_memory_free_percent" "$memory_pressure" "{}" "System memory free percentage"
        
        if [[ $memory_pressure -lt 20 ]]; then
            log "${YELLOW}⚠️  Low memory: ${memory_pressure}% free${NC}"
        fi
    fi
    
    # Check load average
    local load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    local cpu_count=$(sysctl -n hw.ncpu)
    local load_per_cpu=$(echo "scale=2; $load_avg / $cpu_count" | bc)
    
    send_metric "nestory_system_load_average" "$load_avg" "{}" "System load average"
    send_metric "nestory_system_load_per_cpu" "$load_per_cpu" "{}" "Load average per CPU"
    
    # Check if load is high
    if (( $(echo "$load_per_cpu > 2.0" | bc -l) )); then
        log "${YELLOW}⚠️  High system load: ${load_avg} (${load_per_cpu} per CPU)${NC}"
    fi
}

# Function to check Xcode health
check_xcode_health() {
    # Check if Xcode is responding
    if pgrep -f "Xcode" > /dev/null; then
        local xcode_pid=$(pgrep -f "Xcode" | head -1)
        local xcode_cpu=$(ps -p "$xcode_pid" -o %cpu= 2>/dev/null | xargs)
        local xcode_mem=$(ps -p "$xcode_pid" -o %mem= 2>/dev/null | xargs)
        
        send_metric "nestory_xcode_cpu_usage_percent" "${xcode_cpu:-0}" "{}" "Xcode CPU usage percentage"
        send_metric "nestory_xcode_memory_usage_percent" "${xcode_mem:-0}" "{}" "Xcode memory usage percentage"
        
        # Check for high resource usage
        if (( $(echo "${xcode_cpu:-0} > 200" | bc -l) )); then
            log "${YELLOW}⚠️  High Xcode CPU usage: ${xcode_cpu}%${NC}"
        fi
        
        if (( $(echo "${xcode_mem:-0} > 10" | bc -l) )); then
            log "${YELLOW}⚠️  High Xcode memory usage: ${xcode_mem}%${NC}"
        fi
        
        send_metric "nestory_xcode_running" 1 "{}" "Xcode is running"
    else
        send_metric "nestory_xcode_running" 0 "{}" "Xcode is running"
    fi
    
    # Check derived data size
    local derived_data_dir="$HOME/Library/Developer/Xcode/DerivedData"
    if [[ -d "$derived_data_dir" ]]; then
        local derived_data_size=$(du -sm "$derived_data_dir" 2>/dev/null | cut -f1)
        send_metric "nestory_xcode_derived_data_size_mb" "${derived_data_size:-0}" "{}" "Xcode DerivedData size in MB"
        
        if [[ ${derived_data_size:-0} -gt 10000 ]]; then  # 10GB
            log "${YELLOW}⚠️  Large DerivedData folder: ${derived_data_size}MB${NC}"
        fi
    fi
}

# Main monitoring function
monitor_build_health() {
    log "${BLUE}🏥 Starting build health monitoring${NC}"
    log "Check interval: ${CHECK_INTERVAL}s"
    log "Stuck threshold: ${STUCK_THRESHOLD}s"
    log "Performance threshold: ${PERFORMANCE_THRESHOLD}s"
    log "Auto-recovery: ${AUTO_RECOVERY_ENABLED:-false}"
    
    while true; do
        {
            check_stuck_builds
            check_system_health
            check_xcode_health
            
            # Send heartbeat
            send_metric "nestory_build_monitor_heartbeat" "$(date +%s)" "{}" "Build monitor heartbeat"
            
        } 2>&1 | while IFS= read -r line; do
            if [[ "$line" =~ ^(\[.*\]|.*⚠️|.*🔄|.*⏱️) ]]; then
                echo "$line"
            fi
        done
        
        sleep "$CHECK_INTERVAL"
    done
}

# Function to show status
show_status() {
    echo -e "${CYAN}📊 Build Health Status${NC}"
    echo "======================="
    
    # Current builds
    local build_count=$(ps aux | grep -E "[x]codebuild.*-scheme" | grep -v grep | wc -l)
    echo -e "Current builds: ${build_count}"
    
    if [[ $build_count -gt 0 ]]; then
        echo -e "\n${YELLOW}Active Builds:${NC}"
        ps aux | grep -E "[x]codebuild.*-scheme" | grep -v grep | while IFS= read -r line; do
            local pid=$(echo "$line" | awk '{print $2}')
            local start_time=$(ps -o lstart= -p "$pid" 2>/dev/null || echo "Unknown")
            local scheme=$(echo "$line" | sed -E 's/.*-scheme ([^ ]+).*/\1/' || echo "Unknown")
            echo "  PID $pid: $scheme (started: $start_time)"
        done
    fi
    
    # System resources
    echo -e "\n${CYAN}System Resources:${NC}"
    echo "  Disk usage: $(df -h / | tail -1 | awk '{print $5}')"
    echo "  Load average: $(uptime | awk '{print $(NF-2)}' | sed 's/,//')"
    
    # Recent issues from log
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "\n${YELLOW}Recent Issues (last 10 minutes):${NC}"
        tail -100 "$LOG_FILE" | grep -E "(⚠️|🔄)" | tail -5 || echo "  No recent issues"
    fi
}

# Usage information
usage() {
    cat <<EOF
Usage: $0 [COMMAND] [OPTIONS]

Build Health Monitoring System

Commands:
    monitor     Start continuous monitoring (default)
    status      Show current build status
    config      Show current configuration
    test        Run a single health check

Options:
    -i SECONDS  Check interval (default: $CHECK_INTERVAL)
    -s SECONDS  Stuck threshold (default: $STUCK_THRESHOLD)
    -p SECONDS  Performance threshold (default: $PERFORMANCE_THRESHOLD)
    -a          Enable auto-recovery
    -h          Show this help

Examples:
    $0 monitor -i 60 -s 180    # Monitor with custom intervals
    $0 status                  # Show current status
    $0 test                    # Run single check

Configuration file: $CONFIG_FILE
Log file: $LOG_FILE
EOF
}

# Parse arguments
COMMAND="monitor"
while [[ $# -gt 0 ]]; do
    case $1 in
        monitor|status|config|test)
            COMMAND="$1"
            shift
            ;;
        -i|--interval)
            CHECK_INTERVAL="$2"
            shift 2
            ;;
        -s|--stuck-threshold)
            STUCK_THRESHOLD="$2"
            shift 2
            ;;
        -p|--performance-threshold)
            PERFORMANCE_THRESHOLD="$2"
            shift 2
            ;;
        -a|--auto-recovery)
            AUTO_RECOVERY_ENABLED=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    monitor)
        monitor_build_health
        ;;
    status)
        show_status
        ;;
    config)
        echo "Current configuration:"
        echo "  Check interval: ${CHECK_INTERVAL}s"
        echo "  Stuck threshold: ${STUCK_THRESHOLD}s"
        echo "  Performance threshold: ${PERFORMANCE_THRESHOLD}s"
        echo "  Auto-recovery: ${AUTO_RECOVERY_ENABLED:-false}"
        echo "  Config file: $CONFIG_FILE"
        echo "  Log file: $LOG_FILE"
        ;;
    test)
        echo "Running single health check..."
        check_stuck_builds
        check_system_health
        check_xcode_health
        echo "Health check completed."
        ;;
    *)
        echo "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac