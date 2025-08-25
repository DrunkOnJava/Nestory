//
// Layer: Foundation
// Module: Models
// Purpose: Validation result data model for claim package validation
//

import Foundation

public struct ValidationResult: Equatable, Sendable, Codable, Identifiable {
    public let id = UUID()
    public let isComplete: Bool
    public let missingItems: [String]
    public let totalValue: Decimal
    public let validationDate: Date
    
    // Computed property for backward compatibility
    public var isValid: Bool { isComplete }
    
    // Computed property for validation issues (backward compatibility)
    public var issues: [ValidationIssue] {
        return missingItems.map { missingItem in
            ValidationIssue(
                severity: .error,
                message: "Missing required: \(missingItem)",
                field: missingItem,
                code: "MISSING_REQUIRED"
            )
        }
    }
    
    public init(
        isComplete: Bool,
        missingItems: [String] = [],
        totalValue: Decimal = 0,
        validationDate: Date = Date()
    ) {
        self.isComplete = isComplete
        self.missingItems = missingItems
        self.totalValue = totalValue
        self.validationDate = validationDate
    }
}