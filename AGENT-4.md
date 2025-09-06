# AGENT-4: Mock Services Specialist

## Mission
You are responsible for fixing ALL mock service protocol conformance issues and concurrency problems in the test suite. The protocols have evolved and mock services need updating.

## Critical Context
- **InventoryService Protocol**: Now requires `fetchRooms()` and `exportInventory(format:)`
- **NetworkSimulator**: Has actor isolation issues needing @MainActor or proper async handling
- **ExportFormat**: May need local definition if not accessible
- **Sendable Conformance**: NetworkSimulator needs to be Sendable or properly isolated

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/Mocks/EnhancedMockServices.swift`
2. All files containing `MockInventoryService` implementations:
   - ItemDetailFeatureTests.swift (line 383)
   - ItemEditFeatureTests.swift (line 543)
   - SearchFeatureTests.swift (line 597)
   - InsuranceWorkflowIntegrationTests.swift (line 80)

## Specific Errors to Fix

### EnhancedMockServices.swift:
```
Lines 139, 141, 238, 240, 369, 371, 392, 394, 496, 498: NetworkSimulator Sendable issues
- Non-sendable type 'NetworkSimulator' cannot exit main actor-isolated context
- Expression is 'async' but is not marked with 'await'
```

### MockInventoryService Protocol Conformance:
```
All instances: Does not conform to protocol 'InventoryService'
Missing:
- func fetchRooms() async throws -> [Room]
- func exportInventory(format: ExportFormat) async throws -> Data
```

### MockInsuranceReportService (line 178):
```
Missing:
- generateInsuranceReport(items:categories:options:)
- exportReport(_:filename:)
- shareReport(_:)
```

### MockReceiptOCRService (line 189):
```
Missing:
- processReceiptImage(_:)
```

## Patterns to Fix

### Pattern 1: Fix MockInventoryService Protocol Conformance
**ADD TO EVERY MockInventoryService:**
```swift
func fetchRooms() async throws -> [Room] {
    return []
}

func exportInventory(format: ExportFormat) async throws -> Data {
    return Data()
}
```

### Pattern 2: Define ExportFormat Locally (if needed)
**ADD AT TOP OF FILE IF MISSING:**
```swift
enum ExportFormat: String {
    case csv = "csv"
    case json = "json"
    case pdf = "pdf"
}
```

### Pattern 3: Fix NetworkSimulator Concurrency
**OPTION A - Make NetworkSimulator @MainActor:**
```swift
@MainActor
class NetworkSimulator {
    static let shared = NetworkSimulator()
    // ...
}
```

**OPTION B - Make NetworkSimulator actor:**
```swift
actor NetworkSimulator {
    static let shared = NetworkSimulator()
    // ...
}
```

**OPTION C - Add @unchecked Sendable:**
```swift
final class NetworkSimulator: @unchecked Sendable {
    static let shared = NetworkSimulator()
    // ...
}
```

### Pattern 4: Fix async/await Issues
**WHERE YOU SEE:**
```swift
if NetworkSimulator.shared.shouldFail {
```

**CHANGE TO (if NetworkSimulator is actor):**
```swift
if await NetworkSimulator.shared.shouldFail {
```

### Pattern 5: Fix MockInsuranceReportService
**ADD:**
```swift
func generateInsuranceReport(items: [Item], categories: [Category], options: ReportOptions) async throws -> Data {
    return Data()
}

func exportReport(_ data: Data, filename: String) async throws -> URL {
    return URL(fileURLWithPath: "/tmp/\(filename)")
}

func shareReport(_ url: URL) async {
    // Mock implementation
}
```

### Pattern 6: Fix MockReceiptOCRService
**ADD:**
```swift
func processReceiptImage(_ image: UIImage) async throws -> EnhancedReceiptData {
    return EnhancedReceiptData(
        backingData: Receipt(
            vendor: "Mock Store",
            total: Money(minorUnits: 10000, currencyCode: "USD"),
            purchaseDate: Date()
        )
    )
}
```

## Coordination Rules
1. **DO NOT MODIFY** TestDataFactory.swift - Agent-10's responsibility
2. **DO NOT MODIFY** test methods themselves - only mock service implementations
3. **COORDINATE** with Agent-2/3 if they need specific mock behavior
4. **DOCUMENT** any new mock capabilities you add
5. **USE** consistent error throwing patterns across all mocks

## Success Criteria
- [ ] All MockInventoryService instances conform to protocol
- [ ] NetworkSimulator concurrency issues resolved
- [ ] All mock services have required protocol methods
- [ ] No Sendable conformance warnings
- [ ] All async/await properly handled
- [ ] Files compile without mock-related errors

## Testing Your Changes
```bash
# Test your specific files
swift build --target NestoryTests 2>&1 | grep "EnhancedMockServices.swift"
swift build --target NestoryTests 2>&1 | grep "MockInventoryService"
```

## Important Notes
- Choose ONE concurrency fix approach for NetworkSimulator and apply consistently
- Mock implementations can be minimal - just return empty/default values
- If ReportOptions or EnhancedReceiptData are undefined, create minimal structs
- Ensure all async methods are properly marked
- Consider if mocks need to maintain state between calls