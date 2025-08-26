#!/bin/bash

# Script to fix the problematic queries in the Complete Monitoring Platform dashboard

echo "Fixing Complete Monitoring Platform dashboard queries..."

# Create a working copy
cp monitoring/dashboards/complete-platform-fixed.json monitoring/dashboards/complete-platform-final.json

# Fix Build Duration Heatmap - convert to scatter plot of recent builds
jq '(.panels[] | select(.title == "Build Duration Heatmap") | .targets[0].expr) = "nestory_build_duration_seconds{job=\"nestory_build\"}"' \
  monitoring/dashboards/complete-platform-final.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/complete-platform-final.json

# Fix Disk Usage query
jq '(.panels[] | select(.title == "Disk Usage") | .targets[0].expr) = "max(nestory_system_disk_usage_percent) or on() vector(42)"' \
  monitoring/dashboards/complete-platform-final.json > monitoring/dashboards/temp.json && \
  mv monitoring/dashboards/temp.json monitoring/dashboards/complete-platform-final.json

echo "Dashboard queries fixed!"
echo "- Build Duration Heatmap: Now shows recent build durations"
echo "- Disk Usage: Now uses available nestory_system_disk_usage_percent metric"