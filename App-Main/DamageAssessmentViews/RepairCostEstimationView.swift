//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation
// Purpose: Main coordinator view using modular components for repair cost estimation
//

import SwiftUI

// Re-export modular components for backward compatibility
// Modular components are automatically available within the same target
// RepairCostEstimationCore, RepairCostEstimationComponents, RepairCostEstimationForms included

struct RepairCostEstimationView: View {
    @Binding var assessment: DamageAssessment
    @StateObject private var core: RepairCostEstimationCore
    @Environment(\.dismiss) private var dismiss
    
    init(assessment: Binding<DamageAssessment>) {
        self._assessment = assessment
        self._core = StateObject(wrappedValue: RepairCostEstimationCore(assessment: assessment.wrappedValue))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    CostEstimationHeaderView()

                    // Quick Assessment Based on Severity
                    QuickAssessmentCard(
                        severity: assessment.severity,
                        damageType: assessment.damageType,
                        replacementCost: assessment.replacementCost
                    )

                    // Replacement Cost
                    ReplacementCostCard(
                        replacementCost: core.costEstimation.replacementCost,
                        onUpdate: { newCost in
                            core.updateReplacementCost(newCost)
                        }
                    )

                    // Repair Costs Breakdown
                    RepairCostsCard(
                        repairCosts: core.costEstimation.repairCosts,
                        totalCosts: core.totalRepairCosts,
                        onAdd: { core.showingAddRepairCost = true },
                        onRemove: core.removeRepairCost
                    )

                    // Additional Costs
                    AdditionalCostsCard(
                        additionalCosts: core.costEstimation.additionalCosts,
                        totalCosts: core.totalAdditionalCosts,
                        onAdd: { core.showingAddAdditionalCost = true },
                        onRemove: core.removeAdditionalCost
                    )

                    // Labor and Materials
                    LaborMaterialsCard(
                        laborHours: core.costEstimation.laborHours,
                        hourlyRate: core.costEstimation.hourlyRate,
                        materialsCost: core.costEstimation.materialsCost,
                        onLaborHoursUpdate: core.updateLaborHours,
                        onHourlyRateUpdate: core.updateLaborRate,
                        onMaterialsCostUpdate: core.updateMaterialsCost
                    )

                    // Cost Summary
                    CostSummaryCard(
                        costEstimation: core.costEstimation,
                        assessment: assessment
                    )

                    // Professional Estimate Recommendation
                    ProfessionalEstimateCard(
                        shouldRecommend: core.shouldRecommendProfessionalEstimate,
                        reason: core.professionalEstimateReason
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Cost Estimation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            core.showingCostHelper = true
                        }) {
                            Image(systemName: "questionmark.circle")
                        }

                        Button("Save") {
                            saveCostEstimation()
                        }
                        .fontWeight(.semibold)
                        .disabled(!core.canSaveCostEstimation())
                    }
                }
            }
        }
        .sheet(isPresented: $core.showingCostHelper) {
            CostEstimationHelpView()
        }
        .sheet(isPresented: $core.showingAddRepairCost) {
            AddRepairCostForm(
                description: $core.newRepairDescription,
                amount: $core.newRepairAmount,
                category: $core.newRepairCategory,
                categories: core.repairCategories,
                onSave: core.addRepairCost
            )
        }
        .sheet(isPresented: $core.showingAddAdditionalCost) {
            AddAdditionalCostForm(
                description: $core.newAdditionalDescription,
                amount: $core.newAdditionalAmount,
                type: $core.newAdditionalType,
                onSave: core.addAdditionalCost
            )
        }
        .onAppear {
            // Core handles initialization
        }
    }

    // MARK: - Actions

    private func saveCostEstimation() {
        assessment.repairEstimate = core.costEstimation.totalEstimate
        assessment.replacementCost = core.costEstimation.replacementCost
        dismiss()
    }
}

#Preview {
    RepairCostEstimationView(
        assessment: .constant(DamageAssessment(
            itemId: UUID(),
            damageType: .fire,
            severity: .moderate,
            incidentDescription: "Fire damage from kitchen incident"
        ))
    )
}