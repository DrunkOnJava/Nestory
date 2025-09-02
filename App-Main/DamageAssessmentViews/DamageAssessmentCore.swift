//
// Layer: App-Main
// Module: DamageAssessmentCore
// Purpose: Core workflow state management and business logic for damage assessment
//

import SwiftUI
import SwiftData

@MainActor
public final class DamageAssessmentCore: ObservableObject {
    // MARK: - Published State

    @Published public var workflow: DamageAssessmentWorkflow?
    @Published public var damageType: DamageType = .other
    @Published public var incidentDescription = ""
    @Published public var showingDamageTypeSelector = true

    // MARK: - Dependencies

    private let damageService: any DamageAssessmentServiceProtocol
    private let item: Item

    // MARK: - Initialization

    public init(item: Item, modelContext: ModelContext) throws {
        self.item = item
        self.damageService = try DamageAssessmentService(modelContext: modelContext)
    }
    
    /// Creates a fallback instance with mock service when normal initialization fails
    public static func createFallback(item: Item) -> DamageAssessmentCore {
        let fallbackCore = DamageAssessmentCore.__createFallback(item: item)
        return fallbackCore
    }
    
    /// Internal fallback initializer
    private init(__fallback item: Item) {
        self.item = item
        self.damageService = MockDamageAssessmentService()
    }
    
    private static func __createFallback(item: Item) -> DamageAssessmentCore {
        return DamageAssessmentCore(__fallback: item)
    }

    // MARK: - Computed Properties

    public var canStartAssessment: Bool {
        !incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isLoading: Bool {
        damageService.isLoading
    }

    // MARK: - Actions

    public func startAssessment() {
        Task {
            do {
                let newWorkflow = try await damageService.createAssessment(
                    for: item,
                    damageType: damageType,
                    incidentDescription: incidentDescription
                )

                await MainActor.run {
                    self.workflow = newWorkflow
                    showingDamageTypeSelector = false
                }
            } catch {
                // Handle error - could show alert
                print("Failed to start assessment: \(error)")
            }
        }
    }

    public func completeCurrentStep() {
        guard let workflow else { return }

        Task {
            do {
                var updatedWorkflow = workflow
                try await damageService.completeWorkflowStep(&updatedWorkflow, step: workflow.currentStep)

                await MainActor.run {
                    self.workflow = updatedWorkflow
                }
            } catch {
                print("Failed to complete step: \(error)")
            }
        }
    }

    public func generateReport() {
        guard let workflow else { return }

        Task {
            do {
                let reportData = try await damageService.generateAssessmentReport(workflow)
                // Handle the generated report - could save or share
                print("Generated report with \(reportData.count) bytes")
            } catch {
                print("Failed to generate report: \(error)")
            }
        }
    }

    public func selectDamageType(_ type: DamageType) {
        damageType = type
    }

    public func updateIncidentDescription(_ description: String) {
        incidentDescription = description
    }
}
