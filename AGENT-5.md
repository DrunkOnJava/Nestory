# AGENT-5: Performance Tests Specialist

## Mission
You are responsible for fixing ALL performance test files, focusing on @MainActor annotations, Item property references, and TestDataFactory method calls.

## Critical Context
- **TestDataFactory methods**: All are @MainActor, so test methods using them need the annotation
- **Item properties removed**: estimatedValue, currentValue, model, isArchived, photoCount
- **Category constructor**: Changed signature - now has only name, icon, colorHex
- **PersistentModel**: Room.Type cannot be directly used in ModelContainer arrays

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/Performance/PerformanceTests.swift`
2. `/Users/griffin/Projects/Nestory/NestoryTests/Performance/InsuranceReportPerformanceTests.swift`
3. `/Users/griffin/Projects/Nestory/NestoryTests/Performance/OCRPerformanceTests.swift`
4. `/Users/griffin/Projects/Nestory/NestoryTests/Performance/UIResponsivenessTests.swift`

## Specific Errors to Fix

### PerformanceTests.swift:
```
Line 22: Cannot convert Room.Type to PersistentModel array element
Line 28: Cannot convert Room.Type to PersistentModel type
```

### InsuranceReportPerformanceTests.swift:
```
Line 27: Cannot convert Room.Type to PersistentModel array element
Line 132: Argument order issue with ReportOptions
Lines 490-491: Extra 'color' argument in Category constructor
Lines 497, 506, 525, 546, 575, 594, 617, 639: @MainActor needed for TestDataFactory calls
Lines 499, 508, 527, 548, 577, 596, 619, 641: References to item.estimatedValue
Line 646: Reference to item.photoCount
Lines 656-663: Extra 'color' argument in Category constructors
```

### OCRPerformanceTests.swift:
```
Line 248: abs() doesn't work with Duration type
Line 248: Decimal has no member 'doubleValue'
Line 307: Cannot pass async function to synchronous parameter
```

### UIResponsivenessTests.swift:
```
Line 26: Cannot convert Room.Type to PersistentModel array element
Lines 72, 125, 196, 253, 461, 528: References to item.estimatedValue
Line 324: Missing 'into:' label in reduce call
Line 372: Extra 'color' argument in Category
Line 577: Room has no member 'createDefaultRooms'
Lines 565-569: Extra 'color' argument in Category constructors
Line 586: Reference to item.estimatedValue
```

## Patterns to Fix

### Pattern 1: Remove Room.Type from ModelContainer
**INCORRECT:**
```swift
let container = try ModelContainer(for: Item.self, Category.self, Room.self, ...)
```
**CORRECT:**
```swift
let container = try ModelContainer(for: Item.self, Category.self, ...)
// Note: Remove Room.Type completely from the array
```

### Pattern 2: Add @MainActor to Test Methods
**ADD TO ANY METHOD USING TestDataFactory:**
```swift
@MainActor
func testPerformanceScenario() async {
    let item = TestDataFactory.createCompleteItem()
    // ...
}
```

### Pattern 3: Fix Item Property References
**REMOVE ALL REFERENCES TO:**
```swift
item.estimatedValue  // Remove or use purchasePrice
item.currentValue    // Remove or use purchasePrice
item.model          // Use modelNumber instead
item.photoCount     // Remove completely
item.isArchived     // Remove completely
```

### Pattern 4: Fix Category Constructor
**INCORRECT:**
```swift
Category(name: "Electronics", icon: "tv", color: "#007AFF")
```
**CORRECT:**
```swift
Category(name: "Electronics", icon: "tv", colorHex: "#007AFF")
```

### Pattern 5: Fix Duration/Decimal Comparisons
**FOR OCRPerformanceTests.swift line 248:**
```swift
// If comparing extracted amount with expected:
let extractedAmount = Decimal(string: extractedText) ?? 0
let expectedAmount = Decimal(99.99)
let difference = abs(Double(truncating: extractedAmount as NSNumber) - Double(truncating: expectedAmount as NSNumber))
```

### Pattern 6: Fix Async Measure Block
**FOR OCRPerformanceTests.swift line 307:**
```swift
// If measure doesn't support async:
measure {
    let expectation = self.expectation(description: "OCR")
    Task {
        // async work here
        expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
}
```

### Pattern 7: Fix reduce with 'into:'
**INCORRECT:**
```swift
items.reduce(0) { $0 + ($1.purchasePrice ?? 0) }
```
**CORRECT:**
```swift
items.reduce(into: Decimal(0)) { $0 += ($1.purchasePrice ?? 0) }
```

### Pattern 8: Replace createDefaultRooms
**INSTEAD OF:**
```swift
let rooms = Room.createDefaultRooms()
```
**USE:**
```swift
let rooms = TestDataFactory.createStandardRooms()
```

## Coordination Rules
1. **DO NOT MODIFY** Room.swift or Item.swift models
2. **COORDINATE** with Agent-10 on TestDataFactory usage
3. **DOCUMENT** performance metrics that may change due to property removal
4. **PRESERVE** test intent while fixing compilation errors
5. **USE** purchasePrice as replacement for estimatedValue/currentValue

## Success Criteria
- [ ] All performance test files compile
- [ ] All @MainActor annotations added where needed
- [ ] All Item property references fixed
- [ ] All Category constructor calls updated
- [ ] ModelContainer Room.Type issues resolved
- [ ] OCR performance test async/measure issues fixed
- [ ] No references to removed properties

## Testing Your Changes
```bash
# Test each file individually
swift build --target NestoryTests 2>&1 | grep "PerformanceTests.swift"
swift build --target NestoryTests 2>&1 | grep "InsuranceReportPerformanceTests.swift"
swift build --target NestoryTests 2>&1 | grep "OCRPerformanceTests.swift"
swift build --target NestoryTests 2>&1 | grep "UIResponsivenessTests.swift"
```

## Important Notes
- Performance tests are critical - ensure timing logic remains intact
- When removing estimatedValue, consider if test needs adjustment for accuracy
- Some tests may measure operations that no longer exist - comment these out with explanation
- Document any significant changes to performance baselines
- If a test becomes irrelevant due to property removal, mark with // TODO: Review test relevance