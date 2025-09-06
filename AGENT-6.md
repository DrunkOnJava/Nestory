# AGENT-6: Integration Tests Part 1 Specialist

## Mission
You are responsible for fixing UserJourneyTests.swift and CrossPlatformTests.swift, focusing on Item/Room/Category issues, Warranty constructors, and ModelContainer problems.

## Critical Context
- **Room.Type**: Cannot be used in ModelContainer array - must be removed
- **Warranty constructor**: Now requires startDate parameter
- **Item constructor**: Only accepts name parameter initially
- **Category**: Use Nestory.Category for disambiguation
- **ItemCondition**: No longer has 'destroyed' case

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/UserJourneyTests.swift`
2. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/CrossPlatformTests.swift`

## Specific Errors to Fix

### UserJourneyTests.swift:
```
Line 26: Cannot convert Room.Type to PersistentModel array element
Line 56: Missing 'name' parameter in Item init
Line 76: Cannot infer contextual base for .excellent
Line 135: Cannot find 'Yes' in scope (typo issue)
Lines 340, 361, 503, 509: ItemCondition has no member 'destroyed'
Lines 413, 440, 491: Missing 'name' parameter in Item init
Lines 419, 496: Cannot infer contextual base for .excellent
```

### CrossPlatformTests.swift:
```
Line 27: Cannot convert Room.Type to PersistentModel array element
Line 99: Missing 'startDate' parameter in Warranty init
Line 100: Extra argument 'terms' in call
Line 113: Instance method 'insert' requires Room conform to PersistentModel
Line 127: Non-sendable Room type issue
Line 143-144: Category ambiguity and Room PersistentModel issues
Line 515: No exact matches for Data initializer
Line 601: NetworkError has no member 'connectionLost'
Line 638-639: Warranty constructor issues
Line 643: Room PersistentModel conformance
```

## Patterns to Fix

### Pattern 1: Remove Room.Type from ModelContainer
**INCORRECT:**
```swift
let container = try ModelContainer(for: Item.self, Category.self, Room.self, Warranty.self)
```
**CORRECT:**
```swift
let container = try ModelContainer(for: Item.self, Category.self, Warranty.self)
// Remove Room.Type completely
```

### Pattern 2: Fix Item Constructor
**INCORRECT:**
```swift
let item = Item()
```
**CORRECT:**
```swift
let item = Item(name: "Test Item")
```

### Pattern 3: Fix ItemCondition References
**INCORRECT:**
```swift
item.condition = .destroyed
```
**CORRECT:**
```swift
item.condition = "poor"  // or "damaged" - use string values
```

### Pattern 4: Fix Warranty Constructor
**INCORRECT:**
```swift
let warranty = Warranty(
    provider: "AppleCare",
    type: .extended,
    expiresAt: expiryDate,
    terms: "Full coverage"  // This parameter doesn't exist
)
```
**CORRECT:**
```swift
let warranty = Warranty(
    provider: "AppleCare",
    type: .extended,
    startDate: Date(),
    expiresAt: expiryDate
)
```

### Pattern 5: Fix Category Ambiguity
**ALWAYS USE:**
```swift
let categories = try context.fetch(FetchDescriptor<Nestory.Category>())
```

### Pattern 6: Fix Room Fetching
**SINCE Room isn't PersistentModel, you may need to:**
```swift
// Option A: Comment out Room-related persistence
// Option B: Store rooms as strings on Items
// Option C: Create a separate Room management system
```

### Pattern 7: Fix NetworkError
**REPLACE:**
```swift
NetworkError.connectionLost
```
**WITH:**
```swift
NetworkError.timeout  // or another valid case
```

### Pattern 8: Fix Data Initialization
**Line 515 - if creating Data from array:**
```swift
let data = Data([0x00, 0x01, 0x02])  // Make sure array is [UInt8]
```

### Pattern 9: Fix Condition Context
**When you see "Cannot infer contextual base":**
```swift
// Instead of: item.condition = .excellent
item.condition = "excellent"  // Use string directly
```

## Coordination Rules
1. **DO NOT MODIFY** model files (Item.swift, Room.swift, etc.)
2. **COORDINATE** with Agent-7 on shared integration test patterns
3. **DOCUMENT** any Room persistence workarounds you implement
4. **PRESERVE** test intent while fixing compilation
5. **USE** TestDataFactory methods where appropriate

## Success Criteria
- [ ] Both files compile without errors
- [ ] All ModelContainer initializations fixed
- [ ] All Item constructors updated
- [ ] All Warranty constructors fixed
- [ ] ItemCondition.destroyed references removed
- [ ] Category ambiguity resolved
- [ ] Room persistence issues addressed
- [ ] NetworkError cases corrected

## Testing Your Changes
```bash
# Test your files
swift build --target NestoryTests 2>&1 | grep "UserJourneyTests.swift"
swift build --target NestoryTests 2>&1 | grep "CrossPlatformTests.swift"
```

## Important Notes
- User journey tests are critical for app functionality validation
- If Room persistence is broken, document workaround clearly
- Some tests may need significant restructuring if Room isn't persistable
- Consider using Room as a simple string property on Item if needed
- Document any test scenarios that can't be preserved due to model changes