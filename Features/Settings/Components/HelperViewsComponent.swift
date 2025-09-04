//
// Layer: Features
// Module: Settings/Components
// Purpose: Helper views and utility components for Settings
//

import SwiftUI
import Foundation

struct HelperViewsComponent: View {
    var body: some View {
        Section("Helper Tools") {
            NavigationLink(destination: CategoryManagerView()) {
                Label("Manage Categories", systemImage: "folder.badge.plus")
            }
            
            NavigationLink(destination: RoomManagerView()) {
                Label("Manage Rooms", systemImage: "house")
            }
            
            NavigationLink(destination: TagManagerView()) {
                Label("Manage Tags", systemImage: "tag")
            }
            
            NavigationLink(destination: ValueCalculatorView()) {
                Label("Value Calculator", systemImage: "calculator")
            }
            
            NavigationLink(destination: BulkActionsView()) {
                Label("Bulk Actions", systemImage: "square.stack.3d.up")
            }
        }
        
        Section("Quick Actions") {
            Button(action: duplicateDetection) {
                Label("Find Duplicates", systemImage: "doc.on.doc")
            }
            
            Button(action: missingDataCheck) {
                Label("Find Missing Data", systemImage: "exclamationmark.triangle")
            }
            
            Button(action: updateItemValues) {
                Label("Update All Values", systemImage: "arrow.up.circle")
            }
        }
    }
    
    private func duplicateDetection() {
        // Detect duplicate items
    }
    
    private func missingDataCheck() {
        // Check for items with missing essential data
    }
    
    private func updateItemValues() {
        // Update item values based on current market data
    }
}

private struct CategoryManagerView: View {
    @State private var categories = [
        CategoryDisplay(name: "Electronics", itemCount: 15, color: .blue),
        CategoryDisplay(name: "Furniture", itemCount: 8, color: .brown),
        CategoryDisplay(name: "Jewelry", itemCount: 3, color: .purple),
        CategoryDisplay(name: "Appliances", itemCount: 12, color: .green),
        CategoryDisplay(name: "Clothing", itemCount: 25, color: .pink)
    ]
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var selectedColor = Color.blue
    
