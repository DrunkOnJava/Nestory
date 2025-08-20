//
// Layer: Services
// Module: AnalyticsService
// Purpose: Protocol-first analytics service for calculations and dashboard generation
//

import Foundation
import SwiftData

/// Protocol defining analytics capabilities for inventory data analysis
public protocol AnalyticsService {
    func calculateTotalValue(for items: [Item]) async -> Decimal
    func calculateCategoryBreakdown(for items: [Item]) async -> [CategoryBreakdown]
    func calculateValueTrends(for items: [Item], period: TrendPeriod) async -> [TrendPoint]
    func calculateTopItems(from items: [Item], limit: Int) async -> [Item]
    func calculateDepreciation(for items: [Item]) async -> [DepreciationReport]
    func generateDashboard(for items: [Item]) async -> DashboardData
    func trackEvent(_ event: AnalyticsEvent) async
}
