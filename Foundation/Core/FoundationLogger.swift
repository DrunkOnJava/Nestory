//
// Layer: Foundation
// Module: Foundation/Core
// Purpose: Foundation-layer logging protocol - no system framework dependencies
//

import Foundation

/// Foundation-layer logging abstraction that doesn't depend on system frameworks
/// Infrastructure layer provides the actual implementation
public protocol FoundationLogger: Sendable {
    /// Log an informational message
    func info(_ message: String)

    /// Log a warning message
    func warning(_ message: String)

    /// Log an error message
    func error(_ message: String)
}

/// No-op implementation for Foundation layer when no logger is provided
public struct NoOpFoundationLogger: FoundationLogger {
    public init() {}

    public func info(_: String) {
        // No-op - Foundation layer cannot log directly
    }

    public func warning(_: String) {
        // No-op - Foundation layer cannot log directly
    }

    public func error(_: String) {
        // No-op - Foundation layer cannot log directly
    }
}
