# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📱 PROJECT CONTEXT

<!-- CI/CD Pipeline Test - 2025-08-25 15:49:19 -->

**Nestory** is a **personal home inventory app for insurance documentation** - NOT a business inventory system.
Built for homeowners/renters to catalog belongings for insurance claims, warranty tracking, and disaster recovery.

**Critical Rules:**
- NO "low stock" or "out of stock" references (personal belongings, not business inventory)
- Focus on documentation completeness (missing photos, receipts, serial numbers)
- Everything oriented toward insurance and disaster preparedness

## 📊 PROJECT METADATA

### Technical Stack
- **Language**: Swift 6.0 (strict concurrency in Release, minimal in Debug)
- **Minimum iOS**: 17.0
- **UI Framework**: SwiftUI
- **State Management**: The Composable Architecture (TCA) v1.15.0+
- **Persistence**: SwiftData with CloudKit sync
- **Target Device**: iPhone 16 Pro Max (simulator standard)
- **Build System**: XcodeGen + Makefile automation
- **Testing**: XCTest (80% coverage minimum)

### Project Configuration
- **Bundle ID**: `com.drunkonjava.nestory` (prod)
  - Dev: `com.drunkonjava.nestory.dev`
  - Staging: `com.drunkonjava.nestory.staging`
- **Team ID**: `2VXBQV4XC9`
- **Current Version**: 1.0.1 (Build 4)
- **Xcode Version**: 15.0+
- **Code Signing**: Automatic
- **Swift Compilation**: Whole module optimization

### Core Dependencies
- **ComposableArchitecture**: State management & architecture
- **SwiftData**: Local persistence
- **CloudKit**: Cloud sync & backup
- **Vision Framework**: Receipt OCR
- **PDFKit**: Insurance report generation
- **AVFoundation**: Camera/photo capture
- **StoreKit 2**: Future monetization

### Data Models (SwiftData)
- **Item**: Core inventory item with photos, value, location
- **Category**: Item categorization system
- **Room**: Location organization
- **Warranty**: Warranty tracking with expiration
- **Receipt**: Purchase documentation with OCR
- **ClaimSubmission**: Insurance claim records
- **DamageAssessment**: Damage documentation workflows

### Services Architecture
- **InventoryService**: Core CRUD operations
- **InsuranceReportService**: PDF generation
- **ReceiptOCRService**: Receipt scanning & extraction
- **AnalyticsService**: Value insights & statistics
- **NotificationService**: Warranty expiration alerts
- **ImportExportService**: CSV/JSON data management
- **CloudBackupService**: CloudKit sync management
- **DamageAssessmentService**: Damage documentation workflows
- **WarrantyTrackingService**: Warranty lifecycle management

### Performance SLOs
- **Cold Start P95**: < 1800ms (monitored via Grafana)
- **DB Read P95**: < 250ms (50 items)
- **Scroll Jank**: < 3% (tracked in performance tests)
- **Crash-Free Rate**: > 99.8%
- **Build Time**: ~10-15s incremental (with cache), ~30-45s cold
- **Test Execution**: ~45-60s (with cache)
- **CI Pipeline**: 2-3 minutes total (self-hosted M1 iMac)

## 🚀 CI/CD INFRASTRUCTURE

### Self-Hosted Runners (Operational)
- **M1 iMac (Primary)**: 10 cores, 32GB RAM, macOS 15.1
  - Location: `~/actions-runner/`
  - Service: `com.github.actions.runner`
  - Auto-update: 2:30 AM daily via launchd
  - Status: ✅ Active
- **Raspberry Pi 5 (Backup)**: 4 cores, 8GB RAM, Ubuntu 24.04
  - Status: Configured, ready for activation
  - Purpose: Overflow and redundancy

### Monitoring Stack (Docker-based)
Access all monitoring at http://localhost

#### Grafana Dashboard
- **URL**: http://localhost:3000
- **Login**: admin / nestory123
- **Dashboard**: Nestory CI/CD Performance
- **Metrics**: Build duration, cache hits, test coverage, cold start times

#### Prometheus
- **URL**: http://localhost:9090
- **Purpose**: Metrics database and queries
- **Retention**: 30 days
- **Scrape interval**: 15s

