//
// Layer: App-Main
// Module: ClaimPackageAssembly
// Purpose: Main coordinator view using modular components for claim package assembly
//

import SwiftUI
import SwiftData

// Re-export modular components for backward compatibility
@_exported import ClaimPackageAssemblyCore
@_exported import ClaimPackageAssemblySteps
@_exported import ClaimPackageAssemblyComponents

struct ClaimPackageAssemblyView: View {
    // MARK: - Dependencies

    @Query private var allItems: [Item]
    @Query private var allCategories: [Category]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var core = ClaimPackageAssemblyCore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                AssemblyProgressView(
                    currentStep: core.currentStep,
                    progress: core.progress
                )

                // Step content
                stepContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom action bar
                AssemblyActionBar(
                    currentStep: core.currentStep,
                    canProceed: core.canProceed,
                    isLastStep: core.isLastStep,
                    onPrevious: core.previousStep,
                    onNext: core.nextStep,
                    onFinish: { dismiss() }
                )
            }
            .navigationTitle("Claim Package Assembly")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        core.resetAssembly()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $core.showingScenarioSetup) {
            ClaimScenarioSetupView(scenario: $core.claimScenario)
        }
        .sheet(isPresented: $core.showingOptionsSetup) {
            ClaimPackageOptionsView(options: $core.packageOptions)
        }
        .sheet(isPresented: $core.showingExportOptions) {
            // Export options would be implemented here
            Text("Export Options")
        }
        .alert("Assembly Error", isPresented: Binding(
            get: { core.errorAlert != nil },
            set: { if !$0 { core.errorAlert = nil } }
        )) {
            Button("OK") { core.errorAlert = nil }
        } message: {
            Text(core.errorAlert?.message ?? "An error occurred")
        }
    }

    // MARK: - Step Content Views

    @ViewBuilder
    private var stepContentView: some View {
        switch core.currentStep {
        case .itemSelection:
            VStack(spacing: 16) {
                SelectionSummaryCard(
                    selectedItemCount: core.selectedItems.count,
                    totalValue: core.totalSelectedValue(from: allItems),
                    scenario: core.claimScenario
                )

                ItemSelectionStepView(
                    allItems: allItems,
                    selectedItems: core.selectedItems,
                    onToggleItem: core.toggleItemSelection,
                    onSelectAll: { core.selectAllItems(from: allItems) },
                    onClearAll: core.clearAllSelections
                )
            }

        case .scenarioSetup:
            ScenarioSetupStepView(
                scenario: $core.claimScenario,
                selectedItemCount: core.selectedItems.count,
                onAdvancedSetup: { core.showingScenarioSetup = true }
            )

        case .packageOptions:
            PackageOptionsStepView(
                options: $core.packageOptions,
                onAdvancedOptions: { core.showingOptionsSetup = true }
            )

        case .validation:
            ValidationStepView(
                selectedItems: core.selectedItemsList(from: allItems),
                scenario: core.claimScenario,
                options: core.packageOptions
            )

        case .assembly:
            AssemblyStepView(
                assemblyService: core.assemblerService,
                generatedPackage: core.generatedPackage,
                errorAlert: core.errorAlert
            )

        case .export:
            ExportStepView(
                generatedPackage: core.generatedPackage,
                onExportAction: core.exportPackage
            )
        }
    }
}

#Preview {
    ClaimPackageAssemblyView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}