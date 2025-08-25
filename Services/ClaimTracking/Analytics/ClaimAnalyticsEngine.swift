//
// Layer: Services
// Module: ClaimTracking/Analytics  
// Purpose: Statistical analysis and insights for claim tracking data
//

import Foundation

/// Generates analytics and insights from claim tracking data
public struct ClaimAnalyticsEngine {
    
    private let operations: ClaimTrackingOperations
    
    public init(operations: ClaimTrackingOperations) {
        self.operations = operations
    }
    
    // MARK: - Core Analytics
    
    public func generateClaimAnalytics() -> ClaimAnalytics {
        let allClaims = operations.getAllClaims()
        let activeClaims = operations.getActiveClaims()
        
        let statusDistribution = Dictionary(grouping: allClaims) { $0.status }
            .mapValues { $0.count }
        
        let typeDistribution = Dictionary(grouping: allClaims) { $0.claimType.rawValue }
            .mapValues { $0.count }
        
        let averageProcessingTime = calculateAverageProcessingTime(allClaims)
        let totalClaimValue = allClaims.reduce(0) { $0 + $1.totalClaimedValue }
        
        let submissionMethodDistribution = Dictionary(grouping: allClaims) { $0.submissionMethod }
            .mapValues { $0.count }
        
        return ClaimAnalytics(
            totalClaims: allClaims.count,
            activeClaims: activeClaims.count,
            statusDistribution: statusDistribution,
            typeDistribution: typeDistribution,
            averageProcessingDays: averageProcessingTime,
            totalClaimValue: totalClaimValue,
            submissionMethodDistribution: submissionMethodDistribution,
            successRate: calculateSuccessRate(allClaims)
        )
    }
    
    // MARK: - Trend Analysis
    
    public func analyzeTrends(months: Int = 12) -> ClaimTrendAnalysis {
        let allClaims = operations.getAllClaims()
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
        let recentClaims = allClaims.filter { $0.createdAt >= cutoffDate }
        
        // Monthly claim creation trend
        var monthlyCreation: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        for claim in recentClaims {
            let monthKey = dateFormatter.string(from: claim.createdAt)
            monthlyCreation[monthKey, default: 0] += 1
        }
        
        // Resolution time trends
        let resolvedClaims = recentClaims.filter { isClaimResolved($0) }
        let averageResolutionTimes = calculateMonthlyResolutionTimes(resolvedClaims)
        
        // Success rate trends
        let monthlySuccessRates = calculateMonthlySuccessRates(recentClaims)
        
        return ClaimTrendAnalysis(
            monthlyClaimCreation: monthlyCreation,
            averageMonthlyResolutionTimes: averageResolutionTimes,
            monthlySuccessRates: monthlySuccessRates,
            overallTrend: determineTrend(monthlyCreation)
        )
    }
    
    // MARK: - Performance Metrics
    
    public func calculatePerformanceMetrics() -> ClaimPerformanceMetrics {
        let allClaims = operations.getAllClaims()
        let activities = operations.getRecentActivity(limit: 1000)
        
        // Response time metrics
        let averageFirstResponse = calculateAverageFirstResponseTime(allClaims, activities: activities)
        let averageResolutionTime = calculateAverageProcessingTime(allClaims)
        
        // Efficiency metrics
        let statusChangeVelocity = calculateStatusChangeVelocity(activities)
        let communicationFrequency = calculateCommunicationFrequency(activities)
        
        // Quality metrics
        let reopenRate = calculateReopenRate(allClaims)
        let customerSatisfactionScore = estimateCustomerSatisfaction(allClaims)
        
        return ClaimPerformanceMetrics(
            averageFirstResponseDays: averageFirstResponse,
            averageResolutionDays: averageResolutionTime,
            statusChangeVelocity: statusChangeVelocity,
            communicationFrequency: communicationFrequency,
            reopenRate: reopenRate,
            estimatedSatisfactionScore: customerSatisfactionScore
        )
    }
    
    // MARK: - Private Calculation Methods
    
    private func calculateAverageProcessingTime(_ claims: [ClaimSubmission]) -> Double {
        let completedClaims = claims.filter { isClaimResolved($0) }
        guard !completedClaims.isEmpty else { return 0 }
        
        let totalDays = completedClaims.compactMap { claim -> Double? in
            guard let submissionDate = claim.submissionDate else { return nil }
            return claim.updatedAt.timeIntervalSince(submissionDate) / (24 * 60 * 60)
        }.reduce(0, +)
        
        return totalDays / Double(completedClaims.count)
    }
    
    private func calculateSuccessRate(_ claims: [ClaimSubmission]) -> Double {
        let finalizedClaims = claims.filter { isClaimResolved($0) }
        guard !finalizedClaims.isEmpty else { return 0 }
        
        let approvedClaims = finalizedClaims.filter { $0.status == .settled }.count
        return Double(approvedClaims) / Double(finalizedClaims.count)
    }
    
    private func isClaimResolved(_ claim: ClaimSubmission) -> Bool {
        [.settled, .denied, .closed].contains(claim.status)
    }
    
    private func calculateAverageFirstResponseTime(_ claims: [ClaimSubmission], activities: [ClaimActivity]) -> Double {
        var responseTimes: [Double] = []
        
        for claim in claims {
            guard let submissionDate = claim.submissionDate else { continue }
            
            let claimActivities = activities.filter { $0.claimId == claim.id && $0.timestamp > submissionDate }
            let firstResponse = claimActivities.min(by: { $0.timestamp < $1.timestamp })
            
            if let firstResponse = firstResponse {
                let responseTime = firstResponse.timestamp.timeIntervalSince(submissionDate) / (24 * 60 * 60)
                responseTimes.append(responseTime)
            }
        }
        
        return responseTimes.isEmpty ? 0 : responseTimes.reduce(0, +) / Double(responseTimes.count)
    }
    
