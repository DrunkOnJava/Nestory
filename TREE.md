# Project Structure

_Last updated: 2025-08-23 03:23:19_

```
[01;34m.[0m
├── [01;34mApp-Main[0m
│   ├── [01;34mAnalyticsViews[0m
│   │   ├── AnalyticsCharts.swift
│   │   ├── AnalyticsDataProvider.swift
│   │   ├── EnhancedAnalyticsSummaryView.swift
│   │   ├── EnhancedInsightsView.swift
│   │   └── InsightsView.swift
│   ├── [01;34mAssets.xcassets[0m
│   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   ├── [01;35mAppIcon-1024.0x1024.0@1x.png[0m
│   │   │   ├── [01;35mAppIcon-20.0x20.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-20.0x20.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-29.0x29.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-29.0x29.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-40.0x40.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-40.0x40.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-60.0x60.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-60.0x60.0@3x.png[0m
│   │   │   ├── [01;35mAppIcon-76.0x76.0@2x.png[0m
│   │   │   ├── [01;35mAppIcon-83.5x83.5@2x.png[0m
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── [01;34mBarcodeScannerViews[0m
│   │   ├── CameraScannerView.swift
│   │   ├── ScanningTipsView.swift
│   │   ├── ScanOptionsView.swift
│   │   └── ScanResultView.swift
│   ├── [01;34mClaimPackageAssemblyView[0m
│   │   ├── [01;34mComponents[0m
│   │   │   ├── ClaimItemRow.swift
│   │   │   └── ValidationCheckRow.swift
│   │   ├── [01;34mSteps[0m
│   │   │   ├── [01;34mAssembly[0m
│   │   │   │   ├── AssemblyErrorView.swift
│   │   │   │   ├── AssemblyProgressView.swift
│   │   │   │   ├── AssemblyStepView.swift
│   │   │   │   └── AssemblySuccessView.swift
│   │   │   ├── [01;34mExport[0m
│   │   │   │   ├── ExportReadyView.swift
│   │   │   │   ├── ExportStepView.swift
│   │   │   │   └── ExportUnavailableView.swift
│   │   │   ├── [01;34mItemSelection[0m
│   │   │   │   ├── ItemSelectionControls.swift
│   │   │   │   └── ItemSelectionStepView.swift
│   │   │   ├── [01;34mPackageOptions[0m
│   │   │   │   ├── AdvancedOptionsSection.swift
│   │   │   │   ├── DocumentationLevelSection.swift
│   │   │   │   ├── ExportFormatSection.swift
│   │   │   │   ├── IncludePhotosSection.swift
│   │   │   │   └── PackageOptionsStepView.swift
│   │   │   ├── [01;34mScenarioSetup[0m
│   │   │   │   ├── AdvancedSetupSection.swift
│   │   │   │   ├── ClaimTypeSection.swift
│   │   │   │   ├── IncidentDetailsSection.swift
│   │   │   │   ├── QuickStatsSection.swift
│   │   │   │   └── ScenarioSetupStepView.swift
│   │   │   └── [01;34mValidation[0m
│   │   │       ├── PackageSummarySection.swift
│   │   │       ├── ValidationChecksSection.swift
│   │   │       ├── ValidationStepView.swift
│   │   │       ├── ValidationWarningsCalculator.swift
│   │   │       └── WarningsSection.swift
│   │   ├── ClaimPackageAssemblyComponents.swift
│   │   ├── ClaimPackageAssemblyCore.swift
│   │   ├── ClaimPackageAssemblyIndex.swift
│   │   ├── ClaimPackageAssemblySteps.swift
│   │   └── README.md
│   ├── [01;34mClaimSubmission[0m
│   │   ├── ClaimSubmissionComponents.swift
│   │   ├── ClaimSubmissionCore.swift
│   │   └── ClaimSubmissionSteps.swift
│   ├── [01;34mDamageAssessmentViews[0m
│   │   ├── [01;34mDamageAssessmentReport[0m
│   │   │   ├── [01;34mActions[0m
│   │   │   │   └── ReportActionsSection.swift
│   │   │   ├── [01;34mComponents[0m
│   │   │   │   └── ReportSupportingViews.swift
│   │   │   ├── [01;34mSections[0m
│   │   │   │   ├── AssessmentSummarySection.swift
│   │   │   │   ├── ReportFeaturesSection.swift
│   │   │   │   ├── ReportGenerationSection.swift
│   │   │   │   ├── ReportHeaderView.swift
│   │   │   │   └── ReportStatusSection.swift
│   │   │   ├── [01;34mUtils[0m
│   │   │   │   └── ReportActionManager.swift
│   │   │   └── DamageAssessmentReportIndex.swift
│   │   ├── [01;34mDamageSeverityAssessment[0m
│   │   │   ├── [01;34mComponents[0m
│   │   │   │   ├── DamageSeverityAssessmentHeader.swift
│   │   │   │   ├── RepairabilityGuide.swift
│   │   │   │   ├── RepairabilityHelpView.swift
│   │   │   │   ├── SeverityCard.swift
│   │   │   │   └── ValueImpactBar.swift
│   │   │   ├── [01;34mSections[0m
│   │   │   │   ├── AssessmentNotesSection.swift
│   │   │   │   ├── CurrentSelectionSummarySection.swift
│   │   │   │   ├── ProfessionalAssessmentSection.swift
│   │   │   │   ├── RepairabilitySection.swift
│   │   │   │   ├── SeveritySelectionSection.swift
│   │   │   │   └── ValueImpactSection.swift
│   │   │   └── [01;34mUtilities[0m
│   │   │       └── AssessmentUtils.swift
│   │   ├── [01;34mPhotoComparison[0m
│   │   │   ├── [01;34mCamera[0m
│   │   │   │   └── DamageCameraView.swift
│   │   │   ├── [01;34mComponents[0m
│   │   │   │   ├── PhotoActionButtons.swift
│   │   │   │   ├── PhotoCard.swift
│   │   │   │   ├── PhotoComparisonGrid.swift
│   │   │   │   ├── PhotoComparisonHeader.swift
│   │   │   │   ├── PhotoDescriptionInput.swift
│   │   │   │   ├── PhotoGuidelines.swift
│   │   │   │   ├── PhotoPlaceholderCard.swift
│   │   │   │   └── PhotoTypeSelector.swift
│   │   │   ├── [01;34mLogic[0m
│   │   │   │   └── PhotoOperationsManager.swift
│   │   │   ├── [01;34mTypes[0m
│   │   │   │   └── PhotoType.swift
│   │   │   ├── PhotoComparisonIndex.swift
│   │   │   └── README.md
│   │   ├── [01;34mRepairCostEstimation[0m
│   │   │   ├── [01;34mCards[0m
│   │   │   │   ├── AdditionalCostsCard.swift
│   │   │   │   ├── CostSummaryCard.swift
│   │   │   │   ├── LaborMaterialsCard.swift
│   │   │   │   ├── ProfessionalEstimateCard.swift
│   │   │   │   ├── QuickAssessmentCard.swift
│   │   │   │   ├── RepairCostsCard.swift
│   │   │   │   └── ReplacementCostCard.swift
│   │   │   ├── [01;34mComponents[0m
│   │   │   │   ├── AdditionalCostRow.swift
│   │   │   │   ├── CostEstimationHeaderView.swift
│   │   │   │   └── RepairCostRow.swift
│   │   │   ├── [01;34mSections[0m
│   │   │   │   ├── AdditionalCostsSection.swift
│   │   │   │   ├── CostSummarySection.swift
│   │   │   │   ├── LaborMaterialsSection.swift
│   │   │   │   ├── ProfessionalEstimateSection.swift
│   │   │   │   ├── QuickAssessmentSection.swift
│   │   │   │   ├── RepairCostsSection.swift
│   │   │   │   └── ReplacementCostSection.swift
│   │   │   ├── RepairCostEstimationComponents.swift
│   │   │   ├── RepairCostEstimationCore.swift
│   │   │   └── RepairCostEstimationForms.swift
│   │   ├── [01;34mReportSections[0m
│   │   ├── BeforeAfterPhotoComparisonView.swift
│   │   ├── DamageAssessmentComponents.swift
│   │   ├── DamageAssessmentCore.swift
│   │   ├── DamageAssessmentReportView.swift
│   │   ├── DamageAssessmentReportView.swift.backup
│   │   ├── DamageAssessmentSteps.swift
│   │   ├── DamageAssessmentWorkflowView.swift
│   │   ├── DamageSeverityAssessmentView.swift
│   │   └── RepairCostEstimationView.swift
│   ├── [01;34mInsuranceClaim[0m
│   │   ├── [01;34mComponents[0m
│   │   │   ├── ClaimTypeCard.swift
│   │   │   └── SummaryRow.swift
│   │   ├── [01;34mLogic[0m
│   │   │   ├── ClaimDataPersistence.swift
│   │   │   ├── ClaimGenerationCoordinator.swift
│   │   │   └── ClaimValidation.swift
│   │   ├── [01;34mSteps[0m
│   │   │   ├── ClaimTypeStep.swift
│   │   │   ├── ContactInformationStep.swift
│   │   │   ├── IncidentDetailsStep.swift
│   │   │   └── ReviewAndGenerateStep.swift
│   │   ├── InsuranceClaimIndex.swift
│   │   └── README.md
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
│   │   ├── CloudStorageOptionsView.swift
│   │   ├── CurrencySettingsView.swift
│   │   ├── DangerZoneSettingsView.swift
│   │   ├── DataStorageSettingsView.swift
│   │   ├── DeveloperToolsView.swift
│   │   ├── ExportOptionsView.swift
│   │   ├── GeneralSettingsView.swift
│   │   ├── ImportExportSettingsView.swift
│   │   ├── InsuranceReportOptionsView.swift
│   │   ├── NotificationAnalyticsView.swift
│   │   ├── NotificationFrequencyView.swift
│   │   ├── NotificationSettingsView.swift
│   │   ├── PrivacyPolicyView.swift
│   │   └── TermsOfServiceView.swift
│   ├── [01;34mViewModels[0m
│   │   ├── AdvancedSearchViewModel.swift
│   │   └── InventoryListViewModel.swift
│   ├── [01;34mWarrantyViews[0m
│   │   ├── [01;34mWarrantyTracking[0m
│   │   │   ├── [01;34mSheets[0m
│   │   │   │   ├── [01;34mAutoDetection[0m
│   │   │   │   │   ├── AutoDetectionActionButtons.swift
│   │   │   │   │   ├── AutoDetectionHeader.swift
│   │   │   │   │   ├── AutoDetectResultSheet.swift
│   │   │   │   │   ├── ConfidenceCard.swift
│   │   │   │   │   └── DetectedInfoCard.swift
│   │   │   │   ├── [01;34mComponents[0m
│   │   │   │   │   └── InfoRow.swift
│   │   │   │   ├── [01;34mExtension[0m
│   │   │   │   │   ├── CurrentWarrantyCard.swift
│   │   │   │   │   ├── ExtensionOptionCard.swift
│   │   │   │   │   ├── ExtensionOptionsSection.swift
│   │   │   │   │   ├── ExtensionPurchaseButton.swift
│   │   │   │   │   ├── SelectedExtensionCard.swift
│   │   │   │   │   └── WarrantyExtensionSheet.swift
│   │   │   │   ├── [01;34mManualForm[0m
│   │   │   │   │   ├── AdditionalDetailsSection.swift
│   │   │   │   │   ├── BasicInformationSection.swift
│   │   │   │   │   ├── CoveragePeriodSection.swift
│   │   │   │   │   ├── ManualWarrantyFormSheet.swift
│   │   │   │   │   └── WarrantyFormState.swift
│   │   │   │   ├── [01;34mTypes[0m
│   │   │   │   │   └── WarrantyExtension.swift
│   │   │   │   ├── README.md
│   │   │   │   └── WarrantyTrackingSheetsIndex.swift
│   │   │   ├── WarrantyTrackingComponents.swift
│   │   │   ├── WarrantyTrackingCore.swift
│   │   │   └── WarrantyTrackingSheets.swift
│   │   ├── DocumentManagementView.swift
│   │   ├── LocationManagementView.swift
│   │   ├── WarrantyCharts.swift
│   │   ├── WarrantyDashboardComponents.swift
│   │   ├── WarrantyFormView.swift
│   │   ├── WarrantyManagementView.swift
│   │   ├── WarrantyStatusCalculator.swift
│   │   ├── WarrantySubviews.swift
│   │   └── WarrantyTrackingView.swift
│   ├── AddItemView.swift
│   ├── AdvancedSearchView.swift
│   ├── BarcodeScannerView.swift
│   ├── CaptureView.swift
│   ├── CategoriesView.swift
│   ├── ClaimExportView.swift
│   ├── ClaimPackageAssemblyView.swift
│   ├── ClaimPreviewView.swift
│   ├── ClaimsDashboardComponents.swift
│   ├── ClaimsDashboardView.swift
│   ├── ClaimSubmissionView.swift
│   ├── EditItemView.swift
│   ├── EnhancedReceiptDataView.swift
│   ├── Info.plist
│   ├── InsuranceClaimView.swift
│   ├── InsuranceExportOptionsView.swift
│   ├── InventoryListView.swift
│   ├── ItemConditionView.swift
│   ├── ItemDetailView.swift
│   ├── LiveReceiptScannerView.swift
│   ├── ManualBarcodeEntryView.swift
│   ├── Nestory.entitlements
│   ├── NestoryApp.swift
│   ├── PhotoCaptureView.swift
│   ├── ReceiptCaptureView.swift
│   ├── ReceiptDetailView.swift
│   ├── ReceiptsSection.swift
│   ├── RootFeature.swift
│   ├── RootView.swift
│   ├── SingleItemInsuranceReportView.swift
│   ├── ThemeManager.swift
│   ├── WarrantyDashboardView.swift
│   └── WarrantyDocumentsView.swift
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
│   ├── [01;34mScripts[0m
│   ├── [01;34mServices[0m
│   │   └── [01;34mAuthentication[0m
│   │       ├── AuthError.swift
│   │       └── AuthService.swift
│   ├── [01;34mTCA-Migration[0m
│   │   ├── [01;34mApp-Main.backup[0m
│   │   │   ├── RootFeature.swift
│   │   │   └── RootView.swift
│   │   ├── [01;34mFeatures.backup[0m
│   │   │   └── [01;34mInventory[0m
│   │   │       ├── InventoryFeature.swift
│   │   │       ├── InventoryView.swift
│   │   │       ├── ItemDetailFeature.swift
│   │   │       └── ItemEditFeature.swift
│   │   └── DependencyKeys.swift.backup
│   └── manual_navigation_test.swift
├── [01;34mAssets[0m
│   ├── [01;34mIcons[0m
│   │   └── [01;35mAppIcon.png[0m
│   └── [01;34mScreenshots[0m
├── [01;34mBuild Nestory-Prod_2025-08-21T23-12-46.xcresult[0m
│   ├── [01;34mData[0m
│   │   ├── data.0~GFXXcyxcbzYnBO9L2RXnA6zyfOsVUS6550FeHMo8hyrNIRCXt1lxmG6YfMFzF61GBMuXUjLkkE_Xf76Etp5abA==
│   │   ├── data.0~K5Q6HRt4Pr67KyOvy1fGcV6w44GkWgvcJM4loj9SeUG3YRuOJihe56c_flRY0yqH8Bd5tQueyfDCQ7vHwe8ApA==
│   │   ├── data.0~zW6qUCHSMumkKZzjOn9Xelo3jixiPF7yGWyKn0vTcMKO8aB6vHWuimvETkzhM8mCRXpidRrxenEHrAHRaKJfKA==
│   │   ├── refs.0~GFXXcyxcbzYnBO9L2RXnA6zyfOsVUS6550FeHMo8hyrNIRCXt1lxmG6YfMFzF61GBMuXUjLkkE_Xf76Etp5abA==
│   │   ├── refs.0~K5Q6HRt4Pr67KyOvy1fGcV6w44GkWgvcJM4loj9SeUG3YRuOJihe56c_flRY0yqH8Bd5tQueyfDCQ7vHwe8ApA==
│   │   └── refs.0~zW6qUCHSMumkKZzjOn9Xelo3jixiPF7yGWyKn0vTcMKO8aB6vHWuimvETkzhM8mCRXpidRrxenEHrAHRaKJfKA==
│   └── Info.plist
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
│   │   │       ├── [01;34mModels[0m
│   │   │       │   └── ArchitectureSpec.swift
│   │   │       ├── [01;34mUtils[0m
│   │   │       │   ├── CryptoUtils.swift
│   │   │       │   └── ProjectUtils.swift
│   │   │       └── main.swift
│   │   ├── Package.resolved
│   │   └── Package.swift
│   ├── [01;32menhanced-pre-commit.sh[0m
│   └── [01;32minstall_hooks.sh[0m
├── [01;34mfastlane[0m
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
├── [01;34mFeatures[0m
│   ├── [01;34mAnalytics[0m
│   │   ├── AnalyticsDashboardView.swift
│   │   └── AnalyticsFeature.swift
│   ├── [01;34mInventory[0m
│   │   ├── InventoryFeature.swift
│   │   ├── InventoryView.swift
│   │   ├── ItemDetailFeature.swift
│   │   └── ItemEditFeature.swift
│   ├── [01;34mSearch[0m
│   │   ├── [01;34mComponents[0m
│   │   │   ├── [01;34mActions[0m
│   │   │   │   └── SearchActions.swift
│   │   │   ├── [01;34mEffects[0m
│   │   │   │   └── SearchEffects.swift
│   │   │   ├── [01;34mReducers[0m
│   │   │   │   └── SearchReducer.swift
│   │   │   ├── [01;34mState[0m
│   │   │   │   └── SearchState.swift
│   │   │   └── [01;34mUtils[0m
│   │   │       └── SearchUtils.swift
│   │   ├── SearchFeature.swift
│   │   ├── SearchResultComponents.swift
│   │   ├── SearchSheetComponents.swift
│   │   ├── SearchToolbarComponents.swift
│   │   ├── SearchView.swift
│   │   ├── SearchViewComponents.swift
│   │   └── SearchViewModifiers.swift
│   └── [01;34mSettings[0m
│       ├── [01;34mComponents[0m
│       │   ├── [01;34mActions[0m
│       │   │   └── SettingsActions.swift
│       │   ├── [01;34mReducers[0m
│       │   │   └── SettingsReducer.swift
│       │   ├── [01;34mState[0m
│       │   │   └── SettingsState.swift
│       │   ├── [01;34mTypes[0m
│       │   │   └── SettingsTypes.swift
│       │   ├── [01;34mUtils[0m
│       │   │   └── SettingsUtils.swift
│       │   ├── SettingsIndex.swift
│       │   ├── SettingsReceiptComponents.swift
│       │   └── SettingsViewComponents.swift
│       ├── SettingsFeature.swift
│       ├── SettingsFeature.swift.backup
│       └── SettingsView.swift
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
│   │   ├── FoundationLogger.swift
│   │   ├── Identifiers.swift
│   │   ├── Money.swift
│   │   ├── NonEmptyString.swift
│   │   ├── RetryStrategy.swift
│   │   ├── ServiceError.swift
│   │   ├── Slug.swift
│   │   └── ValidationIssue.swift
│   ├── [01;34mModels[0m
│   │   ├── AnalyticsModels.swift
│   │   ├── AuthTypes.swift
│   │   ├── BackupMetadata.swift
│   │   ├── Category.swift
│   │   ├── ClaimInfo.swift
│   │   ├── CorrespondenceTypes.swift
│   │   ├── CostEstimation.swift
│   │   ├── DocumentationLevel.swift
│   │   ├── ExportFormat.swift
│   │   ├── ExportTypes.swift
│   │   ├── InsuranceReportData.swift
│   │   ├── InsuranceTypes.swift
│   │   ├── Item.swift
│   │   ├── Receipt.swift
│   │   ├── ReportMetadata.swift
│   │   ├── ReportOptions.swift
│   │   ├── Room.swift
│   │   ├── SearchFilters.swift
│   │   ├── ValidationResult.swift
│   │   ├── Warranty.swift
│   │   └── WarrantyStatus.swift
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
│   ├── [01;34mDatabase[0m
│   │   └── DatabaseProvider.swift
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
│   │   ├── ServiceHealthManager.swift
│   │   └── Signpost.swift
│   ├── [01;34mNetwork[0m
│   │   ├── Endpoint.swift
│   │   ├── HTTPClient.swift
│   │   ├── NetworkClient.swift
│   │   └── NetworkError.swift
│   ├── [01;34mNotifications[0m
│   │   └── NotificationProvider.swift
│   ├── [01;34mPerformance[0m
│   │   ├── PerformanceBaselines.swift
│   │   └── PerformanceProfiler.swift
│   ├── [01;34mPhotos[0m
│   │   └── PhotoPicker.swift
│   ├── [01;34mSecurity[0m
│   │   ├── CryptoBox.swift
│   │   ├── KeychainStore.swift
│   │   └── SecureEnclaveHelper.swift
│   ├── [01;34mStorage[0m
│   │   ├── Cache.swift
│   │   ├── FileStore.swift
│   │   ├── ImageIO.swift
│   │   ├── PerceptualHash.swift
│   │   ├── SecureStorage.swift
│   │   └── Thumbnailer.swift
│   ├── [01;34mVision[0m
│   │   └── VisionProcessor.swift
│   └── [01;34mVisionKit[0m
│       └── DocumentScannerView.swift
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
│   ├── [01;32marchitecture-verification.sh[0m
│   ├── [01;32mcheck-file-sizes.sh[0m
│   ├── [01;32mcodebase-health-report.sh[0m
│   ├── [01;32mconfigure_app_store_connect.rb[0m
│   ├── [01;32mdev_cycle.sh[0m
│   ├── [01;32mdev_stats.sh[0m
│   ├── [01;32mfinalize_bundle_identifier_update.sh[0m
│   ├── [01;32mgenerate-project-config.swift[0m
│   ├── [01;32mios_simulator_automation.applescript[0m
│   ├── [01;32mmanage-file-size-overrides.sh[0m
│   ├── [01;32mmodularization-monitor.sh[0m
│   ├── move_models.sh
│   ├── nestory_aliases.sh
│   ├── [01;32moptimize_xcode_workflow.sh[0m
│   ├── [01;32mquick_build.sh[0m
│   ├── [01;32mquick_test.sh[0m
│   ├── README.md
│   ├── [01;32mrun_fastlane_screenshots.sh[0m
│   ├── [01;32mrun_simulator_automation.sh[0m
│   ├── [01;32msetup_asc_credentials.sh[0m
│   ├── [01;32mupdate_bundle_identifiers.sh[0m
│   ├── [01;32mvalidate-configuration.sh[0m
│   └── [01;32mverify_app_store_setup.sh[0m
├── [01;34mServices[0m
│   ├── [01;34mAnalyticsService[0m
│   │   ├── AnalyticsCurrencyOperations.swift
│   │   ├── AnalyticsService.swift
│   │   ├── AnalyticsServiceError.swift
│   │   ├── AnalyticsServiceModels.swift
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
│   ├── [01;34mAuthService[0m
│   │   └── AuthService.swift
│   ├── [01;34mBarcodeScannerService[0m
│   │   ├── BarcodeScannerService.swift
│   │   ├── LiveBarcodeScannerService.swift
│   │   ├── MockBarcodeScannerService.swift
│   │   └── ProductLookupService.swift
│   ├── [01;34mClaimExport[0m
│   │   ├── ClaimExportCore.swift
│   │   ├── ClaimExportFormatters.swift
│   │   ├── ClaimExportModels.swift
│   │   └── ClaimExportValidators.swift
│   ├── [01;34mClaimTracking[0m
│   │   ├── [01;34mAnalytics[0m
│   │   │   └── ClaimAnalyticsEngine.swift
│   │   ├── [01;34mFollowUp[0m
│   │   │   └── FollowUpManager.swift
│   │   ├── [01;34mModels[0m
│   │   │   └── ClaimTrackingModels.swift
│   │   ├── [01;34mOperations[0m
│   │   │   └── ClaimTrackingOperations.swift
│   │   ├── [01;34mTimeline[0m
│   │   │   └── ClaimTimelineManager.swift
│   │   └── ClaimTrackingIndex.swift
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
│   ├── [01;34mDamageAssessmentService[0m
│   │   ├── DamageAssessmentModels.swift
│   │   └── DamageAssessmentService.swift
│   ├── [01;34mDependencies[0m
│   │   └── CoreServiceKeys.swift.backup
│   ├── [01;34mExportService[0m
│   │   └── ExportService.swift
│   ├── [01;34mImportExportService[0m
│   │   ├── CSVOperations.swift
│   │   ├── ImportExportModels.swift
│   │   ├── ImportExportService.swift
│   │   ├── JSONOperations.swift
│   │   ├── LiveImportExportService.swift
│   │   └── MockImportExportService.swift
│   ├── [01;34mInsuranceClaim[0m
│   │   ├── [01;34mClaimDocumentGenerator[0m
│   │   │   ├── ClaimDocumentCore.swift
│   │   │   ├── ClaimDocumentHelpers.swift
│   │   │   ├── ClaimHTMLGenerator.swift
│   │   │   ├── ClaimJSONGenerator.swift
│   │   │   ├── ClaimPDFGenerator.swift
│   │   │   └── ClaimSpreadsheetGenerator.swift
│   │   ├── [01;34mTemplates[0m
│   │   │   ├── [01;34mFields[0m
│   │   │   ├── [01;34mGenerators[0m
│   │   │   │   ├── AllstateTemplateGenerator.swift
│   │   │   │   ├── GeicoTemplateGenerator.swift
│   │   │   │   ├── GenericTemplateGenerator.swift
│   │   │   │   └── StateFarmTemplateGenerator.swift
│   │   │   ├── [01;34mLogos[0m
│   │   │   ├── [01;34mSections[0m
│   │   │   ├── [01;34mUtils[0m
│   │   │   │   └── TemplateValidator.swift
│   │   │   ├── ClaimTemplateIndex.swift
│   │   │   └── ClaimTemplateTypes.swift
│   │   ├── ClaimDocumentGenerator.swift
│   │   ├── ClaimTemplateManager.swift
│   │   └── ClaimTemplateManager.swift.backup
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
│   │   ├── NotificationAdvancedOperations.swift
│   │   ├── NotificationAnalytics.swift
│   │   ├── NotificationBackgroundProcessor.swift
│   │   ├── NotificationManagement.swift
│   │   ├── NotificationOtherOperations.swift
│   │   ├── NotificationPersistence.swift
│   │   ├── NotificationScheduler.swift
│   │   ├── NotificationSchedulingTypes.swift
│   │   ├── NotificationService.swift
│   │   ├── NotificationServiceError.swift
│   │   ├── NotificationSettings.swift
│   │   └── NotificationWarrantyOperations.swift
│   ├── [01;34mReceiptOCR[0m
│   │   ├── AppleFrameworksReceiptProcessor.swift
│   │   ├── CategoryClassifier.swift
│   │   ├── MLReceiptProcessor.swift
│   │   ├── ReceiptDataParser.swift
│   │   ├── ReceiptItemExtractor.swift
│   │   └── VisionTextExtractor.swift
│   ├── [01;34mSyncService[0m
│   │   └── SyncService.swift
│   ├── [01;34mWarrantyService[0m
│   │   └── WarrantyService.swift
│   ├── [01;34mWarrantyTrackingService[0m
│   │   ├── [01;34mOperations[0m
│   │   │   ├── [01;34mAnalytics[0m
│   │   │   │   └── WarrantyAnalyticsEngine.swift
│   │   │   ├── [01;34mBulk[0m
│   │   │   │   └── WarrantyBulkOperations.swift
│   │   │   ├── [01;34mCache[0m
│   │   │   │   └── WarrantyCacheManager.swift
│   │   │   ├── [01;34mCore[0m
│   │   │   │   └── WarrantyCoreOperations.swift
│   │   │   ├── [01;34mDetection[0m
│   │   │   │   └── WarrantyDetectionEngine.swift
│   │   │   ├── [01;34mStatus[0m
│   │   │   │   └── WarrantyStatusManager.swift
│   │   │   └── WarrantyOperationsIndex.swift
│   │   ├── LiveWarrantyTrackingService.swift
│   │   ├── LiveWarrantyTrackingService.swift.backup
│   │   └── WarrantyTrackingService.swift
│   ├── ClaimContentGenerator.swift
│   ├── ClaimDocumentProcessor.swift
│   ├── ClaimEmailService.swift
│   ├── ClaimExportService.swift
│   ├── ClaimPackageAssemblerService.swift
│   ├── ClaimPackageCore.swift
│   ├── ClaimPackageExporter.swift
│   ├── ClaimTrackingService.swift
│   ├── ClaimTrackingService.swift.backup
│   ├── ClaimValidationService.swift
│   ├── CloudStorageServices.swift
│   ├── DependencyKeys.swift
│   ├── DependencyUtilities.swift
│   ├── DependencyValueExtensions.swift
│   ├── InsuranceClaimCore.swift
│   ├── InsuranceClaimModels.swift
│   ├── InsuranceClaimService.swift
│   ├── InsuranceClaimValidation.swift
│   ├── InsuranceExportService.swift
│   ├── InsuranceReportService.swift
│   ├── MockServiceImplementations.swift
│   ├── NotificationServiceCompatibility.swift
│   ├── ReceiptOCRService.swift
│   ├── ReliableMockInventoryService.swift
│   └── ServiceDependencyKeys.swift
├── [01;34mSources[0m
│   └── [01;34mNestoryGuards[0m
│       └── NestoryGuards.swift
├── [01;34mTests[0m
│   ├── [01;34mArchitectureTests[0m
│   │   └── ArchitectureTests.swift
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
│   ├── [01;34mServicesTests[0m
│   │   ├── WarrantyTrackingServiceCoreTests.swift
│   │   └── WarrantyTrackingServiceIntegrationTests.swift
│   ├── [01;34mSnapshot[0m
│   │   └── SnapshotTests.swift
│   ├── [01;34mTestSupport[0m
│   │   ├── ServiceMocks.swift
│   │   └── UITestHelpers.swift
│   ├── [01;34mUI[0m
│   │   ├── AccessibilityTests.swift
│   │   ├── AddItemViewTests.swift
│   │   ├── InventoryListViewTests.swift
│   │   ├── ItemDetailViewTests.swift
│   │   └── SettingsViewTests.swift
│   ├── [01;34mUnit[0m
│   │   ├── [01;34mFoundation[0m
│   │   │   ├── CloudKitCompatibilityTests.swift
│   │   │   ├── IdentifierTests.swift
│   │   │   ├── ModelInvariantTests.swift
│   │   │   ├── MoneyTests.swift
│   │   │   └── TestHelpers.swift
│   │   └── [01;34mServices[0m
│   │       └── InsuranceClaimServiceTests.swift
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
│   │   ├── ComingSoonView.swift
│   │   ├── ErrorView.swift
│   │   ├── ExportOptionsView.swift
│   │   ├── InfoRow.swift
│   │   ├── InsuranceReportOptionsView.swift
│   │   ├── ManualBarcodeEntryView.swift
│   │   ├── MLProcessingProgressView.swift
│   │   ├── ServiceHealthIndicator.swift
│   │   └── SummaryCardsView.swift
│   ├── [01;34mPerformance[0m
│   │   └── UIPerformanceOptimizer.swift
│   ├── [01;34mUI-Components[0m
│   │   ├── EmptyStateView.swift
│   │   ├── ItemCard.swift
│   │   ├── PrimaryButton.swift
│   │   ├── SearchBar.swift
│   │   └── ShareSheet.swift
│   └── [01;34mUI-Core[0m
│       ├── Extensions.swift
│       ├── Theme.swift
│       └── Typography.swift
├── [01;32manalyze_architecture.sh[0m
├── APP_STORE_CONNECT_API.md
├── APP_STORE_SUBMISSION_GUIDE.md
├── APPLESCRIPT_IOS_SIMULATOR_NAVIGATION.md
├── ARCHAEOLOGICAL_LAYERS.md
├── ARCHITECTURE_NOTES.md
├── architecture_report.md
├── ARCHITECTURE_STATUS.md
├── AuthKey_NWV654RNK3.p8
├── AUTOMATION_SYSTEM.md
├── Build Nestory-Dev_2025-08-21T23-51-02.txt
├── Build Nestory-Dev_2025-08-22T02-30-40.txt
├── Build Nestory-Dev_2025-08-22T03-11-00.txt
├── Build Nestory-Dev_2025-08-22T04-47-37.txt
├── Build Nestory-Dev_2025-08-22T06-19-48.txt
├── Build Nestory-Dev_2025-08-22T07-17-10.txt
├── Build Nestory-Dev_2025-08-22T09-24-12.txt
├── Build Nestory-Dev_2025-08-22T12-53-20.txt
├── Build Nestory-Dev_2025-08-22T16-06-39.txt
├── Build Nestory-Dev_2025-08-22T16-27-30.txt
├── Build Nestory-Dev_2025-08-22T16-53-38.txt
├── Build Nestory-Dev_2025-08-22T19-25-50.txt
├── Build Nestory-Dev_2025-08-22T22-11-24.txt
├── Build Nestory-Prod_2025-08-21T23-12-46.txt
├── BUILD_INSTRUCTIONS.md
├── [01;32mbuild_ios.sh[0m
├── BUILD_STATUS.md
├── build_with_swift6.sh
├── [01;32mbuild.sh[0m
├── [01;32mcheck_environment.sh[0m
├── CLAIM_PACKAGE_SUMMARY.md
├── CLAUDE.md
├── CLOUDKIT_MIGRATION_STRATEGY.md
├── CURRENT_CONTEXT.md
├── DECISIONS.md
├── dependencies.dot
├── [01;35mdependencies.png[0m
├── DEVELOPMENT_CHECKLIST.md
├── emergency_fix.sh
├── EMERGENCY_MODULARIZATION.md
├── EXPORT_COMPLIANCE.md
├── fastlane_plugins_recommendations.md
├── [01;32mfix_build.sh[0m
├── Gemfile.lock
├── [01;32mgenerate_app_icons.sh[0m
├── HOT_RELOAD_AUDIT_REPORT.md
├── HOT_RELOAD_DOCUMENTATION.md
├── LICENSE
├── LINTING.md
├── Makefile
├── [01;32mmetrics.sh[0m
├── MODULARIZATION_PLAN.md
├── Observability.md
├── open_xcode.sh
├── Package.resolved
├── Package.swift
├── PERFORMANCE_OPTIMIZATION_SUMMARY.md
├── PHASE2_COMPLETION_REPORT.md
├── PRIVACY_POLICY.md
├── [01;32mprocess_app_icon.sh[0m
├── PROJECT_CONTEXT.md
├── project-uitests.yml
├── project.yml
├── [01;32mquick_build.sh[0m
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
├── STATUS.md
├── SWIFT6_UITEST_MIGRATION.md
├── tca_analysis.py
├── TCA_IMPLEMENTATION_STATUS.md
├── THIRD_PARTY_LICENSES.md
├── TODO.md
├── TREE.md
├── [01;32mupdate_tree.sh[0m
├── [01;32mupload_to_testflight.sh[0m
├── verify_build.sh
└── XCODE_FIX.md

197 directories, 732 files
```

_📁 Directories:  | 📄 Files: 
