#!/bin/bash

#
# Unified Runner Monitoring Dashboard
# Monitor both M1 iMac and Raspberry Pi runners
#

set -euo pipefail

# Configuration (use environment variables for security)
IMAC_HOST="${IMAC_HOST:?IMAC_HOST environment variable is required}"
IMAC_USER="${IMAC_USER:-griffin}"
PI_HOST="${PI_HOST:?PI_HOST environment variable is required}"
PI_USER="${PI_USER:-griffin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Get runner status via SSH
get_runner_status() {
    local host=$1
    local user=$2
    
    # Use secure SSH connection with proper host checking
    SSH_OPTS="-o ConnectTimeout=2"
    # SSH keys and host checking should be configured in ~/.ssh/config
    # Example config:
    # Host pi-runner
    #   HostName 100.116.38.90
    #   User griffin  
    #   IdentityFile ~/.ssh/raspberry_pi_key_new
    
    ssh $SSH_OPTS "$user@$host" 2>/dev/null << 'ENDSSH' || echo "offline"
    if [[ -d "$HOME/actions-runner" ]]; then
        cd "$HOME/actions-runner"
        
        # Check if configured
        if [[ ! -f ".runner" ]]; then
            echo "not-configured"
            exit
        fi
        
        # Check service status
        if [[ "$(uname)" == "Darwin" ]]; then
            if ./svc.sh status 2>/dev/null | grep -q "Started"; then
                echo "running"
            else
                echo "stopped"
            fi
        else
            if systemctl is-active --quiet github-runner 2>/dev/null; then
                echo "running"
            else
                echo "stopped"
            fi
        fi
    else
        echo "not-installed"
    fi
ENDSSH
}

# Get system metrics
get_system_metrics() {
    local host=$1
    local user=$2
    
    # Use secure SSH connection with proper host checking
    SSH_OPTS="-o ConnectTimeout=2"
    # SSH keys and host checking should be configured in ~/.ssh/config
    # Example config:
    # Host pi-runner
    #   HostName 100.116.38.90
    #   User griffin  
    #   IdentityFile ~/.ssh/raspberry_pi_key_new
    
    ssh $SSH_OPTS "$user@$host" 2>/dev/null << 'ENDSSH' || echo "N/A|N/A|N/A|N/A"
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS metrics
        CPU=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        MEM=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | sed 's/M.*//')
        DISK=$(df -h / | awk 'NR==2 {print $5}')
        TEMP="N/A"
    else
        # Linux metrics
        CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        MEM=$(free -m | awk 'NR==2{printf "%.1f", $3*100/$2}')
        DISK=$(df -h / | awk 'NR==2 {print $5}')
        TEMP=$(vcgencmd measure_temp 2>/dev/null | sed 's/temp=//' | sed "s/'C/°C/" || echo "N/A")
    fi
    echo "$CPU|$MEM|$DISK|$TEMP"
ENDSSH
}

# Get recent jobs
get_recent_jobs() {
    local host=$1
    local user=$2
    
    # Use secure SSH connection with proper host checking
    SSH_OPTS="-o ConnectTimeout=2"
    # SSH keys and host checking should be configured in ~/.ssh/config
    # Example config:
    # Host pi-runner
    #   HostName 100.116.38.90
    #   User griffin  
    #   IdentityFile ~/.ssh/raspberry_pi_key_new
    
    ssh $SSH_OPTS "$user@$host" 2>/dev/null << 'ENDSSH' || echo "No connection"
    if [[ -d "$HOME/actions-runner/_diag" ]]; then
        cd "$HOME/actions-runner"
        tail -100 _diag/Runner*.log 2>/dev/null | \
            grep -E "Running job:|Job .+ completed" | \
            tail -3 | \
            sed 's/.*Running job: /🔄 /' | \
            sed 's/.*Job \(.*\) completed.*/✅ \1/' || echo "No recent jobs"
    else
        echo "Runner not found"
    fi
ENDSSH
}

