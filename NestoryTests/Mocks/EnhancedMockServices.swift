//
// Layer: Tests  
// Module: Mocks
// Purpose: Enhanced mock services with network simulation for comprehensive insurance testing
//

import Foundation
import Combine
import SwiftData
@testable import Nestory

// MARK: - Network Simulation Framework

/// Network condition simulator for realistic testing scenarios
public class NetworkSimulator {
    
    public enum NetworkCondition {
        case perfect
        case slow(latency: Double) // seconds
        case unstable(packetLoss: Double) // 0.0 to 1.0
        case offline
        case intermittent(uptime: Double, downtime: Double) // seconds
    }
    
    @MainActor public static let shared = NetworkSimulator()
    public var currentCondition: NetworkCondition = .perfect
    
    private var isCurrentlyOnline = true
    private var intermittentTimer: Timer?
    
    public func simulate(condition: NetworkCondition) async {
        currentCondition = condition
        
        switch condition {
        case .perfect:
            isCurrentlyOnline = true
            
        case .slow(let latency):
            isCurrentlyOnline = true
            try? await Task.sleep(nanoseconds: UInt64(latency * 1_000_000_000))
            
        case .unstable(let packetLoss):
            isCurrentlyOnline = Double.random(in: 0...1) > packetLoss
            
        case .offline:
            isCurrentlyOnline = false
            
        case .intermittent(let uptime, let downtime):
            startIntermittentSimulation(uptime: uptime, downtime: downtime)
        }
    }
    
    private func startIntermittentSimulation(uptime: Double, downtime: Double) {
        intermittentTimer?.invalidate()
        
        var isUp = true
        intermittentTimer = Timer.scheduledTimer(withTimeInterval: uptime, repeats: true) { _ in
            isUp.toggle()
            self.isCurrentlyOnline = isUp
            
            // Switch timer interval based on current state
            self.intermittentTimer?.invalidate()
            let nextInterval = isUp ? uptime : downtime
            self.intermittentTimer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { _ in
                self.startIntermittentSimulation(uptime: uptime, downtime: downtime)
            }
        }
    }
    
    public var isOnline: Bool {
        isCurrentlyOnline
    }
    
    public func reset() {
        currentCondition = .perfect
        isCurrentlyOnline = true
        intermittentTimer?.invalidate()
        intermittentTimer = nil
    }
}

// MARK: - Enhanced Receipt OCR Mock Service

public class EnhancedMockReceiptOCRService: ReceiptOCRServiceProtocol {
    
    // Configurable behaviors
    public var shouldSucceed = true
    public var processingDelay: Double = 1.0
    public var extractionAccuracy: Double = 0.95 // 95% accuracy
    public var shouldSimulateNetworkIssues = false
    
    // Pre-defined receipt scenarios for insurance testing
    private let insuranceReceiptScenarios: [ReceiptScenario] = [
        ReceiptScenario(
            merchantName: "Apple Store",
            items: [
                ReceiptItem(name: "MacBook Pro 16\"", price: Decimal(2499.00), category: "Electronics"),
                ReceiptItem(name: "AppleCare+ Protection", price: Decimal(399.00), category: "Warranty")
            ],
            total: Decimal(2898.00),
            date: Date(),
            confidence: 0.98
        ),
        ReceiptScenario(
            merchantName: "Best Buy",
            items: [
                ReceiptItem(name: "Samsung 65\" QLED TV", price: Decimal(1299.99), category: "Electronics"),
                ReceiptItem(name: "Extended Warranty 3 Year", price: Decimal(199.99), category: "Warranty")
            ],
            total: Decimal(1499.98),
            date: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            confidence: 0.92
        ),
        ReceiptScenario(
            merchantName: "Jewelry Exchange", 
            items: [
                ReceiptItem(name: "Diamond Engagement Ring", price: Decimal(5999.00), category: "Jewelry"),
                ReceiptItem(name: "Ring Insurance Appraisal", price: Decimal(150.00), category: "Documentation")
            ],
            total: Decimal(6149.00),
            date: Date().addingTimeInterval(-86400 * 365), // 1 year ago
            confidence: 0.89
        ),
        ReceiptScenario(
            merchantName: "Home Depot",
            items: [
                ReceiptItem(name: "DeWalt Power Drill Set", price: Decimal(299.99), category: "Tools"),
                ReceiptItem(name: "Craftsman Tool Box", price: Decimal(149.99), category: "Tools")
            ],
            total: Decimal(449.98),
            date: Date().addingTimeInterval(-86400 * 7), // 1 week ago
            confidence: 0.94
        )
    ]
    
