//
// Layer: Foundation
// Module: Models  
// Purpose: Export format enumeration for all data export operations
//

import Foundation

public enum ExportFormat: String, CaseIterable, Equatable, Sendable, Codable {
    // Standard data formats
    case csv = "csv"
    case json = "json"
    case xml = "xml"
    case txt = "txt"
    
    // Document formats
    case pdf = "pdf"
    case excel = "xlsx"
    case html = "html"
    case spreadsheet = "spreadsheet"
    
    public var displayName: String {
        switch self {
        case .csv: "CSV"
        case .json: "JSON"
        case .xml: "XML"
        case .txt: "Text"
        case .pdf: "PDF Document"
        case .excel: "Excel Spreadsheet"
        case .html: "HTML Page"
        case .spreadsheet: "Spreadsheet"
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .json: "json"
        case .xml: "xml"
        case .txt: "txt"
        case .pdf: "pdf"
        case .excel: "xlsx"
        case .html: "html"
        case .spreadsheet: "xlsx"
        }
    }
    
    public var mimeType: String {
        switch self {
        case .csv: "text/csv"
        case .json: "application/json"
        case .xml: "application/xml"
        case .txt: "text/plain"
        case .pdf: "application/pdf"
        case .excel, .spreadsheet: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .html: "text/html"
        }
    }
}