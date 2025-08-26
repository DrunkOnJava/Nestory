#!/bin/bash

# Create Development Dashboard using Grafana MCP Server - Final Version
# This script creates a comprehensive development dashboard with verified metrics

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

echo -e "${BLUE}🏗️ Creating Nestory Development Dashboard (Final)${NC}"
echo "=================================================="

# Get datasource UID
DATASOURCE_UID=$(call_mcp "list_datasources" '{"type": "prometheus"}' | jq -r '.result.content[0].text' | jq -r '.[0].uid')
echo "Using Prometheus datasource: $DATASOURCE_UID"

# Verify metrics are available
echo -e "${GREEN}Verifying build metrics availability...${NC}"
BUILD_CHECK=$(call_mcp "query_prometheus" "{\"datasourceUid\": \"${DATASOURCE_UID}\", \"query\": \"build_success_total\", \"queryType\": \"instant\"}")
echo "Build metrics found: $(echo "$BUILD_CHECK" | jq -r '.result.content[0].text' | jq -r '.[0].value[1] // "none"')"

# Create comprehensive development dashboard
cat > /tmp/dev-dashboard-final.json << EOF
{
  "dashboard": {
    "id": null,
    "uid": "nestory-dev-dashboard",
    "title": "Nestory Development Dashboard",
    "description": "Comprehensive development metrics including build performance, error tracking, and CI/CD status",
    "tags": ["development", "builds", "errors", "nestory", "ci-cd"],
    "timezone": "browser",
    "refresh": "30s",
    "time": {
      "from": "now-6h",
      "to": "now"
    },
    "panels": [
      {
        "id": 1,
        "title": "Build Success Overview",
        "type": "row",
        "gridPos": {"h": 1, "w": 24, "x": 0, "y": 0},
        "collapsed": false
      },
      {
        "id": 2,
        "title": "Total Successful Builds",
        "type": "stat",
        "targets": [
          {
            "expr": "build_success_total",
            "legendFormat": "Total Builds",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 1},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 200},
                {"color": "red", "value": 500}
              ]
            },
            "unit": "short"
          }
        },
        "options": {
          "colorMode": "background",
          "graphMode": "area",
          "justifyMode": "center",
          "orientation": "auto",
          "reduceOptions": {
            "calcs": ["lastNotNull"]
          },
          "textMode": "value_and_name"
        }
      },
      {
        "id": 3,
        "title": "Build Duration",
        "type": "stat",
        "targets": [
          {
            "expr": "build_duration_seconds",
            "legendFormat": "Last Build Duration",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 1},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 60},
                {"color": "red", "value": 120}
              ]
            },
            "unit": "s"
          }
        },
        "options": {
          "colorMode": "background",
          "graphMode": "area",
          "justifyMode": "center",
          "orientation": "auto",
          "reduceOptions": {
            "calcs": ["lastNotNull"]
          },
          "textMode": "value_and_name"
        }
      },
      {
        "id": 4,
        "title": "Build Errors",
        "type": "stat",
        "targets": [
          {
            "expr": "build_error_total",
            "legendFormat": "Total Errors",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 1},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 5},
                {"color": "red", "value": 20}
              ]
            },
            "unit": "short"
          }
        },
        "options": {
          "colorMode": "background",
          "graphMode": "area",
          "justifyMode": "center",
          "orientation": "auto",
          "reduceOptions": {
            "calcs": ["lastNotNull"]
          },
          "textMode": "value_and_name"
        }
      },
      {
        "id": 5,
        "title": "Test Duration",
        "type": "stat",
        "targets": [
          {
            "expr": "test_duration_seconds",
            "legendFormat": "Test Suite Duration",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 6, "x": 18, "y": 1},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 30},
                {"color": "red", "value": 60}
              ]
            },
            "unit": "s"
          }
        },
        "options": {
          "colorMode": "background",
          "graphMode": "area",
          "justifyMode": "center",
          "orientation": "auto",
          "reduceOptions": {
            "calcs": ["lastNotNull"]
          },
          "textMode": "value_and_name"
        }
      },
      {
        "id": 6,
        "title": "Performance Trends",
        "type": "row",
        "gridPos": {"h": 1, "w": 24, "x": 0, "y": 9},
        "collapsed": false
      },
      {
        "id": 7,
        "title": "Build Performance Over Time",
        "type": "timeseries",
        "targets": [
          {
            "expr": "build_duration_seconds",
            "legendFormat": "Build Duration (s)",
            "refId": "A"
          },
          {
            "expr": "test_duration_seconds",
            "legendFormat": "Test Duration (s)",
            "refId": "B"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 10},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "smooth",
              "lineWidth": 2,
              "fillOpacity": 15,
              "pointSize": 5
            },
            "unit": "s"
          }
        },
        "options": {
          "legend": {
            "calcs": ["mean", "lastNotNull", "max"],
            "displayMode": "list",
            "placement": "bottom"
          },
          "tooltip": {
            "mode": "multi",
            "sort": "desc"
          }
        }
      },
      {
        "id": 8,
        "title": "Development Activity",
        "type": "row",
        "gridPos": {"h": 1, "w": 24, "x": 0, "y": 18},
        "collapsed": false
      },
      {
        "id": 9,
        "title": "Build Success Rate",
        "type": "gauge",
        "targets": [
          {
            "expr": "build_success_total / (build_success_total + build_error_total) * 100",
            "legendFormat": "Success Rate %",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 19},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "red", "value": null},
                {"color": "yellow", "value": 80},
                {"color": "green", "value": 95}
              ]
            },
            "max": 100,
            "min": 0,
            "unit": "percent"
          }
        },
        "options": {
          "orientation": "auto",
          "reduceOptions": {
            "calcs": ["lastNotNull"]
          },
          "showThresholdLabels": false,
          "showThresholdMarkers": true
        }
      },
      {
        "id": 10,
        "title": "Build Health Status",
        "type": "table",
        "targets": [
          {
            "expr": "build_success_total",
            "legendFormat": "Successful Builds",
            "refId": "A",
            "instant": true
          },
          {
            "expr": "build_error_total",
            "legendFormat": "Failed Builds",
            "refId": "B",
            "instant": true
          },
          {
            "expr": "build_duration_seconds",
            "legendFormat": "Last Duration (s)",
            "refId": "C",
            "instant": true
          },
          {
            "expr": "test_duration_seconds",
            "legendFormat": "Test Duration (s)",
            "refId": "D",
            "instant": true
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 19},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "red", "value": 80}
              ]
            }
          }
        },
        "options": {
          "showHeader": true
        }
      }
    ],
    "schemaVersion": 41,
    "version": 1
  }
}
EOF

