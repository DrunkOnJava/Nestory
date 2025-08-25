# Emergency Modularization Procedure

This document provides step-by-step guidance for modularizing large Swift files that exceed the established size limits in the Nestory project.

## 🚨 Critical Thresholds

- **CRITICAL (>600 lines)**: MUST be modularized before any commits
- **HIGH PRIORITY (500-599 lines)**: Should be modularized soon
- **MEDIUM PRIORITY (400-499 lines)**: Consider modularizing

## 🔧 Automated Detection

Run these commands to identify files that need modularization:

```bash
# Full architecture check (recommended)
DevTools/nestoryctl/.build/debug/nestoryctl arch-verify

# Pre-commit check (automatic)
git commit  # Will block if critical files found

# CI/CD check (automatic)
# GitHub Actions will fail PRs with critical files
```

## 📋 Emergency Modularization Steps

### Step 1: Identify Split Points

Analyze the file to identify natural boundaries for splitting:

```swift
// Look for these patterns to identify split points:

// 1. MARK: comments indicate logical sections
// MARK: - User Interface
// MARK: - Data Processing  
// MARK: - Network Operations

// 2. Nested types that can be extracted
struct ValidationRules {
    // Move to separate file
}

// 3. Extensions that can be separated
extension MyView {
    // Move to MyView+Extensions.swift
}

// 4. Helper functions that can be grouped
private func validateInput() { }
private func sanitizeData() { }
// Move to InputValidation.swift

// 5. Protocol conformances
extension MyView: UITableViewDataSource {
    // Move to MyView+UITableViewDataSource.swift
}
```

### Step 2: Determine Target Layer

Choose the appropriate layer based on the 6-layer architecture:

| Content Type | Target Layer | Notes |
|-------------|-------------|-------|
| SwiftUI Views with business logic | `Features/[Domain]/` | TCA Reducers, ViewModels |
| Pure SwiftUI components | `UI/Components/` | Reusable, no business logic |
| Business logic, protocols | `Services/[Domain]/` | Domain APIs, implementations |
| Technical utilities | `Infrastructure/[Area]/` | Network, Cache, Security |
| Data models, pure types | `Foundation/Models/` | Item, Category, etc. |
| App-level coordination | `App-Main/` | Root views, app lifecycle |

### Step 3: Create Modular Files

#### 3.1 Extract View Components

For large SwiftUI views:

```swift
// Original: ClaimSubmissionView.swift (777 lines)
// Split into:

// Features/Insurance/ClaimSubmissionFeature.swift
@Reducer
struct ClaimSubmissionFeature {
    @ObservableState
    struct State: Equatable {
        // State management
    }
    enum Action {
        // Actions
    }
    var body: some ReducerOf<Self> {
        // Business logic
    }
}

// Features/Insurance/ClaimSubmissionView.swift
struct ClaimSubmissionView: View {
    @Bindable var store: StoreOf<ClaimSubmissionFeature>
    
    var body: some View {
        // Main view structure
        ClaimHeaderView(store: store.scope(state: \.header, action: \.header))
        ClaimFormView(store: store.scope(state: \.form, action: \.form))
        ClaimActionsView(store: store.scope(state: \.actions, action: \.actions))
    }
}

// UI/Components/ClaimHeaderView.swift
struct ClaimHeaderView: View {
    // Pure UI component
}

// UI/Components/ClaimFormView.swift  
struct ClaimFormView: View {
    // Pure UI component
}

// UI/Components/ClaimActionsView.swift
struct ClaimActionsView: View {
    // Pure UI component
}
```

#### 3.2 Extract Service Logic

For large service files:

