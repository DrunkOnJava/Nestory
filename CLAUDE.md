# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📱 PROJECT CONTEXT

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
- **Cold Start P95**: < 1800ms
- **DB Read P95**: < 250ms (50 items)
- **Scroll Jank**: < 3%
- **Crash-Free Rate**: > 99.8%
- **Build Time**: ~30s (fast-build with 10 cores)

## 🏗️ ARCHITECTURE

### 6-Layer TCA Architecture (STRICT)
```
App → Features → UI → Services → Infrastructure → Foundation
        ↘     ↗
```

**Layer Import Rules (@SPEC.json is LAW):**
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

### Development Workflow (with Automatic Metrics)
```bash
# ALL builds automatically send metrics to dashboard at http://localhost:3000
# Build errors, warnings, duration, and success rates are tracked

# Build and run (always iPhone 16 Pro Max) 
make run          # Build and launch in simulator (metrics enabled)
make build        # Build only (metrics enabled)
make fast-build   # Optimized parallel build (metrics enabled)

# When using xcodegen or xcodebuild directly:
Scripts/CI/xcodegen-with-metrics.sh    # Instead of 'xcodegen'
Scripts/CI/xcodebuild-with-metrics.sh  # Instead of 'xcodebuild'
Scripts/CI/build-with-timeout.sh -t 600 -m --  # For timeout protection (prod builds)

# Build Health & Stuck Detection:
Scripts/CI/build-health-monitor.sh status    # Check current build health  
Scripts/CI/build-health-monitor.sh monitor   # Start continuous monitoring
Scripts/CI/build-health-monitor.sh test      # Run single health check

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

# Utilities
make context      # Generate CURRENT_CONTEXT.md for session continuity
make stats        # Project statistics
make todo         # List all TODOs
make clean        # Clean build artifacts
```

### Specialized iOS Automation Tools
```bash
# SwiftLint Code Quality Analysis
fastlane ios swiftlint_quality           # Comprehensive code quality analysis with auto-fixes
swiftlint lint --config .swiftlint.yml   # Direct SwiftLint analysis (no plugins)
swiftlint autocorrect                     # Auto-fix correctable issues

# iOS Simulator Control & Management  
fastlane ios simulator_control           # Boot and manage multiple simulators
fastlane ios simulator_cleanup           # Clean up simulator state
xcrun simctl boot "iPhone 16 Pro Max"    # Boot specific simulator directly
xcrun simctl list devices                # List available simulators
xcrun simctl shutdown all                # Shutdown all simulators

# Semantic Versioning & Changelog Generation
fastlane ios semantic_versioning         # Generate comprehensive changelog
git log --oneline --no-merges -25        # View recent commits for changelog

# Focused TestFlight Upload Options
fastlane ios focused_testflight          # Streamlined TestFlight upload
fastlane ios upload_current_archive      # Upload specific archive to TestFlight
ruby fastlane/DirectTestFlightUpload.rb  # Direct upload bypassing plugins

# Run Multiple Tools
fastlane ios run_tools tools:swiftlint,simulators,versioning  # Run specific tools
fastlane ios run_tools tools:swiftlint   # Run only SwiftLint analysis
fastlane ios run_tools tools:simulators  # Run only simulator control
```

**📋 Comprehensive Tool Documentation**: See @fastlane/SPECIALIZED_iOS_TOOLS_GUIDE.md for complete technical specifications, quality metrics, integration patterns, and production readiness guidelines.

### UI Testing Commands
```bash
# Run specific UI test
xcodebuild test -scheme Nestory-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  -only-testing:NestoryUITests/[TestClass]/[testMethod]
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
enum MyServiceKey: DependencyKey {
    static var liveValue: MyService {
        do {
            let service = try LiveMyService()
            
            // Record successful service creation
            Task { @MainActor in
                ServiceHealthManager.shared.recordSuccess(for: .myService)
            }
            
            return service
        } catch {
            // Record service failure for health monitoring
            Task { @MainActor in
                ServiceHealthManager.shared.recordFailure(for: .myService, error: error)
                ServiceHealthManager.shared.notifyDegradedMode(service: .myService)
            }
            
            // Structured error logging (never use print statements)
            Logger.service.error("Failed to create MyService: \(error.localizedDescription)")
            Logger.service.info("Falling back to MockMyService for graceful degradation")
            
            #if DEBUG
            Logger.service.debug("MyService creation debug info: \(error)")
            #endif
            
            return MockMyService() // Graceful degradation
        }
    }
    
    static let testValue: MyService = MockMyService()
}
```

## 🛡️ ERROR HANDLING & RELIABILITY PATTERNS

