# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

### Strategic Context for Claude Code CLI - Nestory Project

## 📱 PROJECT OVERVIEW

**CRITICAL**: Nestory is a **personal home inventory app for insurance documentation**, NOT a business inventory/stock management system. 

The app helps homeowners and renters catalog their belongings for:
- Insurance claims after disasters (fire, flood, theft)
- Warranty tracking and expiration alerts
- Receipt storage and purchase documentation
- Estate planning and value tracking
- Personal organization (NOT stock levels)

### Current Implementation Status
- ✅ Core inventory management with photos
- ✅ Category system with SwiftData relationships
- ✅ Insurance PDF report generation (InsuranceReportService)
- ✅ Receipt OCR with automatic data extraction (ReceiptOCRService)
- ✅ CSV/JSON import/export (ImportExportService)
- ✅ Analytics dashboard with value insights
- ✅ Advanced search with documentation tracking
- ✅ Swift 6 strict concurrency compliance
- ✅ Documentation status indicators (NOT stock indicators)

### Key Implementation Details
- **NO "low stock" or "out of stock" references** - This is for personal belongings
- **Focus on documentation completeness** - Missing photos, receipts, serial numbers
- **Insurance-first features** - Everything oriented toward disaster preparedness

## 🎯 PRIME DIRECTIVES
1. **SPEC.json is LAW** - Never modify. All architecture decisions flow from it.
2. **Build incrementally** - Complete small working features, not partial large ones.
3. **ALWAYS WIRE UP IMPLEMENTATIONS** - Every service/feature MUST be accessible from the UI. No orphaned code!
4. **No placeholders** - Every `TODO` or `FIXME` must reference `ADR-\d+` or be rejected.
5. **Test everything** - 80% coverage minimum. No untested code ships.
6. **Fail fast** - If uncertain about architecture compliance, run `nestoryctl arch-verify` immediately.
7. **ALWAYS USE iPhone 16 Pro Max** - When building/testing in simulator, always use "iPhone 16 Pro Max" as the target device.

## 📐 ARCHITECTURE (TCA 6-LAYER)
```
App → Features → UI → Services → Infrastructure → Foundation
        ↘     ↗
```
**NEW TCA Implementation**: The project uses **The Composable Architecture (TCA)** with a 6-layer architecture for sophisticated state management and Apple Framework integration.

- **App**: Root app coordination and TCA store setup. Imports Features+UI+Services+Foundation.
- **Features**: TCA Reducers with business logic and state management. Import UI+Services+Foundation ONLY.
- **UI**: Shared SwiftUI components. Import Foundation ONLY. NO business logic.
- **Services**: Protocol-first domain APIs for TCA dependency injection. Import Infrastructure+Foundation ONLY.
- **Infrastructure**: Technical adapters (Cache, Network, Security). Import Foundation ONLY.
- **Foundation**: Pure types/models (Item, Category, Money). NO imports except Swift stdlib.

### Instant Violation Check
```swift
// ILLEGAL: Features → Infrastructure
import NetworkClient // ❌ Must go through Services

// ILLEGAL: UI → Services  
import InventoryService // ❌ UI components must be pure

// LEGAL: Features → Services (TCA Dependency)
@Dependency(\.inventoryService) var inventoryService // ✅

// LEGAL: App → Features (TCA Store)
StoreOf<RootFeature>() // ✅

// LEGAL: Services → Infrastructure
import NetworkClient // ✅ Services can use infrastructure
```

## 🏗️ CODE GENERATION RULES

### File Headers (MANDATORY)
```swift
//
// Layer: Foundation|Infrastructure|Services|UI|Features|App
// Module: [ModuleName]
// Purpose: [One line description]
//

import [ONLY_ALLOWED_IMPORTS]
```

### SwiftData Models Pattern
```swift
@Model
final class Item {
    // Required properties with defaults
    var id = UUID()
    var createdAt = Date()
    var updatedAt = Date()
    
    // Optional relationships
    var category: Category?
    
    // Required init for non-optionals
    init(name: String) {
        self.name = name
    }
}
```