    public func processReceiptImage(_ imageData: Data) async throws -> ReceiptData {
        // Simulate network conditions
        if shouldSimulateNetworkIssues {
            await NetworkSimulator.shared.simulate(condition: .slow(latency: 2.0))
            
            if !NetworkSimulator.shared.isOnline {
                throw ReceiptOCRError.networkUnavailable
            }
        }
        
        // Simulate processing time
        try await Task.sleep(nanoseconds: UInt64(processingDelay * 1_000_000_000))
        
        if !shouldSucceed {
            throw ReceiptOCRError.processingFailed
        }
        
        // Select receipt scenario based on image data hash (for deterministic testing)
        let scenarioIndex = abs(imageData.hashValue) % insuranceReceiptScenarios.count
        let scenario = insuranceReceiptScenarios[scenarioIndex]
        
        // Apply extraction accuracy simulation
        let extractedScenario = applyExtractionAccuracy(to: scenario)
        
        return ReceiptData(
            merchantName: extractedScenario.merchantName,
            totalAmount: extractedScenario.total,
            purchaseDate: extractedScenario.date,
            items: extractedScenario.items.map { receiptItem in
                ExtractedReceiptItem(
                    name: receiptItem.name,
                    price: receiptItem.price,
                    category: receiptItem.category,
                    confidence: extractedScenario.confidence
                )
            },
            confidence: extractedScenario.confidence,
            rawText: generateMockReceiptText(for: extractedScenario)
        )
    }
    
    private func applyExtractionAccuracy(to scenario: ReceiptScenario) -> ReceiptScenario {
        guard extractionAccuracy < 1.0 else { return scenario }
        
        // Simulate extraction errors based on accuracy percentage
        var modifiedScenario = scenario
        
        if Double.random(in: 0...1) > extractionAccuracy {
            // Introduce minor errors to simulate OCR imperfection
            modifiedScenario.merchantName = modifiedScenario.merchantName + " [?]"
            modifiedScenario.confidence *= extractionAccuracy
        }
        
        return modifiedScenario
    }
    
    private func generateMockReceiptText(for scenario: ReceiptScenario) -> String {
        let itemLines = scenario.items.map { "  \($0.name) - $\($0.price)" }.joined(separator: "\n")
        
        return """
        \(scenario.merchantName)
        \(DateFormatter.receiptFormatter.string(from: scenario.date))
        
        Items:
        \(itemLines)
        
        Total: $\(scenario.total)
        
        Thank you for your purchase!
        """
    }
}

// MARK: - Enhanced Insurance Report Mock Service

public class EnhancedMockInsuranceReportService: InsuranceReportServiceProtocol {
    
    public var shouldSucceed = true
    public var generationDelay: Double = 3.0
    public var shouldSimulateNetworkIssues = false
    public var reportQuality: ReportQuality = .high
    
    public enum ReportQuality {
        case low, standard, high, premium
        
        var fileSize: Int {
            switch self {
            case .low: return 50_000 // 50KB
            case .standard: return 200_000 // 200KB  
            case .high: return 500_000 // 500KB
            case .premium: return 1_000_000 // 1MB
            }
        }
    }
    
    public func generateInsuranceReport(
        for items: [Item],
        options: InsuranceReportOptions = InsuranceReportOptions()
    ) async throws -> Data {
        
        // Simulate network conditions for cloud-based PDF generation
        if shouldSimulateNetworkIssues {
            await NetworkSimulator.shared.simulate(condition: .unstable(packetLoss: 0.1))
            
            if !NetworkSimulator.shared.isOnline {
                throw InsuranceReportError.networkUnavailable
            }
        }
        
        // Simulate realistic PDF generation time based on content
        let baseDelay = generationDelay
        let complexityMultiplier = Double(items.count) * 0.1 + (options.includePhotos ? 2.0 : 1.0)
        let totalDelay = baseDelay * complexityMultiplier
        
        try await Task.sleep(nanoseconds: UInt64(min(totalDelay, 30.0) * 1_000_000_000))
        
        if !shouldSucceed {
            throw InsuranceReportError.generationFailed
        }
        
        // Generate mock PDF data with realistic size
        let pdfContent = generateMockPDFContent(for: items, options: options)
        return pdfContent
    }
    
