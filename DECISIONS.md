# Architecture Decision Records

This document tracks significant architectural decisions for the Nestory project.

## ADR-0001: Spec as Code & Guard Rails

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Need to enforce architecture without human review on every commit.

### Decision

Implement a "Spec as Code" system with automated guard rails:

1. **SPEC.json** - Machine-readable specification defining:
   - Architectural layers and boundaries
   - Allowed import relationships
   - Technology choices and constraints
   - Quality gates and SLO targets

2. **Automated Enforcement** via:
   - SwiftSyntax-based architecture tests
   - Pre-commit hooks for local verification
   - CI/CD workflows for continuous validation
   - Dev CLI tools for maintenance

3. **Hash-based Integrity** using SPEC.lock to detect unauthorized changes

### Consequences

**Positive:**
- Architecture violations caught at commit time
- Self-documenting architectural rules
- Consistent enforcement across team
- Clear boundaries prevent technical debt
- Automated verification reduces review burden

**Negative:**
- Additional build step overhead
- Learning curve for spec modification
- Requires discipline to maintain
- May slow down prototyping

**Mitigations:**
- Clear documentation and examples
- Fast verification tools (< 5 seconds locally)
- Emergency bypass with `--no-verify`
- Regular team training on the system

### Implementation

The guard rails are implemented through:
- `ArchitectureTests.swift` - SwiftSyntax-based import validation
- `nestoryctl` - CLI tool for verification and maintenance
- `install_hooks.sh` - Git hook installation
- GitHub Actions workflows for CI/CD

### References

