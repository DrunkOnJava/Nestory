//
// Layer: Infrastructure
// Module: Configuration
// Purpose: Centralized environment configuration - Generated from ProjectConfiguration.json
// ⚠️ DO NOT EDIT MANUALLY - Run 'swift Scripts/generate-project-config.swift' to update
//

import Foundation

// MARK: - Configuration Models (matches ProjectConfiguration.json)

public enum ProjectConfigurationLoader {
    static func loadConfiguration() -> ProjectConfigurationData? {
        guard let url = Bundle.main.url(forResource: "ProjectConfiguration", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            // Fallback to file system if not in bundle
            let projectURL = URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .appendingPathComponent("ProjectConfiguration.json")

            guard let data = try? Data(contentsOf: projectURL) else {
                print("⚠️ Could not load ProjectConfiguration.json - using defaults")
                return nil
            }
            return try? JSONDecoder().decode(ProjectConfigurationData.self, from: data)
        }
        return try? JSONDecoder().decode(ProjectConfigurationData.self, from: data)
    }
}

public struct ProjectConfigurationData: Codable {
    let project: ProjectInfo
    let environments: [String: EnvironmentConfig]
    let derivedValues: DerivedValues
}

public struct ProjectInfo: Codable {
    let name: String
    let displayName: String
    let version: String
    let buildNumber: String
    let teamId: String
    let organizationName: String
    let minIOSVersion: String
    let swiftVersion: String
}

public struct EnvironmentConfig: Codable {
    let name: String
    let displayName: String
    let bundleIdSuffix: String
    let productNameSuffix: String
    let cloudKitContainer: String
    let apiBaseURL: String
    let fxAPIEndpoint: String
    let buildConfiguration: String
    let archiveConfiguration: String
    let featureFlags: FeatureFlagsConfig
    let codeSign: CodeSignConfig
}

public struct FeatureFlagsConfig: Codable {
    let debugMenu: Bool
    let analytics: Bool
    let crashReporting: Bool
    let remoteConfig: Bool
    let allFeatures: Bool
    let performanceLogging: Bool
    let memoryDebugging: Bool
}

public struct CodeSignConfig: Codable {
    let style: String
    let identity: String
    let provisioningProfile: String?
}

public struct DerivedValues: Codable {
    let baseBundleId: String
    let baseProductName: String
    let simulator: SimulatorConfig
    let schemes: [String: String]
    let buildTimeouts: BuildTimeoutsConfig
}

public struct SimulatorConfig: Codable {
    let name: String
    let os: String
}

public struct BuildTimeoutsConfig: Codable {
    let build: Int
    let test: Int
    let archive: Int
}

public enum AppEnvironment: String, CaseIterable {
    case development
    case staging
    case production

    var displayName: String {
        switch self {
        case .development: "Development"
        case .staging: "Staging"
        case .production: "Production"
        }
    }
}

@MainActor
public final class EnvironmentConfiguration: ObservableObject {
    public static let shared = EnvironmentConfiguration()

    // Master configuration data
    private let configData: ProjectConfigurationData?

    // MARK: - Environment Detection

    public let currentEnvironment: AppEnvironment

    // MARK: - CloudKit Configuration

    public let cloudKitContainer: String

    // MARK: - API Configuration

    public let apiBaseURL: String
    public let fxAPIEndpoint: String

    // MARK: - App Configuration

    public let bundleIdentifier: String
    public let productName: String

    // MARK: - Feature Flags

    public let debugMenuEnabled: Bool
    public let analyticsEnabled: Bool
    public let crashReportingEnabled: Bool
    public let remoteConfigEnabled: Bool
    public let allFeaturesEnabled: Bool

