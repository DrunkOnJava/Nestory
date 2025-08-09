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