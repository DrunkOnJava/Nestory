#!/bin/bash

#
# Raspberry Pi SSH Setup Helper
# Configures SSH access for GitHub Actions runner deployment
#

set -euo pipefail

# Configuration
PI_HOST="100.116.38.90"
PI_USER="${PI_USER:-griffin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              Raspberry Pi SSH Configuration Helper              ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo

# Check if SSH key exists
if [[ ! -f ~/.ssh/id_rsa.pub ]] && [[ ! -f ~/.ssh/id_ed25519.pub ]]; then
    echo -e "${YELLOW}No SSH key found. Generating one...${NC}"
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
    echo -e "${GREEN}✓ SSH key generated${NC}"
fi

# Get the public key
if [[ -f ~/.ssh/id_ed25519.pub ]]; then
    PUB_KEY=$(cat ~/.ssh/id_ed25519.pub)
elif [[ -f ~/.ssh/id_rsa.pub ]]; then
    PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
else
    echo -e "${RED}Error: No SSH public key found${NC}"
    exit 1
fi

echo -e "${YELLOW}Your SSH public key:${NC}"
echo "$PUB_KEY"
echo

echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    Setup Instructions                         ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${YELLOW}Option 1: Automatic Setup (if you have password access)${NC}"
echo "Run this command and enter your Pi password when prompted:"
echo
echo -e "${GREEN}ssh-copy-id $PI_USER@$PI_HOST${NC}"
echo
echo "────────────────────────────────────────────────────────────────"
echo
echo -e "${YELLOW}Option 2: Manual Setup (on the Raspberry Pi)${NC}"
echo "1. Connect to your Pi (via keyboard/monitor or existing SSH)"
echo "2. Run these commands on the Pi:"
echo
cat << 'EOF'
# Create SSH directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add the public key (copy the key shown above)
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Ensure SSH is enabled
sudo systemctl enable ssh
sudo systemctl start ssh

# Check SSH status
sudo systemctl status ssh
EOF
echo
echo "────────────────────────────────────────────────────────────────"
echo
echo -e "${YELLOW}Option 3: Using Tailscale SSH (Beta)${NC}"
echo "If Tailscale SSH is enabled on your Pi:"
echo
echo "1. On the Pi, run:"
echo "   tailscale up --ssh"
echo
echo "2. Then connect with:"
echo "   tailscale ssh $PI_USER@$PI_HOST"
echo
echo "────────────────────────────────────────────────────────────────"
echo
echo -e "${BLUE}After completing any option above, test the connection:${NC}"
echo -e "${GREEN}ssh $PI_USER@$PI_HOST 'echo Success!'${NC}"
echo

# Try to test the connection
echo -e "${YELLOW}Testing current connection...${NC}"
if ssh -o ConnectTimeout=3 -o ConnectTimeout=10 -o PasswordAuthentication=no "$PI_USER@$PI_HOST" "echo '✓ SSH key authentication working!'" 2>/dev/null; then
    echo -e "${GREEN}✅ Connection successful! You can now deploy the runner.${NC}"
    echo
    echo "Run: ./deploy-runner-remote.sh --deploy-pi"
else
    echo -e "${RED}❌ Connection failed. Please follow the setup instructions above.${NC}"
    
    # Offer to try password authentication
    echo
    read -p "Would you like to try setting up SSH key automatically with password? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Attempting to copy SSH key...${NC}"
        if ssh-copy-id "$PI_USER@$PI_HOST"; then
            echo -e "${GREEN}✅ SSH key copied successfully!${NC}"
            
            # Test the connection
            if ssh -o ConnectTimeout=3 "$PI_USER@$PI_HOST" "echo '✓ Connection verified!'" 2>/dev/null; then
                echo -e "${GREEN}Connection working! You can now deploy the runner.${NC}"
            fi
        else
            echo -e "${RED}Failed to copy SSH key. Please try manual setup.${NC}"
        fi
    fi
fi