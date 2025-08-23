//
// Layer: App-Main
// Module: DamageAssessment/DamageSeverityAssessment/Sections
// Purpose: Repairability assessment with conditional repair time input
//

import SwiftUI

public struct RepairabilitySection: View {
    let selectedSeverity: DamageSeverity
    @Binding var isRepairable: Bool
    @Binding var estimatedRepairTime: String
    @Binding var showingRepairabilityHelp: Bool
    
    public init(
        selectedSeverity: DamageSeverity,
        isRepairable: Binding<Bool>,
        estimatedRepairTime: Binding<String>,
        showingRepairabilityHelp: Binding<Bool>
    ) {
        self.selectedSeverity = selectedSeverity
        self._isRepairable = isRepairable
        self._estimatedRepairTime = estimatedRepairTime
        self._showingRepairabilityHelp = showingRepairabilityHelp
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Repairability Assessment", systemImage: "wrench.and.screwdriver")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Spacer()

                    Button(action: {
                        showingRepairabilityHelp = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                    }
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("Can this item be repaired?")
                            .font(.body)

                        Spacer()

                        Picker("Repairability", selection: $isRepairable) {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }

                    if isRepairable {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estimated Repair Time")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("e.g., 2-3 weeks", text: $estimatedRepairTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        RepairabilityGuide(severity: selectedSeverity)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Item requires replacement")
                                    .font(.body)
                                    .foregroundColor(.red)
                            }

                            Text("Total loss - repair not economically viable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}