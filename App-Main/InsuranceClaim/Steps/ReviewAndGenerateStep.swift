//
// Layer: App-Main
// Module: InsuranceClaim/Steps
// Purpose: Final review step with claim generation and preview
//

import SwiftUI

public struct ReviewAndGenerateStep: View {
    public let items: [Item]
    public let selectedClaimType: ClaimType
    public let selectedCompany: InsuranceCompany
    public let incidentDate: Date
    public let validationIssues: [String]?
    public let estimatedValue: Decimal
    public let generatedClaim: GeneratedClaim?
    public let isGenerating: Bool
    public let onGenerateClaim: () -> Void
    public let onShowPreview: () -> Void
    public let onShowExport: () -> Void
    
    public init(
        items: [Item],
        selectedClaimType: ClaimType,
        selectedCompany: InsuranceCompany,
        incidentDate: Date,
        validationIssues: [String]?,
        estimatedValue: Decimal,
        generatedClaim: GeneratedClaim?,
        isGenerating: Bool,
        onGenerateClaim: @escaping () -> Void,
        onShowPreview: @escaping () -> Void,
        onShowExport: @escaping () -> Void
    ) {
        self.items = items
        self.selectedClaimType = selectedClaimType
        self.selectedCompany = selectedCompany
        self.incidentDate = incidentDate
        self.validationIssues = validationIssues
        self.estimatedValue = estimatedValue
        self.generatedClaim = generatedClaim
        self.isGenerating = isGenerating
        self.onGenerateClaim = onGenerateClaim
        self.onShowPreview = onShowPreview
        self.onShowExport = onShowExport
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 4: Review & Generate")
                .font(.title2)
                .fontWeight(.bold)

            if let validationIssues = validationIssues, !validationIssues.isEmpty {
                GroupBox("⚠️ Documentation Issues") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The following items have missing documentation:")
                            .font(.caption)
                            .foregroundColor(.orange)

                        ForEach(validationIssues, id: \.self) { issue in
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text(issue)
                                    .font(.caption)
                                Spacer()
                            }
                        }

                        Text("Claims may be processed faster with complete documentation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }

            // Summary
            GroupBox("Claim Summary") {
                VStack(alignment: .leading, spacing: 12) {
                    SummaryRow(label: "Claim Type", value: selectedClaimType.rawValue)
                    SummaryRow(label: "Insurance Company", value: selectedCompany.rawValue)
                    SummaryRow(label: "Incident Date", value: formatDate(incidentDate))
                    SummaryRow(label: "Items Count", value: "\(items.count)")
                    SummaryRow(label: "Estimated Value", value: formatCurrency(estimatedValue))
                }
            }

            // Items preview
            GroupBox("Claimed Items") {
                LazyVStack(spacing: 8) {
                    ForEach(items.prefix(5), id: \.id) { item in
                        HStack {
                            AsyncImage(url: nil) { _ in
                                if let imageData = item.imageData,
                                   let uiImage = UIImage(data: imageData)
                                {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipped()
                                        .cornerRadius(6)
                                } else {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        )
                                }
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }

                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                if let price = item.purchasePrice {
                                    Text(formatCurrency(price))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Text(item.itemCondition.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }

                    if items.count > 5 {
                        Text("... and \(items.count - 5) more items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if isGenerating {
                ProgressView("Generating claim document...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            if generatedClaim != nil {
                GroupBox("Generated Claim") {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Claim document generated successfully!")
                                .fontWeight(.medium)
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            Button("Preview") {
                                onShowPreview()
                            }
                            .buttonStyle(.bordered)

                            Button("Export & Share") {
                                onShowExport()
                            }
                            .buttonStyle(.borderedProminent)

                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
    }
}

#Preview {
    ReviewAndGenerateStepPreview()
}

private struct ReviewAndGenerateStepPreview: View {
    var body: some View {
        let item = Item(name: "Test Item", itemDescription: "Test item", quantity: 1)
        item.purchasePrice = 100.00
        
        return ReviewAndGenerateStep(
            items: [item],
            selectedClaimType: .fire,
            selectedCompany: .aaa,
            incidentDate: Date(),
            validationIssues: ["Missing receipt for Test Item"],
            estimatedValue: 100.00,
            generatedClaim: nil,
            isGenerating: false,
            onGenerateClaim: {},
            onShowPreview: {},
            onShowExport: {}
        )
        .padding()
    }
}