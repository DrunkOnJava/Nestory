#!/bin/bash

#
# GitHub Actions Self-Hosted Runner Setup for Raspberry Pi 5
# Designed for auxiliary CI/CD tasks (non-Apple frameworks)
#

set -euo pipefail

# Configuration
RUNNER_VERSION="2.321.0"  # Update this to latest version
RUNNER_NAME="${RUNNER_NAME:-nestory-pi5}"
RUNNER_WORKDIR="${HOME}/actions-runner"
REPO_OWNER="DrunkOnJava"
REPO_NAME="Nestory"
LABELS="self-hosted,Linux,ARM64,raspberry-pi,docker-capable,auxiliary"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Header
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   GitHub Actions Self-Hosted Runner Setup - Raspberry Pi 5     ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo

# Check if running on Linux
if [[ "$(uname)" != "Linux" ]]; then
    log_error "This script is designed for Linux. For macOS, use setup-github-runner-macos.sh"
    exit 1
fi

# Check for ARM64 architecture
if [[ "$(uname -m)" != "aarch64" ]]; then
    log_warning "This machine is not ARM64, but continuing anyway..."
fi

# Function to get runner token
get_runner_token() {
    log_info "Getting runner registration token..."
    
    # Check if GitHub CLI is installed and authenticated
    if ! command -v gh &>/dev/null; then
        log_error "GitHub CLI is not installed. Installing..."
        # Install GitHub CLI for Debian/Ubuntu
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    # Check authentication
    if ! gh auth status &>/dev/null; then
        log_error "GitHub CLI is not authenticated. Please run: gh auth login"
        exit 1
    fi
    
    # Get registration token using GitHub CLI
    TOKEN=$(gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token" \
        --jq '.token')
    
    if [[ -z "$TOKEN" ]]; then
        log_error "Failed to get registration token"
        exit 1
    fi
    
    echo "$TOKEN"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Update package list
    sudo apt-get update
    
    # Install required packages
    local packages=("curl" "jq" "git" "build-essential" "libssl-dev")
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg"; then
            log_info "Installing $pkg..."
            sudo apt-get install -y "$pkg"
        fi
    done
    
    # Check Docker installation
    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version)
        log_info "Found Docker: $DOCKER_VERSION"
        LABELS="${LABELS},docker"
    else
        log_warning "Docker not found. Some CI tasks may not work."
        log_info "To install Docker, run: curl -sSL https://get.docker.com | sh"
    fi
    
    # Check Node.js
    if command -v node &>/dev/null; then
        NODE_VERSION=$(node --version)
        log_info "Found Node.js: $NODE_VERSION"
        LABELS="${LABELS},node"
    fi
    
    # Check Python
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version)
        log_info "Found Python: $PYTHON_VERSION"
        LABELS="${LABELS},python"
    fi
    
    log_success "Prerequisites checked"
}

# Function to create runner user (optional for security)
create_runner_user() {
    log_info "Checking runner user..."
    
    RUNNER_USER="github-runner"
    
    if ! id "$RUNNER_USER" &>/dev/null; then
        read -p "Create dedicated user for runner (recommended for security)? (y/n): " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Creating runner user..."
            sudo useradd -m -s /bin/bash "$RUNNER_USER"
            sudo usermod -aG docker "$RUNNER_USER" 2>/dev/null || true
            
            # Switch to runner user for installation
            log_info "Switching to runner user. You may need to enter the runner user password."
            sudo -u "$RUNNER_USER" bash -c "$(declare -f log_info log_success log_warning log_error); $(declare -f download_runner); $(declare -f configure_runner); $(declare -f create_env_setup); RUNNER_WORKDIR=/home/$RUNNER_USER/actions-runner RUNNER_VERSION=$RUNNER_VERSION RUNNER_NAME=$RUNNER_NAME LABELS='$LABELS' REPO_OWNER=$REPO_OWNER REPO_NAME=$REPO_NAME; download_runner; configure_runner; create_env_setup"
            RUNNER_WORKDIR="/home/$RUNNER_USER/actions-runner"
        fi
    fi
}

