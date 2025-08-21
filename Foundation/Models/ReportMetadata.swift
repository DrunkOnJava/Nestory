//
// Layer: Foundation
// Module: Models
// Purpose: Insurance report metadata information
//

import Foundation

public struct ReportMetadata: Equatable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let generatedDate: Date
    public let totalItems: Int
    public let totalValue: Decimal
    public let propertyAddress: String?
    public let policyNumber: String?
    
    public init(
        id: UUID = UUID(),
        totalItems: Int,
        totalValue: Decimal,
        propertyAddress: String? = nil,
        policyNumber: String? = nil
    ) {
        self.id = id
        self.generatedDate = Date()
        self.totalItems = totalItems
        self.totalValue = totalValue
        self.propertyAddress = propertyAddress
        self.policyNumber = policyNumber
    }
}