```swift
// Original: ClaimPackageAssemblerService.swift (948 lines)
// Split into:

// Services/Insurance/ClaimPackageAssemblerService.swift (Protocol + Core)
public protocol ClaimPackageAssemblerService: Sendable {
    func assembleClaimPackage() async throws -> ClaimPackage
}

public struct LiveClaimPackageAssemblerService: ClaimPackageAssemblerService {
    // Core assembly logic only
}

// Services/Insurance/ClaimDocumentCollector.swift
struct ClaimDocumentCollector {
    // Document collection logic
}

// Services/Insurance/ClaimValidationEngine.swift
struct ClaimValidationEngine {
    // Validation rules and checks
}

// Services/Insurance/ClaimPackageBuilder.swift
struct ClaimPackageBuilder {
    // Package construction logic
}
```

#### 3.3 Extract Extensions

For files with many extensions:

```swift
// Original file with many extensions
// Split into:

// CoreType.swift (Main definition)
struct MyType {
    // Core properties and methods only
}

// MyType+Validation.swift
extension MyType {
    var isValid: Bool { /* validation logic */ }
    func validate() throws { /* validation */ }
}

// MyType+Formatting.swift
extension MyType {
    var displayString: String { /* formatting */ }
    func formatted(style: FormatStyle) -> String { /* formatting */ }
}

// MyType+Persistence.swift
extension MyType {
    func save() async throws { /* persistence */ }
    static func load() async throws -> [MyType] { /* persistence */ }
}
```

### Step 4: Update Imports and Dependencies

After splitting files, update imports:

```swift
// Before modularization (in large file):
import SwiftUI
import Foundation
import ComposableArchitecture
import NetworkClient
import ValidationEngine

// After modularization:

// In Feature file:
import ComposableArchitecture
import Services  // Only access through protocols

// In UI Component:
import SwiftUI
// NO business logic imports

// In Service file:
import Foundation
import Infrastructure  // Technical dependencies only
```

### Step 5: Test Build and Functionality

Verify the modularization didn't break anything:

```bash
# 1. Build check
make build

# 2. Architecture compliance
DevTools/nestoryctl/.build/debug/nestoryctl arch-verify

# 3. Run tests
make test

# 4. Manual testing
make run
# Test the affected functionality in simulator
```

### Step 6: Commit Modularized Components

Use atomic commits for each logical component:

```bash
# Commit each new component separately
git add Features/Insurance/ClaimSubmissionFeature.swift
git commit -m "feat: extract ClaimSubmissionFeature from large view

- Move TCA reducer logic to proper Features layer
- Separate business logic from UI presentation
- Part of modularization for ClaimSubmissionView.swift (777→200 lines)

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git add UI/Components/ClaimHeaderView.swift UI/Components/ClaimFormView.swift
git commit -m "feat: extract reusable UI components for claims

- Create ClaimHeaderView and ClaimFormView as pure UI components
- No business logic, suitable for reuse across claim features
- Part of modularization for ClaimSubmissionView.swift (777→200 lines)

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Finally, commit the reduced original file
git add Features/Insurance/ClaimSubmissionView.swift
git commit -m "refactor: complete ClaimSubmissionView modularization

- Reduce from 777 to ~200 lines by extracting components
- Use TCA store scoping for child components  
- Complies with file size guardrails (<600 lines critical threshold)

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## 🎯 Specific Strategies by File Type

### Large TCA Features

**Problem**: Feature files with too much state/logic
**Solution**: Split into sub-features

```swift
// Before: InventoryFeature.swift (500+ lines)
@Reducer
struct InventoryFeature {
    @ObservableState
    struct State {
        var items: [Item] = []
        var search: SearchState = .init()
        var filters: FilterState = .init()
        var sorting: SortState = .init()
        // Too much state!
    }
}

