// Layer: Foundation

import Foundation
import SwiftData

@Model
public final class MaintenanceTask {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var taskDescription: String?
    public var schedule: MaintenanceSchedule
    public var intervalDays: Int?
    public var intervalMonths: Int?
    public var lastCompletedAt: Date?
    public var nextDueAt: Date?
    public var estimatedDurationMinutes: Int?
    public var costAmount: Int64?
    public var costCurrency: String?
    public var notes: String?
    public var isActive: Bool

    @Relationship(deleteRule: .nullify)
    public var item: Item?

    public var completionHistory: [MaintenanceCompletion]

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        title: String,
        schedule: MaintenanceSchedule,
        description: String? = nil,
        item: Item? = nil
    ) throws {
        id = UUID()
        self.title = title
        taskDescription = description
        self.schedule = schedule
        self.item = item
        isActive = true
        completionHistory = []
        createdAt = Date()
        updatedAt = Date()

        try updateNextDueDate()
    }

    public var cost: Money? {
        guard let amount = costAmount,
              let currency = costCurrency else { return nil }
        return try? Money(amountInMinorUnits: amount, currencyCode: currency)
    }

    public func setCost(_ money: Money?) {
        costAmount = money?.amountInMinorUnits
        costCurrency = money?.currencyCode
        updatedAt = Date()
    }

    public var isOverdue: Bool {
        guard let nextDue = nextDueAt else { return false }
        return nextDue < Date() && isActive
    }

    public var isDueSoon: Bool {
        guard let nextDue = nextDueAt else { return false }
        let sevenDaysFromNow = Date().addingTimeInterval(7 * 24 * 60 * 60)
        return nextDue > Date() && nextDue <= sevenDaysFromNow && isActive
    }

    public func markCompleted(notes: String? = nil, cost: Money? = nil) throws {
        let completion = MaintenanceCompletion(
            completedAt: Date(),
            notes: notes,
            cost: cost
        )
        completionHistory.append(completion)
        lastCompletedAt = Date()

        if let cost {
            setCost(cost)
        }

        try updateNextDueDate()
        updatedAt = Date()
    }

    private func updateNextDueDate() throws {
        let baseDate = lastCompletedAt ?? Date()

        switch schedule {
        case .oneTime:
            nextDueAt = lastCompletedAt == nil ? Date() : nil
            if lastCompletedAt != nil {
                isActive = false
            }

        case .daily:
            nextDueAt = Calendar.current.date(byAdding: .day, value: 1, to: baseDate)

        case .weekly:
            nextDueAt = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: baseDate)

        case .monthly:
            nextDueAt = Calendar.current.date(byAdding: .month, value: 1, to: baseDate)

        case .quarterly:
            nextDueAt = Calendar.current.date(byAdding: .month, value: 3, to: baseDate)

        case .semiAnnually:
            nextDueAt = Calendar.current.date(byAdding: .month, value: 6, to: baseDate)

        case .annually:
            nextDueAt = Calendar.current.date(byAdding: .year, value: 1, to: baseDate)

        case .custom:
            if let days = intervalDays {
                nextDueAt = Calendar.current.date(byAdding: .day, value: days, to: baseDate)
            } else if let months = intervalMonths {
                nextDueAt = Calendar.current.date(byAdding: .month, value: months, to: baseDate)
            } else {
                throw AppError.validation(field: "interval", reason: "Custom schedule requires interval days or months")
            }

        case .asNeeded:
            nextDueAt = nil
        }
    }
}

public enum MaintenanceSchedule: String, Codable, CaseIterable {
    case oneTime = "one_time"
    case daily
    case weekly
    case monthly
    case quarterly
    case semiAnnually = "semi_annually"
    case annually
    case custom
    case asNeeded = "as_needed"

    public var displayName: String {
        switch self {
        case .oneTime: "One Time"
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .quarterly: "Quarterly"
        case .semiAnnually: "Semi-Annually"
        case .annually: "Annually"
        case .custom: "Custom"
        case .asNeeded: "As Needed"
        }
    }
}

public struct MaintenanceCompletion: Codable {
    public let id: UUID
    public let completedAt: Date
    public let notes: String?
    public let costAmount: Int64?
    public let costCurrency: String?

    public init(completedAt: Date, notes: String? = nil, cost: Money? = nil) {
        id = UUID()
        self.completedAt = completedAt
        self.notes = notes
        costAmount = cost?.amountInMinorUnits
        costCurrency = cost?.currencyCode
    }

    public var cost: Money? {
        guard let amount = costAmount,
              let currency = costCurrency else { return nil }
        return try? Money(amountInMinorUnits: amount, currencyCode: currency)
    }
}