    public func exportItemsAsCSV(_ items: [Item]) async throws -> Data {
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        let csvHeader = "Name,Description,Category,Purchase Price,Purchase Date,Serial Number,Warranty Expiration\n"
        let csvRows = items.map { item in
            let category = item.category?.name ?? "Uncategorized"
            let price = item.purchasePrice?.description ?? "0"
            let purchaseDate = item.purchaseDate?.ISO8601Format() ?? ""
            let serialNumber = item.serialNumber ?? ""
            let warrantyExpiration = item.warrantyExpirationDate?.ISO8601Format() ?? ""
            
            return "\(item.name),\"\(item.itemDescription ?? "")\",\(category),\(price),\(purchaseDate),\(serialNumber),\(warrantyExpiration)"
        }.joined(separator: "\n")
        
        let csvContent = csvHeader + csvRows
        return Data(csvContent.utf8)
    }
    
    private func generateMockPDFContent(for items: [Item], options: InsuranceReportOptions) -> Data {
        // Generate realistic PDF-like content with appropriate size
        let baseContent = generatePDFTextContent(for: items, options: options)
        let contentSize = reportQuality.fileSize
        
        // Pad content to reach realistic file size
        let padding = String(repeating: " ", count: max(0, contentSize - baseContent.count))
        let fullContent = baseContent + padding
        
        return Data(fullContent.utf8)
    }
    
    private func generatePDFTextContent(for items: [Item], options: InsuranceReportOptions) -> String {
        let totalValue = items.reduce(Decimal(0)) { $0 + ($1.purchasePrice ?? 0) }
        let reportDate = DateFormatter.reportFormatter.string(from: Date())
        
        var content = """
        INSURANCE INVENTORY REPORT
        Generated: \(reportDate)
        
        SUMMARY
        Total Items: \(items.count)
        Total Estimated Value: $\(totalValue)
        
        DETAILED INVENTORY
        
        """
        
        for (index, item) in items.enumerated() {
            content += """
            \(index + 1). \(item.name)
               Description: \(item.itemDescription ?? "N/A")
               Category: \(item.category?.name ?? "Uncategorized")
               Purchase Price: $\(item.purchasePrice ?? 0)
               Serial Number: \(item.serialNumber ?? "N/A")
               Condition: \(item.condition)
               
            """
            
            if options.includePhotos && item.imageData != nil {
                content += "   [PHOTO INCLUDED]\n\n"
            }
            
            if options.includeReceipts && item.receiptImageData != nil {
                content += "   [RECEIPT INCLUDED]\n\n"
            }
            
            if options.includeWarrantyInfo && item.warrantyExpirationDate != nil {
                content += "   Warranty Expires: \(item.warrantyExpirationDate!.formatted())\n\n"
            }
        }
        
        content += """
        
        RECOMMENDATIONS
        - Review and update item values annually
        - Keep original receipts and documentation secure  
        - Consider additional coverage for high-value items
        - Document any changes in item condition
        
        This report was generated for insurance documentation purposes.
        """
        
        return content
    }
}

// MARK: - Enhanced Cloud Backup Mock Service

public class EnhancedMockCloudBackupService: CloudBackupServiceProtocol {
    
    public var shouldSucceed = true
    public var syncDelay: Double = 0.5
    public var shouldSimulateNetworkIssues = false
    public var storageQuotaUsed: Double = 0.3 // 30% of quota used
    public var storageQuotaLimit: Int = 5_000_000_000 // 5GB
    
    // Simulated cloud storage
    private var cloudStorage: [String: CloudItem] = [:]
    private var conflictResolutionStrategy: ConflictResolutionStrategy = .lastWriteWins
    
    public enum ConflictResolutionStrategy {
        case lastWriteWins
        case firstWriteWins
        case userPrompt
        case mergeBoth
    }
    
    public func syncItemToCloud(_ item: Item) async throws {
        if shouldSimulateNetworkIssues {
            await NetworkSimulator.shared.simulate(condition: .slow(latency: syncDelay))
            
            if !NetworkSimulator.shared.isOnline {
                throw CloudBackupError.networkUnavailable
            }
        }
        
        try await Task.sleep(nanoseconds: UInt64(syncDelay * 1_000_000_000))
        
        if !shouldSucceed {
            throw CloudBackupError.syncFailed
        }
        
        // Check for conflicts
        if let existingItem = cloudStorage[item.id.uuidString] {
            try await resolveConflict(existing: existingItem, incoming: CloudItem(from: item))
        } else {
            cloudStorage[item.id.uuidString] = CloudItem(from: item)
        }
    }
    
