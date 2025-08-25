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
    public let suggestion: String?
    public let affectedItems: [String]
    
    public init(
        severity: ValidationSeverity,
        message: String,
        field: String? = nil,
        code: String? = nil,
        suggestion: String? = nil,
        affectedItems: [String] = []
    ) {
        self.severity = severity
        self.message = message
        self.field = field
        self.code = code
        self.suggestion = suggestion
        self.affectedItems = affectedItems
    }
}

public enum ValidationSeverity: String, CaseIterable, Equatable, Sendable, Codable {
    case critical = "Critical"
    case error = "Error"
    case warning = "Warning"
    case info = "Info"
    
    public var color: String {
        switch self {
        case .critical: "red"
        case .error: "red"
        case .warning: "orange"
        case .info: "blue"
        }
    }
    
    public var icon: String {
        switch self {
        case .critical: "exclamationmark.circle.fill"
        case .error: "exclamationmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        }
    }
}