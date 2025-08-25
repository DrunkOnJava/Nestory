#!/bin/bash
# Smart file size checking with caching to reduce repeated overhead

CACHE_FILE="${TMPDIR:-/tmp}/nestory-file-size-cache.txt"
CACHE_DURATION=3600  # 1 hour in seconds

# Check if cache is still valid
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if (( CACHE_AGE < CACHE_DURATION )); then
        echo "📏 Using cached file size results (age: ${CACHE_AGE}s)"
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Run full file size check and cache results
echo "📏 Running file size check (caching for ${CACHE_DURATION}s)..."
"$(dirname "$0")/check-file-sizes.sh" | tee "$CACHE_FILE"
