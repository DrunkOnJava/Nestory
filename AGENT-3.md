# AGENT-3: Search Feature Specialist

## Mission
You own the ENTIRE SearchFeatureTests.swift file. This is the most error-prone file with 60+ compilation errors related to action mismatches, constructor issues, and API changes.

## Critical Context
- **SearchAction enum location**: `/Users/griffin/Projects/Nestory/Features/Search/Components/Actions/SearchActions.swift`
- **SearchFilters location**: `/Users/griffin/Projects/Nestory/Foundation/Models/SearchFilters.swift`
- **SearchHistoryItem**: Requires `filters: SearchFilters` parameter (not timestamp)
- **Many actions have been renamed or removed**

## Your Assigned File
1. `/Users/griffin/Projects/Nestory/NestoryTests/Features/SearchFeatureTests.swift` (COMPLETE OWNERSHIP)

## Specific Errors to Fix (60+ total)

### Action Mismatches:
```
Line 206: Type has no member 'clearAllFilters' -> Use 'clearFilters'
Line 240: Type has no member 'sortBy' -> Use 'sortOptionChanged'
Line 250: Type has no member 'sortBy' -> Use 'sortOptionChanged'
Line 276: Type has no member 'searchAddedToHistory' -> Remove, history is automatic
Line 297: Type has no member 'loadSearchHistory' -> Use 'showHistory'
Line 302: Type has no member 'searchFromHistory' -> Use 'selectHistoryItem'
Line 317: Type has no member 'loadSearchHistory' -> Use 'showHistory'
Line 327: Type has no member 'clearSearchHistory' -> Use 'clearHistory'
Line 353: Type has no member 'saveSearch' -> Use 'saveCurrentSearch'
Line 379: Type has no member 'loadSavedSearch' -> Use saved search differently
Line 410: Type has no member 'performAdvancedSearch' -> Use 'performSearch'
Line 494-516: Sheet actions don't exist -> Use show/hide versions
Line 530: Type has no member 'selectItem' -> Use 'itemTapped'
Line 536: Type has no member 'dismissItemDetail' -> Use 'hideItemDetail'
```

### Constructor Issues:
```
Lines 163-164: No exact matches for .min/.max on ClosedRange<Double>
Line 277-293: SearchHistoryItem constructor incorrect
Line 319-320: SearchHistoryItem constructor incorrect
Line 397: Cannot find 'AdvancedSearchQuery'
Line 403: Cannot find 'DateRange'
Line 727, 755, 776: SavedSearch init issues
```

### SearchFilters Issues:
```
Line 422: SearchFilters has no member 'brand'
Line 423: SearchFilters has no member 'modelNumber'
Line 424: SearchFilters has no member 'tags'
Line 657: SearchFilters has no member 'matches'
```

### Other Issues:
```
Line 438: Cannot convert SearchError types
Line 468-470: searchFailed with contextual type issues
Line 474: alert action issues
Line 597: MockInventoryService doesn't conform to protocol
Line 604: Call to main actor-isolated method
Line 638: Item has no member 'model'
Line 647: async/await issues
```

## Complete Pattern Fixes

### Pattern 1: Fix All Action Names
```swift
// OLD -> NEW
clearAllFilters -> clearFilters
sortBy -> sortOptionChanged
loadSearchHistory -> showHistory
searchFromHistory -> selectHistoryItem
clearSearchHistory -> clearHistory
saveSearch -> saveCurrentSearch
performAdvancedSearch -> performSearch
showFiltersSheet -> showFilters
dismissFiltersSheet -> hideFilters
showAdvancedSearchSheet -> showAdvancedSearch
dismissAdvancedSearchSheet -> hideAdvancedSearch
showHistorySheet -> showHistory
dismissHistorySheet -> hideHistory
selectItem -> itemTapped
dismissItemDetail -> hideItemDetail
```

### Pattern 2: Fix SearchHistoryItem Constructor
**OLD:**
```swift
SearchHistoryItem(query: "test", timestamp: Date(), resultCount: 5)
```
**NEW:**
```swift
SearchHistoryItem(query: "test", filters: SearchFilters(), resultCount: 5)
```

### Pattern 3: Fix Price Comparisons
**OLD:**
```swift
priceRange.min
priceRange.max
```
**NEW:**
```swift
priceRange.lowerBound
priceRange.upperBound
```

### Pattern 4: Fix SavedSearch
**OLD:**
```swift
SavedSearch()
```
**NEW:**
```swift
SavedSearch(
    name: "Test",
    query: "query",
    filters: SearchFilters(),
    createdAt: Date()
)
```

### Pattern 5: Remove Non-Existent Filter Properties
**REMOVE REFERENCES TO:**
- SearchFilters.brand
- SearchFilters.modelNumber
- SearchFilters.tags
- SearchFilters.matches

### Pattern 6: Fix Mock Service
**ADD TO MockInventoryService:**
```swift
func fetchRooms() async throws -> [Room] { [] }
func exportInventory(format: ExportFormat) async throws -> Data { Data() }
```

### Pattern 7: Add @MainActor
**ADD TO TEST CLASS:**
```swift
@MainActor
final class SearchFeatureTests: XCTestCase {
```

## Coordination Rules
1. **YOU OWN** the entire SearchFeatureTests.swift file
2. **DO NOT** modify any other files
3. **DEFINE** local ExportFormat enum if needed
4. **USE** proper async/await patterns
5. **REMOVE** references to non-existent properties

## Success Criteria
- [ ] All 60+ errors in SearchFeatureTests.swift resolved
- [ ] All action names updated
- [ ] All constructors fixed
- [ ] Mock service conforms to protocol
- [ ] No references to non-existent properties
- [ ] File compiles without errors

## Testing Your Changes
```bash
# Test only your file
swift build --target NestoryTests 2>&1 | grep "SearchFeatureTests.swift" | head -20
```

## Important Notes
- This is the most complex file with the most errors
- Many actions have been renamed, not removed
- SearchHistoryItem uses filters, not timestamp
- AdvancedSearchQuery doesn't exist - use regular search
- Be thorough - this file affects search functionality testing