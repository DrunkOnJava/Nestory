# AGENT-8: Unit Tests Specialist

## Mission
You are responsible for fixing ALL unit test files focusing on Category ambiguity, @MainActor annotations for TestDataFactory calls, and model property references.

## Critical Context
- **Category Ambiguity**: Always use `Nestory.Category` to disambiguate
- **TestDataFactory**: All methods are @MainActor - test methods need annotation
- **Room**: Not a PersistentModel, needs special handling
- **Item properties removed**: estimatedValue, currentValue, model, isArchived

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/Unit/Models/CategoryModelTests.swift`
2. `/Users/griffin/Projects/Nestory/NestoryTests/Unit/Models/CloudKitSyncTests.swift`
3. `/Users/griffin/Projects/Nestory/NestoryTests/Unit/Models/DataMigrationTests.swift`
4. `/Users/griffin/Projects/Nestory/NestoryTests/Unit/Models/WarrantyModelTests.swift`

## Specific Errors to Fix

### CategoryModelTests.swift:
```
Lines 209, 213: @MainActor needed for TestDataFactory calls
Line 450: Generic parameter 'T' could not be inferred
Line 450: Category is ambiguous for type lookup
```

### CloudKitSyncTests.swift:
```
Line 26: Cannot convert Room.Type to PersistentModel
Line 40: @MainActor needed for TestDataFactory call
Line 107: Room has no member 'createDefaultRooms'
Lines 147: Category ambiguity in fetch
Lines 190, 249, 324, 363: @MainActor needed for TestDataFactory
Line 401: @MainActor needed for kitchenFloodingIncident
Line 404: InsuranceTestScenarioData has no member 'damagedItems'
Line 414: No exact matches for initializer
Lines 454, 479, 535: @MainActor needed for TestDataFactory
```

### DataMigrationTests.swift:
```
Lines 74, 97, 262, 463: Cannot convert Room.Type to PersistentModel
Lines 202-204: Extra 'color' argument in Category constructor
Line 233-234: Category ambiguity in fetch
Lines 273-274: Extra arguments in Room constructor
Lines 280, 285: item.estimatedValue doesn't exist
Line 299: Room doesn't conform to PersistentModel
Line 432: Extra 'color' argument
Line 445: Category ambiguity
Line 477-478: Category/Room constructor issues
Line 518: Extra 'estimatedValue' argument
Lines 538, 547, 556, 564, 580: item.estimatedValue references
Lines 584-585: Optional string unwrapping issues
```

### WarrantyModelTests.swift:
```
Line 536: @MainActor needed for TestDataFactory call
```

## Patterns to Fix

### Pattern 1: Fix Category Ambiguity
**ALWAYS USE:**
```swift
// In fetch
let categories = try context.fetch(FetchDescriptor<Nestory.Category>())

// In type declarations
var category: Nestory.Category?

// In sort descriptors
SortDescriptor<Nestory.Category>(\.name)
```

### Pattern 2: Add @MainActor Annotations
**FOR ANY TEST USING TestDataFactory:**
```swift
@MainActor
func testSomething() async {
    let item = TestDataFactory.createHighValueItem()
    // ...
}
```

### Pattern 3: Remove Room.Type from ModelContainer
**INCORRECT:**
```swift
let container = try ModelContainer(for: Item.self, Category.self, Room.self)
```
**CORRECT:**
```swift
let container = try ModelContainer(for: Item.self, Category.self)
// Remove Room.Type completely
```

### Pattern 4: Fix Category Constructor
**INCORRECT:**
```swift
Category(name: "Electronics", icon: "tv", color: "#007AFF")
```
**CORRECT:**
```swift
Nestory.Category(name: "Electronics", icon: "tv", colorHex: "#007AFF")
```

### Pattern 5: Fix Room Constructor
**INCORRECT:**
```swift
Room(name: "Living Room", icon: "sofa", floor: "Ground")
```
**CORRECT:**
```swift
Room(name: "Living Room")
// Set other properties separately if available
```

### Pattern 6: Replace estimatedValue
**REPLACE ALL:**
```swift
item.estimatedValue = Decimal(500)
XCTAssertEqual(item.estimatedValue, 500)
```
**WITH:**
```swift
// Remove or use purchasePrice
item.purchasePrice = Decimal(500)
XCTAssertEqual(item.purchasePrice, Decimal(500))
```

### Pattern 7: Replace createDefaultRooms
**REPLACE:**
```swift
let rooms = Room.createDefaultRooms()
```
**WITH:**
```swift
let rooms = TestDataFactory.createStandardRooms()
```

### Pattern 8: Fix InsuranceTestScenarioData
**IF 'damagedItems' doesn't exist:**
```swift
// Check actual properties of InsuranceTestScenarioData
// May need to use 'items' or similar property
```

### Pattern 9: Fix Optional String Checks
**INCORRECT:**
```swift
someString.isEmpty  // When someString is optional
```
**CORRECT:**
```swift
someString?.isEmpty == true
// or
!(someString?.isEmpty ?? true)
```

## Coordination Rules
1. **DO NOT MODIFY** model files (Item.swift, Category.swift, Room.swift)
2. **ALWAYS** use Nestory.Category for disambiguation
3. **COORDINATE** with Agent-10 on TestDataFactory usage
4. **DOCUMENT** any removed test scenarios due to model changes
5. **PRESERVE** test coverage for critical functionality

## Success Criteria
- [ ] All Category ambiguity resolved with Nestory.Category
- [ ] All @MainActor annotations added where needed
- [ ] All Room.Type removed from ModelContainer calls
- [ ] All estimatedValue references removed/replaced
- [ ] All constructor calls updated
- [ ] No compilation errors in assigned files

## Testing Your Changes
```bash
# Test each file
swift build --target NestoryTests 2>&1 | grep "CategoryModelTests.swift"
swift build --target NestoryTests 2>&1 | grep "CloudKitSyncTests.swift"
swift build --target NestoryTests 2>&1 | grep "DataMigrationTests.swift"
swift build --target NestoryTests 2>&1 | grep "WarrantyModelTests.swift"
```

## Important Notes
- CloudKit sync tests are critical for data integrity
- Data migration tests ensure backward compatibility
- If a test becomes impossible due to model changes, comment with explanation
- Always prefer Nestory.Category over just Category
- Document any significant test logic changes