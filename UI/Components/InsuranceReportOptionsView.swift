//
// Layer: UI
// Module: Components
// Purpose: Insurance report options view for configuring report generation
//

import os.log
import SwiftUI

public struct InsuranceReportOptionsView: View {
    let items: [Item]
    let categories: [Category]
    let insuranceReportService: InsuranceReportService
    @Binding var isGenerating: Bool
    @Environment(\.dismiss) private var dismiss
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev", category: "InsuranceReportUI")

    @State private var includePhotos = true
    @State private var includeReceipts = true
    @State private var includeDepreciation = false
    @State private var groupByRoom = true
    @State private var includeSerialNumbers = true
    @State private var includePurchaseInfo = true
    @State private var includeTotalValue = true
    @State private var propertyAddress = ""
    @State private var policyNumber = ""

    public init(items: [Item], categories: [Category], insuranceReportService: InsuranceReportService, isGenerating: Binding<Bool>) {
        self.items = items
        self.categories = categories
        self.insuranceReportService = insuranceReportService
        _isGenerating = isGenerating
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Report Options") {
                    Toggle("Include Photos", isOn: $includePhotos)
                    Toggle("Include Receipts", isOn: $includeReceipts)
                    Toggle("Include Purchase Information", isOn: $includePurchaseInfo)
                    Toggle("Include Serial Numbers", isOn: $includeSerialNumbers)
                    Toggle("Show Total Value", isOn: $includeTotalValue)
                    Toggle("Group by Room/Category", isOn: $groupByRoom)
                    Toggle("Calculate Depreciation", isOn: $includeDepreciation)
                }

                Section("Policy Information (Optional)") {
                    TextField("Property Address", text: $propertyAddress)
                        .textContentType(.fullStreetAddress)

                    TextField("Policy Number", text: $policyNumber)
                        .textContentType(.none)
                }

                Section("Report Details") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text(formatTotalValue())
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Items with Photos")
                        Spacer()
                        Text("\(items.count { $0.imageData != nil })")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Items with Serial Numbers")
                        Spacer()
                        Text("\(items.count { $0.serialNumber != nil })")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(action: generateReport) {
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Generating Report...")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Generate Report")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isGenerating)
                }
            }
            .navigationTitle("Insurance Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func formatTotalValue() -> String {
        let total = items.compactMap(\.purchasePrice).reduce(0, +)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: total as NSNumber) ?? "$0"
    }

    @MainActor
    private func generateReport() {
        isGenerating = true

        Task {
            do {
                let options = InsuranceReportService.ReportOptions()
                // Configure options based on toggles
                var mutableOptions = options
                mutableOptions.includePhotos = includePhotos
                mutableOptions.includeReceipts = includeReceipts
                mutableOptions.includeDepreciation = includeDepreciation
                mutableOptions.groupByRoom = groupByRoom
                mutableOptions.includeSerialNumbers = includeSerialNumbers
                mutableOptions.includePurchaseInfo = includePurchaseInfo
                mutableOptions.includeTotalValue = includeTotalValue

                // Generate the PDF
                let pdfData = try await insuranceReportService.generateInsuranceReport(
                    items: items,
                    categories: categories,
                    options: mutableOptions,
                )

                // Export and share
                let url = try await insuranceReportService.exportReport(pdfData)
                await insuranceReportService.shareReport(url)

                isGenerating = false
                dismiss()
            } catch {
                isGenerating = false
                // Handle error - in production would show alert
                logger.error("Report generation failed: \(error)")
            }
        }
    }
}

#Preview {
    InsuranceReportOptionsView(
        items: [],
        categories: [],
        insuranceReportService: InsuranceReportService(),
        isGenerating: .constant(false),
    )
}