    var body: some View {
        List {
            ForEach(categories) { category in
                HStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 12, height: 12)
                    
                    Text(category.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(category.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Edit") {
                        // Edit category
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                }
            }
            .onDelete(perform: deleteCategories)
            .onMove(perform: moveCategories)
        }
        .navigationTitle("Manage Categories")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                Button("Add") {
                    showingAddCategory = true
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            NavigationView {
                VStack(spacing: 20) {
                    TextField("Category Name", text: $newCategoryName)
                        .textFieldStyle(.roundedBorder)
                    
                    ColorPicker("Category Color", selection: $selectedColor)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("New Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddCategory = false
                            newCategoryName = ""
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            let newCategory = CategoryDisplay(name: newCategoryName, itemCount: 0, color: selectedColor)
                            categories.append(newCategory)
                            showingAddCategory = false
                            newCategoryName = ""
                        }
                        .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
    }
}

private struct RoomManagerView: View {
    @State private var rooms = [
        RoomDisplay(name: "Living Room", itemCount: 12),
        RoomDisplay(name: "Bedroom", itemCount: 8),
        RoomDisplay(name: "Kitchen", itemCount: 15),
        RoomDisplay(name: "Office", itemCount: 6),
        RoomDisplay(name: "Garage", itemCount: 4)
    ]
    
    var body: some View {
        List {
            ForEach(rooms) { room in
                HStack {
                    Image(systemName: "house.fill")
                        .foregroundColor(.blue)
                    
                    Text(room.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(room.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: deleteRooms)
            
            Button("Add Room") {
                // Add new room
            }
            .foregroundColor(.blue)
        }
        .navigationTitle("Manage Rooms")
    }
    
    private func deleteRooms(offsets: IndexSet) {
        rooms.remove(atOffsets: offsets)
    }
}

private struct TagManagerView: View {
    @State private var tags = [
        Tag(name: "High Value", itemCount: 5, color: .red),
        Tag(name: "Fragile", itemCount: 8, color: .orange),
        Tag(name: "Vintage", itemCount: 3, color: .purple),
        Tag(name: "Gift", itemCount: 12, color: .green)
    ]
    
    var body: some View {
        List {
            ForEach(tags) { tag in
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(tag.color)
                        .frame(width: 20, height: 12)
                    
                    Text(tag.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(tag.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: deleteTags)
            
            Button("Add Tag") {
                // Add new tag
            }
            .foregroundColor(.blue)
        }
        .navigationTitle("Manage Tags")
    }
    
    private func deleteTags(offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
    }
}

private struct ValueCalculatorView: View {
    @State private var originalValue = ""
    @State private var purchaseDate = Date()
    @State private var condition = Condition.excellent
    @State private var depreciationRate = 10.0
    @State private var calculatedValue = 0.0
    
    var body: some View {
        Form {
            Section("Item Information") {
                TextField("Original Value", text: $originalValue)
                    .keyboardType(.decimalPad)
                
                DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                
                Picker("Condition", selection: $condition) {
                    ForEach(Condition.allCases, id: \.self) { condition in
                        Text(condition.displayName).tag(condition)
                    }
                }
            }
            
            Section("Depreciation") {
                HStack {
                    Text("Annual Rate")
                    Spacer()
                    Text("\(depreciationRate, specifier: "%.1f")%")
                }
                
                Slider(value: $depreciationRate, in: 0...50, step: 0.5)
            }
            
            Section("Result") {
                HStack {
                    Text("Current Estimated Value")
                        .font(.headline)
                    Spacer()
                    Text("$\(calculatedValue, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            Button("Calculate") {
                calculateValue()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Value Calculator")
    }
    
    private func calculateValue() {
        guard let original = Double(originalValue) else { return }
        
        let yearsOld = Date().timeIntervalSince(purchaseDate) / (365.25 * 24 * 3600)
        let depreciation = 1.0 - (depreciationRate / 100.0 * yearsOld)
        let conditionMultiplier = condition.valueMultiplier
        
        calculatedValue = original * max(0.1, depreciation) * conditionMultiplier
    }
}

private struct BulkActionsView: View {
    @State private var selectedAction = BulkAction.updateValues
    @State private var selectedItems = Set<String>()
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Action", selection: $selectedAction) {
                ForEach(BulkAction.allCases, id: \.self) { action in
                    Text(action.displayName).tag(action)
                }
            }
            .pickerStyle(.segmented)
            
            Text("Select items to perform bulk action")
                .font(.headline)
            
            // Mock item selection list
            List {
                ForEach(0..<10) { index in
                    HStack {
                        Image(systemName: selectedItems.contains("item\(index)") ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                if selectedItems.contains("item\(index)") {
                                    selectedItems.remove("item\(index)")
                                } else {
                                    selectedItems.insert("item\(index)")
                                }
                            }
                        
                        Text("Sample Item \(index + 1)")
                        
                        Spacer()
                        
                        Text("$\((index + 1) * 100)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Button("Perform Action on \(selectedItems.count) Items") {
                performBulkAction()
            }
            .disabled(selectedItems.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Bulk Actions")
    }
    
    private func performBulkAction() {
        // Perform the selected bulk action
    }
}

// MARK: - Helper Models

private struct CategoryDisplay: Identifiable {
    let id = UUID()
    let name: String
    let itemCount: Int
    let color: Color
}

private struct RoomDisplay: Identifiable {
    let id = UUID()
    let name: String
    let itemCount: Int
}

private struct Tag: Identifiable {
    let id = UUID()
    let name: String
    let itemCount: Int
    let color: Color
}

private enum Condition: CaseIterable {
    case poor, fair, good, excellent, mint
    
    var displayName: String {
        switch self {
        case .poor: return "Poor"
        case .fair: return "Fair"
        case .good: return "Good"
        case .excellent: return "Excellent"
        case .mint: return "Mint"
        }
    }
    
    var valueMultiplier: Double {
        switch self {
        case .poor: return 0.3
        case .fair: return 0.5
        case .good: return 0.7
        case .excellent: return 0.9
        case .mint: return 1.0
        }
    }
}

private enum BulkAction: CaseIterable {
    case updateValues, changeCategory, moveRoom, addTags
    
    var displayName: String {
        switch self {
        case .updateValues: return "Update Values"
        case .changeCategory: return "Change Category"
        case .moveRoom: return "Move Room"
        case .addTags: return "Add Tags"
        }
    }
}

#Preview {
    NavigationView {
        List {
            HelperViewsComponent()
        }
        .navigationTitle("Settings")
    }
}