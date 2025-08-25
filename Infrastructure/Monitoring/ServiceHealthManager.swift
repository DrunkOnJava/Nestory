//
// Layer: Infrastructure
// Module: Monitoring
// Purpose: Service health monitoring and recovery system
//

import Foundation
import os.log

@MainActor
public class ServiceHealthManager: ObservableObject {
    public static let shared = ServiceHealthManager()
    
    @Published public var serviceStates: [ServiceType: ServiceHealth] = [:]
    @Published public var isDegradedMode = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nestory.app", category: "ServiceHealth")
    private var healthCheckTimer: Timer?
    
    private init() {
        startHealthMonitoring()
    }
    
    // MARK: - Service Health Tracking
    
    public func recordSuccess(for service: ServiceType) {
        let current = serviceStates[service] ?? ServiceHealth()
        serviceStates[service] = ServiceHealth(
            isHealthy: true,
            consecutiveFailures: 0,
            lastSuccess: Date(),
            lastFailure: current.lastFailure,
            totalFailures: current.totalFailures,
            degradedSince: nil
        )
        
        updateDegradedMode()
        logger.info("Service \(service.rawValue) reported success")
    }
    
    public func recordFailure(for service: ServiceType, error: Error) {
        let current = serviceStates[service] ?? ServiceHealth()
        let newFailureCount = current.consecutiveFailures + 1
        
        serviceStates[service] = ServiceHealth(
            isHealthy: newFailureCount < 3, // Healthy if less than 3 consecutive failures
            consecutiveFailures: newFailureCount,
            lastSuccess: current.lastSuccess,
            lastFailure: Date(),
            totalFailures: current.totalFailures + 1,
            degradedSince: newFailureCount >= 3 ? (current.degradedSince ?? Date()) : nil
        )
        
        updateDegradedMode()
        logger.error("Service \(service.rawValue) reported failure: \(error.localizedDescription)")
        
        // Trigger recovery attempt if needed
        if newFailureCount >= 3 {
            Task {
                await attemptServiceRecovery(service)
            }
        }
    }
    
    public func notifyDegradedMode(service: ServiceType) {
        let current = serviceStates[service] ?? ServiceHealth()
        serviceStates[service] = ServiceHealth(
            isHealthy: false,
            consecutiveFailures: current.consecutiveFailures,
            lastSuccess: current.lastSuccess,
            lastFailure: current.lastFailure,
            totalFailures: current.totalFailures,
            degradedSince: Date()
        )
        
        updateDegradedMode()
        logger.warning("Service \(service.rawValue) entered degraded mode")
    }
    
    // MARK: - Health Monitoring
    
    private func startHealthMonitoring() {
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.performHealthChecks()
            }
        }
    }
    
    private func performHealthChecks() async {
        for service in ServiceType.allCases {
            let health = serviceStates[service] ?? ServiceHealth()
            
            // If service has been degraded for more than 5 minutes, attempt recovery
            if let degradedSince = health.degradedSince,
               Date().timeIntervalSince(degradedSince) > 300 {
                await attemptServiceRecovery(service)
            }
        }
    }
    
    private func attemptServiceRecovery(_ service: ServiceType) async {
        logger.info("Attempting recovery for service \(service.rawValue)")
        
        // Implement service-specific recovery logic here
        switch service {
        case .inventory:
            // Attempt to reinitialize inventory service
            break
        case .analytics:
            // Clear analytics cache and retry
            break
        case .cloudBackup:
            // Check network connectivity and retry
            break
        case .notifications:
            // Reauthorize notification permissions
            break
        case .photoIntegration:
            // Re-establish photo library permissions / refresh photo index
            break
        case .export:
            // Reset export pipelines / clean temp files
            break
        case .barcode:
            // Recreate camera session / barcode scanner resources
            break
        case .receiptOCR:
            // Flush OCR caches / reinitialize OCR engine
            break
        case .insuranceReport:
            // Reset report generation state
            break
        default:
            // Future service types: no-op recovery by default
            logger.debug("No specific recovery strategy for service: \(service.rawValue)")
            break
        }
    }
    
    private func updateDegradedMode() {
        let hasDegradedServices = serviceStates.values.contains { !$0.isHealthy }
        isDegradedMode = hasDegradedServices
    }
    
    // MARK: - User-Friendly Status
    
    public func getServiceStatusMessage(for service: ServiceType) -> String {
        guard let health = serviceStates[service] else {
            return "Service status unknown"
        }
        
        if health.isHealthy {
            return "All systems operational"
        } else if let degradedSince = health.degradedSince {
            let formatter = RelativeDateTimeFormatter()
            let timeString = formatter.localizedString(for: degradedSince, relativeTo: Date())
            return "Limited functionality since \(timeString). Some features may be unavailable."
        } else {
            return "Temporary issues detected. Retrying automatically."
        }
    }
}

// MARK: - Supporting Types

public struct ServiceHealth {
    public let isHealthy: Bool
    public let consecutiveFailures: Int
    public let lastSuccess: Date?
    public let lastFailure: Date?
    public let totalFailures: Int
    public let degradedSince: Date?
    
    public init(
        isHealthy: Bool = true,
        consecutiveFailures: Int = 0,
        lastSuccess: Date? = nil,
        lastFailure: Date? = nil,
        totalFailures: Int = 0,
        degradedSince: Date? = nil
    ) {
        self.isHealthy = isHealthy
        self.consecutiveFailures = consecutiveFailures
        self.lastSuccess = lastSuccess
        self.lastFailure = lastFailure
        self.totalFailures = totalFailures
        self.degradedSince = degradedSince
    }
}

public enum ServiceType: String, CaseIterable {
    case inventory = "Inventory"
    case analytics = "Analytics"
    case cloudBackup = "Cloud Backup"
    case notifications = "Notifications"
    case photoIntegration = "Photo Integration"
    case export = "Export"
    case barcode = "Barcode Scanner"
    case receiptOCR = "Receipt OCR"
    case insuranceReport = "Insurance Reports"
    case insuranceClaim = "Insurance Claims"
}
