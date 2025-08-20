#!/usr/bin/env swift

//
// Layer: Infrastructure
// Module: Configuration Generator
// Purpose: Generate all project configurations from single source of truth
//

import Foundation

// MARK: - Configuration Models

struct ProjectConfiguration: Codable {
    let project: ProjectInfo
    let environments: [String: Environment]
    let derivedValues: DerivedValues
    let deploymentRings: [String: DeploymentRing]
}

struct ProjectInfo: Codable {
    let name: String
    let displayName: String
    let version: String
    let buildNumber: String
    let teamId: String
    let organizationName: String
    let minIOSVersion: String
    let swiftVersion: String
}

struct Environment: Codable {
    let name: String
    let displayName: String
    let bundleIdSuffix: String
    let productNameSuffix: String
    let cloudKitContainer: String
    let apiBaseURL: String
    let fxAPIEndpoint: String
    let buildConfiguration: String
    let archiveConfiguration: String
    let featureFlags: FeatureFlags
    let codeSign: CodeSign
}

struct FeatureFlags: Codable {
    let debugMenu: Bool
    let analytics: Bool
    let crashReporting: Bool
    let remoteConfig: Bool
    let allFeatures: Bool
    let performanceLogging: Bool
    let memoryDebugging: Bool
}

struct CodeSign: Codable {
    let style: String
    let identity: String
    let provisioningProfile: String?
}

struct DerivedValues: Codable {
    let baseBundleId: String
    let baseProductName: String
    let simulator: Simulator
    let schemes: [String: String]
    let buildTimeouts: BuildTimeouts
}

struct Simulator: Codable {
    let name: String
    let os: String
}

struct BuildTimeouts: Codable {
    let build: Int
    let test: Int
    let archive: Int
}

struct DeploymentRing: Codable {
    let name: String
    let environment: String
    let audience: String
    let size: CodableSize
    let duration: String
    let rollbackTime: String
}

enum CodableSize: Codable {
    case number(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Int.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            throw DecodingError.typeMismatch(
                CodableSize.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or String")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .number(number):
            try container.encode(number)
        case let .string(string):
            try container.encode(string)
        }
    }
}

// MARK: - Configuration Generator

class ConfigurationGenerator {
    private let config: ProjectConfiguration
    private let baseDir: URL

    init(configPath: String) throws {
        let configURL = URL(fileURLWithPath: configPath)
        let data = try Data(contentsOf: configURL)
        self.config = try JSONDecoder().decode(ProjectConfiguration.self, from: data)
        self.baseDir = configURL.deletingLastPathComponent().deletingLastPathComponent()
    }

    func generateAll() throws {
        print("🔧 Generating project configurations from master source...")

        try generateXcodeGenProject()
        try generateXcconfigs()
        try generateMakefile()
        try generateEnvironmentConfiguration()
        try generateRingsDocumentation()

        print("✅ All configurations generated successfully!")
    }

    // MARK: - XcodeGen project.yml Generation

