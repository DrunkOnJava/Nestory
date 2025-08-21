//
// Layer: Foundation
// Module: Models
// Purpose: Insurance-related type definitions and enumerations
//

import Foundation

public enum ClaimType: String, CaseIterable, Equatable, Sendable, Codable {
    case theft = "Theft"
    case fire = "Fire Damage"
    case water = "Water Damage"
    case vandalism = "Vandalism"
    case naturalDisaster = "Natural Disaster"
    case accident = "Accidental Damage"
    case burglary = "Burglary"
    case windStorm = "Wind/Storm Damage"
    case generalLoss = "General Loss"
    
    public var displayName: String { rawValue }
    
    public var icon: String {
        switch self {
        case .theft, .burglary: "person.fill.xmark"
        case .fire: "flame.fill"
        case .water: "drop.fill"
        case .vandalism: "hammer.fill"
        case .naturalDisaster: "tornado"
        case .accident: "exclamationmark.triangle.fill"
        case .windStorm: "wind"
        case .generalLoss: "questionmark.circle"
        }
    }
    
    public var requiredDocumentation: [String] {
        switch self {
        case .theft, .burglary:
            return ["Police Report", "List of Stolen Items", "Purchase Receipts", "Photos of Items"]
        case .fire:
            return ["Fire Department Report", "Photos of Damage", "Inventory List", "Repair Estimates"]
        case .water:
            return ["Photos of Damage", "Source of Water Damage", "Repair Estimates", "Mitigation Records"]
        case .vandalism:
            return ["Police Report", "Photos of Damage", "Repair Estimates", "Witness Statements"]
        case .naturalDisaster:
            return ["Weather Reports", "Government Disaster Declaration", "Photos", "Damage Assessment"]
        case .accident:
            return ["Incident Description", "Photos of Damage", "Repair Estimates", "Witness Information"]
        case .windStorm:
            return ["Weather Reports", "Photos of Damage", "Repair Estimates", "Structural Assessment"]
        case .generalLoss:
            return ["Detailed Description", "Supporting Documentation", "Value Proof", "Photos"]
        }
    }
}

public enum InsuranceCompany: String, CaseIterable, Equatable, Sendable, Codable {
    case stateFarm = "State Farm"
    case allstate = "Allstate"
    case geico = "GEICO"
    case progressive = "Progressive"
    case usaa = "USAA"
    case nationwide = "Nationwide"
    case farmers = "Farmers"
    case aaa = "AAA"
    case libertymutual = "Liberty Mutual"
    case travelers = "Travelers"
    case aig = "AIG"
    case amica = "Amica"
    case other = "Other"
    
    public var displayName: String { rawValue }
    
    public var supportedClaimTypes: [ClaimType] {
        // All major insurers support all claim types
        ClaimType.allCases
    }
    
    public var preferredFormatName: String {
        switch self {
        case .stateFarm, .allstate, .farmers:
            return "Standard PDF"
        case .geico, .progressive, .nationwide:
            return "Detailed PDF"
        case .usaa:
            return "Military Format"
        case .aaa, .libertymutual, .travelers:
            return "Excel Spreadsheet"
        case .aig, .amica:
            return "Structured JSON"
        case .other:
            return "PDF"
        }
    }
}