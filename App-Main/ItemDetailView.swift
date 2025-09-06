// Layer: App
// Module: ItemDetailView
// Purpose: Individual item details and management
//  - Edit Item (✓ Wired)
//  - Receipt OCR (✓ Wired)
//  - Photo Management
//  - Document Attachments
//  Always check if new item-related services should be accessible from here!

import ComposableArchitecture
import SwiftData
import SwiftUI

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with ActivityKit - Add Live Activities for warranty countdown timers
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with LinkPresentation - Rich URL previews for purchase links and manuals
// APPLE_FRAMEWORK_OPPORTUNITY: Replace with PassKit - Store warranty cards and receipts in Apple Wallet

struct ItemDetailView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var showingReceiptCapture = false
    @State private var showingWarrantyDocuments = false
    @State private var showingConditionDocumentation = false
    @State private var showingDamageAssessment = false
    @State private var showingInsuranceReport = false
    @State private var showingClaimPackage = false
    @State private var showingWarrantyTracking = false
    @State private var showingInsuranceClaim = false
    @State private var showingWarrantyDashboard = false
    @State private var warrantyStatus: WarrantyStatus = .noWarranty

    @Dependency(\.insuranceReportService) var insuranceReportService
    @Dependency(\.claimPackageAssemblerService) var claimPackageService
    @Dependency(\.notificationService) var notificationService

    private var warrantyTrackingService: LiveWarrantyTrackingService {
        LiveWarrantyTrackingService(modelContext: modelContext, notificationService: LiveNotificationService())
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                // Item Image
                if let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray),
                        )
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Basic Info
                    GroupBox("Basic Information") {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Name", value: item.name)

                            if let description = item.itemDescription {
                                DetailRow(label: "Description", value: description)
                            }

                            DetailRow(label: "Quantity", value: "\(item.quantity)")

                            if let category = item.category {
                                HStack {
                                    Text("Category")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Label(category.name, systemImage: category.icon)
                                        .foregroundColor(Color(hex: category.colorHex) ?? .accentColor)
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }

                    // Additional Details
                    if item.brand != nil || item.modelNumber != nil || item.serialNumber != nil {
                        GroupBox("Product Details") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let brand = item.brand {
                                    DetailRow(label: "Brand", value: brand)
                                }
                                if let model = item.modelNumber {
                                    DetailRow(label: "Model", value: model)
                                }
                                if let serial = item.serialNumber {
                                    DetailRow(label: "Serial #", value: serial)
                                }
                            }
                        }
                    }

                    // Purchase Info
                    if item.purchasePrice != nil || item.purchaseDate != nil {
                        GroupBox("Purchase Information") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let price = item.purchasePrice {
                                    DetailRow(label: "Price", value: "\(item.currency) \(price)")
                                }
                                if let date = item.purchaseDate {
                                    DetailRow(label: "Purchase Date", value: date.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                        }
                    }

                    // Condition Section - WIRED UP!
                    GroupBox("Condition Documentation") {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: item.itemCondition.icon)
                                    .foregroundColor(Color(hex: item.itemCondition.color))
                                VStack(alignment: .leading) {
                                    Text("Condition: \(item.itemCondition.rawValue)")
                                        .font(.headline)
                                    Text(item.itemCondition.insuranceImpact)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }

                            if let notes = item.conditionNotes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if !item.conditionPhotos.isEmpty {
                                HStack {
                                    Image(systemName: "photo.stack.fill")
                                        .foregroundColor(.orange)
                                    Text("\(item.conditionPhotos.count) condition photo\(item.conditionPhotos.count == 1 ? "" : "s")")
                                    Spacer()
                                }
                            }

                            HStack(spacing: 8) {
                                Button(action: { showingConditionDocumentation = true }) {
                                    Label("Update Condition", systemImage: "pencil.circle")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)

                                Button(action: { showingDamageAssessment = true }) {
                                    Label("Damage Assessment", systemImage: "exclamationmark.triangle.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Enhanced Warranty & Location Section
                    GroupBox("Warranty & Location") {
                        VStack(spacing: 12) {
                            // Enhanced Warranty status with new service
                            HStack {
                                Image(systemName: warrantyStatus.icon)
                                    .font(.title2)
                                    .foregroundColor(Color(hex: warrantyStatus.color ?? "#007AFF"))
                                VStack(alignment: .leading) {
                                    Text("Warranty Status")
                                        .font(.headline)
                                    Text(warrantyStatus.displayText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()

                                if warrantyStatus.requiresAttention {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                }
                            }

                            // Show progress for active warranties
                            if case let .active(daysRemaining) = warrantyStatus,
                               let warranty = item.warranty
                            {
                                let totalDays = warranty.durationInDays
                                let progress = Double(totalDays - daysRemaining) / Double(totalDays)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Progress")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(daysRemaining) days remaining")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    ProgressView(value: progress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                }
                            } else if case let .expiringSoon(daysRemaining) = warrantyStatus {
                                HStack {
                                    Image(systemName: "clock.badge.exclamationmark")
                                        .foregroundColor(.orange)
                                    Text("⚠️ Expires in \(daysRemaining) days")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(6)
                            }


                            // Documents count
                            if !item.documentNames.isEmpty {
                                HStack {
                                    Image(systemName: "doc.stack.fill")
                                        .foregroundColor(.orange)
                                    Text("\(item.documentNames.count) document\(item.documentNames.count == 1 ? "" : "s") attached")
                                    Spacer()
                                }
                            }

                            // Enhanced Action buttons
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Button(action: { showingWarrantyTracking = true }) {
                                        Label("Warranty Tracking", systemImage: "shield.lefthalf.filled")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button(action: { showingWarrantyDocuments = true }) {
                                        Label("Documents", systemImage: "doc.stack")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                Button(action: { showingWarrantyDashboard = true }) {
                                    Label("Warranty Dashboard", systemImage: "chart.xyaxis.line")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Receipts Section
                    ReceiptsSection(item: item, showingReceiptCapture: $showingReceiptCapture)

                    // Insurance Report Section
                    GroupBox("Insurance Documentation") {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("Generate Insurance Report")
                                        .font(.headline)
                                    Text("Create a detailed report for this item for insurance claims")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }

                            Button(action: { showingInsuranceReport = true }) {
                                Label("Generate Item Report", systemImage: "doc.text")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }

                    // Insurance Claim Generation Section
                    GroupBox("Insurance Claim Generation") {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text("Generate Insurance Claim")
                                        .font(.headline)
                                    Text("Create professional insurance claim documents for this item")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }

                            HStack(spacing: 8) {
                                Button(action: { showingInsuranceClaim = true }) {
                                    Label("Generate Claim", systemImage: "doc.badge.plus")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button(action: { showingClaimPackage = true }) {
                                    Label("Claim Package", systemImage: "folder.badge.plus")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Notes
                    if let notes = item.notes {
                        GroupBox("Notes") {
                            Text(notes)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Metadata
                    GroupBox("Metadata") {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Added", value: item.createdAt.formatted(date: .abbreviated, time: .shortened))
                            DetailRow(label: "Updated", value: item.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingReceiptCapture) {
            ReceiptCaptureView(item: item)
        }
        .sheet(isPresented: $showingWarrantyDocuments) {
            WarrantyDocumentsView(item: item)
        }
        .sheet(isPresented: $showingConditionDocumentation) {
            ItemConditionView(item: item)
        }
        .sheet(isPresented: $showingDamageAssessment) {
            DamageAssessmentWorkflowView(item: item, modelContext: modelContext)
        }
        .sheet(isPresented: $showingInsuranceReport) {
            SingleItemInsuranceReportView(item: item, insuranceReportService: insuranceReportService)
        }
        .sheet(isPresented: $showingClaimPackage) {
            ClaimPackageAssemblyView()
        }
        .sheet(isPresented: $showingWarrantyTracking) {
            WarrantyTrackingView(item: item, modelContext: modelContext)
        }
        .sheet(isPresented: $showingInsuranceClaim) {
            InsuranceClaimView(items: [item])
        }
        .sheet(isPresented: $showingWarrantyDashboard) {
            WarrantyDashboardView()
        }
        .task {
            await loadWarrantyStatus()
        }
    }

    // MARK: - Helper Methods

    private func loadWarrantyStatus() async {
        do {
            let status = try await warrantyTrackingService.getWarrantyStatus(for: item)
            await MainActor.run {
                warrantyStatus = status
            }
        } catch {
            print("Failed to load warranty status: \(error.localizedDescription)")
            // Fallback to basic status calculation
            await MainActor.run {
                if let warranty = item.warranty {
                    let now = Date()
                    let calendar = Calendar.current
                    if now >= warranty.expiresAt {
                        let days = calendar.dateComponents([.day], from: warranty.expiresAt, to: now).day ?? 0
                        warrantyStatus = .expired(daysAgo: days)
                    } else {
                        let days = calendar.dateComponents([.day], from: now, to: warranty.expiresAt).day ?? 0
                        warrantyStatus = days <= 30 ? .expiringSoon(daysRemaining: days) : .active(daysRemaining: days)
                    }
                } else {
                    warrantyStatus = .noWarranty
                }
            }
        }
    }
}

// DetailRow is now available from WarrantyTrackingComponents.swift
// Removed local definition to avoid redeclaration conflict

#Preview {
    if let container = try? ModelContainer(for: Item.self, Category.self, Warranty.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)) {
        let context = ModelContext(container)
        
        let category = Category(name: "Electronics", icon: "tv.fill", colorHex: "#FF6B6B")
        let item = Item(name: "MacBook Pro", itemDescription: "13-inch M2", quantity: 1, category: category)
        item.purchaseDate = Date()
        item.purchasePrice = 1299.00
        item.brand = "Apple"

        context.insert(category)
        context.insert(item)

        NavigationStack {
            ItemDetailView(item: item)
                .modelContainer(container)
        }
    } else {
        Text("Preview Error: Failed to create ModelContainer")
            .foregroundColor(.red)
    }
}

// MARK: - Color Extension

