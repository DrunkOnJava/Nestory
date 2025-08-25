# Nestory Project Context
Generated: Thu Aug 21 06:06:56 EDT 2025

## CRITICAL REMINDERS
- **App Type**: Personal home inventory for INSURANCE DOCUMENTATION
- **NOT**: Business inventory or stock management
- **Simulator**: ALWAYS use iPhone 16 Pro Max (per CLAUDE.md)
- **Architecture**: App → Services → Infrastructure → Foundation
- **Focus**: Insurance claims, warranties, receipts, disaster documentation

## Build & Run Commands
```bash
make run          # Build and run on iPhone 16 Pro Max
make build        # Build only
make check        # Run all verification checks
make doctor       # Diagnose setup issues
```

## Active Services
- ClaimContentGenerator.swift
- ClaimDocumentProcessor.swift
- ClaimEmailService.swift
- ClaimExportService.swift
- ClaimPackageAssemblerService.swift
- ClaimPackageCore.swift
- ClaimPackageExporter.swift
- ClaimTrackingService.swift
- ClaimValidationService.swift
- CloudStorageServices.swift
- DependencyKeys.swift
- InsuranceClaimCore.swift
- InsuranceClaimModels.swift
- InsuranceClaimService.swift
- InsuranceClaimValidation.swift
- InsuranceExportService.swift
- InsuranceReportService.swift
- ReceiptOCRService.swift

## UI Views
- AddItemView.swift
- AdvancedSearchView.swift
- BarcodeScannerView.swift
- CategoriesView.swift
- ClaimExportView.swift
- ClaimPackageAssemblyView.swift
- ClaimPreviewView.swift
- ClaimSubmissionView.swift
- EditItemView.swift
- EnhancedReceiptDataView.swift
- InsuranceClaimView.swift
- InsuranceExportOptionsView.swift
- InventoryListView.swift
- ItemConditionView.swift
- ItemDetailView.swift
- LiveReceiptScannerView.swift
- ManualBarcodeEntryView.swift
- PhotoCaptureView.swift
- ReceiptCaptureView.swift
- ReceiptDetailView.swift
- RootView.swift
- SingleItemInsuranceReportView.swift
- WarrantyDashboardView.swift
- WarrantyDocumentsView.swift

## Models
- Category.swift
- Item.swift
- Receipt.swift
- Room.swift
- Warranty.swift

## Wiring Status
✗ ClaimContentGenerator - NOT WIRED
✗ ClaimDocumentProcessor - NOT WIRED
✗ ClaimEmailService - NOT WIRED
✗ ClaimExportService - NOT WIRED
✗ ClaimPackageAssemblerService - NOT WIRED
✗ ClaimPackageCore - NOT WIRED
✗ ClaimPackageExporter - NOT WIRED
✓ ClaimTrackingService - wired
✗ ClaimValidationService - NOT WIRED
✗ CloudStorageServices - NOT WIRED
✗ DependencyKeys - NOT WIRED
✗ InsuranceClaimCore - NOT WIRED
✗ InsuranceClaimModels - NOT WIRED
✗ InsuranceClaimService - NOT WIRED
✗ InsuranceClaimValidation - NOT WIRED
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
./Features/Search/SearchFeature.swift:    // TODO: P0.1.4 - Add searchHistoryService to DependencyKeys.swift
./App-Main/BarcodeScannerView.swift:            // TODO: P0.1.4 - Fix BarcodeScannerService protocol to include errorMessage
./App-Main/BarcodeScannerView.swift:                    // TODO: P0.1.4 - Fix BarcodeScannerService protocol
./App-Main/BarcodeScannerView.swift:                // TODO: P0.1.4 - Fix BarcodeScannerService protocol

## Git Status
 M .claude/settings.local.json
 M CURRENT_CONTEXT.md
 M Features/Analytics/AnalyticsFeature.swift
 M Services/ClaimExport/ClaimExportCore.swift
 M Services/ClaimExport/ClaimExportValidators.swift
 M Services/ClaimExportService.swift
 M Services/ClaimPackageAssemblerService.swift
 M Services/DependencyKeys.swift
 M Services/InsuranceClaimModels.swift
 M TREE.md
 D Tests/UI/ContentViewTests.swift
?? Services/AuthService/
?? Services/Dependencies/
?? Services/ExportService/
?? Services/SyncService/

## Last Commit
8ed8815 feat: complete TCA migration and project cleanup with automated build artifact management
