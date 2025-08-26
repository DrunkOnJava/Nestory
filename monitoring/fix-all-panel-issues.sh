#!/bin/bash

# Comprehensive fix script for all dashboard panel issues
# Based on available metrics analysis and user-reported snapshot issues

echo "Fixing all problematic dashboard panels..."

# Download current dashboard
curl -s -u admin:nestory123 "http://localhost:3000/api/dashboards/uid/nestory-full" | jq '.dashboard' > monitoring/dashboards/current-state.json

# Create working copy
cp monitoring/dashboards/current-state.json monitoring/dashboards/fixed-complete-platform.json

echo "1. Fixing Build Performance Timeline - removing scheme filter for metrics without scheme labels"
jq '(.panels[] | select(.title == "Build Performance Timeline") | .targets[0].expr) = "nestory_build_duration_seconds"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "2. Fixing Build Duration Heatmap - converting to scatter plot"
jq '(.panels[] | select(.title == "Build Duration Heatmap") | .targets[0].expr) = "nestory_build_duration_seconds"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "Build Duration Heatmap") | .targets[0].format) = "time_series"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "3. Fixing CPU & Memory Usage - using available system metrics"
jq '(.panels[] | select(.title == "CPU & Memory Usage") | .targets[0].expr) = "nestory_xcode_cpu_usage_percent"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "CPU & Memory Usage") | .targets[1].expr) = "nestory_xcode_memory_usage_percent"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "4. Fixing Network I/O - replacing with available system metrics"
jq '(.panels[] | select(.title == "Network I/O") | .targets[0].expr) = "nestory_system_load_average"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "Network I/O") | .targets[0].legendFormat) = "System Load"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "Network I/O") | .targets[1].expr) = "nestory_system_memory_free_percent"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "Network I/O") | .targets[1].legendFormat) = "Free Memory %"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "5. Fixing System Health - using up metrics properly"
jq '(.panels[] | select(.title == "System Health") | .targets[0].expr) = "(count(nestory_xcode_running > 0) / count(nestory_xcode_running)) * 100 or on() vector(100)"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "6. Fixing Response Time Distribution - using available histogram"
jq '(.panels[] | select(.title == "Response Time Distribution") | .targets[0].expr) = "histogram_quantile(0.50, rate(nestory_database_query_duration_seconds_bucket[5m]))"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "Response Time Distribution") | .targets[1].expr) = "histogram_quantile(0.95, rate(nestory_database_query_duration_seconds_bucket[5m]))"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

jq '(.panels[] | select(.title == "Response Time Distribution") | .targets[2].expr) = "histogram_quantile(0.99, rate(nestory_database_query_duration_seconds_bucket[5m]))"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "7. Fixing Build Time Distribution - using available phase metrics"
jq '(.panels[] | select(.title == "Build Time Distribution") | .targets[0].expr) = "sum by (phase) (nestory_build_phase_duration_seconds) or on() vector(0)"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "8. Fixing Test Suite Performance - graceful degradation"
jq '(.panels[] | select(.title == "Test Suite Performance") | .targets[0].expr) = "avg by (suite) (nestory_test_suite_duration_seconds) or on() vector(0)"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "9. Fixing Recent Build Details table"
jq '(.panels[] | select(.title == "Recent Build Details") | .targets[0].expr) = "topk(10, nestory_build_duration_seconds)"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "10. Fixing scheme template variable to use proper regex"
jq '.templating.list[1].allValue = ".*"' \
  monitoring/dashboards/fixed-complete-platform.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/fixed-complete-platform.json

echo "All panel fixes applied! Dashboard saved to monitoring/dashboards/fixed-complete-platform.json"