### TCA Feature Pattern
```swift
// Features use TCA Reducer pattern with structured state management
@Reducer
struct InventoryFeature {
    @ObservableState
    struct State: Equatable {
        var items: [Item] = []
        var isLoading = false
        var searchText = ""
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case onAppear
        case loadItems
        case itemsLoaded([Item])
        case searchTextChanged(String)
        case itemTapped(Item)
    }
    
    @Dependency(\.inventoryService) var inventoryService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let items = try await inventoryService.fetchItems()
                    await send(.itemsLoaded(items))
                }
            case let .itemsLoaded(items):
                state.items = items
                state.isLoading = false
                return .none
            case let .searchTextChanged(text):
                state.searchText = text
                return .none
            case .itemTapped:
                return .none
            }
        }
    }
}
```

### TCA Service Integration
```swift
// Protocol-first service for TCA dependency injection
public protocol InventoryService: Sendable {
    func fetchItems() async throws -> [Item]
    func saveItem(_ item: Item) async throws
    func searchItems(query: String) async throws -> [Item]
}

// Live implementation for TCA dependencies
public struct LiveInventoryService: InventoryService {
    private let modelContext: ModelContext
    private let cache: Cache<UUID, Item>
    
    public init(modelContext: ModelContext) throws {
        self.modelContext = modelContext
        self.cache = try Cache(name: "inventory")
    }
    
    public func fetchItems() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>()
        return try modelContext.fetch(descriptor)
    }
}

// TCA Dependency Key
extension DependencyValues {
    var inventoryService: InventoryService {
        get { self[InventoryServiceKey.self] }
        set { self[InventoryServiceKey.self] = newValue }
    }
}

private enum InventoryServiceKey: DependencyKey {
    static let liveValue: InventoryService = LiveInventoryService()
}
```

## ⚡ PERFORMANCE CONTRACTS
```swift
// ALWAYS measure critical paths
let signpost = OSSignposter()
let state = signpost.beginInterval("fetch_items")
defer { signpost.endInterval("fetch_items", state) }

// ALWAYS batch database operations
try await database.transaction { context in
    items.forEach { context.insert($0) }
}

// ALWAYS use lazy loading for lists
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
            .onAppear { loadMoreIfNeeded(item) }
    }
}
```

## 🔒 SECURITY PATTERNS
```swift
// ALWAYS use Keychain for secrets
let secret = try Keychain.load("api_key") ?? Secrets.fallback

// ALWAYS encrypt sensitive data
let encrypted = try CryptoBox.encrypt(data, using: key)

// ALWAYS validate inputs
guard let validated = NonEmptyString(rawValue: input) else {
    throw ValidationError.empty
}
```

## 🧪 TEST REQUIREMENTS

### Unit Test Pattern
```swift
@MainActor
final class InventoryServiceTests: XCTestCase {
    var liveService: LiveInventoryService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        super.setUp()
        
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Item.self, Category.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)
        liveService = try LiveInventoryService(modelContext: modelContext)
    }

    func testFetchItems() async throws {
        let item = Item(name: "Test Item")
        modelContext.insert(item)
        try modelContext.save()
        
        let items = try await liveService.fetchItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Test Item")
    }
}
```

### UI Test Pattern
```swift
// Run single UI test with:
// xcodebuild test -scheme Nestory-Dev -destination 'platform=iOS Simulator,name=iPhone 16 Plus' -only-testing:NestoryUITests/testInventoryFlow

@MainActor
final class InventoryUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testInventoryFlow() {
        // Navigate to inventory tab
        app.tabBars.buttons["Inventory"].tap()
        
        // Test add item button
        app.navigationBars.buttons["Add Item"].tap()
        
        // Fill out form
        let nameField = app.textFields["Item Name"]
        nameField.tap()
        nameField.typeText("Test Item")
        
        // Save item
        app.buttons["Save"].tap()
        
        // Verify item appears
        XCTAssertTrue(app.staticTexts["Test Item"].exists)
    }
}
```

## 🚨 ERROR HANDLING

