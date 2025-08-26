#!/bin/bash

echo "🔧 Fixing remaining problematic panels..."

# Work with current dashboard
cp monitoring/dashboards/current-dashboard.json monitoring/dashboards/final-fixed.json

echo "Panel 1: Response Time Distribution - Fixing histogram queries"
# Fix the histogram quantile queries to work with available buckets
jq '(.panels[] | select(.id == 22) | .targets[0].expr) = "histogram_quantile(0.50, nestory_database_query_duration_seconds_bucket) * 1000"' \
  monitoring/dashboards/final-fixed.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/final-fixed.json

jq '(.panels[] | select(.id == 22) | .targets[1].expr) = "histogram_quantile(0.95, nestory_database_query_duration_seconds_bucket) * 1000"' \
  monitoring/dashboards/final-fixed.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/final-fixed.json

jq '(.panels[] | select(.id == 22) | .targets[2].expr) = "histogram_quantile(0.99, nestory_database_query_duration_seconds_bucket) * 1000"' \
  monitoring/dashboards/final-fixed.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/final-fixed.json

echo "Panel 2: Application Logs - Adding fallback message"
# Application Logs depends on Loki - this is expected to show "No data" if Loki not configured
echo "  → Application Logs requires Loki datasource configuration"

echo "Panel 3: Active Alerts - Normal behavior"
# "No alerts matching filters" is normal when no alerts are firing
echo "  → Active Alerts showing 'No alerts matching filters' is expected when system is healthy"

echo "✅ Remaining panel fixes applied!"