// After: Split into composed features
@Reducer
struct InventoryFeature {
    @ObservableState
    struct State {
        var items: [Item] = []
        var search: SearchFeature.State = .init()
        var filters: FilterFeature.State = .init()
        var sorting: SortFeature.State = .init()
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }
        Scope(state: \.filters, action: \.filters) {
            FilterFeature()
        }
        Scope(state: \.sorting, action: \.sorting) {
            SortFeature()
        }
        Reduce { state, action in
            // Only core inventory logic here
        }
    }
}
```

### Large SwiftUI Views

**Problem**: Views with too many subviews and complex layout
**Solution**: Extract view components

```swift
// Before: Large body with many subviews
var body: some View {
    VStack {
        // 50+ lines of header content
        HStack { ... }
        Image { ... }
        Text { ... }
        
        // 100+ lines of form content  
        Form { ... }
        
        // 50+ lines of action buttons
        HStack { ... }
    }
}

// After: Composed from smaller views
var body: some View {
    VStack {
        ItemDetailHeaderView(item: item)
        ItemDetailFormView(item: item)
        ItemDetailActionsView(item: item)
    }
}
```

### Large Service Classes

**Problem**: Service classes handling too many responsibilities
**Solution**: Single-responsibility services

```swift
// Before: ClaimProcessingService with multiple concerns
class ClaimProcessingService {
    func validateClaim() { /* 50 lines */ }
    func generateDocuments() { /* 100 lines */ }
    func submitToInsurer() { /* 75 lines */ }
    func trackStatus() { /* 50 lines */ }
    func handleCallbacks() { /* 100 lines */ }
}

// After: Separate services for each concern
protocol ClaimValidationService {
    func validateClaim() async throws
}

protocol ClaimDocumentService {
    func generateDocuments() async throws
}

protocol ClaimSubmissionService {
    func submitToInsurer() async throws
}

// Coordinate through higher-level service
struct ClaimProcessingOrchestrator {
    private let validator: ClaimValidationService
    private let documentService: ClaimDocumentService
    private let submissionService: ClaimSubmissionService
    
    func processClaim() async throws {
        try await validator.validateClaim()
        try await documentService.generateDocuments()
        try await submissionService.submitToInsurer()
    }
}
```

## 🚫 Common Modularization Mistakes

### ❌ Wrong: Creating More Large Files

```swift
// Don't just move code to create another large file
// ClaimSubmissionView.swift (777 lines) 
// ↓
// ClaimSubmissionHelpers.swift (600 lines) ❌
```

### ❌ Wrong: Breaking Architectural Layers

```swift
// Don't move UI code to Services layer
// Services/ClaimSubmissionView.swift ❌

// Don't move business logic to UI layer  
// UI/Components/ClaimValidationLogic.swift ❌
```

### ❌ Wrong: Creating Circular Dependencies

```swift
// Don't create imports that create cycles
// A imports B, B imports C, C imports A ❌
```

### ✅ Right: Follow Single Responsibility

```swift
// Each file should have one clear purpose
// ClaimValidation.swift - only validation logic
// ClaimFormatting.swift - only formatting logic
// ClaimSubmissionView.swift - only view presentation
```

## 📊 Success Metrics

After modularization, verify:

- ✅ No files exceed 600 lines (critical threshold)
- ✅ All files pass architecture verification: `nestoryctl arch-verify`
- ✅ Build succeeds: `make build`
- ✅ Tests pass: `make test`
- ✅ App functions correctly: `make run`
- ✅ Each file has single, clear responsibility
- ✅ Import dependencies follow layer rules

## 🔗 Related Documentation

- [CLAUDE.md](./CLAUDE.md) - Full architecture guidelines
- [SPEC.json](./SPEC.json) - Architecture specification
- [DECISIONS.md](./DECISIONS.md) - Architecture decision records

## 💡 Getting Help

If you're unsure about modularization strategy:

1. **Check layer rules**: See CLAUDE.md for allowed imports per layer
2. **Run arch-verify**: `nestoryctl arch-verify` shows violations
3. **Follow patterns**: Look at existing well-modularized files as examples
4. **Test early**: Build and test after each extraction step

Remember: The goal is **sustainable architecture**, not just smaller files. Each modularized component should have clear boundaries and single responsibility.