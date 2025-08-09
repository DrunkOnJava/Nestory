#!/usr/bin/env swift
import Foundation
import SwiftSyntax
import SwiftParser

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
            return "Run all verification checks"
        case .archVerify:
            return "Verify architecture conformance"
        case .specVerify:
            return "Verify SPEC.json hash matches SPEC.lock"
        case .specCommit:
            return "Update SPEC.lock with new hash"
        case .spmAudit:
            return "Audit SPM dependencies are pinned"
        case .licenses:
            return "Update third-party licenses"
        }
    }
}

// MARK: - Models

struct ArchitectureSpec: Codable {
    let app: String
    let teamId: String
    let bundleIds: [String: String]
    let minOS: String
    let language: String
    let state: String
    let persistence: String
    let sync: String
    let layers: [String]
    let features: [String]
    let allowedImports: [String: [String]]
    let slo: SLO
    let ci: CI
    let policy: Policy
    
    struct SLO: Codable {
        let coldStartP95Ms: Int
        let dbRead50P95Ms: Int
        let scrollJankPctMax: Int
        let crashFreeMin: Double
    }
    
    struct CI: Codable {
        let coverageMin: Double
        let perfBudgetEnforced: Bool
        let archTestEnforced: Bool
        let spmPinned: Bool
        let specGuard: Bool
    }
    
    struct Policy: Codable {
        let banTrackingSDKs: Bool
        let requireADRForNewDeps: Bool
        let precommitHooks: Bool
    }
}

struct ImportEdge {
    let fromFile: String
    let fromModule: String
    let toModule: String
    let line: Int
}

// MARK: - Core Functions

func findProjectRoot() -> URL? {
    var currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    
    while currentPath.path != "/" {
        let specPath = currentPath.appendingPathComponent("SPEC.json")
        if FileManager.default.fileExists(atPath: specPath.path) {
            return currentPath
        }
        currentPath = currentPath.deletingLastPathComponent()
    }
    
    return nil
}

func computeSHA256(of file: URL) throws -> String {
    let data = try Data(contentsOf: file)
    let digest = data.withUnsafeBytes { bytes in
        var hash = [UInt8](repeating: 0, count: Int(32))
        CC_SHA256(bytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(data.count), &hash)
        return hash
    }
    return digest.map { String(format: "%02x", $0) }.joined()
}

// Fallback SHA256 implementation for systems without CommonCrypto
func computeSHA256Fallback(of file: URL) throws -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/shasum")
    task.arguments = ["-a", "256", file.path]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    try task.run()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output.split(separator: " ").first.map(String.init) ?? ""
}

// MARK: - Command Implementations

func runCheck(projectRoot: URL) -> Int32 {
    print("🔍 Running all checks...")
    
    var exitCode: Int32 = 0
    
    print("\n📋 Spec verification:")
    exitCode |= runSpecVerify(projectRoot: projectRoot)
    
    print("\n🏗️ Architecture verification:")
    exitCode |= runArchVerify(projectRoot: projectRoot)
    
    print("\n📦 SPM audit:")
    exitCode |= runSpmAudit(projectRoot: projectRoot)
    
    print("\n📜 License check:")
    exitCode |= runLicenses(projectRoot: projectRoot)
    
    if exitCode == 0 {
        print("\n✅ All checks passed!")
    } else {
        print("\n❌ Some checks failed. Please fix the issues above.")
    }
    
    return exitCode
}

func runSpecVerify(projectRoot: URL) -> Int32 {
    let specPath = projectRoot.appendingPathComponent("SPEC.json")
    let lockPath = projectRoot.appendingPathComponent("SPEC.lock")
    
    guard FileManager.default.fileExists(atPath: specPath.path) else {
        print("❌ SPEC.json not found")
        return 1
    }
    
    guard FileManager.default.fileExists(atPath: lockPath.path) else {
        print("❌ SPEC.lock not found")
        return 1
    }
    
    do {
        let currentHash = try computeSHA256Fallback(of: specPath).trimmingCharacters(in: .whitespacesAndNewlines)
        let lockHash = try String(contentsOf: lockPath).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentHash == lockHash {
            print("✅ SPEC.json hash matches SPEC.lock")
            return 0
        } else {
            print("❌ SPEC.json has been modified without updating SPEC.lock")
            print("   Current: \(currentHash)")
            print("   Expected: \(lockHash)")
            print("   Run 'nestoryctl spec-commit' to update SPEC.lock")
            return 1
        }
    } catch {
        print("❌ Error verifying spec: \(error)")
        return 1
    }
}

