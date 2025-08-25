#!/bin/bash

#
# Test SSH Connections to GitHub Actions Runners
# Verifies connectivity to both M1 iMac (via Tailscale) and Raspberry Pi
#

set -euo pipefail

# Configuration (Both machines via Tailscale)
IMAC_HOST="100.106.87.23"  # M1 iMac Tailscale IP
IMAC_USER="griffin"
PI_HOST="100.116.38.90"    # Raspberry Pi 5 Tailscale IP
PI_USER="griffin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}          Testing GitHub Actions Runner Connections              ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo

# Test M1 iMac connection
echo -e "${YELLOW}Testing M1 iMac connection (Tailscale)...${NC}"
echo "  Host: $IMAC_HOST"
echo "  User: $IMAC_USER"

if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$IMAC_USER@$IMAC_HOST" "echo '  ✓ Connected'; uname -a | sed 's/^/  /'; sw_vers | head -2 | sed 's/^/  /'" 2>/dev/null; then
    echo -e "${GREEN}  ✓ M1 iMac connection successful${NC}"
    
    # Check if runner is installed
    if ssh -o ConnectTimeout=2 "$IMAC_USER@$IMAC_HOST" "test -d ~/actions-runner && echo '  ✓ Runner directory exists' || echo '  ✗ Runner not installed'" 2>/dev/null; then
        ssh -o ConnectTimeout=2 "$IMAC_USER@$IMAC_HOST" "cd ~/actions-runner 2>/dev/null && ./svc.sh status 2>/dev/null | head -3 | sed 's/^/  /'" 2>/dev/null || echo "  Runner service not configured"
    fi
else
    echo -e "${RED}  ✗ M1 iMac connection failed${NC}"
    echo "  Troubleshooting:"
    echo "  1. Check if Tailscale is running on both machines"
    echo "  2. Verify IP with: tailscale status"
    echo "  3. Check SSH is enabled on iMac: System Settings > General > Sharing > Remote Login"
fi

echo
echo -e "${YELLOW}Testing Raspberry Pi 5 connection (Tailscale)...${NC}"
echo "  Host: $PI_HOST"
echo "  User: $PI_USER"

if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$PI_USER@$PI_HOST" "echo '  ✓ Connected'; uname -a | sed 's/^/  /'; lsb_release -d 2>/dev/null | sed 's/^/  /'" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Raspberry Pi connection successful${NC}"
    
    # Check if runner is installed
    if ssh -o ConnectTimeout=2 "$PI_USER@$PI_HOST" "test -d ~/actions-runner && echo '  ✓ Runner directory exists' || echo '  ✗ Runner not installed'" 2>/dev/null; then
        ssh -o ConnectTimeout=2 "$PI_USER@$PI_HOST" "systemctl is-active github-runner 2>/dev/null && echo '  ✓ Runner service is active' || echo '  ✗ Runner service not active'" 2>/dev/null || echo "  Runner service not configured"
    fi
    
    # Check Docker
    ssh -o ConnectTimeout=2 "$PI_USER@$PI_HOST" "docker --version 2>/dev/null | sed 's/^/  /' || echo '  Docker not installed'" 2>/dev/null
else
    echo -e "${RED}  ✗ Raspberry Pi connection failed${NC}"
    echo "  Troubleshooting:"
    echo "  1. Check if Tailscale is running on Pi: tailscale status"
    echo "  2. Verify IP with: tailscale status | grep raspberrypi"
    echo "  3. Check SSH is enabled: sudo systemctl status ssh"
fi

echo
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                      Connection Test Summary                    ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

# Summary
M1_OK=false
PI_OK=false

ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no "$IMAC_USER@$IMAC_HOST" "exit 0" 2>/dev/null && M1_OK=true
ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no "$PI_USER@$PI_HOST" "exit 0" 2>/dev/null && PI_OK=true

if $M1_OK && $PI_OK; then
    echo -e "${GREEN}✓ Both runners are accessible${NC}"
    echo
    echo "Ready to deploy! Run:"
    echo "  ./deploy-runner-remote.sh --deploy-all"
elif $M1_OK; then
    echo -e "${YELLOW}⚠ Only M1 iMac is accessible${NC}"
    echo
    echo "You can deploy to M1 iMac only:"
    echo "  ./deploy-runner-remote.sh --deploy-macos"
elif $PI_OK; then
    echo -e "${YELLOW}⚠ Only Raspberry Pi is accessible${NC}"
    echo
    echo "You can deploy to Raspberry Pi only:"
    echo "  ./deploy-runner-remote.sh --deploy-pi"
else
    echo -e "${RED}✗ No runners are accessible${NC}"
    echo
    echo "Please check network connectivity and SSH configuration"
fi

echo
echo "SSH Config Recommendation:"
echo "Add to ~/.ssh/config for easier access:"
echo
echo "Host imac"
echo "    HostName $IMAC_HOST"
echo "    User $IMAC_USER"
echo ""
echo "Host pi"
echo "    HostName $PI_HOST"
echo "    User $PI_USER"