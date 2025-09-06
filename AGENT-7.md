# AGENT-7: Integration Tests Part 2 Specialist

## Mission
You are responsible for fixing ErrorRecoveryTests.swift and InsuranceWorkflowIntegrationTests.swift, focusing on mock service issues, duplicate InsuranceTestScenarios, and Receipt/Warranty constructors.

## Critical Context
- **InsuranceTestScenarios**: Duplicate definition exists - must resolve
- **Receipt constructor**: Uses Money type with backingData pattern
- **MockInventoryService**: Missing protocol methods
- **Item constructor**: Now simplified, many parameters removed
- **Room constructor**: Only accepts name parameter

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/ErrorRecoveryTests.swift`
2. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/InsuranceWorkflowIntegrationTests.swift`
3. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/InsuranceTestScenarios.swift`

## Specific Errors to Fix

### ErrorRecoveryTests.swift:
```
Line 25: Cannot convert Room.Type to PersistentModel array element
Line 52: Cannot assign to 'failureError' (get-only property)
Lines 55, 62: MockInventoryService has no member 'getAllItems'
Line 118: Cannot assign to 'fetchDescriptor' (let constant)
Line 157: Cannot assign to 'networkError' (get-only)
Line 165: NetworkError doesn't conform to Equatable
Line 165: NetworkError has no member 'connectionLost'
Line 168: MockInventoryService has no member 'getAllItems'
Line 203: Cannot assign to 'diskError' (get-only)
Line 251: Cannot assign to 'processingError' (get-only)
Line 251: ReceiptOCRError has no member 'serviceUnavailable'
Line 273: Cannot assign to 'pdfError' (get-only)
Lines 443, 452, 455: Cannot use mutating member on immutable value
Line 498: ReceiptOCRError has no member 'serviceUnavailable'
Line 505: Missing arguments for Receipt init
```

### InsuranceWorkflowIntegrationTests.swift:
```
Line 58: InsuranceTestScenarios has no member 'floodDamage'
Line 80: MockInventoryService doesn't conform to protocol
Line 178: MockInsuranceReportService doesn't conform to protocol
Line 184: Optional Decimal unwrapping needed
Line 189: MockReceiptOCRService doesn't conform to protocol
Lines 191-192: Receipt constructor issues
Line 204: Duplicate InsuranceTestScenarios definition
Line 208: Extra 'floor' argument in Room constructor
Lines 211, 222, 233, 257: Item constructor has too many arguments
Lines 251-253: Extra 'floor' argument in Room constructor
```

### InsuranceTestScenarios.swift:
```
Line 12: Invalid redeclaration of 'InsuranceTestScenarios'
Lines 38, 53, 67, 109, 123, 137, 180, 207: item.currentValue doesn't exist
Line 236: item.currentValue and optional unwrapping
Line 298: Missing 'into:' label
Line 359: reduce produces wrong type
Line 382: Trailing closure issue with filter
```

## Patterns to Fix

### Pattern 1: Remove Duplicate InsuranceTestScenarios
**CHOOSE ONE FILE TO KEEP** (likely InsuranceTestScenarios.swift)
**In InsuranceWorkflowIntegrationTests.swift:**
```swift
// Remove the duplicate struct definition starting at line 204
// Use import or reference the original
```

### Pattern 2: Fix Mock Service Get-Only Properties
**INSTEAD OF:**
```swift
mockService.failureError = someError
```
**CREATE A CONFIGURED MOCK:**
```swift
class ConfigurableMockService: InventoryService {
    var shouldFail = false
    var errorToThrow: Error?
    
    // Implement methods using these properties
}
```

### Pattern 3: Fix Receipt Constructor
**INCORRECT:**
```swift
Receipt(merchantName: "Store", totalAmount: 99.99, purchaseDate: Date())
```
**CORRECT:**
```swift
Receipt(
    vendor: "Store",
    total: Money(minorUnits: 9999, currencyCode: "USD"),
    purchaseDate: Date()
)
```

### Pattern 4: Fix Item Constructor
**INCORRECT:**
```swift
Item(
    name: "Test",
    description: "Desc",
    purchasePrice: 100,
    category: category,
    room: room,
    // many more parameters...
)
```
**CORRECT:**
```swift
let item = Item(name: "Test")
item.itemDescription = "Desc"
item.purchasePrice = Decimal(100)
item.category = category
item.room = room?.name  // Room is now string
```

### Pattern 5: Fix Room Constructor
**INCORRECT:**
```swift
Room(name: "Living Room", icon: "sofa", floor: "Ground")
```
**CORRECT:**
```swift
Room(name: "Living Room")
// Properties must be set separately if Room supports them
```

### Pattern 6: Replace getAllItems
**REPLACE:**
```swift
mockService.getAllItems()
```
**WITH:**
```swift
try await mockService.fetchItems()  // or whatever the protocol defines
```

### Pattern 7: Fix NetworkError Cases
**REPLACE:**
```swift
NetworkError.connectionLost
NetworkError.serviceUnavailable
```
**WITH valid cases like:**
```swift
NetworkError.timeout
NetworkError.invalidResponse
```

### Pattern 8: Fix currentValue References
**REPLACE ALL:**
```swift
item.currentValue
```
**WITH:**
```swift
item.purchasePrice  // or remove if not needed
```

### Pattern 9: Fix reduce for Decimal
**INCORRECT:**
```swift
items.reduce(0) { $0 + $1.purchasePrice }
```
**CORRECT:**
```swift
items.reduce(into: Decimal(0)) { result, item in
    result += item.purchasePrice ?? 0
}
```

## Coordination Rules
1. **RESOLVE** InsuranceTestScenarios duplicate with clear decision
2. **COORDINATE** with Agent-4 on mock service patterns
3. **DOCUMENT** which InsuranceTestScenarios to keep
4. **PRESERVE** error recovery test scenarios
5. **USE** Money type consistently for financial values

## Success Criteria
- [ ] Duplicate InsuranceTestScenarios resolved
- [ ] All mock services conform to protocols
- [ ] All Receipt constructors use Money type
- [ ] All Item constructors simplified
- [ ] Room constructors fixed
- [ ] NetworkError cases corrected
- [ ] currentValue references removed
- [ ] Error recovery logic preserved

## Testing Your Changes
```bash
# Test your files
swift build --target NestoryTests 2>&1 | grep "ErrorRecoveryTests.swift"
swift build --target NestoryTests 2>&1 | grep "InsuranceWorkflowIntegrationTests.swift"
swift build --target NestoryTests 2>&1 | grep "InsuranceTestScenarios.swift"
```

## Important Notes
- Error recovery tests are critical for app resilience
- Choose ONE InsuranceTestScenarios and delete the other
- Mock services may need significant refactoring for get-only properties
- Document any error scenarios that can't be tested due to API changes
- Ensure Money type is used consistently for all monetary values