### Always Graceful Degradation
```swift
// NEVER crash on missing credentials
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? "DEMO_KEY"

// NEVER show raw errors to users
do {
    try await performOperation()
} catch {
    logger.error("Operation failed: \(error)")
    state.alert = .init(title: "Something went wrong", 
                        message: "Please try again")
}

// ALWAYS provide offline fallbacks
if !networkAvailable {
    return cachedData ?? .empty
}
```

## 🛠️ MAKEFILE SYSTEM

### Purpose
The Makefile serves as the **single source of truth** for all project operations, ensuring consistency across different chat sessions and context windows.

### Key Commands for Every Session

```bash
# Start of session
make doctor      # Verify project setup
make context     # Generate CURRENT_CONTEXT.md for session continuity

# Development workflow  
make run         # ALWAYS builds and runs on iPhone 16 Plus
make build       # Build with consistent settings
make check       # Run ALL verification checks

# Testing (critical)
make test        # Run Swift Package Manager tests
make test-xcode  # Run Xcode tests (includes UI tests)
make test-ui     # Run UI tests only on iPhone 16 Plus
swift test --filter InventoryServiceTests  # Run single test suite

# Verify compliance
make verify-wiring      # Ensure all services are wired to UI
make verify-no-stock    # Check for inappropriate inventory references
make verify-arch        # Verify architecture compliance

# Code quality
make lint        # Run SwiftLint
make format      # Run SwiftFormat

# Quick shortcuts
make r           # Shortcut for run
make b           # Shortcut for build
make c           # Shortcut for check
make d           # Shortcut for doctor
```

### Development Tools

```bash
# Create new components
make new-service NAME=MyService    # Create properly formatted service
make new-feature NAME=MyFeature    # Create feature scaffold

# Project maintenance
make stats       # Show project statistics
make todo        # List all TODOs
make clean       # Clean build artifacts
make fix         # Emergency rebuild when things go wrong
```

### Critical Enforcement

The Makefile **automatically enforces**:
- ✅ iPhone 16 Plus simulator usage (no more simulator confusion!)
- ✅ All services must be wired to UI (catches orphaned code)
- ✅ No business inventory references (insurance focus only)
- ✅ Architecture layer compliance
- ✅ Proper service template with @MainActor and ObservableObject

### Context Preservation

**ALWAYS run at session start:**
```bash
make context
```

This generates `CURRENT_CONTEXT.md` containing:
- Current wiring status
- Active services and views
- Project rules and reminders
- Git status
- Recent TODOs

Share this file when starting new chat sessions to maintain continuity!

## 🚀 DEPLOYMENT & CI/CD

### Current Status
- **Production Ready**: TestFlight build 3 successfully deployed
- **App Store Connect**: Full API integration with automated workflows
- **FastLane**: Complete CI/CD pipeline configured

### Deployment Commands
```bash
# Fastlane deployment (requires credentials)
bundle exec fastlane beta              # Build and upload to TestFlight
bundle exec fastlane release           # Submit to App Store
bundle exec fastlane screenshots       # Generate App Store screenshots

# Local testing
make archive                           # Create .xcarchive for distribution
make screenshot                        # Capture UI test screenshots
```

### App Store Connect Integration
The project includes sophisticated App Store Connect automation:
- **AppStoreConnectOrchestrator**: High-level workflow management
- **AppMetadataService**: Metadata and version management  
- **MediaUploadService**: Screenshot and asset upload
- **EncryptionDeclarationService**: Export compliance automation

### Build Configuration
- **Project Generation**: Uses XcodeGen with project.yml
- **Swift 6**: Strict concurrency in Release, minimal in Debug  
- **Simulator Target**: iPhone 16 Plus (enforced by Makefile)
- **Deployment Target**: iOS 17.0+

## 📋 SESSION BEHAVIOR

### Start Every Response With
1. Run `make doctor` to verify setup
2. Check what layer/module we're in
3. Verify allowed imports for that layer
4. Read relevant parts of SPEC.json

### Before Writing Code
1. State the layer explicitly: "Creating in Services layer..."
2. List allowed imports: "Can import: Infrastructure, Foundation"
3. Identify the pattern: "Using Service protocol pattern..."

