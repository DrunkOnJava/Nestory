# Nestory Guard Rails

**This repository contains guard rails and enforcement mechanisms only.** It does not contain application code.

## Purpose

This repository establishes and enforces the architectural constraints, quality gates, and development standards for the Nestory iOS application. It provides:

- **Architecture enforcement** via SPEC-as-code and automated tests
- **Pre-commit hooks** to prevent architectural drift
- **CI/CD workflows** to maintain quality standards
- **Dev CLI tools** for verification and maintenance

## Architecture

The enforced 6-layer architecture:

```
┌─────────────────────────────────────────────┐
│                 App Layer                   │
├─────────────────────────────────────────────┤
│              Features Layer                 │
├─────────────────────────────────────────────┤
│                 UI Layer                    │
├─────────────────────────────────────────────┤
│              Services Layer                 │
├─────────────────────────────────────────────┤
│           Infrastructure Layer              │
├─────────────────────────────────────────────┤
│             Foundation Layer                │
└─────────────────────────────────────────────┘
```

Dependencies flow downward only. Cross-layer and circular dependencies are prohibited.

## Local Quickstart

```bash
# 1. Clone the repository
git clone [repository-url]
cd Nestory

# 2. Install git hooks
make install-hooks

# 3. Run the guard suite
make guard

# 4. Run architecture tests
swift test

# 5. Verify SPEC integrity
make spec-verify
```

## Available Commands

### Makefile Targets

- `make guard` - Run all verification checks
- `make install-hooks` - Install git pre-commit hooks
- `make spec-verify` - Verify SPEC.json integrity
- `make spec-commit` - Update SPEC.lock after changes
- `make arch-verify` - Check architecture conformance
- `make test` - Run all tests
- `make clean` - Clean build artifacts

### Dev CLI (nestoryctl)

```bash
# Build the CLI tool
swift build -c release --package-path DevTools/nestoryctl

# Run commands
./DevTools/nestoryctl/.build/release/nestoryctl check        # Run all checks
./DevTools/nestoryctl/.build/release/nestoryctl arch-verify  # Verify architecture
./DevTools/nestoryctl/.build/release/nestoryctl spec-verify  # Verify SPEC hash
./DevTools/nestoryctl/.build/release/nestoryctl spec-commit  # Update SPEC.lock
./DevTools/nestoryctl/.build/release/nestoryctl spm-audit    # Audit dependencies
./DevTools/nestoryctl/.build/release/nestoryctl licenses     # Update licenses
```

## SPEC-as-Code

The `SPEC.json` file defines:
- Application configuration (bundle IDs, team ID, minimum OS)
- Technology choices (Swift 6, TCA, SwiftData, CloudKit)
- Architectural layers and allowed import rules
- SLO targets (performance, reliability)
- CI/CD policies and quality gates

The `SPEC.lock` file contains the SHA256 hash of `SPEC.json` to detect unauthorized changes.

## Modifying the SPEC

1. Edit `SPEC.json` with your changes
2. Document changes in `SPEC_CHANGE.md`
3. Add an ADR entry to `DECISIONS.md`
4. Run `make spec-commit` to update `SPEC.lock`
5. Commit all files together

## Architecture Tests

The `ArchitectureTests` use SwiftSyntax to:
- Parse all Swift files in the codebase
- Extract import statements
- Build a dependency graph
- Validate against `SPEC.json` rules
- Fail the build on violations

## Pre-commit Hooks

Installed hooks will:
- Check code formatting (if swiftformat is installed)
- Run linting (if swiftlint is installed)
- Verify SPEC.json integrity
- Run architecture verification
- Block commits with bare TODO/FIXME (must reference ADR)

## CI/CD Workflows

### Pull Request (quality.yml)
- Runs on all PRs to main/develop
- Executes full guard suite
- Reports violations
- Updates BUILD_STATUS.md

### Main Branch (ci.yml)
- Runs on pushes to main
- Full test suite execution
- Coverage generation
- Artifact collection

## Next Steps

After setting up these guard rails:

1. **Generate application code** - Run your Nestory codegen prompt within this repository. The guards will enforce architectural compliance.

2. **Add Swift files** - Place implementation files in the appropriate layer directories. The architecture tests will validate imports.

3. **Configure Xcode** - Create an Xcode project that references the Package.swift and follows the module structure.

4. **Set up dependencies** - Add third-party packages to Package.swift, ensuring they're pinned to exact versions.

5. **Document decisions** - Continue adding ADRs to DECISIONS.md for significant architectural choices.

## Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- Git

## License

See LICENSE file for details.

## Support

For issues or questions about the guard rails system, please file an issue in the repository.