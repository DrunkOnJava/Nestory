//
// Layer: Foundation
// Module: Models
// Purpose: Core claim information data model
//

import Foundation

public struct ClaimInfo: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let type: String
    public let insuranceCompany: String
    public let policyNumber: String?
    public let incidentDate: Date?
    public let incidentDescription: String?
    public let createdAt: Date
    public let format: String
    
    public init(
        id: UUID = UUID(),
        type: String,
        insuranceCompany: String,
        policyNumber: String? = nil,
        incidentDate: Date? = nil,
        incidentDescription: String? = nil,
        createdAt: Date = Date(),
        format: String = "JSON"
    ) {
        self.id = id
        self.type = type
        self.insuranceCompany = insuranceCompany
        self.policyNumber = policyNumber
        self.incidentDate = incidentDate
        self.incidentDescription = incidentDescription
        self.createdAt = createdAt
        self.format = format
    }
}