func runSpecCommit(projectRoot: URL) -> Int32 {
    let specPath = projectRoot.appendingPathComponent("SPEC.json")
    let lockPath = projectRoot.appendingPathComponent("SPEC.lock")
    let changeLogPath = projectRoot.appendingPathComponent("SPEC_CHANGE.md")
    let decisionsPath = projectRoot.appendingPathComponent("DECISIONS.md")
    
    // Check for required documentation
    if !FileManager.default.fileExists(atPath: changeLogPath.path) {
        print("❌ SPEC_CHANGE.md not found. Please document your changes before committing.")
        return 1
    }
    
    if !FileManager.default.fileExists(atPath: decisionsPath.path) {
        print("❌ DECISIONS.md not found. Please add an ADR entry for this change.")
        return 1
    }
    
    do {
        let newHash = try computeSHA256Fallback(of: specPath).trimmingCharacters(in: .whitespacesAndNewlines)
        try newHash.write(to: lockPath, atomically: true, encoding: .utf8)
        print("✅ SPEC.lock updated with hash: \(newHash)")
        print("📝 Remember to commit SPEC_CHANGE.md and DECISIONS.md with your changes")
        return 0
    } catch {
        print("❌ Error updating SPEC.lock: \(error)")
        return 1
    }
}

func runArchVerify(projectRoot: URL) -> Int32 {
    let specPath = projectRoot.appendingPathComponent("SPEC.json")
    
    guard FileManager.default.fileExists(atPath: specPath.path) else {
        print("⚠️ SPEC.json not found, skipping architecture verification")
        return 0
    }
    
    do {
        let specData = try Data(contentsOf: specPath)
        let spec = try JSONDecoder().decode(ArchitectureSpec.self, from: specData)
        
        let swiftFiles = findSwiftFiles(in: projectRoot)
        
        if swiftFiles.isEmpty {
            print("✅ No Swift files found - architecture is compliant")
            return 0
        }
        
        var violations: [String] = []
        
        for file in swiftFiles {
            let imports = try extractImports(from: file)
            let module = inferModule(from: file, rootPath: projectRoot)
            
            for (importedModule, line) in imports {
                if !isImportAllowed(from: module, to: importedModule, spec: spec) {
                    let relativePath = file.path.replacingOccurrences(of: projectRoot.path + "/", with: "")
                    violations.append(
                        "  \(relativePath):\(line) - Illegal import: \(module) → \(importedModule)"
                    )
                }
            }
        }
        
        if violations.isEmpty {
            print("✅ Architecture verification passed")
            return 0
        } else {
            print("❌ Architecture violations detected:")
            violations.forEach { print($0) }
            return 1
        }
    } catch {
        print("❌ Error during architecture verification: \(error)")
        return 1
    }
}