# Draw box
draw_box() {
    local title=$1
    local width=${2:-60}
    
    echo -e "${CYAN}┌─${BOLD}$title${NC}${CYAN}$(printf '─%.0s' $(seq $((width - ${#title} - 2))))┐${NC}"
}

draw_box_bottom() {
    local width=${1:-60}
    echo -e "${CYAN}└$(printf '─%.0s' $(seq $((width - 1))))┘${NC}"
}

# Format status with color
format_status() {
    local status=$1
    case "$status" in
        "running")
            echo -e "${GREEN}● Running${NC}"
            ;;
        "stopped")
            echo -e "${YELLOW}● Stopped${NC}"
            ;;
        "offline")
            echo -e "${RED}● Offline${NC}"
            ;;
        "not-installed")
            echo -e "${RED}○ Not Installed${NC}"
            ;;
        "not-configured")
            echo -e "${YELLOW}○ Not Configured${NC}"
            ;;
        *)
            echo -e "${RED}● Unknown${NC}"
            ;;
    esac
}

# Main monitoring loop
monitor_loop() {
    while true; do
        clear
        
        # Header
        echo -e "${BOLD}${BLUE}GitHub Actions Runner Monitor${NC}"
        echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
        echo
        
        # M1 iMac Section
        draw_box " M1 iMac Runner "
        
        IMAC_STATUS=$(get_runner_status "$IMAC_HOST" "$IMAC_USER")
        echo -e "│ Status: $(format_status "$IMAC_STATUS")"
        
        if [[ "$IMAC_STATUS" == "running" ]] || [[ "$IMAC_STATUS" == "stopped" ]]; then
            METRICS=$(get_system_metrics "$IMAC_HOST" "$IMAC_USER")
            IFS='|' read -r CPU MEM DISK TEMP <<< "$METRICS"
            
            echo -e "│ ${BOLD}System:${NC}"
            echo -e "│   CPU:  ${YELLOW}${CPU}%${NC}"
            echo -e "│   Mem:  ${YELLOW}${MEM}%${NC}"
            echo -e "│   Disk: ${YELLOW}${DISK}${NC}"
            
            echo -e "│ ${BOLD}Recent Jobs:${NC}"
            JOBS=$(get_recent_jobs "$IMAC_HOST" "$IMAC_USER")
            while IFS= read -r job; do
                echo -e "│   $job"
            done <<< "$JOBS"
        else
            echo -e "│ ${RED}Runner not available${NC}"
        fi
        
        draw_box_bottom
        echo
        
        # Raspberry Pi Section
        draw_box " Raspberry Pi 5 Runner "
        
        PI_STATUS=$(get_runner_status "$PI_HOST" "$PI_USER")
        echo -e "│ Status: $(format_status "$PI_STATUS")"
        
        if [[ "$PI_STATUS" == "running" ]] || [[ "$PI_STATUS" == "stopped" ]]; then
            METRICS=$(get_system_metrics "$PI_HOST" "$PI_USER")
            IFS='|' read -r CPU MEM DISK TEMP <<< "$METRICS"
            
            echo -e "│ ${BOLD}System:${NC}"
            echo -e "│   CPU:  ${YELLOW}${CPU}%${NC}"
            echo -e "│   Mem:  ${YELLOW}${MEM}%${NC}"
            echo -e "│   Disk: ${YELLOW}${DISK}${NC}"
            echo -e "│   Temp: ${YELLOW}${TEMP}${NC}"
            
            echo -e "│ ${BOLD}Recent Jobs:${NC}"
            JOBS=$(get_recent_jobs "$PI_HOST" "$PI_USER")
            while IFS= read -r job; do
                echo -e "│   $job"
            done <<< "$JOBS"
        else
            echo -e "│ ${RED}Runner not available${NC}"
        fi
        
        draw_box_bottom
        echo
        
        # GitHub API Stats (optional)
        if command -v gh &>/dev/null && gh auth status &>/dev/null; then
            draw_box " GitHub Repository Stats "
            
            # Get workflow runs
            RUNS=$(gh api "/repos/DrunkOnJava/Nestory/actions/runs?per_page=5" --jq '.workflow_runs | length' 2>/dev/null || echo "0")
            QUEUED=$(gh api "/repos/DrunkOnJava/Nestory/actions/runs?status=queued" --jq '.total_count' 2>/dev/null || echo "0")
            
            echo -e "│ Recent Runs: ${CYAN}$RUNS${NC}"
            echo -e "│ Queued Jobs: ${YELLOW}$QUEUED${NC}"
            
            draw_box_bottom
            echo
        fi
        
        # Controls
        echo -e "${BOLD}Controls:${NC}"
        echo "  [r] Refresh now"
        echo "  [s] Start all runners"
        echo "  [t] Stop all runners"
        echo "  [q] Quit"
        echo
        echo -e "${CYAN}Auto-refresh in 10 seconds...${NC}"
        
        # Wait for input or timeout
        read -t 10 -n 1 -s key || true
        
        case "$key" in
            r|R)
                continue
                ;;
            s|S)
                echo "Starting runners..."
                ssh "$IMAC_USER@$IMAC_HOST" "cd ~/actions-runner && ./svc.sh start" 2>/dev/null || true
                ssh "$PI_USER@$PI_HOST" "sudo systemctl start github-runner" 2>/dev/null || true
                sleep 2
                ;;
            t|T)
                echo "Stopping runners..."
                ssh "$IMAC_USER@$IMAC_HOST" "cd ~/actions-runner && ./svc.sh stop" 2>/dev/null || true
                ssh "$PI_USER@$PI_HOST" "sudo systemctl stop github-runner" 2>/dev/null || true
                sleep 2
                ;;
            q|Q)
                echo "Exiting monitor..."
                exit 0
                ;;
        esac
    done
}