# Function to download and extract runner
download_runner() {
    log_info "Downloading GitHub Actions Runner v${RUNNER_VERSION}..."
    
    # Create runner directory
    mkdir -p "$RUNNER_WORKDIR"
    cd "$RUNNER_WORKDIR"
    
    # Download runner for Linux ARM64
    local RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz"
    
    if [[ -f "actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz" ]]; then
        log_info "Runner package already downloaded"
    else
        curl -L -o "actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz" "$RUNNER_URL"
    fi
    
    # Extract runner
    log_info "Extracting runner..."
    tar xzf "actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz"
    
    # Remove tarball to save space
    rm -f "actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz"
    
    log_success "Runner downloaded and extracted"
}

# Function to configure runner
configure_runner() {
    log_info "Configuring runner..."
    
    cd "$RUNNER_WORKDIR"
    
    # Get registration token
    local TOKEN=$(get_runner_token)
    
    # Configure the runner
    ./config.sh \
        --url "https://github.com/${REPO_OWNER}/${REPO_NAME}" \
        --token "$TOKEN" \
        --name "$RUNNER_NAME" \
        --labels "$LABELS" \
        --work "_work" \
        --replace \
        --unattended
    
    log_success "Runner configured successfully"
}

# Function to create environment setup
create_env_setup() {
    log_info "Creating environment setup..."
    
    cat > "$RUNNER_WORKDIR/setup-env.sh" << 'EOF'
#!/bin/bash
# Environment setup for GitHub Actions runner on Raspberry Pi

# Basic PATH setup
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Docker configuration (if available)
if command -v docker &>/dev/null; then
    export DOCKER_HOST="unix:///var/run/docker.sock"
fi

# Node.js configuration
if command -v node &>/dev/null; then
    export NODE_ENV="production"
fi

# Python configuration
if command -v python3 &>/dev/null; then
    export PYTHON=$(which python3)
fi

# Build tools
export MAKEFLAGS="-j$(nproc)"

# Cache directories
export npm_config_cache="${HOME}/.npm"
export pip_cache_dir="${HOME}/.cache/pip"

# System limits for Pi
ulimit -n 4096  # Increase file descriptor limit
ulimit -u 2048  # Limit process count

echo "✅ Environment configured for Raspberry Pi runner"
EOF
    
    chmod +x "$RUNNER_WORKDIR/setup-env.sh"
    log_success "Environment setup created"
}

