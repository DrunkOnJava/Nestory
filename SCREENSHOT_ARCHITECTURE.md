# Nestory Screenshot Catalog Architecture

## Overview

This document describes the decomposed, deterministic screenshot cataloging system built for Nestory. Instead of a monolithic "tap and hope" crawler, we've created a layered system of stable primitives that work together reliably.

## The Problem We Solved

Traditional UI crawlers fail because they:
- **Assume discoverability** - Apps don't publish navigation graphs
- **Ignore statefulness** - Async loading and data dependencies break tests
- **Mis-handle interruptions** - Permissions and alerts derail execution
- **Rely on heuristics** - "Tap the first button" leads to chaos
- **Underestimate complexity** - Infinite scrolls and carousels explode coverage
- **Lack extraction discipline** - Screenshots aren't consistently captured

## Our Solution: Decomposed Architecture

### 1. Screen Registry (`Foundation/Core/ScreenRegistry.swift`)
```swift
enum ScreenRoute: String, CaseIterable {
    case inventory, search, capture, analytics, settings
    // ... 40+ screens enumerated
}
```
- **Purpose**: Enumerable list of all navigable screens
- **Benefits**: No guessing, finite set of destinations
- **Features**: Hierarchy, metadata, test fixtures

### 2. UI Test Mode (`Foundation/Core/UITestMode.swift`)
```swift
struct UITestMode {
    static var isEnabled: Bool
    static var disableAnimations: Bool
    static var autoAcceptPermissions: Bool
    static var useTestFixtures: Bool
}
```
- **Purpose**: Deterministic test environment
- **Benefits**: Consistent state, no flakiness
- **Features**: Time freezing, permission auto-accept, test data

### 3. Navigation Router (`App-Main/NavigationRouter.swift`)
```swift
struct NavigationRouter {
    func navigate(to route: ScreenRoute) async
}
```
- **Purpose**: Deterministic navigation to any screen
- **Benefits**: Direct access, no wandering
- **Features**: TCA integration, async-safe

### 4. Interaction Sampler (`NestoryUITests/Framework/InteractionSampler.swift`)
```swift
struct InteractionSampler {
    func sampleCurrentScreen(screenName: String) -> [ScreenshotCapture]
}
```
- **Purpose**: Bounded interaction with infinite states
- **Benefits**: No infinite loops, predictable coverage
- **Features**: Configurable limits, sampling strategies

### 5. Permission Handler (`Scripts/setup-simulator-permissions.sh`)
```bash
xcrun simctl privacy "$DEVICE_ID" grant camera "$BUNDLE_ID"
```
- **Purpose**: Pre-grant all permissions
- **Benefits**: No interruption dialogs
- **Features**: All iOS permissions, status bar config

### 6. Test Implementation (`NestoryUITests/Tests/DeterministicScreenshotTest.swift`)
```swift
func testSingleRouteSnapshot() async
func testMultiRouteSnapshots() async
func testCompleteScreenCatalog() async
```
- **Purpose**: Structured test execution
- **Benefits**: Incremental validation
- **Features**: Single route → Multi route → Full catalog

### 7. Extraction Pipeline (`Scripts/extract-screenshots.py`)
```python
class ScreenshotExtractor:
    def extract() -> List[Path]
    def remove_duplicates() -> int
    def generate_index() -> Path
```
- **Purpose**: Process test artifacts
- **Benefits**: Clean, organized output
- **Features**: Deduplication, HTML generation, JSON manifest

### 8. Orchestration (`Scripts/run-screenshot-catalog.sh`)
```bash
# Complete pipeline
1. Setup simulator permissions
2. Build application
3. Run UI tests
4. Extract screenshots
5. Remove duplicates
6. Generate HTML catalog
```
- **Purpose**: End-to-end automation
- **Benefits**: One command execution
- **Features**: Progress tracking, error handling, reporting

## File Structure

```
/Users/griffin/Projects/Nestory/
├── Foundation/Core/
│   ├── ScreenRegistry.swift         # Screen enumeration
│   └── UITestMode.swift            # Test configuration
├── App-Main/
│   └── NavigationRouter.swift      # Deterministic navigation
├── NestoryUITests/
│   ├── Framework/
│   │   ├── InteractionSampler.swift # Bounded interactions
│   │   ├── ScreenshotHelper.swift   # Screenshot utilities
│   │   └── XCUIElement+Extensions.swift
│   ├── Base/
│   │   └── NestoryUITestBase.swift # Base test class
│   └── Tests/
│       └── DeterministicScreenshotTest.swift
└── Scripts/
    ├── setup-simulator-permissions.sh
    ├── extract-screenshots.py
    └── run-screenshot-catalog.sh
```

## Usage

### Quick Start
```bash
# Run complete catalog generation
bash Scripts/run-screenshot-catalog.sh

# Output will be in:
# screenshot-catalog-YYYYMMDD_HHMMSS/
#   ├── index.html           # Interactive catalog
#   ├── screenshots/         # PNG files
#   ├── logs/               # Build/test logs
#   └── test-results.xcresult
```

### Customization

#### Test Only Specific Routes
```swift
let routes = ["inventory", "settings", "analytics"]
for route in routes {
    await captureRoute(route)
}
```

#### Change Sampling Strategy
```swift
let sampler = InteractionSampler(
    app: app,
    config: SamplingStrategy.minimal.config
)
```

#### Add New Screens
1. Add to `ScreenRegistry.swift`
2. Update `NavigationRouter.swift` if needed
3. Run catalog generation

## Benefits of This Architecture

### 1. **Reliability**
- No random failures from async timing
- Permissions pre-granted
- Deterministic navigation

### 2. **Maintainability**
- Each component has single responsibility
- Easy to debug individual layers
- Clear extension points

### 3. **Scalability**
- Add new screens to registry
- Sampling prevents infinite loops
- Parallel test execution possible

### 4. **Reusability**
- Screen registry for manual QA
- Test mode for all UI tests
- Navigation router for integration tests

### 5. **Observability**
- HTML catalog for visual inspection
- JSON manifest for programmatic access
- Detailed logs at each stage

## Future Enhancements

### Matrix Testing
```swift
let configurations = [
    (appearance: .light, textSize: .normal, locale: "en"),
    (appearance: .dark, textSize: .large, locale: "es"),
    (appearance: .light, textSize: .small, locale: "ja")
]
```

### Visual Regression
```python
def compare_with_baseline(current, baseline):
    # Pixel-by-pixel comparison
    # Perceptual hash comparison
    # Generate diff images
```

### CI/CD Integration
```yaml
- name: Generate Screenshot Catalog
  run: bash Scripts/run-screenshot-catalog.sh
- name: Upload Artifacts
  uses: actions/upload-artifact@v3
  with:
    name: screenshot-catalog
    path: screenshot-catalog-*/
```

## Lessons Learned

1. **Decompose complexity** - Big monolithic goals fracture into interdependent layers
2. **Build stable primitives** - Each layer should work independently
3. **Test incrementally** - Single route → Multiple routes → Full catalog
4. **Handle infinite states** - Use sampling budgets, not exhaustive exploration
5. **Automate everything** - From permissions to HTML generation

## Conclusion

By decomposing the screenshot cataloging problem into stable, testable primitives, we've created a robust system that:
- Works reliably without flakiness
- Scales to handle any number of screens
- Provides reusable components for other testing needs
- Generates beautiful, interactive documentation

This architecture demonstrates that complex UI testing challenges can be solved systematically through proper decomposition and layered design.