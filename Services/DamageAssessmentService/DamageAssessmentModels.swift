//
// Layer: Services
// Module: DamageAssessment
// Purpose: Data models and types for damage assessment workflows
//

import Foundation

// MARK: - Damage Type Classification

public enum DamageType: String, CaseIterable, Codable, Sendable {
    case fire = "Fire"
    case water = "Water"
    case theft = "Theft"
    case naturalDisaster = "Natural Disaster"
    case vandalism = "Vandalism"
    case accidental = "Accidental"
    case wear = "Wear & Tear"
    case other = "Other"

    public var icon: String {
        switch self {
        case .fire:
            "flame.fill"
        case .water:
            "drop.fill"
        case .theft:
            "person.fill.xmark"
        case .naturalDisaster:
            "tornado"
        case .vandalism:
            "hammer.fill"
        case .accidental:
            "exclamationmark.triangle.fill"
        case .wear:
            "clock.fill"
        case .other:
            "questionmark.circle.fill"
        }
    }

    public var color: String {
        switch self {
        case .fire:
            "#FF6B35" // Orange-red
        case .water:
            "#007AFF" // Blue
        case .theft:
            "#FF3B30" // Red
        case .naturalDisaster:
            "#8E4EC6" // Purple
        case .vandalism:
            "#FF9500" // Orange
        case .accidental:
            "#FFCC00" // Yellow
        case .wear:
            "#8E8E93" // Gray
        case .other:
            "#6D6D70" // Dark gray
        }
    }

    public var assessmentSteps: [DamageAssessmentStep] {
        switch self {
        case .fire:
            [.initialDocumentation, .smokeAssessment, .heatDamageEvaluation, .structuralCheck, .costEstimation, .reportGeneration]
        case .water:
            [.initialDocumentation, .waterSourceIdentification, .moistureAssessment, .moldRiskEvaluation, .costEstimation, .reportGeneration]
        case .theft:
            [.initialDocumentation, .missingItemsInventory, .securityBreach, .replacementCostCalculation, .reportGeneration]
        case .naturalDisaster:
            [.initialDocumentation, .structuralAssessment, .environmentalImpact, .emergencyNeeds, .costEstimation, .reportGeneration]
        case .vandalism, .accidental, .wear, .other:
            [.initialDocumentation, .damageExtentAssessment, .repairabilityEvaluation, .costEstimation, .reportGeneration]
        }
    }
}

// MARK: - Assessment Steps

public enum DamageAssessmentStep: String, CaseIterable, Codable, Sendable {
    case initialDocumentation = "Initial Documentation"
    case smokeAssessment = "Smoke Damage Assessment"
    case heatDamageEvaluation = "Heat Damage Evaluation"
    case structuralCheck = "Structural Check"
    case waterSourceIdentification = "Water Source Identification"
    case moistureAssessment = "Moisture Assessment"
    case moldRiskEvaluation = "Mold Risk Evaluation"
    case missingItemsInventory = "Missing Items Inventory"
    case securityBreach = "Security Breach Assessment"
    case structuralAssessment = "Structural Assessment"
    case environmentalImpact = "Environmental Impact"
    case emergencyNeeds = "Emergency Needs"
    case damageExtentAssessment = "Damage Extent Assessment"
    case repairabilityEvaluation = "Repairability Evaluation"
    case replacementCostCalculation = "Replacement Cost Calculation"
    case costEstimation = "Cost Estimation"
    case reportGeneration = "Report Generation"

    public var icon: String {
        switch self {
        case .initialDocumentation:
            "doc.text"
        case .smokeAssessment:
            "smoke"
        case .heatDamageEvaluation:
            "thermometer"
        case .structuralCheck, .structuralAssessment:
            "building.2"
        case .waterSourceIdentification:
            "drop.circle"
        case .moistureAssessment:
            "humidity"
        case .moldRiskEvaluation:
            "leaf"
        case .missingItemsInventory:
            "list.bullet.clipboard"
        case .securityBreach:
            "lock.open"
        case .environmentalImpact:
            "globe"
        case .emergencyNeeds:
            "cross.case"
        case .damageExtentAssessment:
            "magnifyingglass"
        case .repairabilityEvaluation:
            "wrench.and.screwdriver"
        case .replacementCostCalculation, .costEstimation:
            "dollarsign.circle"
        case .reportGeneration:
            "doc.richtext"
        }
    }