### After Writing Code
1. Show the file header with Layer tag
2. Confirm no illegal imports
3. **CRITICAL: Show exactly how to wire this up in the UI**
4. Run `make verify-wiring` to ensure it's accessible
5. Suggest the verification command: `make check`

## ⚠️ IMPLEMENTATION CHECKLIST

**EVERY new feature/service MUST have:**
- [ ] Service/Logic implementation
- [ ] UI component/view
- [ ] **WIRED UP in existing navigation** (Tab, Sheet, Navigation Link, Button)
- [ ] Accessible from user interaction
- [ ] Build verification after wiring

**Example: Receipt OCR was created but NOT wired up initially:**
```swift
// ❌ WRONG: Created ReceiptOCRService and ReceiptCaptureView
// But no way for users to access it!

// ✅ RIGHT: Added to ItemDetailView
GroupBox("Receipt Documentation") {
    Button("Add Receipt") { 
        showingReceiptCapture = true  // WIRED UP!
    }
}
.sheet(isPresented: $showingReceiptCapture) {
    ReceiptCaptureView(item: item)  // ACCESSIBLE!
}
```

## 🔧 QUICK PATTERNS

### Need to Share Data?
```swift
// Use Services, not direct Feature→Feature
// Feature A → Service → Feature B
```

### Need Service Integration?
```swift
// Use @StateObject in views
struct InventoryListView: View {
    @StateObject private var inventoryService = InventoryService()
    
    var body: some View {
        List(inventoryService.items) { item in
            ItemRow(item: item)
        }
        .task {
            try? await inventoryService.fetchItems()
        }
    }
}
```

### Need Navigation?
```swift
// Use @State for sheet/navigation presentation
struct ContentView: View {
    @State private var showingAddItem = false
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationStack {
            // Content here
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView()
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
        }
    }
}
```

### Need Async Image Loading?
```swift
// Use AsyncImage with cache
AsyncImage(url: url) { image in
    image.resizable().aspectRatio(contentMode: .fit)
} placeholder: {
    ProgressView()
}
.onAppear { ImageCache.prefetch(url) }
```

## 🔌 WIRING CHECKLIST - NEVER SKIP THIS!

When implementing ANY new feature:

1. **Create the Service/Logic** ✓
2. **Create the View/UI** ✓  
3. **WIRE IT UP** ⚠️ **← MOST IMPORTANT STEP**
4. **Test in Simulator** ✓

### Where to Wire Features:

| Feature Type | Wire Location | How to Wire |
|-------------|---------------|-------------|
| Item-specific | ItemDetailView | Add button/section with sheet/navigation |
| Global utility | SettingsView | Add to Import/Export section |
| Browse/Search | SearchView | Add filter or search syntax |
| Analytics | AnalyticsDashboardView | Add chart/insight |
| Category | CategoriesView | Add management option |
| New major feature | ContentView | Add new tab |

### Wiring Examples:

```swift
// ALWAYS add @State for presentation
@State private var showingFeature = false

// ALWAYS add trigger in UI
Button("Access Feature") {
    showingFeature = true
}

// ALWAYS add presentation modifier
.sheet(isPresented: $showingFeature) {
    YourFeatureView()
}
```

## ⛔ NEVER DO THIS

### Never Cross Features
```swift
// ❌ WRONG
import Analytics // from inside Inventory

// ✅ RIGHT
@Dependency(\.analyticsService) var analytics
```

### Never Expose Infrastructure
```swift
// ❌ WRONG - Feature using URLSession
let (data, _) = try await URLSession.shared.data(from: url)

// ✅ RIGHT - Feature using Service
let data = try await networkService.fetch(from: url)
```

### Never Skip Tests
```swift
// ❌ WRONG
// TODO: Add tests later

// ✅ RIGHT
// Tests in Tests/Unit/[Module]/[Feature]Tests.swift
```

### Never Hardcode Secrets
```swift
// ❌ WRONG
let apiKey = "sk-abc123xyz789"

// ✅ RIGHT
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? "DEMO"
```

