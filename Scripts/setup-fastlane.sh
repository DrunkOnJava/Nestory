#!/bin/bash
# Setup script for Fastlane dependencies

set -euo pipefail

echo "🔧 Setting up Fastlane dependencies..."

# Check for Ruby
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby is not installed. Please install Ruby first."
    echo "   On macOS: brew install ruby"
    exit 1
fi

echo "✅ Ruby found: $(ruby --version)"

# Check for bundler
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing bundler..."
    gem install bundler
fi

echo "✅ Bundler found: $(bundle --version)"

# Install dependencies
echo "📦 Installing gems..."
cd "$(dirname "$0")/.."

# Create minimal Gemfile if needed
if [ ! -f "Gemfile" ]; then
    cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "fastlane", "~> 2.220"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
EOF
fi

# Install
bundle install

echo "✅ Setup complete!"
echo ""
echo "Available Fastlane commands:"
echo "  bundle exec fastlane test         - Run tests"
echo "  bundle exec fastlane screenshots   - Capture screenshots"
echo "  bundle exec fastlane beta         - Deploy to TestFlight"
echo ""
echo "For all lanes: bundle exec fastlane lanes"