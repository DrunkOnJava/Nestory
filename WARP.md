# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Nestory is a Swift 6 iOS app built with a strict 6-layer TCA architecture, generated via XcodeGen, and automated with a comprehensive Makefile. The Makefile is the single source of truth for building, testing, and verifying architecture.

Commands (canonical)

- Setup and environment
  - make setup        # Install tools used by the project (e.g., xcodegen); initial setup
  - make doctor       # Diagnose environment (Xcode, Swift, required dirs, simulator availability)

- Build and run (iOS Simulator: iPhone 16 Pro Max is enforced)
  - make run          # Build and launch the app in the simulator
  - make build        # Build (Debug)
  - make fast-build   # Clean derived data + parallel optimized build with enhanced caching
  - make open         # Open the Xcode project
  - Scheme variants: append SCHEME_TARGET=dev|staging|prod (e.g., make run SCHEME_TARGET=staging)

- Tests
  - make test         # Run all Swift tests (SPM-based)
  - make test-xcode   # Run tests via xcodebuild using the active scheme/destination
  - make test-unit    # Unit tests only
  - make test-ui      # UI tests on the standard simulator
  - Single test examples:
    - swift test --filter InventoryServiceTests
    - xcodebuild test -scheme Nestory-Dev -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' -only-testing:NestoryUITests/SomeTestClass/testSomeCase

- Quality and verification
  - make check        # Build + tests + guards + wiring + lint + file-size checks + framework self-test
  - make verify-arch  # Layer rules verification (uses nestoryctl under the hood)
  - make verify-wiring# Ensure all services/features are reachable from UI
  - make lint         # SwiftLint
  - make format       # SwiftFormat

- Shortcuts and utilities
  - make r | b | f | c | d      # Shortcuts for run/build/fast-build/check/doctor
  - make stats                  # Project statistics
  - make todo                   # Aggregate TODOs
  - make reset-simulator        # Reset iPhone 16 Pro Max simulator
  - make ci                     # CI pipeline (local)
  - make archive                # Create distribution archive

Build system notes (important)

- The app uses Xcode/XcodeGen for builds; swift build is intentionally blocked for app targets. Use the Makefile and xcodebuild paths above.
- Swift tests are executed via swift test for module/guard checks and via xcodebuild for UI/targeted suites.

High-level architecture (big picture)

- 6-layer TCA architecture (strict layering)
  - App → Features → UI → Services → Infrastructure → Foundation
  - Build order is fail-fast and enforced in project.yml: Foundation → Infrastructure → Services → UI → Features → App-Main

- Layer import rules (from CLAUDE.md / SPEC)
  - App: may import Features, UI, Services, Infrastructure, Foundation
  - Features: may import UI, Services, Foundation (and TCA)
  - UI: may import Foundation only (pure components)
  - Services: may import Infrastructure, Foundation
  - Infrastructure: may import Foundation only
  - Foundation: no internal imports beyond Swift stdlib

- TCA patterns and dependencies
  - Features are @Reducer-based with @Dependency injection; unidirectional data flow (State → View → Action → Reducer → State)
  - Strict Swift 6 concurrency; @MainActor where appropriate for UI/services

- Project generation and CI hooks
  - XcodeGen (project.yml) defines targets, schemes, and build scripts
  - Build metrics and error collection run via Scripts/CI/* during builds/tests
  - Architecture verification and guard suite are integrated via Makefile targets (verify-arch, guard)

Domain and policy highlights (from CLAUDE.md)

- Purpose: personal belongings inventory for insurance documentation (not business stock management)
- Always wire new features/services to the UI; no orphaned code
- Enforced standard simulator: iPhone 16 Pro Max
- New features must follow TCA patterns

Monitoring and local telemetry (optional)

- Start the development telemetry stack (Prometheus, Pushgateway, Grafana, OTEL collector):
  - docker compose -f monitoring/docker-compose-dev.yml up -d
  - make -C monitoring setup
  - make -C monitoring status
  - Grafana will be on http://localhost:3000 (datasources/provisioning handled by the stack)

References

- Key files: README.md (project overview and commands), Makefile (automation), project.yml (XcodeGen configuration), CLAUDE.md (rules/policies), monitoring/* (observability stack)
- Schemes from Config/MakefileConfig.mk: Nestory-Dev, Nestory-Staging, Nestory-Prod; use SCHEME_TARGET to switch in Make targets

