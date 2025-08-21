//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking
// Purpose: Modal sheet views for warranty tracking workflows
//

import SwiftUI

// MARK: - Auto-Detection Results Sheet

public struct AutoDetectResultSheet: View {
    let detectionResult: WarrantyDetectionResult
    let onAccept: () -> Void
    let onReject: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(
        detectionResult: WarrantyDetectionResult,
        onAccept: @escaping () -> Void,
        onReject: @escaping () -> Void
    ) {
        self.detectionResult = detectionResult
        self.onAccept = onAccept
        self.onReject = onReject
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Warranty Detected")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("We found warranty information for this item")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Detection Results
                    detectedInfoCard
                    
                    // Confidence and Source
                    confidenceCard
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Auto-Detection Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onReject()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var detectedInfoCard: some View {
        GroupBox("Detected Warranty Information") {
            VStack(spacing: 12) {
                InfoRow(label: "Provider", value: detectionResult.suggestedProvider)
                
                InfoRow(label: "Duration", value: "\(detectionResult.suggestedDuration) months")
                
                InfoRow(label: "Confidence", value: String(format: "%.1f%%", detectionResult.confidence * 100))
                
                if let extractedText = detectionResult.extractedText {
                    InfoRow(label: "Source", value: extractedText)
                }
                
                // Note: Registration info not available in current detection result
                if false { // Placeholder for registration logic
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Registration Required")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                }
                
                if let terms = detectionResult.terms, !terms.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Warranty Terms:")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text(terms)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var confidenceCard: some View {
        GroupBox("Detection Quality") {
            VStack(spacing: 8) {
                HStack {
                    Text("Confidence")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int(detectionResult.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(confidenceColor)
                }
                
                ProgressView(value: detectionResult.confidence)
                    .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor))
                
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Source: \(detectionResult.extractedText ?? "Database lookup")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                onAccept()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Accept & Apply Warranty")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                onReject()
                dismiss()
            }) {
                Text("Decline")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var confidenceColor: Color {
        if detectionResult.confidence >= 0.8 {
            return .green
        } else if detectionResult.confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Manual Warranty Form Sheet

public struct ManualWarrantyFormSheet: View {
    @Binding var item: Item
    @Environment(\.dismiss) private var dismiss
    
    @State private var warrantyType: WarrantyType = .manufacturer
    @State private var provider = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var terms = ""
    @State private var registrationRequired = false
    @State private var isRegistered = false
    
    public init(item: Binding<Item>) {
        self._item = item
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    Picker("Warranty Type", selection: $warrantyType) {
                        ForEach(WarrantyType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    TextField("Provider/Company", text: $provider)
                }
                
                Section(header: Text("Coverage Period")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    
                    if endDate <= startDate {
                        Label("End date must be after start date", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Toggle("Registration Required", isOn: $registrationRequired)
                    
                    if registrationRequired {
                        Toggle("Already Registered", isOn: $isRegistered)
                    }
                    
                    TextField("Terms and Conditions", text: $terms, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Additional Details")
                } footer: {
                    Text("Enter any specific warranty terms, coverage limitations, or important notes.")
                }
            }
            .navigationTitle("Add Warranty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWarranty()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !provider.isEmpty && endDate > startDate
    }
    
    private func saveWarranty() {
        let warranty = Warranty(
            provider: provider.isEmpty ? "Unknown" : provider,
            type: warrantyType,
            startDate: startDate,
            expiresAt: endDate,
            item: item
        )
        
        // Note: Additional properties like terms and registration not available in current Warranty model
        if !terms.isEmpty {
            warranty.coverageNotes = terms
        }
        
        item.warranty = warranty
        dismiss()
    }
}

// MARK: - Warranty Extension Options Sheet

public struct WarrantyExtensionSheet: View {
    let currentWarranty: Warranty
    let onExtensionPurchased: (WarrantyExtension) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedExtension: WarrantyExtension?
    
    public init(
        currentWarranty: Warranty,
        onExtensionPurchased: @escaping (WarrantyExtension) -> Void
    ) {
        self.currentWarranty = currentWarranty
        self.onExtensionPurchased = onExtensionPurchased
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Current warranty status
                    currentWarrantyCard
                    
                    // Extension options
                    extensionOptionsSection
                    
                    // Selected extension details
                    if let selected = selectedExtension {
                        selectedExtensionCard(selected)
                    }
                    
                    // Purchase button
                    if selectedExtension != nil {
                        purchaseButton
                    }
                }
                .padding()
            }
            .navigationTitle("Extend Warranty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var currentWarrantyCard: some View {
        GroupBox("Current Warranty") {
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Provider", value: currentWarranty.provider ?? "N/A")
                
                if let endDate = currentWarranty.endDate {
                    InfoRow(label: "Expires", value: DateFormatter.medium.string(from: endDate))
                }
                
                InfoRow(label: "Type", value: currentWarranty.type?.rawValue ?? "N/A")
            }
        }
    }
    
    private var extensionOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Extension Options")
                .font(.headline)
            
            ForEach(availableExtensions, id: \.id) { warrantyExt in
                ExtensionOptionCard(
                    extension: warrantyExt,
                    isSelected: selectedExtension?.id == warrantyExt.id,
                    onSelect: { selectedExtension = warrantyExt }
                )
            }
        }
    }
    
    private func selectedExtensionCard(_ warrantyExtension: WarrantyExtension) -> some View {
        GroupBox("Selected Extension") {
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Duration", value: warrantyExtension.displayDuration)
                InfoRow(label: "Cost", value: warrantyExtension.displayPrice)
                InfoRow(label: "Coverage", value: warrantyExtension.coverageType)
                
                if !warrantyExtension.benefits.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Benefits:")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        ForEach(warrantyExtension.benefits, id: \.self) { benefit in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text(benefit)
                                    .font(.caption)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var purchaseButton: some View {
        Button(action: {
            if let selected = selectedExtension {
                onExtensionPurchased(selected)
                dismiss()
            }
        }) {
            HStack {
                Image(systemName: "cart.badge.plus")
                Text("Purchase Extension")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var availableExtensions: [WarrantyExtension] {
        [
            WarrantyExtension(
                id: UUID(),
                duration: 12,
                price: 99.99,
                coverageType: "Standard Extended",
                benefits: ["Extended repair coverage", "Priority support", "Free diagnostics"]
            ),
            WarrantyExtension(
                id: UUID(),
                duration: 24,
                price: 179.99,
                coverageType: "Premium Extended",
                benefits: ["Full replacement coverage", "24/7 support", "Free shipping", "Accident protection"]
            ),
            WarrantyExtension(
                id: UUID(),
                duration: 36,
                price: 249.99,
                coverageType: "Ultimate Protection",
                benefits: ["Complete coverage", "Concierge service", "Annual check-ups", "Data recovery"]
            )
        ]
    }
}

// MARK: - Extension Option Card

public struct ExtensionOptionCard: View {
    let warrantyExtension: WarrantyExtension
    let isSelected: Bool
    let onSelect: () -> Void
    
    public init(
        `extension`: WarrantyExtension,
        isSelected: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.warrantyExtension = `extension`
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(warrantyExtension.displayDuration)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(warrantyExtension.coverageType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(warrantyExtension.displayPrice)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting Views

// Note: InfoRow is now defined in UI/Components/InfoRow.swift

// MARK: - Supporting Types

public struct WarrantyExtension {
    public let id: UUID
    public let duration: Int // months
    public let price: Double
    public let coverageType: String
    public let benefits: [String]
    
    public var displayDuration: String {
        if duration == 12 {
            return "1 Year"
        } else {
            return "\(duration) Months"
        }
    }
    
    public var displayPrice: String {
        return String(format: "$%.2f", price)
    }
    
    public init(id: UUID, duration: Int, price: Double, coverageType: String, benefits: [String]) {
        self.id = id
        self.duration = duration
        self.price = price
        self.coverageType = coverageType
        self.benefits = benefits
    }
}

// MARK: - WarrantyType Extensions

extension WarrantyType {
    var displayName: String {
        switch self {
        case .manufacturer: return "Manufacturer"
        case .extended: return "Extended"
        case .dealer: return "Dealer"
        case .thirdParty: return "Third Party"
        case .insurance: return "Insurance"
        case .service: return "Service Plan"
        case .store: return "Store/Retailer"
        }
    }
}