    private func generateXcodeGenProject() throws {
        print("📱 Generating project.yml...")

        let projectYml = """
        name: \(config.project.name)
        options:
          bundleIdPrefix: \(config.derivedValues.baseBundleId)
          deploymentTarget:
            iOS: \(config.project.minIOSVersion)
          developmentLanguage: en
          xcodeVersion: 15.0
          createIntermediateGroups: true
          generateEmptyDirectories: true

        attributes:
          ORGANIZATIONNAME: \(config.project.organizationName)
          DEVELOPMENT_TEAM: \(config.project.teamId)

        configs:
          Debug:
            xcconfig: Config/Debug.xcconfig
          Release:
            xcconfig: Config/Release.xcconfig

        settings:
          base:
            IPHONEOS_DEPLOYMENT_TARGET: \(config.project.minIOSVersion)
            SWIFT_VERSION: \(config.project.swiftVersion)
            DEVELOPMENT_TEAM: \(config.project.teamId)
            CODE_SIGN_STYLE: Automatic
            CURRENT_PROJECT_VERSION: \(config.project.buildNumber)
            MARKETING_VERSION: \(config.project.version)
            ENABLE_BITCODE: NO
            DEBUG_INFORMATION_FORMAT: dwarf-with-dsym
            ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
          configs:
            Debug:
              SWIFT_STRICT_CONCURRENCY: minimal
              SWIFT_TREAT_WARNINGS_AS_ERRORS: NO
              OTHER_SWIFT_FLAGS: "-Xfrontend -disable-availability-checking -suppress-warnings"
              DEBUG_INFORMATION_FORMAT: dwarf-with-dsym
            Release:
              SWIFT_STRICT_CONCURRENCY: complete
              DEBUG_INFORMATION_FORMAT: dwarf-with-dsym

        packages: {}

        targets:
          \(config.project.name):
            type: application
            platform: iOS
            deploymentTarget: \(config.project.minIOSVersion)

            sources:
              - path: App-Main
                excludes:
                  - "RootFeature.swift"
                  - "RootView.swift"
                  - "SearchView-Old.swift"
              - path: Foundation/Models
              - path: Foundation/Core
              - path: Foundation/Utils
              - path: Infrastructure/Storage
              - path: Infrastructure/Cache
              - path: Infrastructure/Camera
              - path: Infrastructure/Security
              - path: Infrastructure/Actors
              - path: Infrastructure/Network
              - path: Infrastructure/Monitoring
              - path: Infrastructure/HotReload
                excludes:
                  - "*.swift"
              - path: Services
              - path: Services/BarcodeScannerService
              - path: Services/CloudBackupService
              - path: Services/ImportExportService
              - path: Services/InsuranceExport
              - path: Services/InsuranceReport
              - path: Services/NotificationService
              - path: Services/ReceiptOCR
              - path: UI/UI-Core
              - path: UI/UI-Components
              - path: Config/FeatureFlags.swift
              - path: Config/EnvironmentConfiguration.swift

            resources:
              - path: App-Main/Assets.xcassets
                buildPhase: resources
              - path: App-Main/Preview Content/PreviewAssets.xcassets
                buildPhase: resources

            settings:
              base:
                PRODUCT_NAME: \(config.derivedValues.baseProductName)
                PRODUCT_BUNDLE_IDENTIFIER: \(config.derivedValues.baseBundleId).dev
                INFOPLIST_FILE: App-Main/Info.plist
                ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
                ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS: YES
                ENABLE_PREVIEWS: YES
                SWIFT_UPCOMING_FEATURE_CONCURRENCY: YES
                SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY: YES

            dependencies:
              - sdk: SwiftData.framework
              - sdk: CloudKit.framework

          \(config.project.name)UITests:
            type: bundle.ui-testing
            platform: iOS
            deploymentTarget: \(config.project.minIOSVersion)
            sources:
              - \(config.project.name)UITests
            dependencies:
              - target: \(config.project.name)
            settings:
              base:
                PRODUCT_BUNDLE_IDENTIFIER: \(config.derivedValues.baseBundleId).UITests
                TEST_TARGET_NAME: \(config.project.name)
                GENERATE_INFOPLIST_FILE: YES
                SWIFT_VERSION: \(config.project.swiftVersion)
                SWIFT_STRICT_CONCURRENCY: minimal
                SWIFT_TREAT_WARNINGS_AS_ERRORS: NO

        \(generateSchemeSection())
        """

        let outputURL = baseDir.appendingPathComponent("project.yml")
        try projectYml.write(to: outputURL, atomically: true, encoding: .utf8)
    }

    private func generateSchemeSection() -> String {
        var schemes = "schemes:\n"

        for (envKey, env) in config.environments {
            let schemeName = config.derivedValues.schemes[envKey] ?? "\(config.project.name)-\(env.displayName)"
            let bundleId = config.derivedValues.baseBundleId + env.bundleIdSuffix
            let productName = config.derivedValues.baseProductName + env.productNameSuffix

            schemes += """
              \(schemeName):
                build:
                  targets:
                    \(config.project.name): all
                run:
                  config: \(env.buildConfiguration)
                  environmentVariables:
                    CLOUDKIT_CONTAINER: \(env.cloudKitContainer)
                    NESTORY_ENVIRONMENT: \(env.name)
                    API_BASE_URL: \(env.apiBaseURL)
                    FX_API_ENDPOINT: \(env.fxAPIEndpoint)
                test:
                  config: \(env.buildConfiguration)
                  targets:
                    - \(config.project.name)UITests
                profile:
                  config: \(env.buildConfiguration)
                analyze:
                  config: \(env.buildConfiguration)
                archive:
                  config: \(env.archiveConfiguration)

            """
        }

        return schemes
    }

