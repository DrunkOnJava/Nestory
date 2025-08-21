#!/usr/bin/env swift
import Foundation
import SwiftParser
import SwiftSyntax

// MARK: - Command Line Interface

enum Command: String, CaseIterable {
    case check
    case archVerify = "arch-verify"
    case specVerify = "spec-verify"
    case specCommit = "spec-commit"
    case spmAudit = "spm-audit"
    case licenses

    var description: String {
        switch self {
        case .check:
            "Run all verification checks"
        case .archVerify:
            "Verify architecture conformance"
        case .specVerify:
            "Verify SPEC.json hash matches SPEC.lock"
        case .specCommit:
            "Update SPEC.lock with new hash"
        case .spmAudit:
            "Audit SPM dependencies are pinned"
        case .licenses:
            "Update third-party licenses"
        }
    }
}

// MARK: - Main

let arguments = CommandLine.arguments
guard arguments.count > 1 else {
    print("Usage: nestoryctl <command>")
    print()
    print("Available commands:")
    for command in Command.allCases {
        print("  \(command.rawValue) - \(command.description)")
    }
    exit(1)
}

let commandString = arguments[1]
guard let command = Command(rawValue: commandString) else {
    print("Unknown command: \(commandString)")
    print("Available commands: \(Command.allCases.map(\.rawValue).joined(separator: ", "))")
    exit(1)
}

guard let projectRoot = findProjectRoot() else {
    print("❌ Error: Could not find SPEC.json. Make sure you're in a project directory.")
    exit(1)
}

let specFile = projectRoot.appendingPathComponent("SPEC.json")

do {
    let specData = try Data(contentsOf: specFile)
    let spec = try JSONDecoder().decode(ArchitectureSpec.self, from: specData)

    switch command {
    case .check:
        exit(performCheck(projectRoot: projectRoot, spec: spec))
    case .archVerify:
        exit(performArchVerify(projectRoot: projectRoot, spec: spec))
    case .specVerify:
        exit(performSpecVerify(projectRoot: projectRoot))
    case .specCommit:
        exit(performSpecCommit(projectRoot: projectRoot))
    case .spmAudit:
        exit(performSpmAudit(projectRoot: projectRoot))
    case .licenses:
        exit(performLicensesUpdate(projectRoot: projectRoot))
    }
} catch {
    print("❌ Error: \(error)")
    exit(1)
}

// MARK: - Command Implementations

func performCheck(projectRoot: URL, spec: ArchitectureSpec) -> Int32 {
    print("🔍 Running comprehensive project checks...")
    
    var allPassed = true
    
    // Architecture verification
    print("\n📐 Checking architecture conformance...")
    if performArchVerify(projectRoot: projectRoot, spec: spec) != 0 {
        allPassed = false
    }
    
    // SPEC.json verification
    print("\n📋 Checking SPEC.json integrity...")
    if performSpecVerify(projectRoot: projectRoot) != 0 {
        allPassed = false
    }
    
    // SPM audit
    print("\n📦 Auditing SPM dependencies...")
    if performSpmAudit(projectRoot: projectRoot) != 0 {
        allPassed = false
    }
    
    if allPassed {
        print("\n✅ All checks passed!")
        return 0
    } else {
        print("\n❌ Some checks failed!")
        return 1
    }
}

