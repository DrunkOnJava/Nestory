//
// Layer: Services
// Module: WarrantyTrackingService/Operations/Analytics
// Purpose: Warranty data analysis and statistical reporting
//

import Foundation

/// Generates analytics and statistics for warranty tracking data
public struct WarrantyAnalyticsEngine {
    
    private let statusManager: WarrantyStatusManager
    
    public init(statusManager: WarrantyStatusManager = WarrantyStatusManager()) {
        self.statusManager = statusManager
    }
    
    // MARK: - Statistical Analysis
    
    public func generateStatistics(from items: [Item]) async throws -> WarrantyTrackingStatistics {
        let totalItems = items.count
        let itemsWithWarranty = items.filter { $0.warranty != nil }.count
        let warranties = items.compactMap { $0.warranty }
        
        let activeWarranties = statusManager.getActiveWarranties(from: warranties).count
        let expiringSoon = statusManager.getExpiringWarranties(within: 30, from: warranties).count
        let expired = statusManager.getExpiredWarranties(from: warranties).count
        let missingWarrantyInfo = totalItems - itemsWithWarranty
        
        // Calculate average warranty duration
        let warrantyDurations = warranties.compactMap { warranty in
            Calendar.current.dateComponents([.day], from: warranty.startDate, to: warranty.expiresAt).day
        }.map { Double($0) / 365.0 } // Convert to years
        
        // Calculate provider statistics
        var providerCounts: [String: Int] = [:]
        for warranty in warranties {
            providerCounts[warranty.provider, default: 0] += 1
        }
        
        let averageWarrantyDuration = warrantyDurations.isEmpty ? 0.0 : warrantyDurations.reduce(0, +) / Double(warrantyDurations.count)
        let mostCommonProvider = providerCounts.max(by: { $0.value < $1.value })?.key
        
        return WarrantyTrackingStatistics(
            totalWarranties: itemsWithWarranty,
            activeWarranties: activeWarranties,
            expiredWarranties: expired,
            expiringSoonCount: expiringSoon,
            noWarrantyCount: missingWarrantyInfo,
            averageDurationDays: averageWarrantyDuration * 365.0, // Convert years to days
            totalCoverageValue: 0.0, // Calculate if coverage values are available
            totalItems: totalItems,
            itemsWithWarranty: itemsWithWarranty,
            missingWarrantyInfo: missingWarrantyInfo,
            averageWarrantyDuration: averageWarrantyDuration,
            mostCommonProvider: mostCommonProvider
        )
    }
    
    // MARK: - Trend Analysis
    
    public func analyzeExpirationTrends(from warranties: [Warranty], months: Int = 12) -> ExpirationTrendAnalysis {
        let now = Date()
        let calendar = Calendar.current
        
        var monthlyExpirations: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        // Analyze expirations over the next specified months
        for month in 0..<months {
            guard let targetMonth = calendar.date(byAdding: .month, value: month, to: now) else { continue }
            let monthKey = dateFormatter.string(from: targetMonth)
            
            let expirationsInMonth = warranties.filter { warranty in
                let warrantyMonth = dateFormatter.string(from: warranty.expiresAt)
                return warrantyMonth == monthKey && warranty.expiresAt > now
            }.count
            
            monthlyExpirations[monthKey] = expirationsInMonth
        }
        
        return ExpirationTrendAnalysis(
            monthlyExpirations: monthlyExpirations,
            analysisStartDate: now,
            analysisMonths: months
        )
    }
    
    // MARK: - Coverage Analysis
    
    public func analyzeCoverageByCategory(from items: [Item]) -> CategoryCoverageAnalysis {
        var categoryStats: [String: CategoryStats] = [:]
        
        for item in items {
            let categoryName = item.category?.name ?? "Uncategorized"
            
            if categoryStats[categoryName] == nil {
                categoryStats[categoryName] = CategoryStats(
                    categoryName: categoryName,
                    totalItems: 0,
                    itemsWithWarranty: 0,
                    activeWarranties: 0,
                    expiredWarranties: 0
                )
            }
            
            categoryStats[categoryName]?.totalItems += 1
            
            if let warranty = item.warranty {
                categoryStats[categoryName]?.itemsWithWarranty += 1
                
                let now = Date()
                if warranty.expiresAt > now && warranty.startDate <= now {
                    categoryStats[categoryName]?.activeWarranties += 1
                } else if warranty.expiresAt <= now {
                    categoryStats[categoryName]?.expiredWarranties += 1
                }
            }
        }
        
        return CategoryCoverageAnalysis(categoryStats: Array(categoryStats.values))
    }
    
