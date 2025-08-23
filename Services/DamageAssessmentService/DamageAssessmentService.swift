//
// Layer: Services
// Module: DamageAssessment
// Purpose: Main service for damage assessment workflows and documentation
//

import Foundation
import SwiftData

// MARK: - Service Protocol

public protocol DamageAssessmentServiceProtocol: Sendable {
    func createAssessment(for item: Item, damageType: DamageType, incidentDescription: String) async throws -> DamageAssessmentWorkflow
    func updateAssessment(_ assessment: DamageAssessment) async throws
    func completeWorkflowStep(_ workflow: inout DamageAssessmentWorkflow, step: DamageAssessmentStep) async throws
    func addPhoto(_ photo: DamagePhoto, to assessment: inout DamageAssessment) async throws
    func calculateDamageValue(for item: Item, severity: DamageSeverity) async throws -> Decimal
    func generateAssessmentReport(_ workflow: DamageAssessmentWorkflow) async throws -> Data
    func getAssessmentTemplate(for damageType: DamageType) async throws -> AssessmentTemplate
    func getActiveAssessments(for item: Item) async throws -> [DamageAssessmentWorkflow]
}

// MARK: - Live Implementation

@MainActor
public final class DamageAssessmentService: ObservableObject, DamageAssessmentServiceProtocol {
    // MARK: - Properties

    @Published public var activeAssessments: [DamageAssessmentWorkflow] = []
    @Published public var isLoading = false
    @Published public var lastError: Error?

    private let modelContext: ModelContext
    private let templateProvider: AssessmentTemplateProvider
    private let reportGenerator: DamageAssessmentReportGenerator
    private let photoManager: DamagePhotoManager

    // MARK: - Initialization

    public init(modelContext: ModelContext) throws {
        self.modelContext = modelContext
        self.templateProvider = AssessmentTemplateProvider()
        self.reportGenerator = DamageAssessmentReportGenerator()
        self.photoManager = DamagePhotoManager()
    }
    
    // MARK: - Mock Instance Factory
    
