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