func performArchVerify(projectRoot: URL, spec: ArchitectureSpec) -> Int32 {
    print("📐 Verifying architecture...")
    
    var violations: [String] = []
    var fileSizeViolations: [String] = []
    
    // Check file sizes first (new feature)
    let swiftFiles = findSwiftFiles(in: projectRoot)
    
    for file in swiftFiles {
        do {
            let content = try String(contentsOf: file)
            let lineCount = content.components(separatedBy: .newlines).count
            let relativePath = file.path.replacingOccurrences(of: projectRoot.path + "/", with: "")
            
            if lineCount > 600 {
                fileSizeViolations.append("  \(relativePath) - CRITICAL: \(lineCount) lines (>600 lines) - MUST be modularized")
            } else if lineCount > 500 {
                fileSizeViolations.append("  \(relativePath) - HIGH: \(lineCount) lines (>500 lines) - Should be modularized")
            } else if lineCount > 400 {
                fileSizeViolations.append("  \(relativePath) - MEDIUM: \(lineCount) lines (>400 lines) - Consider modularizing")
            }
        } catch {
            print("⚠️  Could not read file: \(file.path)")
        }
    }
    
    // Report file size violations
    if !fileSizeViolations.isEmpty {
        print("\n📏 File Size Analysis:")
        for violation in fileSizeViolations.prefix(20) { // Limit output
            print(violation)
        }
        if fileSizeViolations.count > 20 {
            print("  ... and \(fileSizeViolations.count - 20) more files")
        }
        
        let criticalCount = fileSizeViolations.filter { $0.contains("CRITICAL") }.count
        if criticalCount > 0 {
            violations.append("Found \(criticalCount) files exceeding 600 lines (critical threshold)")
        }
    }
    
    // Check import relationships (simplified version)
    var importViolations: [String] = []
    for file in swiftFiles.prefix(50) { // Limit to avoid timeout
        if let moduleViolations = checkImportCompliance(file: file, spec: spec, projectRoot: projectRoot) {
            importViolations.append(contentsOf: moduleViolations)
        }
    }
    
    violations.append(contentsOf: importViolations)
    
    if violations.isEmpty {
        print("✅ Architecture verification passed!")
        return 0
    } else {
        print("\n❌ Architecture violations found:")
        for violation in violations.prefix(10) { // Limit output
            print("  • \(violation)")
        }
        if violations.count > 10 {
            print("  ... and \(violations.count - 10) more violations")
        }
        return 1
    }
}

func performSpecVerify(projectRoot: URL) -> Int32 {
    print("📋 Verifying SPEC.json integrity...")
    
    let specFile = projectRoot.appendingPathComponent("SPEC.json")
    let lockFile = projectRoot.appendingPathComponent("SPEC.lock")
    
    guard FileManager.default.fileExists(atPath: lockFile.path) else {
        print("⚠️  SPEC.lock not found. Run 'nestoryctl spec-commit' to create it.")
        return 1
    }
    
    do {
        let currentHash = try computeSHA256(of: specFile)
        let lockContent = try String(contentsOf: lockFile).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentHash == lockContent {
            print("✅ SPEC.json verified!")
            return 0
        } else {
            print("❌ SPEC.json has been modified without updating SPEC.lock")
            print("   Current hash: \(currentHash)")
            print("   Expected hash: \(lockContent)")
            print("   Run 'nestoryctl spec-commit' to update the lock file.")
            return 1
        }
    } catch {
        print("❌ Error verifying SPEC.json: \(error)")
        return 1
    }
}

func performSpecCommit(projectRoot: URL) -> Int32 {
    print("📋 Updating SPEC.lock...")
    
    let specFile = projectRoot.appendingPathComponent("SPEC.json")
    let lockFile = projectRoot.appendingPathComponent("SPEC.lock")
    
    do {
        let hash = try computeSHA256(of: specFile)
        try hash.write(to: lockFile, atomically: true, encoding: .utf8)
        print("✅ SPEC.lock updated with hash: \(hash)")
        return 0
    } catch {
        print("❌ Error updating SPEC.lock: \(error)")
        return 1
    }
}

