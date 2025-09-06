//
// Layer: App
// Module: ClaimSubmission
// Purpose: Claim submission interface coordinator using modular components
//

import SwiftUI
import SwiftData
import MessageUI
import Foundation
import Nestory

// Modular components are automatically available within the same target
// ClaimSubmissionCore, ClaimSubmissionComponents, ClaimSubmissionSteps included

// MARK: - Missing Types (temporary implementations)
struct ContactInformation {
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var address: String = ""
    
    init(email: String, phone: String, address: String) {
        self.email = email
        self.phone = phone
        self.address = address
    }
}

struct ClaimSubmissionView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var selectedItems: [Item] = []
    @State private var claimType: ClaimType = .theft
    @State private var incidentDescription = ""
    @State private var incidentDate = Date()
    @State private var contactInfo = ContactInformation(email: "", phone: "", address: "")
    @State private var showingEmailComposer = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isGeneratingPackage = false
    @State private var generatedClaimPackage: ClaimPackage?
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // Progress indicator
                    ClaimSubmissionProgressIndicator(currentStep: currentStep, totalSteps: 4)
                    
                    // Current step content
                    stepContentView
                    
                    // Navigation buttons
                    navigationButtonsView
                }
                .padding()
            }
            .navigationTitle("Submit Insurance Claim")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
        }
        .sheet(isPresented: $showingEmailComposer) {
            if let claimPackage = generatedClaimPackage {
                ClaimEmailComposerView(claimPackage: claimPackage)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isGeneratingPackage {
                loadingOverlay
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var stepContentView: some View {
        Group {
            switch currentStep {
            case 0:
                ClaimTypeSelectionStep(
                    selectedType: Binding(
                        get: { claimType },
                        set: { claimType = $0 }
                    ),
                    incidentDate: $incidentDate,
                    incidentDescription: $incidentDescription
                )
            case 1:
                ItemSelectionStep(
                    items: items,
                    selectedItems: $selectedItems,
                    categories: categories
                )
            case 2:
                ClaimContactInformationStep(contactInfo: $contactInfo)
            case 3:
                ClaimReviewStep(
                    claimType: claimType,
                    incidentDate: incidentDate,
                    incidentDescription: incidentDescription,
                    selectedItems: selectedItems,
                    contactInfo: contactInfo
                )
            default:
                Text("Unknown step")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    private var navigationButtonsView: some View {
        HStack {
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep < 3 {
                Button("Next") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isCurrentStepValid)
            } else {
                Button("Submit Claim") {
                    Task {
                        await submitClaim()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isCurrentStepValid || isGeneratingPackage)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .overlay {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Generating Claim Package...")
                        .padding(.top)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
    }
    
    // MARK: - Computed Properties
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0:
            return !incidentDescription.isEmpty
        case 1:
            return !selectedItems.isEmpty
        case 2:
            return !contactInfo.email.isEmpty && !contactInfo.phone.isEmpty
        case 3:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Methods
    
    private func submitClaim() async {
        isGeneratingPackage = true
        
        do {
            // Create ClaimScenario from the collected data
            let scenario = ClaimScenario(
                type: .multipleItems, // Default claim scope
                incidentDate: incidentDate,
                description: incidentDescription,
                metadata: [
                    "policeReportNumber": "",
                    "insuranceAdjuster": "",
                    "referenceNumber": ""
                ],
                requiresConditionDocumentation: true
            )
            
            // Create ClaimPackageOptions from contact info
            var options = ClaimPackageOptions()
            options.policyHolder = contactInfo.fullName
            options.propertyAddress = contactInfo.address
            options.contactEmail = contactInfo.email
            options.contactPhone = contactInfo.phone
            options.includePhotos = true
            options.includeReceipts = true
            options.includeWarranties = true
            options.compressPhotos = false
            options.generateAttestation = true
            options.documentationLevel = .detailed
            
            // Create ClaimPackageRequest with selected item IDs
            let claimRequest = ClaimPackageRequest(
                selectedItemIds: selectedItems.map(\.id),
                scenario: scenario,
                options: options
            )
            
            // Use dependency injection instead of shared instance
            let assemblerService = LiveClaimPackageAssemblerService()
            let claimPackage = try await assemblerService.assemblePackage(request: claimRequest)
            
            await MainActor.run {
                self.generatedClaimPackage = claimPackage
                self.showingEmailComposer = true
                self.isGeneratingPackage = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate claim package: \(error.localizedDescription)"
                self.showingError = true
                self.isGeneratingPackage = false
            }
        }
    }
}

// MARK: - Missing Components (Temporary implementations)

private struct ClaimSubmissionProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 20, height: 20)
                if step < totalSteps - 1 {
                    Rectangle()
                        .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
        .padding()
    }
}

private struct ClaimTypeSelectionStep: View {
    @Binding var selectedType: ClaimType
    @Binding var incidentDate: Date
    @Binding var incidentDescription: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Claim Type")
                .font(.headline)
            
            Picker("Claim Type", selection: $selectedType) {
                ForEach(ClaimType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            DatePicker("Incident Date", selection: $incidentDate, displayedComponents: .date)
            
            VStack(alignment: .leading) {
                Text("Description")
                    .font(.subheadline)
                TextEditor(text: $incidentDescription)
                    .frame(minHeight: 100)
                    .border(Color.gray.opacity(0.3))
            }
        }
    }
}

private struct ItemSelectionStep: View {
    let items: [Item]
    @Binding var selectedItems: [Item]
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Items")
                .font(.headline)
            
            List(items, id: \.id) { item in
                HStack {
                    Button(action: {
                        if selectedItems.contains(item) {
                            selectedItems.removeAll { $0.id == item.id }
                        } else {
                            selectedItems.append(item)
                        }
                    }) {
                        Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedItems.contains(item) ? .blue : .gray)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.subheadline)
                        if let category = item.category {
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let price = item.purchasePrice {
                        Text("$\(price)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(minHeight: 200)
        }
    }
}

private struct ClaimContactInformationStep: View {
    @Binding var contactInfo: ContactInformation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.headline)
            
            TextField("Full Name", text: $contactInfo.fullName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $contactInfo.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
            
            TextField("Phone", text: $contactInfo.phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            
            TextField("Address", text: $contactInfo.address)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private struct ClaimReviewStep: View {
    let claimType: ClaimType
    let incidentDate: Date
    let incidentDescription: String
    let selectedItems: [Item]
    let contactInfo: ContactInformation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review Your Claim")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Claim Type: \(claimType.displayName)")
                Text("Incident Date: \(incidentDate, style: .date)")
                Text("Description: \(incidentDescription)")
                Text("Items: \(selectedItems.count)")
                Text("Contact: \(contactInfo.fullName)")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

private struct ClaimEmailComposerView: View {
    let claimPackage: ClaimPackage
    
    var body: some View {
        VStack {
            Text("Email Composer")
                .font(.headline)
            Text("Claim package ready to send")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Supporting Types


public struct ClaimSubmissionView_Previews: PreviewProvider {
    public static var previews: some View {
        NavigationStack {
            ClaimSubmissionView()
        }
        .modelContainer(for: [Item.self, Category.self, ])
    }
}
