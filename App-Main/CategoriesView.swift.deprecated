//
//  CategoriesView.swift
//  Nestory
//

import SwiftData
import SwiftUI

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var showingAddCategory = false
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(categories) { category in
                        CategoryCard(category: category)
                            .onTapGesture {
                                selectedCategory = category
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCategory = true }) {
                        Label("Add Category", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .sheet(item: $selectedCategory) { category in
                CategoryDetailView(category: category)
            }
            .onAppear {
                if categories.isEmpty {
                    setupDefaultCategories()
                }
            }
        }
    }

    private func setupDefaultCategories() {
        for defaultCategory in Category.createDefaultCategories() {
            modelContext.insert(defaultCategory)
        }
    }
}

struct CategoryCard: View {
    let category: Category

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 32))
                .foregroundColor(Color(hex: category.colorHex) ?? .blue)

            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)

            Text("\(category.items?.count ?? 0) items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "#007AFF"

    let availableIcons = [
        "folder.fill", "tv.fill", "sofa.fill", "tshirt.fill",
        "book.fill", "fork.knife", "hammer.fill", "sportscourt.fill",
        "house.fill", "car.fill", "airplane", "gamecontroller.fill",
    ]

    let availableColors = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFEAA7", "#DDA0DD", "#98D8C8", "#B0B0B0",
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(selectedIcon == icon ? .white : .accentColor)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                        ForEach(availableColors, id: \.self) { color in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: color) ?? Color.accentColor)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    selectedColor == color ?
                                        Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        : nil,
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let category = Category(
                            name: name,
                            icon: selectedIcon,
                            colorHex: selectedColor,
                        )
                        modelContext.insert(category)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct CategoryDetailView: View {
    let category: Category
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [Item]

    var categoryItems: [Item] {
        allItems.filter { $0.category?.id == category.id }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Category Info") {
                    HStack {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundColor(Color(hex: category.colorHex) ?? .accentColor)
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.headline)
                            Text("\(categoryItems.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Items") {
                    if categoryItems.isEmpty {
                        Text("No items in this category")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(categoryItems) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.body)
                                    if let description = item.itemDescription {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// Color extension moved to UI/UI-Core/Extensions.swift

#Preview {
    CategoriesView()
        .modelContainer(for: [Item.self, Category.self], inMemory: true)
}
