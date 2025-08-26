#!/bin/bash

# Create Development Dashboard using Grafana MCP Server
# This script uses MCP tools to build a comprehensive dev dashboard

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

echo -e "${BLUE}🏗️ Creating Nestory Development Dashboard${NC}"
echo "=============================================="

# First, let's check what Prometheus metrics are available
echo -e "${GREEN}1. Checking available build metrics...${NC}"
DATASOURCE_UID=$(call_mcp "list_datasources" '{"type": "prometheus"}' | jq -r '.result.content[0].text' | jq -r '.[0].uid')
echo "Using Prometheus datasource: $DATASOURCE_UID"

# Query for build metrics
echo -e "${GREEN}2. Querying existing build metrics...${NC}"
BUILD_METRICS=$(call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"nestory_build_success_total\", \"queryType\": \"instant\"}")
echo "Build success metrics: $BUILD_METRICS"

ERROR_METRICS=$(call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"nestory_error_total\", \"queryType\": \"instant\"}")
echo "Error metrics: $ERROR_METRICS"

# Create development dashboard JSON
echo -e "${GREEN}3. Creating development dashboard JSON...${NC}"
cat > /tmp/dev-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Nestory Development Dashboard",
    "description": "Comprehensive development metrics including build times, error tracking, and CI/CD status",
    "tags": ["development", "builds", "errors", "nestory", "ci-cd"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Build Success Rate",
        "type": "timeseries",
        "targets": [
          {
            "expr": "rate(nestory_build_success_total[1h]) * 3600",
            "legendFormat": "Builds/hour",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "smooth",
              "lineWidth": 2,
              "fillOpacity": 15
            },
            "unit": "reqps"
          }
        }
      },
      {
        "id": 2,
        "title": "Build Duration",
        "type": "timeseries", 
        "targets": [
          {
            "expr": "nestory_build_duration_seconds",
            "legendFormat": "{{scheme}}-{{configuration}}",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "smooth",
              "lineWidth": 2
            },
            "unit": "s"
          }
        }
      },
      {
        "id": 3,
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(nestory_error_total[5m]) * 300",
            "legendFormat": "Errors/5min",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 4, "w": 6, "x": 0, "y": 8},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 1},
                {"color": "red", "value": 5}
              ]
            }
          }
        }
      },
      {
        "id": 4,
        "title": "Total Builds",
        "type": "stat",
        "targets": [
          {
            "expr": "nestory_build_success_total",
            "legendFormat": "Total Builds",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 4, "w": 6, "x": 6, "y": 8},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null}
              ]
            },
            "unit": "short"
          }
        }
      },
      {
        "id": 5,
        "title": "App Cold Start Performance",
        "type": "timeseries",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, nestory_app_cold_start_ms_bucket)",
            "legendFormat": "95th percentile",
            "refId": "A"
          },
          {
            "expr": "histogram_quantile(0.50, nestory_app_cold_start_ms_bucket)",
            "legendFormat": "50th percentile",
            "refId": "B"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "smooth",
              "lineWidth": 2
            },
            "unit": "ms"
          }
        }
      },
      {
        "id": 6,
        "title": "Deployment Success Rate", 
        "type": "timeseries",
        "targets": [
          {
            "expr": "rate(nestory_deployment_success_total[1h]) * 3600",
            "legendFormat": "Deployments/hour",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 6, "w": 24, "x": 0, "y": 16},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {
              "drawStyle": "bars",
              "lineWidth": 1,
              "fillOpacity": 80
            },
            "unit": "reqps"
          }
        }
      }
    ],
    "time": {
      "from": "now-6h",
      "to": "now"
    },
    "refresh": "30s",
    "schemaVersion": 41,
    "version": 1
  }
}
EOF

# Create the dashboard using MCP server
echo -e "${GREEN}4. Creating dashboard via MCP server...${NC}"
DASHBOARD_JSON=$(cat /tmp/dev-dashboard.json)
DASHBOARD_RESULT=$(call_mcp "update_dashboard" "{\"dashboard\": $(cat /tmp/dev-dashboard.json | jq '.dashboard')}")

echo "Dashboard creation result:"
echo "$DASHBOARD_RESULT" | jq -r '.result.content[0].text' 2>/dev/null || echo "$DASHBOARD_RESULT"

# Generate deep link to the new dashboard
echo -e "${GREEN}5. Generating dashboard link...${NC}"
DASHBOARD_UID=$(echo "$DASHBOARD_RESULT" | jq -r '.result.content[0].text' | jq -r '.uid' 2>/dev/null)
if [[ "$DASHBOARD_UID" != "null" && -n "$DASHBOARD_UID" ]]; then
    DEEP_LINK=$(call_mcp "generate_deeplink" "{\"resourceType\": \"dashboard\", \"dashboardUid\": \"${DASHBOARD_UID}\"}")
    echo "Dashboard deep link:"
    echo "$DEEP_LINK" | jq -r '.result.content[0].text' 2>/dev/null || echo "$DEEP_LINK"
fi

echo -e "${BLUE}✅ Development Dashboard Created!${NC}"
echo ""
echo "Dashboard features:"
echo "• Build success rate and timing metrics"
echo "• Error tracking and alerting"
echo "• App performance monitoring" 
echo "• Deployment success tracking"
echo "• Real-time CI/CD status"

rm -f /tmp/dev-dashboard.json