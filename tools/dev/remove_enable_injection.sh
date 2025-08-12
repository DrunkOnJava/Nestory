#!/bin/bash
# Remove all .enableInjection() calls from the project
# These are causing build failures and HotReloading can work without them

PROJECT_ROOT="$(dirname $(dirname $(dirname "$0")))"
cd "$PROJECT_ROOT"

echo "Removing .enableInjection() calls from all Swift files..."

# Find all Swift files and remove .enableInjection() lines
find . -name "*.swift" -type f ! -path "./tools/*" ! -path "./DevTools/*" ! -path "./.build/*" | while read -r file; do
    if grep -q "\.enableInjection()" "$file"; then
        echo "Processing: $file"
        # Remove lines that only contain .enableInjection()
        sed -i '' '/^[[:space:]]*\.enableInjection()[[:space:]]*$/d' "$file"
        
        # Also remove the #if DEBUG / #endif blocks that were only for enableInjection
        sed -i '' '/^[[:space:]]*#if DEBUG[[:space:]]*$/,/^[[:space:]]*#endif[[:space:]]*$/{
            /^[[:space:]]*#if DEBUG[[:space:]]*$/d
            /^[[:space:]]*#endif[[:space:]]*$/d
        }' "$file" 2>/dev/null || true
    fi
done

echo "✅ Removed all .enableInjection() calls"
echo ""
echo "The HotReloading package will still work through automatic injection."
echo "Make sure InjectionIII is running and watching the project directory."