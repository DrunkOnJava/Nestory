# Nestory Project Context
Generated: Sun Aug 10 09:50:24 EDT 2025

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
- ReceiptOCRService.swift

## UI Views
- AddItemView.swift
- AnalyticsDashboardView.swift
- BarcodeScannerView.swift
- CategoriesView.swift
- ContentView.swift
- EditItemView.swift
- InventoryListView.swift
- ItemDetailView.swift
- PhotoCaptureView.swift
- ReceiptCaptureView.swift
- SearchView.swift
- SettingsView.swift
- WarrantyDocumentsView.swift

## Models
- Category.swift
- Item.swift
- Room.swift

## Wiring Status
✓ BarcodeScannerService - wired
✓ CloudBackupService - wired
✓ ImportExportService - wired
✗ InsuranceExportService - NOT WIRED
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
./Features.backup/Inventory/InventoryFeature.swift:            // TODO: Implement with SwiftData

## Git Status
 M CLAUDE.md
 M Config/FeatureFlags.swift
 M Config/Secrets.template.swift
 M DECISIONS.md
 M Makefile
 M Nestory/Infrastructure/Storage/FileStore.swift
 M PROJECT_CONTEXT.md
 M README.md
 M project.yml
?? App-Main.backup/
?? App-Main/
?? BUILD_INSTRUCTIONS.md
?? CURRENT_CONTEXT.md
?? Config/StoreKit/
?? DEVELOPMENT_CHECKLIST.md
?? Features.backup/
?? Foundation/
?? Infrastructure/
?? Services.backup/
?? Services/
?? UI/
?? build.sh
?? emergency_fix.sh
?? fix_build.sh
?? frustratingResults.jpg
?? move_models.sh
?? open_xcode.sh
?? quick_build.sh
?? run_app.sh
?? run_app_final.sh
?? update_tree.sh
?? verify_build.sh

## Last Commit
af14b0a feat: initial Nestory project setup
