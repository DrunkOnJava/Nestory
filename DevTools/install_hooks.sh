#!/bin/sh
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📦 Installing Nestory pre-commit hooks..."

# Find project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_DIR="${PROJECT_ROOT}/.git/hooks"

# Check if .git directory exists
if [ ! -d "${PROJECT_ROOT}/.git" ]; then
    echo "${RED}❌ Error: Not a git repository${NC}"
    echo "Please run this from the project root after 'git init'"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "${HOOKS_DIR}"

# Create pre-commit hook that uses enhanced validation
cat > "${HOOKS_DIR}/pre-commit" << 'EOF'
#!/bin/sh
set -e

# Enhanced Pre-commit Hook for Nestory
# Delegates to comprehensive validation system

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
ENHANCED_HOOK="${PROJECT_ROOT}/DevTools/enhanced-pre-commit.sh"

# Check if enhanced hook exists
if [ ! -f "$ENHANCED_HOOK" ]; then
    echo "❌ Enhanced pre-commit script not found at: $ENHANCED_HOOK"
    echo "Please ensure the automation suite is properly installed."
    exit 1
fi

# Make sure it's executable
chmod +x "$ENHANCED_HOOK"

# Run enhanced validation
echo "🚀 Running enhanced pre-commit validation..."
exec "$ENHANCED_HOOK"
EOF

# Make pre-commit hook executable
chmod +x "${HOOKS_DIR}/pre-commit"

echo "${GREEN}✅ Pre-commit hooks installed successfully!${NC}"
echo ""
echo "Hooks installed:"
echo "  • pre-commit: Runs format/lint checks, spec verification, and architecture validation"
echo ""
echo "To bypass hooks (emergency only): git commit --no-verify"