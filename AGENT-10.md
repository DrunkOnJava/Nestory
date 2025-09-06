# AGENT-10: TestDataFactory & Scenarios Specialist

## Mission
You OWN TestDataFactory.swift and are responsible for fixing ALL factory methods, removing duplicate InsuranceTestScenarios, and ensuring all test data generation works correctly.

## Critical Context
- **TestDataFactory**: Central source of truth for ALL test data
- **Room constructor**: Now only accepts name parameter
- **Receipt**: Uses Money type with backingData pattern
- **Warranty**: Requires startDate parameter
- **Item properties removed**: currentValue, estimatedValue, model, isArchived
- **ALL methods are @MainActor**: This is correct, don't change it

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/TestDataFactory.swift` (COMPLETE OWNERSHIP)
2. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/InsuranceTestScenarios.swift`
3. `/Users/griffin/Projects/Nestory/NestoryTests/Features/DamageAssessmentFeatureTests.swift`

## Specific Errors to Fix

### TestDataFactory.swift:
```
Line 116: Room constructor - Extra arguments at positions #2, #3, #4
Lines 126-132: Room constructors - Extra arguments and nil context issues
Line 248: Receipt - Missing 'backingData' parameter
Line 263: Warranty - Missing 'backingData' parameter
```

### InsuranceTestScenarios.swift:
```
Line 12: Duplicate definition (if keeping this file)
Multiple lines: References to item.currentValue (remove/replace)
Line 298: Missing 'into:' label in reduce
Line 359: reduce type mismatch for Decimal
Line 382: Filter trailing closure issue
```

### DamageAssessmentFeatureTests.swift:
```
Line 29: Async TestDataFactory call needs await
Line 33: Async initializer needs await
Lines 47-51: Main actor-isolated properties in non-isolated context
Line 59: Main actor-isolated initializer call
```

## Patterns to Fix

### Pattern 1: Fix Room Constructor in TestDataFactory
**LINE 116 - INCORRECT:**
```swift
return Room(
    name: name,
    icon: icon,
    roomDescription: "Primary \(name.lowercased()) area",
    floor: floor
)
```
**CORRECT:**
```swift
let room = Room(name: name)
// Note: icon, roomDescription, floor may not be settable
// Document this limitation
return room
```

**LINES 126-132 - INCORRECT:**
```swift
Room(name: "Living Room", icon: "sofa.fill", roomDescription: nil, floor: "Ground Floor")
```
**CORRECT:**
```swift
Room(name: "Living Room")
// Properties lost: icon, roomDescription, floor
// Consider storing these as a separate lookup table if needed
```

### Pattern 2: Fix Receipt Constructor
**LINE 248 - NEEDS FIX:**
```swift
static func createReceiptTestData() -> Receipt {
    let total = Money(minorUnits: 249999, currencyCode: "USD")
    return Receipt(
        vendor: "Apple Store",
        total: total,
        purchaseDate: Date()
    )
    // Set other properties after creation
}
```

### Pattern 3: Fix Warranty Constructor
**LINE 263 - NEEDS FIX:**
```swift
static func createWarrantyTestData() -> Warranty {
    return Warranty(
        provider: "Apple Inc.",
        type: .extended,
        startDate: Date(),
        expiresAt: Calendar.current.date(byAdding: .year, value: 3, to: Date()) ?? Date()
    )
    // Set other properties after creation
}
```

### Pattern 4: Remove currentValue/estimatedValue
**EVERYWHERE IN TestDataFactory:**
```swift
// Remove lines like:
// item.currentValue = Decimal(X)
// item.estimatedValue = Decimal(Y)

// Keep only:
item.purchasePrice = Decimal(X)
```

### Pattern 5: Handle InsuranceTestScenarios Duplicate
**DECISION NEEDED:**
1. Keep InsuranceTestScenarios.swift as the source of truth
2. Remove duplicate from InsuranceWorkflowIntegrationTests.swift
3. Import/reference properly in all test files

### Pattern 6: Fix DamageAssessmentFeatureTests
**ADD @MainActor:**
```swift
@MainActor
final class DamageAssessmentFeatureTests: XCTestCase {
    // This allows calling TestDataFactory methods
}
```

### Pattern 7: Create Room Metadata Storage (Optional)
**IF ROOM PROPERTIES ARE NEEDED FOR TESTS:**
```swift
// Add to TestDataFactory
static let roomMetadata: [String: (icon: String, description: String?, floor: String?)] = [
    "Living Room": ("sofa.fill", nil, "Ground Floor"),
    "Kitchen": ("fork.knife", nil, "Ground Floor"),
    // etc.
]

static func getRoomMetadata(for roomName: String) -> (icon: String, description: String?, floor: String?) {
    return roomMetadata[roomName] ?? ("door.left.hand.open", nil, nil)
}
```

## Coordination Rules
1. **YOU OWN** TestDataFactory.swift completely
2. **ALL OTHER AGENTS** depend on your TestDataFactory fixes
3. **COMMUNICATE** any API changes to factory methods
4. **MAINTAIN** @MainActor on all methods - it's correct
5. **DOCUMENT** any lost functionality due to model changes

## Success Criteria
- [ ] All Room constructors fixed (only name parameter)
- [ ] Receipt constructor uses correct signature
- [ ] Warranty constructor includes startDate
- [ ] All currentValue/estimatedValue references removed
- [ ] InsuranceTestScenarios duplicate resolved
- [ ] DamageAssessmentFeatureTests has @MainActor
- [ ] TestDataFactory compiles without errors
- [ ] Factory methods return valid test data

## Testing Your Changes
```bash
# Test TestDataFactory compilation
swift build --target NestoryTests 2>&1 | grep "TestDataFactory.swift"

# Verify no duplicate symbols
swift build --target NestoryTests 2>&1 | grep "InsuranceTestScenarios"
```

## Important Notes
- TestDataFactory is THE source of truth for test data
- Other agents depend on your factory methods working correctly
- Document any functionality lost due to Room model changes
- Keep @MainActor on all methods - tests will add it to their methods
- Consider creating metadata lookups for lost Room properties if needed

## Communication to Other Agents
After fixing TestDataFactory, document:
1. Any changed method signatures
2. Any removed methods
3. Alternative approaches for lost functionality
4. Confirm Room only accepts name parameter