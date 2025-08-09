#\!/bin/bash
echo "📊 Nestory Metrics Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Files: $(find . -name "*.swift" | wc -l)"
echo "Lines: $(find . -name "*.swift" -exec wc -l {} + | tail -1)"
echo "Tests: $(swift test --list-tests 2>/dev/null | wc -l)"
echo "Coverage: $(swift test --enable-code-coverage 2>&1 | grep coverage | tail -1)"
echo "Commits: $(git rev-list --count HEAD)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
