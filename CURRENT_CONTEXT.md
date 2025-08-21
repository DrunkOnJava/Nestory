# Nestory Project Context
Generated: Wed Aug 20 17:19:06 EDT 2025

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
- InsuranceExportService.swift
- InsuranceReportService.swift
- ReceiptOCRService.swift

## UI Views
- AddItemView.swift
- AdvancedSearchView.swift
- AnalyticsDashboardView.swift
- BarcodeScannerView.swift
- CategoriesView.swift
- ContentView.swift
- EditItemView.swift
- EnhancedReceiptDataView.swift
- InsuranceExportOptionsView.swift
- InventoryListView.swift
- ItemConditionView.swift
- ItemDetailView.swift
- LiveReceiptScannerView.swift
- ManualBarcodeEntryView.swift
- MLProcessingProgressView.swift
- PhotoCaptureView.swift
- ReceiptCaptureView.swift
- ReceiptDetailView.swift
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
✓ InsuranceExportService - wired
✓ InsuranceReportService - wired
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
./Infrastructure/Network/HTTPClient.swift:    // Circuit breaker temporarily disabled for compilation - TODO: Integrate with actor-based CircuitBreaker

## Git Status
 M App-Main/AddItemView.swift
 M App-Main/AnalyticsViews/AnalyticsDataProvider.swift
 M App-Main/BarcodeScannerView.swift
 M App-Main/InventoryListView.swift
 M App-Main/ItemDetailView.swift
 M App-Main/NestoryApp.swift
 M App-Main/PhotoPicker.swift
 M App-Main/ReceiptCaptureView.swift
 M App-Main/SearchView.swift
 M App-Main/SettingsView.swift
 M App-Main/SettingsViews/NotificationSettingsView.swift
 M App-Main/SettingsViews/PrivacyPolicyView.swift
 M App-Main/ViewModels/AdvancedSearchViewModel.swift
 M App-Main/WarrantyViews/WarrantyStatusCalculator.swift
 M CURRENT_CONTEXT.md
 M Foundation/Core/ErrorRecoveryStrategy.swift
 M Foundation/Models/Item.swift
 M Foundation/Models/Receipt.swift
 M Foundation/Utils/CurrencyUtils.swift
 M Foundation/Utils/Validation.swift
 M Infrastructure/Cache/DiskCache.swift
 M Infrastructure/Cache/SmartCache.swift
 M Infrastructure/Camera/CameraScannerViewController.swift
 M Infrastructure/HotReload/InjectionServer.swift
 M Infrastructure/Monitoring/Log.swift
 M Infrastructure/Monitoring/LogContext.swift
 M Infrastructure/Monitoring/PerformanceMonitor.swift
 M Infrastructure/Network/HTTPClient.swift
 M Infrastructure/Network/NetworkClient.swift
 M Infrastructure/Performance/PerformanceProfiler.swift
 M Infrastructure/Security/CryptoBox.swift
 M Infrastructure/Security/KeychainStore.swift
 M Infrastructure/Security/SecureEnclaveHelper.swift
 M Infrastructure/Storage/FileStore.swift
 M Infrastructure/Storage/ImageIO.swift
 M Infrastructure/Storage/PerceptualHash.swift
 M Infrastructure/Storage/SecureStorage.swift
 M Infrastructure/Storage/Thumbnailer.swift
 M Services/AnalyticsService/AnalyticsService.swift
 M Services/AnalyticsService/LiveAnalyticsService.swift
 M Services/AppStoreConnect/AppStoreConnectClient.swift
 M Services/BarcodeScannerService/BarcodeScannerService.swift
 M Services/BarcodeScannerService/LiveBarcodeScannerService.swift
 M Services/CloudBackupService/CloudKitBackupOperations.swift
 M Services/CloudBackupService/LiveCloudBackupService.swift
 M Services/CurrencyService/CurrencyService.swift
 M Services/ImportExportService/CSVOperations.swift
 M Services/ImportExportService/ImportExportService.swift
 M Services/InsuranceReport/PDFReportGenerator.swift
 M Services/InsuranceReportService.swift
 M Services/InventoryService/InventoryService.swift
 M Services/InventoryService/PhotoIntegration.swift
 M Services/NotificationService/LiveNotificationService.swift
 M Services/NotificationService/NotificationService.swift
 M Services/ReceiptOCR/ReceiptDataParser.swift
 M Services/ReceiptOCRService.swift
 M TODO.md
 M TREE.md
 M UI/Performance/UIPerformanceOptimizer.swift
?? App-Main/EnhancedReceiptDataView.swift
?? App-Main/LiveReceiptScannerView.swift
?? App-Main/MLProcessingProgressView.swift
?? App-Main/ReceiptDetailView.swift
?? App-Main/ReceiptsSection.swift
?? App-Main/SettingsViews/CurrencySettingsView.swift
?? Services/ReceiptOCR/AppleFrameworksReceiptProcessor.swift
?? Services/ReceiptOCR/CategoryClassifier.swift
?? Services/ReceiptOCR/MLReceiptProcessor.swift

## Last Commit
e5d2caa feat: complete Swift 6 migration with multi-scheme build verification
