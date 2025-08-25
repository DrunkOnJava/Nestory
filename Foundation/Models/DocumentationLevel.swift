//
// Layer: Foundation
// Module: Models
// Purpose: Documentation level enumeration for claim package assembly
//

import Foundation

public enum DocumentationLevel: String, CaseIterable, Equatable, Sendable, Codable {
    case basic = "Basic"
    case detailed = "Detailed"
    case comprehensive = "Comprehensive"
}