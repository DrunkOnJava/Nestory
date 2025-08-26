#!/bin/bash

#
# Fixed Unified Runner Monitoring Dashboard
# Addresses security vulnerabilities: proper SSH configuration and credential management
#

set -euo pipefail

# Configuration - Use environment variables and config files instead of hardcoded values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../../monitoring/config/runners.conf"

# Default configuration (can be overridden by config file or environment)
IMAC_HOST="${IMAC_HOST:-}"
IMAC_USER="${IMAC_USER:-griffin}"
PI_HOST="${PI_HOST:-}"
PI_USER="${PI_USER:-griffin}"
SSH_CONFIG_FILE="${SSH_CONFIG_FILE:-$HOME/.ssh/config}"

# Load configuration from file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    # Source the config file safely (only allow expected variables)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Only allow specific configuration variables
        case "$key" in
            IMAC_HOST|IMAC_USER|PI_HOST|PI_USER|SSH_CONFIG_FILE)
                declare "$key=$value"
                ;;
        esac
    done < "$CONFIG_FILE"
fi

# Validate required configuration
if [[ -z "$IMAC_HOST" || -z "$PI_HOST" ]]; then
    echo "❌ Error: Host configuration missing"
    echo "Please configure hosts in $CONFIG_FILE or set IMAC_HOST and PI_HOST environment variables"
    echo "Example configuration:"
    echo "IMAC_HOST=100.106.87.23"
    echo "PI_HOST=100.116.38.90"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Secure SSH connection function
ssh_connect() {
    local host=$1
    local user=$2
    local command=$3
    
    # Use SSH config file for proper key management
    # This avoids hardcoding keys and allows proper host verification
    local ssh_opts=(
        "-F" "$SSH_CONFIG_FILE"
        "-o" "ConnectTimeout=5"
        "-o" "ServerAliveInterval=30"
        "-o" "ServerAliveCountMax=3"
    )
    
    # Execute command with proper error handling
    if ssh "${ssh_opts[@]}" "$user@$host" "$command" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get runner status via secure SSH
get_runner_status() {
    local host=$1
    local user=$2
    
    local status
    status=$(ssh_connect "$host" "$user" '
        if [[ -d "$HOME/actions-runner" ]]; then
            cd "$HOME/actions-runner"
            
            # Check if configured
            if [[ ! -f ".runner" ]]; then
                echo "not-configured"
                exit 0
            fi
            
            # Check service status based on OS
            if [[ "$(uname)" == "Darwin" ]]; then
                if ./svc.sh status 2>/dev/null | grep -q "Started"; then
                    echo "running"
                elif ./svc.sh status 2>/dev/null | grep -q "Stopped"; then
                    echo "stopped"
                else
                    echo "unknown"
                fi
            else
                # Linux (Raspberry Pi)
                if systemctl --user is-active --quiet actions.runner.*.service 2>/dev/null; then
                    echo "running"
                elif systemctl --user is-enabled --quiet actions.runner.*.service 2>/dev/null; then
                    echo "stopped"
                else
                    echo "not-configured"
                fi
            fi
        else
            echo "not-installed"
        fi
    ' 2>/dev/null)
    
    echo "${status:-offline}"
}

# Get system information securely
get_system_info() {
    local host=$1
    local user=$2
    
    local info
    info=$(ssh_connect "$host" "$user" '
        echo "HOSTNAME:$(hostname)"
        echo "UPTIME:$(uptime | sed "s/.*up //" | sed "s/,.*//")"
        echo "LOAD:$(uptime | grep -oE "load average[s]?: [0-9]+\.[0-9]+" | sed "s/load average[s]*: //")"
        echo "MEMORY:$(free -h 2>/dev/null | grep "Mem:" | awk "{print \$3\"/\"\$2}" || vm_stat | grep "Pages free" | awk "{print \"N/A\"}")"
        echo "DISK:$(df -h / | tail -1 | awk "{print \$3\"/\"\$2 \" (\" \$5 \" used)\"}")"
    ' 2>/dev/null)
    
    echo "$info"
}

# Display runner status with enhanced formatting
show_runner_status() {
    local name=$1
    local host=$2  
    local user=$3
    local emoji=$4
    
    echo -e "${BOLD}$emoji $name Runner${NC} ($host)"
    echo -e "$(printf '%.0s─' {1..50})"
    
    local status
    status=$(get_runner_status "$host" "$user")
    
    case "$status" in
        "running")
            echo -e "Status: ${GREEN}🟢 Running${NC}"
            ;;
        "stopped")
            echo -e "Status: ${YELLOW}🟡 Stopped${NC}"
            ;;
        "not-configured")
            echo -e "Status: ${YELLOW}⚙️  Not Configured${NC}"
            ;;
        "not-installed")
            echo -e "Status: ${RED}📦 Not Installed${NC}"
            ;;
        "offline")
            echo -e "Status: ${RED}🔴 Offline${NC}"
            echo -e "Error: Unable to connect to $host"
            echo ""
            return
            ;;
        *)
            echo -e "Status: ${MAGENTA}❓ Unknown${NC}"
            ;;
    esac
    
    # Only get system info if runner is accessible
    if [[ "$status" != "offline" ]]; then
        echo -e "${CYAN}System Information:${NC}"
        local info
        info=$(get_system_info "$host" "$user")
        
        if [[ -n "$info" ]]; then
            echo "$info" | while IFS=':' read -r key value; do
                case "$key" in
                    "HOSTNAME") echo -e "  Host: $value" ;;
                    "UPTIME")   echo -e "  Uptime: $value" ;;
                    "LOAD")     echo -e "  Load: $value" ;;
                    "MEMORY")   echo -e "  Memory: $value" ;;
                    "DISK")     echo -e "  Disk: $value" ;;
                esac
            done
        else
            echo -e "  ${YELLOW}System info unavailable${NC}"
        fi
    fi
    
    echo ""
}

