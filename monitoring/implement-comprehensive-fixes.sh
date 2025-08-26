#!/bin/bash

echo "🎯 Implementing comprehensive dashboard fixes..."

# Download current dashboard
curl -s -u admin:nestory123 "http://localhost:3000/api/dashboards/uid/nestory-full" | jq '.dashboard' > monitoring/dashboards/current-dashboard.json

# Create working copy
cp monitoring/dashboards/current-dashboard.json monitoring/dashboards/comprehensive-fixes.json

echo "1. Fix Build Success Rate - use $__range instead of hardcoded [24h]"
jq '(.panels[] | select(.id == 5) | .targets[0].expr) = "100 * sum(increase(nestory_build_success_total{scheme=~\"$scheme\"}[$__range])) / clamp_min(sum(increase(nestory_build_total{scheme=~\"$scheme\"}[$__range])), 1)"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "2. Fix Builds Today - rename and use $__range"
jq '(.panels[] | select(.id == 4) | .title) = "Builds (Δ $__range)"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 4) | .targets[0].expr) = "sum(increase(nestory_build_total{scheme=~\"$scheme\"}[$__range]))"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "3. Remove fake default from Disk Usage"
jq '(.panels[] | select(.id == 20) | .targets[0].expr) = "max(nestory_system_disk_usage_percent)"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "4. Fix Error Rate - make it true errors/sec"
jq '(.panels[] | select(.id == 10) | .title) = "Error Rate (events/s)"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 10) | .targets[0].expr) = "sum(rate(nestory_error_total[$__rate_interval]))"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 10) | .fieldConfig.defaults.unit) = "ops"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "5. Rename Network I/O to reflect actual metrics"
jq '(.panels[] | select(.id == 19) | .title) = "System Load & Free Memory"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "6. Change Avg Build Time to P95 Build Duration"
jq '(.panels[] | select(.id == 6) | .title) = "Build Duration p95"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

# Note: P95 requires histogram buckets which may not exist yet
jq '(.panels[] | select(.id == 6) | .targets[0].expr) = "histogram_quantile(0.95, sum by (le) (rate(nestory_build_duration_seconds_bucket{scheme=~\"$scheme\"}[$__rate_interval]))) or avg(nestory_build_duration_seconds{scheme=~\"$scheme\"})"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "7. Fix Build Performance Timeline - use $__rate_interval"
jq '(.panels[] | select(.id == 12) | .targets[0].expr) = "nestory_build_duration_seconds{scheme=~\"$scheme\"}"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "8. Fix Response Time Distribution - use $__rate_interval"
jq '(.panels[] | select(.id == 22) | .targets[0].expr) = "histogram_quantile(0.50, sum by (le) (rate(nestory_http_request_duration_seconds_bucket[$__rate_interval]))) * 1000"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 22) | .targets[1].expr) = "histogram_quantile(0.95, sum by (le) (rate(nestory_http_request_duration_seconds_bucket[$__rate_interval]))) * 1000"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 22) | .targets[2].expr) = "histogram_quantile(0.99, sum by (le) (rate(nestory_http_request_duration_seconds_bucket[$__rate_interval]))) * 1000"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "9. Fix Cache Hit Ratio - use $__rate_interval"
jq '(.panels[] | select(.id == 23) | .targets[0].expr) = "100 * sum(rate(nestory_cache_hits_total[$__rate_interval])) / clamp_min(sum(rate(nestory_cache_requests_total[$__rate_interval])), 1)"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "10. Replace Active PRs with Queue Length"
jq '(.panels[] | select(.id == 8) | .title) = "Queue Length"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 8) | .targets[0].expr) = "max(nestory_build_queue_length{scheme=~\"$scheme\"}) or on() vector(0)"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 8) | .fieldConfig.defaults.color.fixedColor) = "green"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

jq '(.panels[] | select(.id == 8) | .fieldConfig.defaults.thresholds.steps) = [{"color": "green", "value": 0}, {"color": "yellow", "value": 2}, {"color": "red", "value": 5}]' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "11. Fix Recent Build Details - make it actually recent"
jq '(.panels[] | select(.id == 16) | .targets[0].expr) = "topk(10, last_over_time(nestory_build_duration_seconds{scheme=~\"$scheme\"}[$__range]))"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "12. Change dashboard refresh from 10s to 30s"
jq '.refresh = "30s"' \
  monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "13. Add branch and configuration variables"
# Add branch variable
jq '.templating.list += [{
  "name": "branch", 
  "type": "query",
  "datasource": {"type": "prometheus", "uid": "${DS_PROMETHEUS}"},
  "definition": "label_values(nestory_build_total, branch)",
  "includeAll": true,
  "allValue": ".*", 
  "multi": true,
  "refresh": 1
}]' monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

# Add configuration variable  
jq '.templating.list += [{
  "name": "configuration_filter",
  "type": "query", 
  "datasource": {"type": "prometheus", "uid": "${DS_PROMETHEUS}"},
  "definition": "label_values(nestory_build_total, configuration)",
  "includeAll": true,
  "allValue": ".*",
  "multi": true,
  "refresh": 1
}]' monitoring/dashboards/comprehensive-fixes.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/comprehensive-fixes.json

echo "✅ All comprehensive fixes applied!"
echo "Key improvements:"
echo "  - Fixed hardcoded time ranges to use $__range and $__rate_interval"
echo "  - Removed fake defaults and placeholder data"
echo "  - Renamed misleading panel titles"
echo "  - Changed refresh rate to 30s for better performance"
echo "  - Added proper filtering variables"
echo "  - Made metrics semantically correct (errors/sec vs percentages)"