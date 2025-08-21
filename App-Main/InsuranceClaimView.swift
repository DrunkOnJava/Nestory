//
// Layer: App
// Module: InsuranceClaimView
// Purpose: Insurance claim generation interface with multi-step wizard
//

import ComposableArchitecture
import SwiftUI
import SwiftData

struct InsuranceClaimView: View {
    let items: [Item]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Dependency(\.insuranceClaimService) var claimService
    @Dependency(\.notificationService) var notificationService

    @State private var currentStep = 1
    @State private var selectedClaimType: ClaimType = .generalLoss
    @State private var selectedCompany: InsuranceCompany = .aaa
    @State private var incidentDate = Date()
    @State private var incidentDescription = ""
    @State private var policyNumber = ""
    @State private var claimNumber = ""

    // Contact information
    @State private var contactName = ""
    @State private var contactPhone = ""
    @State private var contactEmail = ""
    @State private var contactAddress = ""
    @State private var emergencyContact = ""

    // Generation state
    @State private var generatedClaim: GeneratedClaim?
    @State private var showingExport = false
    @State private var showingPreview = false
    @State private var errorMessage = ""
    @State private var showingError = false

    private let totalSteps = 4

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep), total: Double(totalSteps))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch currentStep {
                        case 1:
                            claimTypeStep
                        case 2:
                            incidentDetailsStep
                        case 3:
                            contactInformationStep
                        case 4:
                            reviewAndGenerateStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }

                // Navigation buttons
                HStack {
                    if currentStep > 1 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()

                    if currentStep < totalSteps {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceedFromCurrentStep)
                    } else {
                        Button("Generate Claim") {
                            Task {
                                await generateClaim()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canGenerateClaim || claimService.isGenerating)
                    }
                }
                .padding()
            }
            .navigationTitle("Insurance Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let claim = generatedClaim {
                ClaimPreviewView(claim: claim)
            }
        }
        .sheet(isPresented: $showingExport) {
            if let claim = generatedClaim {
                ClaimExportView(claim: claim)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .task {
            loadSavedContactInfo()
        }
    }

    // MARK: - Step 1: Claim Type Selection

    @ViewBuilder
    private var claimTypeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 1: Claim Type")
                .font(.title2)
                .fontWeight(.bold)

            Text("What type of incident occurred?")
                .foregroundColor(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(ClaimType.allCases, id: \.self) { claimType in
                    ClaimTypeCard(
                        claimType: claimType,
                        isSelected: selectedClaimType == claimType
                    ) {
                        selectedClaimType = claimType
                    }
                }
            }

            Text("Insurance Company")
                .font(.headline)
                .padding(.top)

            Picker("Insurance Company", selection: $selectedCompany) {
                ForEach(InsuranceCompany.allCases, id: \.self) { company in
                    Text(company.rawValue).tag(company)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }

    // MARK: - Step 2: Incident Details

    @ViewBuilder
    private var incidentDetailsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 2: Incident Details")
                .font(.title2)
                .fontWeight(.bold)

            Text("Provide details about when and how the incident occurred.")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                Text("Date of Incident")
                    .font(.headline)

                DatePicker("Incident Date", selection: $incidentDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)

                Text("Description of Incident")
                    .font(.headline)

                TextEditor(text: $incidentDescription)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                Text("Policy Number (Optional)")
                    .font(.headline)

                TextField("Policy Number", text: $policyNumber)
                    .textFieldStyle(.roundedBorder)

                Text("Claim Number (if assigned)")
                    .font(.headline)

                TextField("Claim Number", text: $claimNumber)
                    .textFieldStyle(.roundedBorder)
            }

            // Required documentation reminder
            if !selectedClaimType.requiredDocumentation.isEmpty {
                GroupBox("Required Documentation") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("For \(selectedClaimType.rawValue) claims, you may need:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(selectedClaimType.requiredDocumentation, id: \.self) { doc in
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.blue)
                                Text(doc)
                                    .font(.caption)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Contact Information

    @ViewBuilder
    private var contactInformationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 3: Contact Information")
                .font(.title2)
                .fontWeight(.bold)

            Text("Provide your contact details for the insurance company.")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Full Name")
                        .font(.headline)
                    TextField("Your Full Name", text: $contactName)
                        .textFieldStyle(.roundedBorder)

                    Text("Phone Number")
                        .font(.headline)
                    TextField("Phone Number", text: $contactPhone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)

                    Text("Email Address")
                        .font(.headline)
                    TextField("Email Address", text: $contactEmail)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    Text("Address")
                        .font(.headline)
                    TextField("Full Address", text: $contactAddress, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3)
                }

                Text("Emergency Contact (Optional)")
                    .font(.headline)
                TextField("Emergency Contact", text: $emergencyContact)
                    .textFieldStyle(.roundedBorder)
            }

            Button("Save Contact Info") {
                saveContactInfo()
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
    }

    // MARK: - Step 4: Review and Generate

    @ViewBuilder
    private var reviewAndGenerateStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 4: Review & Generate")
                .font(.title2)
                .fontWeight(.bold)

            if let validationIssues = validateItemsForClaim(), !validationIssues.isEmpty {
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
                    SummaryRow(label: "Estimated Value", value: formatCurrency(estimateClaimValue()))
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

            if claimService.isGenerating {
                ProgressView("Generating claim document...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            if let claim = generatedClaim {
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
                                showingPreview = true
                            }
                            .buttonStyle(.bordered)

                            Button("Export & Share") {
                                showingExport = true
                            }
                            .buttonStyle(.borderedProminent)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    private func ClaimTypeCard(
        claimType: ClaimType,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: claimType.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .accentColor)

                Text(claimType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func SummaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    // MARK: - Validation and Generation

    private var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case 1:
            true // Claim type is always selected
        case 2:
            !incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3:
            !contactName.isEmpty && !contactPhone.isEmpty && !contactEmail.isEmpty && !contactAddress.isEmpty
        default:
            false
        }
    }

    private var canGenerateClaim: Bool {
        canProceedFromCurrentStep && !items.isEmpty
    }

    private func validateItemsForClaim() -> [String]? {
        claimService.validateItemsForClaim(items: items)
    }

    private func estimateClaimValue() -> Decimal {
        claimService.estimateClaimValue(items: items)
    }

    private func generateClaim() async {
        let contactInfo = ClaimContactInfo(
            name: contactName,
            phone: contactPhone,
            email: contactEmail,
            address: contactAddress,
            emergencyContact: emergencyContact.isEmpty ? nil : emergencyContact
        )

        let request = ClaimRequest(
            claimType: selectedClaimType,
            insuranceCompany: selectedCompany,
            items: items,
            incidentDate: incidentDate,
            incidentDescription: incidentDescription,
            policyNumber: policyNumber.isEmpty ? nil : policyNumber,
            claimNumber: claimNumber.isEmpty ? nil : claimNumber,
            contactInfo: contactInfo,
            estimatedTotalLoss: estimateClaimValue()
        )

        do {
            generatedClaim = try await claimService.generateClaim(for: request)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }

    // MARK: - Persistence Helpers

    private func loadSavedContactInfo() {
        contactName = UserDefaults.standard.string(forKey: "insurance_contact_name") ?? ""
        contactPhone = UserDefaults.standard.string(forKey: "insurance_contact_phone") ?? ""
        contactEmail = UserDefaults.standard.string(forKey: "insurance_contact_email") ?? ""
        contactAddress = UserDefaults.standard.string(forKey: "insurance_contact_address") ?? ""
        emergencyContact = UserDefaults.standard.string(forKey: "insurance_emergency_contact") ?? ""
    }

    private func saveContactInfo() {
        UserDefaults.standard.set(contactName, forKey: "insurance_contact_name")
        UserDefaults.standard.set(contactPhone, forKey: "insurance_contact_phone")
        UserDefaults.standard.set(contactEmail, forKey: "insurance_contact_email")
        UserDefaults.standard.set(contactAddress, forKey: "insurance_contact_address")
        UserDefaults.standard.set(emergencyContact, forKey: "insurance_emergency_contact")
    }

    // MARK: - Formatting Helpers

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

// MARK: - Preview Support

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let context = ModelContext(container)

    // Create sample items
    let item1 = Item(name: "MacBook Pro", itemDescription: "Laptop computer", quantity: 1)
    item1.purchasePrice = 2499.00
    item1.purchaseDate = Date()

    let item2 = Item(name: "iPhone", itemDescription: "Smartphone", quantity: 1)
    item2.purchasePrice = 999.00
    item2.purchaseDate = Date()

    return InsuranceClaimView(items: [item1, item2])
        .modelContainer(container)
}
