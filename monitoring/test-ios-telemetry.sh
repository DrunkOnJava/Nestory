#!/bin/bash

# Test iOS telemetry pipeline end-to-end
# Sends sample OTLP metrics to collector and verifies in Prometheus

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📱 Testing iOS Telemetry Pipeline${NC}"
echo "================================="

# Test 1: Send a sample metric via OTLP HTTP
echo -e "${GREEN}1. Sending test metric to collector...${NC}"

# Generate timestamp
timestamp_nano="$(date +%s)000000000"

# OTLP JSON payload for a simple counter metric  
test_payload=$(cat << EOF
{
  "resourceMetrics": [
    {
      "resource": {
        "attributes": [
          {"key": "service.name", "value": {"stringValue": "nestory-ios-test"}},
          {"key": "service.version", "value": {"stringValue": "1.0.0"}},
          {"key": "telemetry.sdk.language", "value": {"stringValue": "swift"}}
        ]
      },
      "scopeMetrics": [
        {
          "scope": {
            "name": "nestory.ios.test"
          },
          "metrics": [
            {
              "name": "ios_app_launches_total",
              "description": "Test app launches counter",
              "unit": "1",
              "sum": {
                "dataPoints": [
                  {
                    "attributes": [
                      {"key": "type", "value": {"stringValue": "test"}},
                      {"key": "environment", "value": {"stringValue": "dev"}}
                    ],
                    "asInt": "1",
                    "timeUnixNano": "$timestamp_nano"
                  }
                ],
                "aggregationTemporality": 2,
                "isMonotonic": true
              }
            }
          ]
        }
      ]
    }
  ]
}
EOF
)

# Send to collector
response=$(curl -s -w "%{http_code}" -o /tmp/otlp_response.json \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$test_payload" \
  http://localhost:4318/v1/metrics)

if [[ "$response" == "200" ]]; then
    echo -e "✅ Collector accepted metric (HTTP 200)"
else
    echo -e "❌ Collector rejected metric (HTTP $response)"
    echo "Response: $(cat /tmp/otlp_response.json)"
    exit 1
fi

# Test 2: Wait and check Prometheus
echo -e "${GREEN}2. Waiting for metric to appear in Prometheus...${NC}"
sleep 10

prometheus_response=$(curl -s "http://localhost:9090/api/v1/query?query=ios_app_launches_total")
metric_count=$(echo "$prometheus_response" | jq -r '.data.result | length')

if [[ "$metric_count" -gt 0 ]]; then
    echo -e "✅ Metric found in Prometheus ($metric_count series)"
    # Show the metric
    echo "$prometheus_response" | jq -r '.data.result[] | "  " + .metric.__name__ + "{" + (.metric | to_entries | map(.key + "=\"" + .value + "\"") | join(",")) + "} = " + .value[1]'
else
    echo -e "❌ Metric not found in Prometheus"
    echo "Available metrics:"
    curl -s "http://localhost:9090/api/v1/label/__name__/values" | jq -r '.data[] | select(test("ios_")) | "  " + .'
fi

# Test 3: Check Grafana can query the data
echo -e "${GREEN}3. Testing Grafana data source...${NC}"

# Login to Grafana and get session
grafana_login=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"user":"admin","password":"nestory123"}' \
  http://localhost:3000/login)

if echo "$grafana_login" | grep -q "Logged in"; then
    echo -e "✅ Grafana authentication successful"
else
    echo -e "❌ Grafana authentication failed"
fi

# Test datasource
datasource_test=$(curl -s -u admin:nestory123 \
  "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=ios_app_launches_total")

if echo "$datasource_test" | jq -e '.data.result | length > 0' >/dev/null 2>&1; then
    echo -e "✅ Grafana can query Prometheus data"
else
    echo -e "⚠️  Grafana datasource may need configuration"
fi

echo ""
echo -e "${GREEN}📊 Dashboard URLs:${NC}"
echo -e "Grafana: http://localhost:3000 (admin/nestory123)"
echo -e "Prometheus: http://localhost:9090"
echo ""

echo -e "${BLUE}📱 iOS Integration Ready!${NC}"
echo "Your iOS app can now send telemetry to:"
echo "  OTLP Endpoint: http://localhost:4318"
echo ""
echo "Next steps:"
echo "1. Add OpenTelemetry-Swift to your iOS project"
echo "2. Initialize TelemetryBootstrap in your app"
echo "3. Use InstrumentedHTTPClient for network requests"
echo "4. View real-time metrics in Grafana"

rm -f /tmp/otlp_response.json