#!/bin/bash

# Entitlements Validation Script
# Purpose: Ensure entitlements are properly configured for each build configuration
# Best Practice: Different capabilities for development vs production

set -euo pipefail

echo "🔍 Validating Entitlements Configuration"
echo "========================================"

# Configuration
DEV_ENTITLEMENTS="App-Main/Nestory-Dev.entitlements"
PROD_ENTITLEMENTS="App-Main/Nestory.entitlements"

# Validation Functions
validate_entitlements_file() {
    local file=$1
    local env=$2
    
    echo "📋 Validating $env entitlements: $file"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ ERROR: Entitlements file not found: $file"
        exit 1
    fi
    
    # Check XML validity
    if ! plutil -lint "$file" >/dev/null 2>&1; then
        echo "❌ ERROR: Invalid plist format in $file"
        exit 1
    fi
    
    echo "✅ $env entitlements file is valid"
}

check_capability() {
    local file=$1
    local capability=$2
    local expected_value=$3
    local env=$4
    
    if plutil -extract "$capability" raw "$file" 2>/dev/null | grep -q "$expected_value"; then
        echo "✅ $env: $capability = $expected_value"
        return 0
    else
        current_value=$(plutil -extract "$capability" raw "$file" 2>/dev/null || echo "NOT_SET")
        echo "⚠️  $env: $capability = $current_value (expected: $expected_value)"
        return 1
    fi
}

# Main Validation
echo
validate_entitlements_file "$DEV_ENTITLEMENTS" "Development"
validate_entitlements_file "$PROD_ENTITLEMENTS" "Production"

echo
echo "🔍 Checking Critical Capabilities"
echo "----------------------------------"

# Development should have critical alerts disabled
if check_capability "$DEV_ENTITLEMENTS" "com.apple.developer.usernotifications.critical-alerts" "false" "Development"; then
    echo "✅ Development properly disables critical alerts"
else
    echo "❌ Development should have critical-alerts = false for automatic provisioning"
fi

# Production should have critical alerts enabled
if check_capability "$PROD_ENTITLEMENTS" "com.apple.developer.usernotifications.critical-alerts" "true" "Production"; then
    echo "✅ Production properly enables critical alerts"
else
    echo "⚠️  Production critical alerts configuration may need Apple approval"
fi

# Both should have in-app purchases enabled
for env_file in "$DEV_ENTITLEMENTS:Development" "$PROD_ENTITLEMENTS:Production"; do
    file=$(echo $env_file | cut -d: -f1)
    env=$(echo $env_file | cut -d: -f2)
    
    if check_capability "$file" "com.apple.developer.in-app-purchases" "true" "$env"; then
        echo "✅ $env in-app purchases enabled"
    else
        echo "⚠️  $env may need App Store Connect configuration for in-app purchases"
    fi
done

echo
echo "🔍 Checking CloudKit Configuration"
echo "-----------------------------------"

# Check CloudKit container configuration
for env_file in "$DEV_ENTITLEMENTS:Development" "$PROD_ENTITLEMENTS:Production"; do
    file=$(echo $env_file | cut -d: -f1)
    env=$(echo $env_file | cut -d: -f2)
    
    container_ref=$(plutil -extract "com.apple.developer.icloud-container-identifiers.0" raw "$file" 2>/dev/null || echo "NOT_SET")
    if [[ "$container_ref" == '$(CLOUDKIT_CONTAINER)' ]]; then
        echo "✅ $env uses proper CloudKit container variable substitution"
    else
        echo "⚠️  $env CloudKit container: $container_ref"
    fi
done

echo
echo "✅ Entitlements validation complete!"
echo
echo "📋 Next Steps for Production Deployment:"
echo "  1. Request critical alerts entitlement from Apple"
echo "  2. Configure in-app purchases in App Store Connect"
echo "  3. Set up proper provisioning profiles with required capabilities"
echo "  4. Verify CloudKit container exists and is properly configured"