//
// Layer: App
// Module: ClaimSubmission
// Purpose: Claim submission interface coordinator using modular components
//

import SwiftUI
import SwiftData
import MessageUI
import Foundation

// Modular components are automatically available within the same target
// ClaimSubmissionCore, ClaimSubmissionComponents, ClaimSubmissionSteps included

struct ClaimSubmissionView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @Query private var rooms: [Room]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var selectedItems: [Item] = []
    @State private var claimType: ClaimType = .generalLoss
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
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    // Progress indicator
                    ClaimSubmissionProgressIndicator(currentStep: currentStep, totalSteps: 4)
                    
                    // Current step content
                    Group {
                        switch currentStep {
                        case 0:
                            ClaimTypeSelectionStep(
                                selectedType: $claimType,
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
                            ContactInformationStep(contactInfo: $contactInfo)
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
                    
                    // Navigation buttons
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
                .padding()
            }
            .navigationTitle("Submit Insurance Claim")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
        }
    }
    
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
    
    private func submitClaim() async {
        isGeneratingPackage = true
        
        do {
            let claimContactInfo = ClaimContactInfo(
                name: "User", // TODO: Get from user preferences
                phone: contactInfo.phone,
                email: contactInfo.email,
                address: contactInfo.address,
                emergencyContact: nil
            )
            
            let claimRequest = ClaimRequest(
                claimType: claimType,
                insuranceCompany: .statefarm, // TODO: Make user selectable
                items: selectedItems,
                incidentDate: incidentDate,
                incidentDescription: incidentDescription,
                policyNumber: nil, // TODO: Add to UI
                claimNumber: nil,
                contactInfo: claimContactInfo,
                additionalDocuments: [],
                documentNames: [],
                estimatedTotalLoss: selectedItems.compactMap(\.purchasePrice).reduce(0, +),
                format: .pdf
            )
            
            let claimPackage = try await ClaimPackageAssemblerService.shared.assemblePackage(request: claimRequest)
            
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

// MARK: - Supporting Types

struct ContactInformation {
    var email: String
    var phone: String
    var address: String
}


// MARK: - Preview

#Preview {
    NavigationStack {
        ClaimSubmissionView()
    }
    .modelContainer(for: [Item.self, Category.self, Room.self])
}