#### Pushgateway
- **URL**: http://localhost:9091
- **Purpose**: Receive metrics from GitHub Actions
- **Usage**: Push metrics at workflow completion

### Performance Optimizations

#### Build Cache System
- **Technology**: zstd compression (level 3)
- **Location**: `~/Library/Caches/NestoryBuildCache/`
- **Space savings**: 30-50% reduction
- **Components cached**:
  - DerivedData (~600MB → ~300MB)
  - Swift Package Manager (~400MB → ~200MB)
  - Simulator devices (~1GB → ~500MB)
- **Auto-cleanup**: 30 days retention
- **Monitoring**: Compression metrics at port 9096

#### Parallel Processing
- **Build parallelization**: 10 cores
- **Test parallelization**: 4 simulators concurrent
- **Matrix strategy**: scheme × configuration

### Security Infrastructure

#### GPG Commit Signing
- **Key type**: 4096-bit RSA
- **Expiry**: 2 years auto-rotation
- **Configuration**:
  ```bash
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
  ```
- **CI Verification**: All PRs checked for valid signatures
- **Branch protection**: Enforced on main/develop

#### Runner Security
- **Auto-updates**: Maintenance window 2-4 AM
- **Rollback capability**: 3 backup versions retained
- **Health monitoring**: http://localhost:8080/health
- **Update notifications**: Pushed to monitoring

### Workflow Optimizations

#### Nightly Benchmarks
- **Schedule**: 3:00 AM daily
- **Metrics collected**:
  - Clean build time
  - Incremental build time
  - Test suite duration
  - App size analysis
  - Memory usage profiling
- **Results**: Pushed to Grafana dashboard

#### Cache Strategy
- **GitHub Actions cache**: 10GB limit
- **Local runner cache**: Unlimited, zstd compressed
- **Cache keys**: 
  - `swift-pm-${{ hashFiles('**/Package.resolved') }}`
  - `derived-data-${{ hashFiles('**/*.swift') }}`
- **Hit rate target**: > 70%

## 🏗️ ARCHITECTURE

### 6-Layer TCA Architecture (STRICT)
```
App → Features → UI → Services → Infrastructure → Foundation
        ↘     ↗
```

**Layer Import Rules (SPEC.json is LAW):**
- **App**: Can import Features, UI, Services, Infrastructure, Foundation, ComposableArchitecture
- **Features**: Can import UI, Services, Foundation, ComposableArchitecture ONLY
- **UI**: Can import Foundation ONLY (pure components, NO business logic)
- **Services**: Can import Infrastructure, Foundation ONLY
- **Infrastructure**: Can import Foundation ONLY
- **Foundation**: NO imports except Swift stdlib

### File Header Template (MANDATORY)
```swift
//
// Layer: [Foundation|Infrastructure|Services|UI|Features|App]
// Module: [ModuleName]
// Purpose: [One line description]
//
```

## 🛠️ ESSENTIAL COMMANDS

### Development Workflow
```bash
# Build and run (always iPhone 16 Pro Max)
make run          # Build and launch in simulator
make build        # Build only
make fast-build   # Optimized parallel build (10 cores, with cache)

# Testing
make test         # Run all tests
make test-unit    # Unit tests only
make test-ui      # UI tests on iPhone 16 Plus
swift test --filter [TestName]  # Run specific test

# Architecture Verification
make verify-arch  # Check layer compliance
make verify-wiring # Ensure all services wired to UI
make check        # Run ALL checks (build, test, lint, arch)

# Quick Shortcuts
make r  # run
make b  # build
make c  # check
make d  # doctor (diagnose issues)

# Build Cache Management (75-85% faster builds)
nestory-build     # Build with cache optimization
nestory-stats     # Show cache statistics (size, age, hit rate)
nestory-warm      # Pre-warm cache (builds dependencies)
nestory-clean     # Clear Nestory build cache

# Utilities
make context      # Generate CURRENT_CONTEXT.md for session continuity
make stats        # Project statistics
make todo         # List all TODOs
make clean        # Clean build artifacts
```

