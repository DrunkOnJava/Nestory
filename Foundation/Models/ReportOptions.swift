//
// Layer: Foundation
// Module: Models
// Purpose: Insurance report generation options
//

import Foundation

public struct ReportOptions: Equatable, Sendable, Codable {
    public var includePhotos = true
    public var includeReceipts = true
    public var includeDepreciation = false
    public var groupByRoom = true
    public var includeSerialNumbers = true
    public var includePurchaseInfo = true
    public var includeTotalValue = true
    public var format: ReportFormat = .pdf
    public var template: ReportTemplate = .standard
    
    public init(
        includePhotos: Bool = true,
        includeReceipts: Bool = true,
        includeDepreciation: Bool = false,
        groupByRoom: Bool = true,
        includeSerialNumbers: Bool = true,
        includePurchaseInfo: Bool = true,
        includeTotalValue: Bool = true,
        format: ReportFormat = .pdf,
        template: ReportTemplate = .standard
    ) {
        self.includePhotos = includePhotos
        self.includeReceipts = includeReceipts
        self.includeDepreciation = includeDepreciation
        self.groupByRoom = groupByRoom
        self.includeSerialNumbers = includeSerialNumbers
        self.includePurchaseInfo = includePurchaseInfo
        self.includeTotalValue = includeTotalValue
        self.format = format
        self.template = template
    }
}

public enum ReportFormat: String, CaseIterable, Equatable, Sendable, Codable {
    case pdf = "PDF"
    case csv = "CSV" 
    case json = "JSON"
    case html = "HTML"
    
    public var fileExtension: String {
        switch self {
        case .pdf: return "pdf"
        case .csv: return "csv" 
        case .json: return "json"
        case .html: return "html"
        }
    }
}

public enum ReportTemplate: String, CaseIterable, Equatable, Sendable, Codable {
    case standard = "Standard"
    case detailed = "Detailed"
    case compact = "Compact"
    case insuranceClaim = "Insurance Claim"
}