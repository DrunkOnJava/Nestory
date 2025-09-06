# AGENT-1: Room Model Specialist

## Mission
You are responsible for fixing ALL Room-related compilation errors in the test suite. The Room model has specific constructor requirements that differ from what the tests expect.

## Critical Context
- **Room Model Location**: `/Users/griffin/Projects/Nestory/Foundation/Models/Room.swift`
- **Room Constructor**: `init(name: String, icon: String = "door.left.hand.open", roomDescription: String? = nil, floor: String? = nil)`
- **Room DOES have all properties**: The model has icon, roomDescription, floor - but tests show errors
- **Issue**: Likely a SwiftData @Model or PersistentModel conformance issue in test context

## Your Assigned Files
1. `/Users/griffin/Projects/Nestory/NestoryTests/Unit/Models/RoomModelTests.swift`
2. `/Users/griffin/Projects/Nestory/NestoryTests/Integration/UserJourneyTests.swift` (Room-related sections only)
3. `/Users/griffin/Projects/Nestory/NestoryTests/Performance/UIResponsivenessTests.swift` (Room sections)

## Specific Errors to Fix

### RoomModelTests.swift (70+ errors):
```
Line 44: Value of type 'Room' has no member 'icon'
Line 45: Value of type 'Room' has no member 'roomDescription' 
Line 46: Value of type 'Room' has no member 'floor'
Line 50: Extra arguments at positions #2, #3, #4 in call
Lines 90-129: Multiple property access errors
Line 136: Type 'Room' has no member 'createDefaultRooms'
Line 244: Instance method 'insert' requires that 'Room' conform to 'PersistentModel'
Lines 267-287: Extra arguments in Room constructor calls
Lines 324-327: Extra arguments in Room constructor calls
Lines 554-593: Multiple Room constructor errors
Lines 617-624: Multiple Room constructor errors
```

### UserJourneyTests.swift:
```
Line 26: Cannot convert value of type 'Room.Type' to expected element type
```

### UIResponsivenessTests.swift:
```
Line 577: Type 'Room' has no member 'createDefaultRooms'
```

## Patterns to Fix

### Pattern 1: Room Property Access
**SEARCH FOR:**
```swift
room.icon
room.roomDescription  
room.floor
```
**ANALYSIS NEEDED:** These properties exist in the model but tests can't see them. May need type casting or different approach.

### Pattern 2: Room Constructor Calls
**CURRENT FAILING PATTERN:**
```swift
Room(name: "Living Room", icon: "sofa.fill", floor: "Ground Floor")
```
**FIX TO:**
```swift
Room(name: "Living Room", icon: "sofa.fill", roomDescription: nil, floor: "Ground Floor")
```

### Pattern 3: createDefaultRooms Static Method
**SEARCH FOR:**
```swift
Room.createDefaultRooms()
```
**CHECK:** Verify if this method exists in Room model, if not create mock data differently

### Pattern 4: PersistentModel Conformance
**ERROR:** Instance method 'insert' requires that 'Room' conform to 'PersistentModel'
**INVESTIGATE:** Room has @Model attribute which should provide PersistentModel conformance
**POTENTIAL FIX:** May need to import SwiftData in test files

## Coordination Rules
1. **DO NOT MODIFY** Room.swift model file - it's correct
2. **DO NOT TOUCH** TestDataFactory.swift - that's Agent-10's responsibility  
3. **ONLY FIX** Room-related errors in your assigned files
4. **COMMUNICATE** if you discover Room model insights that affect other agents
5. **USE** `Nestory.Category` if you encounter Category ambiguity

## Success Criteria
- [ ] All Room property access errors resolved
- [ ] All Room constructor calls fixed
- [ ] PersistentModel conformance issues resolved
- [ ] createDefaultRooms references handled
- [ ] No new errors introduced
- [ ] Files compile without Room-related errors

## Testing Your Changes
```bash
# Test only your specific files
swift build --target NestoryTests 2>&1 | grep "RoomModelTests.swift"
swift build --target NestoryTests 2>&1 | grep "UserJourneyTests.swift" 
swift build --target NestoryTests 2>&1 | grep "UIResponsivenessTests.swift"
```

## Important Notes
- The Room model HAS all the properties (icon, roomDescription, floor)
- The constructor accepts all 4 parameters
- The issue is likely related to SwiftData's @Model in test context
- Consider adding necessary imports or type annotations
- Document any discoveries about why properties aren't visible in tests