# Function to create systemd service
create_systemd_service() {
    log_info "Creating systemd service..."
    
    local SERVICE_NAME="github-runner"
    local SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
    
    sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=GitHub Actions Runner for Nestory
After=network.target

[Service]
Type=simple
User=${RUNNER_USER:-$USER}
WorkingDirectory=$RUNNER_WORKDIR
ExecStartPre=/bin/bash -c 'source $RUNNER_WORKDIR/setup-env.sh'
ExecStart=$RUNNER_WORKDIR/run.sh
Restart=always
RestartSec=10

# Resource limits for Raspberry Pi
CPUQuota=80%
MemoryMax=2G
TasksMax=100

# Environment
Environment="HOME=${RUNNER_USER:-$HOME}"
Environment="USER=${RUNNER_USER:-$USER}"

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    
    log_success "Systemd service created: $SERVICE_NAME"
    
    # Create management scripts
    cat > "$RUNNER_WORKDIR/start-runner.sh" << EOF
#!/bin/bash
sudo systemctl start $SERVICE_NAME
sudo systemctl status $SERVICE_NAME
EOF
    
    cat > "$RUNNER_WORKDIR/stop-runner.sh" << EOF
#!/bin/bash
sudo systemctl stop $SERVICE_NAME
EOF
    
    cat > "$RUNNER_WORKDIR/status-runner.sh" << EOF
#!/bin/bash
echo "=== Runner Service Status ==="
sudo systemctl status $SERVICE_NAME --no-pager
echo ""
echo "=== Runner Logs (last 20 lines) ==="
sudo journalctl -u $SERVICE_NAME -n 20 --no-pager
EOF
    
    cat > "$RUNNER_WORKDIR/logs-runner.sh" << EOF
#!/bin/bash
sudo journalctl -u $SERVICE_NAME -f
EOF
    
    chmod +x "$RUNNER_WORKDIR"/*.sh
    
    log_success "Management scripts created"
}

# Function to create monitoring script
create_monitoring_script() {
    log_info "Creating monitoring script..."
    
    cat > "$RUNNER_WORKDIR/monitor-runner.sh" << 'EOF'
#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "=== GitHub Runner Monitor - Raspberry Pi ==="
echo "Press Ctrl+C to exit"
echo ""

while true; do
    # CPU and Memory usage
    echo -e "${YELLOW}System Resources:${NC}"
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
    echo "Temperature: $(vcgencmd measure_temp 2>/dev/null || echo "N/A")"
    echo ""
    
    # Runner status
    echo -e "${YELLOW}Runner Status:${NC}"
    if systemctl is-active --quiet github-runner; then
        echo -e "${GREEN}● Service is running${NC}"
    else
        echo -e "${RED}● Service is stopped${NC}"
    fi
    
    # Recent jobs
    echo ""
    echo -e "${YELLOW}Recent Activity:${NC}"
    tail -5 _diag/Runner*.log 2>/dev/null | grep -E "Running job:|Job .+ completed" || echo "No recent jobs"
    
    sleep 5
    clear
done
EOF
    
    chmod +x "$RUNNER_WORKDIR/monitor-runner.sh"
    log_success "Monitoring script created"
}

# Function to optimize Pi performance
optimize_pi_performance() {
    log_info "Optimizing Raspberry Pi performance..."
    
    # Increase swap size (useful for memory-intensive builds)
    if [[ -f /etc/dphys-swapfile ]]; then
        log_info "Configuring swap..."
        sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
        sudo systemctl restart dphys-swapfile
    fi
    
    # Set CPU governor to performance
    if command -v cpufreq-set &>/dev/null; then
        log_info "Setting CPU governor to performance..."
        sudo cpufreq-set -g performance
    fi
    
    log_success "Performance optimizations applied"
}

# Main installation flow
main() {
    log_info "Starting GitHub Actions runner setup for Raspberry Pi 5..."
    
    # Check prerequisites
    check_prerequisites
    
    # Optional: Create dedicated user
    create_runner_user
    
    # Download and extract runner
    download_runner
    
    # Configure runner
    configure_runner
    
    # Create environment setup
    create_env_setup
    
    # Create monitoring script
    create_monitoring_script
    
    # Optimize Pi performance
    read -p "Apply Raspberry Pi performance optimizations? (y/n): " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        optimize_pi_performance
    fi
    
    # Create systemd service
    read -p "Install runner as a systemd service (auto-start on boot)? (y/n): " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_systemd_service
        
        # Start the service
        read -p "Start the runner service now? (y/n): " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo systemctl start github-runner
            sudo systemctl status github-runner --no-pager
        fi
    else
        log_info "Skipping service installation. You can run './run.sh' manually in $RUNNER_WORKDIR"
    fi
    
    # Print summary
    echo
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}     ✅ GitHub Actions Runner Setup Complete!                   ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo
    echo "Runner Name: $RUNNER_NAME"
    echo "Runner Directory: $RUNNER_WORKDIR"
    echo "Labels: $LABELS"
    echo
    echo "Management Commands:"
    echo "  Start:   $RUNNER_WORKDIR/start-runner.sh"
    echo "  Stop:    $RUNNER_WORKDIR/stop-runner.sh"
    echo "  Status:  $RUNNER_WORKDIR/status-runner.sh"
    echo "  Logs:    $RUNNER_WORKDIR/logs-runner.sh"
    echo "  Monitor: $RUNNER_WORKDIR/monitor-runner.sh"
    echo
    echo "Suitable for auxiliary tasks:"
    echo "  ✓ Documentation generation"
    echo "  ✓ Script validation"
    echo "  ✓ Docker container builds"
    echo "  ✓ Non-iOS testing"
    echo "  ✓ File processing"
    echo "  ✗ iOS/macOS builds (requires macOS)"
    echo
    echo "The runner is now ready to process jobs!"
}

# Run main function
main "$@"