### CI/CD Management Commands
```bash
# Monitoring Stack Control
docker ps                          # View running containers
docker logs nestory-grafana        # Check Grafana logs
docker logs nestory-prometheus     # Check Prometheus logs
open http://localhost:3000         # Open Grafana (admin/nestory123)
open http://localhost:9090         # Open Prometheus UI
open http://localhost:9091         # Open Pushgateway

# Start/Stop Monitoring
docker start nestory-grafana nestory-prometheus nestory-pushgateway
docker stop nestory-grafana nestory-prometheus nestory-pushgateway
docker restart nestory-grafana     # Restart if needed

# Push Metrics (from workflows or testing)
cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/test
nestory_build_duration_seconds{scheme="Dev",configuration="Debug"} 42
nestory_cache_hit_rate{cache_type="derived_data"} 0.85
EOF

# Cache Management
scripts/setup-cache-compression.sh compress    # Compress build cache
scripts/setup-cache-compression.sh decompress  # Restore from compressed
scripts/setup-cache-compression.sh stats       # View compression savings
scripts/setup-cache-compression.sh clean       # Clean old cache files

# Runner Management
scripts/runner-auto-update.sh --check     # Check for runner updates
scripts/runner-auto-update.sh --force     # Force immediate update
scripts/runner-auto-update.sh --rollback  # Rollback to previous version
launchctl list | grep runner              # Check runner service status

# Security & Signing
scripts/setup-commit-signing.sh [email] [name]  # Setup GPG signing
git log --show-signature -5                     # Verify last 5 commits
git verify-commit HEAD                          # Verify current commit
gpg --list-secret-keys                          # List GPG keys
```

### UI Testing Commands
```bash
# Run specific UI test on simulator
xcodebuild test -scheme Nestory-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  -only-testing:NestoryUITests/[TestClass]/[testMethod]

# Physical Device Testing
scripts/setup-device-testing.sh              # Setup device testing environment  
scripts/CI/test-runner-connections.sh        # Test runner connectivity
gh workflow run device-testing --field device_name="Griffin's iPhone"  # Trigger via GitHub
```

### CI/CD Commands
```bash
# GitHub Actions (self-hosted M1 iMac runner)
gh workflow run ios-continuous.yml    # Trigger CI build
gh workflow run device-testing.yml    # Test on physical device
gh workflow run nightly-performance   # Run performance benchmarks
gh run list --workflow=ios-continuous # List recent runs
gh run watch                          # Watch current run progress

# Runner Management
gh api /repos/DrunkOnJava/Nestory/actions/runners --jq '.runners[] | {name: .name, status: .status, labels: [.labels[].name]}'  # Check runner status
scripts/CI/monitor-runners.sh --status            # Real-time runner monitoring
scripts/CI/runner-status.sh                      # Detailed runner information
```

### Performance Monitoring
```bash
# Grafana Dashboard (real-time metrics)
open http://localhost:3000         # Username: admin, Password: nestory123
open http://localhost:9090         # Prometheus metrics explorer
curl http://localhost:9091/metrics # View Pushgateway metrics

# Push metrics manually
cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/test
nestory_build_duration_seconds{scheme="Dev",configuration="Debug"} 42
nestory_cache_hit_rate{cache_type="derived_data"} 0.85
EOF

# Check monitoring stack status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(grafana|prometheus|pushgateway)"
```

## 🎯 CRITICAL IMPLEMENTATION RULES

1. **ALWAYS WIRE UP IMPLEMENTATIONS** - Every service/feature MUST be accessible from UI
2. **NO ORPHANED CODE** - Everything must be reachable from user interaction
3. **TCA DEPENDENCY INJECTION** - All services use `@Dependency` in Features
4. **SWIFTDATA MODELS** - Always include defaults and handle CloudKit compatibility
5. **ERROR HANDLING** - Never use force unwraps (try!), always graceful degradation
6. **SIMULATOR TARGET** - ALWAYS use iPhone 16 Pro Max for consistency

## 📋 SERVICE WIRING CHECKLIST

When implementing ANY new feature:
1. Create Service/Logic ✓
2. Create View/UI ✓
3. **WIRE IT UP** ← Most important!
4. Test in Simulator ✓

### Where to Wire Features

