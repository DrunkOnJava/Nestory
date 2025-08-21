//
// Layer: Services
// Module: InsuranceReport
// Purpose: Data models for insurance report generation
//

import Foundation

public struct InsuranceReportData: Sendable {
    public let summary: String
    public let content: String
    public let generatedDate: Date
    public let policyHolder: String
    public let policyNumber: String
    
    public init(
        summary: String,
        content: String, 
        generatedDate: Date,
        policyHolder: String,
        policyNumber: String
    ) {
        self.summary = summary
        self.content = content
        self.generatedDate = generatedDate
        self.policyHolder = policyHolder
        self.policyNumber = policyNumber
    }
}