# SwiftLint Configuration Guide

## Overview
This document explains the linting strategy for the Nestory project and recent fixes applied to the SwiftLint configuration.

## Major Issues Fixed (August 2025)

### 1. Layer Header Rule Bug (20,000+ false violations)
**Problem**: The `layer_header_required` custom rule was reporting a violation for EVERY LINE in files missing the header, not just once per file. This resulted in 20,000+ violations for a small codebase.

**Root Cause**: The regex `'^(?!//\s*Layer:)'` matched every line that didn't start with `// Layer:`, and SwiftLint custom rules don't support "once per file" reporting.

**Solution**: Removed the rule entirely. Layer headers should be enforced through:
- Code review
- A separate validation script
- Project templates

### 2. Overly Strict Rules
**Changes Made**:
- Line length: 100→120 warning, 120→150 error (was too restrictive for SwiftUI)
- Force unwrapping: error→warning (pragmatic during development)
- TODO must reference ADR: error→warning (too strict for early development)
- Disabled `missing_docs` by default (too noisy, enable for releases)
- Added more identifier name exclusions (dx, dy, pi, e, etc.)
- Increased nesting limits for SwiftUI (type: 2→3, function: 3→4)
- Increased cyclomatic complexity limits (10→15 warning, 20→25 error)

### 3. Missing Exclusions
**Added to excluded paths**:
- `build` directory
- `**/.build` (recursive)
- `**/DerivedData` (recursive)
- `.swiftpm`
- `Package.resolved`
- `*.xcodeproj`
- `*.xcworkspace`

## Current Violation Summary (546 total)

### High Priority (Errors)
- `force_cast` (1) - Avoid `as!`
- `no_force_cast_in_production` (1) - Custom rule for force casting

### Medium Priority (Common Issues)
- `switch_case_on_newline` (129) - Style preference
- `accessibility_label_for_image` (85) - Accessibility
- `swiftui_body_length` (83) - Consider refactoring large views
- `trailing_comma` (55) - Style consistency
- `force_unwrapping` (23) - Use optional binding
- `force_try` (15) - Use do-catch

### Low Priority (Style)
- `multiple_closures_with_trailing_closure` (35)
- `opening_brace` (29)
- `line_length` (20)
- `identifier_name` (11)
- `no_print_statements` (10) - Use logger instead

## Recommended Actions

### Immediate
1. Fix force casts and force unwrapping in production code
2. Add accessibility labels to images
3. Replace print statements with proper logging

### Short Term
1. Refactor large SwiftUI body implementations (83 violations)
2. Fix switch case formatting (129 violations)
3. Remove trailing commas for consistency

### Long Term
1. Create a separate architecture validation tool for layer headers
2. Enable `missing_docs` for public APIs before 1.0 release
3. Consider stricter rules as codebase matures

## Running Linting

```bash
# Check violations
swiftlint lint

# Auto-fix what's possible
swiftlint lint --fix

# Check specific directory
swiftlint lint App-Main/

# Generate HTML report
swiftlint lint --reporter html > lint-report.html
```

## Custom Rules

### Still Active
- `todo_must_reference_adr` - TODOs should reference Architecture Decision Records
- `no_print_statements` - Use proper logging
- `no_force_cast_in_production` - Avoid crashes
- `swiftui_body_length` - Keep views manageable

### Removed
- `layer_header_required` - Flawed implementation, use code review instead

## Pre-commit Hook

The pre-commit hook runs SwiftLint but currently has issues with:
1. SwiftFormat causing indentation problems in `#if DEBUG` blocks
2. Too many violations blocking commits

Consider:
- Making pre-commit hook advisory only (warnings not blocking)
- Running formatter and linter separately
- Using `--no-verify` for urgent commits

## Best Practices

1. **Fix errors immediately** - They can cause crashes
2. **Address warnings gradually** - Don't let them accumulate
3. **Configure per-directory** - Tests might have different rules
4. **Review rules quarterly** - Adjust as team/project grows
5. **Document exemptions** - Use `// swiftlint:disable` sparingly with explanations

## Future Improvements

1. **Architecture Validation Script**
   ```bash
   # Check for layer headers
   find . -name "*.swift" -exec grep -L "// Layer:" {} \;
   ```

2. **Gradual Rule Tightening**
   - Start with warnings
   - Move to errors after fixing
   - Add new opt-in rules gradually

3. **Team Agreement**
   - Review rules with team
   - Document style decisions
   - Update as Swift/SwiftUI evolves