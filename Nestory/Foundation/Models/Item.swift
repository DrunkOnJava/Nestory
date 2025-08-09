// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class Item {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var slug: String
    public var itemDescription: String?
    public var quantity: Int
    public var serialNumber: String?
    public var modelNumber: String?
    public var manufacturer: String?
    public var notes: String?
    public var tags: [String]

    public var purchasePriceAmount: Int64?
    public var purchasePriceCurrency: String?
    public var purchaseDate: Date?
    public var purchaseLocation: String?

    public var estimatedValueAmount: Int64?
    public var estimatedValueCurrency: String?

    @Relationship(deleteRule: .nullify)
    public var category: Category?

    @Relationship(deleteRule: .nullify)
    public var location: Location?

    @Relationship(deleteRule: .cascade, inverse: \PhotoAsset.item)
    public var photos: [PhotoAsset]?

    @Relationship(deleteRule: .cascade, inverse: \Receipt.item)
    public var receipts: [Receipt]?

    @Relationship(deleteRule: .cascade, inverse: \Warranty.item)
    public var warranties: [Warranty]?

    @Relationship(deleteRule: .cascade, inverse: \MaintenanceTask.item)
    public var maintenanceTasks: [MaintenanceTask]?

    public var createdAt: Date
    public var updatedAt: Date
    public var lastViewedAt: Date?

    public init(
        name: String,
        description: String? = nil,
        quantity: Int = 1,
        category: Category? = nil,
        location: Location? = nil
    ) throws {
        guard quantity > 0 else {
            throw AppError.validation(field: "quantity", reason: "Quantity must be positive")
        }

        id = UUID()
        self.name = name
        slug = try Slug(name).value
        itemDescription = description
        self.quantity = quantity
        self.category = category
        self.location = location
        tags = []
        photos = []
        receipts = []
        warranties = []
        maintenanceTasks = []
        createdAt = Date()
        updatedAt = Date()
    }

    public var purchasePrice: Money? {
        get {
            guard let amount = purchasePriceAmount,
                  let currency = purchasePriceCurrency else { return nil }
            return try? Money(amountInMinorUnits: amount, currencyCode: currency)
        }
        set {
            purchasePriceAmount = newValue?.amountInMinorUnits
            purchasePriceCurrency = newValue?.currencyCode
        }
    }

    public var estimatedValue: Money? {
        get {
            guard let amount = estimatedValueAmount,
                  let currency = estimatedValueCurrency else { return nil }
            return try? Money(amountInMinorUnits: amount, currencyCode: currency)
        }
        set {
            estimatedValueAmount = newValue?.amountInMinorUnits
            estimatedValueCurrency = newValue?.currencyCode
        }
    }

    public var totalValue: Money? {
        guard let price = purchasePrice ?? estimatedValue,
              quantity > 0 else { return nil }
        return try? price.multiplying(by: Decimal(quantity))
    }

    public var activeWarranty: Warranty? {
        warranties?.first { warranty in
            if let expiresAt = warranty.expiresAt {
                return expiresAt > Date()
            }
            return false
        }
    }

    public var upcomingMaintenanceTasks: [MaintenanceTask] {
        maintenanceTasks?.filter { task in
            if let nextDue = task.nextDueAt {
                return nextDue > Date() && nextDue < Date().addingTimeInterval(30 * 24 * 60 * 60)
            }
            return false
        }.sorted { ($0.nextDueAt ?? .distantFuture) < ($1.nextDueAt ?? .distantFuture) } ?? []
    }

    public var isWarrantyActive: Bool {
        activeWarranty != nil
    }

    public func addTag(_ tag: String) throws {
        let normalized = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else {
            throw AppError.validation(field: "tag", reason: "Tag cannot be empty")
        }
        if !tags.contains(normalized) {
            tags.append(normalized)
            updatedAt = Date()
        }
    }

    public func removeTag(_ tag: String) {
        let normalized = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        tags.removeAll { $0 == normalized }
        updatedAt = Date()
    }
}
