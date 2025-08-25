# Project Structure

_Last updated: 2025-08-24 15:00:09_

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
│   │   ├── [01;34mCardBackground.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mPrimaryBackground.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mPrimaryText.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mSecondaryBackground.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mSecondaryText.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mWarrantyActive.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mWarrantyExpired.colorset[0m
│   │   │   └── Contents.json
│   │   ├── [01;34mWarrantyExpiring.colorset[0m
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
│   ├── NavigationRouter.swift
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
│   ├── screenshot_lanes.rb
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
│       │   ├── SettingsViewComponents.swift
│       │   └── ThemeComponents.swift
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
│   │   ├── ColorSystem.swift
│   │   ├── ErrorLogger.swift
│   │   ├── ErrorRecoveryStrategy.swift
│   │   ├── Errors.swift
│   │   ├── FoundationLogger.swift
│   │   ├── Identifiers.swift
│   │   ├── Logger.swift
│   │   ├── Money.swift
│   │   ├── NonEmptyString.swift
│   │   ├── RetryStrategy.swift
│   │   ├── ScreenRegistry.swift
│   │   ├── ServiceError.swift
│   │   ├── Slug.swift
│   │   ├── UITestMode.swift
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
│   │       ├── Nestory-Staging.xcscheme
│   │       └── Nestory-UIWiring.xcscheme
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
│   ├── [01;34mFramework[0m
│   │   ├── ScreenshotHelper.swift
│   │   └── XCUIElement+Extensions.swift
│   ├── [01;34mHelpers[0m
│   │   ├── NavigationHelper.swift
│   │   ├── NavigationHelpers.swift
│   │   └── UITestHelpers.swift
│   └── [01;34mTests[0m
│       ├── BasicScreenshotTest.swift
│       ├── ComprehensiveScreenshotTest.swift
│       ├── ComprehensiveUIWiringTest.swift
│       └── DeterministicScreenshotTest.swift
├── [01;34mScripts[0m
│   ├── [01;32marchitecture-verification.sh[0m
│   ├── capture-app-screenshots.swift
│   ├── [01;32mcheck-file-sizes.sh[0m
│   ├── [01;32mcodebase-health-report.sh[0m
│   ├── [01;32mconfigure_app_store_connect.rb[0m
│   ├── [01;32mdev_cycle.sh[0m
│   ├── [01;32mdev_stats.sh[0m
│   ├── extract-screenshots.py
│   ├── [01;32mextract-ui-test-screenshots.sh[0m
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
│   ├── [01;32mrun-screenshots.sh[0m
│   ├── [01;32msetup_asc_credentials.sh[0m
│   ├── setup-fastlane.sh
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
├── [01;34mswift-composable-architecture[0m
│   ├── [01;34mBenchmarks[0m
│   │   ├── [01;34mBenchmarks[0m
│   │   │   └── [01;34mswift-composable-architecture-benchmark[0m
│   │   │       └── Benchmarks.swift
│   │   ├── Package.resolved
│   │   └── Package.swift
│   ├── [01;34mExamples[0m
│   │   ├── [01;34mCaseStudies[0m
│   │   │   ├── [01;34mCaseStudies.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       ├── CaseStudies (SwiftUI).xcscheme
│   │   │   │   │       ├── CaseStudies (UIKit).xcscheme
│   │   │   │   │       └── tvOSCaseStudies.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mSwiftUICaseStudies[0m
│   │   │   │   ├── [01;34m05-HigherOrderReducers-ResuableOfflineDownloads[0m
│   │   │   │   │   ├── DownloadClient.swift
│   │   │   │   │   ├── DownloadComponent.swift
│   │   │   │   │   └── ReusableComponents-Download.swift
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mInternal[0m
│   │   │   │   │   ├── AboutView.swift
│   │   │   │   │   ├── CircularProgressView.swift
│   │   │   │   │   ├── ResignFirstResponder.swift
│   │   │   │   │   ├── TemplateText.swift
│   │   │   │   │   └── UIViewRepresented.swift
│   │   │   │   ├── 00-RootView.swift
│   │   │   │   ├── 01-GettingStarted-AlertsAndConfirmationDialogs.swift
│   │   │   │   ├── 01-GettingStarted-Animations.swift
│   │   │   │   ├── 01-GettingStarted-Bindings-Basics.swift
│   │   │   │   ├── 01-GettingStarted-Bindings-Forms.swift
│   │   │   │   ├── 01-GettingStarted-Composition-TwoCounters.swift
│   │   │   │   ├── 01-GettingStarted-Counter.swift
│   │   │   │   ├── 01-GettingStarted-FocusState.swift
│   │   │   │   ├── 01-GettingStarted-OptionalState.swift
│   │   │   │   ├── 02-Effects-SystemEnvironment.swift
│   │   │   │   ├── 02-SharedState-FileStorage.swift
│   │   │   │   ├── 02-SharedState-InMemory.swift
│   │   │   │   ├── 02-SharedState-Onboarding.swift
│   │   │   │   ├── 02-SharedState-UserDefaults.swift
│   │   │   │   ├── 03-Effects-Basics.swift
│   │   │   │   ├── 03-Effects-Cancellation.swift
│   │   │   │   ├── 03-Effects-LongLiving.swift
│   │   │   │   ├── 03-Effects-Refreshable.swift
│   │   │   │   ├── 03-Effects-Timers.swift
│   │   │   │   ├── 03-Effects-WebSocket.swift
│   │   │   │   ├── 04-Navigation-Lists-NavigateAndLoad.swift
│   │   │   │   ├── 04-Navigation-Multiple-Destinations.swift
│   │   │   │   ├── 04-Navigation-NavigateAndLoad.swift
│   │   │   │   ├── 04-Navigation-Sheet-LoadThenPresent.swift
│   │   │   │   ├── 04-Navigation-Sheet-PresentAndLoad.swift
│   │   │   │   ├── 04-NavigationStack.swift
│   │   │   │   ├── 05-HigherOrderReducers-Recursion.swift
│   │   │   │   ├── 05-HigherOrderReducers-ReusableFavoriting.swift
│   │   │   │   ├── CaseStudiesApp.swift
│   │   │   │   ├── FactClient.swift
│   │   │   │   └── Info.plist
│   │   │   ├── [01;34mSwiftUICaseStudiesTests[0m
│   │   │   │   ├── 01-GettingStarted-AlertsAndConfirmationDialogsTests.swift
│   │   │   │   ├── 01-GettingStarted-AnimationsTests.swift
│   │   │   │   ├── 01-GettingStarted-BindingBasicsTests.swift
│   │   │   │   ├── 02-GettingStarted-SharedStateFileStorageTests.swift
│   │   │   │   ├── 02-GettingStarted-SharedStateInMemoryTests.swift
│   │   │   │   ├── 02-GettingStarted-SharedStateUserDefaultsTests.swift
│   │   │   │   ├── 03-Effects-BasicsTests.swift
│   │   │   │   ├── 03-Effects-CancellationTests.swift
│   │   │   │   ├── 03-Effects-LongLivingTests.swift
│   │   │   │   ├── 03-Effects-RefreshableTests.swift
│   │   │   │   ├── 03-Effects-TimersTests.swift
│   │   │   │   ├── 03-Effects-WebSocketTests.swift
│   │   │   │   ├── 05-HigherOrderReducers-RecursionTests.swift
│   │   │   │   ├── 05-HigherOrderReducers-ReusableFavoritingTests.swift
│   │   │   │   └── 05-HigherOrderReducers-ReusableOfflineDownloadsTests.swift
│   │   │   ├── [01;34mtvOSCaseStudies[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── AppDelegate.swift
│   │   │   │   ├── Core.swift
│   │   │   │   ├── FocusView.swift
│   │   │   │   ├── Info.plist
│   │   │   │   └── RootView.swift
│   │   │   ├── [01;34mtvOSCaseStudiesTests[0m
│   │   │   │   └── FocusTests.swift
│   │   │   ├── [01;34mUIKitCaseStudies[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mBase.lproj[0m
│   │   │   │   │   └── LaunchScreen.storyboard
│   │   │   │   ├── [01;34mInternal[0m
│   │   │   │   │   ├── ActivityIndicatorViewController.swift
│   │   │   │   │   └── IfLetStoreController.swift
│   │   │   │   ├── [01;34mPreview Content[0m
│   │   │   │   │   └── [01;34mPreview Assets.xcassets[0m
│   │   │   │   │       └── Contents.json
│   │   │   │   ├── CounterViewController.swift
│   │   │   │   ├── Info.plist
│   │   │   │   ├── ListsOfState.swift
│   │   │   │   ├── LoadThenNavigate.swift
│   │   │   │   ├── NavigateAndLoad.swift
│   │   │   │   ├── RootViewController.swift
│   │   │   │   └── SceneDelegate.swift
│   │   │   ├── [01;34mUIKitCaseStudiesTests[0m
│   │   │   │   ├── Info.plist
│   │   │   │   └── UIKitCaseStudiesTests.swift
│   │   │   └── README.md
│   │   ├── [01;34mIntegration[0m
│   │   │   ├── [01;34mIntegration[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34miOS 16[0m
│   │   │   │   │   ├── BasicsTestCase.swift
│   │   │   │   │   ├── EnumTestCase.swift
│   │   │   │   │   ├── IdentifiedListTestCase.swift
│   │   │   │   │   ├── NavigationTestCase.swift
│   │   │   │   │   ├── OptionalTestCase.swift
│   │   │   │   │   ├── PresentationTestCase.swift
│   │   │   │   │   └── SiblingTestCase.swift
│   │   │   │   ├── [01;34miOS 16+17[0m
│   │   │   │   │   ├── NewContainsOldTestCase.swift
│   │   │   │   │   ├── NewOldSiblingsTestCase.swift
│   │   │   │   │   ├── NewPresentsOldTestCase.swift
│   │   │   │   │   ├── OldContainsNewTestCase.swift
│   │   │   │   │   └── OldPresentsNewTestCase.swift
│   │   │   │   ├── [01;34miOS 17[0m
│   │   │   │   │   ├── ObservableBasicsTestCase.swift
│   │   │   │   │   ├── ObservableBindingLocalTest.swift
│   │   │   │   │   ├── ObservableEnumTestCase.swift
│   │   │   │   │   ├── ObservableIdentifiedListTestCase.swift
│   │   │   │   │   ├── ObservableNavigationTestCase.swift
│   │   │   │   │   ├── ObservableOptionalTestCase.swift
│   │   │   │   │   ├── ObservablePresentationTestCase.swift
│   │   │   │   │   ├── ObservableSharedStateTestCase.swift
│   │   │   │   │   └── ObservableSiblingTestCase.swift
│   │   │   │   ├── [01;34mLegacy[0m
│   │   │   │   │   ├── BindingLocalTestCase.swift
│   │   │   │   │   ├── BindingsAnimationsTestBench.swift
│   │   │   │   │   ├── EscapedWithViewStoreTestCase.swift
│   │   │   │   │   ├── ForEachBindingTestCase.swift
│   │   │   │   │   ├── IfLetStoreTestCase.swift
│   │   │   │   │   ├── LegacyPresentationTestCase.swift
│   │   │   │   │   ├── NavigationStackTestCase.swift
│   │   │   │   │   ├── PresentationItemTestCase.swift
│   │   │   │   │   └── SwitchStoreTestCase.swift
│   │   │   │   ├── [01;34mPreview Content[0m
│   │   │   │   │   └── [01;34mPreview Assets.xcassets[0m
│   │   │   │   │       └── Contents.json
│   │   │   │   ├── [01;34mTest Cases[0m
│   │   │   │   │   └── MultipleAlertsTestCase.swift
│   │   │   │   ├── Info.plist
│   │   │   │   └── IntegrationApp.swift
│   │   │   ├── [01;34mIntegration.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── Integration.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mIntegrationUITests[0m
│   │   │   │   ├── [01;34mInternal[0m
│   │   │   │   │   ├── BaseIntegrationTests.swift
│   │   │   │   │   └── TestHelpers.swift
│   │   │   │   ├── [01;34miOS 16[0m
│   │   │   │   │   ├── BasicsTests.swift
│   │   │   │   │   ├── EnumTests.swift
│   │   │   │   │   ├── IdentifiedListTests.swift
│   │   │   │   │   ├── NavigationTests.swift
│   │   │   │   │   ├── OptionalTests.swift
│   │   │   │   │   ├── PresentationTests.swift
│   │   │   │   │   └── SiblingTests.swift
│   │   │   │   ├── [01;34miOS 16+17[0m
│   │   │   │   │   ├── NewContainsOldTests.swift
│   │   │   │   │   ├── NewOldSiblingsTests.swift
│   │   │   │   │   ├── NewPresentsOldTests.swift
│   │   │   │   │   ├── OldContainsNewTests.swift
│   │   │   │   │   └── OldPresentsNewTests.swift
│   │   │   │   ├── [01;34miOS 17[0m
│   │   │   │   │   ├── ObservableBasicsTests.swift
│   │   │   │   │   ├── ObservableBindingLocalTests.swift
│   │   │   │   │   ├── ObservableEnumTests.swift
│   │   │   │   │   ├── ObservableIdentifiedListTests.swift
│   │   │   │   │   ├── ObservableNavigationTests.swift
│   │   │   │   │   ├── ObservableOptionalTests.swift
│   │   │   │   │   ├── ObservablePresentationTests.swift
│   │   │   │   │   ├── ObservableSharedStateTests.swift
│   │   │   │   │   └── ObservableSiblingTests.swift
│   │   │   │   ├── [01;34mLegacy[0m
│   │   │   │   │   ├── BindingLocalTests.swift
│   │   │   │   │   ├── EscapedWithViewStoreTests.swift
│   │   │   │   │   ├── ForEachBindingTests.swift
│   │   │   │   │   ├── IfLetStoreTests.swift
│   │   │   │   │   ├── LegacyNavigationTests.swift
│   │   │   │   │   ├── LegacyPresentationTests.swift
│   │   │   │   │   └── SwitchStoreTests.swift
│   │   │   │   ├── [01;34mTest Cases[0m
│   │   │   │   │   └── MultipleAlertsTests.swift
│   │   │   │   └── EnumTests.swift
│   │   │   └── [01;34mTestCases[0m
│   │   │       └── TestCase.swift
│   │   ├── [01;34mSearch[0m
│   │   │   ├── [01;34mSearch[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── SearchApp.swift
│   │   │   │   ├── SearchView.swift
│   │   │   │   └── WeatherClient.swift
│   │   │   ├── [01;34mSearch.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── Search.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mSearchTests[0m
│   │   │   │   └── SearchTests.swift
│   │   │   └── README.md
│   │   ├── [01;34mSpeechRecognition[0m
│   │   │   ├── [01;34mSpeechRecognition[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mSpeechClient[0m
│   │   │   │   │   ├── Client.swift
│   │   │   │   │   ├── Live.swift
│   │   │   │   │   └── Models.swift
│   │   │   │   ├── Info.plist
│   │   │   │   ├── SpeechRecognition.swift
│   │   │   │   └── SpeechRecognitionApp.swift
│   │   │   ├── [01;34mSpeechRecognition.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── SpeechRecognition.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mSpeechRecognitionTests[0m
│   │   │   │   └── SpeechRecognitionTests.swift
│   │   │   └── README.md
│   │   ├── [01;34mSyncUps[0m
│   │   │   ├── [01;34mSyncUps[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   ├── [01;34mThemes[0m
│   │   │   │   │   │   ├── [01;34mbubblegum.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mbuttercup.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mindigo.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mlavender.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mmagenta.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mnavy.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34morange.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34moxblood.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mperiwinkle.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mpoppy.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mpurple.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mseafoam.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34msky.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mtan.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mteal.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34myellow.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mDependencies[0m
│   │   │   │   │   ├── OpenSettings.swift
│   │   │   │   │   └── SpeechRecognizer.swift
│   │   │   │   ├── [01;34mResources[0m
│   │   │   │   │   └── [00;36mding.wav[0m
│   │   │   │   ├── App.swift
│   │   │   │   ├── AppFeature.swift
│   │   │   │   ├── Meeting.swift
│   │   │   │   ├── Models.swift
│   │   │   │   ├── RecordMeeting.swift
│   │   │   │   ├── SyncUpDetail.swift
│   │   │   │   ├── SyncUpForm.swift
│   │   │   │   └── SyncUpsList.swift
│   │   │   ├── [01;34mSyncUps.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── SyncUps.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mSyncUpsTests[0m
│   │   │   │   ├── AppFeatureTests.swift
│   │   │   │   ├── RecordMeetingTests.swift
│   │   │   │   ├── SyncUpDetailTests.swift
│   │   │   │   ├── SyncUpFormTests.swift
│   │   │   │   └── SyncUpsListTests.swift
│   │   │   ├── [01;34mSyncUpsUITests[0m
│   │   │   │   └── SyncUpsUITests.swift
│   │   │   ├── README.md
│   │   │   └── SyncUps.xctestplan
│   │   ├── [01;34mTicTacToe[0m
│   │   │   ├── [01;34mApp[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── RootView.swift
│   │   │   │   └── TicTacToeApp.swift
│   │   │   ├── [01;34mtic-tac-toe[0m
│   │   │   │   ├── [01;34mSources[0m
│   │   │   │   │   ├── [01;34mAppCore[0m
│   │   │   │   │   │   └── AppCore.swift
│   │   │   │   │   ├── [01;34mAppSwiftUI[0m
│   │   │   │   │   │   └── AppView.swift
│   │   │   │   │   ├── [01;34mAppUIKit[0m
│   │   │   │   │   │   └── AppViewController.swift
│   │   │   │   │   ├── [01;34mAuthenticationClient[0m
│   │   │   │   │   │   └── AuthenticationClient.swift
│   │   │   │   │   ├── [01;34mAuthenticationClientLive[0m
│   │   │   │   │   │   └── LiveAuthenticationClient.swift
│   │   │   │   │   ├── [01;34mGameCore[0m
│   │   │   │   │   │   ├── GameCore.swift
│   │   │   │   │   │   └── Three.swift
│   │   │   │   │   ├── [01;34mGameSwiftUI[0m
│   │   │   │   │   │   └── GameView.swift
│   │   │   │   │   ├── [01;34mGameUIKit[0m
│   │   │   │   │   │   └── GameViewController.swift
│   │   │   │   │   ├── [01;34mLoginCore[0m
│   │   │   │   │   │   └── LoginCore.swift
│   │   │   │   │   ├── [01;34mLoginSwiftUI[0m
│   │   │   │   │   │   └── LoginView.swift
│   │   │   │   │   ├── [01;34mLoginUIKit[0m
│   │   │   │   │   │   └── LoginViewController.swift
│   │   │   │   │   ├── [01;34mNewGameCore[0m
│   │   │   │   │   │   └── NewGameCore.swift
│   │   │   │   │   ├── [01;34mNewGameSwiftUI[0m
│   │   │   │   │   │   └── NewGameView.swift
│   │   │   │   │   ├── [01;34mNewGameUIKit[0m
│   │   │   │   │   │   └── NewGameViewController.swift
│   │   │   │   │   ├── [01;34mTwoFactorCore[0m
│   │   │   │   │   │   └── TwoFactorCore.swift
│   │   │   │   │   ├── [01;34mTwoFactorSwiftUI[0m
│   │   │   │   │   │   └── TwoFactorView.swift
│   │   │   │   │   └── [01;34mTwoFactorUIKit[0m
│   │   │   │   │       └── TwoFactorViewController.swift
│   │   │   │   ├── [01;34mTests[0m
│   │   │   │   │   ├── [01;34mAppCoreTests[0m
│   │   │   │   │   │   └── AppCoreTests.swift
│   │   │   │   │   ├── [01;34mGameCoreTests[0m
│   │   │   │   │   │   └── GameCoreTests.swift
│   │   │   │   │   ├── [01;34mLoginCoreTests[0m
│   │   │   │   │   │   └── LoginCoreTests.swift
│   │   │   │   │   ├── [01;34mNewGameCoreTests[0m
│   │   │   │   │   │   └── NewGameCoreTests.swift
│   │   │   │   │   └── [01;34mTwoFactorCoreTests[0m
│   │   │   │   │       └── TwoFactorCoreTests.swift
│   │   │   │   └── Package.swift
│   │   │   ├── [01;34mTicTacToe.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── TicTacToe.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   └── README.md
│   │   ├── [01;34mTodos[0m
│   │   │   ├── [01;34mTodos[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── Todo.swift
│   │   │   │   ├── Todos.swift
│   │   │   │   └── TodosApp.swift
│   │   │   ├── [01;34mTodos.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── Todos.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mTodosTests[0m
│   │   │   │   └── TodosTests.swift
│   │   │   └── README.md
│   │   ├── [01;34mVoiceMemos[0m
│   │   │   ├── [01;34mVoiceMemos[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-60@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-76@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon-iPadPro@2x.png[0m
│   │   │   │   │   │   ├── [01;35mAppIcon.png[0m
│   │   │   │   │   │   ├── Contents.json
│   │   │   │   │   │   └── [01;35mtransparent.png[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mAudioPlayerClient[0m
│   │   │   │   │   ├── AudioPlayerClient.swift
│   │   │   │   │   └── LiveAudioPlayerClient.swift
│   │   │   │   ├── [01;34mAudioRecorderClient[0m
│   │   │   │   │   ├── AudioRecorderClient.swift
│   │   │   │   │   └── LiveAudioRecorderClient.swift
│   │   │   │   ├── Dependencies.swift
│   │   │   │   ├── Helpers.swift
│   │   │   │   ├── Info.plist
│   │   │   │   ├── RecordingMemo.swift
│   │   │   │   ├── VoiceMemo.swift
│   │   │   │   ├── VoiceMemos.swift
│   │   │   │   └── VoiceMemosApp.swift
│   │   │   ├── [01;34mVoiceMemos.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── VoiceMemos.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mVoiceMemosTests[0m
│   │   │   │   └── VoiceMemosTests.swift
│   │   │   └── README.md
│   │   ├── Package.swift
│   │   └── README.md
│   ├── [01;34mSources[0m
│   │   ├── [01;34mComposableArchitecture[0m
│   │   │   ├── [01;34mDependencies[0m
│   │   │   │   ├── Dismiss.swift
│   │   │   │   └── IsPresented.swift
│   │   │   ├── [01;34mDocumentation.docc[0m
│   │   │   │   ├── [01;34mArticles[0m
│   │   │   │   │   ├── [01;34mMigrationGuides[0m
│   │   │   │   │   │   ├── MigratingTo1.10.md
│   │   │   │   │   │   ├── MigratingTo1.11.md
│   │   │   │   │   │   ├── MigratingTo1.12.md
│   │   │   │   │   │   ├── MigratingTo1.13.md
│   │   │   │   │   │   ├── MigratingTo1.14.md
│   │   │   │   │   │   ├── MigratingTo1.15.md
│   │   │   │   │   │   ├── MigratingTo1.16.md
│   │   │   │   │   │   ├── MigratingTo1.17.1.md
│   │   │   │   │   │   ├── MigratingTo1.17.md
│   │   │   │   │   │   ├── MigratingTo1.18.md
│   │   │   │   │   │   ├── MigratingTo1.19.md
│   │   │   │   │   │   ├── MigratingTo1.4.md
│   │   │   │   │   │   ├── MigratingTo1.5.md
│   │   │   │   │   │   ├── MigratingTo1.6.md
│   │   │   │   │   │   ├── MigratingTo1.7.md
│   │   │   │   │   │   ├── MigratingTo1.8.md
│   │   │   │   │   │   └── MigratingTo1.9.md
│   │   │   │   │   ├── Bindings.md
│   │   │   │   │   ├── DependencyManagement.md
│   │   │   │   │   ├── FAQ.md
│   │   │   │   │   ├── GettingStarted.md
│   │   │   │   │   ├── MigrationGuides.md
│   │   │   │   │   ├── Navigation.md
│   │   │   │   │   ├── ObservationBackport.md
│   │   │   │   │   ├── Performance.md
│   │   │   │   │   ├── SharingState.md
│   │   │   │   │   ├── StackBasedNavigation.md
│   │   │   │   │   ├── SwiftConcurrency.md
│   │   │   │   │   ├── TestingTCA.md
│   │   │   │   │   ├── TreeBasedNavigation.md
│   │   │   │   │   └── WhatIsNavigation.md
│   │   │   │   ├── [01;34mExtensions[0m
│   │   │   │   │   ├── [01;34mDeprecations[0m
│   │   │   │   │   │   ├── ReducerDeprecations.md
│   │   │   │   │   │   ├── ScopeDeprecations.md
│   │   │   │   │   │   ├── StoreDeprecations.md
│   │   │   │   │   │   ├── SwiftUIDeprecations.md
│   │   │   │   │   │   └── TestStoreDeprecations.md
│   │   │   │   │   ├── Action.md
│   │   │   │   │   ├── Effect.md
│   │   │   │   │   ├── EffectRun.md
│   │   │   │   │   ├── EffectSend.md
│   │   │   │   │   ├── IdentifiedAction.md
│   │   │   │   │   ├── NavigationLinkState.md
│   │   │   │   │   ├── ObservableState.md
│   │   │   │   │   ├── Presents.md
│   │   │   │   │   ├── Reduce.md
│   │   │   │   │   ├── Reducer.md
│   │   │   │   │   ├── ReducerBody.md
│   │   │   │   │   ├── ReducerBuilder.md
│   │   │   │   │   ├── ReducerForEach.md
│   │   │   │   │   ├── ReducerlIfLet.md
│   │   │   │   │   ├── ReducerlIfLetPresentation.md
│   │   │   │   │   ├── ReducerMacro.md
│   │   │   │   │   ├── Scope.md
│   │   │   │   │   ├── State.md
│   │   │   │   │   ├── Store.md
│   │   │   │   │   ├── StoreDynamicMemberLookup.md
│   │   │   │   │   ├── StoreState.md
│   │   │   │   │   ├── SwiftUIBinding.md
│   │   │   │   │   ├── SwiftUIBindingScopeForEach.md
│   │   │   │   │   ├── SwiftUIBindingScopeIfLet.md
│   │   │   │   │   ├── SwiftUIBindingSubscript.md
│   │   │   │   │   ├── SwiftUIIntegration.md
│   │   │   │   │   ├── SwitchStore.md
│   │   │   │   │   ├── TaskResult.md
│   │   │   │   │   ├── TestStore.md
│   │   │   │   │   ├── TestStoreDependencies.md
│   │   │   │   │   ├── TestStoreExhaustivity.md
│   │   │   │   │   ├── UIKit.md
│   │   │   │   │   ├── ViewStore.md
│   │   │   │   │   ├── ViewStoreBinding.md
│   │   │   │   │   ├── WithViewStore.md
│   │   │   │   │   └── WithViewStoreInit.md
│   │   │   │   ├── [01;34mResources[0m
│   │   │   │   │   ├── [01;35m01-02-image-0003.png[0m
│   │   │   │   │   ├── [01;35m01-02-video-0005.mp4[0m
│   │   │   │   │   ├── [01;35m01-02-video-0006.mp4[0m
│   │   │   │   │   ├── [01;35m01-03-image-0005.jpg[0m
│   │   │   │   │   ├── [01;35m01-homepage.png[0m
│   │   │   │   │   ├── [01;35m02-01-image-0001.png[0m
│   │   │   │   │   ├── [01;35m02-02-video-0005.mov[0m
│   │   │   │   │   ├── [01;35m02-homepage.png[0m
│   │   │   │   │   ├── [01;35m03-03-video-0006.mp4[0m
│   │   │   │   │   ├── [01;35mch02-sub01-sec01-image-0001.png[0m
│   │   │   │   │   ├── [01;35mch02-sub01-sec01-image-0002.png[0m
│   │   │   │   │   ├── [01;35mch02-sub01-sec03-image-0000.mov[0m
│   │   │   │   │   ├── [01;35mch02-sub02-sec01-0000.mov[0m
│   │   │   │   │   ├── [01;35mch02-sub04-sec01-image-0000.png[0m
│   │   │   │   │   ├── [01;35mch02-sub04-sec01-video-0000.mov[0m
│   │   │   │   │   └── [01;35mch02-sub04-sec03-video-0000.mp4[0m
│   │   │   │   ├── [01;34mTutorials[0m
│   │   │   │   │   ├── [01;34mBuildingSyncUps[0m
│   │   │   │   │   │   ├── [01;34m01-WhatIsSyncUps[0m
│   │   │   │   │   │   │   ├── [01;35mCreateProject-0001-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mCreateProject-0002-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mCreateProject-0003-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mCreateProject-0004-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0003-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0004-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0005-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0006-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0007-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0008-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0009-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0010-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0011-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0012-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0013-image.png[0m
│   │   │   │   │   │   │   ├── [01;35mTourOfSyncUps-0014-image.png[0m
│   │   │   │   │   │   │   └── WhatIsSyncUps.tutorial
│   │   │   │   │   │   ├── [01;34m02-ListsOfSyncUps[0m
│   │   │   │   │   │   │   ├── ListsOfSyncUps-01-code-0001.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-01-code-0002.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-01-code-0003.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-01-code-0004.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0001.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0002.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0003.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0004.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0005.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0006-previous.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0006.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0007.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0008.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-02-code-0009.swift
│   │   │   │   │   │   │   ├── [01;35mListsOfSyncUps-02-code-0010.mp4[0m
│   │   │   │   │   │   │   ├── ListsOfSyncUps-03-code-0001-previous.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-03-code-0001.swift
│   │   │   │   │   │   │   ├── ListsOfSyncUps-03-code-0002.diff
│   │   │   │   │   │   │   ├── [01;35mListsOfSyncUps-cover.png[0m
│   │   │   │   │   │   │   ├── ListsOfSyncUps.tutorial
│   │   │   │   │   │   │   ├── TestingListOfSyncUps-01-code-0001.swift
│   │   │   │   │   │   │   ├── TestingListOfSyncUps-01-code-0002.swift
│   │   │   │   │   │   │   ├── TestingListOfSyncUps-01-code-0003.swift
│   │   │   │   │   │   │   ├── TestingListOfSyncUps-01-code-0004.swift
│   │   │   │   │   │   │   └── TestingListOfSyncUps.tutorial
│   │   │   │   │   │   ├── [01;34m03-SyncUpForm[0m
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0004.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0005.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0006.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0007.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0008.swift
│   │   │   │   │   │   │   ├── SyncUpForm-01-code-0009.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0004.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0005.swift
│   │   │   │   │   │   │   ├── SyncUpForm-02-code-0006.swift
│   │   │   │   │   │   │   ├── [01;35mSyncUpForm-02-video-0007.mp4[0m
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0001-previous.swift
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0004-previous.swift
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0004.swift
│   │   │   │   │   │   │   ├── SyncUpForm-03-code-0005.swift
│   │   │   │   │   │   │   ├── SyncUpForm.tutorial
│   │   │   │   │   │   │   ├── [01;35mSyncUpFormBasics-01-0000.png[0m
│   │   │   │   │   │   │   ├── TestingSyncUpForm-01-code-0001.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-01-code-0002.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-01-code-0003.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-01-code-0004-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-01-code-0004.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-01-code-0005.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0001.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0002.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0003.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0004-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0004.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0005.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0006-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0006.swift
│   │   │   │   │   │   │   ├── TestingSyncUpForm-02-code-0007.swift
│   │   │   │   │   │   │   └── TestingSyncUpForm.tutorial
│   │   │   │   │   │   ├── [01;34m04-PresentingSyncUpForm[0m
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-01-code-0001-previous.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-01-code-0001.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-01-code-0002.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-01-code-0003.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-01-code-0004.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-01-code-0005.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-02-code-0001.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-02-code-0002.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-02-code-0003.swift
│   │   │   │   │   │   │   ├── [01;35mPresentingSyncUpForm-02-video-0004.mov[0m
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0001-previous.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0001.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0002.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0003-previous.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0003.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0004.swift
│   │   │   │   │   │   │   ├── PresentingSyncUpForm-03-code-0005.swift
│   │   │   │   │   │   │   ├── [01;35mPresentingSyncUpForm-03-code-0006.mov[0m
│   │   │   │   │   │   │   ├── PresentingSyncUpForm.tutorial
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0001-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0001.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0002.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0003.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0004.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0005-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0005.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0006.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0007-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0007.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0008.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0009.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0010.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0011.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0012.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0013.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-01-code-0014.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0001.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0002.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0003.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0004.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0005.swift
│   │   │   │   │   │   │   ├── TestingSyncUpFormPresentation-02-code-0006.swift
│   │   │   │   │   │   │   └── TestingSyncUpFormPresentation.tutorial
│   │   │   │   │   │   ├── [01;34m05-PersistingSyncUps[0m
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0001-previous.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0001.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0002.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0003.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0004.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0005.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0006-previous.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0006.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-01-code-0007.swift
│   │   │   │   │   │   │   ├── [01;35mPersistingSyncUps-01-video-0008.mov[0m
│   │   │   │   │   │   │   ├── PersistingSyncUps-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-02-code-0001.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-02-code-0002.swift
│   │   │   │   │   │   │   ├── PersistingSyncUps-02-code-0003.swift
│   │   │   │   │   │   │   └── PersistingSyncUps.tutorial
│   │   │   │   │   │   ├── [01;34m06-SyncUpDetail[0m
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0001-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0001.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0002.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0003.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0004.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0005-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0005.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0006.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0007.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0008.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0009-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0009.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0010.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-01-code-0011.swift
│   │   │   │   │   │   │   ├── [01;35mEditingAndDeletingSyncUp-01-cover-480p.mov[0m
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0001.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0002.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0003.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0004.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0005.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0006.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0007.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0008.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0009.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0010.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0011.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0012.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0013.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0014-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-02-code-0014.swift
│   │   │   │   │   │   │   ├── [01;35mEditingAndDeletingSyncUp-02-cover-480p.mov[0m
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0001-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0001.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0002.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0003-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0003.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0004.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0005.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0006.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0007.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0008.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0009.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0010.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0011.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0012.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0013-previous.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp-03-code-0013.swift
│   │   │   │   │   │   │   ├── EditingAndDeletingSyncUp.tutorial
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0004.swift
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0005.swift
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0006.swift
│   │   │   │   │   │   │   ├── SyncUpDetail-01-code-0007.swift
│   │   │   │   │   │   │   ├── [01;35mSyncUpDetail-01-image-0007.png[0m
│   │   │   │   │   │   │   ├── [01;35mSyncUpDetail-cover.png[0m
│   │   │   │   │   │   │   ├── SyncUpDetail.tutorial
│   │   │   │   │   │   │   ├── TestingSyncUpDetail-01-code-0001.swift
│   │   │   │   │   │   │   ├── TestingSyncUpDetail-01-code-0002.swift
│   │   │   │   │   │   │   ├── TestingSyncUpDetail-01-code-0003.swift
│   │   │   │   │   │   │   ├── TestingSyncUpDetail-01-code-0004.swift
│   │   │   │   │   │   │   ├── TestingSyncUpDetail-01-code-0005.swift
│   │   │   │   │   │   │   ├── TestingSyncUpDetail-01-code-0006.swift
│   │   │   │   │   │   │   └── TestingSyncUpDetail.tutorial
│   │   │   │   │   │   ├── [01;34m07-SyncUpDetailNavigation[0m
│   │   │   │   │   │   │   ├── MeetingNavigation-01-code-0001.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-01-code-0002.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-01-code-0003.swift
│   │   │   │   │   │   │   ├── [01;35mMeetingNavigation-01-cover.png[0m
│   │   │   │   │   │   │   ├── MeetingNavigation-02-code-0001.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-02-code-0002.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-02-code-0003-previous.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-02-code-0003.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-02-code-0004-previous.swift
│   │   │   │   │   │   │   ├── MeetingNavigation-02-code-0004.swift
│   │   │   │   │   │   │   ├── MeetingNavigation.tutorial
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0004.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0005.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0006.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0007.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-01-code-0008.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0004.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0005.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0006.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-02-code-0007.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-03-code-0001-previous.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-03-code-0001.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-03-code-0002.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-03-code-0003.swift
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation-03-code-0004.swift
│   │   │   │   │   │   │   ├── [01;35mSyncUpDetailNavigation-03-video-0005.mov[0m
│   │   │   │   │   │   │   ├── [01;35mSyncUpDetailNavigation-03-video-0006.mov[0m
│   │   │   │   │   │   │   ├── SyncUpDetailNavigation.tutorial
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0001.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0002.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0003.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0004.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0005.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0006.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0007.swift
│   │   │   │   │   │   │   ├── TestingNavigation-01-code-0008.swift
│   │   │   │   │   │   │   └── TestingNavigation.tutorial
│   │   │   │   │   │   ├── [01;34m08-RecordMeeting[0m
│   │   │   │   │   │   │   ├── ImplementingSpeechRecognizer.tutorial
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0001-previous.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0001.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0002.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0003.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0004.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0005.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0006.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0007.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0008.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0009.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0010.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0011-previous.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-01-code-0011.swift
│   │   │   │   │   │   │   ├── [01;35mImplementingTimer-01-video-0012.mov[0m
│   │   │   │   │   │   │   ├── ImplementingTimer-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-02-code-0001.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-02-code-0002.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-02-code-0003.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-02-code-0004.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0001-previous.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0001.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0002.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0003.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0004.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0005.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0006.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0007.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-03-code-0008.swift
│   │   │   │   │   │   │   ├── [01;35mImplementingTimer-03-video-0009.mov[0m
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0001.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0002.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0003.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0004.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0005.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0006.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0007.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0008.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0009.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0010.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0011.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0012.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0013.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0014.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0015.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0016.swift
│   │   │   │   │   │   │   ├── ImplementingTimer-04-code-0017.swift
│   │   │   │   │   │   │   ├── ImplementingTimer.tutorial
│   │   │   │   │   │   │   ├── RecordMeetingFeature-01-code-0001.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-01-code-0002.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-01-code-0003.swift
│   │   │   │   │   │   │   ├── [01;35mRecordMeetingFeature-01-image-0004.jpg[0m
│   │   │   │   │   │   │   ├── RecordMeetingFeature-02-code-0001-previous.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-02-code-0001.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-02-code-0002-previous.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-02-code-0002.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-02-code-0003-previous.swift
│   │   │   │   │   │   │   ├── RecordMeetingFeature-02-code-0003.swift
│   │   │   │   │   │   │   ├── [01;35mRecordMeetingFeature-02-video-0004.mov[0m
│   │   │   │   │   │   │   └── RecordMeetingFeature.tutorial
│   │   │   │   │   │   └── BuildingSyncUps.tutorial
│   │   │   │   │   └── [01;34mMeetTheComposableArchitecture[0m
│   │   │   │   │       ├── [01;34m01-Essentials[0m
│   │   │   │   │       │   ├── [01;34m01-YourFirstFeature[0m
│   │   │   │   │       │   │   ├── 01-01-01-code-0001.swift
│   │   │   │   │       │   │   ├── 01-01-01-code-0002.swift
│   │   │   │   │       │   │   ├── 01-01-01-code-0003.swift
│   │   │   │   │       │   │   ├── 01-01-01-code-0004.swift
│   │   │   │   │       │   │   ├── 01-01-01-code-0005.swift
│   │   │   │   │       │   │   ├── 01-01-01-code-0006.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0001.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0002.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0003.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0004.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0005.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0006.swift
│   │   │   │   │       │   │   ├── 01-01-02-code-0007.swift
│   │   │   │   │       │   │   ├── 01-01-03-code-0001.swift
│   │   │   │   │       │   │   ├── 01-01-03-code-0002.swift
│   │   │   │   │       │   │   ├── 01-01-03-code-0003.swift
│   │   │   │   │       │   │   ├── 01-01-03-code-0004.swift
│   │   │   │   │       │   │   └── 01-01-YourFirstFeature.tutorial
│   │   │   │   │       │   ├── [01;34m02-AddingSideEffects[0m
│   │   │   │   │       │   │   ├── 01-02-01-code-0001-previous.swift
│   │   │   │   │       │   │   ├── 01-02-01-code-0001.swift
│   │   │   │   │       │   │   ├── 01-02-01-code-0002.swift
│   │   │   │   │       │   │   ├── 01-02-01-code-0003.swift
│   │   │   │   │       │   │   ├── 01-02-01-code-0004.swift
│   │   │   │   │       │   │   ├── 01-02-01-code-0005.swift
│   │   │   │   │       │   │   ├── 01-02-02-code-0001.swift
│   │   │   │   │       │   │   ├── 01-02-02-code-0002.swift
│   │   │   │   │       │   │   ├── 01-02-02-code-0003.swift
│   │   │   │   │       │   │   ├── 01-02-02-code-0004.swift
│   │   │   │   │       │   │   ├── 01-02-02-code-0005.swift
│   │   │   │   │       │   │   ├── 01-02-03-code-0001.swift
│   │   │   │   │       │   │   ├── 01-02-03-code-0002.swift
│   │   │   │   │       │   │   ├── 01-02-03-code-0003.swift
│   │   │   │   │       │   │   ├── 01-02-03-code-0004.swift
│   │   │   │   │       │   │   ├── 01-02-03-code-0005.swift
│   │   │   │   │       │   │   ├── 01-02-03-code-0006.swift
│   │   │   │   │       │   │   └── 01-02-AddingSideEffects.tutorial
│   │   │   │   │       │   ├── [01;34m03-TestingYourFeatures[0m
│   │   │   │   │       │   │   ├── 01-03-01-code-0001.swift
│   │   │   │   │       │   │   ├── 01-03-01-code-0002.swift
│   │   │   │   │       │   │   ├── 01-03-01-code-0003-previous.swift
│   │   │   │   │       │   │   ├── 01-03-01-code-0003.swift
│   │   │   │   │       │   │   ├── 01-03-01-code-0004.swift
│   │   │   │   │       │   │   ├── 01-03-01-code-0005.swift
│   │   │   │   │       │   │   ├── 01-03-01-code-0006.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0001-previous.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0001.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0002.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0003.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0004.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0005.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0006.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0007.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0008.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0009.swift
│   │   │   │   │       │   │   ├── 01-03-02-code-0010.swift
│   │   │   │   │       │   │   ├── 01-03-03-code-0001-previous.swift
│   │   │   │   │       │   │   ├── 01-03-03-code-0001.swift
│   │   │   │   │       │   │   ├── 01-03-03-code-0002.swift
│   │   │   │   │       │   │   ├── 01-03-03-code-0003.swift
│   │   │   │   │       │   │   ├── 01-03-03-code-0004.swift
│   │   │   │   │       │   │   ├── 01-03-03-code-0005.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0001.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0002.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0003.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0004.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0005.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0006-previous.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0006.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0007.swift
│   │   │   │   │       │   │   ├── 01-03-04-code-0008.swift
│   │   │   │   │       │   │   └── 01-03-TestingYourFeature.tutorial
│   │   │   │   │       │   └── [01;34m04-ComposingFeatures[0m
│   │   │   │   │       │       ├── 01-04-01-code-0001.swift
│   │   │   │   │       │       ├── 01-04-01-code-0002.swift
│   │   │   │   │       │       ├── 01-04-01-code-0003.swift
│   │   │   │   │       │       ├── 01-04-02-code-0001.swift
│   │   │   │   │       │       ├── 01-04-02-code-0002.swift
│   │   │   │   │       │       ├── 01-04-02-code-0003.swift
│   │   │   │   │       │       ├── 01-04-02-code-0004.swift
│   │   │   │   │       │       ├── 01-04-02-code-0005.swift
│   │   │   │   │       │       ├── 01-04-02-code-0006.swift
│   │   │   │   │       │       ├── 01-04-02-code-0007.swift
│   │   │   │   │       │       ├── 01-04-02-code-0008.swift
│   │   │   │   │       │       ├── 01-04-03-code-0001-previous.swift
│   │   │   │   │       │       ├── 01-04-03-code-0001.swift
│   │   │   │   │       │       ├── 01-04-03-code-0002.swift
│   │   │   │   │       │       ├── 01-04-03-code-0003.swift
│   │   │   │   │       │       ├── 01-04-03-code-0004.swift
│   │   │   │   │       │       ├── 01-04-03-code-0005-previous.swift
│   │   │   │   │       │       ├── 01-04-03-code-0005.swift
│   │   │   │   │       │       └── 01-04-ComposingFeatures.tutorial
│   │   │   │   │       ├── [01;34m02-Navigation[0m
│   │   │   │   │       │   ├── [01;34m01-YourFirstPresentation[0m
│   │   │   │   │       │   │   ├── 02-01-01-code-0000.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0001.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0002.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0003.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0004.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0005.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0006.swift
│   │   │   │   │       │   │   ├── 02-01-01-code-0007.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0000.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0001.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0002.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0003.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0004.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0005.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0006.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0007.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0008.swift
│   │   │   │   │       │   │   ├── 02-01-02-code-0009.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0000-previous.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0000.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0001.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0002.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0003-previous.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0003.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0004-previous.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0004.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0005.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0006.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0007-previous.swift
│   │   │   │   │       │   │   ├── 02-01-04-code-0007.swift
│   │   │   │   │       │   │   └── 02-01-YourFirstPresentation.tutorial
│   │   │   │   │       │   ├── [01;34m02-MultipleDestinations[0m
│   │   │   │   │       │   │   ├── 02-02-01-code-0000-previous.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0000.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0001.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0002.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0003.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0004.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0005.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0006-previous.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0006.swift
│   │   │   │   │       │   │   ├── 02-02-01-code-0007.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0000.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0001.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0002.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0003.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0004-previous.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0004.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0005-previous.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0005.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0006-previous.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0006.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0007.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0008.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0009.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0010.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0011.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0012.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0013-previous.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0013.swift
│   │   │   │   │       │   │   ├── 02-02-02-code-0014.swift
│   │   │   │   │       │   │   └── 02-02-MultipleDestinations.tutorial
│   │   │   │   │       │   ├── [01;34m03-TestingPresentation[0m
│   │   │   │   │       │   │   ├── 02-03-01-code-0000.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0001.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0002.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0003.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0004.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0005.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0006-previous.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0006.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0007.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0008-previous.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0008.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0009.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0010.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0011.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0012.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0013.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0014.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0015-previous.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0015.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0016.swift
│   │   │   │   │       │   │   ├── 02-03-01-code-0017.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0000.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0001.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0002.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0003.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0004.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0005.swift
│   │   │   │   │       │   │   ├── 02-03-02-code-0006.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0000.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0001.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0002.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0003.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0004.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0005.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0006.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0007-previous.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0007.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0008-previous.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0008.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0009.swift
│   │   │   │   │       │   │   ├── 02-03-03-code-0010.swift
│   │   │   │   │       │   │   └── 02-03-TestingPresentation.tutorial
│   │   │   │   │       │   └── [01;34m04-NavigationStacks[0m
│   │   │   │   │       │       ├── 02-04-01-code-0000.swift
│   │   │   │   │       │       ├── 02-04-01-code-0001.swift
│   │   │   │   │       │       ├── 02-04-01-code-0002.swift
│   │   │   │   │       │       ├── 02-04-01-code-0003.swift
│   │   │   │   │       │       ├── 02-04-01-code-0004.swift
│   │   │   │   │       │       ├── 02-04-01-code-0005.swift
│   │   │   │   │       │       ├── 02-04-01-code-0006.swift
│   │   │   │   │       │       ├── 02-04-01-code-0007.swift
│   │   │   │   │       │       ├── 02-04-02-code-0000-previous.swift
│   │   │   │   │       │       ├── 02-04-02-code-0000.swift
│   │   │   │   │       │       ├── 02-04-02-code-0001.swift
│   │   │   │   │       │       ├── 02-04-02-code-0002.swift
│   │   │   │   │       │       ├── 02-04-02-code-0003-previous.swift
│   │   │   │   │       │       ├── 02-04-02-code-0003.swift
│   │   │   │   │       │       ├── 02-04-02-code-0004.swift
│   │   │   │   │       │       ├── 02-04-02-code-0005-previous.swift
│   │   │   │   │       │       ├── 02-04-02-code-0005.swift
│   │   │   │   │       │       ├── 02-04-02-code-0006-previous.swift
│   │   │   │   │       │       ├── 02-04-02-code-0006.swift
│   │   │   │   │       │       ├── 02-04-03-code-0000-previous.swift
│   │   │   │   │       │       ├── 02-04-03-code-0000.swift
│   │   │   │   │       │       ├── 02-04-03-code-0001.swift
│   │   │   │   │       │       ├── 02-04-03-code-0002.swift
│   │   │   │   │       │       ├── 02-04-03-code-0003-previous.swift
│   │   │   │   │       │       ├── 02-04-03-code-0003.swift
│   │   │   │   │       │       ├── 02-04-03-code-0004-previous.swift
│   │   │   │   │       │       ├── 02-04-03-code-0004.swift
│   │   │   │   │       │       └── 02-04-NavigationStacks.tutorial
│   │   │   │   │       ├── [01;35mchapter1.png[0m
│   │   │   │   │       ├── [01;35mchapter2.png[0m
│   │   │   │   │       ├── [01;35mchapter3.png[0m
│   │   │   │   │       ├── [01;35mchapter4.png[0m
│   │   │   │   │       ├── [01;35mchapter5.png[0m
│   │   │   │   │       ├── [01;35mchapter6.png[0m
│   │   │   │   │       ├── [01;35mchapter7.png[0m
│   │   │   │   │       ├── [01;35mchapter8.png[0m
│   │   │   │   │       └── MeetComposableArchitecture.tutorial
│   │   │   │   └── ComposableArchitecture.md
│   │   │   ├── [01;34mEffects[0m
│   │   │   │   ├── Animation.swift
│   │   │   │   ├── Cancellation.swift
│   │   │   │   ├── Debounce.swift
│   │   │   │   ├── Publisher.swift
│   │   │   │   ├── TaskResult.swift
│   │   │   │   └── Throttle.swift
│   │   │   ├── [01;34mInternal[0m
│   │   │   │   ├── AreOrderedSetsDuplicates.swift
│   │   │   │   ├── AssumeIsolated.swift
│   │   │   │   ├── Box.swift
│   │   │   │   ├── Create.swift
│   │   │   │   ├── CurrentValueRelay.swift
│   │   │   │   ├── Debug.swift
│   │   │   │   ├── DefaultSubscript.swift
│   │   │   │   ├── Deprecations.swift
│   │   │   │   ├── DispatchQueue.swift
│   │   │   │   ├── EffectActions.swift
│   │   │   │   ├── EphemeralState.swift
│   │   │   │   ├── Exports.swift
│   │   │   │   ├── HashableStaticString.swift
│   │   │   │   ├── KeyPath+Sendable.swift
│   │   │   │   ├── Locking.swift
│   │   │   │   ├── Logger.swift
│   │   │   │   ├── NavigationID.swift
│   │   │   │   ├── NotificationName.swift
│   │   │   │   ├── OpenExistential.swift
│   │   │   │   ├── PresentationID.swift
│   │   │   │   ├── ReturningLastNonNilValue.swift
│   │   │   │   ├── RuntimeWarnings.swift
│   │   │   │   └── StackIDGenerator.swift
│   │   │   ├── [01;34mObservation[0m
│   │   │   │   ├── Alert+Observation.swift
│   │   │   │   ├── Binding+Observation.swift
│   │   │   │   ├── IdentifiedArray+Observation.swift
│   │   │   │   ├── NavigationStack+Observation.swift
│   │   │   │   ├── ObservableState.swift
│   │   │   │   ├── ObservationStateRegistrar.swift
│   │   │   │   ├── Store+Observation.swift
│   │   │   │   └── ViewAction.swift
│   │   │   ├── [01;34mReducer[0m
│   │   │   │   ├── [01;34mReducers[0m
│   │   │   │   │   ├── BindingReducer.swift
│   │   │   │   │   ├── CombineReducers.swift
│   │   │   │   │   ├── DebugReducer.swift
│   │   │   │   │   ├── DependencyKeyWritingReducer.swift
│   │   │   │   │   ├── EmptyReducer.swift
│   │   │   │   │   ├── ForEachReducer.swift
│   │   │   │   │   ├── IfCaseLetReducer.swift
│   │   │   │   │   ├── IfLetReducer.swift
│   │   │   │   │   ├── OnChange.swift
│   │   │   │   │   ├── Optional.swift
│   │   │   │   │   ├── PresentationReducer.swift
│   │   │   │   │   ├── Reduce.swift
│   │   │   │   │   ├── Scope.swift
│   │   │   │   │   ├── SignpostReducer.swift
│   │   │   │   │   └── StackReducer.swift
│   │   │   │   └── ReducerBuilder.swift
│   │   │   ├── [01;34mResources[0m
│   │   │   │   └── PrivacyInfo.xcprivacy
│   │   │   ├── [01;34mSharing[0m
│   │   │   │   └── AppStorageKeyPathKey.swift
│   │   │   ├── [01;34mSwiftUI[0m
│   │   │   │   ├── [01;34mDeprecated[0m
│   │   │   │   │   ├── ActionSheet.swift
│   │   │   │   │   ├── LegacyAlert.swift
│   │   │   │   │   └── NavigationLinkStore.swift
│   │   │   │   ├── Alert.swift
│   │   │   │   ├── Binding.swift
│   │   │   │   ├── ConfirmationDialog.swift
│   │   │   │   ├── ForEachStore.swift
│   │   │   │   ├── FullScreenCover.swift
│   │   │   │   ├── IfLetStore.swift
│   │   │   │   ├── NavigationDestination.swift
│   │   │   │   ├── NavigationStackStore.swift
│   │   │   │   ├── Popover.swift
│   │   │   │   ├── PresentationModifier.swift
│   │   │   │   ├── Sheet.swift
│   │   │   │   ├── SwitchStore.swift
│   │   │   │   └── WithViewStore.swift
│   │   │   ├── [01;34mUIKit[0m
│   │   │   │   ├── AlertStateUIKit.swift
│   │   │   │   ├── IfLetUIKit.swift
│   │   │   │   └── NavigationStackControllerUIKit.swift
│   │   │   ├── CaseReducer.swift
│   │   │   ├── Core.swift
│   │   │   ├── Effect.swift
│   │   │   ├── Macros.swift
│   │   │   ├── Reducer.swift
│   │   │   ├── Store.swift
│   │   │   ├── TestStore.swift
│   │   │   └── ViewStore.swift
│   │   └── [01;34mComposableArchitectureMacros[0m
│   │       ├── Availability.swift
│   │       ├── Extensions.swift
│   │       ├── ObservableStateMacro.swift
│   │       ├── Plugins.swift
│   │       ├── PresentsMacro.swift
│   │       ├── ReducerMacro.swift
│   │       └── ViewActionMacro.swift
│   ├── [01;34mTests[0m
│   │   ├── [01;34mComposableArchitectureMacrosTests[0m
│   │   │   ├── MacroBaseTestCase.swift
│   │   │   ├── ObservableStateMacroTests.swift
│   │   │   ├── PresentsMacroTests.swift
│   │   │   ├── ReducerMacroTests.swift
│   │   │   └── ViewActionMacroTests.swift
│   │   └── [01;34mComposableArchitectureTests[0m
│   │       ├── [01;34mInternal[0m
│   │       │   ├── BaseTCATestCase.swift
│   │       │   └── TestHelpers.swift
│   │       ├── [01;34mReducers[0m
│   │       │   ├── BindingReducerTests.swift
│   │       │   ├── ForEachReducerTests.swift
│   │       │   ├── IfCaseLetReducerTests.swift
│   │       │   ├── IfLetReducerTests.swift
│   │       │   ├── OnChangeReducerTests.swift
│   │       │   ├── PresentationReducerTests.swift
│   │       │   └── StackReducerTests.swift
│   │       ├── BindableStoreTests.swift
│   │       ├── BindingLocalTests.swift
│   │       ├── CompatibilityTests.swift
│   │       ├── ComposableArchitectureTests.swift
│   │       ├── CurrentValueRelayTests.swift
│   │       ├── DebugTests.swift
│   │       ├── DependencyKeyWritingReducerTests.swift
│   │       ├── EffectCancellationIsolationTests.swift
│   │       ├── EffectCancellationTests.swift
│   │       ├── EffectDebounceTests.swift
│   │       ├── EffectFailureTests.swift
│   │       ├── EffectOperationTests.swift
│   │       ├── EffectRunTests.swift
│   │       ├── EffectTests.swift
│   │       ├── EnumReducerMacroTests.swift
│   │       ├── MacroConformanceTests.swift
│   │       ├── MacroTests.swift
│   │       ├── MemoryManagementTests.swift
│   │       ├── ObservableStateEnumMacroTests.swift
│   │       ├── ObservableTests.swift
│   │       ├── ReducerBuilderTests.swift
│   │       ├── ReducerTests.swift
│   │       ├── RuntimeWarningTests.swift
│   │       ├── ScopeCacheTests.swift
│   │       ├── ScopeLoggerTests.swift
│   │       ├── ScopeTests.swift
│   │       ├── StoreLifetimeTests.swift
│   │       ├── StorePerceptionTests.swift
│   │       ├── StoreTests.swift
│   │       ├── TaskCancellationTests.swift
│   │       ├── TaskResultTests.swift
│   │       ├── TestStoreFailureTests.swift
│   │       ├── TestStoreNonExhaustiveTests.swift
│   │       ├── TestStoreTests.swift
│   │       ├── ThrottleTests.swift
│   │       └── ViewStoreTests.swift
│   ├── LICENSE
│   ├── Makefile
│   ├── Package.resolved
│   ├── Package.swift
│   ├── Package@swift-6.0.swift
│   └── README.md
├── [01;34mswift-composable-architecture-extras[0m
│   ├── [01;34mSources[0m
│   │   └── [01;34mComposableArchitectureExtras[0m
│   │       └── TaskResult+VoidSuccess.swift
│   ├── [01;34mTests[0m
│   │   └── [01;34mComposableArchitectureExtrasTests[0m
│   │       └── ComposableArchitectureExtrasTests.swift
│   ├── LICENSE
│   ├── Package.resolved
│   ├── Package.swift
│   └── README.md
├── [01;34mtca-composer[0m
│   ├── [01;34mci_scripts[0m
│   │   └── [01;32mci_post_clone.sh[0m
│   ├── [01;34mExamples[0m
│   │   ├── [01;34mSyncUps[0m
│   │   │   ├── [01;34mSyncUps[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   ├── [01;34mThemes[0m
│   │   │   │   │   │   ├── [01;34mbubblegum.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mbuttercup.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mindigo.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mlavender.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mmagenta.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mnavy.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34morange.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34moxblood.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mperiwinkle.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mpoppy.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mpurple.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mseafoam.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34msky.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mtan.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34mteal.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   ├── [01;34myellow.colorset[0m
│   │   │   │   │   │   │   └── Contents.json
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mDependencies[0m
│   │   │   │   │   ├── DataManager.swift
│   │   │   │   │   ├── OpenSettings.swift
│   │   │   │   │   └── SpeechRecognizer.swift
│   │   │   │   ├── [01;34mResources[0m
│   │   │   │   │   └── [00;36mding.wav[0m
│   │   │   │   ├── App.swift
│   │   │   │   ├── AppFeature.swift
│   │   │   │   ├── Meeting.swift
│   │   │   │   ├── Models.swift
│   │   │   │   ├── RecordMeeting.swift
│   │   │   │   ├── SyncUpDetail.swift
│   │   │   │   ├── SyncUpForm.swift
│   │   │   │   └── SyncUpsList.swift
│   │   │   ├── [01;34mSyncUps.xcodeproj[0m
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mSyncUpsTests[0m
│   │   │   │   ├── AppFeatureTests.swift
│   │   │   │   ├── RecordMeetingTests.swift
│   │   │   │   ├── SyncUpDetailTests.swift
│   │   │   │   ├── SyncUpFormTests.swift
│   │   │   │   └── SyncUpsListTests.swift
│   │   │   └── LICENSE
│   │   ├── [01;34mTodos[0m
│   │   │   ├── [01;34mTodos[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── Todo.swift
│   │   │   │   ├── Todos.swift
│   │   │   │   └── TodosApp.swift
│   │   │   ├── [01;34mTodos.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── Todos.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mTodosTests[0m
│   │   │   │   └── TodosTests.swift
│   │   │   ├── LICENSE
│   │   │   └── README.md
│   │   ├── [01;34mVoiceMemos[0m
│   │   │   ├── [01;34mVoiceMemos[0m
│   │   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   │   └── Contents.json
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mAudioPlayerClient[0m
│   │   │   │   │   ├── AudioPlayerClient.swift
│   │   │   │   │   └── LiveAudioPlayerClient.swift
│   │   │   │   ├── [01;34mAudioRecorderClient[0m
│   │   │   │   │   ├── AudioRecorderClient.swift
│   │   │   │   │   └── LiveAudioRecorderClient.swift
│   │   │   │   ├── Dependencies.swift
│   │   │   │   ├── Helpers.swift
│   │   │   │   ├── RecordingMemo.swift
│   │   │   │   ├── VoiceMemo.swift
│   │   │   │   ├── VoiceMemos.swift
│   │   │   │   └── VoiceMemosApp.swift
│   │   │   ├── [01;34mVoiceMemos.xcodeproj[0m
│   │   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │   │       └── VoiceMemos.xcscheme
│   │   │   │   └── project.pbxproj
│   │   │   ├── [01;34mVoiceMemosTests[0m
│   │   │   │   └── VoiceMemosTests.swift
│   │   │   ├── LICENSE
│   │   │   └── README.md
│   │   └── Package.swift
│   ├── [01;34mSources[0m
│   │   ├── [01;34mTCAComposer[0m
│   │   │   ├── [01;34mDocumentation.docc[0m
│   │   │   │   └── TCAComposer.md
│   │   │   ├── [01;34mMacros[0m
│   │   │   │   ├── ComposedReducerChild.swift
│   │   │   │   ├── ComposeMacros.swift
│   │   │   │   ├── ComposerMacro.swift
│   │   │   │   └── InternalMacros.swift
│   │   │   ├── ReduceAction.swift
│   │   │   ├── ScopePathable.swift
│   │   │   ├── ScopePathable+Bindable.swift
│   │   │   ├── ScopePathable+Store.swift
│   │   │   ├── ScopeSwitchable.swift
│   │   │   └── ScopeSwitchable+Store.swift
│   │   └── [01;34mTCAComposerMacros[0m
│   │       ├── [01;34mInternal[0m
│   │       │   ├── _ComposedActionMacro.swift
│   │       │   ├── _ComposedStateMemberMacro.swift
│   │       │   ├── _ComposerCasePathableActions.swift
│   │       │   ├── _ComposerScopePathableMacro.swift
│   │       │   └── _ComposerScopeSwitchableMacro.swift
│   │       ├── ComposeDirectiveMacro.swift
│   │       ├── Composer.swift
│   │       ├── ComposerMacro.swift
│   │       ├── Composition.swift
│   │       ├── Constants.swift
│   │       ├── Extensions.swift
│   │       ├── Plugin.swift
│   │       ├── ReducerAnalyzer.swift
│   │       └── SharedTypes.swift
│   ├── [01;34mTests[0m
│   │   ├── [01;34mTCAComposerMacroTests[0m
│   │   │   ├── [01;34mComposerDirectives[0m
│   │   │   │   ├── ActionAlertTests.swift
│   │   │   │   ├── ActionCaseTests.swift
│   │   │   │   ├── ActionConfirmationDialogTests.swift
│   │   │   │   ├── BodyActionAlertTests.swift
│   │   │   │   ├── BodyActionCaseTests.swift
│   │   │   │   ├── BodyActionConfirmationDialogTests.swift
│   │   │   │   ├── BodyOnChangeTests.swift
│   │   │   │   ├── BodyTests.swift
│   │   │   │   ├── MacroDirectiveStubs.swift
│   │   │   │   ├── ReducerExistingStateTests.swift
│   │   │   │   └── ScopePathTests.swift
│   │   │   ├── [01;34mComposeReducer[0m
│   │   │   │   ├── ComposeReducerMacroTests.swift
│   │   │   │   ├── EnumeratedReducerOptionTests.swift
│   │   │   │   ├── EnumReducerTests.swift
│   │   │   │   ├── ReducerDiagnosticTests.swift
│   │   │   │   ├── ReducerExistingStateActionTests.swift
│   │   │   │   └── ReducerOptionTests.swift
│   │   │   ├── [01;34mInternals[0m
│   │   │   │   ├── ComposedStateMacroTests.swift
│   │   │   │   └── ComposerScopeSwitchable.swift
│   │   │   ├── ComposedActionMacroTests.swift
│   │   │   ├── ComposedStateMemberMacroTests.swift
│   │   │   ├── ComposeNavigationDestinationMacroTests.swift
│   │   │   ├── ComposeNavigationPathMacroTests.swift
│   │   │   ├── ComposePresentationMacroTests.swift
│   │   │   └── ComposerMacroTests.swift
│   │   └── [01;34mTCAComposerTests[0m
│   │       ├── ComposerTests.swift
│   │       └── TestReducers.swift
│   ├── LICENSE
│   ├── Makefile
│   ├── Package.resolved
│   ├── Package.swift
│   └── README.md
├── [01;34mTCACoordinators[0m
│   ├── [01;34mDocs[0m
│   │   └── [01;34mMigration[0m
│   │       ├── Migrating from 0.11.md
│   │       └── Migrating from 0.8.md
│   ├── [01;34mSources[0m
│   │   └── [01;34mTCACoordinators[0m
│   │       ├── [01;34mDeprecations[0m
│   │       │   ├── IdentifiedRouterState.swift
│   │       │   └── IndexedRouterState.swift
│   │       ├── [01;34mReducers[0m
│   │       │   ├── CancelEffectsOnDismiss.swift
│   │       │   ├── ForEachIdentifiedRoute.swift
│   │       │   ├── ForEachIndexedRoute.swift
│   │       │   ├── ForEachReducer.swift
│   │       │   ├── OnRoutes.swift
│   │       │   └── UpdateRoutesOnInteraction.swift
│   │       ├── [01;34mTCARouter[0m
│   │       │   ├── IdentifiedRouterAction.swift
│   │       │   ├── IndexedRouterAction.swift
│   │       │   ├── RouterAction.swift
│   │       │   ├── TCARouter.swift
│   │       │   ├── TCARouter+IdentifiedScreen.swift
│   │       │   ├── TCARouter+IndexedScreen.swift
│   │       │   └── UnobservedTCARouter.swift
│   │       ├── Collection+safeSubscript.swift
│   │       ├── Effect+routeWithDelaysIfUnsupported.swift
│   │       ├── IdentifiedArray+RoutableCollection.swift
│   │       ├── Route+Hashable.swift
│   │       └── TCACoordinators.swift
│   ├── [01;34mTCACoordinatorsExample[0m
│   │   ├── [01;34mTCACoordinatorsExample[0m
│   │   │   ├── [01;34mAssets.xcassets[0m
│   │   │   │   ├── [01;34mAccentColor.colorset[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   ├── [01;34mAppIcon.appiconset[0m
│   │   │   │   │   └── Contents.json
│   │   │   │   └── Contents.json
│   │   │   ├── [01;34mForm[0m
│   │   │   │   ├── FinalScreen.swift
│   │   │   │   ├── FormAppCoordinator.swift
│   │   │   │   ├── FormScreen.swift
│   │   │   │   ├── FormScreen+Identifiable.swift
│   │   │   │   ├── Step1.swift
│   │   │   │   ├── Step2.swift
│   │   │   │   └── Step3.swift
│   │   │   ├── [01;34mGame[0m
│   │   │   │   ├── AppCoordinator.swift
│   │   │   │   ├── GameCoordinator.swift
│   │   │   │   ├── GameView.swift
│   │   │   │   ├── GameViewState.swift
│   │   │   │   ├── LogInCoordinator.swift
│   │   │   │   ├── LogInScreen+StateIdentifiable.swift
│   │   │   │   ├── LogInView.swift
│   │   │   │   ├── OutcomeView.swift
│   │   │   │   └── WelcomeView.swift
│   │   │   ├── [01;34mPreview Content[0m
│   │   │   │   └── [01;34mPreview Assets.xcassets[0m
│   │   │   │       └── Contents.json
│   │   │   ├── IdentifiedCoordinator.swift
│   │   │   ├── IndexedCoordinator.swift
│   │   │   ├── Info.plist
│   │   │   ├── Screen.swift
│   │   │   └── TCACoordinatorsExampleApp.swift
│   │   ├── [01;34mTCACoordinatorsExample.xcodeproj[0m
│   │   │   ├── [01;34mxcshareddata[0m
│   │   │   │   └── [01;34mxcschemes[0m
│   │   │   │       └── TCACoordinatorsExample.xcscheme
│   │   │   └── project.pbxproj
│   │   ├── [01;34mTCACoordinatorsExampleTests[0m
│   │   │   └── TCACoordinatorsExampleTests.swift
│   │   ├── [01;34mTCACoordinatorsExampleUITests[0m
│   │   │   ├── TCACoordinatorsExampleUITests.swift
│   │   │   └── TCACoordinatorsExampleUITestsLaunchTests.swift
│   │   └── Package.swift
│   ├── [01;34mTests[0m
│   │   └── [01;34mTCACoordinatorsTests[0m
│   │       ├── IdentifiedRouterTests.swift
│   │       └── IndexedRouterTests.swift
│   ├── LICENSE
│   ├── Package.resolved
│   ├── Package.swift
│   └── README.md
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
├── Gemfile
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
├── setup-environment.sh
├── SPEC_CHANGE.md
├── SPEC.json
├── SPEC.lock
├── STATUS.md
├── SWIFT6_UITEST_MIGRATION.md
├── tca_analysis.py
├── TCA_IMPLEMENTATION_STATUS.md
├── TESTING_WORKFLOW.md
├── THIRD_PARTY_LICENSES.md
├── TODO.md
├── TREE.md
├── UI_WIRING_INTEGRATION.md
├── [01;32mupdate_tree.sh[0m
├── [01;32mupload_to_testflight.sh[0m
├── verify_build.sh
├── XCODE_FIX.md
├── XCODE_UI_TESTING_GUIDE.md
└── XCUIAutomation-Definitive-Documentation.md

487 directories, 2050 files
```

_📁 Directories:  | 📄 Files: 
