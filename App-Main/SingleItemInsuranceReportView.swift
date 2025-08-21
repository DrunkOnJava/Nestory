//
// Layer: App
// Module: Reports
// Purpose: Generate insurance report for a single item
//

import SwiftData
import SwiftUI

struct SingleItemInsuranceReportView: View {
    let item: Item
    let insuranceReportService: InsuranceReportService
    @Environment(\.dismiss) private var dismiss

    @State private var isGenerating = false
    @State private var reportError: Error?
    @State private var showingError = false
    @State private var includePhotos = true
    @State private var includeReceipts = true
    @State private var includeSerialNumbers = true
    @State private var includePurchaseInfo = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    HStack {
                        AsyncImage(url: item.imageData.flatMap { UIImage(data: $0)?.pngData() }.flatMap { _ in nil }) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray),
                                )
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)

                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            if let description = item.itemDescription {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if let price = item.purchasePrice {
                                Text("\(item.currency) \(price)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }

                        Spacer()
                    }
                }

                Section("Report Options") {
                    Toggle("Include Photos", isOn: $includePhotos)
                    Toggle("Include Receipts", isOn: $includeReceipts)
                    Toggle("Include Serial Numbers", isOn: $includeSerialNumbers)
                    Toggle("Include Purchase Information", isOn: $includePurchaseInfo)
                }

                Section("Generate Report") {
                    Button(action: generateReport) {
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Generating Report...")
                            }
                        } else {
                            Label("Generate Insurance Report", systemImage: "doc.text")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isGenerating)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Insurance Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Report Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(reportError?.localizedDescription ?? "An error occurred while generating the report.")
        }
    }

    private func generateReport() {
        Task {
            isGenerating = true
            defer { isGenerating = false }

            do {
                var options = ReportOptions()
                options.includePhotos = includePhotos
                options.includeReceipts = includeReceipts
                options.includeDepreciation = false
                options.groupByRoom = false
                options.includeSerialNumbers = includeSerialNumbers
                options.includePurchaseInfo = includePurchaseInfo
                options.includeTotalValue = true

                // Generate report for single item
                let reportData = try await insuranceReportService.generateInsuranceReport(
                    items: [item],
                    categories: item.category.map { [$0] } ?? [],
                    options: options,
                )

                // Export and share the report
                let filename = "Insurance_Report_\(item.name.replacingOccurrences(of: " ", with: "_"))"
                let reportURL = try await insuranceReportService.exportReport(reportData, filename: filename)

                // Share the report
                await insuranceReportService.shareReport(reportURL)

                // Dismiss the view after successful generation
                dismiss()
            } catch {
                reportError = error
                showingError = true
            }
        }
    }
}

#Preview {
    let item = Item(name: "MacBook Pro", itemDescription: "14-inch MacBook Pro", quantity: 1)
    item.purchasePrice = 2499.00
    item.currency = "$"

    SingleItemInsuranceReportView(
        item: item,
        insuranceReportService: try! LiveInsuranceReportService(),
    )
    .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
