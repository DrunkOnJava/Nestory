#!/bin/bash

#
# Remote GitHub Actions Runner Deployment Script
# Deploy runners to M1 iMac and/or Raspberry Pi via SSH
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration (Tailscale IPs)
IMAC_HOST="${IMAC_HOST:-100.106.87.23}"  # M1 iMac via Tailscale
IMAC_USER="${IMAC_USER:-griffin}"
PI_HOST="${PI_HOST:-100.116.38.90}"      # Raspberry Pi 5 via Tailscale
PI_USER="${PI_USER:-griffin}"

# Script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_SCRIPT="setup-github-runner-macos.sh"
PI_SCRIPT="setup-github-runner-pi.sh"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_action() { echo -e "${MAGENTA}[ACTION]${NC} $1"; }

# Header
show_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}        Remote GitHub Actions Runner Deployment Tool            ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Function to check SSH connectivity
check_ssh_connection() {
    local host=$1
    local user=$2
    local name=$3
    
    log_info "Checking SSH connection to $name ($user@$host)..."
    
    if ssh -o ConnectTimeout=5 -o ConnectTimeout=10 "$user@$host" "echo 'Connected'" &>/dev/null; then
        log_success "Successfully connected to $name"
        return 0
    else
        log_error "Failed to connect to $name"
        return 1
    fi
}

# Function to deploy to macOS (M1 iMac)
deploy_to_macos() {
    log_action "Deploying GitHub Actions runner to M1 iMac..."
    
    # Check connection
    if ! check_ssh_connection "$IMAC_HOST" "$IMAC_USER" "M1 iMac"; then
        log_error "Cannot deploy to M1 iMac - SSH connection failed"
        return 1
    fi
    
    # Copy setup script
    log_info "Copying setup script to M1 iMac..."
    scp "$SCRIPT_DIR/$MACOS_SCRIPT" "$IMAC_USER@$IMAC_HOST:/tmp/"
    
    # Execute setup script remotely
    log_info "Executing setup script on M1 iMac..."
    ssh "$IMAC_USER@$IMAC_HOST" << 'ENDSSH'
    # Make script executable
    chmod +x /tmp/setup-github-runner-macos.sh
    
    # Set runner name
    export RUNNER_NAME="nestory-m1-imac"
    
    # Run the setup script
    /tmp/setup-github-runner-macos.sh
    
    # Clean up
    rm /tmp/setup-github-runner-macos.sh
ENDSSH
    
    log_success "M1 iMac runner deployment complete!"
}

# Function to deploy to Raspberry Pi
deploy_to_pi() {
    log_action "Deploying GitHub Actions runner to Raspberry Pi 5..."
    
    # Check connection
    if ! check_ssh_connection "$PI_HOST" "$PI_USER" "Raspberry Pi 5"; then
        log_error "Cannot deploy to Raspberry Pi - SSH connection failed"
        return 1
    fi
    
    # Copy setup script
    log_info "Copying setup script to Raspberry Pi..."
    scp "$SCRIPT_DIR/$PI_SCRIPT" "$PI_USER@$PI_HOST:/tmp/"
    
    # Execute setup script remotely
    log_info "Executing setup script on Raspberry Pi..."
    ssh "$PI_USER@$PI_HOST" << 'ENDSSH'
    # Make script executable
    chmod +x /tmp/setup-github-runner-pi.sh
    
    # Set runner name
    export RUNNER_NAME="nestory-pi5"
    
    # Run the setup script
    /tmp/setup-github-runner-pi.sh
    
    # Clean up
    rm /tmp/setup-github-runner-pi.sh
ENDSSH
    
    log_success "Raspberry Pi runner deployment complete!"
}

# Function to check runner status
check_runner_status() {
    local host=$1
    local user=$2
    local name=$3
    
    log_info "Checking runner status on $name..."
    
    ssh "$user@$host" << 'ENDSSH' 2>/dev/null || echo "Runner not accessible"
    if [[ -d "$HOME/actions-runner" ]]; then
        echo "Runner directory exists"
        if [[ -f "$HOME/actions-runner/.runner" ]]; then
            echo "Runner is configured"
            cat "$HOME/actions-runner/.runner" | jq -r '"Name: \(.name)\nLabels: \(.labels | join(", "))"' 2>/dev/null || echo "Cannot read runner config"
        else
            echo "Runner not configured"
        fi
        
        # Check if service is running
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS - check launchd
            if "$HOME/actions-runner/svc.sh" status 2>/dev/null | grep -q "Started"; then
                echo "Service: Running"
            else
                echo "Service: Stopped"
            fi
        else
            # Linux - check systemd
            if systemctl is-active --quiet github-runner; then
                echo "Service: Running"
            else
                echo "Service: Stopped"
            fi
        fi
    else
        echo "Runner not installed"
    fi
ENDSSH
}

