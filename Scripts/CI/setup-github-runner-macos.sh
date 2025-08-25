#!/bin/bash

#
# GitHub Actions Self-Hosted Runner Setup for M1 iMac
# Designed for Nestory iOS/macOS Development
#

set -euo pipefail

# Configuration
RUNNER_VERSION="2.321.0"  # Update this to latest version
RUNNER_NAME="${RUNNER_NAME:-nestory-m1-imac}"
RUNNER_WORKDIR="${HOME}/actions-runner"
REPO_OWNER="DrunkOnJava"
REPO_NAME="Nestory"
LABELS="self-hosted,macOS,ARM64,M1,xcode,ios-capable"

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
echo -e "${BLUE}     GitHub Actions Self-Hosted Runner Setup - M1 iMac          ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is designed for macOS. For Raspberry Pi, use setup-github-runner-pi.sh"
    exit 1
fi

# Check for Apple Silicon
if [[ "$(uname -m)" != "arm64" ]]; then
    log_warning "This machine is not Apple Silicon, but continuing anyway..."
fi

# Function to get runner token
get_runner_token() {
    log_info "Getting runner registration token..."
    
    # Check if GitHub CLI is authenticated
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
    
    # Check for required tools
    local missing_tools=()
    
    command -v git >/dev/null 2>&1 || missing_tools+=("git")
    command -v gh >/dev/null 2>&1 || missing_tools+=("GitHub CLI (gh)")
    command -v xcodebuild >/dev/null 2>&1 || missing_tools+=("Xcode")
    command -v swift >/dev/null 2>&1 || missing_tools+=("Swift")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install missing tools and try again"
        exit 1
    fi
    
    # Check Xcode version
    XCODE_VERSION=$(xcodebuild -version | head -1 | awk '{print $2}')
    log_info "Found Xcode version: $XCODE_VERSION"
    
    # Check Swift version
    SWIFT_VERSION=$(swift --version | head -1)
    log_info "Found Swift: $SWIFT_VERSION"
    
    log_success "All prerequisites met"
}

# Function to download and extract runner
download_runner() {
    log_info "Downloading GitHub Actions Runner v${RUNNER_VERSION}..."
    
    # Create runner directory
    mkdir -p "$RUNNER_WORKDIR"
    cd "$RUNNER_WORKDIR"
    
    # Download runner for macOS ARM64
    local RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz"
    
    if [[ -f "actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz" ]]; then
        log_info "Runner package already downloaded"
    else
        curl -L -o "actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz" "$RUNNER_URL"
    fi
    
    # Extract runner
    log_info "Extracting runner..."
    tar xzf "actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz"
    
    # Remove tarball to save space
    rm -f "actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz"
    
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
# Environment setup for GitHub Actions runner

# Xcode configuration
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export XCODE_VERSION=$(xcodebuild -version | head -1 | awk '{print $2}')

# Swift and build tools
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Simulator configuration
export SIMULATOR_DEVICE_NAME="iPhone 16 Pro Max"

# Build optimization
export SWIFT_BUILD_FLAGS="-c release"
export XCODEBUILD_FLAGS="-quiet -parallelizeTargets -showBuildTimingSummary"

# Cache directories
export SPM_CACHE_DIR="${HOME}/Library/Caches/org.swift.swiftpm"
export DERIVED_DATA_PATH="${HOME}/Library/Developer/Xcode/DerivedData"

# Node.js (via mise)
if [ -f "${HOME}/.local/share/mise/shims/node" ]; then
    export PATH="${HOME}/.local/share/mise/shims:$PATH"
fi

# Ruby (for Fastlane if needed)
if [ -d "${HOME}/.rbenv" ]; then
    export PATH="${HOME}/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

echo "✅ Environment configured for macOS runner"
EOF
    
    chmod +x "$RUNNER_WORKDIR/setup-env.sh"
    log_success "Environment setup created"
}

