//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Manage item warranty information
//

import SwiftUI

struct WarrantyManagementView: View {
    @Bindable var item: Item

    @State private var warrantyEnabled = false
    @State private var warrantyExpiration = Date()
    @State private var warrantyProvider = ""
    @State private var warrantyNotes = ""
    @State private var showingWarrantyAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Warranty Coverage", isOn: $warrantyEnabled)
                .tint(.green)

            if warrantyEnabled {
                GroupBox {
                    VStack(spacing: 12) {
                        DatePicker(
                            "Expiration Date",
                            selection: $warrantyExpiration,
                            in: Date()...,
                            displayedComponents: .date,
                        )

                        TextField("Warranty Provider", text: $warrantyProvider)
                            .textFieldStyle(.roundedBorder)

                        VStack(alignment: .leading) {
                            Text("Warranty Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $warrantyNotes)
                                .frame(minHeight: 80)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1),
                                )
                        }
                    }
                }

                // Warranty status display
                if let statusInfo = WarrantyStatusCalculator.calculate(expirationDate: warrantyExpiration) {
                    HStack {
                        Image(systemName: statusInfo.icon)
                            .foregroundColor(statusInfo.color)
                        Text(statusInfo.text)
                            .font(.caption)
                            .foregroundColor(statusInfo.color)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(statusInfo.color.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .alert("Warranty Expiring Soon", isPresented: $showingWarrantyAlert) {
            Button("OK") {}
        } message: {
            Text("This warranty expires in less than 30 days. You'll receive a notification reminder.")
        }
        .onAppear {
            loadExistingData()
        }
        .onChange(of: warrantyEnabled) { _, _ in saveChanges() }
        .onChange(of: warrantyExpiration) { _, _ in saveChanges() }
        .onChange(of: warrantyProvider) { _, _ in saveChanges() }
        .onChange(of: warrantyNotes) { _, _ in saveChanges() }
    }

    private func loadExistingData() {
        warrantyEnabled = item.warrantyExpirationDate != nil
        warrantyExpiration = item.warrantyExpirationDate ?? Date()
        warrantyProvider = item.warrantyProvider ?? ""
        warrantyNotes = item.warrantyNotes ?? ""
    }

    private func saveChanges() {
        if warrantyEnabled {
            item.warrantyExpirationDate = warrantyExpiration
            item.warrantyProvider = warrantyProvider.isEmpty ? nil : warrantyProvider
            item.warrantyNotes = warrantyNotes.isEmpty ? nil : warrantyNotes

            // Check if warranty is expiring soon
            if let statusInfo = WarrantyStatusCalculator.calculate(expirationDate: warrantyExpiration),
               statusInfo.daysRemaining < 30, statusInfo.daysRemaining >= 0
            {
                showingWarrantyAlert = true
            }
        } else {
            item.warrantyExpirationDate = nil
            item.warrantyProvider = nil
            item.warrantyNotes = nil
        }

        item.updatedAt = Date()
    }
}
