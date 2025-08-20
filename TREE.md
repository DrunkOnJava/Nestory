# Project Structure

_Last updated: 2025-08-20 03:42:39_

```
[01;34m.[0m
├── [01;34mApp-Main[0m
│   ├── [01;34mAnalyticsViews[0m
│   │   ├── AnalyticsCharts.swift
│   │   ├── AnalyticsDataProvider.swift
│   │   ├── InsightsView.swift
│   │   └── SummaryCardsView.swift
│   ├── [01;34mAssets.xcassets[0m
│   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   ├── [01;35mAppIcon-1024.0x1024.0@1x.png[0m
│   │   │   ├── [01;35mAppIcon-20.0x20.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-20.0x20.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-29.0x29.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-29.0x29.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-38.0x38.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-38.0x38.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-40.0x40.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-40.0x40.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-60.0x60.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-60.0x60.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-64.0x64.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-64.0x64.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-68.0x68.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-76.0x76.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-83.5x83.5@2x.png[0m
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── [01;34mBarcodeScannerViews[0m
│   │   ├── CameraScannerView.swift
│   │   ├── ScanningTipsView.swift
│   │   ├── ScanOptionsView.swift
│   │   └── ScanResultView.swift
│   ├── [01;34mItemConditionViews[0m
│   │   ├── ConditionModels.swift
│   │   ├── ConditionNotesView.swift
│   │   ├── ConditionPhotoManagementView.swift
│   │   └── ConditionSelectionView.swift
│   ├── [01;34mPreview Content[0m
│   │   └── [01;34mPreviewAssets.xcassets[0m
│   │       └── Contents.json
│   ├── [01;34mSearchViews[0m
│   │   ├── SearchFilterView.swift
│   │   ├── SearchHistoryView.swift
│   │   ├── SearchModels.swift
│   │   └── SearchResultsView.swift
│   ├── [01;34mSettingsViews[0m
│   │   ├── AboutSupportSettingsView.swift
│   │   ├── AppearanceSettingsView.swift
│   │   ├── CloudBackupSettingsView.swift
│   │   ├── DangerZoneSettingsView.swift
│   │   ├── DataStorageSettingsView.swift
│   │   ├── ExportOptionsView.swift
│   │   ├── GeneralSettingsView.swift
│   │   ├── ImportExportSettingsView.swift
│   │   ├── InsuranceReportOptionsView.swift
│   │   ├── NotificationSettingsView.swift
│   │   ├── PrivacyPolicyView.swift
│   │   └── TermsOfServiceView.swift
│   ├── [01;34mViewModels[0m
│   │   ├── AdvancedSearchViewModel.swift
│   │   └── InventoryListViewModel.swift
│   ├── [01;34mWarrantyViews[0m
│   │   ├── DocumentManagementView.swift
│   │   ├── LocationManagementView.swift
│   │   ├── WarrantyManagementView.swift
│   │   ├── WarrantyStatusCalculator.swift
│   │   └── WarrantySubviews.swift
│   ├── AddItemView.swift
│   ├── AdvancedSearchView.swift
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
│   ├── ManualBarcodeEntryView.swift
│   ├── Nestory.entitlements
│   ├── NestoryApp.swift
│   ├── PhotoCaptureView.swift
│   ├── PhotoPicker.swift
│   ├── ReceiptCaptureView.swift
│   ├── SearchView.swift
│   ├── SettingsView.swift
│   ├── SingleItemInsuranceReportView.swift
│   ├── ThemeManager.swift
│   └── WarrantyDocumentsView.swift
├── [01;34mApp-Widgets[0m
├── [01;34mArchive[0m
│   ├── [01;34mFuture-Features[0m
│   │   └── [01;34mSyncService[0m
│   │       ├── BGTaskRegistrar.swift
│   │       ├── ConflictResolver.swift
│   │       └── SyncService.swift
│   ├── [01;34mModels[0m
│   │   ├── CurrencyRate.swift
│   │   ├── Location.swift
│   │   ├── MaintenanceTask.swift
│   │   ├── PhotoAsset.swift
│   │   ├── SchemaVersion.swift
│   │   └── ShareGroup.swift
│   ├── [01;34mServices[0m
│   │   └── [01;34mAuthentication[0m
│   │       ├── AuthError.swift
│   │       └── AuthService.swift
│   └── [01;34mTCA-Migration[0m
│       ├── [01;34mApp-Main.backup[0m
│       │   ├── RootFeature.swift
│       │   └── RootView.swift
│       ├── [01;34mFeatures.backup[0m
│       │   └── [01;34mInventory[0m
│       │       ├── InventoryFeature.swift
│       │       ├── InventoryView.swift
│       │       ├── ItemDetailFeature.swift
│       │       └── ItemEditFeature.swift
│       └── DependencyKeys.swift.backup
├── [01;34mConfig[0m
│   ├── [01;34mStoreKit[0m
│   │   └── StoreKitConfiguration.storekit
│   ├── Base.xcconfig
│   ├── CONFIGURATION_SYSTEM.md
│   ├── Debug.xcconfig
│   ├── Dev.xcconfig
│   ├── Development.xcconfig
│   ├── EnvironmentConfiguration.swift
│   ├── FeatureFlags.swift
│   ├── flags.json
│   ├── MakefileConfig.mk
│   ├── Optimization.xcconfig
│   ├── Prod.xcconfig
│   ├── Production.xcconfig
│   ├── ProjectConfiguration.json
│   ├── Release.xcconfig
│   ├── Rings-Generated.md
│   ├── Rings.md
│   ├── Secrets.template.swift
│   └── Staging.xcconfig
├── [01;34mDevTools[0m
│   ├── [01;34mnestoryctl[0m
│   │   ├── [01;34mSources[0m
│   │   │   └── [01;34mNestoryCtl[0m
│   │   │       └── main.swift
│   │   ├── Package.resolved
│   │   └── Package.swift
│   └── [01;32minstall_hooks.sh[0m
├── [01;34mfastlane[0m
│   ├── [01;34mfastlane[0m
│   │   └── [01;34moutput[0m
│   ├── [01;34mmetadata[0m
│   │   └── [01;34men-US[0m
│   │       ├── description.txt
│   │       ├── keywords.txt
│   │       ├── marketing_url.txt
│   │       ├── privacy_url.txt
│   │       ├── promotional_text.txt
│   │       ├── release_notes.txt
│   │       ├── subtitle.txt
│   │       └── support_url.txt
│   ├── [01;34moutput[0m
│   │   ├── [01;34mbuild3[0m
│   │   │   ├── DistributionSummary.plist
│   │   │   └── ExportOptions.plist
│   │   ├── [01;34mlogs[0m
│   │   │   └── [01;34mtests[0m
│   │   └── [01;34mtests[0m
│   │       └── [01;34mNestory-Dev.xcresult[0m
│   │           ├── [01;34mData[0m
│   │           │   ├── data.0~0OJxWWtGY-zr25VnCJoPb1n6Di9tm62yk9FviKzcEHE85aXbZghhZPs_w9SFXDzR4sH1udFAD9gP1O4IfRZGkA==
│   │           │   ├── data.0~3tdcR6bwWxdzU22qUxcKe3glLeiYH8_XaDCQvx9TbExlAgQti1qiRQMlvHkmkDeb8RlcrUaKL8To60JB7E1wdA==
│   │           │   ├── data.0~578N-L_gaTNsJ7gT4RM5cvYXRwYcQpJ_u-UvQi8ytwWD_sXErhZ9BBtTaWZI64jrEFJfCl1Y-WfV8-mO9Sg_oA==
│   │           │   ├── data.0~fjD_EX2aNa694oPlo4aGCPpleUfl3REDSm29jV6RGMDpRKu5rb6jM4srwAhe_d5VyoPCuxbddDC-8R_x7VTuUQ==
│   │           │   ├── data.0~fRjyAQsrS_YSYArimuF5HY5x1BAMQ4TAGuyYeD1ENUjqadCd8pQ-dDPX-dRssvIqcOTkMAGe79Vq8jo4E_Q9-Q==
│   │           │   ├── data.0~GGroomo68b3K0-heFAojL-p6UJ4pRPONKB-y51tOeZ_EHYEvneBO0lFkGYgzHU1WGEY0I9rSL5m1aikTZUMSoA==
│   │           │   ├── data.0~hYMQYJyPXImzVg0lrUKwju6tVsbgyeUrgfwGWmJDwNz64GZLgr5HHprGipLnl2AsFJz3R7fjD35U8gUICYUWUg==
│   │           │   ├── data.0~NpW2WyDhbkgxunncA9g24p8Y8riKmudWzPbYsfsUJYDjfXbey5hRlk4ZWut-da-jsZtPkRA7doC3SXRPUH2xdw==
│   │           │   ├── data.0~olfqdW6Fk7j5wZoo6NgSVSGJWMCEb2fe4CPr-JXQGKggLmnZX8DYSGzgvg4FykUOId9AVmVUkiQKSwU1gFCu2A==
│   │           │   ├── data.0~tt3uRgNHIvT41tRHt_XFvpruZr3IqspblC425EUZYNkhu9Nf32b7L6z_pZz8nLXbVvZ5kZhrdCv62GLFop1ufw==
│   │           │   ├── refs.0~0OJxWWtGY-zr25VnCJoPb1n6Di9tm62yk9FviKzcEHE85aXbZghhZPs_w9SFXDzR4sH1udFAD9gP1O4IfRZGkA==
│   │           │   ├── refs.0~3tdcR6bwWxdzU22qUxcKe3glLeiYH8_XaDCQvx9TbExlAgQti1qiRQMlvHkmkDeb8RlcrUaKL8To60JB7E1wdA==
│   │           │   ├── refs.0~578N-L_gaTNsJ7gT4RM5cvYXRwYcQpJ_u-UvQi8ytwWD_sXErhZ9BBtTaWZI64jrEFJfCl1Y-WfV8-mO9Sg_oA==
│   │           │   ├── refs.0~fjD_EX2aNa694oPlo4aGCPpleUfl3REDSm29jV6RGMDpRKu5rb6jM4srwAhe_d5VyoPCuxbddDC-8R_x7VTuUQ==
│   │           │   ├── refs.0~fRjyAQsrS_YSYArimuF5HY5x1BAMQ4TAGuyYeD1ENUjqadCd8pQ-dDPX-dRssvIqcOTkMAGe79Vq8jo4E_Q9-Q==
│   │           │   ├── refs.0~GGroomo68b3K0-heFAojL-p6UJ4pRPONKB-y51tOeZ_EHYEvneBO0lFkGYgzHU1WGEY0I9rSL5m1aikTZUMSoA==
│   │           │   ├── refs.0~hYMQYJyPXImzVg0lrUKwju6tVsbgyeUrgfwGWmJDwNz64GZLgr5HHprGipLnl2AsFJz3R7fjD35U8gUICYUWUg==
│   │           │   ├── refs.0~NpW2WyDhbkgxunncA9g24p8Y8riKmudWzPbYsfsUJYDjfXbey5hRlk4ZWut-da-jsZtPkRA7doC3SXRPUH2xdw==
│   │           │   ├── refs.0~olfqdW6Fk7j5wZoo6NgSVSGJWMCEb2fe4CPr-JXQGKggLmnZX8DYSGzgvg4FykUOId9AVmVUkiQKSwU1gFCu2A==
│   │           │   └── refs.0~tt3uRgNHIvT41tRHt_XFvpruZr3IqspblC425EUZYNkhu9Nf32b7L6z_pZz8nLXbVvZ5kZhrdCv62GLFop1ufw==
│   │           └── Info.plist
│   ├── [01;34mscreenshots[0m
│   │   ├── [01;34men-US[0m
│   │   └── screenshots.html
│   ├── Deliverfile
│   ├── ExportOptions.plist
│   ├── Fastfile
│   ├── Pluginfile
│   ├── rating_config.json
│   ├── README.md
│   ├── report.xml
│   ├── Snapfile
│   ├── upload_direct.rb
│   └── upload_testflight.rb
├── [01;34mFoundation[0m
│   ├── [01;34mCore[0m
│   │   ├── [01;34mConstants[0m
│   │   │   ├── BusinessConstants.swift
│   │   │   ├── CacheConstants.swift
│   │   │   ├── Constants.swift
│   │   │   ├── NetworkConstants.swift
│   │   │   ├── PDFConstants.swift
│   │   │   ├── TestConstants.swift
│   │   │   └── UIConstants.swift
│   │   ├── BundleConfiguration.swift
│   │   ├── ErrorLogger.swift
│   │   ├── ErrorRecoveryStrategy.swift
│   │   ├── Errors.swift
│   │   ├── Identifiers.swift
│   │   ├── Money.swift
│   │   ├── NonEmptyString.swift
│   │   ├── RetryStrategy.swift
│   │   ├── ServiceError.swift
│   │   └── Slug.swift
│   ├── [01;34mModels[0m
│   │   ├── Category.swift
│   │   ├── Item.swift
│   │   ├── Receipt.swift
│   │   ├── Room.swift
│   │   └── Warranty.swift
│   ├── [01;34mResources[0m
│   │   └── Fixtures.json
│   └── [01;34mUtils[0m
│       ├── CurrencyUtils.swift
│       ├── DateUtils.swift
│       └── Validation.swift
├── [01;34mInfrastructure[0m
│   ├── [01;34mActors[0m
│   │   └── NotificationActor.swift
│   ├── [01;34mCache[0m
│   │   ├── CacheEncoder.swift
│   │   ├── CacheSizeManager.swift
│   │   ├── DiskCache.swift
│   │   ├── MemoryCache.swift
│   │   └── SmartCache.swift
│   ├── [01;34mCamera[0m
│   │   └── CameraScannerViewController.swift
│   ├── [01;34mHotReload[0m
│   │   ├── DynamicLoader.swift
│   │   ├── InjectionClient.swift
│   │   ├── InjectionCompiler.swift
│   │   ├── InjectionOrchestrator.swift
│   │   └── InjectionServer.swift
│   ├── [01;34mMonitoring[0m
│   │   ├── Log.swift
│   │   ├── LogContext.swift
│   │   ├── LogSpecializedOperations.swift
│   │   ├── MetricKitCollector.swift
│   │   ├── PerformanceMonitor.swift
│   │   └── Signpost.swift
│   ├── [01;34mNetwork[0m
│   │   ├── Endpoint.swift
│   │   ├── HTTPClient.swift
│   │   ├── NetworkClient.swift
│   │   └── NetworkError.swift
│   ├── [01;34mPerformance[0m
│   │   ├── PerformanceBaselines.swift
│   │   └── PerformanceProfiler.swift
│   ├── [01;34mSecurity[0m
│   │   ├── CryptoBox.swift
│   │   ├── KeychainStore.swift
│   │   └── SecureEnclaveHelper.swift
│   └── [01;34mStorage[0m
│       ├── Cache.swift
│       ├── FileStore.swift
│       ├── ImageIO.swift
│       ├── PerceptualHash.swift
│       ├── SecureStorage.swift
│       └── Thumbnailer.swift
├── [01;34mNestory.xcodeproj[0m
│   ├── [01;34mNestory.xcodeproj[0m
│   │   ├── [01;34mxcshareddata[0m
│   │   │   └── [01;34mxcschemes[0m
│   │   │       └── Nestory-Dev.xcscheme
│   │   └── project.pbxproj
│   ├── [01;34mxcshareddata[0m
│   │   └── [01;34mxcschemes[0m
│   │       ├── Nestory-Dev.xcscheme
│   │       ├── Nestory-Prod.xcscheme
│   │       └── Nestory-Staging.xcscheme
│   └── project.pbxproj
├── [01;34mNestoryTests[0m
│   ├── [01;34mInfrastructure[0m
│   │   ├── MonitoringTests.swift
│   │   ├── NetworkTests.swift
│   │   ├── SecurityTests.swift
│   │   └── StorageTests.swift
│   └── NestoryTests.swift
├── [01;34mNestoryUITests[0m
│   ├── [01;34mBase[0m
│   │   └── NestoryUITestBase.swift
│   ├── [01;34mExtensions[0m
│   │   ├── XCTestCase+Helpers.swift
│   │   └── XCUIElement+Helpers.swift
│   ├── [01;34mHelpers[0m
│   │   ├── NavigationHelper.swift
│   │   ├── NavigationHelpers.swift
│   │   ├── ScreenshotManager.swift
│   │   └── UITestHelpers.swift
│   └── [01;34mTests[0m
│       ├── ComprehensiveUIFlowTests.swift
│       └── FeatureWiringAuditTests.swift
├── [01;34mScripts[0m
│   ├── [01;32mcheck-file-sizes.sh[0m
│   ├── [01;32mconfigure_app_store_connect.rb[0m
│   ├── [01;32mdev_cycle.sh[0m
│   ├── [01;32mdev_stats.sh[0m
│   ├── [01;32mfinalize_bundle_identifier_update.sh[0m
│   ├── [01;32mgenerate-project-config.swift[0m
│   ├── [01;32mios_simulator_automation.applescript[0m
│   ├── [01;32mmanage-file-size-overrides.sh[0m
│   ├── nestory_aliases.sh
│   ├── [01;32moptimize_xcode_workflow.sh[0m
│   ├── [01;32mquick_build.sh[0m
│   ├── [01;32mquick_test.sh[0m
│   ├── README.md
│   ├── [01;32mrun_fastlane_screenshots.sh[0m
│   ├── [01;32mrun_simulator_automation.sh[0m
│   ├── [01;32msetup_asc_credentials.sh[0m
│   ├── [01;32mupdate_bundle_identifiers.sh[0m
│   └── [01;32mverify_app_store_setup.sh[0m
├── [01;34mServices[0m
│   ├── [01;34mAnalyticsService[0m
│   │   ├── AnalyticsCurrencyOperations.swift
│   │   ├── AnalyticsModels.swift
│   │   ├── AnalyticsService.swift
│   │   ├── AnalyticsServiceError.swift
│   │   ├── LiveAnalyticsService.swift
│   │   └── MockAnalyticsService.swift
│   ├── [01;34mAppStoreConnect[0m
│   │   ├── AppMetadataService.swift
│   │   ├── AppStoreConnectClient.swift
│   │   ├── AppStoreConnectConfiguration.swift
│   │   ├── AppStoreConnectOrchestrator.swift
│   │   ├── AppStoreConnectTypes.swift
│   │   ├── AppVersionModels.swift
│   │   ├── AppVersionOperations.swift
│   │   ├── AppVersionService.swift
│   │   ├── EncryptionDeclarationService.swift
│   │   ├── MediaUploadModels.swift
│   │   ├── MediaUploadOperations.swift
│   │   └── MediaUploadService.swift
│   ├── [01;34mBarcodeScannerService[0m
│   │   ├── BarcodeScannerService.swift
│   │   ├── LiveBarcodeScannerService.swift
│   │   └── MockBarcodeScannerService.swift
│   ├── [01;34mCloudBackupService[0m
│   │   ├── BackupDataTransformer.swift
│   │   ├── BackupModels.swift
│   │   ├── CloudBackupService.swift
│   │   ├── CloudKitAssetManager.swift
│   │   ├── CloudKitBackupOperations.swift
│   │   ├── LiveCloudBackupService.swift
│   │   ├── MockCloudBackupService.swift
│   │   └── RestoreDataTransformer.swift
│   ├── [01;34mCurrencyService[0m
│   │   └── CurrencyService.swift
│   ├── [01;34mImportExportService[0m
│   │   ├── CSVOperations.swift
│   │   ├── ImportExportModels.swift
│   │   ├── ImportExportService.swift
│   │   ├── JSONOperations.swift
│   │   ├── LiveImportExportService.swift
│   │   └── MockImportExportService.swift
│   ├── [01;34mInsuranceExport[0m
│   │   ├── DataFormatHelpers.swift
│   │   ├── HTMLTemplateGenerator.swift
│   │   ├── SpreadsheetExporter.swift
│   │   ├── StandardFormExporter.swift
│   │   └── XMLExporter.swift
│   ├── [01;34mInsuranceReport[0m
│   │   ├── PDFReportGenerator.swift
│   │   ├── ReportDataFormatter.swift
│   │   ├── ReportExportManager.swift
│   │   └── ReportSectionDrawer.swift
│   ├── [01;34mInventoryService[0m
│   │   ├── InventoryService.swift
│   │   └── PhotoIntegration.swift
│   ├── [01;34mNotificationService[0m
│   │   ├── LiveNotificationService.swift
│   │   ├── MockNotificationService.swift
│   │   ├── NotificationManagement.swift
│   │   ├── NotificationOtherOperations.swift
│   │   ├── NotificationService.swift
│   │   ├── NotificationServiceError.swift
│   │   └── NotificationWarrantyOperations.swift
│   ├── [01;34mReceiptOCR[0m
│   │   ├── ReceiptDataParser.swift
│   │   ├── ReceiptItemExtractor.swift
│   │   └── VisionTextExtractor.swift
│   ├── InsuranceExportService.swift
│   ├── InsuranceReportService.swift
│   └── ReceiptOCRService.swift
├── [01;34mSources[0m
│   └── [01;34mNestoryGuards[0m
│       └── NestoryGuards.swift
├── [01;34mTests[0m
│   ├── [01;34mArchitectureTests[0m
│   │   └── ArchitectureTests.swift
│   ├── [01;34mIntegration[0m
│   ├── [01;34mPerformance[0m
│   │   ├── baselines.json
│   │   └── BatchOperationsPerformanceTests.swift
│   ├── [01;34mServices[0m
│   │   ├── AnalyticsServiceTests.swift
│   │   ├── AuthServiceTests.swift
│   │   ├── CloudBackupServiceTests.swift
│   │   ├── ComprehensiveServiceTests.swift
│   │   ├── CurrencyServiceTests.swift
│   │   ├── ImportExportServiceTests.swift
│   │   ├── InventoryServiceTests.swift
│   │   ├── NotificationServiceTests.swift
│   │   └── SyncServiceTests.swift
│   ├── [01;34mSnapshot[0m
│   │   └── SnapshotTests.swift
│   ├── [01;34mTestSupport[0m
│   │   ├── ServiceMocks.swift
│   │   └── UITestHelpers.swift
│   ├── [01;34mUI[0m
│   │   ├── AccessibilityTests.swift
│   │   ├── AddItemViewTests.swift
│   │   ├── ContentViewTests.swift
│   │   ├── InventoryListViewTests.swift
│   │   ├── ItemDetailViewTests.swift
│   │   └── SettingsViewTests.swift
│   ├── [01;34mUnit[0m
│   │   └── [01;34mFoundation[0m
│   │       ├── IdentifierTests.swift
│   │       ├── ModelInvariantTests.swift
│   │       ├── MoneyTests.swift
│   │       └── TestHelpers.swift
│   └── TestConfiguration.swift
├── [01;34mtools[0m
│   └── [01;34mdev[0m
│       ├── [01;32mboot_sim.sh[0m
│       ├── [01;32mbuild_install_run.sh[0m
│       ├── [01;32mconfigure_iterm_links.sh[0m
│       ├── [01;32mensure_swift6.sh[0m
│       ├── [01;32minjection_coordinator.sh[0m
│       ├── [01;32minstall_injection.sh[0m
│       ├── iterm_multiline_links.md
│       ├── [01;32mprepare_injection.sh[0m
│       ├── [01;32mreset_and_verify.sh[0m
│       ├── [01;32mtail_logs.sh[0m
│       └── [01;32mtest_hot_reload.sh[0m
├── [01;34mUI[0m
│   ├── [01;34mComponents[0m
│   │   ├── ExportOptionsView.swift
│   │   ├── InsuranceReportOptionsView.swift
│   │   ├── ManualBarcodeEntryView.swift
│   │   └── PhotoPicker.swift
│   ├── [01;34mPerformance[0m
│   │   └── UIPerformanceOptimizer.swift
│   ├── [01;34mUI-Components[0m
│   │   ├── DocumentScannerView.swift
│   │   ├── EmptyStateView.swift
│   │   ├── ItemCard.swift
│   │   ├── PrimaryButton.swift
│   │   └── SearchBar.swift
│   ├── [01;34mUI-Core[0m
│   │   ├── Extensions.swift
│   │   ├── Theme.swift
│   │   └── Typography.swift
│   └── [01;34mUI-Styles[0m
├── app_store_connect_api_openapi.json
├── APP_STORE_CONNECT_API.md
├── APP_STORE_SUBMISSION_GUIDE.md
├── [01;35mAppIcon.png[0m
├── APPLESCRIPT_IOS_SIMULATOR_NAVIGATION.md
├── ARCHAEOLOGICAL_LAYERS.md
├── ARCHITECTURE_STATUS.md
├── AuthKey_NWV654RNK3.p8
├── Build Nestory-Dev_2025-08-20T02-02-05.txt
├── Build Nestory-Prod_2025-08-20T02-01-06.txt
├── Build Nestory-Staging_2025-08-20T02-03-00.txt
├── BUILD_INSTRUCTIONS.md
├── BUILD_STATUS.md
├── build_with_swift6.sh
├── build.sh
├── [01;32mcheck_environment.sh[0m
├── CLAUDE.md
├── CURRENT_CONTEXT.md
├── DECISIONS.md
├── DEVELOPMENT_CHECKLIST.md
├── emergency_fix.sh
├── EXPORT_COMPLIANCE.md
├── [01;32mfix_build.sh[0m
├── [01;35mfrustratingResults.jpg[0m
├── Gemfile
├── Gemfile.lock
├── [01;32mgenerate_app_icons.sh[0m
├── HOT_RELOAD_AUDIT_REPORT.md
├── HOT_RELOAD_DOCUMENTATION.md
├── LICENSE
├── LINTING.md
├── Makefile
├── manual_navigation_test.swift
├── [01;32mmetrics.sh[0m
├── MODULARIZATION_PLAN.md
├── move_models.sh
├── [01;31mnestory_prompt_pack.zip[0m
├── [01;35mNestory-Add-Item.png[0m
├── [01;35mNestory-After-Cmd5.png[0m
├── [01;35mNestory-After-Plus.png[0m
├── [01;35mNestory-After-Settings-Click.png[0m
├── [01;35mNestory-Current.png[0m
├── [01;35mNestory-Main.png[0m
├── [01;35mNestory-Settings-Before.png[0m
├── [01;35mNestory-Settings-Tab.png[0m
├── [01;35mNestory-Settings.png[0m
├── Observability.md
├── open_xcode.sh
├── optimization_report.html
├── Package.resolved
├── Package.swift
├── PERFORMANCE_OPTIMIZATION_SUMMARY.md
├── PHASE2_COMPLETION_REPORT.md
├── PRIVACY_POLICY.md
├── [01;32mprocess_app_icon.sh[0m
├── PROJECT_CONTEXT.md
├── project-uitests.yml
├── project.yml
├── quick_build.sh
├── README.md
├── RESONANCE.txt
├── run_app_final.sh
├── run_app.sh
├── [01;32mrun_screenshots.sh[0m
├── SCREENSHOTS.md
├── [01;32msetup_auto_tree.sh[0m
├── SPEC_CHANGE.md
├── SPEC.json
├── SPEC.lock
├── SWIFT6_UITEST_MIGRATION.md
├── swiftlint_violations.json
├── THIRD_PARTY_LICENSES.md
├── TODO.md
├── TREE.md
├── [01;32mupdate_tree.sh[0m
├── [01;32mupload_to_testflight.sh[0m
├── verify_build.sh
└── XCODE_FIX.md

107 directories, 447 files
```

_📁 Directories:  | 📄 Files: 
