#!/bin/bash

# Verify App Store Connect Setup for Nestory
# This script checks all components are ready for submission

set -e

echo "🔍 Verifying App Store Connect Setup for Nestory"
echo "================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        return 0
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

SUCCESS_COUNT=0
TOTAL_COUNT=0

echo "1️⃣  Checking Credentials"
echo "------------------------"
TOTAL_COUNT=$((TOTAL_COUNT + 3))

# Check for API credentials
if [ -f "fastlane/.env.local" ]; then
    check 0 "Local environment file exists"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    
    if grep -q "ASC_KEY_ID=1Q3C9RIHO6XC" fastlane/.env.local; then
        check 0 "Key ID configured"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        check 1 "Key ID not found"
    fi
    
    if [ -f "/Users/griffin/Projects/Nestory/AuthKey_NWV654RNK3.p8" ]; then
        check 0 "Private key file exists"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        check 1 "Private key file not found"
    fi
else
    check 1 "Local environment file missing"
fi

echo ""
echo "2️⃣  Checking Metadata"
echo "--------------------"
TOTAL_COUNT=$((TOTAL_COUNT + 6))

# Check metadata files
for file in description keywords subtitle promotional_text release_notes privacy_url; do
    if [ -f "fastlane/metadata/en-US/${file}.txt" ]; then
        check 0 "Metadata: ${file}.txt"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        check 1 "Metadata: ${file}.txt missing"
    fi
done

echo ""
echo "3️⃣  Checking Configuration Files"
echo "--------------------------------"
TOTAL_COUNT=$((TOTAL_COUNT + 4))

# Check Fastlane configuration
if [ -f "fastlane/Fastfile" ]; then
    check 0 "Fastfile exists"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Fastfile missing"
fi

if [ -f "fastlane/Deliverfile" ]; then
    check 0 "Deliverfile configured"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Deliverfile missing"
fi

if [ -f "fastlane/rating_config.json" ]; then
    check 0 "Age rating configured"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Age rating not configured"
fi

if [ -f "fastlane/Snapfile" ]; then
    check 0 "Screenshot configuration ready"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Screenshot configuration missing"
fi

echo ""
echo "4️⃣  Checking App Configuration"
echo "------------------------------"
TOTAL_COUNT=$((TOTAL_COUNT + 4))

# Check project configuration
if [ -f "project.yml" ]; then
    check 0 "Project.yml exists"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    
    if grep -q "MARKETING_VERSION: 1.0.1" project.yml; then
        check 0 "Version set to 1.0.1"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        check 1 "Version not set correctly"
    fi
    
    if grep -q "ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS: YES" project.yml; then
        check 0 "App icon configuration correct"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        check 1 "App icon configuration missing"
    fi
else
    check 1 "Project.yml missing"
fi

# Check app icon
if [ -d "App-Main/Assets.xcassets/AppIcon.appiconset" ]; then
    ICON_COUNT=$(ls App-Main/Assets.xcassets/AppIcon.appiconset/*.png 2>/dev/null | wc -l)
    if [ $ICON_COUNT -gt 0 ]; then
        check 0 "App icons present ($ICON_COUNT icons)"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        check 1 "App icons missing"
    fi
else
    check 1 "AppIcon.appiconset not found"
fi

echo ""
echo "5️⃣  Checking Export Compliance"
echo "------------------------------"
TOTAL_COUNT=$((TOTAL_COUNT + 3))

# Check Info.plist for compliance keys
if grep -q "ITSAppUsesNonExemptEncryption" App-Main/Info.plist; then
    check 0 "Export compliance configured in Info.plist"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Export compliance not configured"
fi

if [ -f "EXPORT_COMPLIANCE.md" ]; then
    check 0 "Export compliance documentation"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Export compliance documentation missing"
fi

if grep -q "export_compliance" fastlane/Deliverfile; then
    check 0 "Export compliance in Deliverfile"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Export compliance not in Deliverfile"
fi

echo ""
echo "6️⃣  Checking Documentation"
echo "--------------------------"
TOTAL_COUNT=$((TOTAL_COUNT + 2))

if [ -f "PRIVACY_POLICY.md" ]; then
    check 0 "Privacy policy created"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "Privacy policy missing"
fi

if [ -f "APP_STORE_CONNECT_API.md" ]; then
    check 0 "API documentation present"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
    check 1 "API documentation missing"
fi

echo ""
echo "📊 Summary"
echo "----------"
echo "Completed: $SUCCESS_COUNT/$TOTAL_COUNT checks"

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    echo -e "${GREEN}✅ All checks passed! Ready for App Store submission.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Build the app: bundle exec fastlane build"
    echo "2. Upload to TestFlight: bundle exec fastlane beta"
    echo "3. Submit for review: bundle exec fastlane submit_for_review"
else
    MISSING=$((TOTAL_COUNT - SUCCESS_COUNT))
    echo -e "${YELLOW}⚠️  $MISSING checks failed. Please address the issues above.${NC}"
    echo ""
    echo "To fix credential issues:"
    echo "  ./scripts/setup_asc_credentials.sh"
    echo ""
    echo "To regenerate project:"
    echo "  xcodegen generate"
fi

echo ""
echo "📱 App Store Connect URLs:"
echo "  • Apps: https://appstoreconnect.apple.com/apps"
echo "  • TestFlight: https://appstoreconnect.apple.com/apps/[app-id]/testflight"
echo "  • API Keys: https://appstoreconnect.apple.com/access/api"