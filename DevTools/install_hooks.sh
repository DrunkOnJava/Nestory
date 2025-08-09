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

# Create pre-commit hook
cat > "${HOOKS_DIR}/pre-commit" << 'EOF'
#!/bin/sh
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Running pre-commit checks..."

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "${PROJECT_ROOT}"

# Check for formatting tools and run if available
if command -v swiftformat >/dev/null 2>&1; then
    echo "📝 Checking Swift formatting..."
    if ! swiftformat --lint . >/dev/null 2>&1; then
        echo "${YELLOW}⚠️  Swift formatting issues detected${NC}"
        echo "Run 'swiftformat .' to fix"
        exit 1
    fi
fi

if command -v swiftlint >/dev/null 2>&1; then
    echo "🧹 Running SwiftLint..."
    if ! swiftlint lint --quiet; then
        echo "${RED}❌ SwiftLint violations found${NC}"
        exit 1
    fi
fi

# Build nestoryctl if needed
NESTORYCTL="${PROJECT_ROOT}/DevTools/nestoryctl/.build/release/nestoryctl"
if [ ! -f "${NESTORYCTL}" ]; then
    echo "🔨 Building nestoryctl..."
    swift build -c release --package-path "${PROJECT_ROOT}/DevTools/nestoryctl" >/dev/null 2>&1
fi

# Run spec verification
echo "📋 Verifying SPEC integrity..."
if ! "${NESTORYCTL}" spec-verify; then
    echo "${RED}❌ SPEC verification failed${NC}"
    
    # Check if SPEC.json was modified
    if git diff --cached --name-only | grep -q "SPEC.json"; then
        echo "${YELLOW}SPEC.json has been modified. Please:${NC}"
        echo "  1. Document changes in SPEC_CHANGE.md"
        echo "  2. Add an ADR entry to DECISIONS.md"
        echo "  3. Run 'nestoryctl spec-commit' to update SPEC.lock"
        
        # Check for required files
        if [ ! -f "${PROJECT_ROOT}/SPEC_CHANGE.md" ]; then
            echo "${RED}❌ SPEC_CHANGE.md is missing${NC}"
            exit 1
        fi
        
        if [ ! -f "${PROJECT_ROOT}/DECISIONS.md" ]; then
            echo "${RED}❌ DECISIONS.md is missing${NC}"
            exit 1
        fi
        
        # Check if DECISIONS.md was also modified
        if ! git diff --cached --name-only | grep -q "DECISIONS.md"; then
            echo "${RED}❌ DECISIONS.md must be updated with an ADR for this SPEC change${NC}"
            exit 1
        fi
    fi
    exit 1
fi

# Run architecture verification
echo "🏗️  Verifying architecture..."
if ! "${NESTORYCTL}" arch-verify; then
    echo "${RED}❌ Architecture verification failed${NC}"
    exit 1
fi

# Check for bare TODOs/FIXMEs
echo "📝 Checking for untracked TODOs..."
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(swift|md)$' || true)

if [ -n "$STAGED_FILES" ]; then
    for file in $STAGED_FILES; do
        # Check for bare TODO/FIXME without ADR reference
        if grep -E '(TODO|FIXME)(?!.*ADR-[0-9]+)' "$file" >/dev/null 2>&1; then
            echo "${YELLOW}⚠️  Found bare TODO/FIXME in $file${NC}"
            echo "Please reference an ADR (e.g., 'TODO(ADR-0001): ...')"
            exit 1
        fi
    done
fi

echo "${GREEN}✅ All pre-commit checks passed!${NC}"
EOF

# Make pre-commit hook executable
chmod +x "${HOOKS_DIR}/pre-commit"

echo "${GREEN}✅ Pre-commit hooks installed successfully!${NC}"
echo ""
echo "Hooks installed:"
echo "  • pre-commit: Runs format/lint checks, spec verification, and architecture validation"
echo ""
echo "To bypass hooks (emergency only): git commit --no-verify"