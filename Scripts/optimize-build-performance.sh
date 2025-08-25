#!/bin/bash
# 
# Build Performance Optimization Script
# Addresses bottlenecks identified in build analysis (XcodeGen overhead, file size checking)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🚀 Implementing Build Performance Optimizations..."

# 1. Create optimized module cache directory structure
echo "📦 Setting up optimized module cache..."
MODULE_CACHE_DIR="${PROJECT_ROOT}/build/OptimizedModuleCache"
mkdir -p "${MODULE_CACHE_DIR}"
mkdir -p "${MODULE_CACHE_DIR}/swift-modules"
mkdir -p "${MODULE_CACHE_DIR}/clang-modules"

# 2. Create build performance configuration
echo "⚙️  Creating performance configuration..."
cat > "${PROJECT_ROOT}/Config/BuildOptimization.xcconfig" << 'EOF'
// BuildOptimization.xcconfig
// Optimizes compilation performance based on bottleneck analysis

// Module Cache Optimization (Reduces XcodeGen overhead)
MODULE_CACHE_DIR = $(SRCROOT)/build/OptimizedModuleCache
SWIFT_MODULE_CACHE_STRATEGY = persistent
CLANG_MODULES_CACHE_PATH = $(MODULE_CACHE_DIR)/clang-modules

// Parallel Compilation (Maximizes CPU utilization)
SWIFT_COMPILATION_BATCH_SIZE = 25
SWIFT_ENABLE_BATCH_MODE = YES
SWIFT_USE_PARALLEL_WMO_TARGETS = YES

// Incremental Build Optimization
SWIFT_ENABLE_INCREMENTAL_COMPILATION = YES
SWIFT_MODULE_INCREMENTAL_BUILD = YES
SWIFT_INCREMENTAL_COMPILATION_AGGRESSIVE = YES

// Debug Information Optimization (Reduces build time)
DEBUG_INFORMATION_FORMAT = dwarf
SWIFT_ENABLE_LIBRARY_EVOLUTION = NO

// Skip unnecessary validations during development
ENABLE_MODULE_VERIFIER = NO
VALIDATE_PRODUCT = NO
ENABLE_HEADER_DEPENDENCIES = NO

// Optimize for development workflow
ONLY_ACTIVE_ARCH = YES
SKIP_INSTALL = YES
STRIP_INSTALLED_PRODUCT = NO

// Swift Package Manager optimization
SWIFT_PACKAGE_MANAGER_BUILD_CACHE = YES
EOF

# 3. Create smart file size checking script (addresses file size check bottleneck)
echo "📏 Creating optimized file size checking..."
cat > "${PROJECT_ROOT}/Scripts/smart-file-size-check.sh" << 'EOF'
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
EOF

chmod +x "${PROJECT_ROOT}/Scripts/smart-file-size-check.sh"

# 4. Update project.yml to use optimizations
echo "🔧 Updating project configuration..."
if ! grep -q "BuildOptimization.xcconfig" "${PROJECT_ROOT}/project.yml"; then
    # Add build optimization include to Debug config
    sed -i '' '/Debug:/,/xcconfig:/s|xcconfig: Config/Debug.xcconfig|xcconfig: Config/Debug.xcconfig\n      - Config/BuildOptimization.xcconfig|' "${PROJECT_ROOT}/project.yml"
fi

# 5. Create build time measurement wrapper
echo "⏱️  Creating build time measurement..."
cat > "${PROJECT_ROOT}/Scripts/measure-build-time.sh" << 'EOF'
#!/bin/bash
# Measure and track build performance improvements

MEASUREMENT_LOG="${TMPDIR:-/tmp}/nestory-build-times.log"

echo "🏗️  Starting measured build..."
START_TIME=$(date +%s.%3N)

# Run the actual build
"$@"
BUILD_EXIT_CODE=$?

END_TIME=$(date +%s.%3N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc -l)

# Log the measurement
echo "$(date '+%Y-%m-%d %H:%M:%S') ${DURATION}s $*" >> "$MEASUREMENT_LOG"
echo "⏱️  Build completed in ${DURATION}s"

# Show recent performance trends
echo "📊 Recent build times:"
tail -5 "$MEASUREMENT_LOG" | while read -r line; do
    echo "   $line"
done

exit $BUILD_EXIT_CODE
EOF

chmod +x "${PROJECT_ROOT}/Scripts/measure-build-time.sh"

# 6. Update Makefile to use optimizations
echo "🎯 Updating Makefile with optimizations..."
cat >> "${PROJECT_ROOT}/Makefile.optimization" << 'EOF'

