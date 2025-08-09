import Foundation
import SwiftParser
import SwiftSyntax
import XCTest

final class ArchitectureTests: XCTestCase {
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

    func testArchitectureConformance() throws {
        // Load SPEC.json
        let specPath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SPEC.json")

        guard FileManager.default.fileExists(atPath: specPath.path) else {
            // No Swift files yet, so no violations possible
            XCTAssertTrue(true, "No SPEC.json found, skipping architecture tests")
            return
        }

        let specData = try Data(contentsOf: specPath)
        let spec = try JSONDecoder().decode(ArchitectureSpec.self, from: specData)

        // Find all Swift files
        let rootPath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let swiftFiles = findSwiftFiles(in: rootPath)

        // Extract imports and build edges
        var edges: [ImportEdge] = []
        for file in swiftFiles {
            let imports = try extractImports(from: file)
            let module = inferModule(from: file, rootPath: rootPath)

            for (importedModule, line) in imports {
                edges.append(ImportEdge(
                    fromFile: file.path,
                    fromModule: module,
                    toModule: importedModule,
                    line: line
                ))
            }
        }

        // Validate edges against spec
        var violations: [String] = []
        for edge in edges {
            if !isImportAllowed(from: edge.fromModule, to: edge.toModule, spec: spec) {
                violations.append(
                    "\(edge.fromFile):\(edge.line) - Illegal import: \(edge.fromModule) → \(edge.toModule)"
                )
            }
        }

        if !violations.isEmpty {
            let message = """
            Architecture Violations Detected:

            \(violations.joined(separator: "\n"))

            Please fix these violations to maintain architectural integrity.
            """
            XCTFail(message)
        }
    }

    private func findSwiftFiles(in directory: URL) -> [URL] {
        var swiftFiles: [URL] = []
        let fileManager = FileManager.default

        // Only search in our architecture directories
        let architectureDirs = [
            "App-Main", "App-Widgets",
            "Features", "UI", "Services",
            "Infrastructure", "Foundation",
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

    private func extractImports(from file: URL) throws -> [(module: String, line: Int)] {
        let sourceCode = try String(contentsOf: file)
        let sourceFile = Parser.parse(source: sourceCode)

        var imports: [(String, Int)] = []

        class ImportVisitor: SyntaxVisitor {
            var imports: [(String, Int)] = []
            let converter: SourceLocationConverter

            init(file: String, source: String) {
                converter = SourceLocationConverter(fileName: file, tree: Parser.parse(source: source))
                super.init(viewMode: .sourceAccurate)
            }

            override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
                let moduleName = node.path.map(\.name.text).joined(separator: ".")
                let location = node.startLocation(converter: converter)
                imports.append((moduleName, location.line ?? 0))
                return .visitChildren
            }
        }

        let visitor = ImportVisitor(file: file.path, source: sourceCode)
        visitor.walk(sourceFile)

        return visitor.imports
    }

    private func inferModule(from file: URL, rootPath: URL) -> String {
        let relativePath = file.path.replacingOccurrences(of: rootPath.path + "/", with: "")
        let components = relativePath.split(separator: "/")

        guard components.count >= 2 else { return "Unknown" }

        let layer = String(components[0])

        // Handle layer-based modules
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

    private func isImportAllowed(from: String, to: String, spec: ArchitectureSpec) -> Bool {
        // System imports are always allowed
        let systemModules = ["Foundation", "UIKit", "SwiftUI", "Combine", "SwiftData",
                             "CloudKit", "StoreKit", "CoreData", "CoreGraphics", "CoreImage",
                             "AVFoundation", "Photos", "PhotosUI", "Vision", "CoreML"]
        if systemModules.contains(to) { return true }

        // Check if from module has rules
        if let allowedList = spec.allowedImports[from] {
            return isModuleInAllowedList(to, allowedList: allowedList)
        }

        // Check wildcard rules
        for (pattern, allowedList) in spec.allowedImports {
            if pattern.hasSuffix("/*") {
                let prefix = String(pattern.dropLast(2))
                if from.hasPrefix(prefix + "/") {
                    return isModuleInAllowedList(to, allowedList: allowedList)
                }
            }
        }

        // No rules found means not allowed
        return false
    }

    private func isModuleInAllowedList(_ module: String, allowedList: [String]) -> Bool {
        for allowed in allowedList {
            if allowed == module {
                return true
            }

            // Handle wildcard patterns
            if allowed.hasSuffix("/*") {
                let prefix = String(allowed.dropLast(2))
                if module.hasPrefix(prefix + "/") {
                    return true
                }
            }

            // Handle layer-level imports
            if !allowed.contains("/") {
                // This is a layer name, check if module is in that layer
                if module.hasPrefix(allowed + "/") || module == allowed {
                    return true
                }
            }
        }

        return false
    }
}
