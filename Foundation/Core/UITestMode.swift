//
// Layer: Foundation
// Module: Core
// Purpose: UI Test Mode configuration and detection
//

import Foundation

/// UI Test Mode configuration for deterministic testing
public struct UITestMode {
    
    // MARK: - Detection
    
    /// Whether the app is running in UI test mode
    public static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("UITEST_MODE") ||
        ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
    }
    
    /// Whether to disable animations for testing
    public static var disableAnimations: Bool {
        isEnabled || ProcessInfo.processInfo.arguments.contains("DISABLE_ANIMATIONS")
    }
    
    /// Whether to auto-accept permissions
    public static var autoAcceptPermissions: Bool {
        isEnabled || ProcessInfo.processInfo.arguments.contains("AUTO_ACCEPT_PERMISSIONS")
    }
    
    /// Whether to use test fixtures instead of real data
    public static var useTestFixtures: Bool {
        isEnabled || ProcessInfo.processInfo.arguments.contains("USE_TEST_FIXTURES")
    }
    
    /// Whether to bypass login/auth flows
    public static var bypassAuth: Bool {
        isEnabled || ProcessInfo.processInfo.arguments.contains("BYPASS_AUTH")
    }
    
    /// Whether to freeze time for consistent screenshots
    public static var freezeTime: Bool {
        isEnabled || ProcessInfo.processInfo.arguments.contains("FREEZE_TIME")
    }
    
    /// Whether to disable network calls
    public static var disableNetwork: Bool {
        ProcessInfo.processInfo.arguments.contains("DISABLE_NETWORK")
    }
    
    // MARK: - Navigation
    
    /// Target screen route for direct navigation
    public static var targetRoute: String? {
        ProcessInfo.processInfo.environment["UITEST_TARGET_ROUTE"]
    }
    
    /// Starting tab for tab-based navigation
    public static var startingTab: String? {
        ProcessInfo.processInfo.environment["UITEST_START_TAB"]
    }
    
    // MARK: - Test Data
    
    /// Frozen date for consistent testing
    public static var frozenDate: Date {
        if freezeTime {
            // January 1, 2025, 12:00 PM
            return Date(timeIntervalSince1970: 1735740000)
        }
        return Date()
    }
    
    /// Test user for bypassed auth
    public static var testUser: TestUser? {
        guard bypassAuth else { return nil }
        return TestUser(
            id: "test-user-001",
            name: "Test User",
            email: "test@nestory.app"
        )
    }
    
    public struct TestUser {
        public let id: String
        public let name: String
        public let email: String
    }
    
    // MARK: - Logging
    
    /// Whether to enable verbose test logging
    public static var verboseLogging: Bool {
        isEnabled || ProcessInfo.processInfo.arguments.contains("VERBOSE_LOGGING")
    }
    
    /// Log a test-specific message
    public static func log(_ message: String, file: String = #file, line: Int = #line) {
        guard verboseLogging else { return }
        let filename = (file as NSString).lastPathComponent
        print("[UITest] \(filename):\(line) - \(message)")
    }
    
    // MARK: - Configuration
    
    /// Apply test mode configurations
    public static func configure() {
        guard isEnabled else { return }
        
        log("UI Test Mode enabled")
        
        if disableAnimations {
            log("Animations disabled")
            // This would be applied in SwiftUI views
        }
        
        if useTestFixtures {
            log("Using test fixtures")
        }
        
        if bypassAuth {
            log("Auth bypassed with test user: \(testUser?.email ?? "none")")
        }
        
        if freezeTime {
            log("Time frozen at: \(frozenDate)")
        }
        
        if let route = targetRoute {
            log("Target route: \(route)")
        }
    }
}

// MARK: - Test Fixtures

extension UITestMode {
    /// Test fixture data for consistent screenshots
    public enum TestFixture {
        case item(id: String)
        case category(name: String)
        case room(name: String)
        case warranty(id: String)
        case receipt(id: String)
        
        public var data: Any {
            switch self {
            case .item(let id):
                return TestData.sampleItem(id: id)
            case .category(let name):
                return TestData.sampleCategory(name: name)
            case .room(let name):
                return TestData.sampleRoom(name: name)
            case .warranty(let id):
                return TestData.sampleWarranty(id: id)
            case .receipt(let id):
                return TestData.sampleReceipt(id: id)
            }
        }
    }
    
    /// Static test data provider
    public struct TestData {
        public static func sampleItem(id: String) -> [String: Any] {
            [
                "id": id,
                "name": "MacBook Pro 16\"",
                "category": "Electronics",
                "room": "Home Office",
                "value": 2499.99,
                "purchaseDate": "2024-01-15",
                "serialNumber": "C02XR3ZJMD6T",
                "notes": "Work laptop with AppleCare+"
            ]
        }
        
        public static func sampleCategory(name: String) -> [String: Any] {
            [
                "name": name,
                "icon": "laptopcomputer",
                "color": "#007AFF",
                "itemCount": 12
            ]
        }
        
        public static func sampleRoom(name: String) -> [String: Any] {
            [
                "name": name,
                "floor": "Ground Floor",
                "itemCount": 25,
                "totalValue": 15750.00
            ]
        }
        
        public static func sampleWarranty(id: String) -> [String: Any] {
            [
                "id": id,
                "itemName": "Refrigerator",
                "expirationDate": "2026-06-30",
                "provider": "Samsung",
                "coverage": "Parts and Labor",
                "contactNumber": "1-800-SAMSUNG"
            ]
        }
        
        public static func sampleReceipt(id: String) -> [String: Any] {
            [
                "id": id,
                "storeName": "Best Buy",
                "date": "2024-11-25",
                "total": 1299.99,
                "items": ["Sony WH-1000XM5", "AppleCare+"],
                "paymentMethod": "Credit Card"
            ]
        }
    }
}