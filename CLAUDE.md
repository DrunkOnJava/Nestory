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
make fast-build   # Optimized parallel build

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

Remember: SPEC.json defines the architecture. When uncertain, check allowed imports there.