func runSpmAudit(projectRoot: URL) -> Int32 {
    let resolvedPath = projectRoot.appendingPathComponent("Package.resolved")
    
    if !FileManager.default.fileExists(atPath: resolvedPath.path) {
        print("⚠️ Package.resolved not found")
        print("   Run 'swift package resolve' to generate it")
        return 0  // Don't fail on missing, just warn
    }
    
    do {
        let data = try Data(contentsOf: resolvedPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let pins = json?["pins"] as? [[String: Any]] {
            var unpinnedPackages: [String] = []
            
            for pin in pins {
                if let package = pin["identity"] as? String,
                   let state = pin["state"] as? [String: Any] {
                    if state["branch"] != nil {
                        unpinnedPackages.append(package)
                    }
                }
            }
            
            if unpinnedPackages.isEmpty {
                print("✅ All packages are properly pinned")
                return 0
            } else {
                print("❌ Found unpinned packages:")
                unpinnedPackages.forEach { print("  - \($0)") }
                return 1
            }
        }
        
        print("✅ Package audit passed")
        return 0
    } catch {
        print("❌ Error auditing packages: \(error)")
        return 1
    }
}

func runLicenses(projectRoot: URL) -> Int32 {
    let licensePath = projectRoot.appendingPathComponent("THIRD_PARTY_LICENSES.md")
    let resolvedPath = projectRoot.appendingPathComponent("Package.resolved")
    
    var content = """
    # Third Party Licenses
    
    This document lists all third-party dependencies and their licenses.
    
    Generated: \(Date())
    
    """
    
    if FileManager.default.fileExists(atPath: resolvedPath.path) {
        do {
            let data = try Data(contentsOf: resolvedPath)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let pins = json["pins"] as? [[String: Any]] {
                
                content += "## Dependencies\n\n"
                
                for pin in pins {
                    if let package = pin["identity"] as? String,
                       let location = pin["location"] as? String {
                        content += "### \(package)\n"
                        content += "- Repository: \(location)\n"
                        content += "- License: [Check Repository](\(location))\n\n"
                    }
                }
            }
        } catch {
            print("⚠️ Could not read Package.resolved: \(error)")
        }
    } else {
        content += "No dependencies found. Run 'swift package resolve' to generate Package.resolved.\n"
    }
    
    do {
        try content.write(to: licensePath, atomically: true, encoding: .utf8)
        print("✅ License file updated")
        return 0
    } catch {
        print("❌ Error updating license file: \(error)")
        return 1
    }
}

// MARK: - Helper Functions

func findSwiftFiles(in directory: URL) -> [URL] {
    var swiftFiles: [URL] = []
    let fileManager = FileManager.default
    
    let architectureDirs = [
        "App-Main", "App-Widgets",
        "Features", "UI", "Services",
        "Infrastructure", "Foundation"
    ]
    
    for dir in architectureDirs {
        let dirPath = directory.appendingPathComponent(dir)
        guard let enumerator = fileManager.enumerator(
            at: dirPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { continue }
        
        for case let file as URL in enumerator {
            if file.pathExtension == "swift" {
                swiftFiles.append(file)
            }
        }
    }
    
    return swiftFiles
}

func extractImports(from file: URL) throws -> [(module: String, line: Int)] {
    let sourceCode = try String(contentsOf: file)
    let sourceFile = Parser.parse(source: sourceCode)
    
    class ImportVisitor: SyntaxVisitor {
        var imports: [(String, Int)] = []
        let converter: SourceLocationConverter
        
        init(file: String, source: String) {
            self.converter = SourceLocationConverter(fileName: file, tree: Parser.parse(source: source))
            super.init(viewMode: .sourceAccurate)
        }
        
        override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
            let moduleName = node.path.map { $0.name.text }.joined(separator: ".")
            let location = node.startLocation(converter: converter)
            imports.append((moduleName, location.line ?? 0))
            return .visitChildren
        }
    }
    
    let visitor = ImportVisitor(file: file.path, source: sourceCode)
    visitor.walk(sourceFile)
    
    return visitor.imports
}

func inferModule(from file: URL, rootPath: URL) -> String {
    let relativePath = file.path.replacingOccurrences(of: rootPath.path + "/", with: "")
    let components = relativePath.split(separator: "/")
    
    guard components.count >= 2 else { return "Unknown" }
    
    let layer = String(components[0])
    
    switch layer {
    case "App-Main", "App-Widgets":
        return "App"
    case "Features":
        if components.count >= 2 {
            return "Features/\(components[1])"
        }
        return "Features"
    case "UI":
        if components.count >= 2 {
            return "UI/\(components[1])"
        }
        return "UI"
    case "Services":
        if components.count >= 2 {
            return "Services/\(components[1])"
        }
        return "Services"
    case "Infrastructure":
        if components.count >= 2 {
            return "Infrastructure/\(components[1])"
        }
        return "Infrastructure"
    case "Foundation":
        if components.count >= 2 {
            return "Foundation/\(components[1])"
        }
        return "Foundation"
    default:
        return layer
    }
}

func isImportAllowed(from: String, to: String, spec: ArchitectureSpec) -> Bool {
    let systemModules = ["Foundation", "UIKit", "SwiftUI", "Combine", "SwiftData",
                       "CloudKit", "StoreKit", "CoreData", "CoreGraphics", "CoreImage",
                       "AVFoundation", "Photos", "PhotosUI", "Vision", "CoreML"]
    if systemModules.contains(to) { return true }
    
    if let allowedList = spec.allowedImports[from] {
        return isModuleInAllowedList(to, allowedList: allowedList)
    }
    
    for (pattern, allowedList) in spec.allowedImports {
        if pattern.hasSuffix("/*") {
            let prefix = String(pattern.dropLast(2))
            if from.hasPrefix(prefix + "/") {
                return isModuleInAllowedList(to, allowedList: allowedList)
            }
        }
    }
    
    return false
}

func isModuleInAllowedList(_ module: String, allowedList: [String]) -> Bool {
    for allowed in allowedList {
        if allowed == module {
            return true
        }
        
        if allowed.hasSuffix("/*") {
            let prefix = String(allowed.dropLast(2))
            if module.hasPrefix(prefix + "/") {
                return true
            }
        }
        
        if !allowed.contains("/") {
            if module.hasPrefix(allowed + "/") || module == allowed {
                return true
            }
        }
    }
    
    return false
}

// MARK: - CommonCrypto Bridge
import var CommonCrypto.CC_SHA256_DIGEST_LENGTH
import func CommonCrypto.CC_SHA256
import typealias CommonCrypto.CC_LONG

// MARK: - Main

func main() {
    let arguments = CommandLine.arguments
    
    guard arguments.count >= 2 else {
        print("nestoryctl - Nestory Development Tools")
        print("\nUsage: nestoryctl <command>")
        print("\nAvailable commands:")
        for command in Command.allCases {
            print("  \(command.rawValue.padding(toLength: 15, withPad: " ", startingAt: 0)) \(command.description)")
        }
        exit(1)
    }
    
    guard let command = Command(rawValue: arguments[1]) else {
        print("❌ Unknown command: \(arguments[1])")
        print("Run 'nestoryctl' without arguments to see available commands")
        exit(1)
    }
    
    guard let projectRoot = findProjectRoot() else {
        print("❌ Could not find project root (no SPEC.json found)")
        exit(1)
    }
    
    let exitCode: Int32
    
    switch command {
    case .check:
        exitCode = runCheck(projectRoot: projectRoot)
    case .archVerify:
        exitCode = runArchVerify(projectRoot: projectRoot)
    case .specVerify:
        exitCode = runSpecVerify(projectRoot: projectRoot)
    case .specCommit:
        exitCode = runSpecCommit(projectRoot: projectRoot)
    case .spmAudit:
        exitCode = runSpmAudit(projectRoot: projectRoot)
    case .licenses:
        exitCode = runLicenses(projectRoot: projectRoot)
    }
    
    exit(exitCode)
}

main()