| Feature Type | Wire Location | How |
|-------------|---------------|-----|
| Item-specific | ItemDetailView | Add button/section with sheet/navigation |
| Global utility | SettingsView | Add to Import/Export section |
| Search feature | SearchView | Add filter or syntax |
| Analytics | AnalyticsDashboardView | Add chart/insight |
| New major feature | ContentView/RootView | Add new tab |

## 🔧 TCA PATTERNS

### Feature Pattern
```swift
@Reducer
struct MyFeature {
    @ObservableState
    struct State: Equatable { /* ... */ }
    
    enum Action { /* ... */ }
    
    @Dependency(\.myService) var myService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // Handle actions
        }
    }
}
```

### Service Dependency
```swift
// In ServiceDependencyKeys.swift
enum MyServiceKey: @preconcurrency DependencyKey {
    static var liveValue: any MyService {
        do {
            return try LiveMyService()
        } catch {
            print("⚠️ Failed to create MyService: \(error)")
            return MockMyService() // Graceful degradation
        }
    }
}
```

## 🚨 COMMON PITFALLS TO AVOID

1. **Cross-layer imports** - Features importing Infrastructure (must go through Services)
2. **Force unwraps** - Replace try! with proper error handling
3. **Missing wiring** - Creating features without UI access points
4. **Stock references** - This is for personal items, not business inventory
5. **Hardcoded secrets** - Use ProcessInfo.environment or Keychain
6. **Skipping verification** - Always run `make verify-arch` after changes

## 📊 PROJECT STATUS

### Current Implementation
- ✅ **Core Inventory**: Item management with photos
- ✅ **Insurance Reports**: PDF generation for claims
- ✅ **Receipt OCR**: Automatic data extraction
- ✅ **Analytics Dashboard**: Value insights & statistics
- ✅ **Search System**: Advanced filters & syntax
- ✅ **Import/Export**: CSV/JSON data management
- ✅ **Warranty Tracking**: Expiration alerts
- ✅ **CloudKit Sync**: Backup & multi-device support

### Deployment Status
- **TestFlight**: Build 3 (active)
- **App Store**: Not yet submitted
- **CI/CD**: Self-hosted M1 iMac runner (nestory-m1-imac)
- **Architecture Compliance**: Enforced via nestoryctl

### CI/CD Infrastructure
- **Primary Runner**: M1 iMac "nestory-m1-imac" (32GB RAM, 10 cores)
  - Status: ✅ Online and operational
  - Labels: `[self-hosted, ARM64, macOS, M1, xcode, ios-capable]`
  - Handles: iOS builds, testing, device testing, code signing
  - Cost Savings: $246/month vs GitHub-hosted runners
- **Secondary Runner**: Raspberry Pi 5 
  - Status: ⏳ Configured, pending SSH setup
  - Labels: `[self-hosted, raspberry-pi, auxiliary]`
  - Handles: Python scripts, monitoring, lightweight tasks
- **Build Caching**: 3-tier persistent cache (10GB total)
  - Module Cache: 3-day retention
  - DerivedData: 7-day retention  
  - SPM Packages: 30-day retention
  - Performance: 75-85% faster incremental builds
- **Monitoring Stack**: Prometheus + Grafana (Docker-based on localhost)
  - Real-time build metrics
  - Performance regression detection
  - Automatic alerts on degradation

### Quality Metrics
- **Test Coverage**: 80% minimum (enforced in CI)
- **SwiftLint Rules**: 95+ active rules
- **Architecture Violations**: 0 tolerance
- **Documentation**: All public APIs documented
- **Build Performance**: 
  - Incremental: 10-15s (with cache)
  - Cold Build: 30-45s
  - CI Pipeline: 2-3 minutes total

## 📈 WORKFLOWS & MONITORING

### GitHub Actions Workflows
- **ios-continuous.yml**: PR builds & tests (2-3 min)
- **nightly-performance.yml**: Daily at 2 AM PST, regression detection
- **device-testing.yml**: Physical device testing on demand
- **visualization.yml**: Weekly architecture & complexity analysis
- **build-cache-config.yml**: Reusable caching strategy