    // MARK: - Xcconfig Generation

    private func generateXcconfigs() throws {
        print("⚙️ Generating .xcconfig files...")

        for (envKey, env) in config.environments {
            let bundleId = config.derivedValues.baseBundleId + env.bundleIdSuffix
            let productName = config.derivedValues.baseProductName + env.productNameSuffix

            let xcconfig = """
            // \(env.displayName).xcconfig - Generated from ProjectConfiguration.json
            #include "Base.xcconfig"

            // \(env.displayName)-Specific Overrides
            PRODUCT_BUNDLE_IDENTIFIER = \(bundleId)
            PRODUCT_NAME = \(productName)

            // Swift Compilation
            SWIFT_ACTIVE_COMPILATION_CONDITIONS = \(env.buildConfiguration.uppercased()) \(env.name.uppercased())_ENVIRONMENT
            GCC_PREPROCESSOR_DEFINITIONS = \(env.buildConfiguration.uppercased())=1 \(env.name.uppercased())_ENVIRONMENT=1\(env.buildConfiguration == "Debug" ? "" : " NDEBUG=1")

            // Build Configuration
            \(generateBuildSettings(for: env))

            // CloudKit
            CLOUDKIT_ENVIRONMENT = \(env.name == "production" ? "Production" : "Development")
            CLOUDKIT_CONTAINER = \(env.cloudKitContainer)

            // API Configuration
            API_BASE_URL = \(env.apiBaseURL)
            FX_API_ENDPOINT = \(env.fxAPIEndpoint)

            // Feature Flags
            \(generateFeatureFlags(for: env.featureFlags))

            // Code Signing
            CODE_SIGN_STYLE = \(env.codeSign.style)
            CODE_SIGN_IDENTITY = \(env.codeSign.identity)
            \(env.codeSign.provisioningProfile.map { "PROVISIONING_PROFILE_SPECIFIER = \($0)" } ?? "")
            """

            let filename = "\(env.displayName.capitalized).xcconfig"
            let outputURL = baseDir.appendingPathComponent("Config").appendingPathComponent(filename)
            try xcconfig.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }

    private func generateBuildSettings(for env: Environment) -> String {
        if env.buildConfiguration == "Debug" {
            """
            ENABLE_TESTABILITY = YES
            ONLY_ACTIVE_ARCH = YES
            DEBUG_INFORMATION_FORMAT = dwarf
            COPY_PHASE_STRIP = NO
            ENABLE_NS_ASSERTIONS = YES
            ENABLE_DEBUG_DYLIB = YES
            MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE
            GCC_OPTIMIZATION_LEVEL = 0
            SWIFT_OPTIMIZATION_LEVEL = -Onone
            """
        } else {
            """
            ENABLE_TESTABILITY = NO
            ONLY_ACTIVE_ARCH = NO
            DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
            COPY_PHASE_STRIP = YES
            ENABLE_NS_ASSERTIONS = NO
            VALIDATE_PRODUCT = YES
            GCC_OPTIMIZATION_LEVEL = s
            MTL_ENABLE_DEBUG_INFO = NO
            SWIFT_OPTIMIZATION_LEVEL = -O
            """
        }
    }

    private func generateFeatureFlags(for flags: FeatureFlags) -> String {
        """
        ENABLE_ANALYTICS = \(flags.analytics ? "YES" : "NO")
        ENABLE_CRASH_REPORTING = \(flags.crashReporting ? "YES" : "NO")
        ENABLE_DEBUG_MENU = \(flags.debugMenu ? "YES" : "NO")
        ENABLE_REMOTE_CONFIG = \(flags.remoteConfig ? "YES" : "NO")
        FF_ALL_FEATURES = \(flags.allFeatures ? "YES" : "NO")
        ENABLE_PERFORMANCE_LOGGING = \(flags.performanceLogging ? "YES" : "NO")
        ENABLE_MEMORY_DEBUGGING = \(flags.memoryDebugging ? "YES" : "NO")
        """
    }

    // MARK: - Makefile Generation

    private func generateMakefile() throws {
        print("🔨 Generating Makefile scheme configuration...")

        let makefileConfig = """
        # Auto-generated scheme configuration from ProjectConfiguration.json
        # DO NOT EDIT MANUALLY - Run 'make generate-config' to update

        # Project Settings
        PROJECT_NAME = \(config.project.name)
        SCHEME_DEV = \(config.derivedValues.schemes["development"] ?? "Nestory-Dev")
        SCHEME_STAGING = \(config.derivedValues.schemes["staging"] ?? "Nestory-Staging")
        SCHEME_PROD = \(config.derivedValues.schemes["production"] ?? "Nestory-Prod")
        WORKSPACE = \(config.project.name).xcworkspace
        PROJECT_FILE = \(config.project.name).xcodeproj

        # CRITICAL: Always use \(config.derivedValues.simulator.name) for consistency
        SIMULATOR_NAME = \(config.derivedValues.simulator.name)
        SIMULATOR_OS = \(config.derivedValues.simulator.os)
        DESTINATION = platform=\(config.derivedValues.simulator.os),name=\(config.derivedValues.simulator.name)

        # Build Timeouts
        BUILD_TIMEOUT = \(config.derivedValues.buildTimeouts.build)
        TEST_TIMEOUT = \(config.derivedValues.buildTimeouts.test)
        ARCHIVE_TIMEOUT = \(config.derivedValues.buildTimeouts.archive)

        # Scheme Selection (default to Dev, can be overridden)
        # Usage: make run SCHEME_TARGET=staging
        SCHEME_TARGET ?= dev
        ifeq ($(SCHEME_TARGET),staging)
            ACTIVE_SCHEME = $(SCHEME_STAGING)
            ACTIVE_CONFIG = \(config.environments["staging"]?.buildConfiguration ?? "Release")
        else ifeq ($(SCHEME_TARGET),prod)
            ACTIVE_SCHEME = $(SCHEME_PROD)
            ACTIVE_CONFIG = \(config.environments["production"]?.buildConfiguration ?? "Release")
        else
            ACTIVE_SCHEME = $(SCHEME_DEV)
            ACTIVE_CONFIG = \(config.environments["development"]?.buildConfiguration ?? "Debug")
        endif
        """

        let outputURL = baseDir.appendingPathComponent("Config/MakefileConfig.mk")
        try makefileConfig.write(to: outputURL, atomically: true, encoding: .utf8)
    }

    // MARK: - Environment Configuration Update

    private func generateEnvironmentConfiguration() throws {
        print("📱 Updating EnvironmentConfiguration.swift...")
        // This would update the Swift file with the new configuration
        // For now, we'll print the values that should be used
        print("   Environments: \(config.environments.keys.joined(separator: ", "))")
    }

    // MARK: - Documentation Generation

    private func generateRingsDocumentation() throws {
        print("📚 Generating deployment rings documentation...")

        var ringsDoc = """
        # Deployment Rings - Generated Configuration

        This file is automatically generated from `Config/ProjectConfiguration.json`.
        DO NOT EDIT MANUALLY - Run `make generate-config` to update.

        ## Overview

        \(config.project.displayName) uses a ring-based deployment strategy to progressively roll out changes with increasing confidence.

        ## Ring Definitions

        """

        for (ringKey, ring) in config.deploymentRings.sorted(by: { $0.key < $1.key }) {
            let sizeString = switch ring.size {
            case let .number(num): "~\(num) users"
            case let .string(str): str
            }

            ringsDoc += """
            ### \(ringKey.capitalized): \(ring.name)
            - **Audience:** \(ring.audience)
            - **Environment:** \(ring.environment.capitalized)
            - **Size:** \(sizeString)
            - **Duration:** \(ring.duration)
            - **Rollback:** \(ring.rollbackTime)

            """
        }

        let outputURL = baseDir.appendingPathComponent("Config/Rings-Generated.md")
        try ringsDoc.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Main Execution

func main() {
    do {
        let configPath = CommandLine.arguments.count > 1
            ? CommandLine.arguments[1]
            : "Config/ProjectConfiguration.json"

        let generator = try ConfigurationGenerator(configPath: configPath)
        try generator.generateAll()

    } catch {
        print("❌ Error: \(error)")
        exit(1)
    }
}

main()
