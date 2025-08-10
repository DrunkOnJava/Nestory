# Nestory Modularization Plan

## Overview
This document outlines the modularization strategy for files exceeding our code quality thresholds (400/500/600 lines). The goal is to improve maintainability, testability, and code organization.

## Priority Classification
- 🔴 **CRITICAL** (600+ lines): Build-blocking, must be fixed immediately
- 🟠 **HIGH** (500-599 lines): Should be modularized soon
- 🟡 **MEDIUM** (400-499 lines): Consider modularizing when touched

---

## 🔴 CRITICAL: SettingsView.swift (757 lines)

### Current Structure
A monolithic view containing all settings sections in one file.

### Modularization Strategy
Break into focused section views under `App-Main/SettingsViews/`:

1. **ProfileSettingsView** (~100 lines)
   - User profile management
   - Display name, email, avatar
   - Account preferences

2. **ImportExportSettingsView** (~120 lines)
   - CSV/JSON import functionality
   - Export options and formats
   - Bulk operations UI

3. **BackupSettingsView** (~130 lines)
   - CloudKit backup settings
   - Backup frequency options
   - Restore functionality

4. **NotificationSettingsView** (~100 lines)
   - Warranty expiration alerts
   - Insurance renewal reminders
   - Push notification preferences

5. **PrivacySettingsView** (~90 lines)
   - Data privacy controls
   - Biometric authentication
   - Data retention settings

6. **AboutSettingsView** (~80 lines)
   - App version info
   - Terms of service
   - Support links

**Main SettingsView**: ~137 lines (orchestrator)

---

## 🟠 HIGH PRIORITY

### BarcodeScannerView.swift (539 lines)

**Target Structure** - `App-Main/BarcodeScannerViews/`:

1. **CameraPreviewView** (~150 lines)
   - AVCaptureSession management
   - Camera preview layer
   - Focus/exposure controls

2. **ScanOverlayView** (~80 lines)
   - Scanning UI overlay
   - Guide frames and animations
   - Scan status indicators

3. **BarcodeDelegate** (~100 lines)
   - AVCaptureMetadataOutputObjectsDelegate
   - Barcode processing logic
   - Validation and formatting

4. **ProductLookupView** (~120 lines)
   - Product information display
   - API lookup results
   - Manual entry fallback

**Main View**: ~89 lines

### InsuranceExportService.swift (510 lines)

**Target Structure** - `Services/InsuranceExport/`:

1. **InsurancePDFGenerator** (~180 lines)
   - PDF creation logic
   - Layout and formatting
   - Image embedding

2. **InsuranceCSVExporter** (~120 lines)
   - CSV generation
   - Field mapping
   - Escaping and formatting

3. **InsuranceHTMLGenerator** (~130 lines)
   - HTML template generation
   - Styling and structure
   - Interactive elements

**Main Service**: ~80 lines (coordinator)

---

## 🟡 MEDIUM PRIORITY

### CloudBackupService.swift (477 lines)

**Target Structure** - `Services/CloudBackup/`:

1. **CloudBackupOperations** (~160 lines)
   - Core CloudKit operations
   - Record management
   - Zone configuration

2. **CloudBackupScheduler** (~120 lines)
   - Backup scheduling logic
   - Background task management
   - Throttling and rate limiting

3. **CloudBackupConflictResolver** (~100 lines)
   - Conflict resolution strategies
   - Merge logic
   - Version management

### InsuranceReportService.swift (468 lines)

**Target Structure** - `Services/InsuranceReport/`:

1. **InsuranceReportGenerator** (~160 lines)
   - Report generation logic
   - Data aggregation
   - Calculations

2. **InsuranceReportTemplates** (~150 lines)
   - Report templates
   - Formatting rules
   - Customization options

3. **InsuranceReportFormatter** (~100 lines)
   - Output formatting
   - Export preparation
   - Validation

### WarrantyDocumentsView.swift (464 lines)

**Target Structure** - `App-Main/WarrantyViews/`:

1. **WarrantyCard** (~140 lines)
   - Individual warranty display
   - Status indicators
   - Quick actions

2. **WarrantyFiltersView** (~110 lines)
   - Filter controls
   - Sort options
   - Search functionality

3. **WarrantyStatsView** (~100 lines)
   - Statistics dashboard
   - Expiration summaries
   - Coverage insights

### AnalyticsDashboardView.swift (454 lines)

**Target Structure** - `App-Main/AnalyticsViews/`:

1. **ValueChartView** (~150 lines)
   - Value over time charts
   - Chart controls
   - Data visualization

2. **CategoryBreakdownView** (~120 lines)
   - Category distribution
   - Pie/bar charts
   - Drill-down capability

3. **InsightCardsView** (~100 lines)
   - Key metrics cards
   - Trend indicators
   - Recommendations

### ReceiptOCRService.swift (442 lines)

**Target Structure** - `Services/ReceiptOCR/`:

1. **ReceiptTextRecognition** (~150 lines)
   - Vision framework integration
   - Text extraction
   - Language detection

2. **ReceiptDataParser** (~140 lines)
   - Receipt parsing logic
   - Field identification
   - Data validation

3. **ReceiptImageProcessor** (~100 lines)
   - Image preprocessing
   - Enhancement filters
   - Orientation correction

### Cache.swift (406 lines)

**Target Structure** - `Infrastructure/Cache/`:

1. **CachePolicy** (~80 lines)
   - Expiration policies
   - Size limits
   - Eviction strategies

2. **CacheStorage** (~180 lines)
   - Storage implementation
   - Persistence layer
   - Memory management

3. **CacheMetrics** (~90 lines)
   - Hit/miss tracking
   - Performance metrics
   - Usage statistics

---

## Implementation Order

### Phase 1: Unblock Builds (Week 1)
1. ✅ Modularize SettingsView.swift (CRITICAL)
2. Create SettingsViews directory structure
3. Test all settings functionality

### Phase 2: High Priority (Week 2)
1. Modularize BarcodeScannerView.swift
2. Modularize InsuranceExportService.swift
3. Ensure all camera and export features work

### Phase 3: Services Cleanup (Week 3)
1. CloudBackupService modularization
2. InsuranceReportService modularization
3. ReceiptOCRService modularization

### Phase 4: Views Cleanup (Week 4)
1. WarrantyDocumentsView modularization
2. AnalyticsDashboardView modularization
3. Cache.swift infrastructure cleanup

---

## Success Metrics

- ✅ No files exceed 600 lines (build-blocking threshold)
- ✅ Minimize files exceeding 500 lines (critical threshold)
- ✅ Reduce files exceeding 400 lines (warning threshold)
- ✅ Maintain 100% feature parity after modularization
- ✅ Improve test coverage with focused unit tests
- ✅ Enhance code reusability and maintainability

---

## Testing Strategy

For each modularized component:
1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Verify components work together
3. **UI Tests**: Ensure user workflows remain intact
4. **Regression Tests**: Verify no functionality is lost

---

## Notes

- Each modularization should be a separate PR for easier review
- Update imports and dependencies carefully
- Maintain backward compatibility where possible
- Document any API changes in DECISIONS.md
- Run `make check-file-sizes` after each modularization to verify progress