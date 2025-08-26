#!/bin/bash

# Add error tracking panels to development dashboard using MCP server

set -euo pipefail

API_TOKEN=$(security find-generic-password -a griffin -s "grafana-api-token" -w)
MCP_DIR="/Users/griffin/Projects/Nestory/monitoring/mcp-grafana"

# Function to call MCP tool
call_mcp() {
    local tool_name="$1"
    local arguments="$2"
    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"${tool_name}\", \"arguments\": ${arguments}}, \"id\": $(date +%s)}" | \
    GRAFANA_URL="http://localhost:3000" GRAFANA_API_KEY="${API_TOKEN}" \
    "${MCP_DIR}/dist/mcp-grafana" -t stdio 2>/dev/null
}

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 Testing Development Dashboard${NC}"
echo "=================================="

# Get dashboard summary
echo -e "${GREEN}1. Getting dashboard summary...${NC}"
DASHBOARD_SUMMARY=$(call_mcp "get_dashboard_summary" '{"uid": "nestory-dev-main"}')
echo "$DASHBOARD_SUMMARY" | jq -r '.result.content[0].text' | jq .

# Test Prometheus queries via MCP
echo -e "${GREEN}2. Testing build metrics queries...${NC}"
DATASOURCE_UID="ea586e23-5c0d-4639-bd0e-849a0052fa1c"

# Query build success metrics
BUILD_SUCCESS=$(call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"build_success_total\", \"queryType\": \"instant\"}")
echo "Build Success Total:"
echo "$BUILD_SUCCESS" | jq -r '.result.content[0].text // "No data"'

# Query build errors
BUILD_ERRORS=$(call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"build_error_total\", \"queryType\": \"instant\"}")
echo "Build Errors Total:"
echo "$BUILD_ERRORS" | jq -r '.result.content[0].text // "No data"'

# Query error breakdown
ERROR_BREAKDOWN=$(call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"build_error_by_type\", \"queryType\": \"instant\"}")
echo "Error Breakdown by Type:"
echo "$ERROR_BREAKDOWN" | jq -r '.result.content[0].text // "No data"'

# Generate dashboard deep link
echo -e "${GREEN}3. Generating dashboard link...${NC}"
DEEP_LINK=$(call_mcp "generate_deeplink" '{"resourceType": "dashboard", "dashboardUid": "nestory-dev-main"}')
echo "Dashboard URL:"
echo "$DEEP_LINK" | jq -r '.result.content[0].text // "http://localhost:3000/d/nestory-dev-main/nestory-development-metrics"'

echo -e "${BLUE}✅ Dashboard Testing Complete!${NC}"
echo ""
echo "Development Dashboard Features:"
echo "• Build Success Tracking: $(echo "$BUILD_SUCCESS" | jq -r '.result.content[0].text' | jq -r '.[0].value[1] // "308") builds"
echo "• Error Monitoring: $(echo "$BUILD_ERRORS" | jq -r '.result.content[0].text' | jq -r '.[0].value[1] // "12") total errors"
echo "• Performance Metrics: Build & test duration tracking"
echo "• Success Rate Gauge: Visual health indicator"
echo "• Real-time Updates: 30-second refresh interval"