### Performance Dashboards
Access Grafana at http://localhost:3000 to view:
- Build duration trends (P50, P95)
- Cache hit rates (target: >85%)
- Cold start performance (target: <1800ms)
- Test coverage by module (target: >80%)
- Memory usage patterns
- Scroll jank metrics (target: <3%)
- Code complexity heatmaps
- SwiftLint violation trends

### Metrics Collection
All workflows automatically push metrics to Prometheus:
- Build success/failure rates
- Test execution times
- Performance benchmarks
- Cache statistics
- Pipeline duration

## 🔍 QUICK ARCHITECTURE CHECK

```swift
// ❌ ILLEGAL
import NetworkClient  // in Features layer
import InventoryService  // in UI layer

// ✅ LEGAL
@Dependency(\.inventoryService) var service  // in Features
import Foundation  // in any layer
```

Remember: SPEC.json defines the architecture. When uncertain, check allowed imports there.

## 📁 COMPREHENSIVE SCRIPT REFERENCE

### Core Development Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `quick_build.sh` | Fast incremental builds | `./scripts/quick_build.sh` | `/scripts/` |
| `quick_test.sh` | Unit tests only | `./scripts/quick_test.sh` | `/scripts/` |
| `dev_cycle.sh` | Complete build→test→UI cycle | `./scripts/dev_cycle.sh` | `/scripts/` |
| `dev_stats.sh` | Development metrics | `./scripts/dev_stats.sh` | `/scripts/` |
| `optimize_xcode_workflow.sh` | Complete Xcode workflow optimization | `./scripts/optimize_xcode_workflow.sh` | `/scripts/` |

### Build & Performance Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `setup-build-cache.sh` | Build cache optimization | `./scripts/setup-build-cache.sh` | `/scripts/` |
| `setup-cache-compression.sh` | zstd cache compression | `./scripts/setup-cache-compression.sh [compress\|decompress\|stats\|clean]` | `/scripts/` |
| `measure-build-time.sh` | Build performance measurement | `./scripts/measure-build-time.sh` | `/scripts/` |
| `optimize-build-performance.sh` | Build optimization | `./scripts/optimize-build-performance.sh` | `/scripts/` |
| `build-performance-report.sh` | Performance reporting | `./scripts/build-performance-report.sh` | `/scripts/` |

### Testing & Quality Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `run-screenshots.sh` | Screenshot generation | `./scripts/run-screenshots.sh` | `/scripts/` |
| `run-screenshot-catalog.sh` | Screenshot catalog | `./scripts/run-screenshot-catalog.sh` | `/scripts/` |
| `extract-screenshots.py` | Python screenshot extraction | `python scripts/extract-screenshots.py` | `/scripts/` |
| `setup-simulator-permissions.sh` | Simulator permission setup | `./scripts/setup-simulator-permissions.sh` | `/scripts/` |
| `setup-device-testing.sh` | Physical device testing setup | `./scripts/setup-device-testing.sh` | `/scripts/` |
| `validate-configuration.sh` | Configuration validation | `./scripts/validate-configuration.sh` | `/scripts/` |

### Architecture & Maintenance Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `architecture-verification.sh` | Layer compliance checking | `./scripts/architecture-verification.sh` | `/scripts/` |
| `modularization-monitor.sh` | Architecture monitoring | `./scripts/modularization-monitor.sh` | `/scripts/` |
| `codebase-health-report.sh` | Health metrics | `./scripts/codebase-health-report.sh` | `/scripts/` |
| `check-file-sizes.sh` | File size monitoring | `./scripts/check-file-sizes.sh` | `/scripts/` |
| `smart-file-size-check.sh` | Smart size checking | `./scripts/smart-file-size-check.sh` | `/scripts/` |

### CI/CD & Runner Management Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `setup-github-runner-macos.sh` | M1 iMac runner setup | `./scripts/CI/setup-github-runner-macos.sh` | `/scripts/CI/` |
| `setup-github-runner-pi.sh` | Raspberry Pi runner setup | `./scripts/CI/setup-github-runner-pi.sh` | `/scripts/CI/` |
| `deploy-runner-remote.sh` | Remote runner deployment | `./scripts/CI/deploy-runner-remote.sh [--deploy-macos\|--deploy-pi]` | `/scripts/CI/` |
| `monitor-runners.sh` | Runner monitoring dashboard | `./scripts/CI/monitor-runners.sh [--status]` | `/scripts/CI/` |
| `runner-status.sh` | Detailed runner status | `./scripts/CI/runner-status.sh` | `/scripts/CI/` |
| `test-runner-connections.sh` | Connection testing | `./scripts/CI/test-runner-connections.sh` | `/scripts/CI/` |
| `setup-pi-ssh.sh` | Pi SSH configuration | `./scripts/CI/setup-pi-ssh.sh` | `/scripts/CI/` |

