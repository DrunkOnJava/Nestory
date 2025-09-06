//
// Layer: App-Main
// Module: DamageAssessmentCore
// Purpose: Core workflow state management and business logic for damage assessment
//

import SwiftUI
import SwiftData
import OSLog

@MainActor
public final class DamageAssessmentCore: ObservableObject {
    // MARK: - Published State

    @Published public var workflow: DamageAssessmentWorkflow?
    @Published public var damageType: DamageType = .other
    @Published public var incidentDescription = ""
    @Published public var showingDamageTypeSelector = true

    // MARK: - Dependencies

    private let damageService: DamageAssessmentService
    private let item: Item

    // MARK: - Initialization

    public init(item: Item, modelContext: ModelContext) throws {
        self.item = item
        self.damageService = try DamageAssessmentService(modelContext: modelContext)
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
                Logger.service.error("Failed to start damage assessment: \(error.localizedDescription)")
                #if DEBUG
                Logger.service.debug("Damage assessment startup error details: \(error)")
                #endif
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
                Logger.service.error("Failed to complete damage assessment step: \(error.localizedDescription)")
                #if DEBUG
                Logger.service.debug("Step completion error details: \(error)")
                #endif
            }
        }
    }

    public func generateReport() {
        guard let workflow else { return }

        Task {
            do {
                let reportData = try await damageService.generateAssessmentReport(workflow)
                Logger.service.info("Successfully generated damage assessment report with \(reportData.count) bytes")
            } catch {
                Logger.service.error("Failed to generate damage assessment report: \(error.localizedDescription)")
                #if DEBUG
                Logger.service.debug("Report generation error details: \(error)")
                #endif
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
