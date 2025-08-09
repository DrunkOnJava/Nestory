# CLAUDE.md
### Strategic Context for Claude Code CLI - Nestory Project

## 🎯 PRIME DIRECTIVES
1. **SPEC.json is LAW** - Never modify. All architecture decisions flow from it.
2. **Build incrementally** - Complete small working features, not partial large ones.
3. **No placeholders** - Every `TODO` or `FIXME` must reference `ADR-\d+` or be rejected.
4. **Test everything** - 80% coverage minimum. No untested code ships.
5. **Fail fast** - If uncertain about architecture compliance, run `nestoryctl arch-verify` immediately.

## 📐 ARCHITECTURE (IMMUTABLE)
```
App → Features → UI/Services → Infrastructure → Foundation
```
- **App**: Entry points only. Wires dependencies.
- **Features**: Own screens/reducers. Import UI+Services+Foundation ONLY.
- **UI**: Shared components. Import Foundation ONLY. NO business logic.
- **Services**: Domain APIs. Import Infrastructure+Foundation ONLY.
- **Infrastructure**: Technical adapters. Import Foundation ONLY.
- **Foundation**: Pure types/models. NO imports except Swift stdlib.

### Instant Violation Check
```swift
// ILLEGAL: Feature → Feature
import Capture // ❌ Inside Inventory feature

// ILLEGAL: Feature → Infrastructure  
import Network // ❌ Must go through Services

// LEGAL: Feature → Services
import InventoryService // ✅
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

### TCA Reducer Pattern
```swift
@Reducer
struct InventoryFeature {
    struct State: Equatable {
        var items: IdentifiedArrayOf<Item.State> = []
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case itemsResponse(TaskResult<[Item]>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.inventoryService) var inventory
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.itemsResponse(
                        TaskResult { try await inventory.fetch() }
                    ))
                }
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}
```

### Service Pattern
```swift
protocol InventoryService {
    func fetch() async throws -> [Item]
    func save(_ item: Item) async throws
}

struct LiveInventoryService: InventoryService {
    @Dependency(\.database) var database
    
    func fetch() async throws -> [Item] {
        try await database.fetch(Item.self)
    }
}

// TCA Dependency
extension DependencyValues {
    var inventoryService: InventoryService {
        get { self[InventoryServiceKey.self] }
        set { self[InventoryServiceKey.self] = newValue }
    }
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
final class InventoryTests: XCTestCase {
    func testFetch() async {
        let store = TestStore(
            initialState: InventoryFeature.State(),
            reducer: { InventoryFeature() }
        )
        
        await store.send(.onAppear)
        await store.receive(.itemsResponse(.success(mockItems))) {
            $0.items = IdentifiedArray(uniqueElements: mockItems)
        }
    }
}
```

### Snapshot Test Pattern
```swift
func testInventoryView() {
    let view = InventoryView(store: .mock)
    
    assertSnapshot(matching: view, as: .image(on: .iPhone15))
    assertSnapshot(matching: view, as: .image(on: .iPadAir))
    assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
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

## 📋 SESSION BEHAVIOR

### Start Every Response With
1. Check what layer/module we're in
2. Verify allowed imports for that layer
3. Read relevant parts of SPEC.json

### Before Writing Code
1. State the layer explicitly: "Creating in Services layer..."
2. List allowed imports: "Can import: Infrastructure, Foundation"
3. Identify the pattern: "Using Service protocol pattern..."

### After Writing Code
1. Show the file header with Layer tag
2. Confirm no illegal imports
3. Suggest the verification command

## 🔧 QUICK PATTERNS

### Need to Share Data?
```swift
// Use Services, not direct Feature→Feature
// Feature A → Service → Feature B
```

### Need Side Effects?
```swift
// Use TCA dependencies
@Dependency(\.service) var service
return .run { send in
    await send(.response(TaskResult { 
        try await service.perform() 
    }))
}
```

### Need Navigation?
```swift
// Use TCA presentation
@PresentationState var destination: Destination.State?
case .itemTapped(let id):
    state.destination = .detail(ItemDetail.State(id: id))
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