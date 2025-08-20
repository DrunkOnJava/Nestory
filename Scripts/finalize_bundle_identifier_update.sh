#!/bin/bash
# Final comprehensive update of all bundle identifiers and GitHub configurations

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔄 Final update: All bundle identifiers to com.drunkonjava.nestory..."

# Update all markdown files
echo "📚 Updating markdown files..."
find . -name "*.md" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.md" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.md" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update GitHub Actions workflows
echo "🚀 Updating GitHub Actions..."
find .github -name "*.yml" -o -name "*.yaml" 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' "$file"
        sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' "$file"
        sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' "$file"
        echo "   Updated: $file"
    fi
done || echo "   No GitHub Actions found"

# Update README files specifically
echo "📖 Updating README files..."
find . -name "README*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "README*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "README*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update any remaining plist files
echo "📱 Updating remaining plist files..."
find . -name "*.plist" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.plist" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.plist" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update any entitlements files
echo "🔐 Updating entitlements files..."
find . -name "*.entitlements" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.entitlements" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.entitlements" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update any remaining script references
echo "🔧 Updating script references..."
find . -name "*.sh" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/ASC_BUNDLE_ID=com\.nestory\.app\.dev/ASC_BUNDLE_ID=com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.sh" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/ASC_BUNDLE_ID=com\.nestory\.app/ASC_BUNDLE_ID=com.drunkonjava.nestory/g' {} \;

# Update environment files
echo "⚙️ Updating environment files..."
find . -name ".env*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/APP_IDENTIFIER=com\.nestory\.app\.dev/APP_IDENTIFIER=com.drunkonjava.nestory.dev/g' {} \;
find . -name ".env*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/APP_IDENTIFIER=com\.nestory\.app/APP_IDENTIFIER=com.drunkonjava.nestory/g' {} \;

# Update any Secrets template or documentation
echo "🔑 Updating secrets and templates..."
find . -name "*Secrets*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*Secrets*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*Secrets*" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update any remaining occurrences in text files
echo "📄 Updating remaining text files..."
find . -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.yaml" -o -name "*.yml" \
    -type f -not -path "*/.build/*" -not -path "*/.git/*" | while read -r file; do
    if [ -f "$file" ]; then
        sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' "$file" 2>/dev/null || true
        sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' "$file" 2>/dev/null || true
        sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' "$file" 2>/dev/null || true
    fi
done

# Update keychain services in scripts
echo "🔐 Updating keychain service references..."
find . -name "*.sh" -type f -not -path "*/.build/*" -not -path "*/.git/*" \
    -exec sed -i '' 's/KEYCHAIN_SERVICE="com\.nestory\.app\.appstoreconnect"/KEYCHAIN_SERVICE="com.drunkonjava.nestory.appstoreconnect"/g' {} \;

# Update all Xcode configurations
echo "🏗️ Updating Xcode project configurations..."

# Update xcscheme files
find . -name "*.xcscheme" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.xcscheme" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.xcscheme" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update pbxproj files (Xcode project files)
find . -name "*.pbxproj" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.pbxproj" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.pbxproj" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update xcworkspace files if they exist
find . -name "*.xcworkspace" -type d -not -path "*/.build/*" | while read -r workspace; do
    find "$workspace" -name "*.xcworkspacedata" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
    find "$workspace" -name "*.xcworkspacedata" -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
    find "$workspace" -name "*.xcworkspacedata" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;
done

# Update xcuserdata (user-specific Xcode settings)
find . -path "*/xcuserdata/*" -name "*.xcscheme" -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -path "*/xcuserdata/*" -name "*.xcscheme" -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -path "*/xcuserdata/*" -name "*.xcscheme" -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update xctestplan files
find . -name "*.xctestplan" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.xctestplan" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.xctestplan" -type f -not -path "*/.build/*" \
    -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update all plist files thoroughly
echo "📱 Comprehensive plist file updates..."
find . -name "*.plist" -type f -not -path "*/.build/*" -not -path "*/.git/*" | while read -r plist; do
    if [ -f "$plist" ]; then
        sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' "$plist"
        sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' "$plist"
        sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' "$plist"
        # Also update any TeamIdentifierPrefix references
        sed -i '' 's/iCloud\.com\.nestory\.app\.dev/iCloud.com.drunkonjava.nestory.dev/g' "$plist"
        sed -i '' 's/iCloud\.com\.nestory\.app\.staging/iCloud.com.drunkonjava.nestory.staging/g' "$plist"
        sed -i '' 's/iCloud\.com\.nestory\.app/iCloud.com.drunkonjava.nestory/g' "$plist"
        echo "   Updated: $plist"
    fi
done

# Update Fastlane configuration files
echo "🚀 Updating Fastlane configurations..."
find . -path "*/fastlane/*" -type f \( -name "Fastfile" -o -name "Appfile" -o -name "Deliverfile" -o -name "Matchfile" -o -name "Scanfile" \) | while read -r fastfile; do
    if [ -f "$fastfile" ]; then
        sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' "$fastfile"
        sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' "$fastfile"
        sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' "$fastfile"
        echo "   Updated: $fastfile"
    fi
done

# Update Ruby files (Gemfile, .rb files)
echo "💎 Updating Ruby/Gemfile configurations..."
find . -name "Gemfile*" -o -name "*.rb" -type f -not -path "*/.build/*" -not -path "*/.git/*" | while read -r rubyfile; do
    if [ -f "$rubyfile" ]; then
        sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' "$rubyfile"
        sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' "$rubyfile"
        sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' "$rubyfile"
        # Also update any match/sigh references
        sed -i '' 's/"match AppStore com\.nestory\.app\.dev"/"match AppStore com.drunkonjava.nestory.dev"/g' "$rubyfile"
        sed -i '' 's/"match AppStore com\.nestory\.app\.staging"/"match AppStore com.drunkonjava.nestory.staging"/g' "$rubyfile"
        sed -i '' 's/"match AppStore com\.nestory\.app"/"match AppStore com.drunkonjava.nestory"/g' "$rubyfile"
        echo "   Updated: $rubyfile"
    fi
done

# Update any provisioning profile references
echo "📋 Updating provisioning profile references..."
find . -type f \( -name "*.mobileprovision" -o -name "*provision*" \) -not -path "*/.build/*" -not -path "*/.git/*" | while read -r provfile; do
    if [ -f "$provfile" ]; then
        sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' "$provfile" 2>/dev/null || true
        sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' "$provfile" 2>/dev/null || true
        sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' "$provfile" 2>/dev/null || true
        echo "   Updated: $provfile"
    fi
done

# Summary
echo "✅ Final bundle identifier update completed!"
echo ""
echo "📱 Bundle Identifiers Updated:"
echo "   Development: com.drunkonjava.nestory.dev"
echo "   Staging: com.drunkonjava.nestory.staging"
echo "   Production: com.drunkonjava.nestory"
echo ""
echo "🔧 Updated Files:"
echo "   • All markdown (.md) files"
echo "   • GitHub Actions workflows"
echo "   • Property lists (.plist)"
echo "   • Entitlements files"
echo "   • Environment files"
echo "   • Secrets and templates"
echo "   • Build and deployment scripts"
echo "   • Keychain service references"
echo ""
echo "🎯 Pattern Established: com.drunkonjava.nestory"