# Function to manage runners
manage_runner() {
    local host=$1
    local user=$2
    local name=$3
    local action=$4
    
    log_info "Performing $action on $name runner..."
    
    ssh "$user@$host" << ENDSSH
    if [[ -d "\$HOME/actions-runner" ]]; then
        cd "\$HOME/actions-runner"
        case "$action" in
            start)
                if [[ -f "./start-runner.sh" ]]; then
                    ./start-runner.sh
                else
                    ./svc.sh start
                fi
                ;;
            stop)
                if [[ -f "./stop-runner.sh" ]]; then
                    ./stop-runner.sh
                else
                    ./svc.sh stop
                fi
                ;;
            restart)
                if [[ -f "./stop-runner.sh" ]]; then
                    ./stop-runner.sh
                    ./start-runner.sh
                else
                    ./svc.sh stop
                    ./svc.sh start
                fi
                ;;
            status)
                if [[ -f "./status-runner.sh" ]]; then
                    ./status-runner.sh
                else
                    ./svc.sh status
                fi
                ;;
            *)
                echo "Unknown action: $action"
                ;;
        esac
    else
        echo "Runner not installed on $name"
    fi
ENDSSH
}

# Function to show menu
show_menu() {
    echo
    echo "Select an action:"
    echo "1) Deploy to M1 iMac"
    echo "2) Deploy to Raspberry Pi 5"
    echo "3) Deploy to both"
    echo "4) Check runner status"
    echo "5) Start runners"
    echo "6) Stop runners"
    echo "7) Restart runners"
    echo "8) Exit"
    echo
    read -p "Enter choice [1-8]: " choice
    
    case $choice in
        1)
            deploy_to_macos
            ;;
        2)
            deploy_to_pi
            ;;
        3)
            deploy_to_macos
            echo
            deploy_to_pi
            ;;
        4)
            echo
            echo "=== M1 iMac Status ==="
            check_runner_status "$IMAC_HOST" "$IMAC_USER" "M1 iMac"
            echo
            echo "=== Raspberry Pi 5 Status ==="
            check_runner_status "$PI_HOST" "$PI_USER" "Raspberry Pi 5"
            ;;
        5)
            manage_runner "$IMAC_HOST" "$IMAC_USER" "M1 iMac" "start"
            manage_runner "$PI_HOST" "$PI_USER" "Raspberry Pi 5" "start"
            ;;
        6)
            manage_runner "$IMAC_HOST" "$IMAC_USER" "M1 iMac" "stop"
            manage_runner "$PI_HOST" "$PI_USER" "Raspberry Pi 5" "stop"
            ;;
        7)
            manage_runner "$IMAC_HOST" "$IMAC_USER" "M1 iMac" "restart"
            manage_runner "$PI_HOST" "$PI_USER" "Raspberry Pi 5" "restart"
            ;;
        8)
            echo "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# Function to configure hosts
configure_hosts() {
    echo "Current configuration (via Tailscale):"
    echo "  M1 iMac: $IMAC_USER@$IMAC_HOST"
    echo "  Raspberry Pi 5: $PI_USER@$PI_HOST"
    echo
    read -p "Do you want to change these settings? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter M1 iMac hostname/IP [default: $IMAC_HOST]: " new_imac
        IMAC_HOST="${new_imac:-$IMAC_HOST}"
        
        read -p "Enter M1 iMac username [default: $IMAC_USER]: " new_imac_user
        IMAC_USER="${new_imac_user:-$IMAC_USER}"
        
        read -p "Enter Raspberry Pi hostname/IP [default: $PI_HOST]: " new_pi
        PI_HOST="${new_pi:-$PI_HOST}"
        
        read -p "Enter Raspberry Pi username [default: $PI_USER]: " new_pi_user
        PI_USER="${new_pi_user:-$PI_USER}"
        
        echo
        echo "Updated configuration:"
        echo "  M1 iMac: $IMAC_USER@$IMAC_HOST"
        echo "  Raspberry Pi: $PI_USER@$PI_HOST"
    fi
}

# Main execution
main() {
    show_header
    
    # Check if scripts exist
    if [[ ! -f "$SCRIPT_DIR/$MACOS_SCRIPT" ]]; then
        log_error "macOS setup script not found: $SCRIPT_DIR/$MACOS_SCRIPT"
        exit 1
    fi
    
    if [[ ! -f "$SCRIPT_DIR/$PI_SCRIPT" ]]; then
        log_error "Raspberry Pi setup script not found: $SCRIPT_DIR/$PI_SCRIPT"
        exit 1
    fi
    
    # Configure hosts if needed
    configure_hosts
    
    # Interactive menu
    while true; do
        show_menu
        echo
        read -p "Press Enter to continue..."
    done
}

# Parse command line arguments
if [[ $# -gt 0 ]]; then
    case "$1" in
        --deploy-macos)
            show_header
            deploy_to_macos
            ;;
        --deploy-pi)
            show_header
            deploy_to_pi
            ;;
        --deploy-all)
            show_header
            deploy_to_macos
            echo
            deploy_to_pi
            ;;
        --status)
            show_header
            echo "=== M1 iMac Status ==="
            check_runner_status "$IMAC_HOST" "$IMAC_USER" "M1 iMac"
            echo
            echo "=== Raspberry Pi 5 Status ==="
            check_runner_status "$PI_HOST" "$PI_USER" "Raspberry Pi 5"
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --deploy-macos    Deploy runner to M1 iMac"
            echo "  --deploy-pi       Deploy runner to Raspberry Pi"
            echo "  --deploy-all      Deploy to both machines"
            echo "  --status          Check runner status on both machines"
            echo "  --help            Show this help message"
            echo ""
            echo "Without options, runs in interactive mode"
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
else
    # Run interactive mode
    main
fi