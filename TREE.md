# Project Structure

_Last updated: 2025-08-10 10:57:10_

```
.
├── App-Main
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Preview Content
│   │   └── PreviewAssets.xcassets
│   │       └── Contents.json
│   ├── AddItemView.swift
│   ├── AnalyticsDashboardView.swift
│   ├── BarcodeScannerView.swift
│   ├── CategoriesView.swift
│   ├── ContentView.swift
│   ├── EditItemView.swift
│   ├── Info.plist
│   ├── InsuranceExportOptionsView.swift
│   ├── InventoryListView.swift
│   ├── ItemConditionView.swift
│   ├── ItemDetailView.swift
│   ├── Nestory.entitlements
│   ├── NestoryApp.swift
│   ├── PhotoCaptureView.swift
│   ├── ReceiptCaptureView.swift
│   ├── SearchView.swift
│   ├── SettingsView.swift
│   ├── ThemeManager.swift
│   └── WarrantyDocumentsView.swift
├── App-Main.backup
│   ├── RootFeature.swift
│   └── RootView.swift
├── App-Widgets
├── Config
│   ├── StoreKit
│   │   └── StoreKitConfiguration.storekit
│   ├── Base.xcconfig
│   ├── Debug.xcconfig
│   ├── Dev.xcconfig
│   ├── FeatureFlags.swift
│   ├── flags.json
│   ├── Prod.xcconfig
│   ├── Release.xcconfig
│   ├── Rings.md
│   ├── Secrets.template.swift
│   └── Staging.xcconfig
├── DevTools
│   ├── nestoryctl
│   │   ├── Sources
│   │   │   └── NestoryCtl
│   │   │       └── main.swift
│   │   ├── Package.resolved
│   │   └── Package.swift
│   └── install_hooks.sh
├── Features
├── Features.backup
│   └── Inventory
│       ├── InventoryFeature.swift
│       ├── InventoryView.swift
│       ├── ItemDetailFeature.swift
│       └── ItemEditFeature.swift
├── Foundation
│   ├── Core
│   │   ├── Errors.swift
│   │   ├── Identifiers.swift
│   │   ├── Money.swift
│   │   ├── NonEmptyString.swift
│   │   └── Slug.swift
│   ├── Models
│   │   ├── Category.swift
│   │   ├── Item.swift
│   │   ├── Item.swift.backup
│   │   └── Room.swift
│   ├── Models.backup
│   │   ├── Category.swift
│   │   ├── CurrencyRate.swift
│   │   ├── Location.swift
│   │   ├── MaintenanceTask.swift
│   │   ├── PhotoAsset.swift
│   │   ├── Receipt.swift
│   │   ├── SchemaVersion.swift
│   │   ├── ShareGroup.swift
│   │   └── Warranty.swift
│   ├── Resources
│   │   └── Fixtures.json
│   └── Utils
│       ├── CurrencyUtils.swift
│       ├── DateUtils.swift
│       └── Validation.swift
├── Infrastructure
│   ├── Monitoring
│   │   ├── Log.swift
│   │   ├── MetricKitCollector.swift
│   │   ├── PerformanceMonitor.swift
│   │   └── Signpost.swift
│   ├── Network
│   │   ├── Endpoint.swift
│   │   ├── HTTPClient.swift
│   │   ├── NetworkClient.swift
│   │   └── NetworkError.swift
│   ├── Security
│   │   ├── CryptoBox.swift
│   │   ├── KeychainStore.swift
│   │   └── SecureEnclaveHelper.swift
│   └── Storage
│       ├── Cache.swift
│       ├── FileStore.swift
│       ├── ImageIO.swift
│       ├── PerceptualHash.swift
│       ├── SecureStorage.swift
│       └── Thumbnailer.swift
├── Nestory
│   ├── App-Main
│   ├── App-Widgets
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Config
│   ├── DevTools
│   │   └── nestoryctl
│   │       └── Sources
│   │           └── NestoryCtl
│   ├── Features
│   │   ├── Analytics
│   │   ├── Capture
│   │   ├── Inventory
│   │   ├── Maintenance
│   │   ├── Search
│   │   └── Sharing
│   ├── Foundation
│   │   ├── Core
│   │   │   ├── Errors.swift
│   │   │   ├── Identifiers.swift
│   │   │   ├── Money.swift
│   │   │   ├── NonEmptyString.swift
│   │   │   ├── SchemaVersion.swift
│   │   │   └── Slug.swift
│   │   ├── Models
│   │   │   ├── Category.swift
│   │   │   ├── CurrencyRate.swift
│   │   │   ├── Item.swift
│   │   │   ├── Location.swift
│   │   │   ├── MaintenanceTask.swift
│   │   │   ├── PhotoAsset.swift
│   │   │   ├── Receipt.swift
│   │   │   ├── ShareGroup.swift
│   │   │   └── Warranty.swift
│   │   ├── Resources
│   │   │   └── Fixtures.json
│   │   └── Utils
│   │       ├── CurrencyUtils.swift
│   │       ├── DateUtils.swift
│   │       └── Validation.swift
│   ├── Infrastructure
│   │   ├── Monitoring
│   │   │   ├── Log.swift
│   │   │   ├── MetricKitCollector.swift
│   │   │   └── Signpost.swift
│   │   ├── Network
│   │   │   ├── Endpoint.swift
│   │   │   ├── HTTPClient.swift
│   │   │   └── NetworkError.swift
│   │   ├── Security
│   │   │   ├── CryptoBox.swift
│   │   │   ├── KeychainStore.swift
│   │   │   └── SecureEnclaveHelper.swift
│   │   └── Storage
│   │       ├── Cache.swift
│   │       ├── FileStore.swift
│   │       ├── ImageIO.swift
│   │       ├── PerceptualHash.swift
│   │       └── Thumbnailer.swift
│   ├── Models
│   ├── Scripts
│   │   ├── capture_screenshots.sh
│   │   └── quick_screenshot_test.sh
│   ├── Services
│   │   ├── AnalyticsService
│   │   │   └── AnalyticsService.swift
│   │   ├── Authentication
│   │   │   ├── AuthError.swift
│   │   │   └── AuthService.swift
│   │   ├── CurrencyService
│   │   │   └── CurrencyService.swift
│   │   ├── ExportService
│   │   │   └── ExportService.swift
│   │   ├── InventoryService
│   │   │   ├── InventoryService.swift
│   │   │   └── PhotoIntegration.swift
│   │   ├── SyncService
│   │   │   ├── BGTaskRegistrar.swift
│   │   │   ├── ConflictResolver.swift
│   │   │   └── SyncService.swift
│   │   └── DependencyKeys.swift
│   ├── Tests
│   │   └── ArchitectureTests
│   ├── UI
│   │   ├── UI-Components
│   │   ├── UI-Core
│   │   └── UI-Styles
│   ├── Utilities
│   │   └── ThemeManager.swift
│   ├── Views
│   │   ├── AddItemView.swift
│   │   ├── CategoriesView.swift
│   │   ├── EditItemView.swift
│   │   ├── InventoryListView.swift
│   │   ├── ItemDetailView.swift
│   │   ├── SearchView.swift
│   │   └── SettingsView.swift
│   ├── ContentView.swift
│   ├── Info.plist
│   ├── Nestory.entitlements
│   └── NestoryApp.swift
├── Nestory.xcodeproj
│   ├── xcshareddata
│   │   └── xcschemes
│   │       └── Nestory-Dev.xcscheme
│   └── project.pbxproj
├── NestoryTests
│   ├── Infrastructure
│   │   ├── MonitoringTests.swift
│   │   ├── NetworkTests.swift
│   │   ├── SecurityTests.swift
│   │   └── StorageTests.swift
│   └── NestoryTests.swift
├── NestoryUITests
│   ├── NestoryDeviceScreenshotTests.swift
│   ├── NestoryScreenshotTests.swift
│   ├── NestoryUIScreenshotFlow.swift
│   ├── NestoryUITests.swift
│   ├── NestoryUITestsLaunchTests.swift
│   ├── ScreenshotHelper.swift
│   └── SimpleScreenshotTests.swift
├── Scripts
├── Services
│   ├── BarcodeScannerService.swift
│   ├── CloudBackupService.swift
│   ├── DependencyKeys.swift.backup
│   ├── ImportExportService.swift
│   ├── InsuranceExportService.swift
│   ├── InsuranceReportService.swift
│   └── ReceiptOCRService.swift
├── Services.backup
│   ├── AnalyticsService
│   │   └── AnalyticsService.swift
│   ├── Authentication
│   │   ├── AuthError.swift
│   │   └── AuthService.swift
│   ├── CurrencyService
│   │   └── CurrencyService.swift
│   ├── ExportService
│   │   └── ExportService.swift
│   ├── InventoryService
│   │   ├── InventoryService.swift
│   │   └── PhotoIntegration.swift
│   └── SyncService
│       ├── BGTaskRegistrar.swift
│       ├── ConflictResolver.swift
│       └── SyncService.swift
├── Sources
│   └── NestoryGuards
│       └── NestoryGuards.swift
├── Tests
│   ├── ArchitectureTests
│   │   └── ArchitectureTests.swift
│   ├── Integration
│   ├── Performance
│   │   └── baselines.json
│   ├── Services
│   │   ├── AnalyticsServiceTests.swift
│   │   ├── AuthServiceTests.swift
│   │   ├── CurrencyServiceTests.swift
│   │   ├── InventoryServiceTests.swift
│   │   └── SyncServiceTests.swift
│   ├── Snapshot
│   ├── TestSupport
│   │   └── ServiceMocks.swift
│   └── Unit
│       └── Foundation
│           ├── IdentifierTests.swift
│           ├── ModelInvariantTests.swift
│           └── MoneyTests.swift
├── UI
│   ├── UI-Components
│   │   ├── EmptyStateView.swift
│   │   ├── ItemCard.swift
│   │   ├── PrimaryButton.swift
│   │   └── SearchBar.swift
│   ├── UI-Core
│   │   ├── Theme.swift
│   │   └── Typography.swift
│   └── UI-Styles
├── BUILD_INSTRUCTIONS.md
├── BUILD_STATUS.md
├── build.sh
├── check_environment.sh
├── CLAUDE.md
├── CURRENT_CONTEXT.md
├── DECISIONS.md
├── DEVELOPMENT_CHECKLIST.md
├── emergency_fix.sh
├── fix_build.sh
├── frustratingResults.jpg
├── LICENSE
├── Makefile
├── metrics.sh
├── move_models.sh
├── nestory_prompt_pack.zip
├── Observability.md
├── open_xcode.sh
├── Package.resolved
├── Package.swift
├── PROJECT_CONTEXT.md
├── project.yml
├── quick_build.sh
├── README.md
├── run_app_final.sh
├── run_app.sh
├── run_screenshots.sh
├── setup_auto_tree.sh
├── SPEC_CHANGE.md
├── SPEC.json
├── SPEC.lock
├── THIRD_PARTY_LICENSES.md
├── TREE.md
├── update_tree.sh
├── verify_build.sh
└── XCODE_FIX.md

104 directories, 229 files
```

_📁 Directories:  | 📄 Files: 
