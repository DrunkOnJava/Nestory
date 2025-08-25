#!/bin/bash
# Measure and track build performance improvements

MEASUREMENT_LOG="${TMPDIR:-/tmp}/nestory-build-times.log"

echo "🏗️  Starting measured build..."
START_TIME=$(date +%s.%3N)

# Run the actual build
"$@"
BUILD_EXIT_CODE=$?

END_TIME=$(date +%s.%3N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc -l)

# Log the measurement
echo "$(date '+%Y-%m-%d %H:%M:%S') ${DURATION}s $*" >> "$MEASUREMENT_LOG"
echo "⏱️  Build completed in ${DURATION}s"

# Show recent performance trends
echo "📊 Recent build times:"
tail -5 "$MEASUREMENT_LOG" | while read -r line; do
    echo "   $line"
done

exit $BUILD_EXIT_CODE