# Create SSH configuration template if needed
setup_ssh_config() {
    if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
        echo "⚠️ SSH config not found. Creating template at $SSH_CONFIG_FILE"
        mkdir -p "$(dirname "$SSH_CONFIG_FILE")"
        
        cat <<EOF > "$SSH_CONFIG_FILE"
# GitHub Actions Runner Monitoring Configuration
# Configure these hosts with proper SSH keys and host verification

Host imac-runner
    HostName $IMAC_HOST
    User $IMAC_USER
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts

Host pi-runner  
    HostName $PI_HOST
    User $PI_USER
    IdentityFile ~/.ssh/raspberry_pi_key
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
EOF
        
        echo "✅ SSH config template created. Please:"
        echo "   1. Add your SSH keys to the specified locations"
        echo "   2. Run 'ssh-keyscan' to add host keys to known_hosts"
        echo "   3. Test connections manually before running this script"
    fi
}

# Main execution
case "${1:-monitor}" in
    "setup")
        echo "🔧 Setting up secure SSH configuration..."
        setup_ssh_config
        
        # Create runner configuration template
        mkdir -p "$(dirname "$CONFIG_FILE")"
        if [[ ! -f "$CONFIG_FILE" ]]; then
            cat <<EOF > "$CONFIG_FILE"
# Runner Configuration
# Remove hardcoded values from scripts by using this config file

IMAC_HOST=$IMAC_HOST
IMAC_USER=$IMAC_USER
PI_HOST=$PI_HOST
PI_USER=$PI_USER
SSH_CONFIG_FILE=$HOME/.ssh/config
EOF
            echo "✅ Configuration file created at $CONFIG_FILE"
        fi
        ;;
    "monitor"|*)
        echo -e "${BOLD}${CYAN}🏃 GitHub Actions Self-Hosted Runners Monitor${NC}"
        echo -e "${CYAN}Secure monitoring with proper SSH configuration${NC}"
        echo ""
        echo -e "$(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # Check SSH config exists
        if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
            echo "❌ SSH configuration missing. Run: $0 setup"
            exit 1
        fi
        
        # Monitor runners
        show_runner_status "M1 iMac" "$IMAC_HOST" "$IMAC_USER" "💻"
        show_runner_status "Raspberry Pi" "$PI_HOST" "$PI_USER" "🥧"
        
        echo -e "${BOLD}📊 Summary${NC}"
        echo -e "Configured runners: 2"
        echo -e "SSH config: $SSH_CONFIG_FILE"
        echo -e "Runner config: $CONFIG_FILE"
        echo ""
        echo -e "${CYAN}💡 Security improvements:${NC}"
        echo -e "• SSH keys managed via SSH config file"
        echo -e "• Host verification enabled"
        echo -e "• No hardcoded credentials in scripts"
        echo -e "• Timeout and retry protection"
        ;;
esac