- [Clean Architecture principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Architectural Fitness Functions](https://www.thoughtworks.com/insights/articles/fitness-function-driven-development)
- [SwiftSyntax documentation](https://github.com/apple/swift-syntax)

---

## Template for Future ADRs

```markdown
## ADR-XXXX: [Title]

**Date:** YYYY-MM-DD  
**Status:** [Proposed|Accepted|Deprecated|Superseded]  
**Context:** [Why this decision is needed]

### Decision
[What we decided to do]

### Consequences
**Positive:**
- [Benefits]

**Negative:**
- [Drawbacks]

**Mitigations:**
- [How to address drawbacks]

### Implementation
[How it will be implemented]

### References
- [Related links]
```

---

## ADR-0002: Swift 6 with Strict Concurrency

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Need to ensure thread safety and prevent data races in a complex inventory management app.

### Decision

Adopt Swift 6 with strict concurrency checking enabled. Use actors for shared mutable state and Sendable conformance throughout.

### Consequences

**Positive:**
- Compile-time safety for concurrent code
- Better performance with structured concurrency
- Future-proof for Swift evolution
- Prevents data races at compile time

**Negative:**
- Steeper learning curve for team
- Some third-party libraries may not be compatible
- More verbose code in some cases

**Mitigations:**
- Team training on Swift concurrency
- Gradual migration path for existing code
- Maintain compatibility wrappers where needed

### Implementation

- Enable strict concurrency checking in build settings
- Use `@MainActor` for UI-related code
- Implement service layer as actors
- Ensure all types conform to Sendable

---

## ADR-0003: SwiftData for Persistence

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Need a modern persistence layer that integrates well with SwiftUI and supports CloudKit sync.

### Decision

Use SwiftData as the primary persistence framework with CloudKit for sync.

### Consequences

**Positive:**
- Native Swift integration
- Automatic CloudKit sync
- Type safety with Swift macros
- Simplified data modeling
- Built-in migration support

**Negative:**
- iOS 17+ requirement
- Limited to Apple platforms
- Relatively new framework (potential bugs)
- Less community knowledge compared to Core Data

**Mitigations:**
- Maintain abstraction layer for potential future migration
- Comprehensive testing of data operations
- Keep models simple and focused

### Implementation

- Define models with `@Model` macro
- Use `ModelContainer` and `ModelContext`
- Implement schema versioning from day one
- Test CloudKit sync thoroughly

---

## ADR-0004: The Composable Architecture (TCA)

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Need a predictable state management solution that supports testing and modularity.

### Decision

Adopt TCA for state management across all features.

### Consequences

**Positive:**
- Testable by design
- Composable features
- Predictable state updates
- Time-travel debugging
- Clear separation of concerns

**Negative:**
- Learning curve for team
- Boilerplate code
- Dependency on third-party framework
- Potential performance overhead

**Mitigations:**
- Create code snippets and templates
- Invest in team training
- Monitor performance metrics
- Keep TCA version pinned

### Implementation

- Define features as reducers
- Use dependency injection for services
- Comprehensive testing of reducers
- Utilize TCA's effect system for side effects

---

## ADR-0005: Layered Architecture with Strict Dependencies

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Need to maintain architectural integrity as the codebase grows.

### Decision

Implement layered architecture with compile-time dependency checking:
- App → Features → UI → Services → Infrastructure → Foundation

### Consequences

**Positive:**
- Clear separation of concerns
- Prevents architectural drift
- Easier to reason about dependencies
- Supports modular development
- Enables independent testing

**Negative:**
- More complex project structure
- Build time overhead for checks
- May slow down rapid prototyping
- Requires discipline from team

**Mitigations:**
- Automated tooling for verification
- Clear documentation of layers
- Templates for new components
- Regular architecture reviews

### Implementation

- SwiftSyntax-based import validation
- Pre-commit hooks for enforcement
- CI/CD integration
- Architecture tests in test suite

---

## ADR-0006: Value Objects for Domain Modeling

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Need type safety and domain validation throughout the application.

### Decision

Use value objects (Money, NonEmptyString, Slug, etc.) for domain modeling instead of primitive types.

### Consequences

**Positive:**
- Type safety at compile time
- Validation at boundaries
- Self-documenting code
- Prevents invalid states
- Centralized business rules

**Negative:**
- More types to maintain
- Potential performance overhead
- Verbose for simple cases
- Learning curve for team

**Mitigations:**
- Create convenience initializers
- Use typealiases where appropriate
- Performance testing of critical paths
- Comprehensive documentation

### Implementation

- Define value objects in Foundation layer
- Implement Codable conformance
- Add validation in initializers
- Create extensions for common operations

---

## ADR-0007: Actor-based Infrastructure Services

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Infrastructure services need thread-safe access patterns.

### Decision

Implement infrastructure services (NetworkClient, SecureStorage, PerformanceMonitor) as actors.

### Consequences

**Positive:**
- Thread safety by design
- Clear async boundaries
- Prevents race conditions
- Simplified reasoning about concurrency

**Negative:**
- All access must be async
- Potential for actor reentrancy issues
- Debugging can be more complex
- Learning curve for actor model

**Mitigations:**
- Careful design to avoid reentrancy
- Comprehensive testing of concurrent scenarios
- Clear documentation of actor boundaries
- Use of actor isolation checking

### Implementation

- Define services as actors
- Use async/await for all interactions
- Implement proper error handling
- Test concurrent access patterns

---

## ADR-0008: Multi-Currency Support with Deterministic Rounding

**Date:** 2025-08-09  
**Status:** Accepted  
**Context:** Users may have items purchased in different currencies, need accurate financial calculations.

### Decision

Implement Money value object with minor units storage and deterministic rounding rules.

### Consequences

**Positive:**
- Accurate financial calculations
- No floating-point errors
- Support for all world currencies
- Consistent rounding behavior
- Type-safe currency operations

**Negative:**
- More complex than using Decimal directly
- Currency conversion complexity
- Need to maintain exchange rates
- Storage overhead for currency code

**Mitigations:**
- Cache exchange rates locally
- Provide clear conversion APIs
- Document rounding rules clearly
- Test edge cases thoroughly

### Implementation

- Store amounts as Int64 minor units
- Implement currency-specific scale
- Use banker's rounding (round to even)
- Provide formatted display methods

---

## ADR-0009: Course Correction - TCA Implementation

**Date:** 2024-12-14  
**Status:** Accepted  
**Context:** Project drifted from planned TCA architecture to plain SwiftData implementation.

### Decision

Correct course by:
1. Implementing RootFeature with TCA
2. Creating tab-based navigation
3. Wrapping SwiftData operations in TCA services
4. Building features as TCA reducers

### Consequences

**Positive:**
- Back on track with original architecture
- Testable business logic
- Consistent state management
- Clear feature boundaries

**Negative:**
- Rework of existing code
- Temporary tech debt during transition

**Mitigations:**
- Incremental migration
- Keep existing SwiftData models
- Focus on one feature at a time

### Implementation

- Created RootFeature and RootView
- Implemented InventoryFeature with TCA
- Added navigation using TCA path
- Created service dependencies

---

## ADR-0010: UI Component Library First

**Date:** 2024-12-14  
**Status:** Accepted  
**Context:** Need consistent design system before implementing features.

### Decision

Implement shared UI components before features:
- Theme (spacing, corners, animations)
- Typography system
- Common components (buttons, cards, states)

### Consequences

**Positive:**
- Consistent UI across features
- Faster feature development
- Easy theme changes
- Accessibility built-in

**Negative:**
- Upfront time investment
- May over-engineer early

**Mitigations:**
- Start with minimal set
- Expand as needed
- Keep components simple

### Implementation

- Created UI-Core with Theme and Typography
- Built reusable components (PrimaryButton, ItemCard, EmptyStateView)
- Applied consistent styling throughout