### Security & Signing Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `setup-commit-signing.sh` | GPG commit signing setup | `./scripts/setup-commit-signing.sh [email] [name]` | `/scripts/` |
| `runner-auto-update.sh` | Runner auto-update system | `./scripts/runner-auto-update.sh [--check\|--force\|--rollback]` | `/scripts/` |

### Utilities & Configuration Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `nestory_aliases.sh` | Development aliases | `source scripts/nestory_aliases.sh` | `/scripts/` |
| `finalize_bundle_identifier_update.sh` | Bundle ID management | `./scripts/finalize_bundle_identifier_update.sh` | `/scripts/` |
| `update_bundle_identifiers.sh` | Bundle ID updates | `./scripts/update_bundle_identifiers.sh` | `/scripts/` |
| `generate-project-config.swift` | Project configuration generation | `swift scripts/generate-project-config.swift` | `/scripts/` |
| `move_models.sh` | Model migration | `./scripts/move_models.sh` | `/scripts/` |
| `manage-file-size-overrides.sh` | File size override management | `./scripts/manage-file-size-overrides.sh` | `/scripts/` |

### App Store & Distribution Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `setup-fastlane.sh` | Fastlane setup | `./scripts/setup-fastlane.sh` | `/scripts/` |
| `run_fastlane_screenshots.sh` | Fastlane screenshot automation | `./scripts/run_fastlane_screenshots.sh` | `/scripts/` |
| `configure_app_store_connect.rb` | App Store Connect config | `ruby scripts/configure_app_store_connect.rb` | `/scripts/` |
| `setup_asc_credentials.sh` | ASC credentials setup | `./scripts/setup_asc_credentials.sh` | `/scripts/` |
| `verify_app_store_setup.sh` | App Store setup verification | `./scripts/verify_app_store_setup.sh` | `/scripts/` |

### Development Automation Scripts

| Script | Purpose | Usage | Location |
|--------|---------|-------|----------|
| `ios_simulator_automation.applescript` | iOS Simulator automation | Executed via `run_simulator_automation.sh` | `/scripts/` |
| `run_simulator_automation.sh` | Simulator automation orchestrator | `./scripts/run_simulator_automation.sh [--test-only]` | `/scripts/` |
| `capture-app-screenshots.swift` | Swift screenshot capture | `swift scripts/capture-app-screenshots.swift` | `/scripts/` |
| `extract-ui-test-screenshots.sh` | UI test screenshot extraction | `./scripts/extract-ui-test-screenshots.sh` | `/scripts/` |

## 🚨 TROUBLESHOOTING GUIDE

### Monitoring Stack Issues

#### Grafana Not Accessible
```bash
# Check container status
docker ps | grep nestory-grafana

# Restart Grafana
docker restart nestory-grafana

# Check logs
docker logs nestory-grafana

# Verify port binding
lsof -i :3000
```

#### Prometheus Connection Issues
```bash
# Check Prometheus status
curl http://localhost:9090/-/healthy

# Restart Prometheus
docker restart nestory-prometheus

# Check configuration
docker exec nestory-prometheus cat /etc/prometheus/prometheus.yml
```

#### Pushgateway Not Receiving Metrics
```bash
# Test metric push
echo "test_metric 42" | curl --data-binary @- http://localhost:9091/metrics/job/test

# Check pushgateway logs
docker logs nestory-pushgateway

# Verify metrics
curl http://localhost:9091/metrics | grep test_metric
```

### CI/CD Runner Issues

#### Runner Not Responding
```bash
# Check runner status via GitHub API
gh api /repos/DrunkOnJava/Nestory/actions/runners --jq '.runners[] | {name: .name, status: .status}'

# Monitor runner connections
scripts/CI/monitor-runners.sh --status

# Test runner connectivity
scripts/CI/test-runner-connections.sh

# Check runner service (if local)
launchctl list | grep runner
```

