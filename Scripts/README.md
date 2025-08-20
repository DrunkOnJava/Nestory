# Nestory Testing & Automation Scripts

This directory contains comprehensive testing and automation scripts for the Nestory iOS application. These scripts provide a complete development workflow optimization, automated testing, and continuous integration setup.

## 🚀 Quick Start

### 1. Run Complete Optimization
```bash
./Scripts/optimize_xcode_workflow.sh
```
This will optimize your entire Xcode development workflow in one command.

### 2. Load Development Aliases
```bash
source Scripts/nestory_aliases.sh
```
This provides quick commands like `nb` (build), `nt` (test), `ndc` (dev cycle).

### 3. Run Automated Testing
```bash
./Scripts/run_simulator_automation.sh
```
This runs comprehensive iOS Simulator automation with AppleScript.

## 📁 Script Overview

### Core Automation Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `ios_simulator_automation.applescript` | AppleScript for iOS Simulator control | Automatic execution via runner |
| `run_simulator_automation.sh` | iOS Simulator automation orchestrator | `./Scripts/run_simulator_automation.sh` |
| `optimize_xcode_workflow.sh` | Complete Xcode workflow optimization | `./Scripts/optimize_xcode_workflow.sh` |

### Development Workflow Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `quick_build.sh` | Fast incremental builds | `./Scripts/quick_build.sh` or `nb` |
| `quick_test.sh` | Unit tests only | `./Scripts/quick_test.sh` or `nt` |
| `dev_cycle.sh` | Complete build→test→UI cycle | `./Scripts/dev_cycle.sh` or `ndc` |
| `dev_stats.sh` | Development metrics | `./Scripts/dev_stats.sh` or `nstats` |

### Utility Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `nestory_aliases.sh` | Development aliases | `source Scripts/nestory_aliases.sh` |

## 🧪 Testing Infrastructure

### Swift Testing Framework (New)
- **Location**: `Tests/Unit/Foundation/`
- **Features**: Modern Swift Testing with `@Test` and `#expect`
- **Coverage**: Foundation types, models, utilities
- **Example**: `MoneyTests.swift`, `TestHelpers.swift`

### XCTest Framework (Comprehensive)
- **Location**: `Tests/Services/`
- **Features**: Traditional XCTest with extensive service mocking
- **Coverage**: Service layer, integration tests, performance tests
- **Example**: `ComprehensiveServiceTests.swift`

### XCUIAutomation (UI Testing)
- **Location**: `NestoryUITests/Tests/`
- **Features**: Complete user journey testing with screenshots
- **Coverage**: Navigation, features, accessibility, performance
- **Example**: `ComprehensiveUIFlowTests.swift`

## 🏗️ Architecture

### AppleScript iOS Simulator Testing
```
┌─────────────────────────────────────┐
│  run_simulator_automation.sh       │
│  ├── Prerequisites Check            │
│  ├── Simulator Setup               │
│  ├── App Build & Install           │
│  ├── AppleScript Execution         │
│  └── Report Generation             │
└─────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│  ios_simulator_automation.applescript│
│  ├── Environment Setup             │
│  ├── App Launch                    │
│  ├── Navigation Testing            │
│  ├── Feature Testing               │
│  ├── Screenshot Capture            │
│  └── Cleanup                       │
└─────────────────────────────────────┘
```

### XCTest Integration Testing
```
┌─────────────────────────────────────┐
│  ComprehensiveServiceTests.swift    │
│  ├── Analytics Service Tests       │
│  ├── Cloud Backup Tests            │
│  ├── Integration Tests             │
│  ├── Performance Tests             │
│  ├── Memory Management Tests       │
│  └── Thread Safety Tests           │
└─────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│  TestHelpers.swift                  │
│  ├── Test Data Builders            │
│  ├── Mock Services                 │
│  ├── Custom Assertions             │
│  ├── Performance Helpers           │
│  └── Memory Leak Detection         │
└─────────────────────────────────────┘
```

