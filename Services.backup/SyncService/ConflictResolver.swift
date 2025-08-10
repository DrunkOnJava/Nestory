// Layer: Services
// Module: SyncService
// Purpose: Conflict resolution strategies for sync

import Foundation
import os.log

public protocol ConflictResolver: Sendable {
    func resolve(_ conflicts: [SyncConflict]) async throws -> [ConflictResolution]
}

public struct ConflictResolution: Sendable {
    public let recordID: String
    public let strategy: ResolutionStrategy
    public let localChange: SyncChange
    public let remoteChange: SyncChange
    public let mergedChange: SyncChange?

    public init(
        recordID: String,
        strategy: ResolutionStrategy,
        localChange: SyncChange,
        remoteChange: SyncChange,
        mergedChange: SyncChange? = nil
    ) {
        self.recordID = recordID
        self.strategy = strategy
        self.localChange = localChange
        self.remoteChange = remoteChange
        self.mergedChange = mergedChange
    }
}

public enum ResolutionStrategy: Sendable {
    case useLocal
    case useRemote
    case merge
}

public struct AutomaticConflictResolver: ConflictResolver, Sendable {
    private let logger = Logger(subsystem: "com.nestory", category: "ConflictResolver")

    public init() {}

    public func resolve(_ conflicts: [SyncConflict]) async throws -> [ConflictResolution] {
        var resolutions: [ConflictResolution] = []

        for conflict in conflicts {
            let resolution = resolveConflict(conflict)
            resolutions.append(resolution)

            logger.debug("Resolved conflict for \(conflict.recordID) using \(String(describing: resolution.strategy))")
        }

        return resolutions
    }

    private func resolveConflict(_ conflict: SyncConflict) -> ConflictResolution {
        if conflict.localChange.timestamp > conflict.remoteChange.timestamp {
            return ConflictResolution(
                recordID: conflict.recordID,
                strategy: .useLocal,
                localChange: conflict.localChange,
                remoteChange: conflict.remoteChange
            )
        } else if conflict.remoteChange.timestamp > conflict.localChange.timestamp {
            return ConflictResolution(
                recordID: conflict.recordID,
                strategy: .useRemote,
                localChange: conflict.localChange,
                remoteChange: conflict.remoteChange
            )
        } else {
            if let merged = mergeChanges(conflict.localChange, conflict.remoteChange) {
                return ConflictResolution(
                    recordID: conflict.recordID,
                    strategy: .merge,
                    localChange: conflict.localChange,
                    remoteChange: conflict.remoteChange,
                    mergedChange: merged
                )
            } else {
                return ConflictResolution(
                    recordID: conflict.recordID,
                    strategy: .useLocal,
                    localChange: conflict.localChange,
                    remoteChange: conflict.remoteChange
                )
            }
        }
    }

    private func mergeChanges(_ local: SyncChange, _ remote: SyncChange) -> SyncChange? {
        var mergedFields: [String: Any] = [:]

        let allKeys = Set(local.fields.keys).union(Set(remote.fields.keys))

        for key in allKeys {
            if let localValue = local.fields[key],
               let remoteValue = remote.fields[key]
            {
                if key == "quantity" {
                    if let localInt = localValue as? Int,
                       let remoteInt = remoteValue as? Int
                    {
                        mergedFields[key] = max(localInt, remoteInt)
                    } else {
                        mergedFields[key] = localValue
                    }
                } else if key == "updatedAt" {
                    if let localDate = localValue as? Date,
                       let remoteDate = remoteValue as? Date
                    {
                        mergedFields[key] = max(localDate, remoteDate)
                    } else {
                        mergedFields[key] = localValue
                    }
                } else {
                    mergedFields[key] = localValue
                }
            } else if let localValue = local.fields[key] {
                mergedFields[key] = localValue
            } else if let remoteValue = remote.fields[key] {
                mergedFields[key] = remoteValue
            }
        }

        return SyncChange(
            recordID: local.recordID,
            recordType: local.recordType,
            action: local.action,
            fields: mergedFields,
            timestamp: Date()
        )
    }
}

