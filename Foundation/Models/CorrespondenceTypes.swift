//
// Layer: Foundation
// Module: Models
// Purpose: Correspondence tracking types for claim communication
//

import Foundation

/// Direction of correspondence in claim communication
public enum CorrespondenceDirection: String, CaseIterable, Codable, Sendable {
    case incoming = "Incoming"
    case outgoing = "Outgoing"
    
    public var displayName: String {
        return rawValue
    }
}

/// Type of correspondence in claim communication
public enum CorrespondenceType: String, CaseIterable, Codable, Sendable {
    case email = "Email"
    case letter = "Letter"
    case phone = "Phone Call"
    case portal = "Portal Message"
    case fax = "Fax"
    case inPerson = "In Person"
    
    public var displayName: String {
        switch self {
        case .inPerson:
            return "In Person"
        default:
            return rawValue
        }
    }
    
    public var icon: String {
        switch self {
        case .email:
            return "envelope"
        case .letter:
            return "doc.text"
        case .phone:
            return "phone"
        case .portal:
            return "globe"
        case .fax:
            return "faxmachine"
        case .inPerson:
            return "person.2"
        }
    }
}