# 🏠 Nestory - Smart Home Inventory Management

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftData](https://img.shields.io/badge/SwiftData-✓-green.svg)](https://developer.apple.com/documentation/swiftdata)
[![Architecture](https://img.shields.io/badge/Architecture-6--Layer%20TCA-purple.svg)](./SPEC.json)
[![TestFlight](https://img.shields.io/badge/TestFlight-Build%203-success.svg)](https://testflight.apple.com)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

> Transform your home organization with intelligent inventory tracking, seamless categorization, and powerful insights - all in your pocket.

## 📱 About Nestory

Nestory is a comprehensive home inventory management app specifically designed for **personal belongings documentation and insurance preparedness**. Unlike business inventory systems, Nestory focuses on helping homeowners and renters catalog their possessions for insurance claims, warranty tracking, and disaster recovery. Built with Swift 6 and SwiftData, it offers a robust, offline-first experience.

### 🎯 Core Purpose

This app is specifically designed for:
- **Insurance Documentation** - Prepare comprehensive records for insurance claims after disasters
- **Disaster Preparedness** - Quick access to item documentation after catastrophic events  
- **Warranty Management** - Track warranties and important purchase information
- **Personal Organization** - Maintain a searchable catalog of personal belongings
- **Estate Planning** - Document valuable items for estate and inheritance purposes

### Key Features

- 📦 **Comprehensive Item Management** - Track items with photos, receipts, serial numbers, and purchase info
- 📄 **Insurance Report Generation** - Create professional PDF reports for insurance companies
- 🧾 **Receipt OCR** - Scan receipts to automatically extract purchase information
- 🔍 **Advanced Search** - Smart filters and special syntax (e.g., `missing:documentation`)
- 📊 **Analytics Dashboard** - Visual insights into inventory value and documentation status
- 📥 **CSV/JSON Import/Export** - Bulk data management for easy migration
- 🏷️ **Smart Categorization** - Organize belongings with customizable categories
- 📸 **Photo Documentation** - Capture item photos and receipt images
- ✅ **Documentation Status Tracking** - Visual indicators for items missing critical information

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** (Swift 6 support required)
- **iOS 17.0+** deployment target
- **macOS Sonoma 14.0+** for development
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Nestory.git
   cd Nestory
   ```

2. **Initial Setup**
   ```bash
   make setup    # Install dependencies and configure project
   make doctor   # Verify everything is configured correctly
   ```

3. **Build and Run**
   ```bash
   make run      # Build and run on iPhone 16 Pro Max simulator
   # OR
   make open     # Open in Xcode for manual configuration
   ```

### 🛠️ Makefile Commands

Nestory includes a comprehensive Makefile system to ensure consistency across development sessions:

#### Primary Commands
- `make run` - Build and run app on iPhone 16 Pro Max simulator
- `make build` - Build the app (Debug configuration)
- `make test` - Run all tests
- `make check` - Run all verification checks (build, test, lint, architecture)

#### Development Tools
- `make doctor` - Diagnose project setup issues
- `make context` - Generate context file for new chat/development sessions
- `make stats` - Show project statistics
- `make todo` - List all TODOs in the project

#### Code Quality
- `make verify-wiring` - Ensure all services are wired to UI
- `make verify-no-stock` - Verify no business inventory references
- `make verify-arch` - Check architecture compliance
- `make lint` - Run SwiftLint
- `make format` - Format code with SwiftFormat

#### Build Performance
- `make fast-build` - Optimized parallel build (10 cores + enhanced caching)
- `make build-benchmark` - Compare regular vs fast build performance
- `make clean-derived-data` - Clean build cache for fresh builds

#### Utilities
- `make new-service NAME=MyService` - Create a new service
- `make new-feature NAME=MyFeature` - Create a new feature
- `make clean` - Clean build artifacts
- `make reset-simulator` - Reset iPhone 16 Pro Max simulator

#### Quick Access
- `make r` - Shortcut for `make run`
- `make b` - Shortcut for `make build`
- `make c` - Shortcut for `make check`
- `make d` - Shortcut for `make doctor`

**Note:** The Makefile enforces project standards including always using iPhone 16 Pro Max simulator and ensuring all services are properly wired to the UI.

### ⚠️ Important: Build System

**`swift build` is BLOCKED and will NOT work for this iOS app!**

The Package.swift file intentionally causes an error to prevent confusion. If you try to run `swift build`, `swift test`, or other Swift Package Manager commands, you'll get a clear error message directing you to the proper commands.

**For iOS app development, always use:**
- `make run` - Build and run the full iOS app
- `make build` - Build the full iOS app  
- `make fast-build` - Optimized parallel build (⚡ faster)
- `make test` - Run proper iOS tests
- `xcodebuild` - Manual Xcode builds

**Build Performance:** The project includes extensive build optimizations:
- **Parallel compilation** with 10 CPU cores
- **Enhanced caching** with dedicated derived data paths
- **Swift batch mode** for faster compilation
- **Target parallelization** for concurrent builds
- **Incremental compilation** to only rebuild changed files

The project uses XcodeGen + Xcode build system, not Swift Package Manager for the main application.

### First Launch

On first launch, the app will:
1. Initialize the SwiftData container
2. Create default categories (Electronics, Furniture, Clothing, etc.)
3. Present an empty inventory ready for your items

## 🏗️ Architecture

Nestory follows a strict **6-layer TCA (The Composable Architecture)** for sophisticated state management and maintainability:

```
┌─────────────────────────────────────┐
│              App Layer               │  TCA Store setup, root coordination
├─────────────────────────────────────┤
│            Features Layer            │  TCA Reducers, business logic coordination
├─────────────────────────────────────┤
│               UI Layer               │  Reusable SwiftUI components (pure)
├─────────────────────────────────────┤
│            Services Layer            │  Protocol-first domain APIs & TCA dependencies
├─────────────────────────────────────┤
│         Infrastructure Layer         │  Technical adapters, caching, security
├─────────────────────────────────────┤
│           Foundation Layer           │  Models, value types, extensions
└─────────────────────────────────────┘
```

**Key TCA Principles:**
- ✅ Unidirectional data flow (State → View → Action → Reducer → State)
- ✅ TCA @Reducer patterns with @Dependency injection
- ✅ SwiftData models with TCA state management integration
- ✅ Protocol-first service design for TCA testability
- ✅ Swift 6 strict concurrency with TCA @MainActor compliance
- ✅ NavigationStackStore for TCA-driven navigation

## 📈 Current State

**🎉 Production Ready**: Successfully deployed to TestFlight (Build 3) with comprehensive App Store Connect automation.

### ✅ Core Features (Production Ready)

- **📦 Comprehensive Item Management**
  - SwiftData models with 20+ properties (Item, Category, Receipt, Warranty)
  - Full CRUD operations with optimistic UI updates
  - Photo documentation with camera/library integration
  - Serial numbers, model numbers, purchase information tracking

- **🏠 User Interface**
  - Tab-based navigation (Inventory, Search, Analytics, Categories, Settings)
  - Professional iOS design with Dark Mode support
  - Smart empty states with contextual CTAs
  - Swipe gestures and interactive animations
  - Documentation status indicators (not stock levels)

- **📄 Insurance & Documentation**
  - ✅ Professional PDF report generation for insurance claims
  - ✅ Receipt OCR with Vision framework (store, date, amount extraction)
  - ✅ Documentation completeness tracking and visual indicators
  - ✅ Smart search syntax (e.g., `missing:receipt`, `category:electronics`)

- **📊 Data Management & Analytics**
  - ✅ CSV/JSON import/export with data validation
  - ✅ Analytics dashboard with value distribution and trends
  - ✅ Advanced search with real-time filtering
  - ✅ Multi-tier caching system for performance

- **🔧 Infrastructure & Quality**
  - ✅ Swift 6 strict concurrency compliance
  - ✅ Comprehensive testing (80%+ coverage on services)
  - ✅ Professional CI/CD with Fastlane
  - ✅ App Store Connect API integration
  - ✅ Sophisticated error handling and logging

### 🚧 In Active Development

- **Warranty Management**: Expiration tracking with notifications
- **Room/Location Assignment**: Spatial organization of items  
- **Barcode Integration**: Automated product identification
- **Document Attachments**: Manuals, warranties, and receipts

### 🔮 Future Roadmap

- **CloudKit Sync**: Disaster-proof backup and multi-device access
- **Family Sharing**: Collaborative household inventory management
- **Insurance Integration**: Direct API connections with major providers
- **Estate Planning**: Professional reports for inheritance documentation
- **Advanced Analytics**: Depreciation tracking and spending insights

## 🎯 Vision

Nestory aims to become the definitive home inventory solution by:

1. **Eliminating Friction** - Make cataloging items as effortless as taking a photo
2. **Providing Intelligence** - Surface insights about spending, depreciation, and organization
3. **Enabling Peace of Mind** - Insurance-ready documentation at your fingertips
4. **Growing with Users** - From college dorms to family homes to estate management

### Target Personas

- **Homeowners** - Insurance documentation, warranty tracking
- **Renters** - Move-in/out documentation, deposit protection  
- **Collectors** - Detailed cataloging with custom fields
- **Families** - Shared household management
- **Property Managers** - Multi-property inventory tracking

## ⚠️ Common Pitfalls & Solutions

### Swift 6 Concurrency

**❌ Problem:** Adding `Sendable` to SwiftData models
```swift
@Model
final class Item: Sendable { // ❌ Causes compilation errors
```

**✅ Solution:** SwiftData models handle concurrency internally
```swift
@Model
final class Item { // ✅ Correct
```

### ModelContainer Initialization

**❌ Problem:** Using incorrect initializer
```swift
ModelContainer(for: schema, configurations: [config]) // ❌ Doesn't exist
```

**✅ Solution:** Use the simple initializer
```swift
ModelContainer(for: Item.self, Category.self) // ✅ Works
```

### Migration Issues

**❌ Problem:** Adding required properties causes migration failures
```swift
public var currency: String // ❌ Migration fails for existing data
```

**✅ Solution:** Always provide defaults for new required properties
```swift
public var currency: String = "USD" // ✅ Safe migration
```

### Static Properties in Swift 6

**❌ Problem:** Static arrays aren't Sendable
```swift
static let defaultCategories = [...] // ❌ Concurrency warning
```

**✅ Solution:** Use functions instead
```swift
static func createDefaultCategories() -> [Category] { // ✅ No warnings
```

### Simulator Data Corruption

**❌ Problem:** CoreData migration fails with "Validation error missing attribute values"

**✅ Solution:** Reset simulator data when schema changes significantly
```bash
# In iOS Simulator
Device → Erase All Content and Settings

# Or delete just the app
Long press app icon → Delete App
```

## 🧪 Testing

Nestory maintains high test coverage with comprehensive testing at all layers:

```bash
# Run all tests (recommended)
make test                    # Swift Package Manager tests
make test-xcode             # Full Xcode test suite including UI tests
make test-ui                # UI tests only (iPhone 16 Plus)

# Run specific test suites
swift test --filter InventoryServiceTests
swift test --filter ReceiptOCRTests
make test-unit              # Unit tests only

# Architecture and quality checks
make verify-arch            # Check layer dependencies
make verify-wiring          # Ensure services are wired to UI
make lint                   # SwiftLint validation
make check                  # Run all quality checks

# CI/CD testing
make ci                     # Complete CI pipeline
```

### Test Coverage
- **Services**: 80%+ coverage with real SwiftData integration
- **Models**: Comprehensive relationship and validation testing
- **UI**: Automated screenshot testing across device sizes
- **Integration**: End-to-end workflows from UI to persistence

## 📦 Project Structure

```
Nestory/
├── Foundation/                    # Models, value types, core utilities
│   ├── Models/                   # SwiftData models (Item, Category, Receipt, Warranty)
│   ├── Core/                     # Money, Identifiers, Error types
│   └── Utils/                    # Extensions, helpers
├── Infrastructure/               # Technical adapters and external services
│   ├── Cache/                    # Multi-tier caching system
│   ├── Network/                  # HTTP client, API integration
│   ├── Security/                 # Keychain, encryption
│   ├── Storage/                  # File I/O, persistence helpers
│   └── Monitoring/               # Logging, performance tracking
├── Services/                     # Business logic and domain services
│   ├── InventoryService/         # Core inventory operations
│   ├── ReceiptOCR/              # Vision-based text extraction
│   ├── InsuranceReport/         # PDF generation
│   ├── CloudBackup/             # Data synchronization
│   └── AppStoreConnect/         # Deployment automation
├── UI/                          # Reusable UI components
│   ├── UI-Core/                 # Theme, colors, typography
│   └── UI-Components/           # Buttons, cards, form controls
├── App-Main/                    # Main views and navigation
│   ├── NestoryApp.swift         # App entry point
│   ├── ContentView.swift        # Tab navigation
│   ├── InventoryListView.swift  # Primary inventory interface
│   ├── ItemDetailView.swift     # Item editing and details
│   └── Settings/                # Configuration and preferences
├── Tests/                       # Comprehensive test suites
│   ├── Unit/                    # Service and model tests
│   ├── UI/                      # UI and integration tests
│   └── TestSupport/             # Mocks and test utilities
├── fastlane/                    # CI/CD automation
├── DevTools/                    # Development utilities
└── Scripts/                     # Build and maintenance scripts
```

## 🛠️ Development Tools & CI/CD

### Comprehensive Makefile System (762 lines)

The Makefile ensures consistency across development sessions with 60+ commands:

```bash
# Essential commands (run these first)
make doctor                  # Comprehensive environment diagnostics
make context                 # Generate session context file
make run                     # Build and run on iPhone 16 Plus (enforced)

# Development workflow
make build                   # Optimized build with file size checking
make test                    # Full test suite execution
make check                   # Complete quality verification

# Code quality enforcement
make verify-wiring          # Ensure all 13 services are UI-accessible
make verify-no-stock        # Prevent business inventory terminology
make verify-arch            # Architecture layer compliance
```

### Professional CI/CD with Fastlane

Complete App Store deployment automation:

```bash
# TestFlight deployment
bundle exec fastlane beta                 # Build 3 successfully deployed
bundle exec fastlane screenshots         # Multi-device screenshot capture
bundle exec fastlane complete_submission # Full App Store workflow

# Local development
make archive                             # Distribution builds
make screenshot                          # UI test screenshots
```

### App Store Connect Integration

Sophisticated automation includes:
- **AppStoreConnectOrchestrator**: Complete submission workflows
- **AppMetadataService**: Automated metadata management
- **MediaUploadService**: Screenshot and asset automation
- **EncryptionDeclarationService**: Export compliance handling

### XcodeGen Configuration

Professional project generation via `project.yml`:
- Swift 6.0 with strict concurrency (Release) / minimal (Debug)
- iOS 17.0+ deployment target
- iPhone 16 Plus simulator enforcement
- Automatic source discovery and organization

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint rules defined in `.swiftlint.yml`
- Maintain 80% minimum test coverage
- Document public APIs
- Add layer comments to all files

### Pre-commit Hooks

Install hooks to ensure code quality:
```bash
make install-hooks
```

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) by Point-Free
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) by Yonas Kolb
- [SwiftLint](https://github.com/realm/SwiftLint) by Realm
- Apple's SwiftData framework team

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/Nestory/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/Nestory/discussions)
- **Email:** support@nestory.app

---

## 🚀 Deployment Status

**🎉 Production Ready**: Nestory is production-ready with successful TestFlight deployment.

### Current Deployment
- **TestFlight**: Build 3 successfully deployed and available
- **App Store Connect**: Full API integration with automated workflows  
- **CI/CD**: Complete Fastlane pipeline for automated deployment
- **Export Compliance**: Configured and approved for App Store distribution

### Deployment Commands
```bash
# TestFlight deployment
bundle exec fastlane beta                 # Automated build and upload
bundle exec fastlane screenshots         # Generate App Store screenshots
bundle exec fastlane complete_submission # Full submission workflow

# Distribution builds
make archive                             # Create distribution archive
make ci                                  # Complete CI pipeline
```

---

## 📝 TL;DR

**Nestory** is a **production-ready** Swift 6 iOS app for home inventory management focused on insurance documentation.

**Current Status:** ✅ **TestFlight Build 3 deployed** - comprehensive inventory management with receipt OCR, insurance reporting, and analytics.

**Quick Setup:** `git clone` → `make setup` → `make run` (iPhone 16 Plus enforced)

**Architecture:** Clean 4-layer architecture (App-Main → Services → Infrastructure → Foundation) with 80%+ test coverage

**Key Features:** Receipt scanning, insurance PDF reports, analytics dashboard, CSV/JSON import/export, advanced search

**Tech Stack:** Swift 6, SwiftData, SwiftUI, @MainActor patterns, professional CI/CD with Fastlane

**Production Quality:** Comprehensive testing, App Store Connect automation, professional error handling, performance optimization

**Contributing:** Fork → Branch → `make check` → PR with tests

---

*🏠 Built with ❤️ for insurance-ready home inventory documentation*