# 🏠 Nestory - Smart Home Inventory Management

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftData](https://img.shields.io/badge/SwiftData-✓-green.svg)](https://developer.apple.com/documentation/swiftdata)
[![Architecture](https://img.shields.io/badge/Architecture-6--Layer-purple.svg)](./Docs/SPEC.json)
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
   make run      # Build and run on iPhone 16 Plus simulator
   # OR
   make open     # Open in Xcode for manual configuration
   ```

### 🛠️ Makefile Commands

Nestory includes a comprehensive Makefile system to ensure consistency across development sessions:

#### Primary Commands
- `make run` - Build and run app on iPhone 16 Plus simulator
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

#### Utilities
- `make new-service NAME=MyService` - Create a new service
- `make new-feature NAME=MyFeature` - Create a new feature
- `make clean` - Clean build artifacts
- `make reset-simulator` - Reset iPhone 16 Plus simulator

#### Quick Access
- `make r` - Shortcut for `make run`
- `make b` - Shortcut for `make build`
- `make c` - Shortcut for `make check`
- `make d` - Shortcut for `make doctor`

**Note:** The Makefile enforces project standards including always using iPhone 16 Plus simulator and ensuring all services are properly wired to the UI.

### First Launch

On first launch, the app will:
1. Initialize the SwiftData container
2. Create default categories (Electronics, Furniture, Clothing, etc.)
3. Present an empty inventory ready for your items

## 🏗️ Architecture

Nestory follows a strict 6-layer architecture for maintainability and scalability:

```
┌─────────────────────────────────────┐
│            App Layer                 │  Entry points, dependency injection
├─────────────────────────────────────┤
│          Features Layer              │  Screens, view models, feature logic
├─────────────────────────────────────┤
│      UI Layer  │   Services Layer    │  Reusable UI   │  Business logic
├─────────────────────────────────────┤
│        Infrastructure Layer          │  Technical adapters, networking
├─────────────────────────────────────┤
│         Foundation Layer             │  Models, value types, extensions
└─────────────────────────────────────┘
```

**Key Principles:**
- ✅ Unidirectional dependencies (top → bottom only)
- ✅ No cross-feature imports
- ✅ SwiftData models in Foundation layer
- ✅ TCA (The Composable Architecture) for state management
- ✅ Swift 6 concurrency throughout

## 📈 Current State

### ✅ Implemented Features

- **Core Data Models**
  - Extended Item model with 15+ properties including receipt storage
  - Category system with bidirectional relationships
  - Swift 6 concurrency compliance (no Sendable on models)

- **User Interface**
  - Tab-based navigation (Inventory, Search, Analytics, Categories, Settings)
  - Complete CRUD operations for items
  - Category management with custom colors/icons
  - Custom empty states with CTAs
  - Swipe-to-delete with visual feedback
  - Documentation status indicators (replaces stock indicators)

- **Insurance & Documentation**
  - ✅ Insurance PDF report generation with customizable options
  - ✅ Receipt OCR with automatic data extraction (store, date, amount)
  - ✅ Documentation completeness tracking
  - ✅ Smart search for missing documentation

- **Data Management**
  - ✅ CSV/JSON import for bulk data entry
  - ✅ Export in multiple formats (CSV, JSON, PDF)
  - ✅ Analytics dashboard with value insights
  - ✅ Advanced search with special syntax

- **Advanced Features**
  - ✅ Photo capture via camera/library
  - ✅ Receipt scanning with text extraction
  - ✅ Real-time search filtering
  - ✅ Rich item details with purchase information

### 🚧 In Development

- [ ] Warranty tracking with expiration alerts
- [ ] Room/location assignment for items
- [ ] Barcode/serial number scanning
- [ ] Document attachments (manuals, warranties)

### 🔮 Planned Features

- [ ] CloudKit backup for disaster recovery
- [ ] Multi-property support
- [ ] Depreciation tracking for tax/insurance
- [ ] Video documentation support
- [ ] Pre/post incident comparison
- [ ] Insurance policy tracker
- [ ] Estate planning export
- [ ] Disaster preparedness checklist

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

```bash
# Run unit tests
swift test

# Run UI tests
xcodebuild test -scheme Nestory -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Check architecture compliance
./DevTools/nestoryctl/.build/release/nestoryctl arch-verify

# Verify SPEC integrity
make spec-verify
```

## 📦 Project Structure

```
Nestory/
├── Foundation/          # Models, value types
│   └── Models/
│       ├── Item.swift
│       └── Category.swift
├── Infrastructure/      # Network, storage, external services
├── Services/           # Business logic, domain services
├── UI/                 # Reusable UI components
│   ├── UI-Core/       # Theme, colors, typography
│   └── UI-Components/ # Buttons, cards, views
├── Features/          # Feature modules
├── App-Main/         # App entry, navigation
│   ├── NestoryApp.swift
│   └── ContentView.swift
├── Resources/        # Assets, files
├── DevTools/         # Development utilities
│   └── nestoryctl/   # CLI for verification
└── Tests/           # Test suites
```

## 🛠️ Development Tools

### nestoryctl CLI

A custom command-line tool for development tasks:

```bash
# Build the tool
swift build -c release --package-path DevTools/nestoryctl

# Available commands
./DevTools/nestoryctl/.build/release/nestoryctl check        # Run all checks
./DevTools/nestoryctl/.build/release/nestoryctl arch-verify  # Verify architecture
./DevTools/nestoryctl/.build/release/nestoryctl spec-verify  # Verify SPEC hash
```

### XcodeGen Configuration

Project generation is handled via `project.yml`:
- Automatic source file discovery
- Platform-specific settings
- SwiftData capability enabled
- Proper bundle identifiers

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

## 📝 TL;DR

**Nestory** is a Swift 6 iOS app for home inventory management using SwiftData. 

**Current Status:** Core features working - add/edit/delete items with photos, categories, and search.

**Setup:** Clone → `xcodegen generate` → Open in Xcode → Run

**Key Learnings:** 
- Don't mark SwiftData models as `Sendable`
- Use simple `ModelContainer(for: Model.self)` initializer
- Always provide defaults for new required properties
- Reset simulator when CoreData migration fails
- Use functions instead of static arrays for Swift 6 concurrency

**Vision:** Become the go-to app for household inventory with AI categorization, insurance integration, and family sharing.

**Stack:** Swift 6, SwiftData, SwiftUI, TCA, 6-layer architecture

**Contributing:** Fork → Branch → PR with tests

---

*Built with ❤️ using Swift 6 and SwiftData*