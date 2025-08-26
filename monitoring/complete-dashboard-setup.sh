#!/bin/bash

# Complete dashboard setup - handles Grafana auth and uploads dashboards
set -e

GRAFANA_URL="http://localhost:3000"
ADMIN_USER="admin"
ADMIN_PASS="admin"
NEW_ADMIN_PASS="nestory123"

echo "🚀 Complete Dashboard Setup"
echo "═══════════════════════════"
echo ""

# Check if Grafana is running
echo "🏥 Checking Grafana connectivity..."
if ! curl -s "$GRAFANA_URL/api/health" > /dev/null; then
    echo "❌ Cannot connect to Grafana at $GRAFANA_URL"
    echo "💡 Make sure Grafana is running"
    echo "   Docker: docker run -d --name grafana -p 3000:3000 grafana/grafana"
    echo "   Homebrew: brew services start grafana"
    exit 1
fi

health_info=$(curl -s "$GRAFANA_URL/api/health" | jq -r '.version // "unknown"')
echo "✅ Grafana is running (version: $health_info)"
echo ""

# Function to test admin credentials
test_auth() {
    local user="$1"
    local pass="$2"
    curl -s -X GET "$user:$pass@$GRAFANA_URL/api/admin/stats" > /dev/null 2>&1
}

# Try default credentials first
echo "🔐 Testing authentication..."
if test_auth "$ADMIN_USER" "$ADMIN_PASS"; then
    echo "✅ Default admin credentials work (admin/admin)"
    CURRENT_PASS="$ADMIN_PASS"
elif test_auth "$ADMIN_USER" "$NEW_ADMIN_PASS"; then
    echo "✅ Custom admin credentials work (admin/$NEW_ADMIN_PASS)"
    CURRENT_PASS="$NEW_ADMIN_PASS"
else
    echo "⚠️ Cannot authenticate with admin credentials"
    echo "🔧 Attempting to reset admin password..."
    
    # Try to reset password using grafana-cli
    if command -v grafana-cli >/dev/null 2>&1; then
        if grafana-cli admin reset-admin-password "$NEW_ADMIN_PASS" 2>/dev/null; then
            echo "✅ Admin password reset successfully"
            CURRENT_PASS="$NEW_ADMIN_PASS"
        else
            echo "❌ Failed to reset admin password"
            echo "💡 Manual steps:"
            echo "   1. Stop Grafana"
            echo "   2. Run: grafana-cli admin reset-admin-password $NEW_ADMIN_PASS"
            echo "   3. Start Grafana"
            echo "   4. Run this script again"
            exit 1
        fi
    else
        echo "❌ grafana-cli not found"
        echo "💡 Please manually create an API token at: $GRAFANA_URL/admin/api-keys"
        echo "   Then run: ./upload-dashboard.sh 'your-token'"
        exit 1
    fi
fi

echo ""

# Create API key using legacy method (simpler and more reliable)
echo "🔑 Creating API key..."
api_key_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"nestory-dashboard-$(date +%s)\", \"role\": \"Admin\"}" \
    "$ADMIN_USER:$CURRENT_PASS@$GRAFANA_URL/api/auth/keys")

api_key=$(echo "$api_key_response" | jq -r '.key // empty')

if [[ -z "$api_key" ]]; then
    echo "❌ Failed to create API key"
    echo "Response: $api_key_response"
    
    # Fallback: try service account method
    echo "🔄 Trying service account method..."
    
    # Create service account
    sa_response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{"name": "nestory-monitoring", "role": "Admin"}' \
        "$ADMIN_USER:$CURRENT_PASS@$GRAFANA_URL/api/serviceaccounts")
    
    sa_id=$(echo "$sa_response" | jq -r '.id // empty')
    
    if [[ -n "$sa_id" ]]; then
        # Create token for service account
        token_response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "{\"name\": \"nestory-token-$(date +%s)\"}" \
            "$ADMIN_USER:$CURRENT_PASS@$GRAFANA_URL/api/serviceaccounts/$sa_id/tokens")
        
        api_key=$(echo "$token_response" | jq -r '.key // empty')
    fi
    
    if [[ -z "$api_key" ]]; then
        echo "❌ All authentication methods failed"
        echo "💡 Please manually create a token and use: ./upload-dashboard.sh 'your-token'"
        exit 1
    fi
fi

echo "✅ Created API token: ${api_key:0:10}...${api_key: -10}"
echo ""

# Store token for future use
export GRAFANA_API_TOKEN="$api_key"

# Upload dashboards
echo "📊 Uploading dashboards..."
echo ""

# Upload comprehensive dashboard
echo "📈 Uploading comprehensive dashboard (15 panels)..."
comp_response=$(curl -s -X POST \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\": $(cat dashboards/comprehensive-dev.json), \"folderId\": 0, \"overwrite\": true}" \
    "$GRAFANA_URL/api/dashboards/db")

comp_uid=$(echo "$comp_response" | jq -r '.uid // "error"')
comp_url=$(echo "$comp_response" | jq -r '.url // ""')

if [[ "$comp_uid" != "error" && "$comp_uid" != "null" ]]; then
    echo "✅ Comprehensive dashboard uploaded successfully"
    echo "🔗 Direct link: $GRAFANA_URL$comp_url"
else
    echo "❌ Failed to upload comprehensive dashboard"
    echo "$(echo "$comp_response" | jq -r '.message // .')"
fi

echo ""

# Upload production dashboard  
echo "📊 Uploading production dashboard (10 panels)..."
prod_response=$(curl -s -X POST \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\": $(cat dashboards/production-prod.json), \"folderId\": 0, \"overwrite\": true}" \
    "$GRAFANA_URL/api/dashboards/db")

prod_uid=$(echo "$prod_response" | jq -r '.uid // "error"')
prod_url=$(echo "$prod_response" | jq -r '.url // ""')

if [[ "$prod_uid" != "error" && "$prod_uid" != "null" ]]; then
    echo "✅ Production dashboard uploaded successfully"
    echo "🔗 Direct link: $GRAFANA_URL$prod_url"
else
    echo "❌ Failed to upload production dashboard"
    echo "$(echo "$prod_response" | jq -r '.message // .')"
fi

echo ""
echo "🎉 Dashboard setup complete!"
echo ""
echo "═══════════════════════════════════════"
echo "📊 DASHBOARD QUICK ACCESS"
echo "═══════════════════════════════════════"
echo ""
echo "🏠 Grafana Home: $GRAFANA_URL"
echo "📋 All Dashboards: $GRAFANA_URL/dashboards"
echo ""
echo "📈 Comprehensive Dashboard: $GRAFANA_URL$comp_url"
echo "   • 15 panels across 4 sections"
echo "   • Executive overview, infrastructure, CI/CD, application metrics"
echo ""
echo "📊 Production Dashboard: $GRAFANA_URL$prod_url" 
echo "   • 10 critical panels"
echo "   • SLOs, production infrastructure, performance"
echo ""
echo "🔑 Your API Token: $api_key"
echo "💾 Save for future use: export GRAFANA_API_TOKEN='$api_key'"
echo ""