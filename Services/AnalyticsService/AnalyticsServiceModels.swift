//
// Layer: Services
// Module: AnalyticsService
// Purpose: Service-specific extensions for Foundation analytics models
//

import Foundation

// Service-specific extensions for analytics data
extension DashboardData {
    // Non-Codable computed properties for UI
    public var topValueItems: [Item] {
        // This would be populated by the service based on topValueItemIds
        return []
    }
    
    public var recentItems: [Item] {
        // This would be populated by the service based on recentItemIds
        return []
    }
}
