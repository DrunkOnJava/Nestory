//
// Layer: Features/Search
// Module: Search/Components/Utils
// Purpose: Search utility functions and helper methods
//

import Foundation

public struct SearchUtils {
    
    // MARK: - Sort Operations
    
    public static func sortResults(_ items: [Item], by sortOption: SearchState.SortOption) -> [Item] {
        switch sortOption {
        case .nameAscending:
            return items.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
        case .nameDescending:
            return items.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending })
        case .priceAscending:
            return items.sorted(by: { ($0.purchasePrice ?? 0) < ($1.purchasePrice ?? 0) })
        case .priceDescending:
            return items.sorted(by: { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) })
        case .dateAdded:
            return items.sorted(by: { $0.createdAt > $1.createdAt })
        case .dateModified:
            return items.sorted(by: { $0.updatedAt > $1.updatedAt })
        case .relevance:
            // For relevance, we'd typically use search score, but for now use name
            return items.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
        }
    }
    
    // MARK: - Search Query Processing
    
    public static func processSearchQuery(_ query: String) -> SearchQuery {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let terms = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        return SearchQuery(
            originalQuery: query,
            processedQuery: trimmed,
            searchTerms: terms,
            isEmpty: trimmed.isEmpty
        )
    }
    
    // MARK: - Filter Validation
    
    public static func validateFilters(_ filters: SearchFilters) -> SearchFilterValidation {
        var issues: [String] = []
        
        // Check for conflicting price ranges
        if let minPrice = filters.priceRange?.lowerBound,
           let maxPrice = filters.priceRange?.upperBound,
           minPrice > maxPrice {
            issues.append("Minimum price cannot be greater than maximum price")
        }
        
        // Check for conflicting date ranges
        if let startDate = filters.dateRange?.lowerBound,
           let endDate = filters.dateRange?.upperBound,
           startDate > endDate {
            issues.append("Start date cannot be later than end date")
        }
        
        return SearchFilterValidation(
            isValid: issues.isEmpty,
            issues: issues
        )
    }
    
    // MARK: - Search Analytics
    
    public static func calculateSearchRelevanceScore(
        item: Item,
        query: String,
        filters: SearchFilters
    ) -> Double {
        var score = 0.0
        let queryLowercased = query.lowercased()
        
        // Name match scoring
        if item.name.lowercased().contains(queryLowercased) {
            score += 10.0
            if item.name.lowercased().hasPrefix(queryLowercased) {
                score += 5.0
            }
        }
        
        // Description match scoring
        if let description = item.itemDescription,
           description.lowercased().contains(queryLowercased) {
            score += 5.0
        }
        
        // Category match scoring
        if let category = item.category,
           category.name.lowercased().contains(queryLowercased) {
            score += 3.0
        }
        
        // Recent items get slight boost
        let daysSinceCreated = Calendar.current.dateComponents([.day], 
                                                               from: item.createdAt, 
                                                               to: Date()).day ?? 0
        if daysSinceCreated < 30 {
            score += 1.0
        }
        
        return score
    }
}

// MARK: - Supporting Types

public struct SearchQuery {
    public let originalQuery: String
    public let processedQuery: String
    public let searchTerms: [String]
    public let isEmpty: Bool
    
    public init(originalQuery: String, processedQuery: String, searchTerms: [String], isEmpty: Bool) {
        self.originalQuery = originalQuery
        self.processedQuery = processedQuery
        self.searchTerms = searchTerms
        self.isEmpty = isEmpty
    }
}

public struct SearchFilterValidation {
    public let isValid: Bool
    public let issues: [String]
    
    public init(isValid: Bool, issues: [String]) {
        self.isValid = isValid
        self.issues = issues
    }
}