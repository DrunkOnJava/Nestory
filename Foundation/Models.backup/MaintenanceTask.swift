// Layer: Foundation
// Module: Foundation/Models
// Purpose: Maintenance task model for scheduled item maintenance

import Foundation
import SwiftData

/// Maintenance task for items requiring regular service
@Model
public final class MaintenanceTask {
    // MARK: - Properties
    
    @Attribute(.unique)
    public var id: UUID
    
    public var title: String
    public var taskDescription: String?
    public var schedule: String // "daily", "weekly", "monthly", "quarterly", "yearly", "custom"
    public var intervalDays: Int? // For custom schedules
    public var nextDueAt: Date
    public var lastCompletedAt: Date?
    public var completionHistory: Data? // JSON array of dates
    public var estimatedDuration: Int? // in minutes
    public var priority: String // "low", "medium", "high", "critical"
    public var notes: String?
    public var isActive: Bool
    
    // Timestamps
    public var createdAt: Date
    public var updatedAt: Date
    
    // MARK: - Relationships
    
    @Relationship(inverse: \Item.maintenanceTasks)
    public var item: Item?
    
    // MARK: - Initialization
    
    public init(
        title: String,
        schedule: MaintenanceSchedule = .monthly,
        nextDueAt: Date,
        priority: Priority = .medium,
        item: Item? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.schedule = schedule.rawValue
        self.nextDueAt = nextDueAt
        self.priority = priority.rawValue
        self.item = item
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// Schedule type enum
    public var scheduleType: MaintenanceSchedule {
        get { MaintenanceSchedule(rawValue: schedule) ?? .custom }
        set {
            schedule = newValue.rawValue
            updatedAt = Date()
        }
    }
    
    /// Priority level enum
    public var priorityLevel: Priority {
        get { Priority(rawValue: priority) ?? .medium }
        set {
            priority = newValue.rawValue
            updatedAt = Date()
        }
    }
    
    /// Get completion history as array of dates
    public var completionDates: [Date] {
        get {
            guard let data = completionHistory else { return [] }
            let dates = try? JSONDecoder().decode([Date].self, from: data)
            return dates ?? []
        }
        set {
            completionHistory = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }
    
    /// Check if task is overdue
    public var isOverdue: Bool {
        isActive && Date() > nextDueAt
    }
    
    /// Days until due (negative if overdue)
    public var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextDueAt)
        return components.day ?? 0
    }
    
    /// Status description
    public var status: String {
        if !isActive {
            return "Inactive"
        } else if isOverdue {
            let days = abs(daysUntilDue)
            return "Overdue by \(days) day\(days == 1 ? "" : "s")"
        } else {
            let days = daysUntilDue
            if days == 0 {
                return "Due today"
            } else if days == 1 {
                return "Due tomorrow"
            } else if days <= 7 {
                return "Due in \(days) days"
            } else {
                return "Upcoming"
            }
        }
    }
    
    /// Number of times completed
    public var completionCount: Int {
        completionDates.count
    }
    
    /// Average days between completions
    public var averageCompletionInterval: Int? {
        let dates = completionDates.sorted()
        guard dates.count >= 2 else { return nil }
        
        var totalDays = 0
        for i in 1..<dates.count {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: dates[i-1], to: dates[i])
            totalDays += components.day ?? 0
        }
        
        return totalDays / (dates.count - 1)
    }
    
    /// Calculate next interval based on schedule
    public var scheduleInterval: Int {
        switch scheduleType {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        case .quarterly: return 90
        case .yearly: return 365
        case .custom: return intervalDays ?? 30
        }
    }
    
    // MARK: - Methods
    
    /// Mark task as completed
    public func markCompleted(on date: Date = Date()) {
        lastCompletedAt = date
        
        // Add to completion history
        var dates = completionDates
        dates.append(date)
        completionDates = dates
        
        // Calculate next due date
        let calendar = Calendar.current
        nextDueAt = calendar.date(byAdding: .day, value: scheduleInterval, to: date) ?? date
        
        updatedAt = Date()
    }
    
    /// Skip this occurrence
    public func skip() {
        let calendar = Calendar.current
        nextDueAt = calendar.date(byAdding: .day, value: scheduleInterval, to: nextDueAt) ?? nextDueAt
        updatedAt = Date()
    }
    
    /// Snooze for a number of days
    public func snooze(days: Int) {
        let calendar = Calendar.current
        nextDueAt = calendar.date(byAdding: .day, value: days, to: Date()) ?? nextDueAt
        updatedAt = Date()
    }
    
    /// Update task properties
    public func update(
        title: String? = nil,
        description: String? = nil,
        schedule: MaintenanceSchedule? = nil,
        intervalDays: Int? = nil,
        priority: Priority? = nil,
        estimatedDuration: Int? = nil,
        notes: String? = nil
    ) {
        if let title = title {
            self.title = title
        }
        if let description = description {
            self.taskDescription = description
        }
        if let schedule = schedule {
            self.scheduleType = schedule
        }
        if let intervalDays = intervalDays {
            self.intervalDays = intervalDays
        }
        if let priority = priority {
            self.priorityLevel = priority
        }
        if let estimatedDuration = estimatedDuration {
            self.estimatedDuration = estimatedDuration
        }
        if let notes = notes {
            self.notes = notes
        }
        self.updatedAt = Date()
    }
    
    /// Activate or deactivate the task
    public func setActive(_ active: Bool) {
        self.isActive = active
        self.updatedAt = Date()
    }
}

// MARK: - Maintenance Schedule

public enum MaintenanceSchedule: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    case custom = "custom"
    
    public var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        case .custom: return "Custom"
        }
    }
}

// MARK: - Priority

public enum Priority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    public var color: String {
        switch self {
        case .low: return "#808080" // Gray
        case .medium: return "#007AFF" // Blue
        case .high: return "#FF9500" // Orange
        case .critical: return "#FF3B30" // Red
        }
    }
    
    public var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

// MARK: - Comparable

extension MaintenanceTask: Comparable {
    public static func < (lhs: MaintenanceTask, rhs: MaintenanceTask) -> Bool {
        // Sort by priority first
        if lhs.priorityLevel.sortOrder != rhs.priorityLevel.sortOrder {
            return lhs.priorityLevel.sortOrder < rhs.priorityLevel.sortOrder
        }
        // Then by due date
        return lhs.nextDueAt < rhs.nextDueAt
    }
}
