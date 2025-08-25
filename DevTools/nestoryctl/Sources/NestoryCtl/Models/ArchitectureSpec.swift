import Foundation

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