### XCUIAutomation Workflow Testing
```
┌─────────────────────────────────────┐
│  ComprehensiveUIFlowTests.swift     │
│  ├── Complete User Journeys        │
│  ├── Inventory Management Flow     │
│  ├── Settings Configuration        │
│  ├── Analytics Dashboard           │
│  ├── Error Handling Scenarios      │
│  ├── Accessibility Testing         │
│  └── Performance Testing           │
└─────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│  NestoryUITestBase.swift            │
│  ├── Swift 6 Concurrency           │
│  ├── MainActor Isolation           │
│  ├── Screenshot Management         │
│  ├── Navigation Helpers            │
│  └── Wait & Assertion Helpers      │
└─────────────────────────────────────┘
```

## ⚡ Performance Optimizations

### Build Performance
- **Incremental Compilation**: Optimized for faster rebuilds
- **Derived Data**: Custom location for SSD optimization
- **Parallel Builds**: Multi-core compilation enabled
- **Build Settings**: Debug-optimized configurations

### Test Performance
- **Parallel Testing**: Concurrent test execution
- **Mock Services**: Fast test doubles
- **Targeted Testing**: Unit tests vs. full suite
- **Test Configuration**: Environment-based optimization

### Workflow Performance
- **One-Command Operations**: `nb`, `nt`, `ndc` aliases
- **Pre-commit Hooks**: Automated validation
- **Fast Feedback**: Instant build/test results
- **Automated Reporting**: Real-time metrics

## 🔧 Configuration Files

### Build Optimization
- `Config/Optimization.xcconfig` - Build performance settings
- `Nestory-Dev-Fast.xcscheme` - Optimized development scheme
- `Nestory-Tests-Fast.xcscheme` - Fast testing configuration

### Testing Configuration
- `TestConfiguration.swift` - Global test settings
- Test environment variables for mock/fast modes
- Screenshot management and reporting

## 📊 Monitoring & Reporting

### Automated Reports
- **HTML Test Reports**: Complete test run documentation
- **Screenshot Galleries**: Visual test progression
- **Performance Metrics**: Build and test timing
- **Development Statistics**: Code metrics and progress

### Key Metrics Tracked
- Build times (clean and incremental)
- Test execution times
- Code coverage percentages
- Memory usage patterns
- UI automation success rates

## 🚨 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and rebuild
./Scripts/optimize_xcode_workflow.sh --clean-only
./Scripts/quick_build.sh
```

#### Simulator Issues
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all
```

#### Test Failures
```bash
# Run with verbose logging
FAST_TEST_MODE=0 ./Scripts/quick_test.sh
```

### Debug Commands
```bash
# View optimization log
tail -f optimization.log

# Check development stats
./Scripts/dev_stats.sh

# Test specific component
./Scripts/run_simulator_automation.sh --test-only
```

## 🔄 Continuous Integration

### GitHub Actions Integration
The scripts are designed to work with CI/CD pipelines:

```yaml
- name: Run Optimized Tests
  run: |
    ./Scripts/optimize_xcode_workflow.sh --build-only
    ./Scripts/quick_test.sh
    ./Scripts/run_simulator_automation.sh --test-only
```

### Pre-commit Hooks
Automated validation before commits:
- Swift format checking
- Build verification
- Basic test validation

## 📚 Best Practices

### Development Workflow
1. **Start with optimization**: Run `optimize_xcode_workflow.sh` once
2. **Use aliases**: Load `nestory_aliases.sh` for quick commands
3. **Incremental testing**: Use `nt` for quick unit test feedback
4. **Full validation**: Use `ndc` before commits
5. **Monitor metrics**: Regular `nstats` checks

### Testing Strategy
1. **Unit tests first**: Fast feedback with comprehensive coverage
2. **Integration tests**: Service layer validation
3. **UI automation**: Complete user journey validation
4. **Performance tests**: Regular performance regression checks

### Code Quality
1. **Pre-commit validation**: Automated quality checks
2. **Test-driven development**: Tests written with implementation
3. **Mock services**: Fast, reliable test isolation
4. **Continuous monitoring**: Real-time metrics and reporting

## 🤝 Contributing

When adding new scripts or tests:

1. **Follow naming conventions**: Clear, descriptive names
2. **Add documentation**: Update this README
3. **Include error handling**: Robust failure management
4. **Add logging**: Comprehensive operation tracking
5. **Test thoroughly**: Validate on clean environment

## 📝 License

These scripts are part of the Nestory project and follow the same licensing terms.

---

*Generated by Nestory Testing & Automation Framework*
*Last updated: August 2025*