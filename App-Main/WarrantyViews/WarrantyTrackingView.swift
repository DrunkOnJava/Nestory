//
// Layer: App
// Module: WarrantyViews
// Purpose: Main coordinator view using modular components for warranty tracking
//

import SwiftUI
import SwiftData

// Modular components are automatically available within the same target
// WarrantyTrackingCore, WarrantyTrackingComponents, WarrantyTrackingSheets included

/// Enhanced warranty tracking view with smart detection and comprehensive management
struct WarrantyTrackingView: View {
    @Bindable var item: Item
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationService: LiveNotificationService

    @StateObject private var core: WarrantyTrackingCore

    init(item: Item, modelContext: ModelContext) {
        self.item = item
        self._core = StateObject(wrappedValue: WarrantyTrackingCore(item: item, modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    // Current Warranty Status Card
                    WarrantyStatusCard(
                        item: item,
                        warrantyStatus: core.warrantyStatus,
                        progress: core.warrantyProgress,
                        daysRemaining: core.daysRemaining
                    )

                    // Quick Actions
                    WarrantyQuickActions(
                        hasWarranty: core.hasWarranty,
                        canAutoDetect: core.canAutoDetect,
                        isLoading: core.isLoading,
                        onAutoDetect: core.startAutoDetection,
                        onManualAdd: core.addManualWarranty,
                        onRemove: core.removeWarranty,
                        onRegister: core.registerWarranty,
                        onExtend: core.extendWarranty
                    )

                    // Warranty Details (if exists)
                    if let warranty = item.warranty {
                        WarrantyDetailsCard(warranty: warranty)
                    }

                    // Smart Detection Section
                    if !core.hasWarranty {
                        SmartDetectionCard(
                            canAutoDetect: core.canAutoDetect,
                            isLoading: core.isLoading,
                            errorMessage: core.errorMessage,
                            onAutoDetect: core.startAutoDetection
                        )
                    }

                    // Warranty Statistics (if has warranty)
                    if core.hasWarranty {
                        WarrantyStatisticsCard(
                            statistics: core.getWarrantyStatistics()
                        )
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Warranty Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: core.configureNotifications) {
                            Label("Notifications", systemImage: "bell")
                        }
                        
                        if core.hasWarranty {
                            Button(action: core.extendWarranty) {
                                Label("Extend Warranty", systemImage: "arrow.up.circle")
                            }
                            
                            Button(role: .destructive, action: core.removeWarranty) {
                                Label("Remove Warranty", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $core.showingAutoDetectSheet) {
            if let result = core.detectionResult {
                AutoDetectResultSheet(
                    detectionResult: result,
                    onAccept: core.acceptDetectionResult,
                    onReject: core.rejectDetectionResult
                )
            }
        }
        .sheet(isPresented: $core.showingWarrantyForm) {
            ManualWarrantyFormSheet(item: $item)
        }
        .sheet(isPresented: $core.showingExtensionOptions) {
            if let warranty = item.warranty {
                WarrantyExtensionSheet(
                    currentWarranty: warranty,
                    onExtensionPurchased: { extensionInfo in
                        // Handle extension purchase
                        core.showingExtensionOptions = false
                    }
                )
            }
        }
        .sheet(isPresented: $core.showingNotificationSettings) {
            // Notification settings would be implemented here
            Text("Notification Settings")
        }
        .alert("Error", isPresented: Binding(
            get: { core.errorMessage != nil },
            set: { if !$0 { core.errorMessage = nil } }
        )) {
            Button("OK") { core.errorMessage = nil }
        } message: {
            Text(core.errorMessage ?? "An error occurred")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let context = ModelContext(container)
    
    // Create sample item
    let item = Item(name: "MacBook Pro")
    item.brand = "Apple"
    item.modelNumber = "MacBook Pro 16-inch"
    item.serialNumber = "ABC123DEF456"
    
    WarrantyTrackingView(item: item, modelContext: context)
        .modelContainer(container)
        .environmentObject(LiveNotificationService())
}