    public var description: String {
        switch self {
        case .initialDocumentation:
            "Document the initial state and take overview photos"
        case .smokeAssessment:
            "Assess smoke damage and odor infiltration"
        case .heatDamageEvaluation:
            "Evaluate heat-related damage to materials"
        case .structuralCheck, .structuralAssessment:
            "Check for structural integrity issues"
        case .waterSourceIdentification:
            "Identify the source and type of water damage"
        case .moistureAssessment:
            "Measure moisture levels and affected areas"
        case .moldRiskEvaluation:
            "Assess potential for mold growth"
        case .missingItemsInventory:
            "Document all missing or stolen items"
        case .securityBreach:
            "Assess how entry was gained and security failures"
        case .environmentalImpact:
            "Evaluate environmental effects from disaster"
        case .emergencyNeeds:
            "Identify immediate safety and habitability concerns"
        case .damageExtentAssessment:
            "Thoroughly assess the extent of damage"
        case .repairabilityEvaluation:
            "Determine if items can be repaired or must be replaced"
        case .replacementCostCalculation, .costEstimation:
            "Calculate repair or replacement costs"
        case .reportGeneration:
            "Generate comprehensive assessment report"
        }
    }
}

// MARK: - Damage Severity

public enum DamageSeverity: String, CaseIterable, Codable, Sendable {
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case severe = "Severe"
    case total = "Total Loss"

    public var color: String {
        switch self {
        case .minor:
            "#34C759" // Green
        case .moderate:
            "#FF9500" // Orange
        case .major:
            "#FF6B35" // Orange-red
        case .severe:
            "#CC0000" // Dark red
        case .total:
            "#FF3B30" // Red
        }
    }

    public var icon: String {
        switch self {
        case .minor:
            "checkmark.circle"
        case .moderate:
            "exclamationmark.triangle"
        case .major:
            "xmark.octagon"
        case .severe:
            "xmark.circle.fill"
        case .total:
            "multiply.circle.fill"
        }
    }

    public var valueImpactPercentage: Double {
        switch self {
        case .minor:
            0.1 // 10% value reduction
        case .moderate:
            0.35 // 35% value reduction
        case .major:
            0.75 // 75% value reduction
        case .severe:
            0.90 // 90% value reduction
        case .total:
            1.0 // 100% value reduction (total loss)
        }
    }

    public var description: String {
        switch self {
        case .minor:
            "Cosmetic damage, easily repairable"
        case .moderate:
            "Functional damage, moderate repair needed"
        case .major:
            "Significant damage, extensive repair or replacement needed"
        case .severe:
            "Severe damage, near-total loss with minimal salvage value"
        case .total:
            "Complete loss, item cannot be repaired"
        }
    }
}

// MARK: - Assessment Data Models

public struct DamageAssessment: Codable, Identifiable, Sendable {
    public let id: UUID
    public let itemId: UUID
    public let assessmentDate: Date
    public let damageType: DamageType
    public var severity: DamageSeverity

    public var incidentDate: Date?
    public var incidentLocation: String?
    public var incidentDescription: String

    // Photo documentation
    public var beforePhotos: [Data] = []
    public var afterPhotos: [Data] = []
    public var detailPhotos: [Data] = []
    public var photoDescriptions: [String] = []

    // Assessment details
    public var assessmentNotes = ""
    public var repairEstimate: Decimal?
    public var replacementCost: Decimal?
    public var isRepairable = true
    public var estimatedRepairTime: String?

    // Professional assessment
    public var professionalAssessmentRequired = false
    public var professionalContacted = false
    public var professionalNotes = ""

    // Insurance information
    public var claimNumber: String?
    public var adjustorName: String?
    public var adjustorContact: String?
    public var insuranceNotes = ""

    public init(
        itemId: UUID,
        damageType: DamageType,
        severity: DamageSeverity,
        incidentDescription: String
    ) {
        self.id = UUID()
        self.itemId = itemId
        self.assessmentDate = Date()
        self.damageType = damageType
        self.severity = severity
        self.incidentDescription = incidentDescription
    }
}