    public static func createMockInstance() -> DamageAssessmentService {
        // Create a minimal in-memory ModelContext for the mock instance
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Item.self, configurations: config)
            let context = ModelContext(container)
            return try DamageAssessmentService(modelContext: context)
        } catch {
            print("⚠️ Could not create mock DamageAssessmentService: \(error)")
            print("🔄 Creating ultra-minimal fallback instance")
            // Return a version that won't crash - use an empty container
            let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            let context = ModelContext(container)
            return try! DamageAssessmentService(modelContext: context)
        }
    }

    // MARK: - Assessment Management

    public func createAssessment(
        for item: Item,
        damageType: DamageType,
        incidentDescription: String
    ) async throws -> DamageAssessmentWorkflow {
        isLoading = true
        defer { isLoading = false }

        let severity = determineSeverity(from: incidentDescription, damageType: damageType)

        var assessment = DamageAssessment(
            itemId: item.id,
            damageType: damageType,
            severity: severity,
            incidentDescription: incidentDescription
        )

        // Set replacement cost from item's purchase price if available
        if let purchasePrice = item.purchasePrice {
            assessment.replacementCost = purchasePrice
        }

        let workflow = DamageAssessmentWorkflow(damageType: damageType, assessment: assessment)
        activeAssessments.append(workflow)

        // Update item condition to damaged
        item.itemCondition = .damaged
        item.conditionNotes = "Damage assessment in progress: \(incidentDescription)"
        item.lastConditionUpdate = Date()
        item.updatedAt = Date()

        try modelContext.save()

        return workflow
    }

    public func updateAssessment(_ assessment: DamageAssessment) async throws {
        isLoading = true
        defer { isLoading = false }

        // Find and update the assessment in active workflows
        if let index = activeAssessments.firstIndex(where: { $0.assessment.id == assessment.id }) {
            activeAssessments[index].assessment = assessment
            activeAssessments[index].updatedAt = Date()
        }

        try modelContext.save()
    }

    public func completeWorkflowStep(
        _ workflow: inout DamageAssessmentWorkflow,
        step: DamageAssessmentStep
    ) async throws {
        workflow.completeStep(step)

        // Update in active assessments
        if let index = activeAssessments.firstIndex(where: { $0.id == workflow.id }) {
            activeAssessments[index] = workflow
        }

        try modelContext.save()
    }

    // MARK: - Photo Management

    public func addPhoto(
        _ photo: DamagePhoto,
        to assessment: inout DamageAssessment
    ) async throws {
        switch photo.photoType {
        case .before:
            assessment.beforePhotos.append(photo.imageData)
        case .after:
            assessment.afterPhotos.append(photo.imageData)
        case .detail, .overview, .comparison:
            assessment.detailPhotos.append(photo.imageData)
        }

        assessment.photoDescriptions.append(photo.description)

        try await updateAssessment(assessment)
    }

    // MARK: - Value Calculation

    public func calculateDamageValue(for item: Item, severity: DamageSeverity) async throws -> Decimal {
        guard let purchasePrice = item.purchasePrice else {
            throw DamageAssessmentError.missingPurchasePrice
        }

        let damageMultiplier = Decimal(severity.valueImpactPercentage)
        return purchasePrice * damageMultiplier
    }

    // MARK: - Report Generation

    public func generateAssessmentReport(_ workflow: DamageAssessmentWorkflow) async throws -> Data {
        isLoading = true
        defer { isLoading = false }

        return try await reportGenerator.generateReport(workflow)
    }

    // MARK: - Templates

    public func getAssessmentTemplate(for damageType: DamageType) async throws -> AssessmentTemplate {
        templateProvider.getTemplate(for: damageType)
    }

    // MARK: - Data Retrieval

    public func getActiveAssessments(for item: Item) async throws -> [DamageAssessmentWorkflow] {
        activeAssessments.filter { $0.assessment.itemId == item.id }
    }

    public func loadAssessments() async throws {
        isLoading = true
        defer { isLoading = false }

        // In a real implementation, this would load from persistent storage
        // For now, we keep assessments in memory
    }

    // MARK: - Private Helpers

    private func determineSeverity(from description: String, damageType _: DamageType) -> DamageSeverity {
        let lowerDescription = description.lowercased()

        // Keywords that suggest total loss
        let totalLossKeywords = ["destroyed", "completely", "total", "gone", "missing", "stolen"]
        if totalLossKeywords.contains(where: lowerDescription.contains) {
            return .total
        }

        // Keywords that suggest major damage
        let majorKeywords = ["major", "extensive", "severe", "significant", "structural"]
        if majorKeywords.contains(where: lowerDescription.contains) {
            return .major
        }

        // Keywords that suggest moderate damage
        let moderateKeywords = ["moderate", "noticeable", "damaged", "broken", "cracked"]
        if moderateKeywords.contains(where: lowerDescription.contains) {
            return .moderate
        }

        // Default to minor for other cases
        return .minor
    }
}

// MARK: - Supporting Classes

@MainActor
public class AssessmentTemplateProvider {
    public func getTemplate(for damageType: DamageType) -> AssessmentTemplate {
        switch damageType {
        case .fire:
            createFireDamageTemplate()
        case .water:
            createWaterDamageTemplate()
        case .theft:
            createTheftTemplate()
        case .naturalDisaster:
            createNaturalDisasterTemplate()
        default:
            createGeneralDamageTemplate()
        }
    }

    private func createFireDamageTemplate() -> AssessmentTemplate {
        let checklistItems = [
            AssessmentTemplate.ChecklistItem(
                description: "Check for heat damage to surface materials",
                category: "Heat Damage",
                isRequired: true,
                helpText: "Look for warping, melting, or discoloration"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Assess smoke damage and odor infiltration",
                category: "Smoke Damage",
                isRequired: true,
                helpText: "Note any soot deposits or persistent smoke odors"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Document structural integrity",
                category: "Structural",
                isRequired: true,
                helpText: "Check for compromised joints, supports, or frameworks"
            ),
        ]

        let photoRequirements = [
            AssessmentTemplate.PhotoRequirement(
                description: "Overall view showing fire damage extent",
                photoType: .overview,
                isRequired: true,
                guidelines: "Capture the full scope of fire damage from multiple angles"
            ),
            AssessmentTemplate.PhotoRequirement(
                description: "Close-up of heat damage details",
                photoType: .detail,
                isRequired: true,
                guidelines: "Focus on specific areas showing heat-related damage"
            ),
            AssessmentTemplate.PhotoRequirement(
                description: "Smoke damage documentation",
                photoType: .detail,
                isRequired: true,
                guidelines: "Show soot deposits and smoke staining"
            ),
        ]

        return AssessmentTemplate(
            damageType: .fire,
            checklistItems: checklistItems,
            photoRequirements: photoRequirements,
            recommendedMeasurements: ["Affected area dimensions", "Temperature readings if available", "Air quality measurements"]
        )
    }

