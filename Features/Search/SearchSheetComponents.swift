//
// Layer: Features
// Module: Search
// Purpose: Sheet presentation components for search interface
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Search Filter Sheet

public struct TCASearchFilterView: View {
    let filters: SearchFilters
    let availableCategories: [Category]
    let availableRooms: [String]
    let onFiltersUpdated: (SearchFilters) -> Void
    let onDismiss: () -> Void

    public init(
        filters: SearchFilters,
        availableCategories: [Category],
        availableRooms: [String],
        onFiltersUpdated: @escaping (SearchFilters) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.filters = filters
        self.availableCategories = availableCategories
        self.availableRooms = availableRooms
        self.onFiltersUpdated = onFiltersUpdated
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            Form {
                categorySection
                priceRangeSection
                documentationSection
                roomsSection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onDismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") { onDismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private var categorySection: some View {
        Section("Categories") {
            ForEach(availableCategories) { category in
                HStack {
                    Text(category.name)
                    Spacer()
                    if filters.selectedCategories.contains(category.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    var updatedFilters = filters
                    if updatedFilters.selectedCategories.contains(category.id) {
                        updatedFilters.selectedCategories.remove(category.id)
                    } else {
                        updatedFilters.selectedCategories.insert(category.id)
                    }
                    onFiltersUpdated(updatedFilters)
                }
            }
        }
    }

    @ViewBuilder
    private var priceRangeSection: some View {
        Section("Price Range") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("$\(Int(filters.priceRange?.lowerBound ?? 0))")
                    Spacer()
                    Text("$\(Int(filters.priceRange?.upperBound ?? 10000))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                PriceRangeSlider(
                    value: Binding(
                        get: { filters.priceRange ?? 0...10000 },
                        set: { newRange in
                            var updatedFilters = filters
                            updatedFilters.priceRange = newRange
                            onFiltersUpdated(updatedFilters)
                        }
                    ),
                    bounds: 0...10000,
                    step: 50
                )
            }
        }
    }

    @ViewBuilder
    private var documentationSection: some View {
        Section("Documentation") {
            Toggle("Has Photo", isOn: Binding(
                get: { filters.hasPhoto ?? false },
                set: { newValue in
                    var updatedFilters = filters
                    updatedFilters.hasPhoto = newValue
                    onFiltersUpdated(updatedFilters)
                }
            ))
            
            Toggle("Has Receipt", isOn: Binding(
                get: { filters.hasReceipt ?? false },
                set: { newValue in
                    var updatedFilters = filters
                    updatedFilters.hasReceipt = newValue
                    onFiltersUpdated(updatedFilters)
                }
            ))
            
            Toggle("Has Warranty", isOn: Binding(
                get: { filters.hasWarranty ?? false },
                set: { newValue in
                    var updatedFilters = filters
                    updatedFilters.hasWarranty = newValue
                    onFiltersUpdated(updatedFilters)
                }
            ))
            
            Toggle("Has Serial Number", isOn: Binding(
                get: { filters.hasSerialNumber ?? false },
                set: { newValue in
                    var updatedFilters = filters
                    updatedFilters.hasSerialNumber = newValue
                    onFiltersUpdated(updatedFilters)
                }
            ))
        }
    }

    @ViewBuilder
    private var roomsSection: some View {
        Section("Rooms") {
            ForEach(availableRooms, id: \.self) { roomName in
                HStack {
                    Text(roomName)
                    Spacer()
                    if filters.rooms.contains(roomName) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    var updatedFilters = filters
                    if updatedFilters.rooms.contains(roomName) {
                        updatedFilters.rooms.remove(roomName)
                    } else {
                        updatedFilters.rooms.insert(roomName)
                    }
                    onFiltersUpdated(updatedFilters)
                }
            }
        }
    }
}

// MARK: - Search History Sheet

public struct TCASearchHistorySheet: View {
    let searchHistory: [SearchHistoryItem]
    let savedSearches: [SavedSearch]
    let canSaveSearch: Bool
    let onHistoryItemSelected: (SearchHistoryItem) -> Void
    let onHistoryItemDeleted: (UUID) -> Void
    let onSaveCurrentSearch: (String) -> Void
    let onSavedSearchDeleted: (UUID) -> Void
    let onDismiss: () -> Void

    @State private var searchNameInput = ""
    @State private var showingSaveSearch = false

    public init(
        searchHistory: [SearchHistoryItem],
        savedSearches: [SavedSearch],
        canSaveSearch: Bool,
        onHistoryItemSelected: @escaping (SearchHistoryItem) -> Void,
        onHistoryItemDeleted: @escaping (UUID) -> Void,
        onSaveCurrentSearch: @escaping (String) -> Void,
        onSavedSearchDeleted: @escaping (UUID) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.searchHistory = searchHistory
        self.savedSearches = savedSearches
        self.canSaveSearch = canSaveSearch
        self.onHistoryItemSelected = onHistoryItemSelected
        self.onHistoryItemDeleted = onHistoryItemDeleted
        self.onSaveCurrentSearch = onSaveCurrentSearch
        self.onSavedSearchDeleted = onSavedSearchDeleted
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            List {
                if canSaveSearch {
                    saveCurrentSearchSection
                }
                
                if !savedSearches.isEmpty {
                    savedSearchesSection
                }
                
                if !searchHistory.isEmpty {
                    searchHistorySection
                }
            }
            .navigationTitle("Search History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { onDismiss() }
                        .fontWeight(.semibold)
                }
            }
            .alert("Save Search", isPresented: $showingSaveSearch) {
                TextField("Search name", text: $searchNameInput)
                Button("Save") {
                    onSaveCurrentSearch(searchNameInput)
                    searchNameInput = ""
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Give your search a name to save it for later")
            }
        }
    }

    @ViewBuilder
    private var saveCurrentSearchSection: some View {
        Section {
            Button {
                showingSaveSearch = true
            } label: {
                Label("Save Current Search", systemImage: "bookmark")
            }
        }
    }

    @ViewBuilder
    private var savedSearchesSection: some View {
        Section("Saved Searches") {
            ForEach(savedSearches) { saved in
                HStack {
                    VStack(alignment: .leading) {
                        Text(saved.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(saved.query)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        onSavedSearchDeleted(saved.id)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .onTapGesture {
                    // Handle saved search selection
                }
            }
        }
    }

    @ViewBuilder
    private var searchHistorySection: some View {
        Section("Recent Searches") {
            ForEach(searchHistory) { history in
                HStack {
                    VStack(alignment: .leading) {
                        Text(history.query)
                            .font(.subheadline)
                        Text(history.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        onHistoryItemDeleted(history.id)
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    onHistoryItemSelected(history)
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Range Slider Helper

private struct PriceRangeSlider: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack {
            HStack {
                Slider(
                    value: Binding(
                        get: { value.lowerBound },
                        set: { newValue in
                            value = newValue...max(newValue + step, value.upperBound)
                        }
                    ),
                    in: bounds,
                    step: step
                )
                
                Slider(
                    value: Binding(
                        get: { value.upperBound },
                        set: { newValue in
                            value = min(newValue - step, value.lowerBound)...newValue
                        }
                    ),
                    in: bounds,
                    step: step
                )
            }
        }
    }
}