#!/bin/bash

# Automatic dashboard upload with API token creation
# Uses Grafana's service account API to create token programmatically

set -e

GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASS="admin"

echo "🚀 Automatic Dashboard Upload"
echo "════════════════════════════"
echo ""

# Check if Grafana is running
echo "🏥 Checking Grafana connectivity..."
if ! curl -s "$GRAFANA_URL/api/health" > /dev/null; then
    echo "❌ Cannot connect to Grafana at $GRAFANA_URL"
    echo "💡 Make sure Grafana is running: docker run -d -p 3000:3000 grafana/grafana"
    exit 1
fi
echo "✅ Grafana is running"
echo ""

# Create service account
echo "👤 Creating service account..."
service_account_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"name": "nestory-monitoring", "role": "Admin"}' \
    "$GRAFANA_USER:$GRAFANA_PASS@$GRAFANA_URL/api/serviceaccounts" || echo '{"error": "failed"}')

if [[ $(echo "$service_account_response" | jq -r '.id // "null"') == "null" ]]; then
    echo "⚠️ Service account creation failed or already exists"
    
    # Try to find existing service account
    echo "🔍 Looking for existing service account..."
    existing_accounts=$(curl -s -X GET "$GRAFANA_USER:$GRAFANA_PASS@$GRAFANA_URL/api/serviceaccounts")
    service_account_id=$(echo "$existing_accounts" | jq -r '.serviceAccounts[] | select(.name=="nestory-monitoring") | .id')
    
    if [[ -z "$service_account_id" || "$service_account_id" == "null" ]]; then
        echo "❌ Could not create or find service account"
        echo "💡 Try manually: Go to $GRAFANA_URL/admin/api-keys and create a token"
        exit 1
    fi
    echo "✅ Found existing service account (ID: $service_account_id)"
else
    service_account_id=$(echo "$service_account_response" | jq -r '.id')
    echo "✅ Created service account (ID: $service_account_id)"
fi

echo ""

# Create API token
echo "🔑 Creating API token..."
token_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"nestory-dashboard-upload-$(date +%s)\"}" \
    "$GRAFANA_USER:$GRAFANA_PASS@$GRAFANA_URL/api/serviceaccounts/$service_account_id/tokens")

api_token=$(echo "$token_response" | jq -r '.key // empty')

if [[ -z "$api_token" ]]; then
    echo "❌ Failed to create API token"
    echo "Response: $token_response"
    exit 1
fi

echo "✅ Created API token: ${api_token:0:8}...${api_token: -8}"
echo ""

# Upload dashboards
echo "📊 Uploading dashboards..."

# Upload comprehensive dashboard
echo "📈 Uploading comprehensive dashboard..."
comprehensive_response=$(curl -s -X POST \
    -H "Authorization: Bearer $api_token" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\": $(cat dashboards/comprehensive-dev.json), \"folderId\": 0, \"overwrite\": true, \"message\": \"Auto-uploaded via script\"}" \
    "$GRAFANA_URL/api/dashboards/db")

comprehensive_uid=$(echo "$comprehensive_response" | jq -r '.uid // "error"')
if [[ "$comprehensive_uid" != "error" && "$comprehensive_uid" != "null" ]]; then
    echo "✅ Comprehensive dashboard uploaded"
    echo "🔗 View: $GRAFANA_URL/d/$comprehensive_uid"
else
    echo "❌ Failed to upload comprehensive dashboard"
    echo "$comprehensive_response" | jq -r '.message // .'
fi

echo ""

# Upload production dashboard
echo "📊 Uploading production dashboard..."
production_response=$(curl -s -X POST \
    -H "Authorization: Bearer $api_token" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\": $(cat dashboards/production-prod.json), \"folderId\": 0, \"overwrite\": true, \"message\": \"Auto-uploaded via script\"}" \
    "$GRAFANA_URL/api/dashboards/db")

production_uid=$(echo "$production_response" | jq -r '.uid // "error"')
if [[ "$production_uid" != "error" && "$production_uid" != "null" ]]; then
    echo "✅ Production dashboard uploaded" 
    echo "🔗 View: $GRAFANA_URL/d/$production_uid"
else
    echo "❌ Failed to upload production dashboard"
    echo "$production_response" | jq -r '.message // .'
fi

echo ""
echo "🎉 Dashboard upload complete!"
echo ""
echo "📋 Quick Links:"
echo "• All Dashboards: $GRAFANA_URL/dashboards"
echo "• Comprehensive: $GRAFANA_URL/d/$comprehensive_uid"
echo "• Production: $GRAFANA_URL/d/$production_uid"
echo ""
echo "🔑 API Token (save this): $api_token"
echo "💡 Store token for future use:"
echo "   export GRAFANA_API_TOKEN='$api_token'"