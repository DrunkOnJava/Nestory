// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class Warranty {
    @Attribute(.unique) public var id: UUID
    public var provider: String
    public var warrantyNumber: String?
    public var startDate: Date
    public var expiresAt: Date?
    public var coverageType: CoverageType
    public var coverageNotes: String?
    public var contactPhone: String?
    public var contactEmail: String?
    public var contactWebsite: String?
    public var documentFileName: String?

    @Relationship(deleteRule: .nullify)
    public var item: Item?

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        provider: String,
        startDate: Date = Date(),
        expiresAt: Date? = nil,
        coverageType: CoverageType = .standard,
        coverageNotes: String? = nil
    ) throws {
        if let expires = expiresAt, expires <= startDate {
            throw AppError.validation(field: "expiresAt", reason: "Expiration date must be after start date")
        }

        id = UUID()
        self.provider = provider
        self.startDate = startDate
        self.expiresAt = expiresAt
        self.coverageType = coverageType
        self.coverageNotes = coverageNotes
        createdAt = Date()
        updatedAt = Date()
    }

    public var isActive: Bool {
        guard let expires = expiresAt else { return true }
        return expires > Date()
    }

    public var isExpired: Bool {
        guard let expires = expiresAt else { return false }
        return expires <= Date()
    }

    public var isExpiringSoon: Bool {
        guard let expires = expiresAt else { return false }
        let thirtyDaysFromNow = Date().addingTimeInterval(30 * 24 * 60 * 60)
        return expires > Date() && expires <= thirtyDaysFromNow
    }

    public var daysRemaining: Int? {
        guard let expires = expiresAt, isActive else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expires)
        return components.day
    }

    public var duration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day]
        formatter.unitsStyle = .full

        if let expires = expiresAt {
            return formatter.string(from: startDate, to: expires) ?? "Unknown"
        } else {
            return "Lifetime"
        }
    }
}

public enum CoverageType: String, Codable, CaseIterable {
    case standard
    case extended
    case lifetime
    case limited
    case comprehensive
    case partsOnly = "parts_only"
    case laborOnly = "labor_only"
    case accidental

    public var displayName: String {
        switch self {
        case .standard: "Standard Warranty"
        case .extended: "Extended Warranty"
        case .lifetime: "Lifetime Warranty"
        case .limited: "Limited Warranty"
        case .comprehensive: "Comprehensive Coverage"
        case .partsOnly: "Parts Only"
        case .laborOnly: "Labor Only"
        case .accidental: "Accidental Damage"
        }
    }
}
