// Layer: Config
// Module: Config
// Purpose: Template for secrets configuration (DO NOT COMMIT ACTUAL VALUES)

import Foundation

/// Template for application secrets
/// Copy this file to Secrets.swift and add actual values
/// NEVER commit Secrets.swift to version control
enum SecretsTemplate {
    
    // MARK: - CloudKit
    
    /// CloudKit container identifier
    static let cloudKitContainer = "iCloud.com.nestory.REPLACE_ME"
    
    // MARK: - API Keys
    
    /// Currency exchange API key
    static let currencyAPIKey = "REPLACE_WITH_FX_API_KEY"
    
    /// Barcode scanning API key (if using external service)
    static let barcodeAPIKey = "REPLACE_WITH_BARCODE_API_KEY"
    
    /// OCR service API key
    static let ocrAPIKey = "REPLACE_WITH_OCR_API_KEY"
    
    // MARK: - Analytics
    
    /// Analytics service API key (if using external service)
    static let analyticsAPIKey = "REPLACE_WITH_ANALYTICS_API_KEY"
    
    // MARK: - OAuth
    
    /// Google OAuth client ID (for Google Sign-In)
    static let googleClientID = "REPLACE_WITH_GOOGLE_CLIENT_ID"
    
    /// Apple Sign-In service ID
    static let appleServiceID = "com.nestory.signin"
    
    // MARK: - App Store
    
    /// Shared secret for receipt validation
    static let appStoreSharedSecret = "REPLACE_WITH_APP_STORE_SHARED_SECRET"
    
    // MARK: - Push Notifications
    
    /// Push notification server key
    static let pushServerKey = "REPLACE_WITH_PUSH_SERVER_KEY"
    
    // MARK: - Environment URLs
    
    /// Backend API base URL
    static let apiBaseURL = URL(string: "https://api.nestory.com")!
    
    /// Currency API base URL
    static let currencyAPIBaseURL = URL(string: "https://api.exchangerate-api.com/v4")!
    
    // MARK: - Feature Flags
    
    /// Enable debug logging
    static let enableDebugLogging = false
    
    /// Enable crash reporting
    static let enableCrashReporting = true
    
    /// Enable analytics
    static let enableAnalytics = true
    
    /// Enable CloudKit sync
    static let enableCloudSync = true
    
    // MARK: - Build Configuration
    
    /// Current environment
    static let environment: Environment = .production
    
    enum Environment: String {
        case development = "dev"
        case staging = "staging"
        case production = "prod"
        
        var bundleID: String {
            switch self {
            case .development: return "com.nestory.app.dev"
            case .staging: return "com.nestory.app.staging"
            case .production: return "com.nestory.app"
            }
        }
        
        var displayName: String {
            switch self {
            case .development: return "Nestory (Dev)"
            case .staging: return "Nestory (Staging)"
            case .production: return "Nestory"
            }
        }
    }
}

// MARK: - Security Notice

/*
 SECURITY CHECKLIST:
 
 1. [ ] Copy this file to Secrets.swift
 2. [ ] Add Secrets.swift to .gitignore
 3. [ ] Replace all REPLACE_ME values with actual credentials
 4. [ ] Store credentials securely in a password manager
 5. [ ] Use environment-specific credentials
 6. [ ] Rotate credentials regularly
 7. [ ] Never log credentials
 8. [ ] Use Apple Keychain for runtime storage
 
 For CI/CD:
 - Use environment variables or secure secret management
 - Generate Secrets.swift during build process
 - Never store credentials in CI configuration files
 */