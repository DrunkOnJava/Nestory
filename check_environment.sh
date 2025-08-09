#\!/bin/bash
echo "🔍 Checking environment..."

# Check Xcode
if \! xcode-select -p &> /dev/null; then
    echo "❌ Xcode not found. Install from App Store."
    exit 1
fi
echo "✅ Xcode: $(xcodebuild -version | head -1)"

# Check Swift
echo "✅ Swift: $(swift --version | head -1)"

# Check Claude Code CLI
if \! command -v claude-code &> /dev/null; then
    echo "⚠️  Claude Code CLI not found. Install from: https://docs.anthropic.com/en/docs/claude-code"
else
    echo "✅ Claude Code CLI installed"
fi

# Check for required tools
for tool in git xcodegen; do
    if \! command -v $tool &> /dev/null; then
        echo "⚠️  $tool not found. Run: brew install $tool"
    else
        echo "✅ $tool installed"
    fi
done

echo "🎯 Environment check complete\!"
