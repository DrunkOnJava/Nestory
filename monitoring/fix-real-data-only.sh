#!/bin/bash

echo "🎯 Fixing dashboard to show ONLY real live project data - removing all placeholders!"

# Work with current dashboard  
cp monitoring/dashboards/current-dashboard.json monitoring/dashboards/real-data-only.json

echo "1. Response Time Distribution - Using real HTTP request histograms"
# Use the actual HTTP request duration buckets that exist
jq '(.panels[] | select(.id == 22) | .targets[0].expr) = "histogram_quantile(0.50, sum(rate(nestory_http_request_duration_seconds_bucket[5m])) by (le)) * 1000"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

jq '(.panels[] | select(.id == 22) | .targets[1].expr) = "histogram_quantile(0.95, sum(rate(nestory_http_request_duration_seconds_bucket[5m])) by (le)) * 1000"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

jq '(.panels[] | select(.id == 22) | .targets[2].expr) = "histogram_quantile(0.99, sum(rate(nestory_http_request_duration_seconds_bucket[5m])) by (le)) * 1000"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

echo "2. Cache Hit Ratio - Using real cache metrics (no fallback)"
# Remove fallback - show only if cache metrics actually exist
jq '(.panels[] | select(.id == 23) | .targets[0].expr) = "(sum(rate(nestory_cache_hits_total[5m])) / sum(rate(nestory_cache_requests_total[5m]))) * 100"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

echo "3. Database Performance - Using real database metrics (no fallbacks)"  
# Remove fallbacks - show only actual database query times and connections
jq '(.panels[] | select(.id == 24) | .targets[0].expr) = "avg(nestory_database_query_duration_seconds) * 1000"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

jq '(.panels[] | select(.id == 24) | .targets[1].expr) = "nestory_database_connections_active"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

echo "4. System Health - Using real Xcode running status (no fallback)"
# Remove fallback calculation - show actual Xcode running status
jq '(.panels[] | select(.id == 3) | .targets[0].expr) = "(count(nestory_xcode_running > 0) / count(nestory_xcode_running)) * 100"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

echo "5. Build Time Distribution - Remove fallback"
# Only show actual build phase data when it exists
jq '(.panels[] | select(.id == 14) | .targets[0].expr) = "sum by (phase) (nestory_build_phase_duration_seconds)"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

echo "6. Test Suite Performance - Remove fallback"  
# Only show actual test suite data when it exists
jq '(.panels[] | select(.id == 15) | .targets[0].expr) = "avg by (suite) (nestory_test_suite_duration_seconds)"' \
  monitoring/dashboards/real-data-only.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/real-data-only.json

echo "🎯 All fallbacks removed! Dashboard now shows ONLY real live project data."
echo "Panels will show 'No data' when metrics don't exist, which is accurate."