    private func createWaterDamageTemplate() -> AssessmentTemplate {
        let checklistItems = [
            AssessmentTemplate.ChecklistItem(
                description: "Identify water source and type",
                category: "Water Source",
                isRequired: true,
                helpText: "Determine if clean water, gray water, or black water"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Measure moisture levels",
                category: "Moisture Assessment",
                isRequired: true,
                helpText: "Use moisture meter if available or note visible moisture"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Check for mold risk factors",
                category: "Mold Risk",
                isRequired: true,
                helpText: "Look for conditions that promote mold growth"
            ),
        ]

        let photoRequirements = [
            AssessmentTemplate.PhotoRequirement(
                description: "Water damage extent overview",
                photoType: .overview,
                isRequired: true,
                guidelines: "Show the full area affected by water damage"
            ),
            AssessmentTemplate.PhotoRequirement(
                description: "Water source documentation",
                photoType: .detail,
                isRequired: true,
                guidelines: "Photograph the source of water intrusion"
            ),
        ]

        return AssessmentTemplate(
            damageType: .water,
            checklistItems: checklistItems,
            photoRequirements: photoRequirements,
            recommendedMeasurements: ["Moisture readings", "Affected area dimensions", "Water depth if standing"]
        )
    }

    private func createTheftTemplate() -> AssessmentTemplate {
        let checklistItems = [
            AssessmentTemplate.ChecklistItem(
                description: "Document all missing items",
                category: "Missing Items",
                isRequired: true,
                helpText: "Create comprehensive list of stolen property"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Assess point of entry",
                category: "Security Breach",
                isRequired: true,
                helpText: "Document how access was gained"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Check for vandalism or additional damage",
                category: "Additional Damage",
                isRequired: false,
                helpText: "Note any damage beyond the theft itself"
            ),
        ]

        let photoRequirements = [
            AssessmentTemplate.PhotoRequirement(
                description: "Point of entry documentation",
                photoType: .detail,
                isRequired: true,
                guidelines: "Show how entry was gained - damaged doors, windows, etc."
            ),
            AssessmentTemplate.PhotoRequirement(
                description: "Area where items were taken",
                photoType: .overview,
                isRequired: true,
                guidelines: "Show the spaces where items were removed from"
            ),
        ]

        return AssessmentTemplate(
            damageType: .theft,
            checklistItems: checklistItems,
            photoRequirements: photoRequirements,
            recommendedMeasurements: ["Entry point dimensions", "Affected room/area sizes"]
        )
    }

    private func createNaturalDisasterTemplate() -> AssessmentTemplate {
        let checklistItems = [
            AssessmentTemplate.ChecklistItem(
                description: "Assess structural safety",
                category: "Safety",
                isRequired: true,
                helpText: "Check for immediate safety hazards"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Document environmental damage",
                category: "Environmental",
                isRequired: true,
                helpText: "Note wind, water, debris, or other environmental damage"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Identify emergency needs",
                category: "Emergency Response",
                isRequired: true,
                helpText: "Determine immediate habitability and safety requirements"
            ),
        ]

        let photoRequirements = [
            AssessmentTemplate.PhotoRequirement(
                description: "Overall disaster impact",
                photoType: .overview,
                isRequired: true,
                guidelines: "Wide shots showing the scope of damage"
            ),
            AssessmentTemplate.PhotoRequirement(
                description: "Specific damage details",
                photoType: .detail,
                isRequired: true,
                guidelines: "Close-ups of specific damage to individual items or areas"
            ),
        ]

        return AssessmentTemplate(
            damageType: .naturalDisaster,
            checklistItems: checklistItems,
            photoRequirements: photoRequirements,
            recommendedMeasurements: ["Affected area dimensions", "Debris measurements", "Water levels if applicable"]
        )
    }

