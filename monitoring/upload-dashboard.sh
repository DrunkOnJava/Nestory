#!/bin/bash

# Simple dashboard upload script
# Usage: ./upload-dashboard.sh [grafana-api-token]

GRAFANA_URL="http://localhost:3000"
TOKEN="${1:-$GRAFANA_API_TOKEN}"

if [[ -z "$TOKEN" ]]; then
    echo "❌ No Grafana API token provided"
    echo "Usage: $0 [token]"
    echo "Or set GRAFANA_API_TOKEN environment variable"
    echo ""
    echo "To get a token:"
    echo "1. Go to: $GRAFANA_URL/admin/api-keys"
    echo "2. Click 'Add API key'"
    echo "3. Name: 'Dashboard Upload', Role: 'Admin'"
    echo "4. Copy the token and run:"
    echo "   $0 'your-token-here'"
    exit 1
fi

echo "🚀 Uploading dashboards to Grafana..."

# Upload comprehensive dashboard
echo "📊 Uploading comprehensive dashboard..."
if response=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\": $(cat dashboards/comprehensive-dev.json), \"folderId\": 0, \"overwrite\": true}" \
    "$GRAFANA_URL/api/dashboards/db"); then
    
    uid=$(echo "$response" | jq -r '.uid // "error"')
    if [[ "$uid" != "error" && "$uid" != "null" ]]; then
        echo "✅ Comprehensive dashboard uploaded successfully"
        echo "🔗 URL: $GRAFANA_URL/d/$uid"
    else
        echo "❌ Failed to upload comprehensive dashboard"
        echo "$response" | jq -r '.message // .'
    fi
else
    echo "❌ Failed to connect to Grafana"
fi

echo ""

# Upload production dashboard  
echo "📊 Uploading production dashboard..."
if response=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\": $(cat dashboards/production-prod.json), \"folderId\": 0, \"overwrite\": true}" \
    "$GRAFANA_URL/api/dashboards/db"); then
    
    uid=$(echo "$response" | jq -r '.uid // "error"')
    if [[ "$uid" != "error" && "$uid" != "null" ]]; then
        echo "✅ Production dashboard uploaded successfully"
        echo "🔗 URL: $GRAFANA_URL/d/$uid"
    else
        echo "❌ Failed to upload production dashboard"
        echo "$response" | jq -r '.message // .'
    fi
else
    echo "❌ Failed to connect to Grafana"
fi

echo ""
echo "🎉 Dashboard upload complete!"
echo "📋 View all dashboards: $GRAFANA_URL/dashboards"