## 🎓 DECISION FLOWCHART

```mermaid
graph TD
    A[Need to add feature?] --> B{Which layer?}
    B -->|New screen| C[Features/]
    B -->|Shared UI| D[UI/]
    B -->|Business logic| E[Services/]
    B -->|Technical| F[Infrastructure/]
    B -->|Data model| G[Foundation/]
    
    C --> H{Check imports}
    D --> H
    E --> H
    F --> H
    G --> H
    
    H -->|Valid| I[Write code]
    H -->|Invalid| J[Run arch-verify]
    
    I --> K[Write tests]
    K --> L[Run nestoryctl check]
```

## 🚀 PHASE-SPECIFIC HINTS

### Phase A (Foundation)
- Focus on value objects and invariants
- SwiftData models are immutable schema after v1
- Every model needs init with required fields

### Phase B (Infrastructure)
- All IO must be abstracted
- Circuit breakers on all network calls
- File operations need proper error handling

### Phase C (Services)
- Protocol-first design
- Every service needs mock for tests
- TCA dependency keys go in single file

### Phase D (Inventory)
- This makes the app runnable - must be complete
- Include all CRUD operations
- Performance test with 500+ items

### Phase E (Capture)
- Vision framework for OCR
- AVFoundation for camera
- Graceful fallback if no camera access

### Phase F (Analytics)
- Use Swift Charts, not third-party
- Memoize expensive calculations
- Export must handle large datasets

### Phase G (Sharing)
- CloudKit zones per share
- Role enforcement in Service layer
- Offline queue for pending invites

### Phase H (Monetization)
- StoreKit 2 only, no legacy
- Products from local config for testing
- Entitlements drive feature gates

## 📊 QUALITY METRICS

### Every File Must
- [ ] Compile without warnings
- [ ] Have 80%+ test coverage
- [ ] Include layer header comment
- [ ] Pass SwiftLint rules
- [ ] Handle errors gracefully

### Every Feature Must
- [ ] Work offline (degraded is OK)
- [ ] Support iPhone + iPad
- [ ] Support Dark Mode
- [ ] Support Dynamic Type
- [ ] Include VoiceOver labels

### Every Commit Must
- [ ] Pass `nestoryctl check`
- [ ] Include conventional message
- [ ] Update PROJECT_CONTEXT.md
- [ ] Not break existing tests

## 💡 POWER MOVES

### Instant Architecture Check
```bash
alias noch="./DevTools/nestoryctl/.build/release/nestoryctl check"
```

### Quick Feature Scaffold
```swift
// Generate in correct folder structure
Features/[Name]/
├── [Name]Feature.swift      # TCA Reducer
├── [Name]View.swift         # SwiftUI View  
├── [Name]Models.swift       # Local types
└── [Name]DI.swift          # Dependencies
```

### Test Coverage Report
```bash
swift test --enable-code-coverage
xcrun llvm-cov report .build/debug/*.xctest/Contents/MacOS/* \
    -instr-profile .build/debug/codecov/default.profdata
```

### Performance Baseline Update
```bash
swift test --filter Performance
# If acceptable: update Tests/Performance/baselines.json
# Document why in DECISIONS.md
```

## 🎯 SUCCESS CRITERIA

You know you're doing it right when:
1. **No architecture violations** - `arch-verify` always passes
2. **Tests pass first try** - Well-structured code tests easily  
3. **Features are independent** - Can develop in parallel
4. **Performance is predictable** - Baselines rarely need updates
5. **Code reviews are boring** - Patterns are consistent

## 🔄 CONTINUOUS LOOP

```bash
while developing; do
    read SPEC.json
    check layer rules
    write code
    run tests
    run nestoryctl check
    commit
done
```

---

**Remember**: You're building production-grade iOS architecture. Every decision matters. Every pattern compounds. Build it right the first time.

**Your primary job**: Transform requirements into compliant, tested, performant code that respects the 6-layer architecture without exception.

**When in doubt**: Check SPEC.json → Run arch-verify → Ask for clarification → Then proceed.
- READ FILES BEFORE WRITING TO THE M