    private func createGeneralDamageTemplate() -> AssessmentTemplate {
        let checklistItems = [
            AssessmentTemplate.ChecklistItem(
                description: "Document damage extent",
                category: "General Assessment",
                isRequired: true,
                helpText: "Thoroughly document all visible damage"
            ),
            AssessmentTemplate.ChecklistItem(
                description: "Determine repairability",
                category: "Repair Assessment",
                isRequired: true,
                helpText: "Assess whether item can be repaired or must be replaced"
            ),
        ]

        let photoRequirements = [
            AssessmentTemplate.PhotoRequirement(
                description: "Before and after comparison",
                photoType: .comparison,
                isRequired: true,
                guidelines: "Show the item's condition before and after damage if possible"
            ),
            AssessmentTemplate.PhotoRequirement(
                description: "Damage detail documentation",
                photoType: .detail,
                isRequired: true,
                guidelines: "Close-up photos of specific damage"
            ),
        ]

        return AssessmentTemplate(
            damageType: .other,
            checklistItems: checklistItems,
            photoRequirements: photoRequirements,
            recommendedMeasurements: ["Damaged area dimensions", "Depth of damage if applicable"]
        )
    }
}

@MainActor
public class DamageAssessmentReportGenerator {
    public func generateReport(_ workflow: DamageAssessmentWorkflow) async throws -> Data {
        // This would generate a comprehensive PDF report
        // For now, return a simple text report as Data
        let report = generateTextReport(workflow)
        return report.data(using: .utf8) ?? Data()
    }

    private func generateTextReport(_ workflow: DamageAssessmentWorkflow) -> String {
        var report = """
        DAMAGE ASSESSMENT REPORT
        ========================

        Assessment ID: \(workflow.id.uuidString)
        Date: \(workflow.assessment.assessmentDate.formatted())
        Damage Type: \(workflow.damageType.rawValue)
        Severity: \(workflow.assessment.severity.rawValue)

        INCIDENT DETAILS
        ================
        """

        if let incidentDate = workflow.assessment.incidentDate {
            report += "\nIncident Date: \(incidentDate.formatted())"
        }

        if let location = workflow.assessment.incidentLocation {
            report += "\nLocation: \(location)"
        }

        report += """

        Description: \(workflow.assessment.incidentDescription)

        ASSESSMENT PROGRESS
        ===================
        Progress: \(Int(workflow.progress * 100))% Complete
        Completed Steps: \(workflow.completedSteps.count)/\(workflow.damageType.assessmentSteps.count)

        DAMAGE EVALUATION
        =================
        Severity: \(workflow.assessment.severity.rawValue)
        Repairable: \(workflow.assessment.isRepairable ? "Yes" : "No")
        """

        if let repairEstimate = workflow.assessment.repairEstimate {
            report += "\nRepair Estimate: $\(repairEstimate)"
        }

        if let replacementCost = workflow.assessment.replacementCost {
            report += "\nReplacement Cost: $\(replacementCost)"
        }

        if !workflow.assessment.assessmentNotes.isEmpty {
            report += """

            NOTES
            =====
            \(workflow.assessment.assessmentNotes)
            """
        }

        report += """

        DOCUMENTATION
        =============
        Before Photos: \(workflow.assessment.beforePhotos.count)
        After Photos: \(workflow.assessment.afterPhotos.count)
        Detail Photos: \(workflow.assessment.detailPhotos.count)

        Report Generated: \(Date().formatted())
        """

        return report
    }
}

@MainActor
public class DamagePhotoManager {
    public func processPhoto(_ imageData: Data, description: String, type: DamagePhoto.PhotoType) -> DamagePhoto {
        DamagePhoto(imageData: imageData, description: description, photoType: type)
    }

    public func validatePhoto(_ photo: DamagePhoto) -> Bool {
        // Basic validation - check if image data exists and is not empty
        !photo.imageData.isEmpty && !photo.description.isEmpty
    }
}

// MARK: - Errors

public enum DamageAssessmentError: LocalizedError {
    case missingPurchasePrice
    case invalidWorkflowState
    case photoProcessingFailed
    case reportGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .missingPurchasePrice:
            "Item purchase price is required for damage value calculation"
        case .invalidWorkflowState:
            "Assessment workflow is in an invalid state"
        case .photoProcessingFailed:
            "Failed to process damage documentation photo"
        case .reportGenerationFailed:
            "Failed to generate assessment report"
        }
    }
}