# Function to install as service
install_service() {
    log_info "Installing runner as a service..."
    
    cd "$RUNNER_WORKDIR"
    
    # Install the service
    ./svc.sh install
    
    # Start the service
    ./svc.sh start
    
    # Check status
    ./svc.sh status
    
    log_success "Runner service installed and started"
}

# Function to create management scripts
create_management_scripts() {
    log_info "Creating management scripts..."
    
    # Create start script
    cat > "$RUNNER_WORKDIR/start-runner.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
./svc.sh start
./svc.sh status
EOF
    
    # Create stop script
    cat > "$RUNNER_WORKDIR/stop-runner.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
./svc.sh stop
EOF
    
    # Create status script
    cat > "$RUNNER_WORKDIR/status-runner.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "=== Runner Service Status ==="
./svc.sh status
echo ""
echo "=== Runner Configuration ==="
cat .runner | jq -r '"Name: \(.name)\nLabels: \(.labels | join(", "))"'
echo ""
echo "=== Recent Jobs ==="
tail -20 _diag/Runner*.log 2>/dev/null | grep -E "Running job:|Job .+ completed" | tail -5
EOF
    
    # Create update script
    cat > "$RUNNER_WORKDIR/update-runner.sh" << 'EOF'
#!/bin/bash
set -e

echo "Checking for runner updates..."
cd "$(dirname "$0")"

# Stop the service
./svc.sh stop

# Check for updates
LATEST_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4 | sed 's/^v//')
CURRENT_VERSION=$(./config.sh --version 2>/dev/null | head -1 | awk '{print $3}')

if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
    echo "Update available: $CURRENT_VERSION → $LATEST_VERSION"
    echo "Please run the setup script again with RUNNER_VERSION=$LATEST_VERSION"
else
    echo "Runner is up to date (v$CURRENT_VERSION)"
fi

# Start the service again
./svc.sh start
EOF
    
    # Make all scripts executable
    chmod +x "$RUNNER_WORKDIR"/*.sh
    
    log_success "Management scripts created"
}

# Function to create uninstall script
create_uninstall_script() {
    log_info "Creating uninstall script..."
    
    cat > "$RUNNER_WORKDIR/uninstall-runner.sh" << 'EOF'
#!/bin/bash
set -e

echo "⚠️  This will completely remove the GitHub Actions runner"
read -p "Are you sure? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "Cancelled"
    exit 0
fi

cd "$(dirname "$0")"

# Stop and uninstall service
./svc.sh stop || true
./svc.sh uninstall || true

# Remove runner from GitHub
if command -v gh &> /dev/null; then
    RUNNER_ID=$(cat .runner | jq -r '.id // empty')
    if [[ -n "$RUNNER_ID" ]]; then
        gh api -X DELETE "/repos/DrunkOnJava/Nestory/actions/runners/$RUNNER_ID" || true
    fi
fi

# Clean up
cd ..
rm -rf "$(basename "$PWD")"

echo "✅ Runner uninstalled successfully"
EOF
    
    chmod +x "$RUNNER_WORKDIR/uninstall-runner.sh"
    log_success "Uninstall script created"
}

# Main installation flow
main() {
    log_info "Starting GitHub Actions runner setup for M1 iMac..."
    
    # Check prerequisites
    check_prerequisites
    
    # Download and extract runner
    download_runner
    
    # Configure runner
    configure_runner
    
    # Create environment setup
    create_env_setup
    
    # Create management scripts
    create_management_scripts
    
    # Create uninstall script
    create_uninstall_script
    
    # Install as service
    read -p "Install runner as a service (auto-start on boot)? (y/n): " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_service
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
    echo "  Update:  $RUNNER_WORKDIR/update-runner.sh"
    echo "  Uninstall: $RUNNER_WORKDIR/uninstall-runner.sh"
    echo
    echo "The runner is now ready to process jobs!"
}

# Run main function
main "$@"