    // MARK: - Provider Analysis
    
    public func analyzeProviderPerformance(from warranties: [Warranty]) -> ProviderPerformanceAnalysis {
        var providerStats: [String: ProviderStats] = [:]
        
        for warranty in warranties {
            if providerStats[warranty.provider] == nil {
                providerStats[warranty.provider] = ProviderStats(
                    providerName: warranty.provider,
                    totalWarranties: 0,
                    averageDuration: 0.0,
                    activeCount: 0,
                    expiredCount: 0
                )
            }
            
            providerStats[warranty.provider]?.totalWarranties += 1
            
            // Calculate duration in years
            let durationInDays = Calendar.current.dateComponents([.day], from: warranty.startDate, to: warranty.expiresAt).day ?? 0
            let durationInYears = Double(durationInDays) / 365.0
            
            let currentTotal = providerStats[warranty.provider]?.averageDuration ?? 0.0
            let currentCount = providerStats[warranty.provider]?.totalWarranties ?? 1
            providerStats[warranty.provider]?.averageDuration = ((currentTotal * Double(currentCount - 1)) + durationInYears) / Double(currentCount)
            
            // Status counts
            let now = Date()
            if warranty.expiresAt > now && warranty.startDate <= now {
                providerStats[warranty.provider]?.activeCount += 1
            } else if warranty.expiresAt <= now {
                providerStats[warranty.provider]?.expiredCount += 1
            }
        }
        
        return ProviderPerformanceAnalysis(providerStats: Array(providerStats.values))
    }
}

// MARK: - Supporting Types
// Note: WarrantyTrackingStatistics is imported from Foundation/Models/WarrantyStatus.swift

public struct ExpirationTrendAnalysis {
    public let monthlyExpirations: [String: Int] // Month (YYYY-MM) -> Count
    public let analysisStartDate: Date
    public let analysisMonths: Int
    
    public init(monthlyExpirations: [String: Int], analysisStartDate: Date, analysisMonths: Int) {
        self.monthlyExpirations = monthlyExpirations
        self.analysisStartDate = analysisStartDate
        self.analysisMonths = analysisMonths
    }
}

public struct CategoryCoverageAnalysis {
    public let categoryStats: [CategoryStats]
    
    public init(categoryStats: [CategoryStats]) {
        self.categoryStats = categoryStats
    }
}

public struct CategoryStats {
    public let categoryName: String
    public var totalItems: Int
    public var itemsWithWarranty: Int
    public var activeWarranties: Int
    public var expiredWarranties: Int
    
    public var coveragePercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(itemsWithWarranty) / Double(totalItems) * 100.0
    }
    
    public init(categoryName: String, totalItems: Int, itemsWithWarranty: Int, activeWarranties: Int, expiredWarranties: Int) {
        self.categoryName = categoryName
        self.totalItems = totalItems
        self.itemsWithWarranty = itemsWithWarranty
        self.activeWarranties = activeWarranties
        self.expiredWarranties = expiredWarranties
    }
}

public struct ProviderPerformanceAnalysis {
    public let providerStats: [ProviderStats]
    
    public init(providerStats: [ProviderStats]) {
        self.providerStats = providerStats
    }
}

public struct ProviderStats {
    public let providerName: String
    public var totalWarranties: Int
    public var averageDuration: Double // in years
    public var activeCount: Int
    public var expiredCount: Int
    
    public init(providerName: String, totalWarranties: Int, averageDuration: Double, activeCount: Int, expiredCount: Int) {
        self.providerName = providerName
        self.totalWarranties = totalWarranties
        self.averageDuration = averageDuration
        self.activeCount = activeCount
        self.expiredCount = expiredCount
    }
}