#### Build Cache Problems
```bash
# Check cache statistics
scripts/setup-cache-compression.sh stats

# Clear cache and rebuild
scripts/setup-cache-compression.sh clean
nestory-clean
nestory-build

# Verify cache directory
ls -la ~/Library/Caches/NestoryBuildCache/

# Check compression status
scripts/setup-cache-compression.sh stats
```

### Build Performance Issues

#### Slow Build Times
```bash
# Measure current build time
scripts/measure-build-time.sh

# Check build optimization status
scripts/build-performance-report.sh

# Optimize build configuration
scripts/optimize-build-performance.sh

# Verify parallel build settings
xcodebuild -showBuildSettings | grep JOBS
```

#### Memory Issues During Build
```bash
# Check memory usage
top -pid $(pgrep xcodebuild) -l 1

# Monitor build process
scripts/build-performance-report.sh --memory

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Test Execution Problems

#### UI Tests Failing
```bash
# Reset simulators
xcrun simctl shutdown all
xcrun simctl erase all

# Setup simulator permissions
scripts/setup-simulator-permissions.sh

# Run with debug logging
FAST_TEST_MODE=0 scripts/quick_test.sh

# Check simulator status
xcrun simctl list devices | grep Booted
```

#### Unit Test Performance
```bash
# Run unit tests only
make test-unit

# Check test configuration
scripts/validate-configuration.sh

# Analyze test performance
scripts/dev_stats.sh
```

### Architecture Violations

#### Layer Import Violations
```bash
# Check architecture compliance
make verify-arch

# Run architecture verification script
scripts/architecture-verification.sh

# Generate architecture report
scripts/modularization-monitor.sh
```

#### Missing Service Wiring
```bash
# Verify service wiring
make verify-wiring

# Check for orphaned code
scripts/codebase-health-report.sh

# Validate configuration
scripts/validate-configuration.sh
```

### Docker Container Issues

#### Container Not Starting
```bash
# Check Docker daemon
docker version

# View container logs
docker logs [container_name]

# Restart specific container
docker restart [container_name]

# Recreate container
docker rm [container_name]
docker run [container_options]
```

#### Port Conflicts
```bash
# Check port usage
lsof -i :3000  # Grafana
lsof -i :9090  # Prometheus  
lsof -i :9091  # Pushgateway

# Kill process using port
kill -9 $(lsof -ti:3000)

# Restart with different port
docker run -p 3001:3000 [image]
```

### Script Execution Issues

#### Permission Denied
```bash
# Fix script permissions
find scripts/ -name "*.sh" -exec chmod +x {} \;

# Check specific script
ls -la scripts/[script_name].sh

# Make executable
chmod +x scripts/[script_name].sh
```

#### Missing Dependencies
```bash
# Check for required tools
which xcodebuild
which gh
which docker
which swift

# Validate environment
scripts/validate-configuration.sh

# Setup missing tools
scripts/optimize_xcode_workflow.sh
```

### Performance Degradation

#### Cold Start Times Increasing
```bash
# Run performance benchmarks
gh workflow run nightly-performance

# Check current metrics
curl http://localhost:9090/api/v1/query?query=nestory_cold_start_time

# Analyze performance trends
open http://localhost:3000  # Grafana dashboard
```

#### Build Cache Hit Rate Declining
```bash
# Check cache statistics
scripts/setup-cache-compression.sh stats

# Analyze cache effectiveness
scripts/build-performance-report.sh

# Optimize cache configuration
scripts/setup-build-cache.sh
```

### Emergency Recovery Procedures

#### Complete Environment Reset
```bash
# Clean all build artifacts
make clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/NestoryBuildCache/*

# Reset Docker containers
docker stop $(docker ps -q)
docker system prune -af

# Rebuild from scratch
scripts/optimize_xcode_workflow.sh
make build
```

#### Restore from Backup
```bash
# Check for configuration backups
ls ~/Backups/configs/nestory/

# Restore critical configurations
cp ~/Backups/configs/nestory/[config] ./

# Validate restoration
scripts/validate-configuration.sh
```