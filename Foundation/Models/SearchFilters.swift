//
// Layer: Foundation
// Module: Models
// Purpose: Search filter types for inventory search operations
//

import Foundation

/// Comprehensive search filters for inventory items
public struct SearchFilters: Equatable, Sendable, Codable {
    public var categories: Set<String>
    public var selectedCategories: Set<UUID>
    public var rooms: Set<String>
    public var priceRange: ClosedRange<Double>?
    public var dateRange: ClosedRange<Date>?
    public var hasWarranty: Bool?
    public var hasReceipt: Bool?
    public var hasPhoto: Bool?
    public var searchTerms: [String]
    
    // Advanced filter options
    public var warrantyStatus: Set<WarrantyFilterStatus>
    public var condition: Set<ItemCondition>
    public var purchaseDateRange: ClosedRange<Date>?
    public var serialNumberExists: Bool?
    public var hasSerialNumber: Bool?
    
    // Quantity filter options
    public var minQuantity: Int
    public var maxQuantity: Int
    public var documentationCompleteOnly: Bool
    
    public init(
        categories: Set<String> = [],
        selectedCategories: Set<UUID> = [],
        rooms: Set<String> = [],
        priceRange: ClosedRange<Double>? = nil,
        dateRange: ClosedRange<Date>? = nil,
        hasWarranty: Bool? = nil,
        hasReceipt: Bool? = nil,
        hasPhoto: Bool? = nil,
        searchTerms: [String] = [],
        warrantyStatus: Set<WarrantyFilterStatus> = [],
        condition: Set<ItemCondition> = [],
        purchaseDateRange: ClosedRange<Date>? = nil,
        serialNumberExists: Bool? = nil,
        hasSerialNumber: Bool? = nil,
        minQuantity: Int = 0,
        maxQuantity: Int = 100,
        documentationCompleteOnly: Bool = false
    ) {
        self.categories = categories
        self.selectedCategories = selectedCategories
        self.rooms = rooms
        self.priceRange = priceRange
        self.dateRange = dateRange
        self.hasWarranty = hasWarranty
        self.hasReceipt = hasReceipt
        self.hasPhoto = hasPhoto
        self.searchTerms = searchTerms
        self.warrantyStatus = warrantyStatus
        self.condition = condition
        self.purchaseDateRange = purchaseDateRange
        self.serialNumberExists = serialNumberExists
        self.hasSerialNumber = hasSerialNumber
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.documentationCompleteOnly = documentationCompleteOnly
    }
    
    /// Check if any filters are active
    public var hasActiveFilters: Bool {
        return !categories.isEmpty ||
               !selectedCategories.isEmpty ||
               !rooms.isEmpty ||
               priceRange != nil ||
               dateRange != nil ||
               hasWarranty != nil ||
               hasReceipt != nil ||
               hasPhoto != nil ||
               !searchTerms.isEmpty ||
               !warrantyStatus.isEmpty ||
               !condition.isEmpty ||
               purchaseDateRange != nil ||
               serialNumberExists != nil ||
               hasSerialNumber != nil ||
               minQuantity > 0 ||
               maxQuantity < 100 ||
               documentationCompleteOnly
    }
    
    /// Clear a specific filter type
    public mutating func clearFilter(_ filterType: FilterType) {
        switch filterType {
        case .categories:
            categories.removeAll()
            selectedCategories.removeAll()
        case .rooms:
            rooms.removeAll()
        case .priceRange:
            priceRange = nil
        case .dateRange:
            dateRange = nil
        case .hasWarranty:
            hasWarranty = nil
        case .hasReceipt:
            hasReceipt = nil
        case .hasPhoto:
            hasPhoto = nil
        case .searchTerms:
            searchTerms.removeAll()
        case .warrantyStatus:
            warrantyStatus.removeAll()
        case .condition:
            condition.removeAll()
        case .purchaseDateRange:
            purchaseDateRange = nil
        case .serialNumberExists:
            serialNumberExists = nil
            hasSerialNumber = nil
        }
    }
    
    /// Clear all filters
    public mutating func clearAll() {
        categories.removeAll()
        selectedCategories.removeAll()
        rooms.removeAll()
        priceRange = nil
        dateRange = nil
        hasWarranty = nil
        hasReceipt = nil
        hasPhoto = nil
        searchTerms.removeAll()
        warrantyStatus.removeAll()
        condition.removeAll()
        purchaseDateRange = nil
        serialNumberExists = nil
        hasSerialNumber = nil
        minQuantity = 0
        maxQuantity = 100
        documentationCompleteOnly = false
    }
}

/// Filter types for clearing specific filters
public enum FilterType: String, CaseIterable, Sendable {
    case categories
    case rooms
    case priceRange
    case dateRange
    case hasWarranty
    case hasReceipt
    case hasPhoto
    case searchTerms
    case warrantyStatus
    case condition
    case purchaseDateRange
    case serialNumberExists
}

/// Warranty filter status options
public enum WarrantyFilterStatus: String, CaseIterable, Codable, Sendable {
    case active
    case expiringSoon
    case expired
    case none
    
    public var displayName: String {
        switch self {
        case .active: return "Active"
        case .expiringSoon: return "Expiring Soon"
        case .expired: return "Expired"
        case .none: return "No Warranty"
        }
    }
}

// ItemCondition is defined in Foundation/Models/Item.swift

/// Search history item for storing past searches
public struct SearchHistoryItem: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public let query: String
    public let filters: SearchFilters
    public let timestamp: Date
    public let resultCount: Int
    
    public init(query: String, filters: SearchFilters, resultCount: Int) {
        self.id = UUID()
        self.query = query
        self.filters = filters
        self.timestamp = Date()
        self.resultCount = resultCount
    }
    
    /// Display name for history item
    public var displayName: String {
        if query.isEmpty {
            let activeFilters = filters.categories.count + filters.rooms.count
            return "Filtered search (\(activeFilters) filters)"
        }
        return query
    }
}

/// Saved search for frequently used searches
public struct SavedSearch: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public let name: String
    public let query: String
    public let filters: SearchFilters
    public let createdAt: Date
    public var lastUsed: Date
    
    public init(name: String, query: String, filters: SearchFilters) {
        self.id = UUID()
        self.name = name
        self.query = query
        self.filters = filters
        self.createdAt = Date()
        self.lastUsed = Date()
    }
    
    /// Update last used timestamp
    public mutating func markAsUsed() {
        lastUsed = Date()
    }
}