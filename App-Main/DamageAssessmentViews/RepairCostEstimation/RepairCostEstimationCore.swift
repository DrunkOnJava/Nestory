//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation
// Purpose: Core state management and business logic for repair cost estimation
//

import SwiftUI
import Foundation

// MARK: - Core State Management

@MainActor
public final class RepairCostEstimationCore: ObservableObject {
    // MARK: - Published Properties

    @Published public var costEstimation = CostEstimation()
    @Published public var showingCostHelper = false
    @Published public var showingAddRepairCost = false
    @Published public var showingAddAdditionalCost = false

    // Form State
    @Published public var newRepairDescription = ""
    @Published public var newRepairAmount = ""
    @Published public var newRepairCategory = "Repair"
    @Published public var newAdditionalDescription = ""
    @Published public var newAdditionalAmount = ""
    @Published public var newAdditionalType: CostEstimation.AdditionalCost.CostType = .other

    // MARK: - Constants

    public let repairCategories = ["Parts", "Labor", "Materials", "Tools", "Professional Services", "Other"]

    // MARK: - Dependencies

    private let assessment: DamageAssessment

    // MARK: - Initialization

    public init(assessment: DamageAssessment) {
        self.assessment = assessment
        initializeCostEstimation()
    }

    // MARK: - Computed Properties

    public var totalRepairCosts: Decimal {
        costEstimation.repairCosts.reduce(0) { $0 + $1.amount }
    }

    public var totalAdditionalCosts: Decimal {
        costEstimation.additionalCosts.reduce(0) { $0 + $1.amount }
    }

    public var shouldRecommendProfessionalEstimate: Bool {
        costEstimation.totalEstimate > 1000 ||
            assessment.severity == .major ||
            assessment.severity == .total ||
            assessment.damageType == .fire ||
            assessment.damageType == .naturalDisaster
    }

    public var professionalEstimateReason: String {
        if costEstimation.totalEstimate > 1000 {
            "High-value repairs benefit from professional estimates"
        } else if assessment.severity == .major || assessment.severity == .total {
            "Extensive damage requires professional evaluation"
        } else {
            "Complex damage types need specialist assessment"
        }
    }

    // MARK: - Initialization

    private func initializeCostEstimation() {
        costEstimation.replacementCost = assessment.replacementCost
    }

    // MARK: - Repair Cost Management

    public func addRepairCost() {
        guard let amount = Decimal(string: newRepairAmount), !newRepairDescription.isEmpty else { return }

        let repairCost = CostEstimation.RepairCost(
            description: newRepairDescription,
            amount: amount,
            category: newRepairCategory
        )

        costEstimation.repairCosts.append(repairCost)

        // Reset form
        resetRepairCostForm()
        showingAddRepairCost = false
    }

    public func removeRepairCost(_ repairCost: CostEstimation.RepairCost) {
        costEstimation.repairCosts.removeAll { $0.id == repairCost.id }
    }

    private func resetRepairCostForm() {
        newRepairDescription = ""
        newRepairAmount = ""
        newRepairCategory = "Repair"
    }

    // MARK: - Additional Cost Management

    public func addAdditionalCost() {
        guard let amount = Decimal(string: newAdditionalAmount), !newAdditionalDescription.isEmpty else { return }

        let additionalCost = CostEstimation.AdditionalCost(
            description: newAdditionalDescription,
            amount: amount,
            type: newAdditionalType
        )

        costEstimation.additionalCosts.append(additionalCost)

        // Reset form
        resetAdditionalCostForm()
        showingAddAdditionalCost = false
    }

    public func removeAdditionalCost(_ additionalCost: CostEstimation.AdditionalCost) {
        costEstimation.additionalCosts.removeAll { $0.id == additionalCost.id }
    }

    private func resetAdditionalCostForm() {
        newAdditionalDescription = ""
        newAdditionalAmount = ""
        newAdditionalType = .other
    }

    // MARK: - Labor and Materials

    public func updateLaborHours(_ hours: String) {
        if let hoursDecimal = Decimal(string: hours) {
            costEstimation.laborHours = hoursDecimal
        }
    }

    public func updateLaborRate(_ rate: String) {
        if let rateDecimal = Decimal(string: rate) {
            costEstimation.hourlyRate = rateDecimal
        }
    }

    public func updateMaterialsCost(_ cost: String) {
        if let costDecimal = Decimal(string: cost) {
            costEstimation.materialsCost = costDecimal
        }
    }

    public func updateReplacementCost(_ cost: String) {
        if let costDecimal = Decimal(string: cost) {
            costEstimation.replacementCost = costDecimal
        }
    }

    // MARK: - Quick Assessment

    public func getQuickDamageEstimate() -> Decimal? {
        guard let originalValue = assessment.replacementCost else { return nil }
        return originalValue * Decimal(assessment.severity.valueImpactPercentage)
    }

    // MARK: - Validation

    public func canSaveCostEstimation() -> Bool {
        costEstimation.totalEstimate > 0 || costEstimation.replacementCost != nil
    }

    // MARK: - Reset

    public func reset() {
        costEstimation = CostEstimation()
        showingCostHelper = false
        showingAddRepairCost = false
        showingAddAdditionalCost = false
        resetRepairCostForm()
        resetAdditionalCostForm()
        initializeCostEstimation()
    }
}

// MARK: - Cost Estimation Model

// Note: CostEstimation is now defined in Foundation/Models/CostEstimation.swift