### Critical Safety Rules
1. **NEVER USE `try!`** - All force unwraps eliminated for crash-free operation
2. **ALWAYS PROVIDE FALLBACKS** - Every service has mock implementation for graceful degradation  
3. **USE STRUCTURED LOGGING** - Replace all `print()` with `Logger.service` calls
4. **MONITOR SERVICE HEALTH** - Integrate with ServiceHealthManager for failure tracking

### ModelContainer Creation Pattern
```swift
// ✅ Safe Pattern (REQUIRED)
do {
    let container = try ModelContainer(for: Item.self, configurations: config)
    return MyView().modelContainer(container)
} catch {
    Logger.service.error("Failed to create ModelContainer: \(error.localizedDescription)")
    return Text("Data initialization failed: \(error.localizedDescription)")
        .foregroundColor(.red)
}

// ❌ Dangerous Pattern (FORBIDDEN)
let container = try! ModelContainer(for: Item.self) // Will crash in production!
```

### TCA Error State Management
```swift
@ObservableState
struct State: Equatable {
    var errorMessage: String?
    var showingError = false
    var isLoading = false
}

enum Action {
    case setError(String?)
    case dismissError
    case someAsyncAction
    case someAsyncActionResponse(Result<SuccessType, Error>)
}
```

### Service Health Integration
All service dependencies must integrate with ServiceHealthManager:
- Record success: `ServiceHealthManager.shared.recordSuccess(for: .serviceName)`  
- Record failure: `ServiceHealthManager.shared.recordFailure(for: .serviceName, error: error)`
- Notify degraded mode: `ServiceHealthManager.shared.notifyDegradedMode(service: .serviceName)`

### Comprehensive Documentation
See @Documentation/ERROR_HANDLING_GUIDE.md for complete patterns and examples.

## 🚨 COMMON PITFALLS TO AVOID

1. **Cross-layer imports** - Features importing Infrastructure (must go through Services)
2. **Force unwraps** - Replace try! with proper error handling (CRITICAL SAFETY ISSUE)
3. **Missing wiring** - Creating features without UI access points
4. **Stock references** - This is for personal items, not business inventory
5. **Hardcoded secrets** - Use ProcessInfo.environment or Keychain
6. **Print statements** - Use Logger.service instead of print() for debugging
7. **Missing mock services** - Every service needs mock implementation for graceful degradation
8. **Skipping verification** - Always run `make verify-arch` after changes
9. **Runaway processes** - Always use timeout protection in scripts and fastlane lanes

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
- **CI/CD**: Fastlane configured
- **Architecture Compliance**: Enforced via nestoryctl

### Quality Metrics
- **Test Coverage**: Target 80% minimum
- **SwiftLint Rules**: 95+ active rules
- **Architecture Violations**: 0 tolerance
- **Documentation**: All public APIs documented

## 🔍 QUICK ARCHITECTURE CHECK

```swift
// ❌ ILLEGAL
import NetworkClient  // in Features layer
import InventoryService  // in UI layer

// ✅ LEGAL
@Dependency(\.inventoryService) var service  // in Features
import Foundation  // in any layer
```

Remember: @SPEC.json defines the architecture. When uncertain, check allowed imports there.
- always check if the simulator is already running and which are booted, do not use beta versions

## 🛡️ PROCESS MANAGEMENT & CLEANUP

### Preventing Runaway Processes
To prevent the Ruby process accumulation that previously affected this project, we've implemented comprehensive process management:

**Key Commands:**
```bash
make cleanup-processes     # Clean up any runaway development processes  
make emergency-cleanup     # Emergency cleanup - kill all development processes
make process-status       # Show current development process status
make install-process-monitor  # Install automatic process cleanup (cron job)
```

**Direct Script Usage:**
```bash
./Scripts/cleanup-runaway-processes.sh cleanup    # Normal cleanup
./Scripts/cleanup-runaway-processes.sh emergency  # Emergency cleanup  
./Scripts/cleanup-runaway-processes.sh status     # Process status
./Scripts/cleanup-runaway-processes.sh install-cron # Install monitoring
```

### Automatic Protections Implemented
1. **Fastlane Timeout Protection**: All test commands use timeout to prevent hanging
2. **PID File Management**: Background processes create tracking files for cleanup  
3. **Infinite Loop Prevention**: Build monitoring scripts have max runtime limits
4. **Pre-commit Hooks**: Prevent committing scripts with infinite loop patterns
5. **Emergency Cleanup**: Aggressive process termination when needed

### Process Thresholds  
- **Max Ruby/fastlane processes**: 5 (configurable via MAX_RUBY_PROCESSES)
- **Max xcodebuild processes**: 3 (configurable via MAX_XCODEBUILD_PROCESSES)
- **Monitoring runtime limit**: 2 hours before auto-shutdown
- **Cleanup frequency**: Every 30 minutes when cron job installed

**⚠️ Emergency Recovery**: If you encounter massive process accumulation again, run `make emergency-cleanup` to kill all development processes immediately.