# Quick status check (non-interactive)
quick_status() {
    echo -e "${BOLD}${BLUE}GitHub Actions Runner Status${NC}"
    echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo
    
    # M1 iMac
    IMAC_STATUS=$(get_runner_status "$IMAC_HOST" "$IMAC_USER")
    echo -e "${BOLD}M1 iMac:${NC} $(format_status "$IMAC_STATUS")"
    
    # Raspberry Pi
    PI_STATUS=$(get_runner_status "$PI_HOST" "$PI_USER")
    echo -e "${BOLD}Raspberry Pi 5:${NC} $(format_status "$PI_STATUS")"
    
    # Get GitHub API status too
    echo
    echo -e "${BOLD}GitHub Repository Status:${NC}"
    gh api /repos/DrunkOnJava/Nestory/actions/runners --jq '.runners[] | "  \(.name): \(.status)"' 2>/dev/null || echo "  Unable to fetch"
    
    # Summary
    echo
    if [[ "$IMAC_STATUS" == "running" ]] && [[ "$PI_STATUS" == "running" ]]; then
        echo -e "${GREEN}✓ All runners operational${NC}"
    elif [[ "$IMAC_STATUS" == "running" ]] || [[ "$PI_STATUS" == "running" ]]; then
        echo -e "${YELLOW}⚠ Partial runner availability${NC}"
    else
        echo -e "${YELLOW}⚠ Checking runner availability...${NC}"
    fi
}

# Main execution
case "${1:-}" in
    --status)
        quick_status
        ;;
    --help)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --status    Show quick status and exit"
        echo "  --help      Show this help message"
        echo ""
        echo "Without options, runs interactive monitoring dashboard"
        ;;
    *)
        echo -e "${CYAN}Starting runner monitor...${NC}"
        echo "Press Ctrl+C to exit"
        sleep 1
        monitor_loop
        ;;
esac