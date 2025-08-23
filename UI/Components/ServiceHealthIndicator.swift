//
// Layer: UI
// Module: Components
// Purpose: User-facing service health indicator
//

import SwiftUI

public struct ServiceHealthIndicator: View {
    @StateObject private var healthManager = ServiceHealthManager.shared
    @State private var showingHealthDetails = false
    
    public init() {}
    
    public var body: some View {
        if healthManager.isDegradedMode {
            Button(action: { showingHealthDetails = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("Limited Functionality")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .clipShape(Capsule())
            }
            .sheet(isPresented: $showingHealthDetails) {
                ServiceHealthDetailView()
            }
        }
    }
}

struct ServiceHealthDetailView: View {
    @StateObject private var healthManager = ServiceHealthManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: healthManager.isDegradedMode ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(healthManager.isDegradedMode ? .orange : .green)
                    
                    Text(healthManager.isDegradedMode ? "Limited Functionality" : "All Systems Operational")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(healthManager.isDegradedMode
                         ? "Some features are temporarily unavailable, but your data is safe."
                         : "All services are running normally.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Service Status List
                List {
                    ForEach(ServiceType.allCases, id: \.rawValue) { serviceType in
                        ServiceStatusRow(
                            serviceType: serviceType,
                            health: healthManager.serviceStates[serviceType] ?? ServiceHealth()
                        )
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("System Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ServiceStatusRow: View {
    let serviceType: ServiceType
    let health: ServiceHealth
    
    var body: some View {
        HStack {
            // Status Icon
            Image(systemName: health.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(health.isHealthy ? .green : .orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(serviceType.rawValue)
                    .font(.headline)
                
                Text(statusDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if !health.isHealthy {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Issues")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    Text("\(health.consecutiveFailures)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusDescription: String {
        if health.isHealthy {
            return "Operating normally"
        } else if let degradedSince = health.degradedSince {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            let timeString = formatter.localizedString(for: degradedSince, relativeTo: Date())
            return "Limited since \(timeString)"
        } else {
            return "Experiencing temporary issues"
        }
    }
}

// MARK: - Previews

#Preview("Healthy State") {
    ServiceHealthIndicator()
        .onAppear {
            // Preview data for healthy state
        }
}

#Preview("Degraded State") {
    ServiceHealthIndicator()
        .onAppear {
            // Preview data for degraded state
            let healthManager = ServiceHealthManager.shared
            healthManager.recordFailure(for: .inventory, error: URLError(.notConnectedToInternet))
            healthManager.recordFailure(for: .analytics, error: URLError(.cannotConnectToHost))
        }
}

#Preview("Health Detail View") {
    ServiceHealthDetailView()
        .onAppear {
            let healthManager = ServiceHealthManager.shared
            healthManager.recordFailure(for: .inventory, error: URLError(.notConnectedToInternet))
            healthManager.recordSuccess(for: .analytics)
        }
}
