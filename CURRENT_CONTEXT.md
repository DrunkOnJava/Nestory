# Nestory Project Context
Generated: Tue Aug 19 09:10:28 EDT 2025

## CRITICAL REMINDERS
- **App Type**: Personal home inventory for INSURANCE DOCUMENTATION
- **NOT**: Business inventory or stock management
- **Simulator**: ALWAYS use iPhone 16 Plus (per CLAUDE.md)
- **Architecture**: App → Services → Infrastructure → Foundation
- **Focus**: Insurance claims, warranties, receipts, disaster documentation

## Build & Run Commands
```bash
make run          # Build and run on iPhone 16 Plus
make build        # Build only
make check        # Run all verification checks
make doctor       # Diagnose setup issues
```

## Active Services
- BarcodeScannerService.swift
- CloudBackupService.swift
- ImportExportService.swift
- InsuranceExportService.swift
- InsuranceReportService.swift
- NotificationService.swift
- ReceiptOCRService.swift

## UI Views
- AddItemView.swift
- AnalyticsDashboardView.swift
- BarcodeScannerView.swift
- CategoriesView.swift
- ContentView.swift
- EditItemView.swift
- InsuranceExportOptionsView.swift
- InventoryListView.swift
- ItemConditionView.swift
- ItemDetailView.swift
- ManualBarcodeEntryView.swift
- PhotoCaptureView.swift
- ReceiptCaptureView.swift
- SearchView.swift
- SettingsView.swift
- SingleItemInsuranceReportView.swift
- WarrantyDocumentsView.swift

## Models
- Category.swift
- Item.swift
- Receipt.swift
- Room.swift
- Warranty.swift

## Wiring Status
✓ BarcodeScannerService - wired
✗ CloudBackupService - NOT WIRED
✗ ImportExportService - NOT WIRED
✓ InsuranceExportService - wired
✓ InsuranceReportService - wired
✓ NotificationService - wired
✓ ReceiptOCRService - wired

## Key Project Rules
1. ALWAYS wire new features in UI (no orphaned code)
2. NO 'low stock' or business inventory references
3. Focus on insurance documentation features
4. Every service must be @MainActor and ObservableObject
5. Use SwiftData for persistence
6. Follow strict Swift 6 concurrency

## Recent TODOs
./Archive/TCA-Migration/Features.backup/Inventory/InventoryFeature.swift:            // TODO: Implement with SwiftData

## Git Status
 M .claude/settings.local.json
 M .swiftlint.yml
 D App-Main.backup/RootFeature.swift
 D App-Main.backup/RootView.swift
 M App-Main/AddItemView.swift
 M App-Main/ContentView.swift
 M App-Main/InventoryListView.swift
 M App-Main/ItemDetailView.swift
 M App-Main/NestoryApp.swift
 M App-Main/SettingsViews/CloudBackupSettingsView.swift
 M App-Main/SettingsViews/ExportOptionsView.swift
 M App-Main/SettingsViews/ImportExportSettingsView.swift
 M App-Main/SettingsViews/InsuranceReportOptionsView.swift
 M App-Main/SettingsViews/NotificationSettingsView.swift
 M App-Main/WarrantyViews/DocumentManagementView.swift
 M App-Main/WarrantyViews/WarrantyManagementView.swift
 M CURRENT_CONTEXT.md
 M DECISIONS.md
 D Features.backup/Inventory/InventoryFeature.swift
 D Features.backup/Inventory/InventoryView.swift
 D Features.backup/Inventory/ItemDetailFeature.swift
 D Features.backup/Inventory/ItemEditFeature.swift
 M Foundation/Core/NonEmptyString.swift
 M Foundation/Core/Slug.swift
 D Foundation/Models.backup/Category.swift
 D Foundation/Models.backup/CurrencyRate.swift
 D Foundation/Models.backup/Location.swift
 D Foundation/Models.backup/MaintenanceTask.swift
 D Foundation/Models.backup/PhotoAsset.swift
 D Foundation/Models.backup/Receipt.swift
 D Foundation/Models.backup/SchemaVersion.swift
 D Foundation/Models.backup/ShareGroup.swift
 D Foundation/Models.backup/Warranty.swift
 M Foundation/Models/Item.swift
 D Foundation/Models/Item.swift.backup
 M Infrastructure/Cache/MemoryCache.swift
 M Infrastructure/Monitoring/Log.swift
 M Infrastructure/Network/NetworkClient.swift
 M Makefile
 D Services.backup/AnalyticsService/AnalyticsService.swift
 D Services.backup/Authentication/AuthError.swift
 D Services.backup/Authentication/AuthService.swift
 D Services.backup/CurrencyService/CurrencyService.swift
 D Services.backup/ExportService/ExportService.swift
 D Services.backup/InventoryService/InventoryService.swift
 D Services.backup/InventoryService/PhotoIntegration.swift
 D Services.backup/SyncService/BGTaskRegistrar.swift
 D Services.backup/SyncService/ConflictResolver.swift
 D Services.backup/SyncService/SyncService.swift
 M Services/AppStoreConnect/AppMetadataService.swift
 M Services/AppStoreConnect/AppStoreConnectClient.swift
 M Services/AppStoreConnect/AppStoreConnectConfiguration.swift
 M Services/AppStoreConnect/AppStoreConnectOrchestrator.swift
 M Services/AppStoreConnect/AppVersionService.swift
 M Services/AppStoreConnect/MediaUploadService.swift
 M Services/CloudBackupService.swift
 D Services/DependencyKeys.swift.backup
 M Services/InsuranceExport/SpreadsheetExporter.swift
 M Services/InsuranceExport/XMLExporter.swift
 M Services/InsuranceExportService.swift
 M Services/InsuranceReport/ReportExportManager.swift
 M Services/InsuranceReport/ReportSectionDrawer.swift
 M Services/InsuranceReportService.swift
 M Services/NotificationService.swift
 M TREE.md
 M Tests/Services/AnalyticsServiceTests.swift
 M UI/Components/ExportOptionsView.swift
 M UI/Components/InsuranceReportOptionsView.swift
 M UI/UI-Components/EmptyStateView.swift
 M project.yml
 M tools/dev/injection_coordinator.sh
?? .file-size-override
?? App-Main/SingleItemInsuranceReportView.swift
?? Archive/
?? Foundation/Core/Constants/
?? Foundation/Models/Receipt.swift
?? Foundation/Models/Warranty.swift
?? Infrastructure/Actors/
?? Infrastructure/HotReload/
?? Services/AnalyticsService/
?? Services/AppStoreConnect/AppStoreConnectTypes.swift
?? Services/AppStoreConnect/AppVersionModels.swift
?? Services/AppStoreConnect/AppVersionOperations.swift
?? Services/AppStoreConnect/MediaUploadModels.swift
?? Services/AppStoreConnect/MediaUploadOperations.swift
?? Services/CurrencyService/
?? Services/InventoryService/
?? Tests/Services/CloudBackupServiceTests.swift
?? Tests/Services/NotificationServiceTests.swift
?? tools/dev/install_injection.sh

## Last Commit
25a34b8 fix: critical CloudKit crash in Settings tab
