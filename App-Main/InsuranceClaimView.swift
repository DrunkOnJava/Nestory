//
// Layer: App-Main
// Module: InsuranceClaimView
// Purpose: Insurance claim generation interface with multi-step wizard - Modularized Architecture
//

import ComposableArchitecture
import SwiftUI
import SwiftData

struct InsuranceClaimView: View {
    let items: [Item]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 1
    @State private var formData = ClaimFormData()
    @State private var generatedClaim: GeneratedClaim?
    @State private var showingExport = false
    @State private var showingPreview = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingClaimsDashboard = false
    
    // Coordinators
    private let generationCoordinator = ClaimGenerationCoordinator()

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
                            ClaimTypeStep(
                                selectedClaimType: $formData.selectedClaimType,
                                selectedCompany: $formData.selectedCompany
                            )
                        case 2:
                            IncidentDetailsStep(
                                incidentDate: $formData.incidentDate,
                                incidentDescription: $formData.incidentDescription,
                                policyNumber: $formData.policyNumber,
                                claimNumber: $formData.claimNumber,
                                selectedClaimType: formData.selectedClaimType
                            )
                        case 3:
                            ContactInformationStep(
                                contactName: $formData.contactName,
                                contactPhone: $formData.contactPhone,
                                contactEmail: $formData.contactEmail,
                                contactAddress: $formData.contactAddress,
                                emergencyContact: $formData.emergencyContact,
                                onSaveContactInfo: saveContactInfo
                            )
                        case 4:
                            ReviewAndGenerateStep(
                                items: items,
                                selectedClaimType: formData.selectedClaimType,
                                selectedCompany: formData.selectedCompany,
                                incidentDate: formData.incidentDate,
                                validationIssues: validateItemsForClaim(),
                                estimatedValue: estimateClaimValue(),
                                generatedClaim: generatedClaim,
                                isGenerating: generationCoordinator.isGenerating,
                                onGenerateClaim: { Task { await generateClaim() } },
                                onShowPreview: { showingPreview = true },
                                onShowExport: { showingExport = true }
                            )
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
                        .disabled(!ClaimValidation.canProceedFromStep(currentStep, with: formData))
                    } else {
                        Button("Generate Claim") {
                            Task {
                                await generateClaim()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!ClaimValidation.canGenerateClaim(with: formData, items: items) || generationCoordinator.isGenerating)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("My Claims") {
                        showingClaimsDashboard = true
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
        .sheet(isPresented: $showingClaimsDashboard) {
            ClaimsDashboardView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .task {
            ClaimDataPersistence.loadContactInfoIntoFormData(&formData)
        }
    }

    // MARK: - Business Logic Methods

    private func validateItemsForClaim() -> [String]? {
        generationCoordinator.validateItemsForClaim(items: items)
    }

    private func estimateClaimValue() -> Decimal {
        generationCoordinator.estimateClaimValue(items: items)
    }

    private func generateClaim() async {
        do {
            generatedClaim = try await generationCoordinator.generateClaim(
                from: formData,
                items: items
            )
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }

    private func saveContactInfo() {
        ClaimDataPersistence.saveContactInfo(formData)
    }
}

// MARK: - Preview Support

#Preview {
    if let container = try? ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)) {
        let context = ModelContext(container)

        // Create sample items
        let item1 = Item(name: "MacBook Pro", itemDescription: "Laptop computer", quantity: 1)
        item1.purchasePrice = 2499.00
        item1.purchaseDate = Date()

        let item2 = Item(name: "iPhone", itemDescription: "Smartphone", quantity: 1)
        item2.purchasePrice = 999.00
        item2.purchaseDate = Date()

        InsuranceClaimView(items: [item1, item2])
            .modelContainer(container)
    } else {
        Text("Preview Error: Failed to create ModelContainer")
            .foregroundColor(.red)
    }
}