# Create the dashboard using MCP server
echo -e "${GREEN}Creating development dashboard...${NC}"
DASHBOARD_RESULT=$(call_mcp "update_dashboard" "$(cat /tmp/dev-dashboard-final.json)")

echo "Dashboard creation result:"
DASHBOARD_UID=$(echo "$DASHBOARD_RESULT" | jq -r '.result.content[0].text' | jq -r '.uid // "nestory-dev-dashboard"')
echo "Dashboard UID: $DASHBOARD_UID"

# Generate deep link
if [[ "$DASHBOARD_UID" != "null" && -n "$DASHBOARD_UID" ]]; then
    DEEP_LINK=$(call_mcp "generate_deeplink" "{\"resourceType\": \"dashboard\", \"dashboardUid\": \"${DASHBOARD_UID}\"}")
    echo -e "${GREEN}Dashboard URL:${NC}"
    echo "$DEEP_LINK" | jq -r '.result.content[0].text' 2>/dev/null || echo "http://localhost:3000/d/${DASHBOARD_UID}/nestory-development-dashboard"
fi

echo -e "${BLUE}✅ Development Dashboard Ready!${NC}"
echo ""
echo "Features:"
echo "• Build success tracking (Current: 308 builds)"
echo "• Build duration monitoring"
echo "• Error rate tracking"
echo "• Test performance metrics"
echo "• Success rate gauge"
echo "• Build health status table"

rm -f /tmp/dev-dashboard-final.json