// MARK: - Assessment Workflow State

public struct DamageAssessmentWorkflow: Codable, Sendable {
    public let id: UUID
    public let damageType: DamageType
    public var currentStep: DamageAssessmentStep
    public var completedSteps: Set<DamageAssessmentStep> = []
    public var stepData: [String: Data] = [:]
    public var assessment: DamageAssessment
    public var affectedItems: [UUID] = []
    public let startedAt: Date
    public var updatedAt: Date
    
    // Photo documentation properties
    public var photos: [DamagePhoto] = []
    public var hasPhotoDocumentation: Bool {
        !photos.isEmpty
    }
    
    // Repair estimation property
    public var hasRepairEstimate: Bool {
        assessment.repairEstimate != nil
    }

    public init(damageType: DamageType, assessment: DamageAssessment) {
        self.id = UUID()
        self.damageType = damageType
        self.currentStep = damageType.assessmentSteps.first ?? .initialDocumentation
        self.assessment = assessment
        self.startedAt = Date()
        self.updatedAt = Date()
    }

    public var progress: Double {
        let totalSteps = damageType.assessmentSteps.count
        let completedCount = completedSteps.count
        return totalSteps > 0 ? Double(completedCount) / Double(totalSteps) : 0
    }

    public var isComplete: Bool {
        completedSteps.count >= damageType.assessmentSteps.count
    }

    public mutating func completeStep(_ step: DamageAssessmentStep) {
        completedSteps.insert(step)
        updatedAt = Date()

        // Move to next step
        if let currentIndex = damageType.assessmentSteps.firstIndex(of: currentStep),
           currentIndex + 1 < damageType.assessmentSteps.count
        {
            currentStep = damageType.assessmentSteps[currentIndex + 1]
        }
    }
}

// MARK: - Photo Documentation

public struct DamagePhoto: Codable, Identifiable, Sendable {
    public let id: UUID
    public let imageData: Data
    public let description: String
    public let captureDate: Date
    public let photoType: PhotoType
    public let location: String?

    public enum PhotoType: String, CaseIterable, Codable, Sendable {
        case before = "Before"
        case after = "After"
        case detail = "Detail"
        case overview = "Overview"
        case comparison = "Comparison"

        public var icon: String {
            switch self {
            case .before:
                "photo.on.rectangle"
            case .after:
                "photo.fill.on.rectangle.fill"
            case .detail:
                "magnifyingglass.circle"
            case .overview:
                "photo.stack"
            case .comparison:
                "photo.on.rectangle.angled"
            }
        }
    }

    public init(
        imageData: Data,
        description: String,
        photoType: PhotoType,
        location: String? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.description = description
        self.captureDate = Date()
        self.photoType = photoType
        self.location = location
    }
}

// MARK: - Cost Estimation

// Note: CostEstimation is now defined in Foundation/Models/CostEstimation.swift

// MARK: - Assessment Templates

public struct AssessmentTemplate: Sendable {
    public let damageType: DamageType
    public let checklistItems: [ChecklistItem]
    public let photoRequirements: [PhotoRequirement]
    public let recommendedMeasurements: [String]

    public struct ChecklistItem: Identifiable, Sendable {
        public let id: UUID
        public let description: String
        public let category: String
        public let isRequired: Bool
        public let helpText: String?

        public init(description: String, category: String, isRequired: Bool = false, helpText: String? = nil) {
            self.id = UUID()
            self.description = description
            self.category = category
            self.isRequired = isRequired
            self.helpText = helpText
        }
    }

    public struct PhotoRequirement: Identifiable, Sendable {
        public let id: UUID
        public let description: String
        public let photoType: DamagePhoto.PhotoType
        public let isRequired: Bool
        public let guidelines: String?

        public init(description: String, photoType: DamagePhoto.PhotoType, isRequired: Bool = false, guidelines: String? = nil) {
            self.id = UUID()
            self.description = description
            self.photoType = photoType
            self.isRequired = isRequired
            self.guidelines = guidelines
        }
    }
}