public struct ManualConflictResolver: ConflictResolver, @unchecked Sendable {
    public typealias ConflictHandler = (SyncConflict) async -> ResolutionStrategy

    private let handler: ConflictHandler
    private let logger = Logger(subsystem: "com.nestory", category: "ManualResolver")

    public init(handler: @escaping ConflictHandler) {
        self.handler = handler
    }

    public func resolve(_ conflicts: [SyncConflict]) async throws -> [ConflictResolution] {
        var resolutions: [ConflictResolution] = []

        for conflict in conflicts {
            let strategy = await handler(conflict)

            let resolution = ConflictResolution(
                recordID: conflict.recordID,
                strategy: strategy,
                localChange: conflict.localChange,
                remoteChange: conflict.remoteChange
            )

            resolutions.append(resolution)
            logger.info("User resolved conflict for \(conflict.recordID) using \(String(describing: strategy))")
        }

        return resolutions
    }
}

public struct RuleBasedConflictResolver: ConflictResolver, @unchecked Sendable {
    public struct Rule {
        public let field: String
        public let condition: (Any?, Any?) -> ResolutionStrategy

        public init(field: String, condition: @escaping (Any?, Any?) -> ResolutionStrategy) {
            self.field = field
            self.condition = condition
        }
    }

    private let rules: [Rule]
    private let fallbackResolver: any ConflictResolver
    private let logger = Logger(subsystem: "com.nestory", category: "RuleBasedResolver")

    public init(
        rules: [Rule],
        fallbackResolver: any ConflictResolver = AutomaticConflictResolver()
    ) {
        self.rules = rules
        self.fallbackResolver = fallbackResolver
    }

    public func resolve(_ conflicts: [SyncConflict]) async throws -> [ConflictResolution] {
        var resolutions: [ConflictResolution] = []
        var unresolvedConflicts: [SyncConflict] = []

        for conflict in conflicts {
            if let resolution = applyRules(to: conflict) {
                resolutions.append(resolution)
                logger.debug("Resolved conflict for \(conflict.recordID) using rules")
            } else {
                unresolvedConflicts.append(conflict)
            }
        }

        if !unresolvedConflicts.isEmpty {
            let fallbackResolutions = try await fallbackResolver.resolve(unresolvedConflicts)
            resolutions.append(contentsOf: fallbackResolutions)
        }

        return resolutions
    }

    private func applyRules(to conflict: SyncConflict) -> ConflictResolution? {
        for rule in rules {
            let localValue = conflict.localChange.fields[rule.field]
            let remoteValue = conflict.remoteChange.fields[rule.field]

            let strategy = rule.condition(localValue, remoteValue)

            return ConflictResolution(
                recordID: conflict.recordID,
                strategy: strategy,
                localChange: conflict.localChange,
                remoteChange: conflict.remoteChange
            )
        }

        return nil
    }
}

public extension RuleBasedConflictResolver.Rule {
    static var preferNewest: Self {
        RuleBasedConflictResolver.Rule(field: "updatedAt") { local, remote in
            guard let localDate = local as? Date,
                  let remoteDate = remote as? Date
            else {
                return .useLocal
            }
            return localDate > remoteDate ? .useLocal : .useRemote
        }
    }

    static var preferHigherQuantity: Self {
        RuleBasedConflictResolver.Rule(field: "quantity") { local, remote in
            guard let localQuantity = local as? Int,
                  let remoteQuantity = remote as? Int
            else {
                return .useLocal
            }
            return localQuantity > remoteQuantity ? .useLocal : .useRemote
        }
    }

    static var preferHigherPrice: Self {
        RuleBasedConflictResolver.Rule(field: "purchasePrice") { local, remote in
            guard let localPrice = local as? Decimal,
                  let remotePrice = remote as? Decimal
            else {
                return .useLocal
            }
            return localPrice > remotePrice ? .useLocal : .useRemote
        }
    }
}
