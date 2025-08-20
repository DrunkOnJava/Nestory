#!/bin/bash
# Update all bundle identifiers to com.drunkonjava.nestory pattern

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔄 Updating all bundle identifiers to com.drunkonjava.nestory pattern..."

# Update main bundle identifiers
echo "📱 Updating main bundle identifiers..."
find . -name "*.xcconfig" -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.xcconfig" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.xcconfig" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update CloudKit containers
echo "☁️ Updating CloudKit containers..."
find . -name "*.xcconfig" -exec sed -i '' 's/iCloud\.com\.nestory\.app\.staging/iCloud.com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.xcconfig" -exec sed -i '' 's/iCloud\.com\.nestory\.app\.dev/iCloud.com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.xcconfig" -exec sed -i '' 's/iCloud\.com\.nestory\.app/iCloud.com.drunkonjava.nestory/g' {} \;

# Update project files
echo "📁 Updating project files..."
find . -name "*.yml" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.yml" -exec sed -i '' 's/com\.nestory\.UITests/com.drunkonjava.nestory.UITests/g' {} \;
find . -name "*.yml" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;
find . -name "*.yml" -exec sed -i '' 's/bundleIdPrefix: com\.nestory/bundleIdPrefix: com.drunkonjava.nestory/g' {} \;

# Update shell scripts
echo "🔧 Updating shell scripts..."
find . -name "*.sh" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory/g' {} \;
find . -name "*.sh" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update subsystem loggers to use consistent pattern
echo "📊 Updating logger subsystems..."
find . -name "*.swift" -exec sed -i '' 's/subsystem: "com\.nestory"/subsystem: "com.drunkonjava.nestory"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/subsystem: "com\.nestory\.app"/subsystem: "com.drunkonjava.nestory"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/subsystem: "com\.nestory\.hotreload"/subsystem: "com.drunkonjava.nestory.hotreload"/g' {} \;

# Update constants and other Swift references
echo "📱 Updating Swift constants..."
find . -name "*.swift" -exec sed -i '' 's/bundleIdentifier = "com\.nestory\.ios"/bundleIdentifier = "com.drunkonjava.nestory"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.auth"/"com.drunkonjava.nestory.auth"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.test"/"com.drunkonjava.nestory.test"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.app"/"com.drunkonjava.nestory"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.signin"/"com.drunkonjava.nestory.signin"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.encryptionKey"/"com.drunkonjava.nestory.encryptionKey"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.encryption"/"com.drunkonjava.nestory.encryption"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.keyagreement"/"com.drunkonjava.nestory.keyagreement"/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.secureenclave"/"com.drunkonjava.nestory.secureenclave"/g' {} \;

# Update queue labels
echo "🔄 Updating queue labels..."
find . -name "*.swift" -exec sed -i '' 's/label: "com\.nestory\./label: "com.drunkonjava.nestory./g' {} \;

# Update cache directories
echo "💾 Updating cache directories..."
find . -name "*.swift" -exec sed -i '' 's/"com\.nestory\.cache\./"com.drunkonjava.nestory.cache./g' {} \;

# Update background task identifiers in Info.plist
echo "⏰ Updating background task identifiers..."
find . -name "Info.plist" -exec sed -i '' 's/com\.nestory\.sync/com.drunkonjava.nestory.sync/g' {} \;
find . -name "Info.plist" -exec sed -i '' 's/com\.nestory\.cleanup/com.drunkonjava.nestory.cleanup/g' {} \;

# Update StoreKit configuration
echo "💰 Updating StoreKit identifiers..."
find . -name "*.storekit" -exec sed -i '' 's/com\.nestory\.premium\./com.drunkonjava.nestory.premium./g' {} \;
find . -name "*.storekit" -exec sed -i '' 's/com\.nestory\.export\./com.drunkonjava.nestory.export./g' {} \;

# Update documentation files
echo "📚 Updating documentation..."
find . -name "*.md" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.md" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update JSON and other config files
echo "⚙️ Updating config files..."
find . -name "*.json" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.json" -exec sed -i '' 's/com\.nestory\.app\.staging/com.drunkonjava.nestory.staging/g' {} \;
find . -name "*.json" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;

# Update Fastlane files
echo "🚀 Updating Fastlane files..."
find . -name "Fastfile" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "Fastfile" -exec sed -i '' 's/com\.nestory\.app/com.drunkonjava.nestory/g' {} \;
find . -name "Deliverfile" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name ".env.default" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;
find . -name "*.rb" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory.dev/g' {} \;

# Update Makefile
echo "🔨 Updating Makefile..."
find . -name "Makefile" -exec sed -i '' 's/com\.nestory\.app\.dev/com.drunkonjava.nestory/g' {} \;

echo "✅ Bundle identifier update completed!"
echo "📱 New pattern: com.drunkonjava.nestory"
echo "🔄 All subsystems, containers, and identifiers updated"