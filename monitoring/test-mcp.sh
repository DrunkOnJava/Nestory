#!/bin/bash
# Test MCP server functionality

API_TOKEN=$(security find-generic-password -a griffin -s "grafana-api-token" -w)
MCP_DIR="$(dirname "$0")/mcp-grafana"

# Function to call MCP tool
call_mcp() {
    local tool_name="$1"
    local arguments="$2"
    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"${tool_name}\", \"arguments\": ${arguments}}, \"id\": $(date +%s)}" | \
    GRAFANA_URL="http://localhost:3000" GRAFANA_API_KEY="${API_TOKEN}" \
    "${MCP_DIR}/dist/mcp-grafana" -t stdio 2>/dev/null
}

echo "🔍 Searching for iOS dashboards..."
call_mcp "search_dashboards" '{"query": "ios"}' | jq -r '.result.content[0].text'

echo ""
echo "📊 Getting dashboard summary..."
call_mcp "get_dashboard_summary" '{"uid": "nry-ios-telemetry"}' | jq -r '.result.content[0].text' | jq .

echo ""
echo "📈 Listing Prometheus datasources..."
call_mcp "list_datasources" '{"type": "prometheus"}' | jq -r '.result.content[0].text'

echo ""
echo "🔄 Testing Prometheus query..."
DATASOURCE_UID=$(call_mcp "list_datasources" '{"type": "prometheus"}' | jq -r '.result.content[0].text' | jq -r '.[0].uid // "ea586e23-5c0d-4639-bd0e-849a0052fa1c"')
call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"ios_app_launches_total\", \"queryType\": \"instant\"}" | jq -r '.result.content[0].text'