    private func calculateStatusChangeVelocity(_ activities: [ClaimActivity]) -> Double {
        let statusChanges = activities.filter { $0.type == .statusUpdate }
        guard statusChanges.count > 1 else { return 0 }
        
        let timespan = statusChanges.max(by: { $0.timestamp < $1.timestamp })!.timestamp
            .timeIntervalSince(statusChanges.min(by: { $0.timestamp < $1.timestamp })!.timestamp)
        let timespanDays = timespan / (24 * 60 * 60)
        
        return Double(statusChanges.count) / timespanDays
    }
    
    private func calculateCommunicationFrequency(_ activities: [ClaimActivity]) -> Double {
        let communications = activities.filter { $0.type == .correspondence }
        guard communications.count > 1 else { return 0 }
        
        let timespan = communications.max(by: { $0.timestamp < $1.timestamp })!.timestamp
            .timeIntervalSince(communications.min(by: { $0.timestamp < $1.timestamp })!.timestamp)
        let timespanDays = timespan / (24 * 60 * 60)
        
        return Double(communications.count) / timespanDays
    }
    
    private func calculateReopenRate(_ claims: [ClaimSubmission]) -> Double {
        // This would require tracking if claims were reopened after closure
        // For now, return a placeholder
        return 0.05 // 5% reopen rate as example
    }
    
    private func estimateCustomerSatisfaction(_ claims: [ClaimSubmission]) -> Double {
        // This would be based on actual feedback data
        // For now, estimate based on resolution speed and success rate
        let successRate = calculateSuccessRate(claims)
        let avgProcessingTime = calculateAverageProcessingTime(claims)
        
        // Simple estimation: higher success rate and lower processing time = higher satisfaction
        let speedScore = max(0, 1 - (avgProcessingTime / 60)) // Normalize to 60 days max
        return (successRate + speedScore) / 2 * 5 // Scale to 1-5
    }
    
    private func calculateMonthlyResolutionTimes(_ claims: [ClaimSubmission]) -> [String: Double] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        var monthlyTimes: [String: [Double]] = [:]
        
        for claim in claims {
            guard let submissionDate = claim.submissionDate else { continue }
            let monthKey = dateFormatter.string(from: claim.updatedAt)
            let resolutionTime = claim.updatedAt.timeIntervalSince(submissionDate) / (24 * 60 * 60)
            
            monthlyTimes[monthKey, default: []].append(resolutionTime)
        }
        
        return monthlyTimes.mapValues { times in
            times.reduce(0, +) / Double(times.count)
        }
    }
    
    private func calculateMonthlySuccessRates(_ claims: [ClaimSubmission]) -> [String: Double] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        var monthlyClaims: [String: [ClaimSubmission]] = [:]
        
        for claim in claims {
            let monthKey = dateFormatter.string(from: claim.updatedAt)
            monthlyClaims[monthKey, default: []].append(claim)
        }
        
        return monthlyClaims.mapValues { monthClaims in
            calculateSuccessRate(monthClaims)
        }
    }
    
    private func determineTrend(_ monthlyData: [String: Int]) -> TrendDirection {
        let sortedMonths = monthlyData.keys.sorted()
        guard sortedMonths.count >= 2 else { return .stable }
        
        let recentMonths = Array(sortedMonths.suffix(3))
        let values = recentMonths.compactMap { monthlyData[$0] }
        
        guard values.count >= 2 else { return .stable }
        
        let firstHalf = values[0..<values.count/2]
        let secondHalf = values[values.count/2..<values.count]
        
        let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
        
        if secondAvg > firstAvg * 1.1 {
            return .increasing
        } else if secondAvg < firstAvg * 0.9 {
            return .decreasing
        } else {
            return .stable
        }
    }
}

// MARK: - Supporting Types

public struct ClaimTrendAnalysis {
    public let monthlyClaimCreation: [String: Int]
    public let averageMonthlyResolutionTimes: [String: Double]
    public let monthlySuccessRates: [String: Double]
    public let overallTrend: TrendDirection
    
    public init(monthlyClaimCreation: [String: Int], averageMonthlyResolutionTimes: [String: Double], monthlySuccessRates: [String: Double], overallTrend: TrendDirection) {
        self.monthlyClaimCreation = monthlyClaimCreation
        self.averageMonthlyResolutionTimes = averageMonthlyResolutionTimes
        self.monthlySuccessRates = monthlySuccessRates
        self.overallTrend = overallTrend
    }
}

public struct ClaimPerformanceMetrics {
    public let averageFirstResponseDays: Double
    public let averageResolutionDays: Double
    public let statusChangeVelocity: Double // changes per day
    public let communicationFrequency: Double // communications per day
    public let reopenRate: Double // percentage
    public let estimatedSatisfactionScore: Double // 1-5 scale
    
    public init(averageFirstResponseDays: Double, averageResolutionDays: Double, statusChangeVelocity: Double, communicationFrequency: Double, reopenRate: Double, estimatedSatisfactionScore: Double) {
        self.averageFirstResponseDays = averageFirstResponseDays
        self.averageResolutionDays = averageResolutionDays
        self.statusChangeVelocity = statusChangeVelocity
        self.communicationFrequency = communicationFrequency
        self.reopenRate = reopenRate
        self.estimatedSatisfactionScore = estimatedSatisfactionScore
    }
}

public enum TrendDirection: String, CaseIterable {
    case increasing = "Increasing"
    case decreasing = "Decreasing" 
    case stable = "Stable"
}