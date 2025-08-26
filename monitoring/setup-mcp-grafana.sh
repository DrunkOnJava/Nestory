#!/bin/bash

# Setup Grafana MCP Server for Natural Language Dashboard Interaction
# This script configures the MCP server for use with Claude Code or other MCP clients

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'  
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔧 Setting up Grafana MCP Server${NC}"
echo "=================================="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="${SCRIPT_DIR}/mcp-grafana"

# Check if MCP server is built
if [[ ! -f "${MCP_DIR}/dist/mcp-grafana" ]]; then
    echo -e "${YELLOW}Building MCP server...${NC}"
    cd "${MCP_DIR}"
    make build
    cd "${SCRIPT_DIR}"
fi

# Retrieve API token from keychain
echo -e "${GREEN}1. Retrieving Grafana API token from keychain...${NC}"
API_TOKEN=$(security find-generic-password -a griffin -s "grafana-api-token" -w)

# Test token
echo -e "${GREEN}2. Testing API token...${NC}"
response=$(curl -s -w "%{http_code}" -o /tmp/grafana_test.json \
    -H "Authorization: Bearer ${API_TOKEN}" \
    "http://localhost:3000/api/datasources")

if [[ "$response" == "200" ]]; then
    echo -e "✅ API token is valid"
else
    echo -e "❌ API token test failed (HTTP $response)"
    echo "Run the script again to create a new token"
    exit 1
fi

# Create Claude Desktop configuration
echo -e "${GREEN}3. Creating Claude Desktop MCP configuration...${NC}"
cat > "${SCRIPT_DIR}/claude-desktop-mcp-config.json" << EOF
{
  "mcpServers": {
    "grafana": {
      "command": "${MCP_DIR}/dist/mcp-grafana",
      "args": ["-debug"],
      "env": {
        "GRAFANA_URL": "http://localhost:3000",
        "GRAFANA_API_KEY": "${API_TOKEN}"
      }
    }
  }
}
EOF

# Create test script for direct MCP usage
echo -e "${GREEN}4. Creating MCP test script...${NC}"
cat > "${SCRIPT_DIR}/test-mcp.sh" << 'EOF'
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
EOF

chmod +x "${SCRIPT_DIR}/test-mcp.sh"

# Create quick start guide
echo -e "${GREEN}5. Creating usage documentation...${NC}"
cat > "${SCRIPT_DIR}/MCP-GRAFANA-USAGE.md" << 'EOF'
# Grafana MCP Server - Natural Language Dashboard Interaction

The MCP server is now configured and ready for natural language interaction with your iOS telemetry dashboard.

## Available Tools (38 total)

### Dashboard Management
- `search_dashboards` - Find dashboards by name/query
- `get_dashboard_summary` - Get overview without full JSON
- `get_dashboard_property` - Extract specific dashboard parts with JSONPath
- `get_dashboard_by_uid` - Get complete dashboard (large context usage)
- `update_dashboard` - Create or modify dashboards

### Data Querying
- `query_prometheus` - Execute PromQL queries
- `list_prometheus_metric_names` - See available metrics
- `query_loki_logs` - Query logs with LogQL
- `list_datasources` - View configured datasources

### Navigation
- `generate_deeplink` - Create direct URLs to dashboards/panels

### Example Natural Language Queries

**Dashboard Discovery:**
"Show me all iOS-related dashboards"
"What panels are in the Nestory iOS telemetry dashboard?"
"Give me a summary of the iOS dashboard without the full JSON"

**Metric Queries:**
"What's the current value of ios_app_launches_total?"
"Show me HTTP request latency over the last hour"
"List all iOS metrics available in Prometheus"

**Dashboard Navigation:**
"Create a direct link to the iOS telemetry dashboard"
"Generate a URL to the app launches panel"

## Direct Usage

Test the MCP server directly:
```bash
./test-mcp.sh
```

## Claude Desktop Integration

Add the configuration from `claude-desktop-mcp-config.json` to your Claude Desktop settings file.

## Dashboard URLs
- Grafana: http://localhost:3000 (admin/nestory123)  
- Prometheus: http://localhost:9090
- iOS Telemetry Dashboard: http://localhost:3000/d/nry-ios-telemetry/nestory-ios-telemetry
EOF

echo -e "${BLUE}✅ Setup Complete!${NC}"
echo ""
echo -e "${GREEN}📋 What's Ready:${NC}"
echo "• MCP server built and configured"
echo "• API token stored in keychain"
echo "• Claude Desktop config: ${SCRIPT_DIR}/claude-desktop-mcp-config.json"
echo "• Test script: ${SCRIPT_DIR}/test-mcp.sh"
echo "• Usage guide: ${SCRIPT_DIR}/MCP-GRAFANA-USAGE.md"
echo ""
echo -e "${GREEN}🚀 Next Steps:${NC}"
echo "1. Run './test-mcp.sh' to verify functionality"
echo "2. Copy config to Claude Desktop settings"
echo "3. Start using natural language queries!"
echo ""
echo -e "${YELLOW}Natural Language Examples:${NC}"
echo '• "Show me the iOS dashboard summary"'
echo '• "What are the current iOS app launches?"'
echo '• "List all available Prometheus metrics"'
echo '• "Create a link to the battery level panel"'