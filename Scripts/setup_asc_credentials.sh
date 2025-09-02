#!/bin/bash

# Setup App Store Connect API Credentials
# This script helps store App Store Connect API credentials securely in macOS Keychain

set -euo pipefail

KEYCHAIN_SERVICE="com.drunkonjava.nestory.appstoreconnect"

echo "🔐 App Store Connect API Credential Setup"
echo "========================================"
echo ""
echo "This script will securely store your App Store Connect API credentials in macOS Keychain."
echo ""

# Function to store in keychain
store_credential() {
    local key=$1
    local value=$2
    
    # Delete existing if present
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$key" 2>/dev/null || true
    
    # Add new credential
    security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$key" -w "$value" -T "" -U
    
    if [ $? -eq 0 ]; then
        echo "✅ Stored $key successfully"
    else
        echo "❌ Failed to store $key"
        exit 1
    fi
}

# Function to read from keychain
read_credential() {
    local key=$1
    security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$key" -w 2>/dev/null || echo ""
}

# Check for command line arguments
if [ "$1" == "--check" ]; then
    echo "🔍 Checking stored credentials..."
    echo ""
    
    KEY_ID=$(read_credential "ASC_KEY_ID")
    ISSUER_ID=$(read_credential "ASC_ISSUER_ID")
    PRIVATE_KEY=$(read_credential "ASC_PRIVATE_KEY")
    
    if [ -n "$KEY_ID" ]; then
        echo "✅ Key ID: ${KEY_ID:0:8}..."
    else
        echo "❌ Key ID: Not found"
    fi
    
    if [ -n "$ISSUER_ID" ]; then
        echo "✅ Issuer ID: ${ISSUER_ID:0:8}..."
    else
        echo "❌ Issuer ID: Not found"
    fi
    
    if [ -n "$PRIVATE_KEY" ]; then
        echo "✅ Private Key: Stored (${#PRIVATE_KEY} characters)"
    else
        echo "❌ Private Key: Not found"
    fi
    
    exit 0
fi

if [ "$1" == "--clear" ]; then
    echo "🗑️  Clearing stored credentials..."
    
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "ASC_KEY_ID" 2>/dev/null || true
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "ASC_ISSUER_ID" 2>/dev/null || true
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "ASC_PRIVATE_KEY" 2>/dev/null || true
    
    echo "✅ Credentials cleared"
    exit 0
fi

if [ "$1" == "--export" ]; then
    echo "📤 Exporting credentials as environment variables..."
    echo ""
    echo "# Add these to your .env or CI/CD configuration:"
    echo ""
    
    KEY_ID=$(read_credential "ASC_KEY_ID")
    ISSUER_ID=$(read_credential "ASC_ISSUER_ID")
    PRIVATE_KEY=$(read_credential "ASC_PRIVATE_KEY")
    
    if [ -n "$KEY_ID" ]; then
        echo "export ASC_KEY_ID=\"$KEY_ID\""
    fi
    
    if [ -n "$ISSUER_ID" ]; then
        echo "export ASC_ISSUER_ID=\"$ISSUER_ID\""
    fi
    
    if [ -n "$PRIVATE_KEY" ]; then
        # Base64 encode for easier storage
        ENCODED_KEY=$(echo "$PRIVATE_KEY" | base64)
        echo "export ASC_KEY_CONTENT=\"$ENCODED_KEY\""
    fi
    
    exit 0
fi

# Interactive setup
echo "📝 Enter your App Store Connect API credentials"
echo "You can find these at: https://appstoreconnect.apple.com/access/api"
echo ""

# Get Key ID
read -p "Key ID (e.g., XXXXXXXXXX): " KEY_ID
if [ -z "$KEY_ID" ]; then
    echo "❌ Key ID is required"
    exit 1
fi

# Get Issuer ID
read -p "Issuer ID (UUID format): " ISSUER_ID
if [ -z "$ISSUER_ID" ]; then
    echo "❌ Issuer ID is required"
    exit 1
fi

# Get Private Key
echo ""
echo "Private Key (.p8 file content):"
echo "You can either:"
echo "  1. Paste the entire content including -----BEGIN PRIVATE KEY----- headers"
echo "  2. Provide the path to your .p8 file"
echo ""
read -p "Private key path or press Enter to paste: " KEY_INPUT

if [ -f "$KEY_INPUT" ]; then
    echo "📂 Reading from file: $KEY_INPUT"
    PRIVATE_KEY=$(cat "$KEY_INPUT")
else
    echo "📋 Paste your private key content (press Ctrl+D when done):"
    PRIVATE_KEY=$(cat)
fi

if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Private key is required"
    exit 1
fi

# Validate private key format
if [[ "$PRIVATE_KEY" == *"BEGIN PRIVATE KEY"* ]]; then
    echo "✅ Private key format validated (PEM)"
else
    # Check if it's base64
    if echo "$PRIVATE_KEY" | base64 -d >/dev/null 2>&1; then
        echo "✅ Private key format validated (Base64)"
    else
        echo "⚠️  Warning: Private key format may be invalid"
    fi
fi

# Store credentials
echo ""
echo "💾 Storing credentials in Keychain..."

store_credential "ASC_KEY_ID" "$KEY_ID"
store_credential "ASC_ISSUER_ID" "$ISSUER_ID"
store_credential "ASC_PRIVATE_KEY" "$PRIVATE_KEY"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Your credentials are now securely stored in macOS Keychain."
echo "They will be automatically loaded by the Nestory app and Fastlane."
echo ""
echo "To verify: $0 --check"
echo "To export: $0 --export"
echo "To clear:  $0 --clear"