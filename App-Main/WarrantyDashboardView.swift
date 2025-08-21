//
// Layer: App-Main
// Module: WarrantyDashboard
// Purpose: Comprehensive warranty management dashboard with insights and analytics
//

import Charts
import SwiftData
import SwiftUI

@MainActor
struct WarrantyDashboardView: View {
    @Query private var items: [Item]
    @Query private var categories: [Category]
    @State private var warrantyService: LiveWarrantyService?
    @State private var insights: WarrantyInsights?
    @State private var expiringSoonItems: [Item] = []
    @State private var expiredItems: [Item] = []
    @State private var missingWarrantyItems: [Item] = []
    @State private var categoryCoverage: [CategoryCoverage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTimeframe: TimeFrame = .next30Days
    @State private var showingAddWarrantySheet = false
    @State private var selectedItem: Item?

    enum TimeFrame: String, CaseIterable {
        case next7Days = "Next 7 Days"
        case next30Days = "Next 30 Days"
        case next90Days = "Next 90 Days"
        case all = "All"

        var days: Int {
            switch self {
            case .next7Days: 7
            case .next30Days: 30
            case .next90Days: 90
            case .all: 3650 // 10 years
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading warranty data...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let errorMessage {
                        ErrorView(message: errorMessage, retry: { await loadData() })
                        .padding()
                    } else {
                        warrantyContent
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Warranty Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Actions", systemImage: "ellipsis.circle") {
                        Button("Export Warranty Report", systemImage: "square.and.arrow.up") {
                            // TODO: Export warranty report
                        }

                        Button("Add Missing Warranties", systemImage: "plus.shield") {
                            showingAddWarrantySheet = true
                        }
                    }
                }
            }
            .refreshable {
                await loadData()
            }
            .sheet(isPresented: $showingAddWarrantySheet) {
                WarrantyBulkAddView(items: missingWarrantyItems)
            }
            .sheet(item: $selectedItem) { item in
                WarrantyDocumentsView(item: item)
            }
        }
        .task {
            await initializeService()
            await loadData()
        }
        .onChange(of: selectedTimeframe) { _, _ in
            Task {
                await loadData()
            }
        }
    }

    @ViewBuilder
    private var warrantyContent: some View {
        // Summary Cards
        if let insights {
            WarrantySummaryCardsView(insights: insights)
                .padding(.horizontal)
        }

        // Timeframe Picker
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)

        // Priority Alerts Section
        priorityAlertsSection

        // Charts Section
        chartsSection

        // Action Items Section
        actionItemsSection

        // Category Coverage Section
        categoryCoverageSection
    }

    @ViewBuilder
    private var priorityAlertsSection: some View {
        if !expiredItems.isEmpty || !expiringSoonItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Priority Alerts")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)

                // Expired Items Alert
                if !expiredItems.isEmpty {
                    WarrantyAlertCard(
                        title: "Expired Warranties",
                        count: expiredItems.count,
                        icon: "shield.slash",
                        color: .red,
                        items: expiredItems
                    ) { item in
                        selectedItem = item
                    }
                }

                // Expiring Soon Alert
                if !expiringSoonItems.isEmpty {
                    WarrantyAlertCard(
                        title: "Expiring Soon",
                        count: expiringSoonItems.count,
                        icon: "exclamationmark.shield",
                        color: .orange,
                        items: expiringSoonItems
                    ) { item in
                        selectedItem = item
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Warranty Timeline Chart
            ChartContainer(title: "Warranty Expiration Timeline") {
                WarrantyTimelineChart(items: expiringSoonItems)
            }

            // Value Protection Chart
            if let insights {
                ChartContainer(title: "Value Protection Overview") {
                    ValueProtectionChart(insights: insights)
                }
            }

            // Coverage by Category Chart
            if !categoryCoverage.isEmpty {
                ChartContainer(title: "Coverage by Category") {
                    CategoryCoverageChart(coverage: categoryCoverage)
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var actionItemsSection: some View {
        if !missingWarrantyItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clipboard.fill")
                        .foregroundColor(.blue)
                    Text("Action Items")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()

                    Button("Add All") {
                        showingAddWarrantySheet = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)

                WarrantyActionCard(
                    title: "Missing Warranty Info",
                    count: missingWarrantyItems.count,
                    icon: "questionmark.shield",
                    color: .blue,
                    items: missingWarrantyItems
                ) { item in
                    selectedItem = item
                }
            }
        }
    }

    @ViewBuilder
    private var categoryCoverageSection: some View {
        if !categoryCoverage.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.green)
                    Text("Category Coverage")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)

                LazyVStack(spacing: 8) {
                    ForEach(categoryCoverage.indices, id: \.self) { index in
                        let coverage = categoryCoverage[index]
                        CategoryCoverageRow(coverage: coverage)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func initializeService() async {
        guard let modelContainer = items.first?.modelContext?.container else { return }
        let modelContext = ModelContext(modelContainer)

        do {
            warrantyService = try LiveWarrantyService(modelContext: modelContext)
        } catch {
            errorMessage = "Failed to initialize warranty service: \(error.localizedDescription)"
        }
    }

    private func loadData() async {
        guard let service = warrantyService else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let insightsTask = service.getWarrantyInsights()
            async let expiringSoonTask = service.fetchItemsExpiringWithin(days: selectedTimeframe.days)
            async let expiredTask = service.fetchExpiredItems()
            async let missingWarrantyTask = service.fetchItemsWithoutWarranty()
            async let categoryCoverageTask = service.getWarrantyCoverageByCategory()

            insights = try await insightsTask
            expiringSoonItems = try await expiringSoonTask
            expiredItems = try await expiredTask
            missingWarrantyItems = try await missingWarrantyTask
            categoryCoverage = try await categoryCoverageTask
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    WarrantyDashboardView()
        .modelContainer(for: [Item.self, Category.self, Warranty.self], inMemory: true)
}
