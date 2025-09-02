//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking
// Purpose: Reusable UI components for warranty tracking interface
//

import SwiftUI

// MARK: - Status Card Component

public struct WarrantyStatusCard: View {
    let item: Item
    let warrantyStatus: WarrantyStatus
    let progress: Double
    let daysRemaining: Int?
    
    public init(
        item: Item,
        warrantyStatus: WarrantyStatus,
        progress: Double,
        daysRemaining: Int?
    ) {
        self.item = item
        self.warrantyStatus = warrantyStatus
        self.progress = progress
        self.daysRemaining = daysRemaining
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    statusIcon
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(warrantyStatus.title)
                            .font(.headline)
                            .foregroundColor(Color(hex: warrantyStatus.color) ?? .gray)
                        
                        Text(statusDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if item.warranty != nil {
                    warrantyProgressBar
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var statusIcon: some View {
        Image(systemName: warrantyStatus.icon)
            .font(.title2)
            .foregroundColor(Color(hex: warrantyStatus.color) ?? .gray)
    }
    
    private var statusDescription: String {
        switch warrantyStatus {
        case .noWarranty:
            return "No warranty information available"
        case .active:
            if let days = daysRemaining {
                return "Expires in \(days) days"
            } else {
                return "Active warranty"
            }
        case .expiringSoon:
            return "Expires soon - take action"
        case .expired:
            return "Warranty has expired"
        case .notStarted:
            return "Warranty not yet active"
        }
    }
    
    @ViewBuilder
    private var warrantyProgressBar: some View {
        if progress > 0 {
            VStack(spacing: 4) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: warrantyStatus.color) ?? .gray))
                
                HStack {
                    Text("Progress")
                        .font(.caption2)
                    Spacer()
                    Text("\(Int(progress * 100))% elapsed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Quick Actions Component

public struct WarrantyQuickActions: View {
    let hasWarranty: Bool
    let canAutoDetect: Bool
    let isLoading: Bool
    let onAutoDetect: () -> Void
    let onManualAdd: () -> Void
    let onRemove: () -> Void
    let onRegister: () -> Void
    let onExtend: () -> Void
    
    public init(
        hasWarranty: Bool,
        canAutoDetect: Bool,
        isLoading: Bool,
        onAutoDetect: @escaping () -> Void,
        onManualAdd: @escaping () -> Void,
        onRemove: @escaping () -> Void,
        onRegister: @escaping () -> Void,
        onExtend: @escaping () -> Void
    ) {
        self.hasWarranty = hasWarranty
        self.canAutoDetect = canAutoDetect
        self.isLoading = isLoading
        self.onAutoDetect = onAutoDetect
        self.onManualAdd = onManualAdd
        self.onRemove = onRemove
        self.onRegister = onRegister
        self.onExtend = onExtend
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                if !hasWarranty {
                    QuickActionButton(
                        icon: "wand.and.stars",
                        title: "Auto-Detect",
                        subtitle: "Smart detection",
                        color: .blue,
                        isEnabled: canAutoDetect && !isLoading,
                        action: onAutoDetect
                    )
                    
                    QuickActionButton(
                        icon: "plus.circle",
                        title: "Add Manual",
                        subtitle: "Enter details",
                        color: .green,
                        isEnabled: !isLoading,
                        action: onManualAdd
                    )
                } else {
                    QuickActionButton(
                        icon: "checkmark.shield",
                        title: "Register",
                        subtitle: "Activate warranty",
                        color: .orange,
                        isEnabled: !isLoading,
                        action: onRegister
                    )
                    
                    QuickActionButton(
                        icon: "arrow.up.circle",
                        title: "Extend",
                        subtitle: "Purchase extension",
                        color: .purple,
                        isEnabled: !isLoading,
                        action: onExtend
                    )
                    
                    QuickActionButton(
                        icon: "trash",
                        title: "Remove",
                        subtitle: "Delete warranty",
                        color: .red,
                        isEnabled: !isLoading,
                        action: onRemove
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

public struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    public init(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isEnabled ? color : .gray)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// MARK: - Warranty Details Component

public struct WarrantyDetailsCard: View {
    let warranty: Warranty
    
    public init(warranty: Warranty) {
        self.warranty = warranty
    }
    
    public var body: some View {
        GroupBox("Warranty Details") {
            VStack(alignment: .leading, spacing: 12) {
                
                VStack(spacing: 8) {
                    DetailRow(label: "Type", value: warranty.type.rawValue)
                    DetailRow(label: "Provider", value: warranty.provider.isEmpty ? "Not specified" : warranty.provider)
                    
                    DetailRow(label: "Start Date", value: DateFormatter.medium.string(from: warranty.startDate))
                    DetailRow(label: "End Date", value: DateFormatter.medium.string(from: warranty.endDate))
                    
                    if let terms = warranty.coverageNotes, !terms.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Terms:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(terms)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Show registration status for all warranties
                    HStack {
                        Image(systemName: warranty.isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(warranty.isRegistered ? .green : .orange)
                        
                        Text(warranty.isRegistered ? "Registered" : "Registration Recommended")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(warranty.isRegistered ? .green : .orange)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct DetailRow: View {
    let label: String
    let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Smart Detection Component

public struct SmartDetectionCard: View {
    let canAutoDetect: Bool
    let isLoading: Bool
    let errorMessage: String?
    let onAutoDetect: () -> Void
    
    public init(
        canAutoDetect: Bool,
        isLoading: Bool,
        errorMessage: String?,
        onAutoDetect: @escaping () -> Void
    ) {
        self.canAutoDetect = canAutoDetect
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.onAutoDetect = onAutoDetect
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Smart Detection")
                            .font(.headline)
                        
                        Text("Automatically detect warranty info")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if canAutoDetect {
                    Button(action: onAutoDetect) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Detecting...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("Start Auto-Detection")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                } else {
                    Text("Add brand, model, or serial number to enable auto-detection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Statistics Component

public struct WarrantyStatisticsCard: View {
    let statistics: WarrantyProgressStatistics
    
    public init(statistics: WarrantyProgressStatistics) {
        self.statistics = statistics
    }
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Warranty Statistics")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    StatisticRow(
                        label: "Total Period",
                        value: "\(statistics.totalDays) days"
                    )
                    
                    StatisticRow(
                        label: "Time Elapsed",
                        value: "\(statistics.elapsedDays) days"
                    )
                    
                    StatisticRow(
                        label: "Time Remaining",
                        value: "\(statistics.remainingDays) days",
                        color: statistics.remainingDays < 30 ? .red : .primary
                    )
                    
                    StatisticRow(
                        label: "Progress",
                        value: "\(Int(statistics.progressPercentage * 100))%"
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

public struct StatisticRow: View {
    let label: String
    let value: String
    let color: Color
    
    public init(label: String, value: String, color: Color = .primary) {
        self.label = label
        self.value = value
        self.color = color
    }
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

// MARK: - WarrantyStatus Extensions

extension WarrantyStatus {
    var title: String {
        switch self {
        case .noWarranty: return "No Warranty"
        case .active: return "Active Warranty"
        case .expiringSoon: return "Expiring Soon"
        case .expired: return "Expired"
        case .notStarted: return "Not Started"
        }
    }
    
}

extension DateFormatter {
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}