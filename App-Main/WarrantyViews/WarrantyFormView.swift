//
// Layer: App
// Module: WarrantyViews
// Purpose: Form for adding and editing warranty information
//

import SwiftUI
import SwiftData

/// Form view for creating and editing warranty information
struct WarrantyFormView: View {
    @Bindable var item: Item
    let warrantyTrackingService: LiveWarrantyTrackingService

    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool

    // Form fields
    @State private var provider: String
    @State private var warrantyType: WarrantyType
    @State private var startDate: Date
    @State private var expiresAt: Date
    @State private var coverageNotes: String
    @State private var policyNumber: String
    @State private var claimPhone: String
    @State private var claimEmail: String
    @State private var claimWebsite: String

    @State private var errorMessage: String?
    @State private var isSaving = false

    init(item: Item, warrantyTrackingService: LiveWarrantyTrackingService) {
        self.item = item
        self.warrantyTrackingService = warrantyTrackingService

        if let warranty = item.warranty {
            // Editing existing warranty
            self._isEditing = State(initialValue: true)
            self._provider = State(initialValue: warranty.provider)
            self._warrantyType = State(initialValue: warranty.type)
            self._startDate = State(initialValue: warranty.startDate)
            self._expiresAt = State(initialValue: warranty.expiresAt)
            self._coverageNotes = State(initialValue: warranty.coverageNotes ?? "")
            self._policyNumber = State(initialValue: warranty.policyNumber ?? "")
            self._claimPhone = State(initialValue: warranty.claimPhone ?? "")
            self._claimEmail = State(initialValue: warranty.claimEmail ?? "")
            self._claimWebsite = State(initialValue: warranty.claimWebsite ?? "")
        } else {
            // Creating new warranty
            self._isEditing = State(initialValue: false)

            // Smart defaults
            let categoryDefaults = CategoryWarrantyDefaults.getDefaults(for: item.category?.name)
            let defaultProvider = item.brand?.isEmpty == false ? item.brand! : categoryDefaults.provider
            let defaultStartDate = item.purchaseDate ?? Date()
            let calendar = Calendar.current
            let defaultExpiresAt = calendar.date(byAdding: .month, value: categoryDefaults.months, to: defaultStartDate) ?? Date()

            self._provider = State(initialValue: defaultProvider)
            self._warrantyType = State(initialValue: .manufacturer)
            self._startDate = State(initialValue: defaultStartDate)
            self._expiresAt = State(initialValue: defaultExpiresAt)
            self._coverageNotes = State(initialValue: "")
            self._policyNumber = State(initialValue: "")
            self._claimPhone = State(initialValue: "")
            self._claimEmail = State(initialValue: "")
            self._claimWebsite = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    HStack {
                        Text("Provider")
                        TextField("e.g., Apple, Samsung", text: $provider)
                            .multilineTextAlignment(.trailing)
                    }

                    Picker("Type", selection: $warrantyType) {
                        ForEach(WarrantyType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                    DatePicker("Expiration Date", selection: $expiresAt, displayedComponents: .date)
                }

                Section("Coverage Details") {
                    HStack {
                        Text("Policy Number")
                        TextField("Optional", text: $policyNumber)
                            .multilineTextAlignment(.trailing)
                    }

                    VStack(alignment: .leading) {
                        Text("Coverage Notes")
                        TextEditor(text: $coverageNotes)
                            .frame(minHeight: 60)
                    }
                }

                Section("Claim Contact Information") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        TextField("Phone number", text: $claimPhone)
                            .keyboardType(.phonePad)
                    }

                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        TextField("Email address", text: $claimEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        TextField("Website URL", text: $claimWebsite)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                }

                Section("Duration") {
                    let duration = calculateDuration()
                    let durationText = formatDuration(duration)

                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(durationText)
                            .foregroundColor(.secondary)
                    }

                    // Quick duration presets
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(durationPresets, id: \.months) { preset in
                            Button(action: {
                                setDuration(months: preset.months)
                            }) {
                                VStack {
                                    Text(preset.label)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(preset.description)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                if isEditing {
                    Section {
                        Button("Delete Warranty", role: .destructive) {
                            deleteWarranty()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Warranty" : "Add Warranty")
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
                    .disabled(provider.isEmpty || isSaving)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .overlay {
                if isSaving {
                    ProgressView("Saving...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
        }
    }

    // MARK: - Duration Presets

    private struct DurationPreset {
        let months: Int
        let label: String
        let description: String
    }

    private var durationPresets: [DurationPreset] {
        [
            DurationPreset(months: 3, label: "3 Mo", description: "Basic"),
            DurationPreset(months: 6, label: "6 Mo", description: "Standard"),
            DurationPreset(months: 12, label: "1 Yr", description: "Standard"),
            DurationPreset(months: 24, label: "2 Yr", description: "Extended"),
            DurationPreset(months: 36, label: "3 Yr", description: "Premium"),
            DurationPreset(months: 60, label: "5 Yr", description: "Lifetime"),
        ]
    }

    // MARK: - Helper Methods

    private func calculateDuration() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: startDate, to: expiresAt)
        return max(0, components.month ?? 0)
    }

    private func formatDuration(_ months: Int) -> String {
        if months < 12 {
            return "\(months) month\(months == 1 ? "" : "s")"
        }
        let years = months / 12
        let remainingMonths = months % 12
        if remainingMonths == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        }
        return "\(years) year\(years == 1 ? "" : "s"), \(remainingMonths) month\(remainingMonths == 1 ? "" : "s")"
    }

    private func setDuration(months: Int) {
        let calendar = Calendar.current
        expiresAt = calendar.date(byAdding: .month, value: months, to: startDate) ?? startDate
    }

    private func saveWarranty() {
        guard !provider.isEmpty else {
            errorMessage = "Provider is required"
            return
        }

        guard expiresAt > startDate else {
            errorMessage = "Expiration date must be after start date"
            return
        }

        Task {
            isSaving = true

            do {
                let warranty = Warranty(
                    provider: provider,
                    type: warrantyType,
                    startDate: startDate,
                    expiresAt: expiresAt,
                    item: item
                )

                // Set optional fields
                warranty.coverageNotes = coverageNotes.isEmpty ? nil : coverageNotes
                warranty.policyNumber = policyNumber.isEmpty ? nil : policyNumber
                warranty.setClaimContact(
                    phone: claimPhone.isEmpty ? nil : claimPhone,
                    email: claimEmail.isEmpty ? nil : claimEmail,
                    website: claimWebsite.isEmpty ? nil : claimWebsite
                )

                try await warrantyTrackingService.saveWarranty(warranty, for: item.id)

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save warranty: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }

    private func deleteWarranty() {
        Task {
            isSaving = true

            do {
                try await warrantyTrackingService.deleteWarranty(for: item.id)

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete warranty: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    if let container = try? ModelContainer(for: Item.self, Category.self, Warranty.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)) {
        let context = ModelContext(container)

        let category = Category(name: "Electronics", icon: "tv.fill", colorHex: "#FF6B6B")
        let item = Item(name: "MacBook Pro", itemDescription: "13-inch M2", quantity: 1, category: category)
        item.purchaseDate = Date()
        item.brand = "Apple"

        context.insert(category)
        context.insert(item)

        let notificationService = LiveNotificationService()
        let warrantyService = LiveWarrantyTrackingService(modelContext: context, notificationService: notificationService)

        WarrantyFormView(item: item, warrantyTrackingService: warrantyService)
    } else {
        Text("Preview Error: Failed to create ModelContainer")
            .foregroundColor(.red)
    }
}