    public func fetchItemFromCloud(id: UUID) async throws -> Item? {
        if shouldSimulateNetworkIssues {
            await NetworkSimulator.shared.simulate(condition: .slow(latency: syncDelay))
            
            if !NetworkSimulator.shared.isOnline {
                throw CloudBackupError.networkUnavailable
            }
        }
        
        guard let cloudItem = cloudStorage[id.uuidString] else {
            return nil
        }
        
        return cloudItem.toItem()
    }
    
    public func getCloudStorageInfo() async throws -> CloudStorageInfo {
        let usedBytes = Int(Double(storageQuotaLimit) * storageQuotaUsed)
        
        return CloudStorageInfo(
            totalQuota: storageQuotaLimit,
            usedBytes: usedBytes,
            itemCount: cloudStorage.count,
            lastSyncDate: Date()
        )
    }
    
    public func performFullSync() async throws -> SyncResult {
        try await Task.sleep(nanoseconds: UInt64(syncDelay * 5 * 1_000_000_000)) // Longer for full sync
        
        if !shouldSucceed {
            throw CloudBackupError.syncFailed
        }
        
        return SyncResult(
            syncedItems: cloudStorage.count,
            conflicts: 0,
            errors: 0,
            duration: syncDelay * 5
        )
    }
    
    private func resolveConflict(existing: CloudItem, incoming: CloudItem) async throws {
        switch conflictResolutionStrategy {
        case .lastWriteWins:
            if incoming.lastModified >= existing.lastModified {
                cloudStorage[incoming.id] = incoming
            }
        case .firstWriteWins:
            // Keep existing item
            break
        case .userPrompt:
            // In real implementation, this would prompt the user
            cloudStorage[incoming.id] = incoming
        case .mergeBoth:
            // In real implementation, this would merge the data
            cloudStorage[incoming.id] = incoming
        }
    }
    
    // Helper method to clear cloud storage for testing
    public func clearCloudStorage() {
        cloudStorage.removeAll()
    }
    
    // Helper method to inject test data
    public func injectCloudItem(_ item: Item) {
        cloudStorage[item.id.uuidString] = CloudItem(from: item)
    }
}

// MARK: - Enhanced Network Client Mock

public class EnhancedMockNetworkClient {
    
    public var shouldSucceed = true
    public var responseDelay: Double = 0.3
    public var shouldSimulateNetworkIssues = false
    
    // Simulated API responses for insurance-related requests
    private let mockResponses: [String: MockAPIResponse] = [
        "/api/items/validate": MockAPIResponse(
            statusCode: 200,
            data: ["valid": true, "suggestions": ["Add serial number", "Include warranty information"]]
        ),
        "/api/receipts/process": MockAPIResponse(
            statusCode: 200,
            data: ["extracted_data": ["merchant": "Apple Store", "total": 2499.00, "date": "2024-01-15"]]
        ),
        "/api/insurance/reports/generate": MockAPIResponse(
            statusCode: 200,
            data: ["report_id": "RPT-12345", "status": "processing", "estimated_completion": "2024-01-15T10:30:00Z"]
        ),
        "/api/warranty/lookup": MockAPIResponse(
            statusCode: 200,
            data: ["warranty_status": "active", "expires_at": "2025-01-15", "coverage_type": "standard"]
        )
    ]
    
    public func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) async throws -> T {
        
        if shouldSimulateNetworkIssues {
            await NetworkSimulator.shared.simulate(condition: NetworkSimulator.shared.currentCondition)
            
            if !NetworkSimulator.shared.isOnline {
                throw NetworkError.connectionFailed
            }
        }
        
        try await Task.sleep(nanoseconds: UInt64(responseDelay * 1_000_000_000))
        
        if !shouldSucceed {
            throw NetworkError.requestFailed(statusCode: 500)
        }
        
        guard let mockResponse = mockResponses[endpoint] else {
            throw NetworkError.notFound
        }
        
        if mockResponse.statusCode >= 400 {
            throw NetworkError.requestFailed(statusCode: mockResponse.statusCode)
        }
        
        let responseData = try JSONSerialization.data(withJSONObject: mockResponse.data)
        return try JSONDecoder().decode(T.self, from: responseData)
    }
}

