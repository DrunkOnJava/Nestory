//
//  ItemConditionView.swift
//  Nestory
//
//  Main condition documentation view - modularized version
//

import SwiftUI
import SwiftData

struct ItemConditionView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCondition: ItemCondition
    @State private var conditionNotes: String
    @State private var photoDescriptions: [String]
    
    init(item: Item) {
        self.item = item
        _selectedCondition = State(initialValue: item.itemCondition)
        _conditionNotes = State(initialValue: item.conditionNotes ?? "")
        _photoDescriptions = State(initialValue: item.conditionPhotoDescriptions)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Condition Selection
                    ConditionSelectionView(selectedCondition: $selectedCondition)
                        .padding(.horizontal)
                    
                    // Condition Notes
                    ConditionNotesView(conditionNotes: $conditionNotes)
                        .padding(.horizontal)
                    
                    // Condition Photos
                    ConditionPhotoManagementView(
                        item: item,
                        photoDescriptions: $photoDescriptions
                    )
                    .padding(.horizontal)
                    
                    // Last Update Info
                    if let lastUpdate = item.lastConditionUpdate {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("Last updated: \(lastUpdate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Condition Documentation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCondition()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveCondition() {
        item.itemCondition = selectedCondition
        item.conditionNotes = conditionNotes.isEmpty ? nil : conditionNotes
        item.conditionPhotoDescriptions = photoDescriptions
        item.lastConditionUpdate = Date()
        item.updatedAt = Date()
        dismiss()
    }
}

#Preview {
    ItemConditionView(item: Item(name: "Test Item"))
        .modelContainer(for: [Item.self], inMemory: true)
}