//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation
// Purpose: Modal forms and input views for repair cost estimation
//

import SwiftUI

// MARK: - Add Repair Cost Form

public struct AddRepairCostView: View {
    @Binding var description: String
    @Binding var amount: String
    @Binding var category: String
    let categories: [String]
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        description: Binding<String>,
        amount: Binding<String>,
        category: Binding<String>,
        categories: [String],
        onSave: @escaping () -> Void
    ) {
        self._description = description
        self._amount = amount
        self._category = category
        self.categories = categories
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Repair Details") {
                    TextField("Description", text: $description)
                        .textInputAutocapitalization(.sentences)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section {
                    Button("Add Repair Cost") {
                        onSave()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
            .navigationTitle("Add Repair Cost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Add Additional Cost Form

public struct AddAdditionalCostView: View {
    @Binding var description: String
    @Binding var amount: String
    @Binding var type: CostEstimation.AdditionalCost.CostType
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        description: Binding<String>,
        amount: Binding<String>,
        type: Binding<CostEstimation.AdditionalCost.CostType>,
        onSave: @escaping () -> Void
    ) {
        self._description = description
        self._amount = amount
        self._type = type
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Cost Details") {
                    TextField("Description", text: $description)
                        .textInputAutocapitalization(.sentences)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Type", selection: $type) {
                        ForEach(CostEstimation.AdditionalCost.CostType.allCases, id: \.self) { costType in
                            HStack {
                                Image(systemName: costType.icon)
                                Text(costType.rawValue)
                            }
                            .tag(costType)
                        }
                    }
                }
                
                Section("Examples") {
                    Group {
                        switch type {
                        case .temporaryHousing:
                            Text("• Hotel stays during repairs")
                            Text("• Rental property costs")
                            Text("• Extended stay accommodations")
                        case .storage:
                            Text("• Storage unit rental")
                            Text("• Moving and packing services")
                            Text("• Climate-controlled storage")
                        case .transportation:
                            Text("• Rental car expenses")
                            Text("• Additional fuel costs")
                            Text("• Public transportation")
                        case .other:
                            Text("• Document replacement fees")
                            Text("• Emergency supplies")
                            Text("• Professional cleaning")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Add Additional Cost") {
                        onSave()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
            .navigationTitle("Add Additional Cost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Cost Estimation Help View

public struct CostEstimationHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Cost Estimation Guide")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Learn how to create accurate repair and replacement estimates")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Quick Assessment
                    helpSection(
                        title: "Quick Assessment",
                        icon: "speedometer",
                        color: .blue,
                        content: """
                        The quick assessment provides an instant damage estimate based on:
                        • Damage severity level
                        • Item's replacement value
                        • Typical impact percentages
                        
                        Use this as a starting point for your detailed estimate.
                        """
                    )
                    
                    // Replacement Cost
                    helpSection(
                        title: "Replacement Cost",
                        icon: "arrow.triangle.2.circlepath",
                        color: .purple,
                        content: """
                        Enter the current cost to replace the item with a similar model:
                        • Check manufacturer websites
                        • Compare retail prices
                        • Consider inflation from purchase date
                        • Account for improved features
                        """
                    )
                    
                    // Repair Costs
                    helpSection(
                        title: "Repair Costs",
                        icon: "wrench.and.screwdriver",
                        color: .orange,
                        content: """
                        Break down repair costs by category:
                        • Parts: Individual components needed
                        • Labor: Professional service hours
                        • Materials: Supplies and consumables
                        • Tools: Specialized equipment rental
                        """
                    )
                    
                    // Additional Costs
                    helpSection(
                        title: "Additional Costs",
                        icon: "plus.square",
                        color: .red,
                        content: """
                        Don't forget indirect costs:
                        • Temporary housing during repairs
                        • Storage for undamaged items
                        • Transportation and logistics
                        • Professional cleaning services
                        """
                    )
                    
                    // Professional Estimates
                    helpSection(
                        title: "Professional Estimates",
                        icon: "person.badge.shield.checkmark",
                        color: .green,
                        content: """
                        Consider professional estimates when:
                        • Total damage exceeds $1,000
                        • Structural damage is involved
                        • Specialized equipment is damaged
                        • Insurance claims are involved
                        """
                    )
                    
                    // Tips
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Pro Tips", systemImage: "lightbulb.fill")
                                .font(.headline)
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Take photos of all damage")
                                Text("• Save receipts for all expenses")
                                Text("• Get multiple quotes for major repairs")
                                Text("• Document all communication with contractors")
                                Text("• Consider depreciation for older items")
                                Text("• Factor in local labor rates")
                            }
                            .font(.body)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func helpSection(title: String, icon: String, color: Color, content: String) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}