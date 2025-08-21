// Layer: Foundation
// Module: Foundation/Models
// Purpose: Warranty model for item coverage

import Foundation
import SwiftData

/// Warranty information for items
@Model
public final class Warranty: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique)
    public var id: UUID

    public var provider: String
    public var warrantyType: String // "manufacturer", "extended", "dealer", "third-party"
    public var startDate: Date
    public var expiresAt: Date
    public var coverageNotes: String?
    public var claimPhone: String?
    public var claimEmail: String?
    public var claimWebsite: String?
    public var policyNumber: String?
    public var documentFileName: String?

    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships

    @Relationship(inverse: \Item.warranty)
    public var item: Item?

    // MARK: - Initialization

    public init(
        provider: String,
        type: WarrantyType = .manufacturer,
        startDate: Date,
        expiresAt: Date,
        item: Item? = nil
    ) {
        id = UUID()
        self.provider = provider
        warrantyType = type.rawValue
        self.startDate = startDate
        self.expiresAt = expiresAt
        self.item = item
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// Warranty type enum
    public var type: WarrantyType {
        get { WarrantyType(rawValue: warrantyType) ?? .manufacturer }
        set {
            warrantyType = newValue.rawValue
            updatedAt = Date()
        }
    }

    /// Duration of warranty in days
    public var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: expiresAt)
        return components.day ?? 0
    }

    /// Duration of warranty in months
    public var durationInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: startDate, to: expiresAt)
        return components.month ?? 0
    }

    /// Check if warranty is currently active
    public var isActive: Bool {
        let now = Date()
        return now >= startDate && now < expiresAt
    }

    /// Check if warranty has expired
    public var isExpired: Bool {
        Date() >= expiresAt
    }

    /// Days until expiration (negative if expired)
    public var daysUntilExpiration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiresAt)
        return components.day ?? 0
    }

    /// Formatted duration string
    public var formattedDuration: String {
        let months = durationInMonths
        if months < 12 {
            return "\(months) month\(months == 1 ? "" : "s")"
        }
        let years = months / 12
        let remainingMonths = months % 12
        if remainingMonths == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        }
        return "\(years) year\(years == 1 ? "" : "s"), \(remainingMonths) month\(remainingMonths == 1 ? "" : "s")"
    }

    /// Status description
    public var status: String {
        if isExpired {
            return "Expired"
        } else if isActive {
            let days = daysUntilExpiration
            if days <= 30 {
                return "Expiring soon (\(days) day\(days == 1 ? "" : "s"))"
            }
            return "Active"
        } else {
            return "Not yet started"
        }
    }

    /// Check if warranty has documentation attached
    public var hasDocument: Bool {
        guard let documentFileName else { return false }
        return !documentFileName.isEmpty
    }

    // MARK: - Methods

    /// Update warranty properties
    public func update(
        provider: String? = nil,
        type: WarrantyType? = nil,
        startDate: Date? = nil,
        expiresAt: Date? = nil,
        coverageNotes: String? = nil,
        policyNumber: String? = nil,
    ) {
        if let provider {
            self.provider = provider
        }
        if let type {
            self.type = type
        }
        if let startDate {
            self.startDate = startDate
        }
        if let expiresAt {
            self.expiresAt = expiresAt
        }
        if let coverageNotes {
            self.coverageNotes = coverageNotes
        }
        if let policyNumber {
            self.policyNumber = policyNumber
        }
        updatedAt = Date()
    }

    /// Set claim contact information
    public func setClaimContact(
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
    ) {
        claimPhone = phone
        claimEmail = email
        claimWebsite = website
        updatedAt = Date()
    }

    /// Attach warranty document
    public func attachDocument(fileName: String) {
        documentFileName = fileName
        updatedAt = Date()
    }
}

// MARK: - Warranty Type

public enum WarrantyType: String, CaseIterable, Codable {
    case manufacturer
    case extended
    case dealer
    case thirdParty = "third-party"
    case insurance
    case service

    public var displayName: String {
        switch self {
        case .manufacturer: "Manufacturer Warranty"
        case .extended: "Extended Warranty"
        case .dealer: "Dealer Warranty"
        case .thirdParty: "Third-Party Warranty"
        case .insurance: "Insurance Coverage"
        case .service: "Service Contract"
        }
    }

    public var icon: String {
        switch self {
        case .manufacturer: "checkmark.shield.fill"
        case .extended: "shield.lefthalf.filled"
        case .dealer: "building.2.fill"
        case .thirdParty: "person.3.fill"
        case .insurance: "umbrella.fill"
        case .service: "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Equatable Conformance for TCA State Management
extension Warranty: Equatable {
    public static func == (lhs: Warranty, rhs: Warranty) -> Bool {
        return lhs.id == rhs.id &&
               lhs.provider == rhs.provider &&
               lhs.warrantyType == rhs.warrantyType &&
               lhs.startDate == rhs.startDate &&
               lhs.expiresAt == rhs.expiresAt &&
               lhs.updatedAt == rhs.updatedAt
    }
}
