//
// Layer: App-Main
// Module: DamageAssessment/RepairCostEstimation/Cards
// Purpose: Labor and materials card wrapper component for repair cost estimation
//

import SwiftUI

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