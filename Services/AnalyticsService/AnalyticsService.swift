//
// Layer: Services
// Module: AnalyticsService
// Purpose: Protocol-first analytics service for calculations and dashboard generation
//
// 🏗️ SERVICE LAYER PATTERN: Analytics Domain Logic
// - Provides business calculations for insurance planning and insights
// - Protocol-first design for TCA dependency injection
// - Follows 6-layer architecture: can import Infrastructure, Foundation only
// - Async operations for performance on large datasets
//
// 🎯 INSURANCE ANALYTICS FOCUS: Financial planning and risk assessment
// - Total portfolio value calculations for coverage planning
// - Category breakdowns for specialized insurance riders
// - Depreciation tracking for accurate claim valuations
// - Trend analysis for coverage gap identification
// - Risk assessment for under-insured categories
//
// 📊 ANALYTICS CATEGORIES:
// - Value Analytics: Portfolio worth, depreciation, growth trends
// - Category Analytics: Distribution, concentration risk, coverage gaps
// - Temporal Analytics: Purchase patterns, warranty expirations, value changes
// - Documentation Analytics: Completeness scoring, missing data identification
//
// 📋 SERVICE STANDARDS:
// - All methods async for non-blocking calculations
// - Decimal precision for financial calculations
// - Privacy-first: no data leaves device unless explicitly requested
// - Performance optimized for 1000+ item inventories
//
// 🍎 APPLE FRAMEWORK OPPORTUNITIES (Phase 3):
// - EventKit: Calendar integration for warranty/maintenance reminders
// - PrivacyAccounting: Privacy-aware analytics with user consent tracking
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
