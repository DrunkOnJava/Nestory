//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation
// Purpose: Reusable UI components for repair cost estimation
//

import SwiftUI

// MARK: - Section Components

public struct QuickAssessmentSection: View {
    let assessment: DamageAssessment
    let quickDamageEstimate: Decimal?

    public init(assessment: DamageAssessment, quickDamageEstimate: Decimal?) {
        self.assessment = assessment
        self.quickDamageEstimate = quickDamageEstimate
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Quick Assessment", systemImage: "speedometer")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Damage Severity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(assessment.severity.rawValue)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: assessment.severity.color))
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Estimated Impact")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(assessment.severity.valueImpactPercentage * 100))%")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: assessment.severity.color))
                        }
                    }

                    if let estimatedDamage = quickDamageEstimate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Damage Estimate")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Text("$\(estimatedDamage.description)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: assessment.severity.color))

                                Text("(based on \(assessment.severity.rawValue.lowercased()) damage)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(hex: assessment.severity.color).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct ReplacementCostSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Replacement Cost", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 12) {
                    if let replacementCost = core.costEstimation.replacementCost {
                        HStack {
                            Text("Current replacement cost:")
                                .font(.body)
                            Spacer()
                            Text("$\(replacementCost.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }

                    HStack {
                        TextField("Enter replacement cost", text: Binding(
                            get: { core.costEstimation.replacementCost?.description ?? "" },
                            set: { core.updateReplacementCost($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                        Text("USD")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct RepairCostsSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Repair Costs", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Spacer()

                    Button(action: {
                        core.showingAddRepairCost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }

                if core.costEstimation.repairCosts.isEmpty {
                    Text("No repair costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(core.costEstimation.repairCosts) { repairCost in
                            RepairCostRow(repairCost: repairCost) {
                                core.removeRepairCost(repairCost)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Total Repair Costs")
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()

                            Text("$\(core.totalRepairCosts.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct AdditionalCostsSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Additional Costs", systemImage: "plus.square")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    Button(action: {
                        core.showingAddAdditionalCost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                }

                if core.costEstimation.additionalCosts.isEmpty {
                    Text("No additional costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(core.costEstimation.additionalCosts) { additionalCost in
                            AdditionalCostRow(additionalCost: additionalCost) {
                                core.removeAdditionalCost(additionalCost)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Total Additional Costs")
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()

                            Text("$\(core.totalAdditionalCosts.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct LaborMaterialsSection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Labor & Materials", systemImage: "person.2.square.stack")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    HStack {
                        Text("Labor Hours:")
                            .font(.body)

                        Spacer()

                        TextField("Hours", text: Binding(
                            get: { core.costEstimation.laborHours == 0 ? "" : core.costEstimation.laborHours.description },
                            set: { core.updateLaborHours($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    }

                    HStack {
                        Text("Hourly Rate:")
                            .font(.body)

                        Spacer()

                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("Rate", text: Binding(
                                get: { core.costEstimation.hourlyRate.description },
                                set: { core.updateLaborRate($0) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                        .frame(width: 100)
                    }

                    HStack {
                        Text("Materials Cost:")
                            .font(.body)

                        Spacer()

                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("Materials", text: Binding(
                                get: { core.costEstimation.materialsCost == 0 ? "" : core.costEstimation.materialsCost.description },
                                set: { core.updateMaterialsCost($0) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                        .frame(width: 100)
                    }

                    Divider()

                    HStack {
                        Text("Labor Cost:")
                            .font(.body)
                            .fontWeight(.medium)

                        Spacer()

                        Text("$\(core.costEstimation.laborCost.description)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct CostSummarySection: View {
    @ObservedObject var core: RepairCostEstimationCore

    public init(core: RepairCostEstimationCore) {
        self.core = core
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Cost Summary", systemImage: "doc.text.magnifyingglass")
                    .font(.headline)
                    .foregroundColor(.green)

                VStack(spacing: 8) {
                    HStack {
                        Text("Repair Costs:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.totalRepairCosts.description)")
                            .font(.body)
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Text("Additional Costs:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.totalAdditionalCosts.description)")
                            .font(.body)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Labor Cost:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.costEstimation.laborCost.description)")
                            .font(.body)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Materials:")
                            .font(.body)

                        Spacer()

                        Text("$\(core.costEstimation.materialsCost.description)")
                            .font(.body)
                            .foregroundColor(.purple)
                    }

                    Divider()

                    HStack {
                        Text("Total Estimate:")
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Text("$\(core.costEstimation.totalEstimate.description)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct ProfessionalEstimateSection: View {
    let shouldRecommend: Bool
    let reason: String

    public init(shouldRecommend: Bool, reason: String) {
        self.shouldRecommend = shouldRecommend
        self.reason = reason
    }

    public var body: some View {
        if shouldRecommend {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.badge.shield.checkmark")
                            .foregroundColor(.orange)

                        Text("Professional Estimate Recommended")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }

                    Text(reason)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Consider getting quotes from licensed contractors for more accurate estimates.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Card Components (Wrappers for RepairCostEstimationView)

public struct QuickAssessmentCard: View {
    let severity: DamageSeverity
    let damageType: DamageType
    let replacementCost: Decimal?
    
    public init(severity: DamageSeverity, damageType: DamageType, replacementCost: Decimal?) {
        self.severity = severity
        self.damageType = damageType
        self.replacementCost = replacementCost
    }
    
    public var body: some View {
        let assessment = DamageAssessment(
            itemId: UUID(),
            damageType: damageType,
            severity: severity,
            incidentDescription: ""
        )
        let quickEstimate = replacementCost.map { $0 * Decimal(severity.valueImpactPercentage) }
        
        QuickAssessmentSection(assessment: assessment, quickDamageEstimate: quickEstimate)
    }
}

public struct ReplacementCostCard: View {
    let replacementCost: Decimal?
    let onUpdate: (String) -> Void
    
    public init(replacementCost: Decimal?, onUpdate: @escaping (String) -> Void) {
        self.replacementCost = replacementCost
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Replacement Cost", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 12) {
                    if let replacementCost = replacementCost {
                        HStack {
                            Text("Current replacement cost:")
                                .font(.body)
                            Spacer()
                            Text("$\(replacementCost.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    HStack {
                        TextField("Enter replacement cost", text: Binding(
                            get: { replacementCost?.description ?? "" },
                            set: { onUpdate($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        
                        Text("USD")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct RepairCostsCard: View {
    let repairCosts: [CostEstimation.RepairCost]
    let totalCosts: Decimal
    let onAdd: () -> Void
    let onRemove: (CostEstimation.RepairCost) -> Void
    
    public init(
        repairCosts: [CostEstimation.RepairCost],
        totalCosts: Decimal,
        onAdd: @escaping () -> Void,
        onRemove: @escaping (CostEstimation.RepairCost) -> Void
    ) {
        self.repairCosts = repairCosts
        self.totalCosts = totalCosts
        self.onAdd = onAdd
        self.onRemove = onRemove
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Repair Costs", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                if repairCosts.isEmpty {
                    Text("No repair costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(repairCosts) { repairCost in
                            RepairCostRow(repairCost: repairCost) {
                                onRemove(repairCost)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Repair Costs")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("$\(totalCosts.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct AdditionalCostsCard: View {
    let additionalCosts: [CostEstimation.AdditionalCost]
    let totalCosts: Decimal
    let onAdd: () -> Void
    let onRemove: (CostEstimation.AdditionalCost) -> Void
    
    public init(
        additionalCosts: [CostEstimation.AdditionalCost],
        totalCosts: Decimal,
        onAdd: @escaping () -> Void,
        onRemove: @escaping (CostEstimation.AdditionalCost) -> Void
    ) {
        self.additionalCosts = additionalCosts
        self.totalCosts = totalCosts
        self.onAdd = onAdd
        self.onRemove = onRemove
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Additional Costs", systemImage: "plus.square")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                if additionalCosts.isEmpty {
                    Text("No additional costs added yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(additionalCosts) { additionalCost in
                            AdditionalCostRow(additionalCost: additionalCost) {
                                onRemove(additionalCost)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Additional Costs")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("$\(totalCosts.description)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct LaborMaterialsCard: View {
    let laborHours: Decimal
    let hourlyRate: Decimal
    let materialsCost: Decimal
    let onLaborHoursUpdate: (String) -> Void
    let onHourlyRateUpdate: (String) -> Void
    let onMaterialsCostUpdate: (String) -> Void
    
    public init(
        laborHours: Decimal,
        hourlyRate: Decimal,
        materialsCost: Decimal,
        onLaborHoursUpdate: @escaping (String) -> Void,
        onHourlyRateUpdate: @escaping (String) -> Void,
        onMaterialsCostUpdate: @escaping (String) -> Void
    ) {
        self.laborHours = laborHours
        self.hourlyRate = hourlyRate
        self.materialsCost = materialsCost
        self.onLaborHoursUpdate = onLaborHoursUpdate
        self.onHourlyRateUpdate = onHourlyRateUpdate
        self.onMaterialsCostUpdate = onMaterialsCostUpdate
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Labor & Materials", systemImage: "person.2.square.stack")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Labor Hours:")
                            .font(.body)
                        
                        Spacer()
                        
                        TextField("Hours", text: Binding(
                            get: { laborHours == 0 ? "" : laborHours.description },
                            set: { onLaborHoursUpdate($0) }
                        ))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Hourly Rate:")
                            .font(.body)
                        
                        Spacer()
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("Rate", text: Binding(
                                get: { hourlyRate.description },
                                set: { onHourlyRateUpdate($0) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                        .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Materials Cost:")
                            .font(.body)
                        
                        Spacer()
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("Materials", text: Binding(
                                get: { materialsCost == 0 ? "" : materialsCost.description },
                                set: { onMaterialsCostUpdate($0) }
                            ))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        }
                        .frame(width: 100)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Labor Cost:")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("$\((laborHours * hourlyRate).description)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct CostSummaryCard: View {
    let costEstimation: CostEstimation
    let assessment: DamageAssessment
    
    public init(costEstimation: CostEstimation, assessment: DamageAssessment) {
        self.costEstimation = costEstimation
        self.assessment = assessment
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Label("Cost Summary", systemImage: "doc.text.magnifyingglass")
                    .font(.headline)
                    .foregroundColor(.green)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Repair Costs:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.totalRepairCosts.description)")
                            .font(.body)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Additional Costs:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.totalAdditionalCosts.description)")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Labor Cost:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.laborCost.description)")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Materials:")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.materialsCost.description)")
                            .font(.body)
                            .foregroundColor(.purple)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total Estimate:")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("$\(costEstimation.totalEstimate.description)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct ProfessionalEstimateCard: View {
    let shouldRecommend: Bool
    let reason: String
    
    public init(shouldRecommend: Bool, reason: String) {
        self.shouldRecommend = shouldRecommend
        self.reason = reason
    }
    
    public var body: some View {
        if shouldRecommend {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.badge.shield.checkmark")
                            .foregroundColor(.orange)
                        
                        Text("Professional Estimate Recommended")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    Text(reason)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Consider getting quotes from licensed contractors for more accurate estimates.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Helper Views

public struct CostEstimationHeaderView: View {
    public init() {}
    
    public var body: some View {
        GroupBox {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Repair Cost Estimation")
                        .font(.headline)
                    Text("Estimate costs for insurance claims")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}


// MARK: - Row Components

public struct RepairCostRow: View {
    let repairCost: CostEstimation.RepairCost
    let onDelete: () -> Void

    public init(repairCost: CostEstimation.RepairCost, onDelete: @escaping () -> Void) {
        self.repairCost = repairCost
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(repairCost.description)
                    .font(.body)
                    .fontWeight(.medium)

                Text(repairCost.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Text("$\(repairCost.amount.description)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

public struct AdditionalCostRow: View {
    let additionalCost: CostEstimation.AdditionalCost
    let onDelete: () -> Void

    public init(additionalCost: CostEstimation.AdditionalCost, onDelete: @escaping () -> Void) {
        self.additionalCost = additionalCost
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: additionalCost.type.icon)
                    .foregroundColor(.red)
                    .font(.caption)

                VStack(alignment: .leading, spacing: 2) {
                    Text(additionalCost.description)
                        .font(.body)
                        .fontWeight(.medium)

                    Text(additionalCost.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Text("$\(additionalCost.amount.description)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