    private init() {
        // Load master configuration
        self.configData = ProjectConfigurationLoader.loadConfiguration()

        // Detect environment from scheme environment variables or fallback to bundle ID
        if let envString = ProcessInfo.processInfo.environment["NESTORY_ENVIRONMENT"],
           let environment = AppEnvironment(rawValue: envString)
        {
            self.currentEnvironment = environment
        } else {
            // Fallback: detect from bundle identifier
            let bundleId = Bundle.main.bundleIdentifier ?? (configData?.derivedValues.baseBundleId ?? "com.drunkonjava.nestory") + ".dev"
            if bundleId.contains(".staging") {
                self.currentEnvironment = .staging
            } else if bundleId.contains(".dev") {
                self.currentEnvironment = .development
            } else {
                self.currentEnvironment = .production
            }
        }

        // Get environment configuration from master config
        let envConfig = configData?.environments[currentEnvironment.rawValue]

        // CloudKit Container Configuration
        if let container = ProcessInfo.processInfo.environment["CLOUDKIT_CONTAINER"] {
            self.cloudKitContainer = container
        } else if let container = envConfig?.cloudKitContainer {
            self.cloudKitContainer = container
        } else {
            // Final fallback
            switch currentEnvironment {
            case .development:
                self.cloudKitContainer = "iCloud.com.drunkonjava.nestory.dev"
            case .staging:
                self.cloudKitContainer = "iCloud.com.drunkonjava.nestory.staging"
            case .production:
                self.cloudKitContainer = "iCloud.com.drunkonjava.nestory"
            }
        }

        // API Configuration from master config
        if let apiURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            self.apiBaseURL = apiURL
        } else if let apiURL = envConfig?.apiBaseURL {
            self.apiBaseURL = apiURL
        } else {
            // Fallback
            switch currentEnvironment {
            case .development:
                self.apiBaseURL = "https://api-dev.nestory.app"
            case .staging:
                self.apiBaseURL = "https://api-staging.nestory.app"
            case .production:
                self.apiBaseURL = "https://api.nestory.app"
            }
        }

        if let fxURL = ProcessInfo.processInfo.environment["FX_API_ENDPOINT"] {
            self.fxAPIEndpoint = fxURL
        } else if let fxURL = envConfig?.fxAPIEndpoint {
            self.fxAPIEndpoint = fxURL
        } else {
            // Fallback
            switch currentEnvironment {
            case .development:
                self.fxAPIEndpoint = "https://fx-dev.nestory.app"
            case .staging:
                self.fxAPIEndpoint = "https://fx-staging.nestory.app"
            case .production:
                self.fxAPIEndpoint = "https://fx.nestory.app"
            }
        }

        // App Configuration from master config
        if let bundleId = ProcessInfo.processInfo.environment["PRODUCT_BUNDLE_IDENTIFIER"] {
            self.bundleIdentifier = bundleId
        } else if let baseBundleId = configData?.derivedValues.baseBundleId,
                  let suffix = envConfig?.bundleIdSuffix
        {
            self.bundleIdentifier = baseBundleId + suffix
        } else {
            self.bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev"
        }

        if let productName = ProcessInfo.processInfo.environment["PRODUCT_NAME"] {
            self.productName = productName
        } else if let baseProductName = configData?.derivedValues.baseProductName,
                  let suffix = envConfig?.productNameSuffix
        {
            self.productName = baseProductName + suffix
        } else {
            // Fallback
            switch currentEnvironment {
            case .development:
                self.productName = "Nestory Dev"
            case .staging:
                self.productName = "Nestory Staging"
            case .production:
                self.productName = "Nestory"
            }
        }

        // Feature Flags from master config
        if let flags = envConfig?.featureFlags {
            self.debugMenuEnabled = flags.debugMenu
            self.analyticsEnabled = flags.analytics
            self.crashReportingEnabled = flags.crashReporting
            self.remoteConfigEnabled = flags.remoteConfig
            self.allFeaturesEnabled = flags.allFeatures
        } else {
            // Fallback based on environment
            switch currentEnvironment {
            case .development:
                self.debugMenuEnabled = true
                self.analyticsEnabled = false
                self.crashReportingEnabled = false
                self.remoteConfigEnabled = false
                self.allFeaturesEnabled = true

            case .staging:
                self.debugMenuEnabled = true
                self.analyticsEnabled = true
                self.crashReportingEnabled = true
                self.remoteConfigEnabled = true
                self.allFeaturesEnabled = true

            case .production:
                self.debugMenuEnabled = false
                self.analyticsEnabled = true
                self.crashReportingEnabled = true
                self.remoteConfigEnabled = true
                self.allFeaturesEnabled = false
            }
        }
    }

    // MARK: - Computed Properties

    public var isDevelopment: Bool {
        currentEnvironment == .development
    }

    public var isStaging: Bool {
        currentEnvironment == .staging
    }

    public var isProduction: Bool {
        currentEnvironment == .production
    }

    public var isDebugBuild: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    public var environmentDisplayName: String {
        currentEnvironment.displayName
    }

    // MARK: - Logging

    public func logConfiguration() {
        print("🔧 Environment Configuration")
        print("   Environment: \(currentEnvironment.rawValue)")
        print("   CloudKit Container: \(cloudKitContainer)")
        print("   API Base URL: \(apiBaseURL)")
        print("   Bundle ID: \(bundleIdentifier)")
        print("   Product Name: \(productName)")
        print("   Debug Menu: \(debugMenuEnabled)")
        print("   Analytics: \(analyticsEnabled)")
    }
}
