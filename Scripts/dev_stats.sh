#!/bin/bash
# Development statistics and metrics

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📊 Nestory Development Statistics"
echo "=================================="

# Code statistics
echo "📝 Code Statistics:"
find "$PROJECT_ROOT" -name "*.swift" -not -path "*/build/*" -not -path "*/.git/*" | xargs wc -l | tail -1 | awk '{print "  Swift lines:", $1}'

# Test coverage (if available)
if [[ -f "$PROJECT_ROOT/build/Logs/Test/"*.xccoverage ]]; then
    echo "🧪 Test Coverage: Available in build/Logs/Test/"
fi

# Build cache size
if [[ -d "$PROJECT_ROOT/build" ]]; then
    echo "💾 Build Cache Size: $(du -sh "$PROJECT_ROOT/build" | cut -f1)"
fi

# Git statistics
echo "📋 Git Statistics:"
echo "  Commits: $(git rev-list --count HEAD)"
echo "  Contributors: $(git log --format='%an' | sort -u | wc -l | xargs)"

echo "=================================="
