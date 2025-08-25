#!/bin/bash
# Generate build performance analysis report

MEASUREMENT_LOG="${TMPDIR:-/tmp}/nestory-build-times.log"

echo "📊 Build Performance Report"
echo "=========================="

if [[ -f "$MEASUREMENT_LOG" ]]; then
    echo "Recent Build Times:"
    echo "==================="
    tail -10 "$MEASUREMENT_LOG" | while IFS=' ' read -r date time duration command; do
        printf "  %s %s: %6s (%s)\n" "$date" "$time" "$duration" "$command"
    done
    
    echo ""
    echo "Performance Statistics:"
    echo "======================"
    
    # Calculate average build time
    AVG_TIME=$(tail -10 "$MEASUREMENT_LOG" | awk '{sum+=$3; count++} END {if(count>0) printf "%.2f", sum/count}')
    echo "  Average build time (last 10): ${AVG_TIME}s"
    
    # Find fastest build
    FASTEST=$(tail -20 "$MEASUREMENT_LOG" | awk '{print $3}' | sed 's/s$//' | sort -n | head -1)
    echo "  Fastest build time: ${FASTEST}s"
    
    # Find slowest build  
    SLOWEST=$(tail -20 "$MEASUREMENT_LOG" | awk '{print $3}' | sed 's/s$//' | sort -n | tail -1)
    echo "  Slowest build time: ${SLOWEST}s"
else
    echo "No build measurements found. Run 'make build-measured' to start tracking."
fi

echo ""
echo "Cache Status:"
echo "============="
CACHE_FILE="${TMPDIR:-/tmp}/nestory-file-size-cache.txt"
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
    echo "  File size cache: Valid (${CACHE_AGE}s old)"
else
    echo "  File size cache: Not found"
fi

MODULE_CACHE="./build/OptimizedModuleCache"
if [[ -d "$MODULE_CACHE" ]]; then
    CACHE_SIZE=$(du -sh "$MODULE_CACHE" 2>/dev/null | cut -f1)
    echo "  Module cache: ${CACHE_SIZE}"
else
    echo "  Module cache: Not initialized"
fi
