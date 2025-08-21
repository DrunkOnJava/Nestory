//
// Layer: Foundation
// Module: Core
// Purpose: Shared validation issue type for consistent error reporting
//

import Foundation

public struct ValidationIssue: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let severity: ValidationSeverity
    public let message: String
    public let field: String?
    public let code: String?
    
    public init(
        severity: ValidationSeverity,
        message: String,
        field: String? = nil,
        code: String? = nil
    ) {
        self.severity = severity
        self.message = message
        self.field = field
        self.code = code
    }
}

public enum ValidationSeverity: String, CaseIterable, Equatable, Sendable {
    case error
    case warning
    case info
}