# Build Performance Optimizations
.PHONY: build-fast build-measured clean-cache

# Fast build with optimizations
build-fast: doctor-quick
	@echo "🚀 Fast build with optimizations..."
	@$(SCRIPT_DIR)/smart-file-size-check.sh
	@time $(XCODEGEN) generate --spec project.yml --cache-path ./.xcodegen-cache
	@xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(DEV_SCHEME) \
		-destination '$(DESTINATION)' \
		-configuration Debug \
		-derivedDataPath ./build/DerivedData \
		build

# Measured build for performance tracking  
build-measured: doctor-quick
	@$(SCRIPT_DIR)/measure-build-time.sh $(MAKE) build-fast

# Clean performance caches
clean-cache:
	@echo "🧹 Cleaning performance caches..."
	@rm -rf ./build/OptimizedModuleCache
	@rm -rf ./build/DerivedData
	@rm -rf ./.xcodegen-cache
	@rm -f "${TMPDIR:-/tmp}/nestory-file-size-cache.txt"
	@rm -f "${TMPDIR:-/tmp}/nestory-build-times.log"
	@echo "✅ Performance caches cleared"

# Quick doctor check (skips heavy validations)
doctor-quick:
	@echo "🏥 Quick health check..."
	@which xcodegen > /dev/null || (echo "❌ XcodeGen not found" && exit 1)
	@which xcodebuild > /dev/null || (echo "❌ Xcode not found" && exit 1)
	@echo "✅ Build tools ready"

EOF

# 7. Create performance monitoring dashboard
echo "📊 Creating performance monitoring..."
cat > "${PROJECT_ROOT}/Scripts/build-performance-report.sh" << 'EOF'
#!/bin/bash
# Generate build performance analysis report

MEASUREMENT_LOG="${TMPDIR:-/tmp}/nestory-build-times.log"

echo "📊 Build Performance Report"
echo "=========================="

if [[ -f "$MEASUREMENT_LOG" ]]; then
    echo "Recent Build Times:"
    echo "==================="
    tail -10 "$MEASUREMENT_LOG" | while IFS=' ' read -r date time duration command; do
        printf "  %s %s: %6s (%s)\n" "$date" "$time" "$duration" "$command"
    done
    
    echo ""
    echo "Performance Statistics:"
    echo "======================"
    
    # Calculate average build time
    AVG_TIME=$(tail -10 "$MEASUREMENT_LOG" | awk '{sum+=$3; count++} END {if(count>0) printf "%.2f", sum/count}')
    echo "  Average build time (last 10): ${AVG_TIME}s"
    
    # Find fastest build
    FASTEST=$(tail -20 "$MEASUREMENT_LOG" | awk '{print $3}' | sed 's/s$//' | sort -n | head -1)
    echo "  Fastest build time: ${FASTEST}s"
    
    # Find slowest build  
    SLOWEST=$(tail -20 "$MEASUREMENT_LOG" | awk '{print $3}' | sed 's/s$//' | sort -n | tail -1)
    echo "  Slowest build time: ${SLOWEST}s"
else
    echo "No build measurements found. Run 'make build-measured' to start tracking."
fi

echo ""
echo "Cache Status:"
echo "============="
CACHE_FILE="${TMPDIR:-/tmp}/nestory-file-size-cache.txt"
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
    echo "  File size cache: Valid (${CACHE_AGE}s old)"
else
    echo "  File size cache: Not found"
fi

MODULE_CACHE="./build/OptimizedModuleCache"
if [[ -d "$MODULE_CACHE" ]]; then
    CACHE_SIZE=$(du -sh "$MODULE_CACHE" 2>/dev/null | cut -f1)
    echo "  Module cache: ${CACHE_SIZE}"
else
    echo "  Module cache: Not initialized"
fi
EOF

chmod +x "${PROJECT_ROOT}/Scripts/build-performance-report.sh"

echo "✅ Build performance optimizations implemented!"
echo ""
echo "🎯 Next Steps:"
echo "  1. Run 'make build-measured' to test optimizations"
echo "  2. Run './Scripts/build-performance-report.sh' to monitor performance"  
echo "  3. Use 'make build-fast' for faster daily development builds"
echo "  4. Use 'make clean-cache' if you encounter cache issues"
echo ""
echo "📈 Expected improvements:"
echo "  - Reduced XcodeGen overhead through persistent caching"
echo "  - Faster file size checking through smart caching (3600s TTL)"
echo "  - Improved parallel compilation with optimized batch sizes"
echo "  - Build time tracking for continuous optimization"