func performSpmAudit(projectRoot: URL) -> Int32 {
    print("📦 Auditing SPM dependencies...")
    
    let packageResolved = projectRoot.appendingPathComponent("Package.resolved")
    
    guard FileManager.default.fileExists(atPath: packageResolved.path) else {
        print("⚠️  Package.resolved not found. This might not be an SPM project.")
        return 1
    }
    
    do {
        let data = try Data(contentsOf: packageResolved)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        // Basic validation - could be expanded
        if let pins = json?["pins"] as? [[String: Any]] {
            let unpinnedDeps = pins.filter { pin in
                guard let state = pin["state"] as? [String: Any],
                      let revision = state["revision"] as? String else {
                    return true
                }
                return revision.isEmpty
            }
            
            if unpinnedDeps.isEmpty {
                print("✅ All SPM dependencies are properly pinned!")
                return 0
            } else {
                print("⚠️  Found \(unpinnedDeps.count) unpinned dependencies")
                return 1
            }
        } else {
            print("❌ Could not parse Package.resolved")
            return 1
        }
    } catch {
        print("❌ Error auditing SPM dependencies: \(error)")
        return 1
    }
}

func performLicensesUpdate(projectRoot: URL) -> Int32 {
    print("📄 Updating third-party licenses...")
    print("ℹ️  License update functionality not yet implemented")
    return 0
}

// MARK: - Helper Functions

func findSwiftFiles(in directory: URL) -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles, .skipsPackageDescendants]
    ) else {
        return []
    }
    
    var swiftFiles: [URL] = []
    
    for case let fileURL as URL in enumerator {
        if fileURL.pathExtension == "swift" {
            // Skip build directories and derived data
            let path = fileURL.path
            if path.contains("/.build/") || 
               path.contains("/DerivedData/") || 
               path.contains("/build/") ||
               path.contains("/SourcePackages/") {
                continue
            }
            swiftFiles.append(fileURL)
        }
    }
    
    return swiftFiles
}

func checkImportCompliance(file: URL, spec: ArchitectureSpec, projectRoot: URL) -> [String]? {
    do {
        let content = try String(contentsOf: file)
        let relativePath = file.path.replacingOccurrences(of: projectRoot.path + "/", with: "")
        
        // Determine layer from file path
        let layer = determineLayer(from: relativePath)
        guard let allowedImports = spec.allowedImports[layer] else {
            return nil // Unknown layer, skip validation
        }
        
        // Find import statements
        let importRegex = try NSRegularExpression(pattern: "^import\\s+(\\w+)", options: [.anchorsMatchLines])
        let matches = importRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        var violations: [String] = []
        for match in matches {
            if let range = Range(match.range(at: 1), in: content) {
                let importedModule = String(content[range])
                if !allowedImports.contains(importedModule) && !isSystemModule(importedModule) {
                    violations.append("Layer '\(layer)' importing disallowed module '\(importedModule)' in \(relativePath)")
                }
            }
        }
        
        return violations.isEmpty ? nil : violations
        
    } catch {
        return nil
    }
}

func determineLayer(from path: String) -> String {
    if path.hasPrefix("Foundation/") { return "Foundation" }
    if path.hasPrefix("Infrastructure/") { return "Infrastructure" }
    if path.hasPrefix("Services/") { return "Services" }
    if path.hasPrefix("UI/") { return "UI" }
    if path.hasPrefix("Features/") { return "Features" }
    if path.hasPrefix("App-Main/") { return "App" }
    return "Unknown"
}

func isSystemModule(_ module: String) -> Bool {
    let systemModules = [
        "SwiftUI", "UIKit", "Foundation", "Combine", "SwiftData",
        "CoreData", "CloudKit", "Vision", "VisionKit", "AVFoundation",
        "Photos", "PhotosUI", "MessageUI", "StoreKit", "UserNotifications",
        "CoreLocation", "MapKit", "WebKit", "SafariServices", "QuickLook",
        "UniformTypeIdentifiers", "CryptoKit", "LocalAuthentication",
        "BackgroundTasks", "WidgetKit", "Intents", "CoreSpotlight",
        "PassKit", "SwiftParser", "SwiftSyntax"
    ]
    return systemModules.contains(module)
}