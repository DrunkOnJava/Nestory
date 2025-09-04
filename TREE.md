# Project Structure

_Last updated: 2025-09-03 23:15:20_

```
[01;34m.[0m
├── [01;34mApp-Main[0m
│   ├── [01;34mAdvancedSearch[0m
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
│   ├── AddItemView.swift.deprecated
│   ├── AdvancedSearchView.swift
│   ├── BarcodeScannerView.swift
│   ├── CaptureView.swift
│   ├── CategoriesView.swift.deprecated
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
│   ├── Nestory-Dev.entitlements
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
├── [01;34mAssets[0m
│   └── [01;34mIcons[0m
│       └── [01;35mAppIcon.png[0m
├── [01;34mConfig[0m
│   ├── [01;34mStoreKit[0m
│   │   └── StoreKitConfiguration.storekit
│   ├── AccessibilityTesting.xcconfig
│   ├── Base.xcconfig
│   ├── BuildOptimization.xcconfig
│   ├── CONFIGURATION_SYSTEM.md
│   ├── Debug.xcconfig
│   ├── Dev.xcconfig
│   ├── Development.xcconfig
│   ├── EnvironmentConfiguration.swift
│   ├── FeatureFlags.swift
│   ├── flags.json
│   ├── MakefileConfig.mk
│   ├── Optimization.xcconfig
│   ├── PerformanceTesting.xcconfig
│   ├── Prod.xcconfig
│   ├── Production.xcconfig
│   ├── ProjectConfiguration.json
│   ├── Release.xcconfig
│   ├── Rings-Generated.md
│   ├── Rings.md
│   ├── Secrets.template.swift
│   ├── Staging.xcconfig
│   └── UITesting.xcconfig
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
├── [01;34mdocs[0m
│   ├── [01;34madr[0m
│   │   ├── ADR-001-tca-state-management.md
│   │   ├── ADR-002-swiftdata-persistence.md
│   │   └── ADR-003-six-layer-architecture.md
│   └── [01;34mreports[0m
│       └── ARCHAEOLOGICAL_LAYERS.md
├── [01;34mDocumentation[0m
│   ├── CRITICAL_FIXES_AUDIT_TEMPLATE.md
│   ├── CRITICAL_FIXES_COMPLETION_REPORT.md
│   └── ERROR_HANDLING_GUIDE.md
├── [01;34mfastlane[0m
│   ├── [01;34mactions[0m
│   │   └── enterprise_xcode_config.rb
│   ├── [01;34mcli[0m
│   │   └── [01;34mlib[0m
│   │       ├── command_executor.rb
│   │       ├── config_manager.rb
│   │       ├── environment_check.rb
│   │       ├── menu_system.rb
│   │       └── ui_helpers.rb
│   ├── [01;34mfastlane[0m
│   │   ├── [01;34mfastlane[0m
│   │   │   └── [01;34moutput[0m
│   │   │       └── [01;34mlogs[0m
│   │   └── [01;34moutput[0m
│   │       └── [01;34mlogs[0m
│   │           └── [01;34mtests[0m
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
│   │   └── [01;34mlogs[0m
│   ├── [01;34mscreenshots[0m
│   │   ├── [01;34men-US[0m
│   │   ├── [01;34men-US-iPhone-16-Pro-Max[0m
│   │   └── screenshots.html
│   ├── [01;34mxcode_ruby_scripts[0m
│   │   ├── [01;32mconfigure_frameworks.rb[0m
│   │   ├── [01;32mconfigure_test_integration.rb[0m
│   │   ├── [01;32mconfigure_ui_testing.rb[0m
│   │   ├── README.md
│   │   ├── [01;32msetup_environment.rb[0m
│   │   ├── [01;32mupdate_build_settings.rb[0m
│   │   └── [01;32mvalidate_configuration.rb[0m
│   ├── Deliverfile
│   ├── ExportOptions.plist
│   ├── Fastfile
│   ├── Gemfile.lock
│   ├── Pluginfile
│   ├── rating_config.json
│   ├── README.md
│   ├── report.xml
│   ├── screenshot_lanes.rb
│   ├── Snapfile
│   ├── upload_direct.rb
│   └── upload_testflight.rb
├── [01;34mFeatures[0m
│   ├── [01;34mAddItem[0m
│   │   ├── AddItemFeature.swift
│   │   └── AddItemView.swift
│   ├── [01;34mAnalytics[0m
│   │   ├── AnalyticsDashboardView.swift
│   │   └── AnalyticsFeature.swift
│   ├── [01;34mCategories[0m
│   │   ├── CategoriesView.swift
│   │   └── CategoryFeature.swift
│   ├── [01;34mInventory[0m
│   │   ├── InventoryFeature.swift
│   │   ├── InventoryFeature.swift.deprecated
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
│       │   ├── CloudStorageComponent.swift
│       │   ├── CurrencyConverterComponent.swift
│       │   ├── HelperViewsComponent.swift
│       │   ├── InsuranceClaimsComponent.swift
│       │   ├── NotificationSettingsComponent.swift
│       │   ├── ReceiptProcessingComponent.swift
│       │   ├── SettingsIndex.swift
│       │   ├── SettingsReceiptComponents.swift
│       │   ├── SettingsViewComponents.swift
│       │   ├── SupportComponent.swift
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
│   │   ├── ContainerFactory.swift
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
│   │   ├── ArrayTransformers.swift
│   │   ├── AuthTypes.swift
│   │   ├── BackupMetadata.swift
│   │   ├── BarcodeModels.swift
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
│   ├── [01;34mQuality[0m
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
│   ├── [01;34mVisionKit[0m
│   │   └── DocumentScannerView.swift
│   └── PerformanceMonitor.swift
├── [01;34mmonitoring[0m
│   ├── [01;34malerts[0m
│   │   ├── build-health.yml
│   │   └── critical-build-health.yml
│   ├── [01;34mconfig[0m
│   │   ├── [01;34mschemas[0m
│   │   │   └── environments-schema.json
│   │   ├── environments.json
│   │   ├── grafana.json
│   │   ├── prometheus-recording-rules.yml
│   │   ├── prometheus.yml
│   │   └── runners.conf.template
│   ├── [01;34mdashboards[0m
│   │   ├── build-errors-dashboard.json
│   │   ├── build-health-focused.json
│   │   ├── complete-base-dashboard.json
│   │   ├── complete-platform-final.json
│   │   ├── complete-platform-fixed.json
│   │   ├── comprehensive-dev.json
│   │   ├── comprehensive-fixes-wrapped.json
│   │   ├── comprehensive-fixes.json
│   │   ├── consolidated-build-health.json
│   │   ├── current-dashboard.json
│   │   ├── current-state.json
│   │   ├── current-updated.json
│   │   ├── current-v8.json
│   │   ├── current-wrapped.json
│   │   ├── current.json
│   │   ├── enhanced-complete-dashboard.json
│   │   ├── final-wrapped.json
│   │   ├── fixed-fundamentals-dashboard.json
│   │   ├── fixed-panels-wrapped.json
│   │   ├── fixed-panels.json
│   │   ├── ios-telemetry.json
│   │   ├── nry-full-template-complete.json
│   │   ├── nry-full-template.json
│   │   ├── production-prod.json
│   │   ├── real-data-only.json
│   │   ├── real-data-wrapped.json
│   │   ├── unified-dev-fixed.json
│   │   └── unified-dev.json
│   ├── [01;34mgrafana[0m
│   │   ├── [01;34mdashboards[0m
│   │   │   ├── ios-telemetry.json
│   │   │   └── unified-dev-fixed.json
│   │   └── [01;34mprovisioning[0m
│   │       ├── [01;34mdashboards[0m
│   │       │   └── dashboards.yaml
│   │       └── [01;34mdatasources[0m
│   │           └── datasources.yaml
│   ├── [01;34mgrafana-panels[0m
│   │   ├── build-errors-panel.json
│   │   ├── build-health-update.json
│   │   └── stuck-builds-panel.json
│   ├── [01;34mmcp-grafana[0m
│   │   ├── [01;34mcmd[0m
│   │   │   ├── [01;34mlinters[0m
│   │   │   │   └── [01;34mjsonschema[0m
│   │   │   │       └── main.go
│   │   │   └── [01;34mmcp-grafana[0m
│   │   │       └── main.go
│   │   ├── [01;34mexamples[0m
│   │   │   └── tls_example.go
│   │   ├── [01;34minternal[0m
│   │   │   └── [01;34mlinter[0m
│   │   │       └── [01;34mjsonschema[0m
│   │   │           ├── jsonschema_lint_test.go
│   │   │           ├── jsonschema_lint.go
│   │   │           └── README.md
│   │   ├── [01;34mtestdata[0m
│   │   │   ├── [01;34mdashboards[0m
│   │   │   │   └── demo.json
│   │   │   ├── [01;34mprovisioning[0m
│   │   │   │   ├── [01;34malerting[0m
│   │   │   │   │   ├── alert_rules.yaml
│   │   │   │   │   └── contact_points.yaml
│   │   │   │   ├── [01;34mdashboards[0m
│   │   │   │   │   └── dashboards.yaml
│   │   │   │   └── [01;34mdatasources[0m
│   │   │   │       └── datasources.yaml
│   │   │   ├── loki-config.yml
│   │   │   ├── [01;32mprometheus-entrypoint.sh[0m
│   │   │   ├── prometheus-seed.yml
│   │   │   ├── prometheus.yml
│   │   │   └── promtail-config.yml
│   │   ├── [01;34mtests[0m
│   │   │   ├── admin_test.py
│   │   │   ├── conftest.py
│   │   │   ├── dashboards_test.py
│   │   │   ├── loki_test.py
│   │   │   ├── navigation_test.py
│   │   │   ├── pyproject.toml
│   │   │   ├── README.md
│   │   │   ├── utils.py
│   │   │   └── uv.lock
│   │   ├── [01;34mtools[0m
│   │   │   ├── admin_test.go
│   │   │   ├── admin.go
│   │   │   ├── alerting_client_test.go
│   │   │   ├── alerting_client.go
│   │   │   ├── alerting_test.go
│   │   │   ├── alerting.go
│   │   │   ├── asserts_cloud_test.go
│   │   │   ├── asserts_test.go
│   │   │   ├── asserts.go
│   │   │   ├── cloud_testing_utils.go
│   │   │   ├── dashboard_test.go
│   │   │   ├── dashboard.go
│   │   │   ├── datasources_test.go
│   │   │   ├── datasources.go
│   │   │   ├── incident_integration_test.go
│   │   │   ├── incident_test.go
│   │   │   ├── incident.go
│   │   │   ├── loki_test.go
│   │   │   ├── loki.go
│   │   │   ├── navigation_test.go
│   │   │   ├── navigation.go
│   │   │   ├── oncall_cloud_test.go
│   │   │   ├── oncall.go
│   │   │   ├── prometheus_test.go
│   │   │   ├── prometheus_unit_test.go
│   │   │   ├── prometheus.go
│   │   │   ├── pyroscope_test.go
│   │   │   ├── pyroscope.go
│   │   │   ├── search_test.go
│   │   │   ├── search.go
│   │   │   ├── sift_cloud_test.go
│   │   │   └── sift.go
│   │   ├── CODEOWNERS
│   │   ├── docker-compose.yaml
│   │   ├── Dockerfile
│   │   ├── go.mod
│   │   ├── go.sum
│   │   ├── [01;32mimage-tag[0m
│   │   ├── LICENSE
│   │   ├── Makefile
│   │   ├── mcpgrafana_test.go
│   │   ├── mcpgrafana.go
│   │   ├── README.md
│   │   ├── tls_test.go
│   │   ├── tools_test.go
│   │   └── tools.go
│   ├── [01;34mscripts[0m
│   │   ├── [01;32mauth_integration.py[0m
│   │   ├── [01;32mcollect-metrics-fixed.sh[0m
│   │   ├── config_manager.py
│   │   ├── dashboard_generator.py
│   │   ├── [01;32mdeploy_dashboards.sh[0m
│   │   ├── [01;32mdeploy-dashboard-env.py[0m
│   │   ├── [01;32mdetect-build-paths.sh[0m
│   │   ├── [01;32mextract-real-metrics.sh[0m
│   │   ├── fix-dashboard-queries.py
│   │   ├── [01;32mhealth-check.py[0m
│   │   ├── [01;32mmacos_grafana_integration.sh[0m
│   │   ├── [01;32mpush-metrics.sh[0m
│   │   ├── [01;32msetup-professional-monitoring.sh[0m
│   │   ├── test_config_manager.py
│   │   ├── upload_to_grafana.py
│   │   ├── [01;32mvalidate-integration.sh[0m
│   │   ├── [01;32mxcode-build-monitor-fixed.sh[0m
│   │   ├── [01;32mxcode-build-monitor.sh[0m
│   │   ├── [01;32mxcode-error-collector.sh[0m
│   │   └── [01;32mxcode-structured-error-parser.sh[0m
│   ├── ACTUAL_SYSTEM_STATUS.md
│   ├── [01;32madd-error-panels.sh[0m
│   ├── ARCHITECTURE_FIXES_IMPLEMENTED.md
│   ├── [01;32mauto-upload-dashboards.sh[0m
│   ├── build-errors.db
│   ├── claude-desktop-mcp-config.json
│   ├── collector-docker.yaml
│   ├── collector-simple.yaml
│   ├── collector.yaml
│   ├── [01;32mcomplete-dashboard-setup.sh[0m
│   ├── [01;32mcreate-dev-dashboard-final.sh[0m
│   ├── [01;32mcreate-dev-dashboard.sh[0m
│   ├── DASHBOARD_DEPLOYMENT_READY.md
│   ├── DASHBOARD_UPLOAD.md
│   ├── dashboard-analysis-enhanced.js
│   ├── dashboard-analysis.js
│   ├── dashboard-consolidation-analysis.md
│   ├── DEV-DASHBOARD-COMPLETE.md
│   ├── dev-dashboard.json
│   ├── docker-compose-dev.yml
│   ├── docker-compose-simple.yml
│   ├── docker-compose-telemetry.yml
│   ├── final-accuracy-fixes.sh
│   ├── fix-all-panel-issues.sh
│   ├── [01;32mfix-dashboard-queries.sh[0m
│   ├── [01;32mfix-panel-by-panel.sh[0m
│   ├── [01;32mfix-real-data-only.sh[0m
│   ├── fix-remaining-panels.sh
│   ├── [01;32mimplement-comprehensive-fixes.sh[0m
│   ├── IMPLEMENTATION_STATUS_REPORT.md
│   ├── INTEGRATION.md
│   ├── Makefile
│   ├── mcp-grafana-config.json
│   ├── MCP-GRAFANA-USAGE.md
│   ├── PERMISSIONS_GUIDE.md
│   ├── PHASE2_DASHBOARD_UX_PLAN.md
│   ├── prometheus-dev.yml
│   ├── prometheus-simple.yml
│   ├── prometheus-telemetry.yml
│   ├── prometheus.yml
│   ├── README-cli-integration.md
│   ├── README-modular-dashboards.md
│   ├── README-professional-monitoring.md
│   ├── real-data-dashboard.json
│   ├── REAL-DATA-SUMMARY.md
│   ├── requirements.txt
│   ├── [01;32msetup-mcp-grafana.sh[0m
│   ├── [01;32mstart-ios-telemetry.sh[0m
│   ├── tempo.yaml
│   ├── [01;32mtest-ios-telemetry.sh[0m
│   ├── [01;32mtest-mcp.sh[0m
│   └── [01;32mupload-dashboard.sh[0m
├── [01;34mNestory.xcodeproj[0m
│   ├── [01;34mxcshareddata[0m
│   │   └── [01;34mxcschemes[0m
│   │       ├── Nestory-Accessibility.xcscheme
│   │       ├── Nestory-Dev.xcscheme
│   │       ├── Nestory-Performance.xcscheme
│   │       ├── Nestory-Prod.xcscheme
│   │       ├── Nestory-Smoke.xcscheme
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
│   ├── [01;34mAccessibilityTests[0m
│   │   └── AccessibilityTests.swift
│   ├── [01;34mBase[0m
│   │   ├── BaseTest.swift
│   │   └── NestoryUITestBase.swift
│   ├── [01;34mCore[0m
│   │   └── [01;34mFramework[0m
│   │       └── TestFramework.swift
│   ├── [01;34mExtensions[0m
│   │   ├── Extensions.swift
│   │   ├── XCTestCase+Helpers.swift
│   │   └── XCUIElement+Helpers.swift
│   ├── [01;34mFramework[0m
│   │   ├── InteractionSampler.swift
│   │   ├── ScreenshotHelper.swift
│   │   └── XCUIElement+Extensions.swift
│   ├── [01;34mHelpers[0m
│   │   ├── Helpers.swift
│   │   ├── NavigationHelper.swift
│   │   ├── NavigationHelpers.swift
│   │   └── UITestHelpers.swift
│   ├── [01;34mPerformanceTests[0m
│   │   └── PerformanceTests.swift
│   ├── [01;34mTests[0m
│   │   ├── BasicScreenshotTest.swift
│   │   ├── ComprehensiveScreenshotTest.swift
│   │   ├── ComprehensiveUIWiringTest.swift
│   │   └── DeterministicScreenshotTest.swift
│   ├── CriticalPathUITests.swift
│   ├── NestoryScreenshotTests.swift
│   ├── SimpleScreenshotTests.swift
│   ├── Snapshot.swift
│   └── SnapshotHelper.swift
├── [01;34mproject-visualization[0m
│   ├── [01;34moutputs[0m
│   │   ├── complexity-report.md
│   │   ├── dead-code-analysis.html
│   │   └── test-coverage.html
│   ├── [01;34mscripts[0m
│   │   ├── check-imports.py
│   │   ├── [01;32mcleanup-dead-code.sh[0m
│   │   ├── complexity-report.py
│   │   └── [01;32mtrack-metrics.sh[0m
│   ├── ACTION_PLAN.md
│   ├── baseline-metrics.json
│   ├── current-metrics.json
│   └── metrics-history.jsonl
├── [01;34mscreenshot-results.xcresult[0m
│   ├── [01;34mData[0m
│   │   ├── data.0~_yxoZCFR-BISzXIcflQ94gTt0MGQEIvBuyB_0lMPceWY-nuakZHEn8ORw0cqOC_ESrm31NJ32Ro5PbUFvAtGuA==
│   │   ├── data.0~2fUNxenYcu9aiURH_Y72xTXdCrj-pFK8BaV5CQ6fXQ2l_IywjMiwNGJ9ILVKSHV98sWt9wW9EE6RplaRIRl0Sw==
│   │   ├── data.0~3tdcR6bwWxdzU22qUxcKe3glLeiYH8_XaDCQvx9TbExlAgQti1qiRQMlvHkmkDeb8RlcrUaKL8To60JB7E1wdA==
│   │   ├── data.0~C2aSKpGMUHe3P3CTP-huRufiOSn9Eq_BSj5UqVxHRPL-yb4UPX3bcIuBNRZ0EzyxgqC-PX8OifUDEAPzNdf2Wg==
│   │   ├── data.0~gbpFevRxwm3QhZUpEvpOW9_h_K67PHPByxn-qOZTlPX5gjOw5dF0PHCbkeMMhxNF0e5ZGSysUNX20cqxxMv_ZA==
│   │   ├── data.0~mRSSLHri8bGxLEPf8m23YhGnAke2mPGZPofUy2F0YLAn5jpyXvW4V1N7Y3L9kkWUw8GhwzqIDgXbQxNX0YanJQ==
│   │   ├── data.0~QTP22HBDh5O5K1zYeSgxz_gATabmHHWGXyyScESisB-OEmqbCkKgXNkkr1gRVlc5b6ZKQP5s6hbL0AjlP0GAWg==
│   │   ├── data.0~upzLsruxF8tvzw1b6n3N8PfDwLcr7Zz1AU_zZH0MezvctM5cnj_CGMdPOXeBm5MXfFTHQUqBuoTy7d_CjcySHA==
│   │   ├── refs.0~_yxoZCFR-BISzXIcflQ94gTt0MGQEIvBuyB_0lMPceWY-nuakZHEn8ORw0cqOC_ESrm31NJ32Ro5PbUFvAtGuA==
│   │   ├── refs.0~2fUNxenYcu9aiURH_Y72xTXdCrj-pFK8BaV5CQ6fXQ2l_IywjMiwNGJ9ILVKSHV98sWt9wW9EE6RplaRIRl0Sw==
│   │   ├── refs.0~3tdcR6bwWxdzU22qUxcKe3glLeiYH8_XaDCQvx9TbExlAgQti1qiRQMlvHkmkDeb8RlcrUaKL8To60JB7E1wdA==
│   │   ├── refs.0~C2aSKpGMUHe3P3CTP-huRufiOSn9Eq_BSj5UqVxHRPL-yb4UPX3bcIuBNRZ0EzyxgqC-PX8OifUDEAPzNdf2Wg==
│   │   ├── refs.0~gbpFevRxwm3QhZUpEvpOW9_h_K67PHPByxn-qOZTlPX5gjOw5dF0PHCbkeMMhxNF0e5ZGSysUNX20cqxxMv_ZA==
│   │   ├── refs.0~mRSSLHri8bGxLEPf8m23YhGnAke2mPGZPofUy2F0YLAn5jpyXvW4V1N7Y3L9kkWUw8GhwzqIDgXbQxNX0YanJQ==
│   │   ├── refs.0~QTP22HBDh5O5K1zYeSgxz_gATabmHHWGXyyScESisB-OEmqbCkKgXNkkr1gRVlc5b6ZKQP5s6hbL0AjlP0GAWg==
│   │   └── refs.0~upzLsruxF8tvzw1b6n3N8PfDwLcr7Zz1AU_zZH0MezvctM5cnj_CGMdPOXeBm5MXfFTHQUqBuoTy7d_CjcySHA==
│   └── Info.plist
├── [01;34mScreenshots[0m
├── [01;34mScripts[0m
│   ├── [01;34mCI[0m
│   │   ├── [01;32mbuild-health-monitor.sh[0m
│   │   ├── [01;32mbuild-with-timeout.sh[0m
│   │   ├── [01;32mcapture-build-metrics.sh[0m
│   │   ├── [01;32mdeploy-runner-remote.sh[0m
│   │   ├── [01;32menhanced-build-metrics.sh[0m
│   │   ├── [01;32menterprise-ui-testing.sh[0m
│   │   ├── [01;32mmonitor-runners-fixed.sh[0m
│   │   ├── [01;32mmonitor-runners.sh[0m
│   │   ├── README.md
│   │   ├── [01;32msetup-github-runner-macos.sh[0m
│   │   ├── [01;32msetup-github-runner-pi.sh[0m
│   │   ├── setup-pi-ssh.sh
│   │   ├── [01;32mtest-runner-connections.sh[0m
│   │   ├── test-stuck-detection.sh
│   │   ├── [01;32mxcode-build-phase.sh[0m
│   │   ├── [01;32mxcodebuild-safe.sh[0m
│   │   ├── [01;32mxcodebuild-with-metrics.sh[0m
│   │   └── [01;32mxcodegen-with-metrics.sh[0m
│   ├── [01;32mapprove-all-ui-files.sh[0m
│   ├── [01;32marchitecture-verification.sh[0m
│   ├── [01;32mbatch-approve-ui-framework.sh[0m
│   ├── [01;32mbuild-performance-report.sh[0m
│   ├── capture-app-screenshots.swift
│   ├── [01;32mcheck-file-sizes.sh[0m
│   ├── [01;32mcodebase-health-report.sh[0m
│   ├── [01;32mconfigure_app_store_connect.rb[0m
│   ├── [01;32mdev_cycle.sh[0m
│   ├── [01;32mdev_stats.sh[0m
│   ├── [01;32mextract-screenshots.py[0m
│   ├── [01;32mextract-ui-test-screenshots.sh[0m
│   ├── [01;32mfinalize_bundle_identifier_update.sh[0m
│   ├── [01;32mgenerate-project-config.swift[0m
│   ├── [01;32mios_simulator_automation.applescript[0m
│   ├── [01;32mmanage-file-size-overrides.sh[0m
│   ├── [01;32mmeasure-build-time.sh[0m
│   ├── [01;32mmodularization-monitor.sh[0m
│   ├── [01;32mmove_models.sh[0m
│   ├── [01;32mnestory_aliases.sh[0m
│   ├── [01;32moptimize_xcode_workflow.sh[0m
│   ├── [01;32moptimize-build-performance.sh[0m
│   ├── [01;32mquick_build.sh[0m
│   ├── [01;32mquick_test.sh[0m
│   ├── README.md
│   ├── [01;32mrun_fastlane_screenshots.sh[0m
│   ├── [01;32mrun_simulator_automation.sh[0m
│   ├── [01;32mrun-screenshot-catalog.sh[0m
│   ├── [01;32mrun-screenshots.sh[0m
│   ├── [01;32msetup_asc_credentials.sh[0m
│   ├── [01;32msetup-fastlane.sh[0m
│   ├── [01;32msetup-simulator-permissions.sh[0m
│   ├── [01;32msmart-file-size-check.sh[0m
│   ├── [01;32mupdate_bundle_identifiers.sh[0m
│   ├── [01;32mvalidate-configuration.sh[0m
│   ├── [01;32mvalidate-ui-testing-framework.sh[0m
│   ├── [01;32mverify_app_store_setup.sh[0m
│   └── verify-degradation.swift
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
│   │   ├── CloudKitConflictResolver.swift
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
│   │   │   ├── [01;34mGenerators[0m
│   │   │   │   ├── AllstateTemplateGenerator.swift
│   │   │   │   ├── GeicoTemplateGenerator.swift
│   │   │   │   ├── GenericTemplateGenerator.swift
│   │   │   │   └── StateFarmTemplateGenerator.swift
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
│   ├── CategoryService.swift
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
│   ├── ServiceDependencyKeys.swift
│   └── TestDataSeederService.swift
├── [01;34mSources[0m
│   └── [01;34mNestoryGuards[0m
│       └── NestoryGuards.swift
├── [01;34mSTATFILE[0m
│   └── [01;31mArchive.zip[0m
├── [01;34mTests[0m
│   ├── [01;34mArchitectureTests[0m
│   │   └── ArchitectureTests.swift
│   ├── [01;34mCoverage[0m
│   │   ├── CoverageAnalyzer.swift
│   │   ├── CoverageDataCollector.swift
│   │   ├── CoverageReporter.swift
│   │   ├── CoverageThresholdValidator.swift
│   │   └── CoverageVisualization.swift
│   ├── [01;34mFeatures[0m
│   │   ├── AddItemFeatureTests.swift
│   │   └── TCAFeatureIntegrationTests.swift
│   ├── [01;34mInfrastructure[0m
│   │   └── CloudKitSyncTests.swift
│   ├── [01;34mPerformance[0m
│   │   ├── baselines.json
│   │   └── BatchOperationsPerformanceTests.swift
│   ├── [01;34mServices[0m
│   │   ├── AnalyticsServiceTests.swift
│   │   ├── AuthServiceTests.swift
│   │   ├── CloudBackupServiceTests.swift
│   │   ├── ComprehensiveServiceTests.swift
│   │   ├── CurrencyServiceTests.swift
│   │   ├── GracefulDegradationTests.swift
│   │   ├── ImportExportServiceTests.swift
│   │   ├── InventoryServiceTests.swift
│   │   ├── ModelContainerErrorHandlingTests.swift
│   │   ├── NotificationServiceTests.swift
│   │   ├── ServiceFailureSimulation.swift
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
│   ├── [01;34mShared[0m
│   ├── [01;34mUI-Components[0m
│   │   ├── EmptyStateView.swift
│   │   ├── ItemCard.swift
│   │   ├── PrimaryButton.swift
│   │   ├── SearchBar.swift
│   │   └── ShareSheet.swift
│   └── [01;34mUI-Core[0m
│       ├── AccessibilityConstants.swift
│       ├── Extensions.swift
│       ├── Theme.swift
│       └── Typography.swift
├── [01;34mvendor[0m
│   └── [01;34mbundle[0m
│       └── [01;34mruby[0m
│           └── [01;34m3.2.0[0m
│               ├── [01;34mbuild_info[0m
│               ├── [01;34mcache[0m
│               │   ├── addressable-2.8.7.gem
│               │   ├── artifactory-3.0.17.gem
│               │   ├── atomos-0.1.3.gem
│               │   ├── aws-eventstream-1.4.0.gem
│               │   ├── aws-partitions-1.1154.0.gem
│               │   ├── aws-sdk-core-3.232.0.gem
│               │   ├── aws-sdk-kms-1.112.0.gem
│               │   ├── aws-sdk-s3-1.198.0.gem
│               │   ├── aws-sigv4-1.12.1.gem
│               │   ├── babosa-1.0.4.gem
│               │   ├── badge-0.13.0.gem
│               │   ├── base64-0.3.0.gem
│               │   ├── bigdecimal-3.2.2.gem
│               │   ├── CFPropertyList-3.0.7.gem
│               │   ├── claide-1.1.0.gem
│               │   ├── colored-1.2.gem
│               │   ├── colored2-3.1.2.gem
│               │   ├── colorize-1.1.0.gem
│               │   ├── commander-4.6.0.gem
│               │   ├── declarative-0.0.20.gem
│               │   ├── digest-crc-0.7.0.gem
│               │   ├── domain_name-0.6.20240107.gem
│               │   ├── dotenv-2.8.1.gem
│               │   ├── emoji_regex-3.2.3.gem
│               │   ├── excon-0.112.0.gem
│               │   ├── faraday_middleware-1.2.1.gem
│               │   ├── faraday-1.10.4.gem
│               │   ├── faraday-cookie_jar-0.0.7.gem
│               │   ├── faraday-em_http-1.0.0.gem
│               │   ├── faraday-em_synchrony-1.0.1.gem
│               │   ├── faraday-excon-1.1.0.gem
│               │   ├── faraday-httpclient-1.0.1.gem
│               │   ├── faraday-multipart-1.1.1.gem
│               │   ├── faraday-net_http_persistent-1.2.0.gem
│               │   ├── faraday-net_http-1.0.2.gem
│               │   ├── faraday-patron-1.0.0.gem
│               │   ├── faraday-rack-1.0.0.gem
│               │   ├── faraday-retry-1.0.3.gem
│               │   ├── fastimage-2.4.0.gem
│               │   ├── fastlane-2.228.0.gem
│               │   ├── fastlane-plugin-appicon-0.16.0.gem
│               │   ├── fastlane-plugin-badge-1.5.0.gem
│               │   ├── fastlane-plugin-changelog-0.16.0.gem
│               │   ├── fastlane-plugin-semantic_release-1.18.2.gem
│               │   ├── fastlane-plugin-test_center-3.19.1.gem
│               │   ├── fastlane-plugin-versioning-0.7.1.gem
│               │   ├── fastlane-sirp-1.0.0.gem
│               │   ├── gh_inspector-1.1.3.gem
│               │   ├── google-apis-androidpublisher_v3-0.54.0.gem
│               │   ├── google-apis-core-0.11.3.gem
│               │   ├── google-apis-iamcredentials_v1-0.17.0.gem
│               │   ├── google-apis-playcustomapp_v1-0.13.0.gem
│               │   ├── google-apis-storage_v1-0.31.0.gem
│               │   ├── google-cloud-core-1.8.0.gem
│               │   ├── google-cloud-env-1.6.0.gem
│               │   ├── google-cloud-errors-1.5.0.gem
│               │   ├── google-cloud-storage-1.47.0.gem
│               │   ├── googleauth-1.8.1.gem
│               │   ├── highline-2.0.3.gem
│               │   ├── http-cookie-1.0.8.gem
│               │   ├── httpclient-2.9.0.gem
│               │   ├── jmespath-1.6.2.gem
│               │   ├── json-2.13.2.gem
│               │   ├── jwt-2.10.2.gem
│               │   ├── logger-1.7.0.gem
│               │   ├── mini_magick-4.13.2.gem
│               │   ├── mini_mime-1.1.5.gem
│               │   ├── multi_json-1.17.0.gem
│               │   ├── multipart-post-2.4.1.gem
│               │   ├── mutex_m-0.3.0.gem
│               │   ├── nanaimo-0.4.0.gem
│               │   ├── naturally-2.3.0.gem
│               │   ├── nkf-0.2.0.gem
│               │   ├── optparse-0.6.0.gem
│               │   ├── os-1.1.4.gem
│               │   ├── plist-3.7.2.gem
│               │   ├── public_suffix-6.0.2.gem
│               │   ├── rake-13.3.0.gem
│               │   ├── representable-3.2.0.gem
│               │   ├── retriable-3.1.2.gem
│               │   ├── rexml-3.4.2.gem
│               │   ├── rouge-3.28.0.gem
│               │   ├── ruby2_keywords-0.0.5.gem
│               │   ├── rubyzip-2.4.1.gem
│               │   ├── security-0.1.5.gem
│               │   ├── signet-0.21.0.gem
│               │   ├── simctl-1.6.10.gem
│               │   ├── slack-notifier-2.4.0.gem
│               │   ├── sysrandom-1.0.5.gem
│               │   ├── terminal-notifier-2.0.0.gem
│               │   ├── terminal-table-3.0.2.gem
│               │   ├── trailblazer-option-0.1.2.gem
│               │   ├── tty-cursor-0.7.1.gem
│               │   ├── tty-screen-0.8.2.gem
│               │   ├── tty-spinner-0.9.3.gem
│               │   ├── uber-0.1.0.gem
│               │   ├── unicode-display_width-2.6.0.gem
│               │   ├── word_wrap-1.0.0.gem
│               │   ├── xcode-install-2.8.1.gem
│               │   ├── xcodeproj-1.27.0.gem
│               │   ├── xcov-1.8.1.gem
│               │   ├── xcpretty-0.4.1.gem
│               │   ├── xcpretty-travis-formatter-1.0.1.gem
│               │   ├── xcresult-0.2.2.gem
│               │   └── xctest_list-1.2.1.gem
│               ├── [01;34mdoc[0m
│               ├── [01;34mextensions[0m
│               │   └── [01;34marm64-darwin-24[0m
│               │       └── [01;34m3.2.0[0m
│               │           ├── [01;34mbigdecimal-3.2.2[0m
│               │           │   ├── [01;32mbigdecimal.bundle[0m
│               │           │   ├── gem_make.out
│               │           │   └── gem.build_complete
│               │           ├── [01;34mdigest-crc-0.7.0[0m
│               │           │   ├── gem_make.out
│               │           │   └── gem.build_complete
│               │           ├── [01;34mjson-2.13.2[0m
│               │           │   ├── [01;34mjson[0m
│               │           │   │   └── [01;34mext[0m
│               │           │   │       ├── [01;32mgenerator.bundle[0m
│               │           │   │       └── [01;32mparser.bundle[0m
│               │           │   ├── gem_make.out
│               │           │   └── gem.build_complete
│               │           ├── [01;34mnkf-0.2.0[0m
│               │           │   ├── gem_make.out
│               │           │   ├── gem.build_complete
│               │           │   └── [01;32mnkf.bundle[0m
│               │           └── [01;34msysrandom-1.0.5[0m
│               │               ├── gem_make.out
│               │               ├── gem.build_complete
│               │               └── [01;32msysrandom_ext.bundle[0m
│               ├── [01;34mgems[0m
│               │   ├── [01;34maddressable-2.8.7[0m
│               │   │   ├── [01;34mdata[0m
│               │   │   │   └── unicode.data
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maddressable[0m
│               │   │   │   │   ├── [01;34midna[0m
│               │   │   │   │   │   ├── native.rb
│               │   │   │   │   │   └── pure.rb
│               │   │   │   │   ├── idna.rb
│               │   │   │   │   ├── template.rb
│               │   │   │   │   ├── uri.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── addressable.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34maddressable[0m
│               │   │   │   │   ├── idna_spec.rb
│               │   │   │   │   ├── net_http_compat_spec.rb
│               │   │   │   │   ├── security_spec.rb
│               │   │   │   │   ├── template_spec.rb
│               │   │   │   │   └── uri_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── [01;34mtasks[0m
│               │   │   │   ├── clobber.rake
│               │   │   │   ├── gem.rake
│               │   │   │   ├── git.rake
│               │   │   │   ├── metrics.rake
│               │   │   │   ├── profile.rake
│               │   │   │   ├── rspec.rake
│               │   │   │   └── yard.rake
│               │   │   ├── addressable.gemspec
│               │   │   ├── CHANGELOG.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34martifactory-3.0.17[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34martifactory[0m
│               │   │   │   │   ├── [01;34mcollections[0m
│               │   │   │   │   │   ├── artifact.rb
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   └── build.rb
│               │   │   │   │   ├── [01;34mresources[0m
│               │   │   │   │   │   ├── artifact.rb
│               │   │   │   │   │   ├── backup.rb
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── build_component.rb
│               │   │   │   │   │   ├── build.rb
│               │   │   │   │   │   ├── certificate.rb
│               │   │   │   │   │   ├── group.rb
│               │   │   │   │   │   ├── layout.rb
│               │   │   │   │   │   ├── ldap_setting.rb
│               │   │   │   │   │   ├── mail_server.rb
│               │   │   │   │   │   ├── permission_target.rb
│               │   │   │   │   │   ├── plugin.rb
│               │   │   │   │   │   ├── repository.rb
│               │   │   │   │   │   ├── system.rb
│               │   │   │   │   │   ├── url_base.rb
│               │   │   │   │   │   └── user.rb
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── configurable.rb
│               │   │   │   │   ├── defaults.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── artifactory.rb
│               │   │   └── LICENSE
│               │   ├── [01;34matomos-0.1.3[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34matomos[0m
│               │   │   │   │   └── version.rb
│               │   │   │   └── atomos.rb
│               │   │   ├── atomos.gemspec
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── VERSION
│               │   ├── [01;34maws-eventstream-1.4.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maws-eventstream[0m
│               │   │   │   │   ├── decoder.rb
│               │   │   │   │   ├── encoder.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── header_value.rb
│               │   │   │   │   ├── message.rb
│               │   │   │   │   └── types.rb
│               │   │   │   └── aws-eventstream.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── VERSION
│               │   ├── [01;34maws-partitions-1.1154.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maws-partitions[0m
│               │   │   │   │   ├── endpoint_provider.rb
│               │   │   │   │   ├── metadata.rb
│               │   │   │   │   ├── partition_list.rb
│               │   │   │   │   ├── partition.rb
│               │   │   │   │   ├── region.rb
│               │   │   │   │   └── service.rb
│               │   │   │   └── aws-partitions.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   ├── partitions-metadata.json
│               │   │   ├── partitions.json
│               │   │   └── VERSION
│               │   ├── [01;34maws-sdk-core-3.232.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maws-defaults[0m
│               │   │   │   │   ├── default_configuration.rb
│               │   │   │   │   └── defaults_mode_config_resolver.rb
│               │   │   │   ├── [01;34maws-sdk-core[0m
│               │   │   │   │   ├── [01;34mbinary[0m
│               │   │   │   │   │   ├── decode_handler.rb
│               │   │   │   │   │   ├── encode_handler.rb
│               │   │   │   │   │   ├── event_builder.rb
│               │   │   │   │   │   ├── event_parser.rb
│               │   │   │   │   │   ├── event_stream_decoder.rb
│               │   │   │   │   │   └── event_stream_encoder.rb
│               │   │   │   │   ├── [01;34mcbor[0m
│               │   │   │   │   │   ├── decoder.rb
│               │   │   │   │   │   └── encoder.rb
│               │   │   │   │   ├── [01;34mclient_side_monitoring[0m
│               │   │   │   │   │   ├── publisher.rb
│               │   │   │   │   │   └── request_metrics.rb
│               │   │   │   │   ├── [01;34mendpoints[0m
│               │   │   │   │   │   ├── condition.rb
│               │   │   │   │   │   ├── endpoint_rule.rb
│               │   │   │   │   │   ├── endpoint.rb
│               │   │   │   │   │   ├── error_rule.rb
│               │   │   │   │   │   ├── function.rb
│               │   │   │   │   │   ├── matchers.rb
│               │   │   │   │   │   ├── reference.rb
│               │   │   │   │   │   ├── rule_set.rb
│               │   │   │   │   │   ├── rule.rb
│               │   │   │   │   │   ├── rules_provider.rb
│               │   │   │   │   │   ├── templater.rb
│               │   │   │   │   │   ├── tree_rule.rb
│               │   │   │   │   │   └── url.rb
│               │   │   │   │   ├── [01;34mjson[0m
│               │   │   │   │   │   ├── builder.rb
│               │   │   │   │   │   ├── error_handler.rb
│               │   │   │   │   │   ├── handler.rb
│               │   │   │   │   │   ├── json_engine.rb
│               │   │   │   │   │   ├── oj_engine.rb
│               │   │   │   │   │   └── parser.rb
│               │   │   │   │   ├── [01;34mlog[0m
│               │   │   │   │   │   ├── formatter.rb
│               │   │   │   │   │   ├── handler.rb
│               │   │   │   │   │   ├── param_filter.rb
│               │   │   │   │   │   └── param_formatter.rb
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   ├── [01;34mprotocols[0m
│               │   │   │   │   │   │   ├── api_gateway.rb
│               │   │   │   │   │   │   ├── ec2.rb
│               │   │   │   │   │   │   ├── json_rpc.rb
│               │   │   │   │   │   │   ├── query.rb
│               │   │   │   │   │   │   ├── rest_json.rb
│               │   │   │   │   │   │   ├── rest_xml.rb
│               │   │   │   │   │   │   └── rpc_v2.rb
│               │   │   │   │   │   ├── [01;34mretries[0m
│               │   │   │   │   │   │   ├── client_rate_limiter.rb
│               │   │   │   │   │   │   ├── clock_skew.rb
│               │   │   │   │   │   │   ├── error_inspector.rb
│               │   │   │   │   │   │   └── retry_quota.rb
│               │   │   │   │   │   ├── api_key.rb
│               │   │   │   │   │   ├── apig_authorizer_token.rb
│               │   │   │   │   │   ├── apig_credentials_configuration.rb
│               │   │   │   │   │   ├── apig_user_agent.rb
│               │   │   │   │   │   ├── bearer_authorization.rb
│               │   │   │   │   │   ├── checksum_algorithm.rb
│               │   │   │   │   │   ├── client_metrics_plugin.rb
│               │   │   │   │   │   ├── client_metrics_send_plugin.rb
│               │   │   │   │   │   ├── credentials_configuration.rb
│               │   │   │   │   │   ├── defaults_mode.rb
│               │   │   │   │   │   ├── endpoint_discovery.rb
│               │   │   │   │   │   ├── endpoint_pattern.rb
│               │   │   │   │   │   ├── event_stream_configuration.rb
│               │   │   │   │   │   ├── global_configuration.rb
│               │   │   │   │   │   ├── helpful_socket_errors.rb
│               │   │   │   │   │   ├── http_checksum.rb
│               │   │   │   │   │   ├── idempotency_token.rb
│               │   │   │   │   │   ├── invocation_id.rb
│               │   │   │   │   │   ├── jsonvalue_converter.rb
│               │   │   │   │   │   ├── logging.rb
│               │   │   │   │   │   ├── param_converter.rb
│               │   │   │   │   │   ├── param_validator.rb
│               │   │   │   │   │   ├── recursion_detection.rb
│               │   │   │   │   │   ├── regional_endpoint.rb
│               │   │   │   │   │   ├── request_compression.rb
│               │   │   │   │   │   ├── response_paging.rb
│               │   │   │   │   │   ├── retry_errors.rb
│               │   │   │   │   │   ├── sign.rb
│               │   │   │   │   │   ├── signature_v2.rb
│               │   │   │   │   │   ├── signature_v4.rb
│               │   │   │   │   │   ├── stub_responses.rb
│               │   │   │   │   │   ├── telemetry.rb
│               │   │   │   │   │   ├── transfer_encoding.rb
│               │   │   │   │   │   └── user_agent.rb
│               │   │   │   │   ├── [01;34mquery[0m
│               │   │   │   │   │   ├── ec2_handler.rb
│               │   │   │   │   │   ├── ec2_param_builder.rb
│               │   │   │   │   │   ├── handler.rb
│               │   │   │   │   │   ├── param_builder.rb
│               │   │   │   │   │   ├── param_list.rb
│               │   │   │   │   │   └── param.rb
│               │   │   │   │   ├── [01;34mresources[0m
│               │   │   │   │   │   └── collection.rb
│               │   │   │   │   ├── [01;34mrest[0m
│               │   │   │   │   │   ├── [01;34mrequest[0m
│               │   │   │   │   │   │   ├── body.rb
│               │   │   │   │   │   │   ├── builder.rb
│               │   │   │   │   │   │   ├── endpoint.rb
│               │   │   │   │   │   │   ├── headers.rb
│               │   │   │   │   │   │   └── querystring_builder.rb
│               │   │   │   │   │   ├── [01;34mresponse[0m
│               │   │   │   │   │   │   ├── body.rb
│               │   │   │   │   │   │   ├── header_list_parser.rb
│               │   │   │   │   │   │   ├── headers.rb
│               │   │   │   │   │   │   ├── parser.rb
│               │   │   │   │   │   │   └── status_code.rb
│               │   │   │   │   │   ├── content_type_handler.rb
│               │   │   │   │   │   └── handler.rb
│               │   │   │   │   ├── [01;34mrpc_v2[0m
│               │   │   │   │   │   ├── builder.rb
│               │   │   │   │   │   ├── cbor_engine.rb
│               │   │   │   │   │   ├── content_type_handler.rb
│               │   │   │   │   │   ├── error_handler.rb
│               │   │   │   │   │   ├── handler.rb
│               │   │   │   │   │   └── parser.rb
│               │   │   │   │   ├── [01;34mstubbing[0m
│               │   │   │   │   │   ├── [01;34mprotocols[0m
│               │   │   │   │   │   │   ├── api_gateway.rb
│               │   │   │   │   │   │   ├── ec2.rb
│               │   │   │   │   │   │   ├── json.rb
│               │   │   │   │   │   │   ├── query.rb
│               │   │   │   │   │   │   ├── rest_json.rb
│               │   │   │   │   │   │   ├── rest_xml.rb
│               │   │   │   │   │   │   ├── rest.rb
│               │   │   │   │   │   │   └── rpc_v2.rb
│               │   │   │   │   │   ├── data_applicator.rb
│               │   │   │   │   │   ├── empty_stub.rb
│               │   │   │   │   │   ├── stub_data.rb
│               │   │   │   │   │   └── xml_error.rb
│               │   │   │   │   ├── [01;34mtelemetry[0m
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── no_op.rb
│               │   │   │   │   │   ├── otel.rb
│               │   │   │   │   │   ├── span_kind.rb
│               │   │   │   │   │   └── span_status.rb
│               │   │   │   │   ├── [01;34mwaiters[0m
│               │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   ├── poller.rb
│               │   │   │   │   │   └── waiter.rb
│               │   │   │   │   ├── [01;34mxml[0m
│               │   │   │   │   │   ├── [01;34mparser[0m
│               │   │   │   │   │   │   ├── frame.rb
│               │   │   │   │   │   │   ├── libxml_engine.rb
│               │   │   │   │   │   │   ├── nokogiri_engine.rb
│               │   │   │   │   │   │   ├── oga_engine.rb
│               │   │   │   │   │   │   ├── ox_engine.rb
│               │   │   │   │   │   │   ├── parsing_error.rb
│               │   │   │   │   │   │   ├── rexml_engine.rb
│               │   │   │   │   │   │   └── stack.rb
│               │   │   │   │   │   ├── builder.rb
│               │   │   │   │   │   ├── default_list.rb
│               │   │   │   │   │   ├── default_map.rb
│               │   │   │   │   │   ├── doc_builder.rb
│               │   │   │   │   │   ├── error_handler.rb
│               │   │   │   │   │   └── parser.rb
│               │   │   │   │   ├── arn_parser.rb
│               │   │   │   │   ├── arn.rb
│               │   │   │   │   ├── assume_role_credentials.rb
│               │   │   │   │   ├── assume_role_web_identity_credentials.rb
│               │   │   │   │   ├── async_client_stubs.rb
│               │   │   │   │   ├── binary.rb
│               │   │   │   │   ├── cbor.rb
│               │   │   │   │   ├── client_side_monitoring.rb
│               │   │   │   │   ├── client_stubs.rb
│               │   │   │   │   ├── credential_provider_chain.rb
│               │   │   │   │   ├── credential_provider.rb
│               │   │   │   │   ├── credentials.rb
│               │   │   │   │   ├── deprecations.rb
│               │   │   │   │   ├── eager_loader.rb
│               │   │   │   │   ├── ec2_metadata.rb
│               │   │   │   │   ├── ecs_credentials.rb
│               │   │   │   │   ├── endpoint_cache.rb
│               │   │   │   │   ├── endpoints.rb
│               │   │   │   │   ├── error_handler.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── event_emitter.rb
│               │   │   │   │   ├── ini_parser.rb
│               │   │   │   │   ├── instance_profile_credentials.rb
│               │   │   │   │   ├── json.rb
│               │   │   │   │   ├── log.rb
│               │   │   │   │   ├── lru_cache.rb
│               │   │   │   │   ├── pageable_response.rb
│               │   │   │   │   ├── pager.rb
│               │   │   │   │   ├── param_converter.rb
│               │   │   │   │   ├── param_validator.rb
│               │   │   │   │   ├── plugins.rb
│               │   │   │   │   ├── process_credentials.rb
│               │   │   │   │   ├── query.rb
│               │   │   │   │   ├── refreshing_credentials.rb
│               │   │   │   │   ├── refreshing_token.rb
│               │   │   │   │   ├── resources.rb
│               │   │   │   │   ├── rest.rb
│               │   │   │   │   ├── rpc_v2.rb
│               │   │   │   │   ├── shared_config.rb
│               │   │   │   │   ├── shared_credentials.rb
│               │   │   │   │   ├── sso_credentials.rb
│               │   │   │   │   ├── sso_token_provider.rb
│               │   │   │   │   ├── static_token_provider.rb
│               │   │   │   │   ├── structure.rb
│               │   │   │   │   ├── stubbing.rb
│               │   │   │   │   ├── telemetry.rb
│               │   │   │   │   ├── token_provider_chain.rb
│               │   │   │   │   ├── token_provider.rb
│               │   │   │   │   ├── token.rb
│               │   │   │   │   ├── type_builder.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   ├── waiters.rb
│               │   │   │   │   └── xml.rb
│               │   │   │   ├── [01;34maws-sdk-sso[0m
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   └── endpoints.rb
│               │   │   │   │   ├── client_api.rb
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── customizations.rb
│               │   │   │   │   ├── endpoint_parameters.rb
│               │   │   │   │   ├── endpoint_provider.rb
│               │   │   │   │   ├── endpoints.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── resource.rb
│               │   │   │   │   └── types.rb
│               │   │   │   ├── [01;34maws-sdk-ssooidc[0m
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   └── endpoints.rb
│               │   │   │   │   ├── client_api.rb
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── customizations.rb
│               │   │   │   │   ├── endpoint_parameters.rb
│               │   │   │   │   ├── endpoint_provider.rb
│               │   │   │   │   ├── endpoints.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── resource.rb
│               │   │   │   │   └── types.rb
│               │   │   │   ├── [01;34maws-sdk-sts[0m
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   ├── endpoints.rb
│               │   │   │   │   │   └── sts_regional_endpoints.rb
│               │   │   │   │   ├── client_api.rb
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── customizations.rb
│               │   │   │   │   ├── endpoint_parameters.rb
│               │   │   │   │   ├── endpoint_provider.rb
│               │   │   │   │   ├── endpoints.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── presigner.rb
│               │   │   │   │   ├── resource.rb
│               │   │   │   │   └── types.rb
│               │   │   │   ├── [01;34mseahorse[0m
│               │   │   │   │   ├── [01;34mclient[0m
│               │   │   │   │   │   ├── [01;34mh2[0m
│               │   │   │   │   │   │   ├── connection.rb
│               │   │   │   │   │   │   └── handler.rb
│               │   │   │   │   │   ├── [01;34mhttp[0m
│               │   │   │   │   │   │   ├── async_response.rb
│               │   │   │   │   │   │   ├── headers.rb
│               │   │   │   │   │   │   ├── request.rb
│               │   │   │   │   │   │   └── response.rb
│               │   │   │   │   │   ├── [01;34mlogging[0m
│               │   │   │   │   │   │   ├── formatter.rb
│               │   │   │   │   │   │   └── handler.rb
│               │   │   │   │   │   ├── [01;34mnet_http[0m
│               │   │   │   │   │   │   ├── connection_pool.rb
│               │   │   │   │   │   │   ├── handler.rb
│               │   │   │   │   │   │   └── patches.rb
│               │   │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   │   ├── content_length.rb
│               │   │   │   │   │   │   ├── endpoint.rb
│               │   │   │   │   │   │   ├── h2.rb
│               │   │   │   │   │   │   ├── logging.rb
│               │   │   │   │   │   │   ├── net_http.rb
│               │   │   │   │   │   │   ├── operation_methods.rb
│               │   │   │   │   │   │   ├── raise_response_errors.rb
│               │   │   │   │   │   │   ├── request_callback.rb
│               │   │   │   │   │   │   └── response_target.rb
│               │   │   │   │   │   ├── async_base.rb
│               │   │   │   │   │   ├── async_response.rb
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── block_io.rb
│               │   │   │   │   │   ├── configuration.rb
│               │   │   │   │   │   ├── events.rb
│               │   │   │   │   │   ├── handler_builder.rb
│               │   │   │   │   │   ├── handler_list_entry.rb
│               │   │   │   │   │   ├── handler_list.rb
│               │   │   │   │   │   ├── handler.rb
│               │   │   │   │   │   ├── managed_file.rb
│               │   │   │   │   │   ├── networking_error.rb
│               │   │   │   │   │   ├── plugin_list.rb
│               │   │   │   │   │   ├── plugin.rb
│               │   │   │   │   │   ├── request_context.rb
│               │   │   │   │   │   ├── request.rb
│               │   │   │   │   │   └── response.rb
│               │   │   │   │   ├── [01;34mmodel[0m
│               │   │   │   │   │   ├── api.rb
│               │   │   │   │   │   ├── authorizer.rb
│               │   │   │   │   │   ├── operation.rb
│               │   │   │   │   │   └── shapes.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   └── version.rb
│               │   │   │   ├── aws-defaults.rb
│               │   │   │   ├── aws-sdk-core.rb
│               │   │   │   ├── aws-sdk-sso.rb
│               │   │   │   ├── aws-sdk-ssooidc.rb
│               │   │   │   ├── aws-sdk-sts.rb
│               │   │   │   └── seahorse.rb
│               │   │   ├── [01;34msig[0m
│               │   │   │   ├── [01;34maws-sdk-core[0m
│               │   │   │   │   ├── [01;34mresources[0m
│               │   │   │   │   │   └── collection.rbs
│               │   │   │   │   ├── [01;34mtelemetry[0m
│               │   │   │   │   │   ├── base.rbs
│               │   │   │   │   │   ├── otel.rbs
│               │   │   │   │   │   ├── span_kind.rbs
│               │   │   │   │   │   └── span_status.rbs
│               │   │   │   │   ├── [01;34mwaiters[0m
│               │   │   │   │   │   └── errors.rbs
│               │   │   │   │   ├── async_client_stubs.rbs
│               │   │   │   │   ├── client_stubs.rbs
│               │   │   │   │   ├── errors.rbs
│               │   │   │   │   └── structure.rbs
│               │   │   │   ├── [01;34mseahorse[0m
│               │   │   │   │   └── [01;34mclient[0m
│               │   │   │   │       ├── async_base.rbs
│               │   │   │   │       ├── base.rbs
│               │   │   │   │       ├── handler_builder.rbs
│               │   │   │   │       └── response.rbs
│               │   │   │   └── aws-sdk-core.rbs
│               │   │   ├── ca-bundle.crt
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── VERSION
│               │   ├── [01;34maws-sdk-kms-1.112.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maws-sdk-kms[0m
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   └── endpoints.rb
│               │   │   │   │   ├── client_api.rb
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── customizations.rb
│               │   │   │   │   ├── endpoint_parameters.rb
│               │   │   │   │   ├── endpoint_provider.rb
│               │   │   │   │   ├── endpoints.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── resource.rb
│               │   │   │   │   └── types.rb
│               │   │   │   └── aws-sdk-kms.rb
│               │   │   ├── [01;34msig[0m
│               │   │   │   ├── client.rbs
│               │   │   │   ├── errors.rbs
│               │   │   │   ├── resource.rbs
│               │   │   │   ├── types.rbs
│               │   │   │   └── waiters.rbs
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── VERSION
│               │   ├── [01;34maws-sdk-s3-1.198.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maws-sdk-s3[0m
│               │   │   │   │   ├── [01;34mcustomizations[0m
│               │   │   │   │   │   ├── [01;34mtypes[0m
│               │   │   │   │   │   │   ├── list_object_versions_output.rb
│               │   │   │   │   │   │   └── permanent_redirect.rb
│               │   │   │   │   │   ├── bucket.rb
│               │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   ├── multipart_upload.rb
│               │   │   │   │   │   ├── object_summary.rb
│               │   │   │   │   │   ├── object_version.rb
│               │   │   │   │   │   └── object.rb
│               │   │   │   │   ├── [01;34mencryption[0m
│               │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   ├── decrypt_handler.rb
│               │   │   │   │   │   ├── default_cipher_provider.rb
│               │   │   │   │   │   ├── default_key_provider.rb
│               │   │   │   │   │   ├── encrypt_handler.rb
│               │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   ├── io_auth_decrypter.rb
│               │   │   │   │   │   ├── io_decrypter.rb
│               │   │   │   │   │   ├── io_encrypter.rb
│               │   │   │   │   │   ├── key_provider.rb
│               │   │   │   │   │   ├── kms_cipher_provider.rb
│               │   │   │   │   │   ├── materials.rb
│               │   │   │   │   │   └── utils.rb
│               │   │   │   │   ├── [01;34mencryptionV2[0m
│               │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   ├── decrypt_handler.rb
│               │   │   │   │   │   ├── default_cipher_provider.rb
│               │   │   │   │   │   ├── default_key_provider.rb
│               │   │   │   │   │   ├── encrypt_handler.rb
│               │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   ├── io_auth_decrypter.rb
│               │   │   │   │   │   ├── io_decrypter.rb
│               │   │   │   │   │   ├── io_encrypter.rb
│               │   │   │   │   │   ├── key_provider.rb
│               │   │   │   │   │   ├── kms_cipher_provider.rb
│               │   │   │   │   │   ├── materials.rb
│               │   │   │   │   │   └── utils.rb
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   ├── accelerate.rb
│               │   │   │   │   │   ├── access_grants.rb
│               │   │   │   │   │   ├── arn.rb
│               │   │   │   │   │   ├── bucket_dns.rb
│               │   │   │   │   │   ├── bucket_name_restrictions.rb
│               │   │   │   │   │   ├── checksum_algorithm.rb
│               │   │   │   │   │   ├── dualstack.rb
│               │   │   │   │   │   ├── endpoints.rb
│               │   │   │   │   │   ├── expect_100_continue.rb
│               │   │   │   │   │   ├── express_session_auth.rb
│               │   │   │   │   │   ├── get_bucket_location_fix.rb
│               │   │   │   │   │   ├── http_200_errors.rb
│               │   │   │   │   │   ├── iad_regional_endpoint.rb
│               │   │   │   │   │   ├── location_constraint.rb
│               │   │   │   │   │   ├── md5s.rb
│               │   │   │   │   │   ├── redirects.rb
│               │   │   │   │   │   ├── s3_host_id.rb
│               │   │   │   │   │   ├── s3_signer.rb
│               │   │   │   │   │   ├── sse_cpk.rb
│               │   │   │   │   │   ├── streaming_retry.rb
│               │   │   │   │   │   └── url_encoded_keys.rb
│               │   │   │   │   ├── access_grants_credentials_provider.rb
│               │   │   │   │   ├── access_grants_credentials.rb
│               │   │   │   │   ├── bucket_acl.rb
│               │   │   │   │   ├── bucket_cors.rb
│               │   │   │   │   ├── bucket_lifecycle_configuration.rb
│               │   │   │   │   ├── bucket_lifecycle.rb
│               │   │   │   │   ├── bucket_logging.rb
│               │   │   │   │   ├── bucket_notification.rb
│               │   │   │   │   ├── bucket_policy.rb
│               │   │   │   │   ├── bucket_region_cache.rb
│               │   │   │   │   ├── bucket_request_payment.rb
│               │   │   │   │   ├── bucket_tagging.rb
│               │   │   │   │   ├── bucket_versioning.rb
│               │   │   │   │   ├── bucket_website.rb
│               │   │   │   │   ├── bucket.rb
│               │   │   │   │   ├── client_api.rb
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── customizations.rb
│               │   │   │   │   ├── encryption_v2.rb
│               │   │   │   │   ├── encryption.rb
│               │   │   │   │   ├── endpoint_parameters.rb
│               │   │   │   │   ├── endpoint_provider.rb
│               │   │   │   │   ├── endpoints.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── event_streams.rb
│               │   │   │   │   ├── express_credentials_provider.rb
│               │   │   │   │   ├── express_credentials.rb
│               │   │   │   │   ├── file_downloader.rb
│               │   │   │   │   ├── file_part.rb
│               │   │   │   │   ├── file_uploader.rb
│               │   │   │   │   ├── legacy_signer.rb
│               │   │   │   │   ├── multipart_download_error.rb
│               │   │   │   │   ├── multipart_file_uploader.rb
│               │   │   │   │   ├── multipart_stream_uploader.rb
│               │   │   │   │   ├── multipart_upload_error.rb
│               │   │   │   │   ├── multipart_upload_part.rb
│               │   │   │   │   ├── multipart_upload.rb
│               │   │   │   │   ├── object_acl.rb
│               │   │   │   │   ├── object_copier.rb
│               │   │   │   │   ├── object_multipart_copier.rb
│               │   │   │   │   ├── object_summary.rb
│               │   │   │   │   ├── object_version.rb
│               │   │   │   │   ├── object.rb
│               │   │   │   │   ├── presigned_post.rb
│               │   │   │   │   ├── presigner.rb
│               │   │   │   │   ├── resource.rb
│               │   │   │   │   ├── transfer_manager.rb
│               │   │   │   │   ├── types.rb
│               │   │   │   │   └── waiters.rb
│               │   │   │   └── aws-sdk-s3.rb
│               │   │   ├── [01;34msig[0m
│               │   │   │   ├── [01;34mcustomizations[0m
│               │   │   │   │   ├── bucket.rbs
│               │   │   │   │   ├── object_summary.rbs
│               │   │   │   │   └── object.rbs
│               │   │   │   ├── bucket_acl.rbs
│               │   │   │   ├── bucket_cors.rbs
│               │   │   │   ├── bucket_lifecycle_configuration.rbs
│               │   │   │   ├── bucket_lifecycle.rbs
│               │   │   │   ├── bucket_logging.rbs
│               │   │   │   ├── bucket_notification.rbs
│               │   │   │   ├── bucket_policy.rbs
│               │   │   │   ├── bucket_request_payment.rbs
│               │   │   │   ├── bucket_tagging.rbs
│               │   │   │   ├── bucket_versioning.rbs
│               │   │   │   ├── bucket_website.rbs
│               │   │   │   ├── bucket.rbs
│               │   │   │   ├── client.rbs
│               │   │   │   ├── errors.rbs
│               │   │   │   ├── multipart_upload_part.rbs
│               │   │   │   ├── multipart_upload.rbs
│               │   │   │   ├── object_acl.rbs
│               │   │   │   ├── object_summary.rbs
│               │   │   │   ├── object_version.rbs
│               │   │   │   ├── object.rbs
│               │   │   │   ├── resource.rbs
│               │   │   │   ├── types.rbs
│               │   │   │   └── waiters.rbs
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── VERSION
│               │   ├── [01;34maws-sigv4-1.12.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34maws-sigv4[0m
│               │   │   │   │   ├── asymmetric_credentials.rb
│               │   │   │   │   ├── credentials.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── request.rb
│               │   │   │   │   ├── signature.rb
│               │   │   │   │   └── signer.rb
│               │   │   │   └── aws-sigv4.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── VERSION
│               │   ├── [01;34mbabosa-1.0.4[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mbabosa[0m
│               │   │   │   │   ├── [01;34mtransliterator[0m
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── bulgarian.rb
│               │   │   │   │   │   ├── cyrillic.rb
│               │   │   │   │   │   ├── danish.rb
│               │   │   │   │   │   ├── german.rb
│               │   │   │   │   │   ├── greek.rb
│               │   │   │   │   │   ├── hindi.rb
│               │   │   │   │   │   ├── latin.rb
│               │   │   │   │   │   ├── macedonian.rb
│               │   │   │   │   │   ├── norwegian.rb
│               │   │   │   │   │   ├── romanian.rb
│               │   │   │   │   │   ├── russian.rb
│               │   │   │   │   │   ├── serbian.rb
│               │   │   │   │   │   ├── spanish.rb
│               │   │   │   │   │   ├── swedish.rb
│               │   │   │   │   │   ├── turkish.rb
│               │   │   │   │   │   ├── ukrainian.rb
│               │   │   │   │   │   └── vietnamese.rb
│               │   │   │   │   ├── [01;34mutf8[0m
│               │   │   │   │   │   ├── active_support_proxy.rb
│               │   │   │   │   │   ├── dumb_proxy.rb
│               │   │   │   │   │   ├── java_proxy.rb
│               │   │   │   │   │   ├── mappings.rb
│               │   │   │   │   │   ├── proxy.rb
│               │   │   │   │   │   └── unicode_proxy.rb
│               │   │   │   │   ├── identifier.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── babosa.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mtransliterators[0m
│               │   │   │   │   ├── base_spec.rb
│               │   │   │   │   ├── bulgarian_spec.rb
│               │   │   │   │   ├── danish_spec.rb
│               │   │   │   │   ├── german_spec.rb
│               │   │   │   │   ├── greek_spec.rb
│               │   │   │   │   ├── hindi_spec.rb
│               │   │   │   │   ├── latin_spec.rb
│               │   │   │   │   ├── macedonian_spec.rb
│               │   │   │   │   ├── norwegian_spec.rb
│               │   │   │   │   ├── polish_spec.rb
│               │   │   │   │   ├── romanian_spec.rb
│               │   │   │   │   ├── russian_spec.rb
│               │   │   │   │   ├── serbian_spec.rb
│               │   │   │   │   ├── spanish_spec.rb
│               │   │   │   │   ├── swedish_spec.rb
│               │   │   │   │   ├── turkish_spec.rb
│               │   │   │   │   ├── ukrainian_spec.rb
│               │   │   │   │   └── vietnamese_spec.rb
│               │   │   │   ├── babosa_spec.rb
│               │   │   │   ├── spec_helper.rb
│               │   │   │   └── utf8_proxy_spec.rb
│               │   │   ├── Changelog.md
│               │   │   ├── MIT-LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mbadge-0.13.0[0m
│               │   │   ├── [01;34massets[0m
│               │   │   │   ├── [01;35malpha_badge_dark.png[0m
│               │   │   │   ├── [01;35malpha_badge_light.png[0m
│               │   │   │   ├── [01;35mbeta_badge_dark.png[0m
│               │   │   │   └── [01;35mbeta_badge_light.png[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mbadge[0m
│               │   │   │   │   ├── base.rb
│               │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   ├── options.rb
│               │   │   │   │   └── runner.rb
│               │   │   │   └── badge.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mbase64-0.3.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── base64.rb
│               │   │   ├── [01;34msig[0m
│               │   │   │   └── base64.rbs
│               │   │   ├── BSDL
│               │   │   ├── COPYING
│               │   │   ├── LEGAL
│               │   │   └── README.md
│               │   ├── [01;34mbigdecimal-3.2.2[0m
│               │   │   ├── [01;34mext[0m
│               │   │   │   └── [01;34mbigdecimal[0m
│               │   │   │       ├── [01;34mmissing[0m
│               │   │   │       │   └── dtoa.c
│               │   │   │       ├── bigdecimal.c
│               │   │   │       ├── bigdecimal.h
│               │   │   │       ├── bits.h
│               │   │   │       ├── extconf.rb
│               │   │   │       ├── feature.h
│               │   │   │       ├── Makefile
│               │   │   │       ├── missing.c
│               │   │   │       ├── missing.h
│               │   │   │       └── static_assert.h
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mbigdecimal[0m
│               │   │   │   │   ├── jacobian.rb
│               │   │   │   │   ├── ludcmp.rb
│               │   │   │   │   ├── math.rb
│               │   │   │   │   ├── newton.rb
│               │   │   │   │   └── util.rb
│               │   │   │   ├── [01;32mbigdecimal.bundle[0m
│               │   │   │   └── bigdecimal.rb
│               │   │   ├── [01;34msample[0m
│               │   │   │   ├── linear.rb
│               │   │   │   ├── nlsolve.rb
│               │   │   │   └── pi.rb
│               │   │   ├── bigdecimal.gemspec
│               │   │   └── LICENSE
│               │   ├── [01;34mCFPropertyList-3.0.7[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mcfpropertylist[0m
│               │   │   │   │   ├── rbBinaryCFPropertyList.rb
│               │   │   │   │   ├── rbCFPlistError.rb
│               │   │   │   │   ├── rbCFPropertyList.rb
│               │   │   │   │   ├── rbCFTypes.rb
│               │   │   │   │   ├── rbLibXMLParser.rb
│               │   │   │   │   ├── rbNokogiriParser.rb
│               │   │   │   │   ├── rbPlainCFPropertyList.rb
│               │   │   │   │   └── rbREXMLParser.rb
│               │   │   │   └── cfpropertylist.rb
│               │   │   ├── LICENSE
│               │   │   ├── README.md
│               │   │   ├── README.rdoc
│               │   │   └── THANKS
│               │   ├── [01;34mclaide-1.1.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mclaide[0m
│               │   │   │   │   ├── [01;34mansi[0m
│               │   │   │   │   │   ├── cursor.rb
│               │   │   │   │   │   ├── graphics.rb
│               │   │   │   │   │   └── string_escaper.rb
│               │   │   │   │   ├── [01;34mcommand[0m
│               │   │   │   │   │   ├── argument_suggester.rb
│               │   │   │   │   │   ├── banner.rb
│               │   │   │   │   │   └── plugin_manager.rb
│               │   │   │   │   ├── ansi.rb
│               │   │   │   │   ├── argument.rb
│               │   │   │   │   ├── argv.rb
│               │   │   │   │   ├── command.rb
│               │   │   │   │   ├── gem_version.rb
│               │   │   │   │   ├── help.rb
│               │   │   │   │   └── informative_error.rb
│               │   │   │   └── claide.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── claide.gemspec
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mcolored-1.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── colored.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   └── colored_test.rb
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README
│               │   ├── [01;34mcolored2-3.1.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mcolored2[0m
│               │   │   │   │   ├── ascii_decorator.rb
│               │   │   │   │   ├── codes.rb
│               │   │   │   │   ├── numbers.rb
│               │   │   │   │   ├── object.rb
│               │   │   │   │   ├── strings.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── colored2.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mcolored2[0m
│               │   │   │   │   ├── numbers_spec.rb
│               │   │   │   │   ├── object_spec.rb
│               │   │   │   │   └── strings_spec.rb
│               │   │   │   ├── colored2_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mcolorize-1.1.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mcolorize[0m
│               │   │   │   │   ├── class_methods.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── instance_methods.rb
│               │   │   │   │   └── version.rb
│               │   │   │   ├── colorize.rb
│               │   │   │   └── colorized_string.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── test_colorize.rb
│               │   │   │   └── test_colorized_string.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── colorize.gemspec
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mcommander-4.6.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mcommander[0m
│               │   │   │   │   ├── [01;34mcore_ext[0m
│               │   │   │   │   │   ├── array.rb
│               │   │   │   │   │   └── object.rb
│               │   │   │   │   ├── [01;34mhelp_formatters[0m
│               │   │   │   │   │   ├── [01;34mterminal[0m
│               │   │   │   │   │   │   ├── command_help.erb
│               │   │   │   │   │   │   └── help.erb
│               │   │   │   │   │   ├── [01;34mterminal_compact[0m
│               │   │   │   │   │   │   ├── command_help.erb
│               │   │   │   │   │   │   └── help.erb
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── terminal_compact.rb
│               │   │   │   │   │   └── terminal.rb
│               │   │   │   │   ├── blank.rb
│               │   │   │   │   ├── command.rb
│               │   │   │   │   ├── configure.rb
│               │   │   │   │   ├── core_ext.rb
│               │   │   │   │   ├── delegates.rb
│               │   │   │   │   ├── help_formatters.rb
│               │   │   │   │   ├── import.rb
│               │   │   │   │   ├── methods.rb
│               │   │   │   │   ├── platform.rb
│               │   │   │   │   ├── runner.rb
│               │   │   │   │   ├── user_interaction.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── commander.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mcore_ext[0m
│               │   │   │   │   ├── array_spec.rb
│               │   │   │   │   └── object_spec.rb
│               │   │   │   ├── [01;34mhelp_formatters[0m
│               │   │   │   │   ├── terminal_compact_spec.rb
│               │   │   │   │   └── terminal_spec.rb
│               │   │   │   ├── command_spec.rb
│               │   │   │   ├── configure_spec.rb
│               │   │   │   ├── methods_spec.rb
│               │   │   │   ├── runner_spec.rb
│               │   │   │   ├── spec_helper.rb
│               │   │   │   └── ui_spec.rb
│               │   │   ├── commander.gemspec
│               │   │   ├── DEVELOPMENT
│               │   │   ├── Gemfile
│               │   │   ├── History.rdoc
│               │   │   ├── LICENSE
│               │   │   ├── Manifest
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mdeclarative-0.0.20[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mdeclarative[0m
│               │   │   │   │   ├── deep_dup.rb
│               │   │   │   │   ├── defaults.rb
│               │   │   │   │   ├── definitions.rb
│               │   │   │   │   ├── heritage.rb
│               │   │   │   │   ├── schema.rb
│               │   │   │   │   ├── testing.rb
│               │   │   │   │   ├── variables.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── declarative.rb
│               │   │   ├── CHANGES.md
│               │   │   ├── declarative.gemspec
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mdigest-crc-0.7.0[0m
│               │   │   ├── [01;34mext[0m
│               │   │   │   └── [01;34mdigest[0m
│               │   │   │       ├── [01;34mcompat[0m
│               │   │   │       │   └── ruby.h
│               │   │   │       ├── [01;34mcrc12_3gpp[0m
│               │   │   │       │   ├── [01;32mcrc12_3gpp_ext.bundle[0m
│               │   │   │       │   ├── crc12_3gpp_ext.c
│               │   │   │       │   ├── crc12_3gpp.c
│               │   │   │       │   ├── crc12_3gpp.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc15[0m
│               │   │   │       │   ├── [01;32mcrc15_ext.bundle[0m
│               │   │   │       │   ├── crc15_ext.c
│               │   │   │       │   ├── crc15.c
│               │   │   │       │   ├── crc15.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16[0m
│               │   │   │       │   ├── [01;32mcrc16_ext.bundle[0m
│               │   │   │       │   ├── crc16_ext.c
│               │   │   │       │   ├── crc16.c
│               │   │   │       │   ├── crc16.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_ccitt[0m
│               │   │   │       │   ├── [01;32mcrc16_ccitt_ext.bundle[0m
│               │   │   │       │   ├── crc16_ccitt_ext.c
│               │   │   │       │   ├── crc16_ccitt.c
│               │   │   │       │   ├── crc16_ccitt.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_dnp[0m
│               │   │   │       │   ├── [01;32mcrc16_dnp_ext.bundle[0m
│               │   │   │       │   ├── crc16_dnp_ext.c
│               │   │   │       │   ├── crc16_dnp.c
│               │   │   │       │   ├── crc16_dnp.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_genibus[0m
│               │   │   │       │   ├── [01;32mcrc16_genibus_ext.bundle[0m
│               │   │   │       │   ├── crc16_genibus_ext.c
│               │   │   │       │   ├── crc16_genibus.c
│               │   │   │       │   ├── crc16_genibus.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_kermit[0m
│               │   │   │       │   ├── [01;32mcrc16_kermit_ext.bundle[0m
│               │   │   │       │   ├── crc16_kermit_ext.c
│               │   │   │       │   ├── crc16_kermit.c
│               │   │   │       │   ├── crc16_kermit.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_modbus[0m
│               │   │   │       │   ├── [01;32mcrc16_modbus_ext.bundle[0m
│               │   │   │       │   ├── crc16_modbus_ext.c
│               │   │   │       │   ├── crc16_modbus.c
│               │   │   │       │   ├── crc16_modbus.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_usb[0m
│               │   │   │       │   ├── [01;32mcrc16_usb_ext.bundle[0m
│               │   │   │       │   ├── crc16_usb_ext.c
│               │   │   │       │   ├── crc16_usb.c
│               │   │   │       │   ├── crc16_usb.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_x_25[0m
│               │   │   │       │   ├── [01;32mcrc16_x_25_ext.bundle[0m
│               │   │   │       │   ├── crc16_x_25_ext.c
│               │   │   │       │   ├── crc16_x_25.c
│               │   │   │       │   ├── crc16_x_25.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_xmodem[0m
│               │   │   │       │   ├── [01;32mcrc16_xmodem_ext.bundle[0m
│               │   │   │       │   ├── crc16_xmodem_ext.c
│               │   │   │       │   ├── crc16_xmodem.c
│               │   │   │       │   ├── crc16_xmodem.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc16_zmodem[0m
│               │   │   │       │   ├── [01;32mcrc16_zmodem_ext.bundle[0m
│               │   │   │       │   ├── crc16_zmodem_ext.c
│               │   │   │       │   ├── crc16_zmodem.c
│               │   │   │       │   ├── crc16_zmodem.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc24[0m
│               │   │   │       │   ├── [01;32mcrc24_ext.bundle[0m
│               │   │   │       │   ├── crc24_ext.c
│               │   │   │       │   ├── crc24.c
│               │   │   │       │   ├── crc24.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32[0m
│               │   │   │       │   ├── [01;32mcrc32_ext.bundle[0m
│               │   │   │       │   ├── crc32_ext.c
│               │   │   │       │   ├── crc32.c
│               │   │   │       │   ├── crc32.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32_bzip2[0m
│               │   │   │       │   ├── [01;32mcrc32_bzip2_ext.bundle[0m
│               │   │   │       │   ├── crc32_bzip2_ext.c
│               │   │   │       │   ├── crc32_bzip2.c
│               │   │   │       │   ├── crc32_bzip2.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32_jam[0m
│               │   │   │       │   ├── [01;32mcrc32_jam_ext.bundle[0m
│               │   │   │       │   ├── crc32_jam_ext.c
│               │   │   │       │   ├── crc32_jam.c
│               │   │   │       │   ├── crc32_jam.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32_mpeg[0m
│               │   │   │       │   ├── [01;32mcrc32_mpeg_ext.bundle[0m
│               │   │   │       │   ├── crc32_mpeg_ext.c
│               │   │   │       │   ├── crc32_mpeg.c
│               │   │   │       │   ├── crc32_mpeg.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32_posix[0m
│               │   │   │       │   ├── [01;32mcrc32_posix_ext.bundle[0m
│               │   │   │       │   ├── crc32_posix_ext.c
│               │   │   │       │   ├── crc32_posix.c
│               │   │   │       │   ├── crc32_posix.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32_xfer[0m
│               │   │   │       │   ├── [01;32mcrc32_xfer_ext.bundle[0m
│               │   │   │       │   ├── crc32_xfer_ext.c
│               │   │   │       │   ├── crc32_xfer.c
│               │   │   │       │   ├── crc32_xfer.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc32c[0m
│               │   │   │       │   ├── [01;32mcrc32c_ext.bundle[0m
│               │   │   │       │   ├── crc32c_ext.c
│               │   │   │       │   ├── crc32c.c
│               │   │   │       │   ├── crc32c.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc5[0m
│               │   │   │       │   ├── [01;32mcrc5_ext.bundle[0m
│               │   │   │       │   ├── crc5_ext.c
│               │   │   │       │   ├── crc5.c
│               │   │   │       │   ├── crc5.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc64[0m
│               │   │   │       │   ├── [01;32mcrc64_ext.bundle[0m
│               │   │   │       │   ├── crc64_ext.c
│               │   │   │       │   ├── crc64.c
│               │   │   │       │   ├── crc64.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc64_jones[0m
│               │   │   │       │   ├── [01;32mcrc64_jones_ext.bundle[0m
│               │   │   │       │   ├── crc64_jones_ext.c
│               │   │   │       │   ├── crc64_jones.c
│               │   │   │       │   ├── crc64_jones.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc64_nvme[0m
│               │   │   │       │   ├── [01;32mcrc64_nvme_ext.bundle[0m
│               │   │   │       │   ├── crc64_nvme_ext.c
│               │   │   │       │   ├── crc64_nvme.c
│               │   │   │       │   ├── crc64_nvme.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc64_xz[0m
│               │   │   │       │   ├── [01;32mcrc64_xz_ext.bundle[0m
│               │   │   │       │   ├── crc64_xz_ext.c
│               │   │   │       │   ├── crc64_xz.c
│               │   │   │       │   ├── crc64_xz.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc8[0m
│               │   │   │       │   ├── [01;32mcrc8_ext.bundle[0m
│               │   │   │       │   ├── crc8_ext.c
│               │   │   │       │   ├── crc8.c
│               │   │   │       │   ├── crc8.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       ├── [01;34mcrc8_1wire[0m
│               │   │   │       │   ├── [01;32mcrc8_1wire_ext.bundle[0m
│               │   │   │       │   ├── crc8_1wire_ext.c
│               │   │   │       │   ├── crc8_1wire.c
│               │   │   │       │   ├── crc8_1wire.h
│               │   │   │       │   ├── extconf.h
│               │   │   │       │   ├── extconf.rb
│               │   │   │       │   └── Makefile
│               │   │   │       └── Rakefile
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mdigest[0m
│               │   │   │       ├── crc.rb
│               │   │   │       ├── crc1.rb
│               │   │   │       ├── crc15.rb
│               │   │   │       ├── crc16_ccitt.rb
│               │   │   │       ├── crc16_dnp.rb
│               │   │   │       ├── crc16_genibus.rb
│               │   │   │       ├── crc16_kermit.rb
│               │   │   │       ├── crc16_modbus.rb
│               │   │   │       ├── crc16_qt.rb
│               │   │   │       ├── crc16_usb.rb
│               │   │   │       ├── crc16_x_25.rb
│               │   │   │       ├── crc16_xmodem.rb
│               │   │   │       ├── crc16_zmodem.rb
│               │   │   │       ├── crc16.rb
│               │   │   │       ├── crc24.rb
│               │   │   │       ├── crc32_bzip2.rb
│               │   │   │       ├── crc32_jam.rb
│               │   │   │       ├── crc32_mpeg.rb
│               │   │   │       ├── crc32_posix.rb
│               │   │   │       ├── crc32_xfer.rb
│               │   │   │       ├── crc32.rb
│               │   │   │       ├── crc32c.rb
│               │   │   │       ├── crc5.rb
│               │   │   │       ├── crc64_jones.rb
│               │   │   │       ├── crc64_nvme.rb
│               │   │   │       ├── crc64_xz.rb
│               │   │   │       ├── crc64.rb
│               │   │   │       ├── crc8_1wire.rb
│               │   │   │       └── crc8.rb
│               │   │   ├── [01;32mbenchmarks.rb[0m
│               │   │   ├── ChangeLog.md
│               │   │   ├── digest-crc.gemspec
│               │   │   ├── Gemfile
│               │   │   ├── gemspec.yml
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mdomain_name-0.6.20240107[0m
│               │   │   ├── [01;34mdata[0m
│               │   │   │   └── public_suffix_list.dat
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mdomain_name[0m
│               │   │   │   │   ├── etld_data.rb
│               │   │   │   │   ├── etld_data.rb.erb
│               │   │   │   │   ├── punycode.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── domain_name.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── helper.rb
│               │   │   │   ├── test_domain_name-punycode.rb
│               │   │   │   └── test_domain_name.rb
│               │   │   ├── [01;34mtool[0m
│               │   │   │   └── [01;32mgen_etld_data.rb[0m
│               │   │   ├── CHANGELOG.md
│               │   │   ├── domain_name.gemspec
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mdotenv-2.8.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mdotenv[0m
│               │   │   │   │   ├── [01;34msubstitutions[0m
│               │   │   │   │   │   ├── command.rb
│               │   │   │   │   │   └── variable.rb
│               │   │   │   │   ├── cli.rb
│               │   │   │   │   ├── environment.rb
│               │   │   │   │   ├── load.rb
│               │   │   │   │   ├── missing_keys.rb
│               │   │   │   │   ├── parser.rb
│               │   │   │   │   ├── tasks.rb
│               │   │   │   │   ├── template.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── dotenv.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34memoji_regex-3.2.3[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── emoji_regex.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mexcon-0.112.0[0m
│               │   │   ├── [01;34mdata[0m
│               │   │   │   └── cacert.pem
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mexcon[0m
│               │   │   │   │   ├── [01;34mextensions[0m
│               │   │   │   │   │   └── uri.rb
│               │   │   │   │   ├── [01;34minstrumentors[0m
│               │   │   │   │   │   ├── logging_instrumentor.rb
│               │   │   │   │   │   └── standard_instrumentor.rb
│               │   │   │   │   ├── [01;34mmiddlewares[0m
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── capture_cookies.rb
│               │   │   │   │   │   ├── decompress.rb
│               │   │   │   │   │   ├── escape_path.rb
│               │   │   │   │   │   ├── expects.rb
│               │   │   │   │   │   ├── idempotent.rb
│               │   │   │   │   │   ├── instrumentor.rb
│               │   │   │   │   │   ├── mock.rb
│               │   │   │   │   │   ├── redirect_follower.rb
│               │   │   │   │   │   └── response_parser.rb
│               │   │   │   │   ├── [01;34mtest[0m
│               │   │   │   │   │   ├── [01;34mplugin[0m
│               │   │   │   │   │   │   └── [01;34mserver[0m
│               │   │   │   │   │   │       ├── exec.rb
│               │   │   │   │   │   │       ├── puma.rb
│               │   │   │   │   │   │       ├── unicorn.rb
│               │   │   │   │   │   │       └── webrick.rb
│               │   │   │   │   │   └── server.rb
│               │   │   │   │   ├── connection.rb
│               │   │   │   │   ├── constants.rb
│               │   │   │   │   ├── error.rb
│               │   │   │   │   ├── headers.rb
│               │   │   │   │   ├── pretty_printer.rb
│               │   │   │   │   ├── response.rb
│               │   │   │   │   ├── socket.rb
│               │   │   │   │   ├── ssl_socket.rb
│               │   │   │   │   ├── unix_socket.rb
│               │   │   │   │   ├── utils.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── excon.rb
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── CONTRIBUTORS.md
│               │   │   ├── excon.gemspec
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday_middleware-1.2.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mfaraday_middleware[0m
│               │   │   │   │   ├── [01;34mrequest[0m
│               │   │   │   │   │   ├── encode_json.rb
│               │   │   │   │   │   ├── method_override.rb
│               │   │   │   │   │   ├── oauth.rb
│               │   │   │   │   │   └── oauth2.rb
│               │   │   │   │   ├── [01;34mresponse[0m
│               │   │   │   │   │   ├── caching.rb
│               │   │   │   │   │   ├── chunked.rb
│               │   │   │   │   │   ├── follow_redirects.rb
│               │   │   │   │   │   ├── mashify.rb
│               │   │   │   │   │   ├── parse_dates.rb
│               │   │   │   │   │   ├── parse_json.rb
│               │   │   │   │   │   ├── parse_marshal.rb
│               │   │   │   │   │   ├── parse_xml.rb
│               │   │   │   │   │   ├── parse_yaml.rb
│               │   │   │   │   │   └── rashify.rb
│               │   │   │   │   ├── backwards_compatibility.rb
│               │   │   │   │   ├── gzip.rb
│               │   │   │   │   ├── instrumentation.rb
│               │   │   │   │   ├── rack_compatible.rb
│               │   │   │   │   ├── redirect_limit_reached.rb
│               │   │   │   │   ├── response_middleware.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── faraday_middleware.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-1.10.4[0m
│               │   │   ├── [01;34mexamples[0m
│               │   │   │   ├── client_spec.rb
│               │   │   │   └── client_test.rb
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mfaraday[0m
│               │   │   │   │   ├── [01;34madapter[0m
│               │   │   │   │   │   ├── test.rb
│               │   │   │   │   │   └── typhoeus.rb
│               │   │   │   │   ├── [01;34mencoders[0m
│               │   │   │   │   │   ├── flat_params_encoder.rb
│               │   │   │   │   │   └── nested_params_encoder.rb
│               │   │   │   │   ├── [01;34mlogging[0m
│               │   │   │   │   │   └── formatter.rb
│               │   │   │   │   ├── [01;34moptions[0m
│               │   │   │   │   │   ├── connection_options.rb
│               │   │   │   │   │   ├── env.rb
│               │   │   │   │   │   ├── proxy_options.rb
│               │   │   │   │   │   ├── request_options.rb
│               │   │   │   │   │   └── ssl_options.rb
│               │   │   │   │   ├── [01;34mrequest[0m
│               │   │   │   │   │   ├── authorization.rb
│               │   │   │   │   │   ├── basic_authentication.rb
│               │   │   │   │   │   ├── instrumentation.rb
│               │   │   │   │   │   ├── json.rb
│               │   │   │   │   │   ├── token_authentication.rb
│               │   │   │   │   │   └── url_encoded.rb
│               │   │   │   │   ├── [01;34mresponse[0m
│               │   │   │   │   │   ├── json.rb
│               │   │   │   │   │   ├── logger.rb
│               │   │   │   │   │   └── raise_error.rb
│               │   │   │   │   ├── [01;34mutils[0m
│               │   │   │   │   │   ├── headers.rb
│               │   │   │   │   │   └── params_hash.rb
│               │   │   │   │   ├── adapter_registry.rb
│               │   │   │   │   ├── adapter.rb
│               │   │   │   │   ├── autoload.rb
│               │   │   │   │   ├── connection.rb
│               │   │   │   │   ├── dependency_loader.rb
│               │   │   │   │   ├── deprecate.rb
│               │   │   │   │   ├── error.rb
│               │   │   │   │   ├── methods.rb
│               │   │   │   │   ├── middleware_registry.rb
│               │   │   │   │   ├── middleware.rb
│               │   │   │   │   ├── options.rb
│               │   │   │   │   ├── parameters.rb
│               │   │   │   │   ├── rack_builder.rb
│               │   │   │   │   ├── request.rb
│               │   │   │   │   ├── response.rb
│               │   │   │   │   ├── utils.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── faraday.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mexternal_adapters[0m
│               │   │   │   │   └── faraday_specs_setup.rb
│               │   │   │   ├── [01;34mfaraday[0m
│               │   │   │   │   ├── [01;34madapter[0m
│               │   │   │   │   │   ├── em_http_spec.rb
│               │   │   │   │   │   ├── em_synchrony_spec.rb
│               │   │   │   │   │   ├── excon_spec.rb
│               │   │   │   │   │   ├── httpclient_spec.rb
│               │   │   │   │   │   ├── net_http_spec.rb
│               │   │   │   │   │   ├── patron_spec.rb
│               │   │   │   │   │   ├── rack_spec.rb
│               │   │   │   │   │   ├── test_spec.rb
│               │   │   │   │   │   └── typhoeus_spec.rb
│               │   │   │   │   ├── [01;34moptions[0m
│               │   │   │   │   │   ├── env_spec.rb
│               │   │   │   │   │   ├── options_spec.rb
│               │   │   │   │   │   ├── proxy_options_spec.rb
│               │   │   │   │   │   └── request_options_spec.rb
│               │   │   │   │   ├── [01;34mparams_encoders[0m
│               │   │   │   │   │   ├── flat_spec.rb
│               │   │   │   │   │   └── nested_spec.rb
│               │   │   │   │   ├── [01;34mrequest[0m
│               │   │   │   │   │   ├── authorization_spec.rb
│               │   │   │   │   │   ├── instrumentation_spec.rb
│               │   │   │   │   │   ├── json_spec.rb
│               │   │   │   │   │   └── url_encoded_spec.rb
│               │   │   │   │   ├── [01;34mresponse[0m
│               │   │   │   │   │   ├── json_spec.rb
│               │   │   │   │   │   ├── logger_spec.rb
│               │   │   │   │   │   ├── middleware_spec.rb
│               │   │   │   │   │   └── raise_error_spec.rb
│               │   │   │   │   ├── [01;34mutils[0m
│               │   │   │   │   │   └── headers_spec.rb
│               │   │   │   │   ├── adapter_registry_spec.rb
│               │   │   │   │   ├── adapter_spec.rb
│               │   │   │   │   ├── composite_read_io_spec.rb
│               │   │   │   │   ├── connection_spec.rb
│               │   │   │   │   ├── deprecate_spec.rb
│               │   │   │   │   ├── error_spec.rb
│               │   │   │   │   ├── middleware_spec.rb
│               │   │   │   │   ├── rack_builder_spec.rb
│               │   │   │   │   ├── request_spec.rb
│               │   │   │   │   ├── response_spec.rb
│               │   │   │   │   └── utils_spec.rb
│               │   │   │   ├── [01;34msupport[0m
│               │   │   │   │   ├── [01;34mshared_examples[0m
│               │   │   │   │   │   ├── adapter.rb
│               │   │   │   │   │   ├── params_encoder.rb
│               │   │   │   │   │   └── request_method.rb
│               │   │   │   │   ├── disabling_stub.rb
│               │   │   │   │   ├── fake_safe_buffer.rb
│               │   │   │   │   ├── helper_methods.rb
│               │   │   │   │   ├── streaming_response_checker.rb
│               │   │   │   │   └── webmock_rack_app.rb
│               │   │   │   ├── faraday_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-cookie_jar-0.0.7[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mfaraday[0m
│               │   │   │   │   ├── [01;34mcookie_jar[0m
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── cookie_jar.rb
│               │   │   │   └── faraday-cookie_jar.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mfaraday-cookie_jar[0m
│               │   │   │   │   └── cookie_jar_spec.rb
│               │   │   │   ├── [01;34msupport[0m
│               │   │   │   │   └── fake_app.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── faraday-cookie_jar.gemspec
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-em_http-1.0.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   ├── em_http_ssl_patch.rb
│               │   │   │       │   └── em_http.rb
│               │   │   │       ├── [01;34mem_http[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── em_http.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-em_synchrony-1.0.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   ├── [01;34mem_synchrony[0m
│               │   │   │       │   │   └── parallel_manager.rb
│               │   │   │       │   └── em_synchrony.rb
│               │   │   │       ├── [01;34mem_synchrony[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── em_synchrony.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-excon-1.1.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   └── excon.rb
│               │   │   │       ├── [01;34mexcon[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── excon.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-httpclient-1.0.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   └── httpclient.rb
│               │   │   │       ├── [01;34mhttpclient[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── httpclient.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-multipart-1.1.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34mmultipart[0m
│               │   │   │       │   ├── file_part.rb
│               │   │   │       │   ├── middleware.rb
│               │   │   │       │   ├── param_part.rb
│               │   │   │       │   └── version.rb
│               │   │   │       └── multipart.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-net_http_persistent-1.2.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   └── net_http_persistent.rb
│               │   │   │       ├── [01;34mnet_http_persistent[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── net_http_persistent.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-net_http-1.0.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   └── net_http.rb
│               │   │   │       ├── [01;34mnet_http[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── net_http.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-patron-1.0.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   └── patron.rb
│               │   │   │       ├── [01;34mpatron[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── patron.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-rack-1.0.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34madapter[0m
│               │   │   │       │   └── rack.rb
│               │   │   │       ├── [01;34mrack[0m
│               │   │   │       │   └── version.rb
│               │   │   │       └── rack.rb
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfaraday-retry-1.0.3[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfaraday[0m
│               │   │   │       ├── [01;34mretry[0m
│               │   │   │       │   ├── middleware.rb
│               │   │   │       │   └── version.rb
│               │   │   │       ├── retriable_response.rb
│               │   │   │       └── retry.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mfastimage-2.4.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mfastimage[0m
│               │   │   │   │   ├── [01;34mfastimage_parsing[0m
│               │   │   │   │   │   ├── avif.rb
│               │   │   │   │   │   ├── bmp.rb
│               │   │   │   │   │   ├── exif.rb
│               │   │   │   │   │   ├── fiber_stream.rb
│               │   │   │   │   │   ├── gif.rb
│               │   │   │   │   │   ├── heic.rb
│               │   │   │   │   │   ├── ico.rb
│               │   │   │   │   │   ├── image_base.rb
│               │   │   │   │   │   ├── iso_bmff.rb
│               │   │   │   │   │   ├── jpeg.rb
│               │   │   │   │   │   ├── jxl.rb
│               │   │   │   │   │   ├── jxlc.rb
│               │   │   │   │   │   ├── png.rb
│               │   │   │   │   │   ├── psd.rb
│               │   │   │   │   │   ├── stream_util.rb
│               │   │   │   │   │   ├── svg.rb
│               │   │   │   │   │   ├── tiff.rb
│               │   │   │   │   │   ├── type_parser.rb
│               │   │   │   │   │   └── webp.rb
│               │   │   │   │   ├── fastimage.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── fastimage.rb
│               │   │   ├── MIT-LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-2.228.0[0m
│               │   │   ├── [01;34mcert[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34mcert[0m
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   └── runner.rb
│               │   │   │   │   └── cert.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mcredentials_manager[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34mcredentials_manager[0m
│               │   │   │   │   │   ├── account_manager.rb
│               │   │   │   │   │   ├── appfile_config.rb
│               │   │   │   │   │   └── cli.rb
│               │   │   │   │   └── credentials_manager.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mdeliver[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── DeliverfileDefault
│               │   │   │   │   │   ├── DeliverfileDefault.swift
│               │   │   │   │   │   ├── ScreenshotsHelp
│               │   │   │   │   │   └── summary.html.erb
│               │   │   │   │   ├── [01;34mdeliver[0m
│               │   │   │   │   │   ├── app_screenshot_iterator.rb
│               │   │   │   │   │   ├── app_screenshot_validator.rb
│               │   │   │   │   │   ├── app_screenshot.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── detect_values.rb
│               │   │   │   │   │   ├── download_screenshots.rb
│               │   │   │   │   │   ├── generate_summary.rb
│               │   │   │   │   │   ├── html_generator.rb
│               │   │   │   │   │   ├── languages.rb
│               │   │   │   │   │   ├── loader.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   ├── screenshot_comparable.rb
│               │   │   │   │   │   ├── setup.rb
│               │   │   │   │   │   ├── submit_for_review.rb
│               │   │   │   │   │   ├── sync_screenshots.rb
│               │   │   │   │   │   ├── upload_metadata.rb
│               │   │   │   │   │   ├── upload_price_tier.rb
│               │   │   │   │   │   └── upload_screenshots.rb
│               │   │   │   │   └── deliver.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mfastlane[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── [01;34mcompletions[0m
│               │   │   │   │   │   │   ├── [01;32mcompletion.bash[0m
│               │   │   │   │   │   │   ├── completion.fish
│               │   │   │   │   │   │   ├── completion.sh
│               │   │   │   │   │   │   └── [01;32mcompletion.zsh[0m
│               │   │   │   │   │   ├── ActionDetails.md.erb
│               │   │   │   │   │   ├── Actions.md.erb
│               │   │   │   │   │   ├── AppfileTemplate
│               │   │   │   │   │   ├── AppfileTemplate.swift
│               │   │   │   │   │   ├── AppfileTemplateAndroid
│               │   │   │   │   │   ├── custom_action_template.rb
│               │   │   │   │   │   ├── DefaultFastfileTemplate
│               │   │   │   │   │   ├── DefaultFastfileTemplate.swift
│               │   │   │   │   │   ├── mailgun_html_template.erb
│               │   │   │   │   │   ├── report_template.xml.erb
│               │   │   │   │   │   ├── s3_html_template.erb
│               │   │   │   │   │   ├── s3_plist_template.erb
│               │   │   │   │   │   └── s3_version_template.erb
│               │   │   │   │   ├── [01;34mfastlane[0m
│               │   │   │   │   │   ├── [01;34mactions[0m
│               │   │   │   │   │   │   ├── [01;34mdevice_grid[0m
│               │   │   │   │   │   │   │   └── README.md
│               │   │   │   │   │   │   ├── [01;34mdocs[0m
│               │   │   │   │   │   │   │   ├── build_app.md
│               │   │   │   │   │   │   │   ├── capture_android_screenshots.md
│               │   │   │   │   │   │   │   ├── capture_ios_screenshots.md
│               │   │   │   │   │   │   │   ├── check_app_store_metadata.md
│               │   │   │   │   │   │   │   ├── create_app_online.md
│               │   │   │   │   │   │   │   ├── frame_screenshots.md
│               │   │   │   │   │   │   │   ├── get_certificates.md
│               │   │   │   │   │   │   │   ├── get_provisioning_profile.md
│               │   │   │   │   │   │   │   ├── get_push_certificate.md
│               │   │   │   │   │   │   │   ├── run_tests.md
│               │   │   │   │   │   │   │   ├── sync_code_signing.md
│               │   │   │   │   │   │   │   ├── upload_to_app_store.md.erb
│               │   │   │   │   │   │   │   ├── upload_to_play_store.md
│               │   │   │   │   │   │   │   └── upload_to_testflight.md
│               │   │   │   │   │   │   ├── actions_helper.rb
│               │   │   │   │   │   │   ├── adb_devices.rb
│               │   │   │   │   │   │   ├── adb.rb
│               │   │   │   │   │   │   ├── add_extra_platforms.rb
│               │   │   │   │   │   │   ├── add_git_tag.rb
│               │   │   │   │   │   │   ├── app_store_build_number.rb
│               │   │   │   │   │   │   ├── app_store_connect_api_key.rb
│               │   │   │   │   │   │   ├── appaloosa.rb
│               │   │   │   │   │   │   ├── appetize_viewing_url_generator.rb
│               │   │   │   │   │   │   ├── appetize.rb
│               │   │   │   │   │   │   ├── appium.rb
│               │   │   │   │   │   │   ├── appledoc.rb
│               │   │   │   │   │   │   ├── appstore.rb
│               │   │   │   │   │   │   ├── apteligent.rb
│               │   │   │   │   │   │   ├── artifactory.rb
│               │   │   │   │   │   │   ├── automatic_code_signing.rb
│               │   │   │   │   │   │   ├── backup_file.rb
│               │   │   │   │   │   │   ├── backup_xcarchive.rb
│               │   │   │   │   │   │   ├── badge.rb
│               │   │   │   │   │   │   ├── build_and_upload_to_appetize.rb
│               │   │   │   │   │   │   ├── build_android_app.rb
│               │   │   │   │   │   │   ├── build_app.rb
│               │   │   │   │   │   │   ├── build_ios_app.rb
│               │   │   │   │   │   │   ├── build_mac_app.rb
│               │   │   │   │   │   │   ├── bundle_install.rb
│               │   │   │   │   │   │   ├── capture_android_screenshots.rb
│               │   │   │   │   │   │   ├── capture_ios_screenshots.rb
│               │   │   │   │   │   │   ├── capture_screenshots.rb
│               │   │   │   │   │   │   ├── carthage.rb
│               │   │   │   │   │   │   ├── cert.rb
│               │   │   │   │   │   │   ├── changelog_from_git_commits.rb
│               │   │   │   │   │   │   ├── chatwork.rb
│               │   │   │   │   │   │   ├── check_app_store_metadata.rb
│               │   │   │   │   │   │   ├── clean_build_artifacts.rb
│               │   │   │   │   │   │   ├── clean_cocoapods_cache.rb
│               │   │   │   │   │   │   ├── clear_derived_data.rb
│               │   │   │   │   │   │   ├── clipboard.rb
│               │   │   │   │   │   │   ├── cloc.rb
│               │   │   │   │   │   │   ├── cocoapods.rb
│               │   │   │   │   │   │   ├── commit_github_file.rb
│               │   │   │   │   │   │   ├── commit_version_bump.rb
│               │   │   │   │   │   │   ├── copy_artifacts.rb
│               │   │   │   │   │   │   ├── create_app_on_managed_play_store.rb
│               │   │   │   │   │   │   ├── create_app_online.rb
│               │   │   │   │   │   │   ├── create_keychain.rb
│               │   │   │   │   │   │   ├── create_pull_request.rb
│               │   │   │   │   │   │   ├── create_xcframework.rb
│               │   │   │   │   │   │   ├── danger.rb
│               │   │   │   │   │   │   ├── debug.rb
│               │   │   │   │   │   │   ├── default_platform.rb
│               │   │   │   │   │   │   ├── delete_keychain.rb
│               │   │   │   │   │   │   ├── deliver.rb
│               │   │   │   │   │   │   ├── deploygate.rb
│               │   │   │   │   │   │   ├── dotgpg_environment.rb
│               │   │   │   │   │   │   ├── download_app_privacy_details_from_app_store.rb
│               │   │   │   │   │   │   ├── download_dsyms.rb
│               │   │   │   │   │   │   ├── download_from_play_store.rb
│               │   │   │   │   │   │   ├── download_universal_apk_from_google_play.rb
│               │   │   │   │   │   │   ├── download.rb
│               │   │   │   │   │   │   ├── dsym_zip.rb
│               │   │   │   │   │   │   ├── echo.rb
│               │   │   │   │   │   │   ├── ensure_bundle_exec.rb
│               │   │   │   │   │   │   ├── ensure_env_vars.rb
│               │   │   │   │   │   │   ├── ensure_git_branch.rb
│               │   │   │   │   │   │   ├── ensure_git_status_clean.rb
│               │   │   │   │   │   │   ├── ensure_no_debug_code.rb
│               │   │   │   │   │   │   ├── ensure_xcode_version.rb
│               │   │   │   │   │   │   ├── environment_variable.rb
│               │   │   │   │   │   │   ├── erb.rb
│               │   │   │   │   │   │   ├── fastlane_version.rb
│               │   │   │   │   │   │   ├── flock.rb
│               │   │   │   │   │   │   ├── frame_screenshots.rb
│               │   │   │   │   │   │   ├── frameit.rb
│               │   │   │   │   │   │   ├── gcovr.rb
│               │   │   │   │   │   │   ├── get_build_number_repository.rb
│               │   │   │   │   │   │   ├── get_build_number.rb
│               │   │   │   │   │   │   ├── get_certificates.rb
│               │   │   │   │   │   │   ├── get_github_release.rb
│               │   │   │   │   │   │   ├── get_info_plist_value.rb
│               │   │   │   │   │   │   ├── get_ipa_info_plist_value.rb
│               │   │   │   │   │   │   ├── get_managed_play_store_publishing_rights.rb
│               │   │   │   │   │   │   ├── get_provisioning_profile.rb
│               │   │   │   │   │   │   ├── get_push_certificate.rb
│               │   │   │   │   │   │   ├── get_version_number.rb
│               │   │   │   │   │   │   ├── git_add.rb
│               │   │   │   │   │   │   ├── git_branch.rb
│               │   │   │   │   │   │   ├── git_commit.rb
│               │   │   │   │   │   │   ├── git_pull.rb
│               │   │   │   │   │   │   ├── git_remote_branch.rb
│               │   │   │   │   │   │   ├── git_submodule_update.rb
│               │   │   │   │   │   │   ├── git_tag_exists.rb
│               │   │   │   │   │   │   ├── github_api.rb
│               │   │   │   │   │   │   ├── google_play_track_release_names.rb
│               │   │   │   │   │   │   ├── google_play_track_version_codes.rb
│               │   │   │   │   │   │   ├── gradle.rb
│               │   │   │   │   │   │   ├── gym.rb
│               │   │   │   │   │   │   ├── hg_add_tag.rb
│               │   │   │   │   │   │   ├── hg_commit_version_bump.rb
│               │   │   │   │   │   │   ├── hg_ensure_clean_status.rb
│               │   │   │   │   │   │   ├── hg_push.rb
│               │   │   │   │   │   │   ├── hockey.rb
│               │   │   │   │   │   │   ├── ifttt.rb
│               │   │   │   │   │   │   ├── import_certificate.rb
│               │   │   │   │   │   │   ├── import_from_git.rb
│               │   │   │   │   │   │   ├── import.rb
│               │   │   │   │   │   │   ├── increment_build_number.rb
│               │   │   │   │   │   │   ├── increment_version_number.rb
│               │   │   │   │   │   │   ├── install_on_device.rb
│               │   │   │   │   │   │   ├── install_provisioning_profile.rb
│               │   │   │   │   │   │   ├── install_xcode_plugin.rb
│               │   │   │   │   │   │   ├── installr.rb
│               │   │   │   │   │   │   ├── ipa.rb
│               │   │   │   │   │   │   ├── is_ci.rb
│               │   │   │   │   │   │   ├── jazzy.rb
│               │   │   │   │   │   │   ├── jira.rb
│               │   │   │   │   │   │   ├── lane_context.rb
│               │   │   │   │   │   │   ├── last_git_commit.rb
│               │   │   │   │   │   │   ├── last_git_tag.rb
│               │   │   │   │   │   │   ├── latest_testflight_build_number.rb
│               │   │   │   │   │   │   ├── lcov.rb
│               │   │   │   │   │   │   ├── mailgun.rb
│               │   │   │   │   │   │   ├── make_changelog_from_jenkins.rb
│               │   │   │   │   │   │   ├── match_nuke.rb
│               │   │   │   │   │   │   ├── match.rb
│               │   │   │   │   │   │   ├── min_fastlane_version.rb
│               │   │   │   │   │   │   ├── modify_services.rb
│               │   │   │   │   │   │   ├── nexus_upload.rb
│               │   │   │   │   │   │   ├── notarize.rb
│               │   │   │   │   │   │   ├── notification.rb
│               │   │   │   │   │   │   ├── notify.rb
│               │   │   │   │   │   │   ├── number_of_commits.rb
│               │   │   │   │   │   │   ├── oclint.rb
│               │   │   │   │   │   │   ├── onesignal.rb
│               │   │   │   │   │   │   ├── opt_out_crash_reporting.rb
│               │   │   │   │   │   │   ├── opt_out_usage.rb
│               │   │   │   │   │   │   ├── pem.rb
│               │   │   │   │   │   │   ├── pilot.rb
│               │   │   │   │   │   │   ├── pod_lib_lint.rb
│               │   │   │   │   │   │   ├── pod_push.rb
│               │   │   │   │   │   │   ├── podio_item.rb
│               │   │   │   │   │   │   ├── precheck.rb
│               │   │   │   │   │   │   ├── println.rb
│               │   │   │   │   │   │   ├── produce.rb
│               │   │   │   │   │   │   ├── prompt.rb
│               │   │   │   │   │   │   ├── push_git_tags.rb
│               │   │   │   │   │   │   ├── push_to_git_remote.rb
│               │   │   │   │   │   │   ├── puts.rb
│               │   │   │   │   │   │   ├── read_podspec.rb
│               │   │   │   │   │   │   ├── README.md
│               │   │   │   │   │   │   ├── recreate_schemes.rb
│               │   │   │   │   │   │   ├── register_device.rb
│               │   │   │   │   │   │   ├── register_devices.rb
│               │   │   │   │   │   │   ├── reset_git_repo.rb
│               │   │   │   │   │   │   ├── reset_simulator_contents.rb
│               │   │   │   │   │   │   ├── resign.rb
│               │   │   │   │   │   │   ├── restore_file.rb
│               │   │   │   │   │   │   ├── rocket.rb
│               │   │   │   │   │   │   ├── rsync.rb
│               │   │   │   │   │   │   ├── ruby_version.rb
│               │   │   │   │   │   │   ├── run_tests.rb
│               │   │   │   │   │   │   ├── s3.rb
│               │   │   │   │   │   │   ├── say.rb
│               │   │   │   │   │   │   ├── scan.rb
│               │   │   │   │   │   │   ├── scp.rb
│               │   │   │   │   │   │   ├── screengrab.rb
│               │   │   │   │   │   │   ├── set_build_number_repository.rb
│               │   │   │   │   │   │   ├── set_changelog.rb
│               │   │   │   │   │   │   ├── set_github_release.rb
│               │   │   │   │   │   │   ├── set_info_plist_value.rb
│               │   │   │   │   │   │   ├── set_pod_key.rb
│               │   │   │   │   │   │   ├── setup_ci.rb
│               │   │   │   │   │   │   ├── setup_circle_ci.rb
│               │   │   │   │   │   │   ├── setup_jenkins.rb
│               │   │   │   │   │   │   ├── setup_travis.rb
│               │   │   │   │   │   │   ├── sh.rb
│               │   │   │   │   │   │   ├── sigh.rb
│               │   │   │   │   │   │   ├── skip_docs.rb
│               │   │   │   │   │   │   ├── slack.rb
│               │   │   │   │   │   │   ├── slather.rb
│               │   │   │   │   │   │   ├── snapshot.rb
│               │   │   │   │   │   │   ├── sonar.rb
│               │   │   │   │   │   │   ├── sourcedocs.rb
│               │   │   │   │   │   │   ├── spaceship_logs.rb
│               │   │   │   │   │   │   ├── spaceship_stats.rb
│               │   │   │   │   │   │   ├── splunkmint.rb
│               │   │   │   │   │   │   ├── spm.rb
│               │   │   │   │   │   │   ├── ssh.rb
│               │   │   │   │   │   │   ├── supply.rb
│               │   │   │   │   │   │   ├── swiftlint.rb
│               │   │   │   │   │   │   ├── sync_code_signing.rb
│               │   │   │   │   │   │   ├── team_id.rb
│               │   │   │   │   │   │   ├── team_name.rb
│               │   │   │   │   │   │   ├── testfairy.rb
│               │   │   │   │   │   │   ├── testflight.rb
│               │   │   │   │   │   │   ├── trainer.rb
│               │   │   │   │   │   │   ├── tryouts.rb
│               │   │   │   │   │   │   ├── twitter.rb
│               │   │   │   │   │   │   ├── typetalk.rb
│               │   │   │   │   │   │   ├── unlock_keychain.rb
│               │   │   │   │   │   │   ├── update_app_group_identifiers.rb
│               │   │   │   │   │   │   ├── update_app_identifier.rb
│               │   │   │   │   │   │   ├── update_code_signing_settings.rb
│               │   │   │   │   │   │   ├── update_fastlane.rb
│               │   │   │   │   │   │   ├── update_icloud_container_identifiers.rb
│               │   │   │   │   │   │   ├── update_info_plist.rb
│               │   │   │   │   │   │   ├── update_keychain_access_groups.rb
│               │   │   │   │   │   │   ├── update_plist.rb
│               │   │   │   │   │   │   ├── update_project_code_signing.rb
│               │   │   │   │   │   │   ├── update_project_provisioning.rb
│               │   │   │   │   │   │   ├── update_project_team.rb
│               │   │   │   │   │   │   ├── update_urban_airship_configuration.rb
│               │   │   │   │   │   │   ├── update_url_schemes.rb
│               │   │   │   │   │   │   ├── upload_app_privacy_details_to_app_store.rb
│               │   │   │   │   │   │   ├── upload_symbols_to_crashlytics.rb
│               │   │   │   │   │   │   ├── upload_symbols_to_sentry.rb
│               │   │   │   │   │   │   ├── upload_to_app_store.rb
│               │   │   │   │   │   │   ├── upload_to_play_store_internal_app_sharing.rb
│               │   │   │   │   │   │   ├── upload_to_play_store.rb
│               │   │   │   │   │   │   ├── upload_to_testflight.rb
│               │   │   │   │   │   │   ├── validate_play_store_json_key.rb
│               │   │   │   │   │   │   ├── verify_build.rb
│               │   │   │   │   │   │   ├── verify_pod_keys.rb
│               │   │   │   │   │   │   ├── verify_xcode.rb
│               │   │   │   │   │   │   ├── version_bump_podspec.rb
│               │   │   │   │   │   │   ├── version_get_podspec.rb
│               │   │   │   │   │   │   ├── xcode_install.rb
│               │   │   │   │   │   │   ├── xcode_select.rb
│               │   │   │   │   │   │   ├── xcode_server_get_assets.rb
│               │   │   │   │   │   │   ├── xcodebuild.rb
│               │   │   │   │   │   │   ├── xcodes.rb
│               │   │   │   │   │   │   ├── xcov.rb
│               │   │   │   │   │   │   ├── xctool.rb
│               │   │   │   │   │   │   ├── xcversion.rb
│               │   │   │   │   │   │   └── zip.rb
│               │   │   │   │   │   ├── [01;34mcore_ext[0m
│               │   │   │   │   │   │   └── bundler_monkey_patch.rb
│               │   │   │   │   │   ├── [01;34mdocumentation[0m
│               │   │   │   │   │   │   ├── actions_list.rb
│               │   │   │   │   │   │   ├── docs_generator.rb
│               │   │   │   │   │   │   └── markdown_docs_generator.rb
│               │   │   │   │   │   ├── [01;34mhelper[0m
│               │   │   │   │   │   │   ├── adb_helper.rb
│               │   │   │   │   │   │   ├── dotenv_helper.rb
│               │   │   │   │   │   │   ├── gem_helper.rb
│               │   │   │   │   │   │   ├── git_helper.rb
│               │   │   │   │   │   │   ├── gradle_helper.rb
│               │   │   │   │   │   │   ├── lane_helper.rb
│               │   │   │   │   │   │   ├── podspec_helper.rb
│               │   │   │   │   │   │   ├── README.md
│               │   │   │   │   │   │   ├── s3_client_helper.rb
│               │   │   │   │   │   │   ├── sh_helper.rb
│               │   │   │   │   │   │   ├── xcodebuild_formatter_helper.rb
│               │   │   │   │   │   │   ├── xcodeproj_helper.rb
│               │   │   │   │   │   │   ├── xcodes_helper.rb
│               │   │   │   │   │   │   └── xcversion_helper.rb
│               │   │   │   │   │   ├── [01;34mnotification[0m
│               │   │   │   │   │   │   └── slack.rb
│               │   │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   │   ├── [01;34mtemplate[0m
│               │   │   │   │   │   │   │   ├── [01;34mfastlane[0m
│               │   │   │   │   │   │   │   │   ├── Fastfile.erb
│               │   │   │   │   │   │   │   │   └── Pluginfile.erb
│               │   │   │   │   │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   │   │   │   │   └── [01;34mfastlane[0m
│               │   │   │   │   │   │   │   │       └── [01;34mplugin[0m
│               │   │   │   │   │   │   │   │           ├── [01;34m%plugin_name%[0m
│               │   │   │   │   │   │   │   │           │   ├── [01;34mactions[0m
│               │   │   │   │   │   │   │   │           │   │   └── %plugin_name%_action.rb.erb
│               │   │   │   │   │   │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │   │   │   │   │   │           │   │   └── %plugin_name%_helper.rb.erb
│               │   │   │   │   │   │   │   │           │   └── version.rb.erb
│               │   │   │   │   │   │   │   │           └── %plugin_name%.rb.erb
│               │   │   │   │   │   │   │   ├── [01;34mspec[0m
│               │   │   │   │   │   │   │   │   ├── %plugin_name%_action_spec.rb.erb
│               │   │   │   │   │   │   │   │   └── spec_helper.rb.erb
│               │   │   │   │   │   │   │   ├── %gem_name%.gemspec.erb
│               │   │   │   │   │   │   │   ├── Gemfile.erb
│               │   │   │   │   │   │   │   ├── LICENSE.erb
│               │   │   │   │   │   │   │   ├── Rakefile
│               │   │   │   │   │   │   │   └── README.md.erb
│               │   │   │   │   │   │   ├── plugin_fetcher.rb
│               │   │   │   │   │   │   ├── plugin_generator_ui.rb
│               │   │   │   │   │   │   ├── plugin_generator.rb
│               │   │   │   │   │   │   ├── plugin_info_collector.rb
│               │   │   │   │   │   │   ├── plugin_info.rb
│               │   │   │   │   │   │   ├── plugin_manager.rb
│               │   │   │   │   │   │   ├── plugin_search.rb
│               │   │   │   │   │   │   ├── plugin_update_manager.rb
│               │   │   │   │   │   │   └── plugins.rb
│               │   │   │   │   │   ├── [01;34mserver[0m
│               │   │   │   │   │   │   ├── action_command_return.rb
│               │   │   │   │   │   │   ├── action_command.rb
│               │   │   │   │   │   │   ├── command_executor.rb
│               │   │   │   │   │   │   ├── command_parser.rb
│               │   │   │   │   │   │   ├── control_command.rb
│               │   │   │   │   │   │   ├── json_return_value_processor.rb
│               │   │   │   │   │   │   ├── socket_server_action_command_executor.rb
│               │   │   │   │   │   │   └── socket_server.rb
│               │   │   │   │   │   ├── [01;34msetup[0m
│               │   │   │   │   │   │   ├── setup_android.rb
│               │   │   │   │   │   │   ├── setup_ios.rb
│               │   │   │   │   │   │   └── setup.rb
│               │   │   │   │   │   ├── action_collector.rb
│               │   │   │   │   │   ├── action.rb
│               │   │   │   │   │   ├── auto_complete.rb
│               │   │   │   │   │   ├── boolean.rb
│               │   │   │   │   │   ├── cli_tools_distributor.rb
│               │   │   │   │   │   ├── command_line_handler.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── configuration_helper.rb
│               │   │   │   │   │   ├── console.rb
│               │   │   │   │   │   ├── environment_printer.rb
│               │   │   │   │   │   ├── erb_template_helper.rb
│               │   │   │   │   │   ├── fast_file.rb
│               │   │   │   │   │   ├── fastlane_require.rb
│               │   │   │   │   │   ├── features.rb
│               │   │   │   │   │   ├── junit_generator.rb
│               │   │   │   │   │   ├── lane_list.rb
│               │   │   │   │   │   ├── lane_manager_base.rb
│               │   │   │   │   │   ├── lane_manager.rb
│               │   │   │   │   │   ├── lane.rb
│               │   │   │   │   │   ├── markdown_table_formatter.rb
│               │   │   │   │   │   ├── new_action.rb
│               │   │   │   │   │   ├── one_off.rb
│               │   │   │   │   │   ├── other_action.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   ├── shells.rb
│               │   │   │   │   │   ├── supported_platforms.rb
│               │   │   │   │   │   ├── swift_fastlane_api_generator.rb
│               │   │   │   │   │   ├── swift_fastlane_function.rb
│               │   │   │   │   │   ├── swift_lane_manager.rb
│               │   │   │   │   │   ├── swift_runner_upgrader.rb
│               │   │   │   │   │   ├── tools.rb
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── fastlane.rb
│               │   │   │   ├── [01;34mswift[0m
│               │   │   │   │   ├── [01;34mFastlaneSwiftRunner[0m
│               │   │   │   │   │   ├── [01;34mFastlaneSwiftRunner.xcodeproj[0m
│               │   │   │   │   │   │   ├── [01;34mxcshareddata[0m
│               │   │   │   │   │   │   │   └── [01;34mxcschemes[0m
│               │   │   │   │   │   │   │       └── FastlaneRunner.xcscheme
│               │   │   │   │   │   │   └── project.pbxproj
│               │   │   │   │   │   └── README.txt
│               │   │   │   │   ├── [01;34mformatting[0m
│               │   │   │   │   │   ├── Brewfile
│               │   │   │   │   │   ├── Brewfile.lock.json
│               │   │   │   │   │   └── Rakefile
│               │   │   │   │   ├── Actions.swift
│               │   │   │   │   ├── Appfile.swift
│               │   │   │   │   ├── ArgumentProcessor.swift
│               │   │   │   │   ├── Atomic.swift
│               │   │   │   │   ├── ControlCommand.swift
│               │   │   │   │   ├── Deliverfile.swift
│               │   │   │   │   ├── DeliverfileProtocol.swift
│               │   │   │   │   ├── Fastfile.swift
│               │   │   │   │   ├── Fastlane.swift
│               │   │   │   │   ├── Gymfile.swift
│               │   │   │   │   ├── GymfileProtocol.swift
│               │   │   │   │   ├── LaneFileProtocol.swift
│               │   │   │   │   ├── main.swift
│               │   │   │   │   ├── MainProcess.swift
│               │   │   │   │   ├── Matchfile.swift
│               │   │   │   │   ├── MatchfileProtocol.swift
│               │   │   │   │   ├── OptionalConfigValue.swift
│               │   │   │   │   ├── Plugins.swift
│               │   │   │   │   ├── Precheckfile.swift
│               │   │   │   │   ├── PrecheckfileProtocol.swift
│               │   │   │   │   ├── RubyCommand.swift
│               │   │   │   │   ├── RubyCommandable.swift
│               │   │   │   │   ├── Runner.swift
│               │   │   │   │   ├── RunnerArgument.swift
│               │   │   │   │   ├── Scanfile.swift
│               │   │   │   │   ├── ScanfileProtocol.swift
│               │   │   │   │   ├── Screengrabfile.swift
│               │   │   │   │   ├── ScreengrabfileProtocol.swift
│               │   │   │   │   ├── Snapshotfile.swift
│               │   │   │   │   ├── SnapshotfileProtocol.swift
│               │   │   │   │   ├── SocketClient.swift
│               │   │   │   │   ├── SocketClientDelegateProtocol.swift
│               │   │   │   │   ├── SocketResponse.swift
│               │   │   │   │   └── upgrade_manifest.json
│               │   │   │   └── README.md
│               │   │   ├── [01;34mfastlane_core[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   └── XMLTemplate.xml.erb
│               │   │   │   │   ├── [01;34mfastlane_core[0m
│               │   │   │   │   │   ├── [01;34manalytics[0m
│               │   │   │   │   │   │   ├── action_completion_context.rb
│               │   │   │   │   │   │   ├── action_launch_context.rb
│               │   │   │   │   │   │   ├── analytics_event_builder.rb
│               │   │   │   │   │   │   ├── analytics_ingester_client.rb
│               │   │   │   │   │   │   ├── analytics_session.rb
│               │   │   │   │   │   │   └── app_identifier_guesser.rb
│               │   │   │   │   │   ├── [01;34mconfiguration[0m
│               │   │   │   │   │   │   ├── commander_generator.rb
│               │   │   │   │   │   │   ├── config_item.rb
│               │   │   │   │   │   │   ├── configuration_file.rb
│               │   │   │   │   │   │   └── configuration.rb
│               │   │   │   │   │   ├── [01;34mcore_ext[0m
│               │   │   │   │   │   │   ├── cfpropertylist.rb
│               │   │   │   │   │   │   ├── shellwords.rb
│               │   │   │   │   │   │   └── string.rb
│               │   │   │   │   │   ├── [01;34mfeature[0m
│               │   │   │   │   │   │   └── feature.rb
│               │   │   │   │   │   ├── [01;34mui[0m
│               │   │   │   │   │   │   ├── [01;34merrors[0m
│               │   │   │   │   │   │   │   ├── fastlane_common_error.rb
│               │   │   │   │   │   │   │   ├── fastlane_crash.rb
│               │   │   │   │   │   │   │   ├── fastlane_error.rb
│               │   │   │   │   │   │   │   ├── fastlane_exception.rb
│               │   │   │   │   │   │   │   └── fastlane_shell_error.rb
│               │   │   │   │   │   │   ├── [01;34mimplementations[0m
│               │   │   │   │   │   │   │   └── shell.rb
│               │   │   │   │   │   │   ├── disable_colors.rb
│               │   │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   │   ├── fastlane_runner.rb
│               │   │   │   │   │   │   ├── github_issue_inspector_reporter.rb
│               │   │   │   │   │   │   ├── help_formatter.rb
│               │   │   │   │   │   │   ├── help.erb
│               │   │   │   │   │   │   ├── interface.rb
│               │   │   │   │   │   │   └── ui.rb
│               │   │   │   │   │   ├── [01;34mupdate_checker[0m
│               │   │   │   │   │   │   ├── changelog.rb
│               │   │   │   │   │   │   └── update_checker.rb
│               │   │   │   │   │   ├── android_package_name_guesser.rb
│               │   │   │   │   │   ├── build_watcher.rb
│               │   │   │   │   │   ├── cert_checker.rb
│               │   │   │   │   │   ├── clipboard.rb
│               │   │   │   │   │   ├── command_executor.rb
│               │   │   │   │   │   ├── device_manager.rb
│               │   │   │   │   │   ├── env.rb
│               │   │   │   │   │   ├── fastlane_folder.rb
│               │   │   │   │   │   ├── fastlane_pty.rb
│               │   │   │   │   │   ├── features.rb
│               │   │   │   │   │   ├── globals.rb
│               │   │   │   │   │   ├── helper.rb
│               │   │   │   │   │   ├── ios_app_identifier_guesser.rb
│               │   │   │   │   │   ├── ipa_file_analyser.rb
│               │   │   │   │   │   ├── ipa_upload_package_builder.rb
│               │   │   │   │   │   ├── itunes_transporter.rb
│               │   │   │   │   │   ├── keychain_importer.rb
│               │   │   │   │   │   ├── languages.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── pkg_file_analyser.rb
│               │   │   │   │   │   ├── pkg_upload_package_builder.rb
│               │   │   │   │   │   ├── print_table.rb
│               │   │   │   │   │   ├── project.rb
│               │   │   │   │   │   ├── provisioning_profile.rb
│               │   │   │   │   │   ├── queue_worker.rb
│               │   │   │   │   │   ├── string_filters.rb
│               │   │   │   │   │   ├── swag.rb
│               │   │   │   │   │   ├── tag_version.rb
│               │   │   │   │   │   └── test_parser.rb
│               │   │   │   │   └── fastlane_core.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mframeit[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   └── [01;35mempty.png[0m
│               │   │   │   │   ├── [01;34mframeit[0m
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── config_parser.rb
│               │   │   │   │   │   ├── dependency_checker.rb
│               │   │   │   │   │   ├── device_types.rb
│               │   │   │   │   │   ├── device.rb
│               │   │   │   │   │   ├── editor.rb
│               │   │   │   │   │   ├── frame_downloader.rb
│               │   │   │   │   │   ├── mac_editor.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── offsets.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   ├── screenshot.rb
│               │   │   │   │   │   ├── strings_parser.rb
│               │   │   │   │   │   ├── template_finder.rb
│               │   │   │   │   │   └── trim_box.rb
│               │   │   │   │   └── frameit.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mgym[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── [01;34mwrap_xcodebuild[0m
│               │   │   │   │   │   │   └── [01;32mxcbuild-safe.sh[0m
│               │   │   │   │   │   ├── GymfileTemplate
│               │   │   │   │   │   └── GymfileTemplate.swift
│               │   │   │   │   ├── [01;34mgym[0m
│               │   │   │   │   │   ├── [01;34mgenerators[0m
│               │   │   │   │   │   │   ├── build_command_generator.rb
│               │   │   │   │   │   │   ├── package_command_generator_xcode7.rb
│               │   │   │   │   │   │   ├── package_command_generator.rb
│               │   │   │   │   │   │   └── README.md
│               │   │   │   │   │   ├── [01;34mxcodebuild_fixes[0m
│               │   │   │   │   │   │   ├── generic_archive_fix.rb
│               │   │   │   │   │   │   └── README.md
│               │   │   │   │   │   ├── code_signing_mapping.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── detect_values.rb
│               │   │   │   │   │   ├── error_handler.rb
│               │   │   │   │   │   ├── manager.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   └── xcode.rb
│               │   │   │   │   └── gym.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mmatch[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── MatchfileTemplate
│               │   │   │   │   │   ├── MatchfileTemplate.swift
│               │   │   │   │   │   └── READMETemplate.md
│               │   │   │   │   ├── [01;34mmatch[0m
│               │   │   │   │   │   ├── [01;34mencryption[0m
│               │   │   │   │   │   │   ├── encryption.rb
│               │   │   │   │   │   │   ├── interface.rb
│               │   │   │   │   │   │   └── openssl.rb
│               │   │   │   │   │   ├── [01;34mstorage[0m
│               │   │   │   │   │   │   ├── [01;34mgitlab[0m
│               │   │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   │   └── secure_file.rb
│               │   │   │   │   │   │   ├── git_storage.rb
│               │   │   │   │   │   │   ├── gitlab_secure_files.rb
│               │   │   │   │   │   │   ├── google_cloud_storage.rb
│               │   │   │   │   │   │   ├── interface.rb
│               │   │   │   │   │   │   └── s3_storage.rb
│               │   │   │   │   │   ├── change_password.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── encryption.rb
│               │   │   │   │   │   ├── generator.rb
│               │   │   │   │   │   ├── importer.rb
│               │   │   │   │   │   ├── migrate.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── nuke.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── portal_cache.rb
│               │   │   │   │   │   ├── portal_fetcher.rb
│               │   │   │   │   │   ├── profile_includes.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   ├── setup.rb
│               │   │   │   │   │   ├── spaceship_ensure.rb
│               │   │   │   │   │   ├── storage.rb
│               │   │   │   │   │   ├── table_printer.rb
│               │   │   │   │   │   └── utils.rb
│               │   │   │   │   └── match.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mpem[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34mpem[0m
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── manager.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   └── options.rb
│               │   │   │   │   └── pem.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mpilot[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34mpilot[0m
│               │   │   │   │   │   ├── build_manager.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── manager.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── tester_exporter.rb
│               │   │   │   │   │   ├── tester_importer.rb
│               │   │   │   │   │   └── tester_manager.rb
│               │   │   │   │   └── pilot.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mprecheck[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── PrecheckfileTemplate
│               │   │   │   │   │   └── PrecheckfileTemplate.swift
│               │   │   │   │   ├── [01;34mprecheck[0m
│               │   │   │   │   │   ├── [01;34mrules[0m
│               │   │   │   │   │   │   ├── [01;34mrules_data[0m
│               │   │   │   │   │   │   │   └── [01;34mcurse_word_hashes[0m
│               │   │   │   │   │   │   │       └── en_us.txt
│               │   │   │   │   │   │   ├── abstract_text_match_rule.rb
│               │   │   │   │   │   │   ├── all.rb
│               │   │   │   │   │   │   ├── copyright_date_rule.rb
│               │   │   │   │   │   │   ├── curse_words_rule.rb
│               │   │   │   │   │   │   ├── custom_text_rule.rb
│               │   │   │   │   │   │   ├── free_stuff_iap_rule.rb
│               │   │   │   │   │   │   ├── future_functionality_rule.rb
│               │   │   │   │   │   │   ├── negative_apple_sentiment_rule.rb
│               │   │   │   │   │   │   ├── other_platforms_rule.rb
│               │   │   │   │   │   │   ├── placeholder_words_rule.rb
│               │   │   │   │   │   │   ├── test_words_rule.rb
│               │   │   │   │   │   │   └── unreachable_urls_rule.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── item_to_check.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── rule_check_result.rb
│               │   │   │   │   │   ├── rule_processor.rb
│               │   │   │   │   │   ├── rule.rb
│               │   │   │   │   │   └── runner.rb
│               │   │   │   │   └── precheck.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mproduce[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34mproduce[0m
│               │   │   │   │   │   ├── available_default_languages.rb
│               │   │   │   │   │   ├── cloud_container.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── developer_center.rb
│               │   │   │   │   │   ├── group.rb
│               │   │   │   │   │   ├── itunes_connect.rb
│               │   │   │   │   │   ├── manager.rb
│               │   │   │   │   │   ├── merchant.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   └── service.rb
│               │   │   │   │   └── produce.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mscan[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── ScanfileTemplate
│               │   │   │   │   │   └── ScanfileTemplate.swift
│               │   │   │   │   ├── [01;34mscan[0m
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── detect_values.rb
│               │   │   │   │   │   ├── error_handler.rb
│               │   │   │   │   │   ├── manager.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── [01;32moptions.rb[0m
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   ├── slack_poster.rb
│               │   │   │   │   │   ├── test_command_generator.rb
│               │   │   │   │   │   ├── test_result_parser.rb
│               │   │   │   │   │   └── xcpretty_reporter_options_generator.rb
│               │   │   │   │   └── scan.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mscreengrab[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── ScreengrabfileTemplate
│               │   │   │   │   │   └── ScreengrabfileTemplate.swift
│               │   │   │   │   ├── [01;34mscreengrab[0m
│               │   │   │   │   │   ├── android_environment.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── dependency_checker.rb
│               │   │   │   │   │   ├── detect_values.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── page.html.erb
│               │   │   │   │   │   ├── reports_generator.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   └── setup.rb
│               │   │   │   │   └── screengrab.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34msigh[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   └── [01;32mresign.sh[0m
│               │   │   │   │   ├── [01;34msigh[0m
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── download_all.rb
│               │   │   │   │   │   ├── local_manage.rb
│               │   │   │   │   │   ├── manager.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── repair.rb
│               │   │   │   │   │   ├── resign.rb
│               │   │   │   │   │   └── runner.rb
│               │   │   │   │   └── sigh.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34msnapshot[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── SnapfileTemplate
│               │   │   │   │   │   ├── SnapfileTemplate.swift
│               │   │   │   │   │   ├── SnapshotHelper.swift
│               │   │   │   │   │   └── SnapshotHelperXcode8.swift
│               │   │   │   │   ├── [01;34msnapshot[0m
│               │   │   │   │   │   ├── [01;34mfixes[0m
│               │   │   │   │   │   │   ├── hardware_keyboard_fix.rb
│               │   │   │   │   │   │   ├── README.md
│               │   │   │   │   │   │   ├── simulator_shared_pasteboard.rb
│               │   │   │   │   │   │   └── simulator_zoom_fix.rb
│               │   │   │   │   │   ├── [01;34msimulator_launchers[0m
│               │   │   │   │   │   │   ├── launcher_configuration.rb
│               │   │   │   │   │   │   ├── simulator_launcher_base.rb
│               │   │   │   │   │   │   ├── simulator_launcher_xcode_8.rb
│               │   │   │   │   │   │   └── simulator_launcher.rb
│               │   │   │   │   │   ├── collector.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── dependency_checker.rb
│               │   │   │   │   │   ├── detect_values.rb
│               │   │   │   │   │   ├── error_handler.rb
│               │   │   │   │   │   ├── latest_os_version.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── options.rb
│               │   │   │   │   │   ├── page.html.erb
│               │   │   │   │   │   ├── reports_generator.rb
│               │   │   │   │   │   ├── reset_simulators.rb
│               │   │   │   │   │   ├── runner.rb
│               │   │   │   │   │   ├── screenshot_flatten.rb
│               │   │   │   │   │   ├── screenshot_rotate.rb
│               │   │   │   │   │   ├── setup.rb
│               │   │   │   │   │   ├── test_command_generator_base.rb
│               │   │   │   │   │   ├── test_command_generator_xcode_8.rb
│               │   │   │   │   │   ├── test_command_generator.rb
│               │   │   │   │   │   └── update.rb
│               │   │   │   │   └── snapshot.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34mspaceship[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34massets[0m
│               │   │   │   │   │   ├── displayFamilies.json
│               │   │   │   │   │   ├── languageMapping.json
│               │   │   │   │   │   └── languageMappingReadable.json
│               │   │   │   │   ├── [01;34mspaceship[0m
│               │   │   │   │   │   ├── [01;34mconnect_api[0m
│               │   │   │   │   │   │   ├── [01;34mmodels[0m
│               │   │   │   │   │   │   │   ├── actor.rb
│               │   │   │   │   │   │   │   ├── age_rating_declaration.rb
│               │   │   │   │   │   │   │   ├── app_availability.rb
│               │   │   │   │   │   │   │   ├── app_category.rb
│               │   │   │   │   │   │   │   ├── app_data_usage_category.rb
│               │   │   │   │   │   │   │   ├── app_data_usage_data_protection.rb
│               │   │   │   │   │   │   │   ├── app_data_usage_grouping.rb
│               │   │   │   │   │   │   │   ├── app_data_usage_purposes.rb
│               │   │   │   │   │   │   │   ├── app_data_usage.rb
│               │   │   │   │   │   │   │   ├── app_data_usages_publish_state.rb
│               │   │   │   │   │   │   │   ├── app_info_localization.rb
│               │   │   │   │   │   │   │   ├── app_info.rb
│               │   │   │   │   │   │   │   ├── app_preview_set.rb
│               │   │   │   │   │   │   │   ├── app_preview.rb
│               │   │   │   │   │   │   │   ├── app_price_point.rb
│               │   │   │   │   │   │   │   ├── app_price_tier.rb
│               │   │   │   │   │   │   │   ├── app_price.rb
│               │   │   │   │   │   │   │   ├── app_screenshot_set.rb
│               │   │   │   │   │   │   │   ├── app_screenshot.rb
│               │   │   │   │   │   │   │   ├── app_store_review_attachment.rb
│               │   │   │   │   │   │   │   ├── app_store_review_detail.rb
│               │   │   │   │   │   │   │   ├── app_store_version_localization.rb
│               │   │   │   │   │   │   │   ├── app_store_version_phased_release.rb
│               │   │   │   │   │   │   │   ├── app_store_version_release_request.rb
│               │   │   │   │   │   │   │   ├── app_store_version_submission.rb
│               │   │   │   │   │   │   │   ├── app_store_version.rb
│               │   │   │   │   │   │   │   ├── app.rb
│               │   │   │   │   │   │   │   ├── beta_app_localization.rb
│               │   │   │   │   │   │   │   ├── beta_app_review_detail.rb
│               │   │   │   │   │   │   │   ├── beta_app_review_submission.rb
│               │   │   │   │   │   │   │   ├── beta_build_localization.rb
│               │   │   │   │   │   │   │   ├── beta_build_metric.rb
│               │   │   │   │   │   │   │   ├── beta_feedback.rb
│               │   │   │   │   │   │   │   ├── beta_group.rb
│               │   │   │   │   │   │   │   ├── beta_screenshot.rb
│               │   │   │   │   │   │   │   ├── beta_tester_metric.rb
│               │   │   │   │   │   │   │   ├── beta_tester.rb
│               │   │   │   │   │   │   │   ├── build_beta_detail.rb
│               │   │   │   │   │   │   │   ├── build_bundle_file_sizes.rb
│               │   │   │   │   │   │   │   ├── build_bundle.rb
│               │   │   │   │   │   │   │   ├── build_delivery.rb
│               │   │   │   │   │   │   │   ├── build.rb
│               │   │   │   │   │   │   │   ├── bundle_id_capability.rb
│               │   │   │   │   │   │   │   ├── bundle_id.rb
│               │   │   │   │   │   │   │   ├── capabilities.rb
│               │   │   │   │   │   │   │   ├── certificate.rb
│               │   │   │   │   │   │   │   ├── custom_app_organization.rb
│               │   │   │   │   │   │   │   ├── custom_app_user.rb
│               │   │   │   │   │   │   │   ├── device.rb
│               │   │   │   │   │   │   │   ├── pre_release_version.rb
│               │   │   │   │   │   │   │   ├── profile.rb
│               │   │   │   │   │   │   │   ├── reset_ratings_request.rb
│               │   │   │   │   │   │   │   ├── resolution_center_message.rb
│               │   │   │   │   │   │   │   ├── resolution_center_thread.rb
│               │   │   │   │   │   │   │   ├── review_rejection.rb
│               │   │   │   │   │   │   │   ├── review_submission_item.rb
│               │   │   │   │   │   │   │   ├── review_submission.rb
│               │   │   │   │   │   │   │   ├── sandbox_tester.rb
│               │   │   │   │   │   │   │   ├── territory_availability.rb
│               │   │   │   │   │   │   │   ├── territory.rb
│               │   │   │   │   │   │   │   ├── user_invitation.rb
│               │   │   │   │   │   │   │   └── user.rb
│               │   │   │   │   │   │   ├── [01;34mprovisioning[0m
│               │   │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   │   └── provisioning.rb
│               │   │   │   │   │   │   ├── [01;34mtestflight[0m
│               │   │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   │   └── testflight.rb
│               │   │   │   │   │   │   ├── [01;34mtunes[0m
│               │   │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   │   └── tunes.rb
│               │   │   │   │   │   │   ├── [01;34musers[0m
│               │   │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   │   └── users.rb
│               │   │   │   │   │   │   ├── api_client.rb
│               │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   ├── file_uploader.rb
│               │   │   │   │   │   │   ├── model.rb
│               │   │   │   │   │   │   ├── response.rb
│               │   │   │   │   │   │   ├── spaceship.rb
│               │   │   │   │   │   │   ├── token_refresh_middleware.rb
│               │   │   │   │   │   │   └── token.rb
│               │   │   │   │   │   ├── [01;34mdu[0m
│               │   │   │   │   │   │   ├── du_client.rb
│               │   │   │   │   │   │   ├── upload_file.rb
│               │   │   │   │   │   │   └── utilities.rb
│               │   │   │   │   │   ├── [01;34mhelper[0m
│               │   │   │   │   │   │   ├── net_http_generic_request.rb
│               │   │   │   │   │   │   ├── plist_middleware.rb
│               │   │   │   │   │   │   └── rels_middleware.rb
│               │   │   │   │   │   ├── [01;34mportal[0m
│               │   │   │   │   │   │   ├── [01;34mui[0m
│               │   │   │   │   │   │   │   └── select_team.rb
│               │   │   │   │   │   │   ├── app_group.rb
│               │   │   │   │   │   │   ├── app_service.rb
│               │   │   │   │   │   │   ├── app.rb
│               │   │   │   │   │   │   ├── certificate.rb
│               │   │   │   │   │   │   ├── cloud_container.rb
│               │   │   │   │   │   │   ├── device.rb
│               │   │   │   │   │   │   ├── invite.rb
│               │   │   │   │   │   │   ├── key.rb
│               │   │   │   │   │   │   ├── legacy_wrapper.rb
│               │   │   │   │   │   │   ├── merchant.rb
│               │   │   │   │   │   │   ├── passbook.rb
│               │   │   │   │   │   │   ├── person.rb
│               │   │   │   │   │   │   ├── persons.rb
│               │   │   │   │   │   │   ├── portal_base.rb
│               │   │   │   │   │   │   ├── portal_client.rb
│               │   │   │   │   │   │   ├── portal.rb
│               │   │   │   │   │   │   ├── provisioning_profile_template.rb
│               │   │   │   │   │   │   ├── provisioning_profile.rb
│               │   │   │   │   │   │   ├── spaceship.rb
│               │   │   │   │   │   │   └── website_push.rb
│               │   │   │   │   │   ├── [01;34mtest_flight[0m
│               │   │   │   │   │   │   ├── app_test_info.rb
│               │   │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   │   ├── beta_review_info.rb
│               │   │   │   │   │   │   ├── build_trains.rb
│               │   │   │   │   │   │   ├── build.rb
│               │   │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   │   ├── export_compliance.rb
│               │   │   │   │   │   │   ├── group.rb
│               │   │   │   │   │   │   ├── test_info.rb
│               │   │   │   │   │   │   └── tester.rb
│               │   │   │   │   │   ├── [01;34mtunes[0m
│               │   │   │   │   │   │   ├── app_analytics.rb
│               │   │   │   │   │   │   ├── app_details.rb
│               │   │   │   │   │   │   ├── app_image.rb
│               │   │   │   │   │   │   ├── app_ratings.rb
│               │   │   │   │   │   │   ├── app_review_attachment.rb
│               │   │   │   │   │   │   ├── app_review.rb
│               │   │   │   │   │   │   ├── app_screenshot.rb
│               │   │   │   │   │   │   ├── app_status.rb
│               │   │   │   │   │   │   ├── app_submission.rb
│               │   │   │   │   │   │   ├── app_trailer.rb
│               │   │   │   │   │   │   ├── app_version_common.rb
│               │   │   │   │   │   │   ├── app_version_generated_promocodes.rb
│               │   │   │   │   │   │   ├── app_version_history.rb
│               │   │   │   │   │   │   ├── app_version_promocodes.rb
│               │   │   │   │   │   │   ├── app_version_ref.rb
│               │   │   │   │   │   │   ├── app_version_states_history.rb
│               │   │   │   │   │   │   ├── app_version.rb
│               │   │   │   │   │   │   ├── application.rb
│               │   │   │   │   │   │   ├── availability.rb
│               │   │   │   │   │   │   ├── b2b_organization.rb
│               │   │   │   │   │   │   ├── b2b_user.rb
│               │   │   │   │   │   │   ├── build_details.rb
│               │   │   │   │   │   │   ├── build_train.rb
│               │   │   │   │   │   │   ├── build.rb
│               │   │   │   │   │   │   ├── developer_response.rb
│               │   │   │   │   │   │   ├── device_type.rb
│               │   │   │   │   │   │   ├── display_family.rb
│               │   │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   │   ├── iap_detail.rb
│               │   │   │   │   │   │   ├── iap_families.rb
│               │   │   │   │   │   │   ├── iap_family_details.rb
│               │   │   │   │   │   │   ├── iap_family_list.rb
│               │   │   │   │   │   │   ├── iap_list.rb
│               │   │   │   │   │   │   ├── iap_status.rb
│               │   │   │   │   │   │   ├── iap_subscription_pricing_info.rb
│               │   │   │   │   │   │   ├── iap_subscription_pricing_tier.rb
│               │   │   │   │   │   │   ├── iap_type.rb
│               │   │   │   │   │   │   ├── iap.rb
│               │   │   │   │   │   │   ├── language_converter.rb
│               │   │   │   │   │   │   ├── language_item.rb
│               │   │   │   │   │   │   ├── legacy_wrapper.rb
│               │   │   │   │   │   │   ├── member.rb
│               │   │   │   │   │   │   ├── members.rb
│               │   │   │   │   │   │   ├── pricing_info.rb
│               │   │   │   │   │   │   ├── pricing_tier.rb
│               │   │   │   │   │   │   ├── sandbox_tester.rb
│               │   │   │   │   │   │   ├── spaceship.rb
│               │   │   │   │   │   │   ├── territory.rb
│               │   │   │   │   │   │   ├── transit_app_file.rb
│               │   │   │   │   │   │   ├── tunes_base.rb
│               │   │   │   │   │   │   ├── tunes_client.rb
│               │   │   │   │   │   │   ├── tunes.rb
│               │   │   │   │   │   │   └── version_set.rb
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── connect_api.rb
│               │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   ├── globals.rb
│               │   │   │   │   │   ├── hashcash.rb
│               │   │   │   │   │   ├── launcher.rb
│               │   │   │   │   │   ├── module.rb
│               │   │   │   │   │   ├── playground.rb
│               │   │   │   │   │   ├── provider.rb
│               │   │   │   │   │   ├── spaceauth_runner.rb
│               │   │   │   │   │   ├── stats_middleware.rb
│               │   │   │   │   │   ├── test_flight.rb
│               │   │   │   │   │   ├── [01;32mtwo_step_or_factor_client.rb[0m
│               │   │   │   │   │   ├── ui.rb
│               │   │   │   │   │   └── upgrade_2fa_later_client.rb
│               │   │   │   │   └── spaceship.rb
│               │   │   │   └── README.md
│               │   │   ├── [01;34msupply[0m
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   ├── [01;34msupply[0m
│               │   │   │   │   │   ├── apk_listing.rb
│               │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   ├── commands_generator.rb
│               │   │   │   │   │   ├── generated_universal_apk.rb
│               │   │   │   │   │   ├── image_listing.rb
│               │   │   │   │   │   ├── languages.rb
│               │   │   │   │   │   ├── listing.rb
│               │   │   │   │   │   ├── [01;32moptions.rb[0m
│               │   │   │   │   │   ├── reader.rb
│               │   │   │   │   │   ├── release_listing.rb
│               │   │   │   │   │   ├── [01;32msetup.rb[0m
│               │   │   │   │   │   └── uploader.rb
│               │   │   │   │   └── [01;32msupply.rb[0m
│               │   │   │   └── README.md
│               │   │   ├── [01;34mtrainer[0m
│               │   │   │   └── [01;34mlib[0m
│               │   │   │       ├── [01;34massets[0m
│               │   │   │       │   └── junit.xml.erb
│               │   │   │       ├── [01;34mtrainer[0m
│               │   │   │       │   ├── [01;34mxcresult[0m
│               │   │   │       │   │   ├── helper.rb
│               │   │   │       │   │   ├── repetition.rb
│               │   │   │       │   │   ├── test_case_attributes.rb
│               │   │   │       │   │   ├── test_case.rb
│               │   │   │       │   │   ├── test_plan.rb
│               │   │   │       │   │   └── test_suite.rb
│               │   │   │       │   ├── commands_generator.rb
│               │   │   │       │   ├── junit_generator.rb
│               │   │   │       │   ├── legacy_xcresult.rb
│               │   │   │       │   ├── module.rb
│               │   │   │       │   ├── options.rb
│               │   │   │       │   ├── plist_test_summary_parser.rb
│               │   │   │       │   ├── test_parser.rb
│               │   │   │       │   └── xcresult.rb
│               │   │   │       └── trainer.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-plugin-appicon-0.16.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfastlane[0m
│               │   │   │       └── [01;34mplugin[0m
│               │   │   │           ├── [01;34mappicon[0m
│               │   │   │           │   ├── [01;34mactions[0m
│               │   │   │           │   │   ├── android_appicon_action.rb
│               │   │   │           │   │   └── appicon_action.rb
│               │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │           │   │   └── appicon_helper.rb
│               │   │   │           │   └── version.rb
│               │   │   │           └── appicon.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-plugin-badge-1.5.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfastlane[0m
│               │   │   │       └── [01;34mplugin[0m
│               │   │   │           ├── [01;34mbadge[0m
│               │   │   │           │   ├── [01;34mactions[0m
│               │   │   │           │   │   └── add_badge_action.rb
│               │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │           │   │   └── badge_helper.rb
│               │   │   │           │   └── version.rb
│               │   │   │           └── badge.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-plugin-changelog-0.16.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfastlane[0m
│               │   │   │       └── [01;34mplugin[0m
│               │   │   │           ├── [01;34mchangelog[0m
│               │   │   │           │   ├── [01;34mactions[0m
│               │   │   │           │   │   ├── emojify_changelog.rb
│               │   │   │           │   │   ├── read_changelog.rb
│               │   │   │           │   │   ├── stamp_changelog.rb
│               │   │   │           │   │   └── update_changelog.rb
│               │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │           │   │   └── changelog_helper.rb
│               │   │   │           │   └── version.rb
│               │   │   │           └── changelog.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-plugin-semantic_release-1.18.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfastlane[0m
│               │   │   │       └── [01;34mplugin[0m
│               │   │   │           ├── [01;34msemantic_release[0m
│               │   │   │           │   ├── [01;34mactions[0m
│               │   │   │           │   │   ├── analyze_commits.rb
│               │   │   │           │   │   └── conventional_changelog.rb
│               │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │           │   │   └── semantic_release_helper.rb
│               │   │   │           │   └── version.rb
│               │   │   │           └── semantic_release.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-plugin-test_center-3.19.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfastlane[0m
│               │   │   │       └── [01;34mplugin[0m
│               │   │   │           ├── [01;34mtest_center[0m
│               │   │   │           │   ├── [01;34mactions[0m
│               │   │   │           │   │   ├── collate_html_reports.rb
│               │   │   │           │   │   ├── collate_json_reports.rb
│               │   │   │           │   │   ├── collate_junit_reports.rb
│               │   │   │           │   │   ├── collate_test_result_bundles.rb
│               │   │   │           │   │   ├── collate_xcresults.rb
│               │   │   │           │   │   ├── multi_scan.rb
│               │   │   │           │   │   ├── quit_core_simulator_service.rb
│               │   │   │           │   │   ├── suppress_tests_from_junit.rb
│               │   │   │           │   │   ├── suppress_tests.rb
│               │   │   │           │   │   ├── suppressed_tests.rb
│               │   │   │           │   │   ├── test_options_from_testplan.rb
│               │   │   │           │   │   ├── testplans_from_scheme.rb
│               │   │   │           │   │   ├── tests_from_junit.rb
│               │   │   │           │   │   ├── tests_from_xcresult.rb
│               │   │   │           │   │   └── tests_from_xctestrun.rb
│               │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │           │   │   ├── [01;34mfastlane_core[0m
│               │   │   │           │   │   │   └── [01;34mdevice_manager[0m
│               │   │   │           │   │   │       └── simulator_extensions.rb
│               │   │   │           │   │   ├── [01;34mmulti_scan_manager[0m
│               │   │   │           │   │   │   ├── device_manager.rb
│               │   │   │           │   │   │   ├── parallel_test_batch_worker.rb
│               │   │   │           │   │   │   ├── report_collator.rb
│               │   │   │           │   │   │   ├── retrying_scan_helper.rb
│               │   │   │           │   │   │   ├── retrying_scan.rb
│               │   │   │           │   │   │   ├── runner.rb
│               │   │   │           │   │   │   ├── simulator_helper.rb
│               │   │   │           │   │   │   ├── test_batch_worker_pool.rb
│               │   │   │           │   │   │   └── test_batch_worker.rb
│               │   │   │           │   │   ├── [01;34mxcodeproj[0m
│               │   │   │           │   │   │   └── [01;34mscheme[0m
│               │   │   │           │   │   │       └── test_action.rb
│               │   │   │           │   │   ├── html_test_report.rb
│               │   │   │           │   │   ├── junit_helper.rb
│               │   │   │           │   │   ├── multi_scan_manager.rb
│               │   │   │           │   │   ├── reportname_helper.rb
│               │   │   │           │   │   ├── scan_helper.rb
│               │   │   │           │   │   ├── test_collector.rb
│               │   │   │           │   │   ├── xcodebuild_string.rb
│               │   │   │           │   │   └── xctestrun_info.rb
│               │   │   │           │   └── version.rb
│               │   │   │           └── test_center.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-plugin-versioning-0.7.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mfastlane[0m
│               │   │   │       └── [01;34mplugin[0m
│               │   │   │           ├── [01;34mversioning[0m
│               │   │   │           │   ├── [01;34mactions[0m
│               │   │   │           │   │   ├── ci_build_number.rb
│               │   │   │           │   │   ├── get_app_store_version_number.rb
│               │   │   │           │   │   ├── get_build_number_from_plist.rb
│               │   │   │           │   │   ├── get_build_number_from_xcodeproj.rb
│               │   │   │           │   │   ├── get_info_plist_path.rb
│               │   │   │           │   │   ├── get_version_number_from_git_branch.rb
│               │   │   │           │   │   ├── get_version_number_from_plist.rb
│               │   │   │           │   │   ├── get_version_number_from_xcodeproj.rb
│               │   │   │           │   │   ├── increment_build_number_in_plist.rb
│               │   │   │           │   │   ├── increment_build_number_in_xcodeproj.rb
│               │   │   │           │   │   ├── increment_version_number_in_plist.rb
│               │   │   │           │   │   └── increment_version_number_in_xcodeproj.rb
│               │   │   │           │   └── version.rb
│               │   │   │           └── versioning.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mfastlane-sirp-1.0.0[0m
│               │   │   ├── [01;34mcerts[0m
│               │   │   │   └── gem-public_cert_grempe.pem
│               │   │   ├── [01;34mdocs[0m
│               │   │   │   ├── rfc2945.txt
│               │   │   │   └── rfc5054.txt
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mfastlane-sirp[0m
│               │   │   │   │   ├── client.rb
│               │   │   │   │   ├── parameters.rb
│               │   │   │   │   ├── sirp.rb
│               │   │   │   │   ├── verifier.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── fastlane-sirp.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── fastlane-sirp.gemspec
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── RELEASE.md
│               │   ├── [01;34mgh_inspector-1.1.3[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgh_inspector[0m
│               │   │   │   │   ├── evidence.rb
│               │   │   │   │   ├── exception_hound.rb
│               │   │   │   │   ├── inspector.rb
│               │   │   │   │   ├── sidekick.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── gh_inspector.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── Gemfile
│               │   │   ├── gh_inspector.gemspec
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mgoogle-apis-androidpublisher_v3-0.54.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mapis[0m
│               │   │   │   │       ├── [01;34mandroidpublisher_v3[0m
│               │   │   │   │       │   ├── classes.rb
│               │   │   │   │       │   ├── gem_version.rb
│               │   │   │   │       │   ├── representations.rb
│               │   │   │   │       │   └── service.rb
│               │   │   │   │       └── androidpublisher_v3.rb
│               │   │   │   └── google-apis-androidpublisher_v3.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── OVERVIEW.md
│               │   ├── [01;34mgoogle-apis-core-0.11.3[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mgoogle[0m
│               │   │   │       ├── [01;34mapi_client[0m
│               │   │   │       │   ├── [01;34mauth[0m
│               │   │   │       │   │   ├── [01;34mstorages[0m
│               │   │   │       │   │   │   ├── file_store.rb
│               │   │   │       │   │   │   └── redis_store.rb
│               │   │   │       │   │   ├── installed_app.rb
│               │   │   │       │   │   ├── key_utils.rb
│               │   │   │       │   │   └── storage.rb
│               │   │   │       │   └── client_secrets.rb
│               │   │   │       ├── [01;34mapis[0m
│               │   │   │       │   ├── [01;34mcore[0m
│               │   │   │       │   │   ├── api_command.rb
│               │   │   │       │   │   ├── base_service.rb
│               │   │   │       │   │   ├── batch.rb
│               │   │   │       │   │   ├── composite_io.rb
│               │   │   │       │   │   ├── download.rb
│               │   │   │       │   │   ├── hashable.rb
│               │   │   │       │   │   ├── http_command.rb
│               │   │   │       │   │   ├── json_representation.rb
│               │   │   │       │   │   ├── logging.rb
│               │   │   │       │   │   ├── multipart.rb
│               │   │   │       │   │   ├── storage_download.rb
│               │   │   │       │   │   ├── storage_upload.rb
│               │   │   │       │   │   ├── upload.rb
│               │   │   │       │   │   └── version.rb
│               │   │   │       │   ├── core.rb
│               │   │   │       │   ├── errors.rb
│               │   │   │       │   └── options.rb
│               │   │   │       └── apis.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── OVERVIEW.md
│               │   ├── [01;34mgoogle-apis-iamcredentials_v1-0.17.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mapis[0m
│               │   │   │   │       ├── [01;34miamcredentials_v1[0m
│               │   │   │   │       │   ├── classes.rb
│               │   │   │   │       │   ├── gem_version.rb
│               │   │   │   │       │   ├── representations.rb
│               │   │   │   │       │   └── service.rb
│               │   │   │   │       └── iamcredentials_v1.rb
│               │   │   │   └── google-apis-iamcredentials_v1.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── OVERVIEW.md
│               │   ├── [01;34mgoogle-apis-playcustomapp_v1-0.13.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mapis[0m
│               │   │   │   │       ├── [01;34mplaycustomapp_v1[0m
│               │   │   │   │       │   ├── classes.rb
│               │   │   │   │       │   ├── gem_version.rb
│               │   │   │   │       │   ├── representations.rb
│               │   │   │   │       │   └── service.rb
│               │   │   │   │       └── playcustomapp_v1.rb
│               │   │   │   └── google-apis-playcustomapp_v1.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── OVERVIEW.md
│               │   ├── [01;34mgoogle-apis-storage_v1-0.31.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mapis[0m
│               │   │   │   │       ├── [01;34mstorage_v1[0m
│               │   │   │   │       │   ├── classes.rb
│               │   │   │   │       │   ├── gem_version.rb
│               │   │   │   │       │   ├── representations.rb
│               │   │   │   │       │   └── service.rb
│               │   │   │   │       └── storage_v1.rb
│               │   │   │   └── google-apis-storage_v1.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.md
│               │   │   └── OVERVIEW.md
│               │   ├── [01;34mgoogle-cloud-core-1.8.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   ├── [01;34mcloud[0m
│               │   │   │   │   │   ├── [01;34mcore[0m
│               │   │   │   │   │   │   └── version.rb
│               │   │   │   │   │   ├── config.rb
│               │   │   │   │   │   └── credentials.rb
│               │   │   │   │   └── cloud.rb
│               │   │   │   └── google-cloud-core.rb
│               │   │   ├── AUTHENTICATION.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mgoogle-cloud-env-1.6.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mcloud[0m
│               │   │   │   │       └── env.rb
│               │   │   │   └── google-cloud-env.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── LICENSE
│               │   │   ├── README.md
│               │   │   └── SECURITY.md
│               │   ├── [01;34mgoogle-cloud-errors-1.5.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mcloud[0m
│               │   │   │   │       ├── [01;34merrors[0m
│               │   │   │   │       │   └── version.rb
│               │   │   │   │       └── errors.rb
│               │   │   │   └── google-cloud-errors.rb
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mgoogle-cloud-storage-1.47.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogle[0m
│               │   │   │   │   └── [01;34mcloud[0m
│               │   │   │   │       ├── [01;34mstorage[0m
│               │   │   │   │       │   ├── [01;34mbucket[0m
│               │   │   │   │       │   │   ├── acl.rb
│               │   │   │   │       │   │   ├── cors.rb
│               │   │   │   │       │   │   ├── lifecycle.rb
│               │   │   │   │       │   │   └── list.rb
│               │   │   │   │       │   ├── [01;34mfile[0m
│               │   │   │   │       │   │   ├── acl.rb
│               │   │   │   │       │   │   ├── list.rb
│               │   │   │   │       │   │   ├── signer_v2.rb
│               │   │   │   │       │   │   ├── signer_v4.rb
│               │   │   │   │       │   │   └── verifier.rb
│               │   │   │   │       │   ├── [01;34mhmac_key[0m
│               │   │   │   │       │   │   └── list.rb
│               │   │   │   │       │   ├── [01;34mpolicy[0m
│               │   │   │   │       │   │   ├── binding.rb
│               │   │   │   │       │   │   ├── bindings.rb
│               │   │   │   │       │   │   └── condition.rb
│               │   │   │   │       │   ├── bucket.rb
│               │   │   │   │       │   ├── convert.rb
│               │   │   │   │       │   ├── credentials.rb
│               │   │   │   │       │   ├── errors.rb
│               │   │   │   │       │   ├── file.rb
│               │   │   │   │       │   ├── hmac_key.rb
│               │   │   │   │       │   ├── notification.rb
│               │   │   │   │       │   ├── policy.rb
│               │   │   │   │       │   ├── post_object.rb
│               │   │   │   │       │   ├── project.rb
│               │   │   │   │       │   ├── service.rb
│               │   │   │   │       │   └── version.rb
│               │   │   │   │       └── storage.rb
│               │   │   │   └── google-cloud-storage.rb
│               │   │   ├── AUTHENTICATION.md
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── LICENSE
│               │   │   ├── LOGGING.md
│               │   │   ├── OVERVIEW.md
│               │   │   └── TROUBLESHOOTING.md
│               │   ├── [01;34mgoogleauth-1.8.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mgoogleauth[0m
│               │   │   │   │   ├── [01;34mexternal_account[0m
│               │   │   │   │   │   ├── aws_credentials.rb
│               │   │   │   │   │   ├── base_credentials.rb
│               │   │   │   │   │   ├── external_account_utils.rb
│               │   │   │   │   │   ├── identity_pool_credentials.rb
│               │   │   │   │   │   └── pluggable_credentials.rb
│               │   │   │   │   ├── [01;34mhelpers[0m
│               │   │   │   │   │   └── connection.rb
│               │   │   │   │   ├── [01;34mid_tokens[0m
│               │   │   │   │   │   ├── errors.rb
│               │   │   │   │   │   ├── key_sources.rb
│               │   │   │   │   │   └── verifier.rb
│               │   │   │   │   ├── [01;34moauth2[0m
│               │   │   │   │   │   └── sts_client.rb
│               │   │   │   │   ├── [01;34mstores[0m
│               │   │   │   │   │   ├── file_token_store.rb
│               │   │   │   │   │   └── redis_token_store.rb
│               │   │   │   │   ├── application_default.rb
│               │   │   │   │   ├── base_client.rb
│               │   │   │   │   ├── client_id.rb
│               │   │   │   │   ├── compute_engine.rb
│               │   │   │   │   ├── credentials_loader.rb
│               │   │   │   │   ├── credentials.rb
│               │   │   │   │   ├── default_credentials.rb
│               │   │   │   │   ├── external_account.rb
│               │   │   │   │   ├── iam.rb
│               │   │   │   │   ├── id_tokens.rb
│               │   │   │   │   ├── json_key_reader.rb
│               │   │   │   │   ├── scope_util.rb
│               │   │   │   │   ├── service_account.rb
│               │   │   │   │   ├── signet.rb
│               │   │   │   │   ├── token_store.rb
│               │   │   │   │   ├── user_authorizer.rb
│               │   │   │   │   ├── user_refresh.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── web_user_authorizer.rb
│               │   │   │   └── googleauth.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── LICENSE
│               │   │   ├── README.md
│               │   │   └── SECURITY.md
│               │   ├── [01;34mhighline-2.0.3[0m
│               │   │   ├── [01;34mdoc[0m
│               │   │   ├── [01;34mexamples[0m
│               │   │   │   ├── ansi_colors.rb
│               │   │   │   ├── asking_for_arrays.rb
│               │   │   │   ├── basic_usage.rb
│               │   │   │   ├── color_scheme.rb
│               │   │   │   ├── get_character.rb
│               │   │   │   ├── limit.rb
│               │   │   │   ├── menus.rb
│               │   │   │   ├── overwrite.rb
│               │   │   │   ├── page_and_wrap.rb
│               │   │   │   ├── password.rb
│               │   │   │   ├── repeat_entry.rb
│               │   │   │   ├── trapping_eof.rb
│               │   │   │   └── using_readline.rb
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mhighline[0m
│               │   │   │   │   ├── [01;34mmenu[0m
│               │   │   │   │   │   └── item.rb
│               │   │   │   │   ├── [01;34mquestion[0m
│               │   │   │   │   │   └── answer_converter.rb
│               │   │   │   │   ├── [01;34mterminal[0m
│               │   │   │   │   │   ├── io_console.rb
│               │   │   │   │   │   ├── ncurses.rb
│               │   │   │   │   │   └── unix_stty.rb
│               │   │   │   │   ├── builtin_styles.rb
│               │   │   │   │   ├── color_scheme.rb
│               │   │   │   │   ├── compatibility.rb
│               │   │   │   │   ├── custom_errors.rb
│               │   │   │   │   ├── import.rb
│               │   │   │   │   ├── io_console_compatible.rb
│               │   │   │   │   ├── list_renderer.rb
│               │   │   │   │   ├── list.rb
│               │   │   │   │   ├── [01;32mmenu.rb[0m
│               │   │   │   │   ├── paginator.rb
│               │   │   │   │   ├── question_asker.rb
│               │   │   │   │   ├── [01;32mquestion.rb[0m
│               │   │   │   │   ├── simulate.rb
│               │   │   │   │   ├── statement.rb
│               │   │   │   │   ├── string_extensions.rb
│               │   │   │   │   ├── string.rb
│               │   │   │   │   ├── [01;32mstyle.rb[0m
│               │   │   │   │   ├── template_renderer.rb
│               │   │   │   │   ├── [01;32mterminal.rb[0m
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── wrapper.rb
│               │   │   │   └── [01;32mhighline.rb[0m
│               │   │   ├── appveyor.yml
│               │   │   ├── AUTHORS
│               │   │   ├── Changelog.md
│               │   │   ├── COPYING
│               │   │   ├── Gemfile
│               │   │   ├── highline.gemspec
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── TODO
│               │   ├── [01;34mhttp-cookie-1.0.8[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mhttp[0m
│               │   │   │   │   ├── [01;34mcookie[0m
│               │   │   │   │   │   ├── ruby_compat.rb
│               │   │   │   │   │   ├── scanner.rb
│               │   │   │   │   │   ├── uri_parser.rb
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   ├── [01;34mcookie_jar[0m
│               │   │   │   │   │   ├── abstract_saver.rb
│               │   │   │   │   │   ├── abstract_store.rb
│               │   │   │   │   │   ├── cookiestxt_saver.rb
│               │   │   │   │   │   ├── hash_store.rb
│               │   │   │   │   │   ├── mozilla_store.rb
│               │   │   │   │   │   └── yaml_saver.rb
│               │   │   │   │   ├── cookie_jar.rb
│               │   │   │   │   └── cookie.rb
│               │   │   │   └── http-cookie.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── helper.rb
│               │   │   │   ├── mechanize.yml
│               │   │   │   ├── simplecov_start.rb
│               │   │   │   ├── test_http_cookie_jar.rb
│               │   │   │   └── test_http_cookie.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── Gemfile
│               │   │   ├── http-cookie.gemspec
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mhttpclient-2.9.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mhttp-access2[0m
│               │   │   │   │   ├── cookie.rb
│               │   │   │   │   └── http.rb
│               │   │   │   ├── [01;34mhttpclient[0m
│               │   │   │   │   ├── auth.rb
│               │   │   │   │   ├── cacert.pem
│               │   │   │   │   ├── cacert1024.pem
│               │   │   │   │   ├── connection.rb
│               │   │   │   │   ├── cookie.rb
│               │   │   │   │   ├── http.rb
│               │   │   │   │   ├── include_client.rb
│               │   │   │   │   ├── jruby_ssl_socket.rb
│               │   │   │   │   ├── session.rb
│               │   │   │   │   ├── ssl_config.rb
│               │   │   │   │   ├── ssl_socket.rb
│               │   │   │   │   ├── timeout.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── webagent-cookie.rb
│               │   │   │   ├── hexdump.rb
│               │   │   │   ├── http-access2.rb
│               │   │   │   ├── httpclient.rb
│               │   │   │   ├── jsonclient.rb
│               │   │   │   └── oauthclient.rb
│               │   │   ├── [01;34msample[0m
│               │   │   │   ├── [01;34mssl[0m
│               │   │   │   │   ├── [01;34mhtdocs[0m
│               │   │   │   │   │   └── index.html
│               │   │   │   │   ├── 0cert.pem
│               │   │   │   │   ├── 0key.pem
│               │   │   │   │   ├── 1000cert.pem
│               │   │   │   │   ├── 1000key.pem
│               │   │   │   │   ├── ssl_client.rb
│               │   │   │   │   └── webrick_httpsd.rb
│               │   │   │   ├── async.rb
│               │   │   │   ├── auth.rb
│               │   │   │   ├── cookie.rb
│               │   │   │   ├── dav.rb
│               │   │   │   ├── generate_test_keys.rb
│               │   │   │   ├── howto.rb
│               │   │   │   ├── jsonclient.rb
│               │   │   │   ├── oauth_buzz.rb
│               │   │   │   ├── oauth_friendfeed.rb
│               │   │   │   ├── oauth_twitter.rb
│               │   │   │   ├── stream.rb
│               │   │   │   ├── thread.rb
│               │   │   │   └── wcat.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── [01;34mfixtures[0m
│               │   │   │   │   ├── verify.alt.cert
│               │   │   │   │   ├── verify.foo.cert
│               │   │   │   │   ├── verify.key
│               │   │   │   │   └── verify.localhost.cert
│               │   │   │   ├── [01;34mjruby_ssl_socket[0m
│               │   │   │   │   └── test_pemutils.rb
│               │   │   │   ├── ca-chain.pem
│               │   │   │   ├── ca.cert
│               │   │   │   ├── ca.key
│               │   │   │   ├── ca.srl
│               │   │   │   ├── client-pass.key
│               │   │   │   ├── client.cert
│               │   │   │   ├── client.key
│               │   │   │   ├── helper.rb
│               │   │   │   ├── htdigest
│               │   │   │   ├── htpasswd
│               │   │   │   ├── runner.rb
│               │   │   │   ├── server.cert
│               │   │   │   ├── server.key
│               │   │   │   ├── sslsvr.rb
│               │   │   │   ├── subca.cert
│               │   │   │   ├── subca.key
│               │   │   │   ├── subca.srl
│               │   │   │   ├── test_auth.rb
│               │   │   │   ├── test_cookie.rb
│               │   │   │   ├── test_hexdump.rb
│               │   │   │   ├── test_http-access2.rb
│               │   │   │   ├── test_httpclient.rb
│               │   │   │   ├── test_include_client.rb
│               │   │   │   ├── test_jsonclient.rb
│               │   │   │   ├── test_ssl.rb
│               │   │   │   └── test_webagent-cookie.rb
│               │   │   └── README.md
│               │   ├── [01;34mjmespath-1.6.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mjmespath[0m
│               │   │   │   │   ├── [01;34mnodes[0m
│               │   │   │   │   │   ├── and.rb
│               │   │   │   │   │   ├── comparator.rb
│               │   │   │   │   │   ├── condition.rb
│               │   │   │   │   │   ├── current.rb
│               │   │   │   │   │   ├── expression.rb
│               │   │   │   │   │   ├── field.rb
│               │   │   │   │   │   ├── flatten.rb
│               │   │   │   │   │   ├── function.rb
│               │   │   │   │   │   ├── index.rb
│               │   │   │   │   │   ├── literal.rb
│               │   │   │   │   │   ├── multi_select_hash.rb
│               │   │   │   │   │   ├── multi_select_list.rb
│               │   │   │   │   │   ├── not.rb
│               │   │   │   │   │   ├── or.rb
│               │   │   │   │   │   ├── pipe.rb
│               │   │   │   │   │   ├── projection.rb
│               │   │   │   │   │   ├── slice.rb
│               │   │   │   │   │   └── subexpression.rb
│               │   │   │   │   ├── caching_parser.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── lexer.rb
│               │   │   │   │   ├── nodes.rb
│               │   │   │   │   ├── parser.rb
│               │   │   │   │   ├── runtime.rb
│               │   │   │   │   ├── token_stream.rb
│               │   │   │   │   ├── token.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── jmespath.rb
│               │   │   ├── LICENSE.txt
│               │   │   └── VERSION
│               │   ├── [01;34mjson-2.13.2[0m
│               │   │   ├── [01;34mext[0m
│               │   │   │   └── [01;34mjson[0m
│               │   │   │       └── [01;34mext[0m
│               │   │   │           ├── [01;34mfbuffer[0m
│               │   │   │           │   └── fbuffer.h
│               │   │   │           ├── [01;34mgenerator[0m
│               │   │   │           │   ├── extconf.rb
│               │   │   │           │   ├── generator.c
│               │   │   │           │   └── Makefile
│               │   │   │           ├── [01;34mparser[0m
│               │   │   │           │   ├── extconf.rb
│               │   │   │           │   ├── Makefile
│               │   │   │           │   └── parser.c
│               │   │   │           ├── [01;34msimd[0m
│               │   │   │           │   ├── conf.rb
│               │   │   │           │   └── simd.h
│               │   │   │           └── [01;34mvendor[0m
│               │   │   │               ├── fpconv.c
│               │   │   │               └── jeaiii-ltoa.h
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mjson[0m
│               │   │   │   │   ├── [01;34madd[0m
│               │   │   │   │   │   ├── bigdecimal.rb
│               │   │   │   │   │   ├── complex.rb
│               │   │   │   │   │   ├── core.rb
│               │   │   │   │   │   ├── date_time.rb
│               │   │   │   │   │   ├── date.rb
│               │   │   │   │   │   ├── exception.rb
│               │   │   │   │   │   ├── ostruct.rb
│               │   │   │   │   │   ├── range.rb
│               │   │   │   │   │   ├── rational.rb
│               │   │   │   │   │   ├── regexp.rb
│               │   │   │   │   │   ├── set.rb
│               │   │   │   │   │   ├── struct.rb
│               │   │   │   │   │   ├── symbol.rb
│               │   │   │   │   │   └── time.rb
│               │   │   │   │   ├── [01;34mext[0m
│               │   │   │   │   │   ├── [01;34mgenerator[0m
│               │   │   │   │   │   │   └── state.rb
│               │   │   │   │   │   ├── [01;32mgenerator.bundle[0m
│               │   │   │   │   │   └── [01;32mparser.bundle[0m
│               │   │   │   │   ├── [01;34mtruffle_ruby[0m
│               │   │   │   │   │   └── generator.rb
│               │   │   │   │   ├── common.rb
│               │   │   │   │   ├── ext.rb
│               │   │   │   │   ├── generic_object.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── json.rb
│               │   │   ├── BSDL
│               │   │   ├── CHANGES.md
│               │   │   ├── COPYING
│               │   │   ├── json.gemspec
│               │   │   ├── LEGAL
│               │   │   └── README.md
│               │   ├── [01;34mjwt-2.10.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mjwt[0m
│               │   │   │   │   ├── [01;34mclaims[0m
│               │   │   │   │   │   ├── audience.rb
│               │   │   │   │   │   ├── crit.rb
│               │   │   │   │   │   ├── decode_verifier.rb
│               │   │   │   │   │   ├── expiration.rb
│               │   │   │   │   │   ├── issued_at.rb
│               │   │   │   │   │   ├── issuer.rb
│               │   │   │   │   │   ├── jwt_id.rb
│               │   │   │   │   │   ├── not_before.rb
│               │   │   │   │   │   ├── numeric.rb
│               │   │   │   │   │   ├── required.rb
│               │   │   │   │   │   ├── subject.rb
│               │   │   │   │   │   ├── verification_methods.rb
│               │   │   │   │   │   └── verifier.rb
│               │   │   │   │   ├── [01;34mconfiguration[0m
│               │   │   │   │   │   ├── container.rb
│               │   │   │   │   │   ├── decode_configuration.rb
│               │   │   │   │   │   └── jwk_configuration.rb
│               │   │   │   │   ├── [01;34mjwa[0m
│               │   │   │   │   │   ├── compat.rb
│               │   │   │   │   │   ├── ecdsa.rb
│               │   │   │   │   │   ├── eddsa.rb
│               │   │   │   │   │   ├── hmac_rbnacl_fixed.rb
│               │   │   │   │   │   ├── hmac_rbnacl.rb
│               │   │   │   │   │   ├── hmac.rb
│               │   │   │   │   │   ├── none.rb
│               │   │   │   │   │   ├── ps.rb
│               │   │   │   │   │   ├── rsa.rb
│               │   │   │   │   │   ├── signing_algorithm.rb
│               │   │   │   │   │   ├── unsupported.rb
│               │   │   │   │   │   └── wrapper.rb
│               │   │   │   │   ├── [01;34mjwk[0m
│               │   │   │   │   │   ├── ec.rb
│               │   │   │   │   │   ├── hmac.rb
│               │   │   │   │   │   ├── key_base.rb
│               │   │   │   │   │   ├── key_finder.rb
│               │   │   │   │   │   ├── kid_as_key_digest.rb
│               │   │   │   │   │   ├── okp_rbnacl.rb
│               │   │   │   │   │   ├── rsa.rb
│               │   │   │   │   │   ├── set.rb
│               │   │   │   │   │   └── thumbprint.rb
│               │   │   │   │   ├── base64.rb
│               │   │   │   │   ├── claims_validator.rb
│               │   │   │   │   ├── claims.rb
│               │   │   │   │   ├── configuration.rb
│               │   │   │   │   ├── decode.rb
│               │   │   │   │   ├── deprecations.rb
│               │   │   │   │   ├── encode.rb
│               │   │   │   │   ├── encoded_token.rb
│               │   │   │   │   ├── error.rb
│               │   │   │   │   ├── json.rb
│               │   │   │   │   ├── jwa.rb
│               │   │   │   │   ├── jwk.rb
│               │   │   │   │   ├── token.rb
│               │   │   │   │   ├── verify.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── x5c_key_finder.rb
│               │   │   │   └── jwt.rb
│               │   │   ├── AUTHORS
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── LICENSE
│               │   │   ├── README.md
│               │   │   └── ruby-jwt.gemspec
│               │   ├── [01;34mlogger-1.7.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mlogger[0m
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── formatter.rb
│               │   │   │   │   ├── log_device.rb
│               │   │   │   │   ├── period.rb
│               │   │   │   │   ├── severity.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── logger.rb
│               │   │   ├── BSDL
│               │   │   ├── COPYING
│               │   │   └── README.md
│               │   ├── [01;34mmini_magick-4.13.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mmini_magick[0m
│               │   │   │   │   ├── [01;34mimage[0m
│               │   │   │   │   │   └── info.rb
│               │   │   │   │   ├── [01;34mtool[0m
│               │   │   │   │   │   ├── animate.rb
│               │   │   │   │   │   ├── compare.rb
│               │   │   │   │   │   ├── composite.rb
│               │   │   │   │   │   ├── conjure.rb
│               │   │   │   │   │   ├── convert.rb
│               │   │   │   │   │   ├── display.rb
│               │   │   │   │   │   ├── identify.rb
│               │   │   │   │   │   ├── import.rb
│               │   │   │   │   │   ├── magick.rb
│               │   │   │   │   │   ├── mogrify_restricted.rb
│               │   │   │   │   │   ├── mogrify.rb
│               │   │   │   │   │   ├── montage.rb
│               │   │   │   │   │   └── stream.rb
│               │   │   │   │   ├── configuration.rb
│               │   │   │   │   ├── image.rb
│               │   │   │   │   ├── shell.rb
│               │   │   │   │   ├── tool.rb
│               │   │   │   │   ├── utilities.rb
│               │   │   │   │   └── version.rb
│               │   │   │   ├── mini_gmagick.rb
│               │   │   │   └── mini_magick.rb
│               │   │   ├── MIT-LICENSE
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mmini_mime-1.1.5[0m
│               │   │   ├── [01;34mbench[0m
│               │   │   │   └── bench.rb
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mdb[0m
│               │   │   │   │   ├── content_type_mime.db
│               │   │   │   │   └── ext_mime.db
│               │   │   │   ├── [01;34mmini_mime[0m
│               │   │   │   │   └── version.rb
│               │   │   │   └── mini_mime.rb
│               │   │   ├── CHANGELOG
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── mini_mime.gemspec
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mmulti_json-1.17.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mmulti_json[0m
│               │   │   │   │   ├── [01;34madapters[0m
│               │   │   │   │   │   ├── gson.rb
│               │   │   │   │   │   ├── jr_jackson.rb
│               │   │   │   │   │   ├── json_gem.rb
│               │   │   │   │   │   ├── json_pure.rb
│               │   │   │   │   │   ├── oj.rb
│               │   │   │   │   │   ├── ok_json.rb
│               │   │   │   │   │   └── yajl.rb
│               │   │   │   │   ├── [01;34mvendor[0m
│               │   │   │   │   │   └── okjson.rb
│               │   │   │   │   ├── adapter_error.rb
│               │   │   │   │   ├── adapter.rb
│               │   │   │   │   ├── convertible_hash_keys.rb
│               │   │   │   │   ├── options_cache.rb
│               │   │   │   │   ├── options.rb
│               │   │   │   │   ├── parse_error.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── multi_json.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── LICENSE.md
│               │   │   └── README.md
│               │   ├── [01;34mmultipart-post-2.4.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mmultipart[0m
│               │   │   │   │   ├── [01;34mpost[0m
│               │   │   │   │   │   ├── composite_read_io.rb
│               │   │   │   │   │   ├── multipartable.rb
│               │   │   │   │   │   ├── parts.rb
│               │   │   │   │   │   ├── upload_io.rb
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── post.rb
│               │   │   │   ├── [01;34mnet[0m
│               │   │   │   │   └── [01;34mhttp[0m
│               │   │   │   │       └── [01;34mpost[0m
│               │   │   │   │           └── multipart.rb
│               │   │   │   ├── composite_io.rb
│               │   │   │   ├── multipart_post.rb
│               │   │   │   ├── multipartable.rb
│               │   │   │   └── parts.rb
│               │   │   ├── changelog.md
│               │   │   ├── license.md
│               │   │   └── readme.md
│               │   ├── [01;34mmutex_m-0.3.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── mutex_m.rb
│               │   │   ├── [01;34msig[0m
│               │   │   │   └── mutex_m.rbs
│               │   │   ├── BSDL
│               │   │   ├── COPYING
│               │   │   └── README.md
│               │   ├── [01;34mnanaimo-0.4.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mnanaimo[0m
│               │   │   │   │   ├── [01;34municode[0m
│               │   │   │   │   │   ├── next_step_mapping.rb
│               │   │   │   │   │   └── quote_maps.rb
│               │   │   │   │   ├── [01;34mwriter[0m
│               │   │   │   │   │   ├── pbxproj.rb
│               │   │   │   │   │   └── xml.rb
│               │   │   │   │   ├── object.rb
│               │   │   │   │   ├── plist.rb
│               │   │   │   │   ├── reader.rb
│               │   │   │   │   ├── unicode.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── writer.rb
│               │   │   │   └── nanaimo.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE.txt
│               │   │   ├── nanaimo.gemspec
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mnaturally-2.3.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mnaturally[0m
│               │   │   │   │   ├── segment.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── naturally.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   └── naturally_spec.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── naturally.gemspec
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34mnkf-0.2.0[0m
│               │   │   ├── [01;34mext[0m
│               │   │   │   ├── [01;34mjava[0m
│               │   │   │   │   └── [01;34morg[0m
│               │   │   │   │       └── [01;34mjruby[0m
│               │   │   │   │           └── [01;34mext[0m
│               │   │   │   │               └── [01;34mnkf[0m
│               │   │   │   │                   ├── Command.java
│               │   │   │   │                   ├── CommandParser.java
│               │   │   │   │                   ├── NKFLibrary.java
│               │   │   │   │                   ├── Option.java
│               │   │   │   │                   ├── Options.java
│               │   │   │   │                   └── RubyNKF.java
│               │   │   │   └── [01;34mnkf[0m
│               │   │   │       ├── [01;34mnkf-utf8[0m
│               │   │   │       │   ├── config.h
│               │   │   │       │   ├── nkf.c
│               │   │   │       │   ├── nkf.h
│               │   │   │       │   ├── utf8tbl.c
│               │   │   │       │   └── utf8tbl.h
│               │   │   │       ├── extconf.rb
│               │   │   │       ├── Makefile
│               │   │   │       └── nkf.c
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── kconv.rb
│               │   │   │   ├── [01;32mnkf.bundle[0m
│               │   │   │   └── nkf.rb
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── nkf.gemspec
│               │   │   ├── Rakefile
│               │   │   └── README.md
│               │   ├── [01;34moptparse-0.6.0[0m
│               │   │   ├── [01;34mdoc[0m
│               │   │   │   └── [01;34moptparse[0m
│               │   │   │       ├── [01;34mruby[0m
│               │   │   │       │   ├── argument_abbreviation.rb
│               │   │   │       │   ├── argument_keywords.rb
│               │   │   │       │   ├── argument_strings.rb
│               │   │   │       │   ├── argv.rb
│               │   │   │       │   ├── array.rb
│               │   │   │       │   ├── basic.rb
│               │   │   │       │   ├── block.rb
│               │   │   │       │   ├── collected_options.rb
│               │   │   │       │   ├── custom_converter.rb
│               │   │   │       │   ├── date.rb
│               │   │   │       │   ├── datetime.rb
│               │   │   │       │   ├── decimal_integer.rb
│               │   │   │       │   ├── decimal_numeric.rb
│               │   │   │       │   ├── default_values.rb
│               │   │   │       │   ├── descriptions.rb
│               │   │   │       │   ├── explicit_array_values.rb
│               │   │   │       │   ├── explicit_hash_values.rb
│               │   │   │       │   ├── false_class.rb
│               │   │   │       │   ├── float.rb
│               │   │   │       │   ├── help_banner.rb
│               │   │   │       │   ├── help_format.rb
│               │   │   │       │   ├── help_program_name.rb
│               │   │   │       │   ├── help.rb
│               │   │   │       │   ├── integer.rb
│               │   │   │       │   ├── long_names.rb
│               │   │   │       │   ├── long_optional.rb
│               │   │   │       │   ├── long_required.rb
│               │   │   │       │   ├── long_simple.rb
│               │   │   │       │   ├── long_with_negation.rb
│               │   │   │       │   ├── match_converter.rb
│               │   │   │       │   ├── matched_values.rb
│               │   │   │       │   ├── method.rb
│               │   │   │       │   ├── missing_options.rb
│               │   │   │       │   ├── mixed_names.rb
│               │   │   │       │   ├── name_abbrev.rb
│               │   │   │       │   ├── no_abbreviation.rb
│               │   │   │       │   ├── numeric.rb
│               │   │   │       │   ├── object.rb
│               │   │   │       │   ├── octal_integer.rb
│               │   │   │       │   ├── optional_argument.rb
│               │   │   │       │   ├── parse_bang.rb
│               │   │   │       │   ├── parse.rb
│               │   │   │       │   ├── proc.rb
│               │   │   │       │   ├── regexp.rb
│               │   │   │       │   ├── required_argument.rb
│               │   │   │       │   ├── shellwords.rb
│               │   │   │       │   ├── short_names.rb
│               │   │   │       │   ├── short_optional.rb
│               │   │   │       │   ├── short_range.rb
│               │   │   │       │   ├── short_required.rb
│               │   │   │       │   ├── short_simple.rb
│               │   │   │       │   ├── string.rb
│               │   │   │       │   ├── terminator.rb
│               │   │   │       │   ├── time.rb
│               │   │   │       │   ├── true_class.rb
│               │   │   │       │   └── uri.rb
│               │   │   │       ├── argument_converters.rdoc
│               │   │   │       ├── creates_option.rdoc
│               │   │   │       ├── option_params.rdoc
│               │   │   │       └── tutorial.rdoc
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34moptparse[0m
│               │   │   │   │   ├── ac.rb
│               │   │   │   │   ├── date.rb
│               │   │   │   │   ├── kwargs.rb
│               │   │   │   │   ├── shellwords.rb
│               │   │   │   │   ├── time.rb
│               │   │   │   │   ├── uri.rb
│               │   │   │   │   └── version.rb
│               │   │   │   ├── optionparser.rb
│               │   │   │   └── optparse.rb
│               │   │   ├── [01;34mmisc[0m
│               │   │   │   ├── rb_optparse.bash
│               │   │   │   └── rb_optparse.zsh
│               │   │   ├── ChangeLog
│               │   │   ├── COPYING
│               │   │   └── README.md
│               │   ├── [01;34mos-1.1.4[0m
│               │   │   ├── [01;34mautotest[0m
│               │   │   │   └── discover.rb
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── os.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── linux_spec.rb
│               │   │   │   ├── os_spec.rb
│               │   │   │   ├── osx_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── ChangeLog
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE
│               │   │   ├── os.gemspec
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── VERSION
│               │   ├── [01;34mplist-3.7.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mplist[0m
│               │   │   │   │   ├── generator.rb
│               │   │   │   │   ├── [01;32mparser.rb[0m
│               │   │   │   │   └── version.rb
│               │   │   │   └── plist.rb
│               │   │   └── LICENSE.txt
│               │   ├── [01;34mpublic_suffix-6.0.2[0m
│               │   │   ├── [01;34mdata[0m
│               │   │   │   └── list.txt
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mpublic_suffix[0m
│               │   │   │   │   ├── domain.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── list.rb
│               │   │   │   │   ├── rule.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── public_suffix.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   ├── README.md
│               │   │   └── SECURITY.md
│               │   ├── [01;34mrake-13.3.0[0m
│               │   │   ├── [01;34mdoc[0m
│               │   │   │   ├── [01;34mexample[0m
│               │   │   │   │   ├── a.c
│               │   │   │   │   ├── b.c
│               │   │   │   │   ├── main.c
│               │   │   │   │   ├── Rakefile1
│               │   │   │   │   └── Rakefile2
│               │   │   │   ├── command_line_usage.rdoc
│               │   │   │   ├── glossary.rdoc
│               │   │   │   ├── jamis.rb
│               │   │   │   ├── proto_rake.rdoc
│               │   │   │   ├── rake.1
│               │   │   │   ├── rakefile.rdoc
│               │   │   │   └── rational.rdoc
│               │   │   ├── [01;34mexe[0m
│               │   │   │   └── [01;32mrake[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mrake[0m
│               │   │   │   │   ├── [01;34mext[0m
│               │   │   │   │   │   ├── core.rb
│               │   │   │   │   │   └── string.rb
│               │   │   │   │   ├── [01;34mloaders[0m
│               │   │   │   │   │   └── makefile.rb
│               │   │   │   │   ├── application.rb
│               │   │   │   │   ├── backtrace.rb
│               │   │   │   │   ├── clean.rb
│               │   │   │   │   ├── cloneable.rb
│               │   │   │   │   ├── cpu_counter.rb
│               │   │   │   │   ├── default_loader.rb
│               │   │   │   │   ├── dsl_definition.rb
│               │   │   │   │   ├── early_time.rb
│               │   │   │   │   ├── file_creation_task.rb
│               │   │   │   │   ├── file_list.rb
│               │   │   │   │   ├── file_task.rb
│               │   │   │   │   ├── file_utils_ext.rb
│               │   │   │   │   ├── file_utils.rb
│               │   │   │   │   ├── invocation_chain.rb
│               │   │   │   │   ├── invocation_exception_mixin.rb
│               │   │   │   │   ├── late_time.rb
│               │   │   │   │   ├── linked_list.rb
│               │   │   │   │   ├── multi_task.rb
│               │   │   │   │   ├── name_space.rb
│               │   │   │   │   ├── packagetask.rb
│               │   │   │   │   ├── phony.rb
│               │   │   │   │   ├── private_reader.rb
│               │   │   │   │   ├── promise.rb
│               │   │   │   │   ├── pseudo_status.rb
│               │   │   │   │   ├── rake_module.rb
│               │   │   │   │   ├── rake_test_loader.rb
│               │   │   │   │   ├── rule_recursion_overflow_error.rb
│               │   │   │   │   ├── scope.rb
│               │   │   │   │   ├── task_argument_error.rb
│               │   │   │   │   ├── task_arguments.rb
│               │   │   │   │   ├── task_manager.rb
│               │   │   │   │   ├── task.rb
│               │   │   │   │   ├── tasklib.rb
│               │   │   │   │   ├── testtask.rb
│               │   │   │   │   ├── thread_history_display.rb
│               │   │   │   │   ├── thread_pool.rb
│               │   │   │   │   ├── trace_output.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── win32.rb
│               │   │   │   └── rake.rb
│               │   │   ├── History.rdoc
│               │   │   ├── MIT-LICENSE
│               │   │   ├── rake.gemspec
│               │   │   └── README.rdoc
│               │   ├── [01;34mrepresentable-3.2.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mrepresentable[0m
│               │   │   │   │   ├── [01;34mhash[0m
│               │   │   │   │   │   ├── allow_symbols.rb
│               │   │   │   │   │   ├── binding.rb
│               │   │   │   │   │   └── collection.rb
│               │   │   │   │   ├── [01;34mjson[0m
│               │   │   │   │   │   ├── collection.rb
│               │   │   │   │   │   └── hash.rb
│               │   │   │   │   ├── [01;34mobject[0m
│               │   │   │   │   │   └── binding.rb
│               │   │   │   │   ├── [01;34mxml[0m
│               │   │   │   │   │   ├── binding.rb
│               │   │   │   │   │   ├── collection.rb
│               │   │   │   │   │   ├── hash.rb
│               │   │   │   │   │   └── namespace.rb
│               │   │   │   │   ├── [01;34myaml[0m
│               │   │   │   │   │   └── binding.rb
│               │   │   │   │   ├── binding.rb
│               │   │   │   │   ├── cached.rb
│               │   │   │   │   ├── coercion.rb
│               │   │   │   │   ├── config.rb
│               │   │   │   │   ├── debug.rb
│               │   │   │   │   ├── declarative.rb
│               │   │   │   │   ├── decorator.rb
│               │   │   │   │   ├── definition.rb
│               │   │   │   │   ├── deserializer.rb
│               │   │   │   │   ├── for_collection.rb
│               │   │   │   │   ├── hash_methods.rb
│               │   │   │   │   ├── hash.rb
│               │   │   │   │   ├── insert.rb
│               │   │   │   │   ├── json.rb
│               │   │   │   │   ├── object.rb
│               │   │   │   │   ├── option.rb
│               │   │   │   │   ├── pipeline_factories.rb
│               │   │   │   │   ├── pipeline.rb
│               │   │   │   │   ├── populator.rb
│               │   │   │   │   ├── represent.rb
│               │   │   │   │   ├── serializer.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   ├── xml.rb
│               │   │   │   │   └── yaml.rb
│               │   │   │   └── representable.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── [01;34mconfig[0m
│               │   │   │   │   └── inherit_test.rb
│               │   │   │   ├── [01;34mexamples[0m
│               │   │   │   │   ├── example.rb
│               │   │   │   │   └── object.rb
│               │   │   │   ├── as_test.rb
│               │   │   │   ├── benchmarking.rb
│               │   │   │   ├── binding_test.rb
│               │   │   │   ├── cached_test.rb
│               │   │   │   ├── class_test.rb
│               │   │   │   ├── coercion_test.rb
│               │   │   │   ├── config_test.rb
│               │   │   │   ├── decorator_scope_test.rb
│               │   │   │   ├── decorator_test.rb
│               │   │   │   ├── default_test.rb
│               │   │   │   ├── defaults_options_test.rb
│               │   │   │   ├── definition_test.rb
│               │   │   │   ├── exec_context_test.rb
│               │   │   │   ├── features_test.rb
│               │   │   │   ├── filter_test.rb
│               │   │   │   ├── for_collection_test.rb
│               │   │   │   ├── generic_test.rb
│               │   │   │   ├── getter_setter_test.rb
│               │   │   │   ├── hash_bindings_test.rb
│               │   │   │   ├── hash_test.rb
│               │   │   │   ├── heritage_test.rb
│               │   │   │   ├── if_test.rb
│               │   │   │   ├── include_exclude_test.rb
│               │   │   │   ├── inherit_test.rb
│               │   │   │   ├── inline_test.rb
│               │   │   │   ├── instance_test.rb
│               │   │   │   ├── is_representable_test.rb
│               │   │   │   ├── json_test.rb
│               │   │   │   ├── lonely_test.rb
│               │   │   │   ├── nested_test.rb
│               │   │   │   ├── object_test.rb
│               │   │   │   ├── option_test.rb
│               │   │   │   ├── parse_pipeline_test.rb
│               │   │   │   ├── pipeline_test.rb
│               │   │   │   ├── populator_test.rb
│               │   │   │   ├── prepare_test.rb
│               │   │   │   ├── private_options_test.rb
│               │   │   │   ├── reader_writer_test.rb
│               │   │   │   ├── realistic_benchmark.rb
│               │   │   │   ├── render_nil_test.rb
│               │   │   │   ├── represent_test.rb
│               │   │   │   ├── representable_test.rb
│               │   │   │   ├── schema_test.rb
│               │   │   │   ├── serialize_deserialize_test.rb
│               │   │   │   ├── skip_test.rb
│               │   │   │   ├── stringify_hash_test.rb
│               │   │   │   ├── test_helper_test.rb
│               │   │   │   ├── test_helper.rb
│               │   │   │   ├── uncategorized_test.rb
│               │   │   │   ├── user_options_test.rb
│               │   │   │   ├── wrap_test.rb
│               │   │   │   ├── xml_bindings_test.rb
│               │   │   │   ├── xml_namespace_test.rb
│               │   │   │   ├── xml_test.rb
│               │   │   │   └── yaml_test.rb
│               │   │   ├── CHANGES.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   ├── representable.gemspec
│               │   │   ├── TODO
│               │   │   └── TODO-4.0.md
│               │   ├── [01;34mretriable-3.1.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mretriable[0m
│               │   │   │   │   ├── [01;34mcore_ext[0m
│               │   │   │   │   │   └── kernel.rb
│               │   │   │   │   ├── config.rb
│               │   │   │   │   ├── exponential_backoff.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── retriable.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34msupport[0m
│               │   │   │   │   └── exceptions.rb
│               │   │   │   ├── config_spec.rb
│               │   │   │   ├── exponential_backoff_spec.rb
│               │   │   │   ├── retriable_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE
│               │   │   ├── README.md
│               │   │   └── retriable.gemspec
│               │   ├── [01;34mrexml-3.4.2[0m
│               │   │   ├── [01;34mdoc[0m
│               │   │   │   └── [01;34mrexml[0m
│               │   │   │       ├── [01;34mtasks[0m
│               │   │   │       │   ├── [01;34mrdoc[0m
│               │   │   │       │   │   ├── child.rdoc
│               │   │   │       │   │   ├── document.rdoc
│               │   │   │       │   │   ├── element.rdoc
│               │   │   │       │   │   ├── node.rdoc
│               │   │   │       │   │   └── parent.rdoc
│               │   │   │       │   └── [01;34mtocs[0m
│               │   │   │       │       ├── child_toc.rdoc
│               │   │   │       │       ├── document_toc.rdoc
│               │   │   │       │       ├── element_toc.rdoc
│               │   │   │       │       ├── master_toc.rdoc
│               │   │   │       │       ├── node_toc.rdoc
│               │   │   │       │       └── parent_toc.rdoc
│               │   │   │       ├── context.rdoc
│               │   │   │       └── tutorial.rdoc
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mrexml[0m
│               │   │   │   │   ├── [01;34mdtd[0m
│               │   │   │   │   │   ├── attlistdecl.rb
│               │   │   │   │   │   ├── dtd.rb
│               │   │   │   │   │   ├── elementdecl.rb
│               │   │   │   │   │   ├── entitydecl.rb
│               │   │   │   │   │   └── notationdecl.rb
│               │   │   │   │   ├── [01;34mformatters[0m
│               │   │   │   │   │   ├── default.rb
│               │   │   │   │   │   ├── pretty.rb
│               │   │   │   │   │   └── transitive.rb
│               │   │   │   │   ├── [01;34mlight[0m
│               │   │   │   │   │   └── node.rb
│               │   │   │   │   ├── [01;34mparsers[0m
│               │   │   │   │   │   ├── baseparser.rb
│               │   │   │   │   │   ├── lightparser.rb
│               │   │   │   │   │   ├── pullparser.rb
│               │   │   │   │   │   ├── sax2parser.rb
│               │   │   │   │   │   ├── streamparser.rb
│               │   │   │   │   │   ├── treeparser.rb
│               │   │   │   │   │   ├── ultralightparser.rb
│               │   │   │   │   │   └── xpathparser.rb
│               │   │   │   │   ├── [01;34mvalidation[0m
│               │   │   │   │   │   ├── relaxng.rb
│               │   │   │   │   │   ├── validation.rb
│               │   │   │   │   │   └── validationexception.rb
│               │   │   │   │   ├── attlistdecl.rb
│               │   │   │   │   ├── attribute.rb
│               │   │   │   │   ├── cdata.rb
│               │   │   │   │   ├── child.rb
│               │   │   │   │   ├── comment.rb
│               │   │   │   │   ├── doctype.rb
│               │   │   │   │   ├── document.rb
│               │   │   │   │   ├── element.rb
│               │   │   │   │   ├── encoding.rb
│               │   │   │   │   ├── entity.rb
│               │   │   │   │   ├── functions.rb
│               │   │   │   │   ├── instruction.rb
│               │   │   │   │   ├── namespace.rb
│               │   │   │   │   ├── node.rb
│               │   │   │   │   ├── output.rb
│               │   │   │   │   ├── parent.rb
│               │   │   │   │   ├── parseexception.rb
│               │   │   │   │   ├── quickpath.rb
│               │   │   │   │   ├── rexml.rb
│               │   │   │   │   ├── sax2listener.rb
│               │   │   │   │   ├── security.rb
│               │   │   │   │   ├── source.rb
│               │   │   │   │   ├── streamlistener.rb
│               │   │   │   │   ├── text.rb
│               │   │   │   │   ├── undefinednamespaceexception.rb
│               │   │   │   │   ├── xmldecl.rb
│               │   │   │   │   ├── xmltokens.rb
│               │   │   │   │   ├── xpath_parser.rb
│               │   │   │   │   └── xpath.rb
│               │   │   │   └── rexml.rb
│               │   │   ├── LICENSE.txt
│               │   │   ├── NEWS.md
│               │   │   └── README.md
│               │   ├── [01;34mrouge-3.28.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mrouge[0m
│               │   │   │   │   ├── [01;34mdemos[0m
│               │   │   │   │   │   ├── abap
│               │   │   │   │   │   ├── actionscript
│               │   │   │   │   │   ├── ada
│               │   │   │   │   │   ├── apache
│               │   │   │   │   │   ├── apex
│               │   │   │   │   │   ├── apiblueprint
│               │   │   │   │   │   ├── applescript
│               │   │   │   │   │   ├── armasm
│               │   │   │   │   │   ├── augeas
│               │   │   │   │   │   ├── awk
│               │   │   │   │   │   ├── batchfile
│               │   │   │   │   │   ├── bbcbasic
│               │   │   │   │   │   ├── bibtex
│               │   │   │   │   │   ├── biml
│               │   │   │   │   │   ├── bpf
│               │   │   │   │   │   ├── brainfuck
│               │   │   │   │   │   ├── brightscript
│               │   │   │   │   │   ├── bsl
│               │   │   │   │   │   ├── c
│               │   │   │   │   │   ├── ceylon
│               │   │   │   │   │   ├── cfscript
│               │   │   │   │   │   ├── clean
│               │   │   │   │   │   ├── clojure
│               │   │   │   │   │   ├── cmake
│               │   │   │   │   │   ├── cmhg
│               │   │   │   │   │   ├── coffeescript
│               │   │   │   │   │   ├── common_lisp
│               │   │   │   │   │   ├── conf
│               │   │   │   │   │   ├── console
│               │   │   │   │   │   ├── coq
│               │   │   │   │   │   ├── cpp
│               │   │   │   │   │   ├── crystal
│               │   │   │   │   │   ├── csharp
│               │   │   │   │   │   ├── css
│               │   │   │   │   │   ├── csvs
│               │   │   │   │   │   ├── cuda
│               │   │   │   │   │   ├── cypher
│               │   │   │   │   │   ├── cython
│               │   │   │   │   │   ├── d
│               │   │   │   │   │   ├── dafny
│               │   │   │   │   │   ├── dart
│               │   │   │   │   │   ├── datastudio
│               │   │   │   │   │   ├── diff
│               │   │   │   │   │   ├── digdag
│               │   │   │   │   │   ├── docker
│               │   │   │   │   │   ├── dot
│               │   │   │   │   │   ├── ecl
│               │   │   │   │   │   ├── eex
│               │   │   │   │   │   ├── eiffel
│               │   │   │   │   │   ├── elixir
│               │   │   │   │   │   ├── elm
│               │   │   │   │   │   ├── email
│               │   │   │   │   │   ├── epp
│               │   │   │   │   │   ├── erb
│               │   │   │   │   │   ├── erlang
│               │   │   │   │   │   ├── escape
│               │   │   │   │   │   ├── factor
│               │   │   │   │   │   ├── fluent
│               │   │   │   │   │   ├── fortran
│               │   │   │   │   │   ├── freefem
│               │   │   │   │   │   ├── fsharp
│               │   │   │   │   │   ├── gdscript
│               │   │   │   │   │   ├── ghc-cmm
│               │   │   │   │   │   ├── ghc-core
│               │   │   │   │   │   ├── gherkin
│               │   │   │   │   │   ├── glsl
│               │   │   │   │   │   ├── go
│               │   │   │   │   │   ├── gradle
│               │   │   │   │   │   ├── graphql
│               │   │   │   │   │   ├── groovy
│               │   │   │   │   │   ├── hack
│               │   │   │   │   │   ├── haml
│               │   │   │   │   │   ├── handlebars
│               │   │   │   │   │   ├── haskell
│               │   │   │   │   │   ├── haxe
│               │   │   │   │   │   ├── hcl
│               │   │   │   │   │   ├── hlsl
│               │   │   │   │   │   ├── hocon
│               │   │   │   │   │   ├── hql
│               │   │   │   │   │   ├── html
│               │   │   │   │   │   ├── http
│               │   │   │   │   │   ├── hylang
│               │   │   │   │   │   ├── idlang
│               │   │   │   │   │   ├── igorpro
│               │   │   │   │   │   ├── ini
│               │   │   │   │   │   ├── io
│               │   │   │   │   │   ├── irb
│               │   │   │   │   │   ├── irb_output
│               │   │   │   │   │   ├── isbl
│               │   │   │   │   │   ├── j
│               │   │   │   │   │   ├── janet
│               │   │   │   │   │   ├── java
│               │   │   │   │   │   ├── javascript
│               │   │   │   │   │   ├── jinja
│               │   │   │   │   │   ├── jsl
│               │   │   │   │   │   ├── json
│               │   │   │   │   │   ├── json-doc
│               │   │   │   │   │   ├── jsonnet
│               │   │   │   │   │   ├── jsp
│               │   │   │   │   │   ├── jsx
│               │   │   │   │   │   ├── julia
│               │   │   │   │   │   ├── kotlin
│               │   │   │   │   │   ├── lasso
│               │   │   │   │   │   ├── liquid
│               │   │   │   │   │   ├── literate_coffeescript
│               │   │   │   │   │   ├── literate_haskell
│               │   │   │   │   │   ├── livescript
│               │   │   │   │   │   ├── llvm
│               │   │   │   │   │   ├── lua
│               │   │   │   │   │   ├── lustre
│               │   │   │   │   │   ├── lutin
│               │   │   │   │   │   ├── m68k
│               │   │   │   │   │   ├── magik
│               │   │   │   │   │   ├── make
│               │   │   │   │   │   ├── markdown
│               │   │   │   │   │   ├── mason
│               │   │   │   │   │   ├── mathematica
│               │   │   │   │   │   ├── matlab
│               │   │   │   │   │   ├── minizinc
│               │   │   │   │   │   ├── moonscript
│               │   │   │   │   │   ├── mosel
│               │   │   │   │   │   ├── msgtrans
│               │   │   │   │   │   ├── mxml
│               │   │   │   │   │   ├── nasm
│               │   │   │   │   │   ├── nesasm
│               │   │   │   │   │   ├── nginx
│               │   │   │   │   │   ├── nim
│               │   │   │   │   │   ├── nix
│               │   │   │   │   │   ├── objective_c
│               │   │   │   │   │   ├── objective_cpp
│               │   │   │   │   │   ├── ocaml
│               │   │   │   │   │   ├── ocl
│               │   │   │   │   │   ├── openedge
│               │   │   │   │   │   ├── opentype_feature_file
│               │   │   │   │   │   ├── pascal
│               │   │   │   │   │   ├── perl
│               │   │   │   │   │   ├── php
│               │   │   │   │   │   ├── plaintext
│               │   │   │   │   │   ├── plist
│               │   │   │   │   │   ├── pony
│               │   │   │   │   │   ├── postscript
│               │   │   │   │   │   ├── powershell
│               │   │   │   │   │   ├── praat
│               │   │   │   │   │   ├── prolog
│               │   │   │   │   │   ├── prometheus
│               │   │   │   │   │   ├── properties
│               │   │   │   │   │   ├── protobuf
│               │   │   │   │   │   ├── puppet
│               │   │   │   │   │   ├── python
│               │   │   │   │   │   ├── q
│               │   │   │   │   │   ├── qml
│               │   │   │   │   │   ├── r
│               │   │   │   │   │   ├── racket
│               │   │   │   │   │   ├── reasonml
│               │   │   │   │   │   ├── rego
│               │   │   │   │   │   ├── rescript
│               │   │   │   │   │   ├── robot_framework
│               │   │   │   │   │   ├── ruby
│               │   │   │   │   │   ├── rust
│               │   │   │   │   │   ├── sas
│               │   │   │   │   │   ├── sass
│               │   │   │   │   │   ├── scala
│               │   │   │   │   │   ├── scheme
│               │   │   │   │   │   ├── scss
│               │   │   │   │   │   ├── sed
│               │   │   │   │   │   ├── shell
│               │   │   │   │   │   ├── sieve
│               │   │   │   │   │   ├── slice
│               │   │   │   │   │   ├── slim
│               │   │   │   │   │   ├── smalltalk
│               │   │   │   │   │   ├── smarty
│               │   │   │   │   │   ├── sml
│               │   │   │   │   │   ├── solidity
│               │   │   │   │   │   ├── sparql
│               │   │   │   │   │   ├── sqf
│               │   │   │   │   │   ├── sql
│               │   │   │   │   │   ├── ssh
│               │   │   │   │   │   ├── stan
│               │   │   │   │   │   ├── stata
│               │   │   │   │   │   ├── supercollider
│               │   │   │   │   │   ├── swift
│               │   │   │   │   │   ├── systemd
│               │   │   │   │   │   ├── tap
│               │   │   │   │   │   ├── tcl
│               │   │   │   │   │   ├── terraform
│               │   │   │   │   │   ├── tex
│               │   │   │   │   │   ├── toml
│               │   │   │   │   │   ├── tsx
│               │   │   │   │   │   ├── ttcn3
│               │   │   │   │   │   ├── tulip
│               │   │   │   │   │   ├── turtle
│               │   │   │   │   │   ├── twig
│               │   │   │   │   │   ├── typescript
│               │   │   │   │   │   ├── vala
│               │   │   │   │   │   ├── vb
│               │   │   │   │   │   ├── vcl
│               │   │   │   │   │   ├── velocity
│               │   │   │   │   │   ├── verilog
│               │   │   │   │   │   ├── vhdl
│               │   │   │   │   │   ├── viml
│               │   │   │   │   │   ├── vue
│               │   │   │   │   │   ├── wollok
│               │   │   │   │   │   ├── xml
│               │   │   │   │   │   ├── xojo
│               │   │   │   │   │   ├── xpath
│               │   │   │   │   │   ├── xquery
│               │   │   │   │   │   ├── yaml
│               │   │   │   │   │   ├── yang
│               │   │   │   │   │   └── zig
│               │   │   │   │   ├── [01;34mformatters[0m
│               │   │   │   │   │   ├── html_inline.rb
│               │   │   │   │   │   ├── html_legacy.rb
│               │   │   │   │   │   ├── html_line_highlighter.rb
│               │   │   │   │   │   ├── html_line_table.rb
│               │   │   │   │   │   ├── html_linewise.rb
│               │   │   │   │   │   ├── html_pygments.rb
│               │   │   │   │   │   ├── html_table.rb
│               │   │   │   │   │   ├── html.rb
│               │   │   │   │   │   ├── null.rb
│               │   │   │   │   │   ├── terminal_truecolor.rb
│               │   │   │   │   │   ├── terminal256.rb
│               │   │   │   │   │   └── tex.rb
│               │   │   │   │   ├── [01;34mguessers[0m
│               │   │   │   │   │   ├── disambiguation.rb
│               │   │   │   │   │   ├── filename.rb
│               │   │   │   │   │   ├── glob_mapping.rb
│               │   │   │   │   │   ├── mimetype.rb
│               │   │   │   │   │   ├── modeline.rb
│               │   │   │   │   │   ├── source.rb
│               │   │   │   │   │   └── util.rb
│               │   │   │   │   ├── [01;34mlexers[0m
│               │   │   │   │   │   ├── [01;34mapache[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mgherkin[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34misbl[0m
│               │   │   │   │   │   │   └── builtins.rb
│               │   │   │   │   │   ├── [01;34mlasso[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mllvm[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mlua[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mmathematica[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mmatlab[0m
│               │   │   │   │   │   │   ├── builtins.rb
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mobjective_c[0m
│               │   │   │   │   │   │   └── common.rb
│               │   │   │   │   │   ├── [01;34mocaml[0m
│               │   │   │   │   │   │   └── common.rb
│               │   │   │   │   │   ├── [01;34mphp[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34msass[0m
│               │   │   │   │   │   │   └── common.rb
│               │   │   │   │   │   ├── [01;34msqf[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── [01;34mtypescript[0m
│               │   │   │   │   │   │   └── common.rb
│               │   │   │   │   │   ├── [01;34mviml[0m
│               │   │   │   │   │   │   └── keywords.rb
│               │   │   │   │   │   ├── abap.rb
│               │   │   │   │   │   ├── actionscript.rb
│               │   │   │   │   │   ├── ada.rb
│               │   │   │   │   │   ├── apache.rb
│               │   │   │   │   │   ├── apex.rb
│               │   │   │   │   │   ├── apiblueprint.rb
│               │   │   │   │   │   ├── apple_script.rb
│               │   │   │   │   │   ├── armasm.rb
│               │   │   │   │   │   ├── augeas.rb
│               │   │   │   │   │   ├── awk.rb
│               │   │   │   │   │   ├── batchfile.rb
│               │   │   │   │   │   ├── bbcbasic.rb
│               │   │   │   │   │   ├── bibtex.rb
│               │   │   │   │   │   ├── biml.rb
│               │   │   │   │   │   ├── bpf.rb
│               │   │   │   │   │   ├── brainfuck.rb
│               │   │   │   │   │   ├── brightscript.rb
│               │   │   │   │   │   ├── bsl.rb
│               │   │   │   │   │   ├── c.rb
│               │   │   │   │   │   ├── ceylon.rb
│               │   │   │   │   │   ├── cfscript.rb
│               │   │   │   │   │   ├── clean.rb
│               │   │   │   │   │   ├── clojure.rb
│               │   │   │   │   │   ├── cmake.rb
│               │   │   │   │   │   ├── cmhg.rb
│               │   │   │   │   │   ├── coffeescript.rb
│               │   │   │   │   │   ├── common_lisp.rb
│               │   │   │   │   │   ├── conf.rb
│               │   │   │   │   │   ├── console.rb
│               │   │   │   │   │   ├── coq.rb
│               │   │   │   │   │   ├── cpp.rb
│               │   │   │   │   │   ├── crystal.rb
│               │   │   │   │   │   ├── csharp.rb
│               │   │   │   │   │   ├── css.rb
│               │   │   │   │   │   ├── csvs.rb
│               │   │   │   │   │   ├── cuda.rb
│               │   │   │   │   │   ├── cypher.rb
│               │   │   │   │   │   ├── cython.rb
│               │   │   │   │   │   ├── d.rb
│               │   │   │   │   │   ├── dafny.rb
│               │   │   │   │   │   ├── dart.rb
│               │   │   │   │   │   ├── datastudio.rb
│               │   │   │   │   │   ├── diff.rb
│               │   │   │   │   │   ├── digdag.rb
│               │   │   │   │   │   ├── docker.rb
│               │   │   │   │   │   ├── dot.rb
│               │   │   │   │   │   ├── ecl.rb
│               │   │   │   │   │   ├── eex.rb
│               │   │   │   │   │   ├── eiffel.rb
│               │   │   │   │   │   ├── elixir.rb
│               │   │   │   │   │   ├── elm.rb
│               │   │   │   │   │   ├── email.rb
│               │   │   │   │   │   ├── epp.rb
│               │   │   │   │   │   ├── erb.rb
│               │   │   │   │   │   ├── erlang.rb
│               │   │   │   │   │   ├── escape.rb
│               │   │   │   │   │   ├── factor.rb
│               │   │   │   │   │   ├── fluent.rb
│               │   │   │   │   │   ├── fortran.rb
│               │   │   │   │   │   ├── freefem.rb
│               │   │   │   │   │   ├── fsharp.rb
│               │   │   │   │   │   ├── gdscript.rb
│               │   │   │   │   │   ├── ghc_cmm.rb
│               │   │   │   │   │   ├── ghc_core.rb
│               │   │   │   │   │   ├── gherkin.rb
│               │   │   │   │   │   ├── glsl.rb
│               │   │   │   │   │   ├── go.rb
│               │   │   │   │   │   ├── gradle.rb
│               │   │   │   │   │   ├── graphql.rb
│               │   │   │   │   │   ├── groovy.rb
│               │   │   │   │   │   ├── hack.rb
│               │   │   │   │   │   ├── haml.rb
│               │   │   │   │   │   ├── handlebars.rb
│               │   │   │   │   │   ├── haskell.rb
│               │   │   │   │   │   ├── haxe.rb
│               │   │   │   │   │   ├── hcl.rb
│               │   │   │   │   │   ├── hlsl.rb
│               │   │   │   │   │   ├── hocon.rb
│               │   │   │   │   │   ├── hql.rb
│               │   │   │   │   │   ├── html.rb
│               │   │   │   │   │   ├── http.rb
│               │   │   │   │   │   ├── hylang.rb
│               │   │   │   │   │   ├── idlang.rb
│               │   │   │   │   │   ├── igorpro.rb
│               │   │   │   │   │   ├── ini.rb
│               │   │   │   │   │   ├── io.rb
│               │   │   │   │   │   ├── irb.rb
│               │   │   │   │   │   ├── isbl.rb
│               │   │   │   │   │   ├── j.rb
│               │   │   │   │   │   ├── janet.rb
│               │   │   │   │   │   ├── java.rb
│               │   │   │   │   │   ├── javascript.rb
│               │   │   │   │   │   ├── jinja.rb
│               │   │   │   │   │   ├── jsl.rb
│               │   │   │   │   │   ├── json_doc.rb
│               │   │   │   │   │   ├── json.rb
│               │   │   │   │   │   ├── jsonnet.rb
│               │   │   │   │   │   ├── jsp.rb
│               │   │   │   │   │   ├── jsx.rb
│               │   │   │   │   │   ├── julia.rb
│               │   │   │   │   │   ├── kotlin.rb
│               │   │   │   │   │   ├── lasso.rb
│               │   │   │   │   │   ├── liquid.rb
│               │   │   │   │   │   ├── literate_coffeescript.rb
│               │   │   │   │   │   ├── literate_haskell.rb
│               │   │   │   │   │   ├── livescript.rb
│               │   │   │   │   │   ├── llvm.rb
│               │   │   │   │   │   ├── lua.rb
│               │   │   │   │   │   ├── lustre.rb
│               │   │   │   │   │   ├── lutin.rb
│               │   │   │   │   │   ├── m68k.rb
│               │   │   │   │   │   ├── magik.rb
│               │   │   │   │   │   ├── make.rb
│               │   │   │   │   │   ├── markdown.rb
│               │   │   │   │   │   ├── mason.rb
│               │   │   │   │   │   ├── mathematica.rb
│               │   │   │   │   │   ├── matlab.rb
│               │   │   │   │   │   ├── minizinc.rb
│               │   │   │   │   │   ├── moonscript.rb
│               │   │   │   │   │   ├── mosel.rb
│               │   │   │   │   │   ├── msgtrans.rb
│               │   │   │   │   │   ├── mxml.rb
│               │   │   │   │   │   ├── nasm.rb
│               │   │   │   │   │   ├── nesasm.rb
│               │   │   │   │   │   ├── nginx.rb
│               │   │   │   │   │   ├── nim.rb
│               │   │   │   │   │   ├── nix.rb
│               │   │   │   │   │   ├── objective_c.rb
│               │   │   │   │   │   ├── objective_cpp.rb
│               │   │   │   │   │   ├── ocaml.rb
│               │   │   │   │   │   ├── ocl.rb
│               │   │   │   │   │   ├── openedge.rb
│               │   │   │   │   │   ├── opentype_feature_file.rb
│               │   │   │   │   │   ├── pascal.rb
│               │   │   │   │   │   ├── perl.rb
│               │   │   │   │   │   ├── php.rb
│               │   │   │   │   │   ├── plain_text.rb
│               │   │   │   │   │   ├── plist.rb
│               │   │   │   │   │   ├── pony.rb
│               │   │   │   │   │   ├── postscript.rb
│               │   │   │   │   │   ├── powershell.rb
│               │   │   │   │   │   ├── praat.rb
│               │   │   │   │   │   ├── prolog.rb
│               │   │   │   │   │   ├── prometheus.rb
│               │   │   │   │   │   ├── properties.rb
│               │   │   │   │   │   ├── protobuf.rb
│               │   │   │   │   │   ├── puppet.rb
│               │   │   │   │   │   ├── python.rb
│               │   │   │   │   │   ├── q.rb
│               │   │   │   │   │   ├── qml.rb
│               │   │   │   │   │   ├── r.rb
│               │   │   │   │   │   ├── racket.rb
│               │   │   │   │   │   ├── reasonml.rb
│               │   │   │   │   │   ├── rego.rb
│               │   │   │   │   │   ├── rescript.rb
│               │   │   │   │   │   ├── robot_framework.rb
│               │   │   │   │   │   ├── ruby.rb
│               │   │   │   │   │   ├── rust.rb
│               │   │   │   │   │   ├── sas.rb
│               │   │   │   │   │   ├── sass.rb
│               │   │   │   │   │   ├── scala.rb
│               │   │   │   │   │   ├── scheme.rb
│               │   │   │   │   │   ├── scss.rb
│               │   │   │   │   │   ├── sed.rb
│               │   │   │   │   │   ├── shell.rb
│               │   │   │   │   │   ├── sieve.rb
│               │   │   │   │   │   ├── slice.rb
│               │   │   │   │   │   ├── slim.rb
│               │   │   │   │   │   ├── smalltalk.rb
│               │   │   │   │   │   ├── smarty.rb
│               │   │   │   │   │   ├── sml.rb
│               │   │   │   │   │   ├── solidity.rb
│               │   │   │   │   │   ├── sparql.rb
│               │   │   │   │   │   ├── sqf.rb
│               │   │   │   │   │   ├── sql.rb
│               │   │   │   │   │   ├── ssh.rb
│               │   │   │   │   │   ├── stan.rb
│               │   │   │   │   │   ├── stata.rb
│               │   │   │   │   │   ├── supercollider.rb
│               │   │   │   │   │   ├── swift.rb
│               │   │   │   │   │   ├── systemd.rb
│               │   │   │   │   │   ├── tap.rb
│               │   │   │   │   │   ├── tcl.rb
│               │   │   │   │   │   ├── terraform.rb
│               │   │   │   │   │   ├── tex.rb
│               │   │   │   │   │   ├── toml.rb
│               │   │   │   │   │   ├── tsx.rb
│               │   │   │   │   │   ├── ttcn3.rb
│               │   │   │   │   │   ├── tulip.rb
│               │   │   │   │   │   ├── turtle.rb
│               │   │   │   │   │   ├── twig.rb
│               │   │   │   │   │   ├── typescript.rb
│               │   │   │   │   │   ├── vala.rb
│               │   │   │   │   │   ├── varnish.rb
│               │   │   │   │   │   ├── vb.rb
│               │   │   │   │   │   ├── velocity.rb
│               │   │   │   │   │   ├── verilog.rb
│               │   │   │   │   │   ├── vhdl.rb
│               │   │   │   │   │   ├── viml.rb
│               │   │   │   │   │   ├── vue.rb
│               │   │   │   │   │   ├── wollok.rb
│               │   │   │   │   │   ├── xml.rb
│               │   │   │   │   │   ├── xojo.rb
│               │   │   │   │   │   ├── xpath.rb
│               │   │   │   │   │   ├── xquery.rb
│               │   │   │   │   │   ├── yaml.rb
│               │   │   │   │   │   ├── yang.rb
│               │   │   │   │   │   └── zig.rb
│               │   │   │   │   ├── [01;34mplugins[0m
│               │   │   │   │   │   └── redcarpet.rb
│               │   │   │   │   ├── [01;34mthemes[0m
│               │   │   │   │   │   ├── base16.rb
│               │   │   │   │   │   ├── bw.rb
│               │   │   │   │   │   ├── colorful.rb
│               │   │   │   │   │   ├── github.rb
│               │   │   │   │   │   ├── gruvbox.rb
│               │   │   │   │   │   ├── igor_pro.rb
│               │   │   │   │   │   ├── magritte.rb
│               │   │   │   │   │   ├── molokai.rb
│               │   │   │   │   │   ├── monokai_sublime.rb
│               │   │   │   │   │   ├── monokai.rb
│               │   │   │   │   │   ├── pastie.rb
│               │   │   │   │   │   ├── thankful_eyes.rb
│               │   │   │   │   │   └── tulip.rb
│               │   │   │   │   ├── cli.rb
│               │   │   │   │   ├── formatter.rb
│               │   │   │   │   ├── guesser.rb
│               │   │   │   │   ├── lexer.rb
│               │   │   │   │   ├── regex_lexer.rb
│               │   │   │   │   ├── template_lexer.rb
│               │   │   │   │   ├── tex_theme_renderer.rb
│               │   │   │   │   ├── text_analyzer.rb
│               │   │   │   │   ├── theme.rb
│               │   │   │   │   ├── token.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── rouge.rb
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE
│               │   │   └── rouge.gemspec
│               │   ├── [01;34mruby2_keywords-0.0.5[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── ruby2_keywords.rb
│               │   │   ├── [01;34mlogs[0m
│               │   │   │   ├── ChangeLog-0.0.0
│               │   │   │   ├── ChangeLog-0.0.1
│               │   │   │   ├── ChangeLog-0.0.2
│               │   │   │   ├── ChangeLog-0.0.3
│               │   │   │   └── ChangeLog-0.0.4
│               │   │   ├── ChangeLog
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mrubyzip-2.4.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mzip[0m
│               │   │   │   │   ├── [01;34mcrypto[0m
│               │   │   │   │   │   ├── decrypted_io.rb
│               │   │   │   │   │   ├── encryption.rb
│               │   │   │   │   │   ├── null_encryption.rb
│               │   │   │   │   │   └── traditional_encryption.rb
│               │   │   │   │   ├── [01;34mextra_field[0m
│               │   │   │   │   │   ├── generic.rb
│               │   │   │   │   │   ├── ntfs.rb
│               │   │   │   │   │   ├── old_unix.rb
│               │   │   │   │   │   ├── universal_time.rb
│               │   │   │   │   │   ├── unix.rb
│               │   │   │   │   │   ├── zip64_placeholder.rb
│               │   │   │   │   │   └── zip64.rb
│               │   │   │   │   ├── [01;34mioextras[0m
│               │   │   │   │   │   ├── abstract_input_stream.rb
│               │   │   │   │   │   └── abstract_output_stream.rb
│               │   │   │   │   ├── central_directory.rb
│               │   │   │   │   ├── compressor.rb
│               │   │   │   │   ├── constants.rb
│               │   │   │   │   ├── decompressor.rb
│               │   │   │   │   ├── deflater.rb
│               │   │   │   │   ├── dos_time.rb
│               │   │   │   │   ├── entry_set.rb
│               │   │   │   │   ├── entry.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── extra_field.rb
│               │   │   │   │   ├── file.rb
│               │   │   │   │   ├── filesystem.rb
│               │   │   │   │   ├── inflater.rb
│               │   │   │   │   ├── input_stream.rb
│               │   │   │   │   ├── ioextras.rb
│               │   │   │   │   ├── null_compressor.rb
│               │   │   │   │   ├── null_decompressor.rb
│               │   │   │   │   ├── null_input_stream.rb
│               │   │   │   │   ├── output_stream.rb
│               │   │   │   │   ├── pass_thru_compressor.rb
│               │   │   │   │   ├── pass_thru_decompressor.rb
│               │   │   │   │   ├── streamable_directory.rb
│               │   │   │   │   ├── streamable_stream.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── zip.rb
│               │   │   ├── [01;34msamples[0m
│               │   │   │   ├── [01;32mexample_filesystem.rb[0m
│               │   │   │   ├── example_recursive.rb
│               │   │   │   ├── [01;32mexample.rb[0m
│               │   │   │   ├── [01;32mgtk_ruby_zip.rb[0m
│               │   │   │   ├── [01;32mqtzip.rb[0m
│               │   │   │   ├── [01;32mwrite_simple.rb[0m
│               │   │   │   └── [01;32mzipfind.rb[0m
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── TODO
│               │   ├── [01;34msecurity-0.1.5[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34msecurity[0m
│               │   │   │   │   ├── certificate.rb
│               │   │   │   │   ├── keychain.rb
│               │   │   │   │   ├── password.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── security.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── certificate_spec.rb
│               │   │   │   ├── keychain_spec.rb
│               │   │   │   ├── password_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE.md
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── security.gemspec
│               │   ├── [01;34msignet-0.21.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34msignet[0m
│               │   │   │   │   ├── [01;34moauth_1[0m
│               │   │   │   │   │   ├── [01;34msignature_methods[0m
│               │   │   │   │   │   │   ├── hmac_sha1.rb
│               │   │   │   │   │   │   ├── plaintext.rb
│               │   │   │   │   │   │   └── rsa_sha1.rb
│               │   │   │   │   │   ├── client.rb
│               │   │   │   │   │   ├── credential.rb
│               │   │   │   │   │   └── server.rb
│               │   │   │   │   ├── [01;34moauth_2[0m
│               │   │   │   │   │   └── client.rb
│               │   │   │   │   ├── errors.rb
│               │   │   │   │   ├── oauth_1.rb
│               │   │   │   │   ├── oauth_2.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── signet.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CODE_OF_CONDUCT.md
│               │   │   ├── LICENSE
│               │   │   ├── README.md
│               │   │   └── SECURITY.md
│               │   ├── [01;34msimctl-1.6.10[0m
│               │   │   ├── [01;34mfastlane-plugin-simctl[0m
│               │   │   │   ├── [01;34mfastlane[0m
│               │   │   │   │   ├── Fastfile
│               │   │   │   │   └── Pluginfile
│               │   │   │   ├── [01;34mlib[0m
│               │   │   │   │   └── [01;34mfastlane[0m
│               │   │   │   │       └── [01;34mplugin[0m
│               │   │   │   │           ├── [01;34msimctl[0m
│               │   │   │   │           │   ├── [01;34mactions[0m
│               │   │   │   │           │   │   └── simctl_action.rb
│               │   │   │   │           │   ├── [01;34mhelper[0m
│               │   │   │   │           │   │   └── simctl_helper.rb
│               │   │   │   │           │   └── version.rb
│               │   │   │   │           └── simctl.rb
│               │   │   │   ├── [01;34mspec[0m
│               │   │   │   │   ├── simctl_action_spec.rb
│               │   │   │   │   └── spec_helper.rb
│               │   │   │   ├── fastlane-plugin-simctl.gemspec
│               │   │   │   ├── Gemfile
│               │   │   │   ├── Rakefile
│               │   │   │   └── README.md
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34msimctl[0m
│               │   │   │   │   ├── [01;34mcommand[0m
│               │   │   │   │   │   ├── boot.rb
│               │   │   │   │   │   ├── create.rb
│               │   │   │   │   │   ├── delete.rb
│               │   │   │   │   │   ├── erase.rb
│               │   │   │   │   │   ├── install.rb
│               │   │   │   │   │   ├── io.rb
│               │   │   │   │   │   ├── keychain.rb
│               │   │   │   │   │   ├── kill.rb
│               │   │   │   │   │   ├── launch.rb
│               │   │   │   │   │   ├── list.rb
│               │   │   │   │   │   ├── openurl.rb
│               │   │   │   │   │   ├── privacy.rb
│               │   │   │   │   │   ├── push.rb
│               │   │   │   │   │   ├── rename.rb
│               │   │   │   │   │   ├── reset.rb
│               │   │   │   │   │   ├── shutdown.rb
│               │   │   │   │   │   ├── spawn.rb
│               │   │   │   │   │   ├── status_bar.rb
│               │   │   │   │   │   ├── terminate.rb
│               │   │   │   │   │   ├── uninstall.rb
│               │   │   │   │   │   ├── upgrade.rb
│               │   │   │   │   │   └── warmup.rb
│               │   │   │   │   ├── [01;34mxcode[0m
│               │   │   │   │   │   ├── path.rb
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   ├── command.rb
│               │   │   │   │   ├── device_launchctl.rb
│               │   │   │   │   ├── device_path.rb
│               │   │   │   │   ├── device_settings.rb
│               │   │   │   │   ├── device_type.rb
│               │   │   │   │   ├── device.rb
│               │   │   │   │   ├── executor.rb
│               │   │   │   │   ├── keychain.rb
│               │   │   │   │   ├── list.rb
│               │   │   │   │   ├── object.rb
│               │   │   │   │   ├── runtime.rb
│               │   │   │   │   ├── status_bar.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── simctl.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mSampleApp[0m
│               │   │   │   │   ├── [01;34mSampleApp[0m
│               │   │   │   │   │   ├── AppDelegate.h
│               │   │   │   │   │   ├── AppDelegate.m
│               │   │   │   │   │   ├── Info.plist
│               │   │   │   │   │   └── main.m
│               │   │   │   │   └── [01;34mSampleApp.xcodeproj[0m
│               │   │   │   │       └── project.pbxproj
│               │   │   │   ├── [01;34msimctl[0m
│               │   │   │   │   ├── device_interaction_spec.rb
│               │   │   │   │   ├── executor_spec.rb
│               │   │   │   │   ├── list_spec.rb
│               │   │   │   │   ├── readme_spec.rb
│               │   │   │   │   ├── upgrade_spec.rb
│               │   │   │   │   └── warmup_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── simctl.gemspec
│               │   ├── [01;34mslack-notifier-2.4.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mslack-notifier[0m
│               │   │   │   │   ├── [01;34mpayload_middleware[0m
│               │   │   │   │   │   ├── at.rb
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── channels.rb
│               │   │   │   │   │   ├── format_attachments.rb
│               │   │   │   │   │   ├── format_message.rb
│               │   │   │   │   │   └── stack.rb
│               │   │   │   │   ├── [01;34mutil[0m
│               │   │   │   │   │   ├── escape.rb
│               │   │   │   │   │   ├── http_client.rb
│               │   │   │   │   │   └── link_formatter.rb
│               │   │   │   │   ├── config.rb
│               │   │   │   │   ├── payload_middleware.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── slack-notifier.rb
│               │   │   └── [01;34mspec[0m
│               │   │       ├── [01;34mintegration[0m
│               │   │       │   └── ping_integration_test.rb
│               │   │       ├── [01;34mlib[0m
│               │   │       │   ├── [01;34mslack-notifier[0m
│               │   │       │   │   ├── [01;34mpayload_middleware[0m
│               │   │       │   │   │   ├── at_spec.rb
│               │   │       │   │   │   ├── base_spec.rb
│               │   │       │   │   │   ├── channels_spec.rb
│               │   │       │   │   │   ├── format_attachments_spec.rb
│               │   │       │   │   │   ├── format_message_spec.rb
│               │   │       │   │   │   └── stack_spec.rb
│               │   │       │   │   ├── [01;34mutil[0m
│               │   │       │   │   │   ├── http_client_spec.rb
│               │   │       │   │   │   └── link_formatter_spec.rb
│               │   │       │   │   ├── config_spec.rb
│               │   │       │   │   └── payload_middleware_spec.rb
│               │   │       │   └── slack-notifier_spec.rb
│               │   │       ├── end_to_end_spec.rb
│               │   │       └── spec_helper.rb
│               │   ├── [01;34msysrandom-1.0.5[0m
│               │   │   ├── [01;34mext[0m
│               │   │   │   └── [01;34msysrandom[0m
│               │   │   │       ├── extconf.rb
│               │   │   │       ├── Makefile
│               │   │   │       ├── randombytes_sysrandom.c
│               │   │   │       └── sysrandom_ext.c
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34msysrandom[0m
│               │   │   │   │   ├── securerandom.rb
│               │   │   │   │   └── version.rb
│               │   │   │   ├── [01;32msysrandom_ext.bundle[0m
│               │   │   │   └── sysrandom.rb
│               │   │   ├── CHANGES.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── sysrandom.gemspec
│               │   ├── [01;34mterminal-notifier-2.0.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── terminal-notifier.rb
│               │   │   ├── [01;34mvendor[0m
│               │   │   │   └── [01;34mterminal-notifier[0m
│               │   │   │       ├── [01;34massets[0m
│               │   │   │       │   ├── [01;35mExample_1.png[0m
│               │   │   │       │   ├── [01;35mExample_2.png[0m
│               │   │   │       │   ├── [01;35mExample_3.png[0m
│               │   │   │       │   ├── [01;35mExample_4.png[0m
│               │   │   │       │   ├── [01;35mExample_5.png[0m
│               │   │   │       │   └── [01;35mSystem_prefs.png[0m
│               │   │   │       ├── [01;34mRuby[0m
│               │   │   │       │   ├── [01;34mlib[0m
│               │   │   │       │   │   └── terminal-notifier.rb
│               │   │   │       │   ├── [01;34mspec[0m
│               │   │   │       │   │   └── terminal-notifier_spec.rb
│               │   │   │       │   ├── Gemfile
│               │   │   │       │   ├── Gemfile.lock
│               │   │   │       │   ├── LICENSE
│               │   │   │       │   ├── Rakefile
│               │   │   │       │   ├── README.markdown
│               │   │   │       │   └── terminal-notifier.gemspec
│               │   │   │       ├── [01;34mTerminal Notifier[0m
│               │   │   │       │   ├── [01;34men.lproj[0m
│               │   │   │       │   │   ├── Credits.rtf
│               │   │   │       │   │   ├── InfoPlist.strings
│               │   │   │       │   │   └── MainMenu.xib
│               │   │   │       │   ├── AppDelegate.h
│               │   │   │       │   ├── AppDelegate.m
│               │   │   │       │   ├── main.m
│               │   │   │       │   ├── Terminal Notifier-Info.plist
│               │   │   │       │   └── Terminal Notifier-Prefix.pch
│               │   │   │       ├── [01;34mTerminal Notifier.xcodeproj[0m
│               │   │   │       │   ├── [01;34mxcshareddata[0m
│               │   │   │       │   │   └── [01;34mxcschemes[0m
│               │   │   │       │   │       └── Terminal Notifier.xcscheme
│               │   │   │       │   └── project.pbxproj
│               │   │   │       ├── [01;34mterminal-notifier.app[0m
│               │   │   │       │   └── [01;34mContents[0m
│               │   │   │       │       ├── [01;34mMacOS[0m
│               │   │   │       │       │   └── [01;32mterminal-notifier[0m
│               │   │   │       │       ├── [01;34mResources[0m
│               │   │   │       │       │   ├── [01;34men.lproj[0m
│               │   │   │       │       │   │   ├── Credits.rtf
│               │   │   │       │       │   │   ├── InfoPlist.strings
│               │   │   │       │       │   │   └── MainMenu.nib
│               │   │   │       │       │   └── Terminal.icns
│               │   │   │       │       ├── Info.plist
│               │   │   │       │       └── PkgInfo
│               │   │   │       ├── LICENSE.md
│               │   │   │       ├── README.markdown
│               │   │   │       └── Terminal.icns
│               │   │   └── README.markdown
│               │   ├── [01;34mterminal-table-3.0.2[0m
│               │   │   ├── [01;34mexamples[0m
│               │   │   │   ├── data.csv
│               │   │   │   ├── [01;32mexamples_unicode.rb[0m
│               │   │   │   ├── [01;32mexamples.rb[0m
│               │   │   │   ├── [01;32missue100.rb[0m
│               │   │   │   ├── [01;32missue111.rb[0m
│               │   │   │   ├── [01;32missue118.rb[0m
│               │   │   │   ├── [01;32missue95.rb[0m
│               │   │   │   ├── [01;32mshow_csv_table.rb[0m
│               │   │   │   └── [01;32mstrong_separator.rb[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mterminal-table[0m
│               │   │   │   │   ├── cell.rb
│               │   │   │   │   ├── import.rb
│               │   │   │   │   ├── row.rb
│               │   │   │   │   ├── separator.rb
│               │   │   │   │   ├── style.rb
│               │   │   │   │   ├── table_helper.rb
│               │   │   │   │   ├── table.rb
│               │   │   │   │   ├── util.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── terminal-table.rb
│               │   │   ├── Gemfile
│               │   │   ├── History.rdoc
│               │   │   ├── LICENSE.txt
│               │   │   ├── Manifest
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   ├── terminal-table.gemspec
│               │   │   └── Todo.rdoc
│               │   ├── [01;34mtrailblazer-option-0.1.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mtrailblazer[0m
│               │   │   │   │   ├── [01;34moption[0m
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── option.rb
│               │   │   │   └── trailblazer-option.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── [01;34mdocs[0m
│               │   │   │   │   └── option_test.rb
│               │   │   │   ├── option_test.rb
│               │   │   │   └── test_helper.rb
│               │   │   ├── CHANGES.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── trailblazer-option.gemspec
│               │   ├── [01;34mtty-cursor-0.7.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mtty[0m
│               │   │   │   │   ├── [01;34mcursor[0m
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── cursor.rb
│               │   │   │   └── tty-cursor.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── README.md
│               │   ├── [01;34mtty-screen-0.8.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mtty[0m
│               │   │   │   │   ├── [01;34mscreen[0m
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── screen.rb
│               │   │   │   └── tty-screen.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── README.md
│               │   ├── [01;34mtty-spinner-0.9.3[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mtty[0m
│               │   │   │   │   ├── [01;34mspinner[0m
│               │   │   │   │   │   ├── formats.rb
│               │   │   │   │   │   ├── multi.rb
│               │   │   │   │   │   └── version.rb
│               │   │   │   │   └── spinner.rb
│               │   │   │   └── tty-spinner.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── LICENSE.txt
│               │   │   └── README.md
│               │   ├── [01;34muber-0.1.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34muber[0m
│               │   │   │   │   ├── builder.rb
│               │   │   │   │   ├── callable.rb
│               │   │   │   │   ├── delegates.rb
│               │   │   │   │   ├── inheritable_attr.rb
│               │   │   │   │   ├── option.rb
│               │   │   │   │   ├── options.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── uber.rb
│               │   │   ├── [01;34mtest[0m
│               │   │   │   ├── builder_test.rb
│               │   │   │   ├── builder-benchmark.rb
│               │   │   │   ├── delegates_test.rb
│               │   │   │   ├── inheritable_attr_test.rb
│               │   │   │   ├── inheritance_test.rb
│               │   │   │   ├── option_test.rb
│               │   │   │   ├── options_test.rb
│               │   │   │   ├── test_helper.rb
│               │   │   │   └── zeugs.rb
│               │   │   ├── CHANGES.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── uber.gemspec
│               │   ├── [01;34municode-display_width-2.6.0[0m
│               │   │   ├── [01;34mdata[0m
│               │   │   │   └── [01;31mdisplay_width.marshal.gz[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34municode[0m
│               │   │   │       ├── [01;34mdisplay_width[0m
│               │   │   │       │   ├── constants.rb
│               │   │   │       │   ├── index.rb
│               │   │   │       │   ├── no_string_ext.rb
│               │   │   │       │   └── string_ext.rb
│               │   │   │       └── display_width.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── MIT-LICENSE.txt
│               │   │   └── README.md
│               │   ├── [01;34mword_wrap-1.0.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mword_wrap[0m
│               │   │   │   │   ├── core_ext.rb
│               │   │   │   │   ├── version.rb
│               │   │   │   │   └── wrapper.rb
│               │   │   │   └── word_wrap.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── core_ext_spec.rb
│               │   │   │   └── ww_spec.rb
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── word_wrap.gemspec
│               │   ├── [01;34mxcode-install-2.8.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── [01;34mxcode[0m
│               │   │   │       ├── [01;34minstall[0m
│               │   │   │       │   ├── cleanup.rb
│               │   │   │       │   ├── cli.rb
│               │   │   │       │   ├── command.rb
│               │   │   │       │   ├── install.rb
│               │   │   │       │   ├── installed.rb
│               │   │   │       │   ├── list.rb
│               │   │   │       │   ├── select.rb
│               │   │   │       │   ├── selected.rb
│               │   │   │       │   ├── simulators.rb
│               │   │   │       │   ├── uninstall.rb
│               │   │   │       │   ├── update.rb
│               │   │   │       │   └── version.rb
│               │   │   │       └── install.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mfixtures[0m
│               │   │   │   │   ├── [01;34mdevcenter[0m
│               │   │   │   │   │   ├── xcode-20150414.html
│               │   │   │   │   │   ├── xcode-20150427.html
│               │   │   │   │   │   ├── xcode-20150508.html
│               │   │   │   │   │   ├── xcode-20150601.html
│               │   │   │   │   │   ├── xcode-20150608.html
│               │   │   │   │   │   ├── xcode-20150624.html
│               │   │   │   │   │   ├── xcode-20150909.html
│               │   │   │   │   │   ├── xcode-20160601.html
│               │   │   │   │   │   ├── xcode-20160705-alt.html
│               │   │   │   │   │   ├── xcode-20160705.html
│               │   │   │   │   │   ├── xcode-20160922.html
│               │   │   │   │   │   └── xcode-20161024.html
│               │   │   │   │   ├── hdiutil.plist
│               │   │   │   │   ├── mail-verify.html
│               │   │   │   │   ├── not_registered_as_developer.json
│               │   │   │   │   ├── xcode_63.json
│               │   │   │   │   ├── xcode.json
│               │   │   │   │   └── yolo.json
│               │   │   │   ├── cli_spec.rb
│               │   │   │   ├── curl_spec.rb
│               │   │   │   ├── install_spec.rb
│               │   │   │   ├── installed_spec.rb
│               │   │   │   ├── installer_spec.rb
│               │   │   │   ├── json_spec.rb
│               │   │   │   ├── list_spec.rb
│               │   │   │   ├── prerelease_spec.rb
│               │   │   │   ├── spec_helper.rb
│               │   │   │   └── uninstall_spec.rb
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   ├── XCODE_VERSION.md
│               │   │   └── xcode-install.gemspec
│               │   ├── [01;34mxcodeproj-1.27.0[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mxcodeproj[0m
│               │   │   │   │   ├── [01;34mcommand[0m
│               │   │   │   │   │   ├── config_dump.rb
│               │   │   │   │   │   ├── project_diff.rb
│               │   │   │   │   │   ├── show.rb
│               │   │   │   │   │   ├── sort.rb
│               │   │   │   │   │   └── target_diff.rb
│               │   │   │   │   ├── [01;34mconfig[0m
│               │   │   │   │   │   └── other_linker_flags_parser.rb
│               │   │   │   │   ├── [01;34mproject[0m
│               │   │   │   │   │   ├── [01;34mobject[0m
│               │   │   │   │   │   │   ├── [01;34mhelpers[0m
│               │   │   │   │   │   │   │   ├── build_settings_array_settings_by_object_version.rb
│               │   │   │   │   │   │   │   ├── file_references_factory.rb
│               │   │   │   │   │   │   │   └── groupable_helper.rb
│               │   │   │   │   │   │   ├── build_configuration.rb
│               │   │   │   │   │   │   ├── build_file.rb
│               │   │   │   │   │   │   ├── build_phase.rb
│               │   │   │   │   │   │   ├── build_rule.rb
│               │   │   │   │   │   │   ├── configuration_list.rb
│               │   │   │   │   │   │   ├── container_item_proxy.rb
│               │   │   │   │   │   │   ├── file_reference.rb
│               │   │   │   │   │   │   ├── file_system_synchronized_exception_set.rb
│               │   │   │   │   │   │   ├── file_system_synchronized_root_group.rb
│               │   │   │   │   │   │   ├── group.rb
│               │   │   │   │   │   │   ├── native_target.rb
│               │   │   │   │   │   │   ├── reference_proxy.rb
│               │   │   │   │   │   │   ├── root_object.rb
│               │   │   │   │   │   │   ├── swift_package_local_reference.rb
│               │   │   │   │   │   │   ├── swift_package_product_dependency.rb
│               │   │   │   │   │   │   ├── swift_package_remote_reference.rb
│               │   │   │   │   │   │   └── target_dependency.rb
│               │   │   │   │   │   ├── case_converter.rb
│               │   │   │   │   │   ├── object_attributes.rb
│               │   │   │   │   │   ├── object_dictionary.rb
│               │   │   │   │   │   ├── object_list.rb
│               │   │   │   │   │   ├── object.rb
│               │   │   │   │   │   ├── project_helper.rb
│               │   │   │   │   │   └── uuid_generator.rb
│               │   │   │   │   ├── [01;34mscheme[0m
│               │   │   │   │   │   ├── abstract_scheme_action.rb
│               │   │   │   │   │   ├── analyze_action.rb
│               │   │   │   │   │   ├── archive_action.rb
│               │   │   │   │   │   ├── build_action.rb
│               │   │   │   │   │   ├── buildable_product_runnable.rb
│               │   │   │   │   │   ├── buildable_reference.rb
│               │   │   │   │   │   ├── command_line_arguments.rb
│               │   │   │   │   │   ├── environment_variables.rb
│               │   │   │   │   │   ├── execution_action.rb
│               │   │   │   │   │   ├── launch_action.rb
│               │   │   │   │   │   ├── location_scenario_reference.rb
│               │   │   │   │   │   ├── macro_expansion.rb
│               │   │   │   │   │   ├── profile_action.rb
│               │   │   │   │   │   ├── remote_runnable.rb
│               │   │   │   │   │   ├── send_email_action_content.rb
│               │   │   │   │   │   ├── shell_script_action_content.rb
│               │   │   │   │   │   ├── test_action.rb
│               │   │   │   │   │   └── xml_element_wrapper.rb
│               │   │   │   │   ├── [01;34mworkspace[0m
│               │   │   │   │   │   ├── file_reference.rb
│               │   │   │   │   │   ├── group_reference.rb
│               │   │   │   │   │   └── reference.rb
│               │   │   │   │   ├── command.rb
│               │   │   │   │   ├── config.rb
│               │   │   │   │   ├── constants.rb
│               │   │   │   │   ├── differ.rb
│               │   │   │   │   ├── gem_version.rb
│               │   │   │   │   ├── helper.rb
│               │   │   │   │   ├── plist.rb
│               │   │   │   │   ├── project.rb
│               │   │   │   │   ├── scheme.rb
│               │   │   │   │   ├── user_interface.rb
│               │   │   │   │   ├── workspace.rb
│               │   │   │   │   └── xcodebuild_helper.rb
│               │   │   │   └── xcodeproj.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mxcov-1.8.1[0m
│               │   │   ├── [01;34massets[0m
│               │   │   │   ├── [01;34mimages[0m
│               │   │   │   │   ├── [01;35mfile_cpp.png[0m
│               │   │   │   │   ├── [01;35mfile_objc.png[0m
│               │   │   │   │   ├── [01;35mfile_swift.png[0m
│               │   │   │   │   └── [01;35mxcov_logo.png[0m
│               │   │   │   ├── [01;34mjavascripts[0m
│               │   │   │   │   ├── application.js
│               │   │   │   │   ├── bootstrap.min.js
│               │   │   │   │   ├── jquery.min.js
│               │   │   │   │   └── main.js
│               │   │   │   └── [01;34mstylesheets[0m
│               │   │   │       ├── application.css
│               │   │   │       ├── bootstrap.min.css
│               │   │   │       ├── main.css
│               │   │   │       └── opensans.css
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mxcov[0m
│               │   │   │   │   ├── [01;34mmodel[0m
│               │   │   │   │   │   ├── base.rb
│               │   │   │   │   │   ├── function.rb
│               │   │   │   │   │   ├── line.rb
│               │   │   │   │   │   ├── range.rb
│               │   │   │   │   │   ├── report.rb
│               │   │   │   │   │   ├── source.rb
│               │   │   │   │   │   └── target.rb
│               │   │   │   │   ├── [01;32mcommands_generator.rb[0m
│               │   │   │   │   ├── coveralls_handler.rb
│               │   │   │   │   ├── [01;32merror_handler.rb[0m
│               │   │   │   │   ├── ignore_handler.rb
│               │   │   │   │   ├── [01;32mmanager.rb[0m
│               │   │   │   │   ├── [01;32moptions.rb[0m
│               │   │   │   │   ├── project_extensions.rb
│               │   │   │   │   ├── [01;32mslack_poster.rb[0m
│               │   │   │   │   └── [01;32mversion.rb[0m
│               │   │   │   ├── [01;34mxcov-core[0m
│               │   │   │   │   └── version.rb
│               │   │   │   ├── xcov-core.rb
│               │   │   │   └── [01;32mxcov.rb[0m
│               │   │   ├── [01;34mviews[0m
│               │   │   │   ├── file.erb
│               │   │   │   ├── function.erb
│               │   │   │   ├── report.erb
│               │   │   │   └── target.erb
│               │   │   ├── [01;32mLICENSE[0m
│               │   │   └── [01;32mREADME.md[0m
│               │   ├── [01;34mxcpretty-0.4.1[0m
│               │   │   ├── [01;34massets[0m
│               │   │   │   └── report.html.erb
│               │   │   ├── [01;34mfeatures[0m
│               │   │   │   ├── [01;34massets[0m
│               │   │   │   │   ├── [01;35mapple_raw.png[0m
│               │   │   │   │   └── [01;35mRACCommandSpec_enabled_signal_should_send_YES_while_executing_is_YES.png[0m
│               │   │   │   ├── [01;34mfixtures[0m
│               │   │   │   ├── [01;34msteps[0m
│               │   │   │   │   ├── custom_reporter_steps.rb
│               │   │   │   │   ├── formatting_steps.rb
│               │   │   │   │   ├── html_steps.rb
│               │   │   │   │   ├── json_steps.rb
│               │   │   │   │   ├── junit_steps.rb
│               │   │   │   │   ├── report_steps.rb
│               │   │   │   │   └── xcpretty_steps.rb
│               │   │   │   ├── [01;34msupport[0m
│               │   │   │   │   └── env.rb
│               │   │   │   ├── custom_formatter.feature
│               │   │   │   ├── custom_reporter.feature
│               │   │   │   ├── html_report.feature
│               │   │   │   ├── json_compilation_database_report.feature
│               │   │   │   ├── junit_report.feature
│               │   │   │   ├── knock_format.feature
│               │   │   │   ├── simple_format.feature
│               │   │   │   ├── tap_format.feature
│               │   │   │   ├── test_format.feature
│               │   │   │   └── xcpretty.feature
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mxcpretty[0m
│               │   │   │   │   ├── [01;34mformatters[0m
│               │   │   │   │   │   ├── formatter.rb
│               │   │   │   │   │   ├── knock.rb
│               │   │   │   │   │   ├── rspec.rb
│               │   │   │   │   │   ├── simple.rb
│               │   │   │   │   │   └── tap.rb
│               │   │   │   │   ├── [01;34mreporters[0m
│               │   │   │   │   │   ├── html.rb
│               │   │   │   │   │   ├── json_compilation_database.rb
│               │   │   │   │   │   ├── junit.rb
│               │   │   │   │   │   └── reporter.rb
│               │   │   │   │   ├── ansi.rb
│               │   │   │   │   ├── parser.rb
│               │   │   │   │   ├── printer.rb
│               │   │   │   │   ├── snippet.rb
│               │   │   │   │   ├── syntax.rb
│               │   │   │   │   ├── term.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── xcpretty.rb
│               │   │   ├── [01;34mspec[0m
│               │   │   │   ├── [01;34mfixtures[0m
│               │   │   │   │   ├── constants.rb
│               │   │   │   │   ├── custom_formatter.rb
│               │   │   │   │   ├── custom_reporter.rb
│               │   │   │   │   ├── NSStringTests.m
│               │   │   │   │   ├── oneliner.m
│               │   │   │   │   ├── raw_kiwi_compilation_fail.txt
│               │   │   │   │   ├── raw_kiwi_fail.txt
│               │   │   │   │   └── raw_specta_fail.txt
│               │   │   │   ├── [01;34msupport[0m
│               │   │   │   │   └── [01;34mmatchers[0m
│               │   │   │   │       └── colors.rb
│               │   │   │   ├── [01;34mxcpretty[0m
│               │   │   │   │   ├── [01;34mformatters[0m
│               │   │   │   │   │   ├── formatter_spec.rb
│               │   │   │   │   │   ├── rspec_spec.rb
│               │   │   │   │   │   └── simple_spec.rb
│               │   │   │   │   ├── [01;34mreporters[0m
│               │   │   │   │   │   ├── junit_spec.rb
│               │   │   │   │   │   └── reporter_spec.rb
│               │   │   │   │   ├── ansi_spec.rb
│               │   │   │   │   ├── parser_spec.rb
│               │   │   │   │   ├── printer_spec.rb
│               │   │   │   │   ├── snippet_spec.rb
│               │   │   │   │   ├── syntax_spec.rb
│               │   │   │   │   └── term_spec.rb
│               │   │   │   └── spec_helper.rb
│               │   │   ├── CHANGELOG.md
│               │   │   ├── CONTRIBUTING.md
│               │   │   ├── Gemfile
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── xcpretty.gemspec
│               │   ├── [01;34mxcpretty-travis-formatter-1.0.1[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   └── travis_formatter.rb
│               │   │   ├── LICENSE
│               │   │   └── README.md
│               │   ├── [01;34mxcresult-0.2.2[0m
│               │   │   ├── [01;34mlib[0m
│               │   │   │   ├── [01;34mxcresult[0m
│               │   │   │   │   ├── models.rb
│               │   │   │   │   ├── parser.rb
│               │   │   │   │   └── version.rb
│               │   │   │   └── xcresult.rb
│               │   │   ├── Gemfile
│               │   │   ├── Gemfile.lock
│               │   │   ├── LICENSE.txt
│               │   │   ├── Rakefile
│               │   │   ├── README.md
│               │   │   └── xcresult.gemspec
│               │   └── [01;34mxctest_list-1.2.1[0m
│               │       └── [01;34mlib[0m
│               │           └── xctest_list.rb
│               ├── [01;34mplugins[0m
│               └── [01;34mspecifications[0m
│                   ├── addressable-2.8.7.gemspec
│                   ├── artifactory-3.0.17.gemspec
│                   ├── atomos-0.1.3.gemspec
│                   ├── aws-eventstream-1.4.0.gemspec
│                   ├── aws-partitions-1.1154.0.gemspec
│                   ├── aws-sdk-core-3.232.0.gemspec
│                   ├── aws-sdk-kms-1.112.0.gemspec
│                   ├── aws-sdk-s3-1.198.0.gemspec
│                   ├── aws-sigv4-1.12.1.gemspec
│                   ├── babosa-1.0.4.gemspec
│                   ├── badge-0.13.0.gemspec
│                   ├── base64-0.3.0.gemspec
│                   ├── bigdecimal-3.2.2.gemspec
│                   ├── CFPropertyList-3.0.7.gemspec
│                   ├── claide-1.1.0.gemspec
│                   ├── colored-1.2.gemspec
│                   ├── colored2-3.1.2.gemspec
│                   ├── colorize-1.1.0.gemspec
│                   ├── commander-4.6.0.gemspec
│                   ├── declarative-0.0.20.gemspec
│                   ├── digest-crc-0.7.0.gemspec
│                   ├── domain_name-0.6.20240107.gemspec
│                   ├── dotenv-2.8.1.gemspec
│                   ├── emoji_regex-3.2.3.gemspec
│                   ├── excon-0.112.0.gemspec
│                   ├── faraday_middleware-1.2.1.gemspec
│                   ├── faraday-1.10.4.gemspec
│                   ├── faraday-cookie_jar-0.0.7.gemspec
│                   ├── faraday-em_http-1.0.0.gemspec
│                   ├── faraday-em_synchrony-1.0.1.gemspec
│                   ├── faraday-excon-1.1.0.gemspec
│                   ├── faraday-httpclient-1.0.1.gemspec
│                   ├── faraday-multipart-1.1.1.gemspec
│                   ├── faraday-net_http_persistent-1.2.0.gemspec
│                   ├── faraday-net_http-1.0.2.gemspec
│                   ├── faraday-patron-1.0.0.gemspec
│                   ├── faraday-rack-1.0.0.gemspec
│                   ├── faraday-retry-1.0.3.gemspec
│                   ├── fastimage-2.4.0.gemspec
│                   ├── fastlane-2.228.0.gemspec
│                   ├── fastlane-plugin-appicon-0.16.0.gemspec
│                   ├── fastlane-plugin-badge-1.5.0.gemspec
│                   ├── fastlane-plugin-changelog-0.16.0.gemspec
│                   ├── fastlane-plugin-semantic_release-1.18.2.gemspec
│                   ├── fastlane-plugin-test_center-3.19.1.gemspec
│                   ├── fastlane-plugin-versioning-0.7.1.gemspec
│                   ├── fastlane-sirp-1.0.0.gemspec
│                   ├── gh_inspector-1.1.3.gemspec
│                   ├── google-apis-androidpublisher_v3-0.54.0.gemspec
│                   ├── google-apis-core-0.11.3.gemspec
│                   ├── google-apis-iamcredentials_v1-0.17.0.gemspec
│                   ├── google-apis-playcustomapp_v1-0.13.0.gemspec
│                   ├── google-apis-storage_v1-0.31.0.gemspec
│                   ├── google-cloud-core-1.8.0.gemspec
│                   ├── google-cloud-env-1.6.0.gemspec
│                   ├── google-cloud-errors-1.5.0.gemspec
│                   ├── google-cloud-storage-1.47.0.gemspec
│                   ├── googleauth-1.8.1.gemspec
│                   ├── highline-2.0.3.gemspec
│                   ├── http-cookie-1.0.8.gemspec
│                   ├── httpclient-2.9.0.gemspec
│                   ├── jmespath-1.6.2.gemspec
│                   ├── json-2.13.2.gemspec
│                   ├── jwt-2.10.2.gemspec
│                   ├── logger-1.7.0.gemspec
│                   ├── mini_magick-4.13.2.gemspec
│                   ├── mini_mime-1.1.5.gemspec
│                   ├── multi_json-1.17.0.gemspec
│                   ├── multipart-post-2.4.1.gemspec
│                   ├── mutex_m-0.3.0.gemspec
│                   ├── nanaimo-0.4.0.gemspec
│                   ├── naturally-2.3.0.gemspec
│                   ├── nkf-0.2.0.gemspec
│                   ├── optparse-0.6.0.gemspec
│                   ├── os-1.1.4.gemspec
│                   ├── plist-3.7.2.gemspec
│                   ├── public_suffix-6.0.2.gemspec
│                   ├── rake-13.3.0.gemspec
│                   ├── representable-3.2.0.gemspec
│                   ├── retriable-3.1.2.gemspec
│                   ├── rexml-3.4.2.gemspec
│                   ├── rouge-3.28.0.gemspec
│                   ├── ruby2_keywords-0.0.5.gemspec
│                   ├── rubyzip-2.4.1.gemspec
│                   ├── security-0.1.5.gemspec
│                   ├── signet-0.21.0.gemspec
│                   ├── simctl-1.6.10.gemspec
│                   ├── slack-notifier-2.4.0.gemspec
│                   ├── sysrandom-1.0.5.gemspec
│                   ├── terminal-notifier-2.0.0.gemspec
│                   ├── terminal-table-3.0.2.gemspec
│                   ├── trailblazer-option-0.1.2.gemspec
│                   ├── tty-cursor-0.7.1.gemspec
│                   ├── tty-screen-0.8.2.gemspec
│                   ├── tty-spinner-0.9.3.gemspec
│                   ├── uber-0.1.0.gemspec
│                   ├── unicode-display_width-2.6.0.gemspec
│                   ├── word_wrap-1.0.0.gemspec
│                   ├── xcode-install-2.8.1.gemspec
│                   ├── xcodeproj-1.27.0.gemspec
│                   ├── xcov-1.8.1.gemspec
│                   ├── xcpretty-0.4.1.gemspec
│                   ├── xcpretty-travis-formatter-1.0.1.gemspec
│                   ├── xcresult-0.2.2.gemspec
│                   └── xctest_list-1.2.1.gemspec
├── [01;32manalyze_architecture.sh[0m
├── APP_STORE_CONNECT_API.md
├── APP_STORE_SUBMISSION_GUIDE.md
├── APPLESCRIPT_IOS_SIMULATOR_NAVIGATION.md
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
├── BUILD_FIXES_COMPLETED.md
├── BUILD_INSTRUCTIONS.md
├── [01;32mbuild_ios.sh[0m
├── BUILD_OPTIMIZATION_FINAL_REPORT.md
├── BUILD_STATUS.md
├── build_with_swift6.sh
├── [01;32mbuild.sh[0m
├── [01;32mcheck_environment.sh[0m
├── CLAIM_PACKAGE_SUMMARY.md
├── CLAUDE.md
├── CLOUDKIT_MIGRATION_STRATEGY.md
├── COMPREHENSIVE_FORENSIC_AUDIT_REPORT.md
├── COMPREHENSIVE_INTEGRATION_AUDIT_REPORT.md
├── CONFIGURATION_ALIGNMENT_SUMMARY.md
├── CRITICAL_INCOMPLETE_FEATURES_AUDIT.md
├── CURRENT_CONTEXT.md
├── DECISIONS.md
├── dependencies.dot
├── [01;35mdependencies.png[0m
├── DEVELOPMENT_CHECKLIST.md
├── emergency_fix.sh
├── EMERGENCY_MODULARIZATION.md
├── ENTERPRISE_RUBY_XCODE_SYSTEM.md
├── EXPORT_COMPLIANCE.md
├── fastlane_plugins_recommendations.md
├── FINAL_COMPREHENSIVE_INTEGRATION_AUDIT.md
├── [01;32mfix_build.sh[0m
├── FOLLOW_UP_INTEGRATION_AUDIT_REPORT.md
├── Gemfile
├── Gemfile.lock
├── [01;32mgenerate_app_icons.sh[0m
├── GITHUB-CLEANUP-BATCH1-SUMMARY.md
├── HOT_RELOAD_AUDIT_REPORT.md
├── HOT_RELOAD_DOCUMENTATION.md
├── IOS_TELEMETRY_INTEGRATION.md
├── LICENSE
├── LINTING.md
├── Makefile
├── [01;32mmetrics.sh[0m
├── MODULARIZATION_PLAN.md
├── NEXT_STEPS.md
├── Observability.md
├── open_xcode.sh
├── package.json
├── Package.swift
├── PERFORMANCE_OPTIMIZATION_SUMMARY.md
├── PHASE2_COMPLETION_REPORT.md
├── pnpm-lock.yaml
├── PRIVACY_POLICY.md
├── [01;32mprocess_app_icon.sh[0m
├── PROJECT_CONTEXT.md
├── project-uitests.yml
├── project.yml
├── [01;32mquick_build.sh[0m
├── README.md
├── run_app_final.sh
├── run_app.sh
├── [01;32mrun_screenshots.sh[0m
├── SCREENSHOT_ARCHITECTURE.md
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
├── TRANSFORMATION_SUMMARY.md
├── TREE.md
├── UI_WIRING_INTEGRATION.md
├── ULTRA_METICULOUS_FOLLOW_UP_AUDIT.md
├── [01;32mupdate_tree.sh[0m
├── [01;32mupload_to_testflight.sh[0m
├── [01;32mvalidate-fixes.sh[0m
├── verify_build.sh
├── XCODE_FIX.md
├── XCODE_UI_TESTING_GUIDE.md
└── XCUIAutomation-Definitive-Documentation.md

1135 directories, 5547 files
```

_📁 Directories:  | 📄 Files: 