// MARK: - Supporting Types

public struct ReceiptScenario {
    var merchantName: String
    var items: [ReceiptItem]
    var total: Decimal
    var date: Date
    var confidence: Double
}

public struct ReceiptItem {
    let name: String
    let price: Decimal
    let category: String
}

public struct CloudItem {
    let id: String
    let name: String
    let purchasePrice: Decimal?
    let lastModified: Date
    let data: Data
    
    init(from item: Item) {
        self.id = item.id.uuidString
        self.name = item.name
        self.purchasePrice = item.purchasePrice
        self.lastModified = item.updatedAt
        
        // Serialize item data (simplified)
        let encoder = JSONEncoder()
        self.data = (try? encoder.encode(ItemData(from: item))) ?? Data()
    }
    
    func toItem() -> Item {
        let item = Item(name: name)
        item.id = UUID(uuidString: id) ?? UUID()
        item.purchasePrice = purchasePrice
        item.updatedAt = lastModified
        return item
    }
}

public struct ItemData: Codable {
    let id: String
    let name: String
    let purchasePrice: Decimal?
    
    init(from item: Item) {
        self.id = item.id.uuidString
        self.name = item.name
        self.purchasePrice = item.purchasePrice
    }
}

public struct CloudStorageInfo {
    let totalQuota: Int
    let usedBytes: Int  
    let itemCount: Int
    let lastSyncDate: Date
}

public struct SyncResult {
    let syncedItems: Int
    let conflicts: Int
    let errors: Int
    let duration: Double
}

public struct MockAPIResponse {
    let statusCode: Int
    let data: [String: Any]
}

public enum HTTPMethod {
    case GET, POST, PUT, DELETE
}

// MARK: - Error Types

public enum ReceiptOCRError: Error {
    case networkUnavailable
    case processingFailed
    case invalidImageFormat
    case serviceQuotaExceeded
}

public enum InsuranceReportError: Error {
    case networkUnavailable
    case generationFailed
    case templateNotFound
    case insufficientData
    case storageQuotaExceeded
}

public enum CloudBackupError: Error {
    case networkUnavailable
    case syncFailed
    case quotaExceeded
    case conflictResolutionFailed
    case authenticationFailed
}

public enum NetworkError: Error {
    case connectionFailed
    case requestFailed(statusCode: Int)
    case notFound
    case timeout
    case invalidResponse
}

// MARK: - Date Formatters

extension DateFormatter {
    static let receiptFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let reportFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

// MARK: - Protocol Definitions (for reference)

public protocol ReceiptOCRServiceProtocol {
    func processReceiptImage(_ imageData: Data) async throws -> ReceiptData
}

public protocol InsuranceReportServiceProtocol {
    func generateInsuranceReport(for items: [Item], options: InsuranceReportOptions) async throws -> Data
    func exportItemsAsCSV(_ items: [Item]) async throws -> Data
}

public protocol CloudBackupServiceProtocol {
    func syncItemToCloud(_ item: Item) async throws
    func fetchItemFromCloud(id: UUID) async throws -> Item?
    func getCloudStorageInfo() async throws -> CloudStorageInfo
    func performFullSync() async throws -> SyncResult
}

// MARK: - Additional Supporting Types

public struct ReceiptData {
    let merchantName: String
    let totalAmount: Decimal
    let purchaseDate: Date
    let items: [ExtractedReceiptItem]
    let confidence: Double
    let rawText: String
}

public struct ExtractedReceiptItem {
    let name: String
    let price: Decimal
    let category: String
    let confidence: Double
}

public struct InsuranceReportOptions {
    let includePhotos: Bool
    let includeReceipts: Bool
    let includeWarrantyInfo: Bool
    let includeConditionAssessment: Bool
    
    init(includePhotos: Bool = true, includeReceipts: Bool = true, includeWarrantyInfo: Bool = true, includeConditionAssessment: Bool = false) {
        self.includePhotos = includePhotos
        self.includeReceipts = includeReceipts
        self.includeWarrantyInfo = includeWarrantyInfo
        self.includeConditionAssessment = includeConditionAssessment
    }
}