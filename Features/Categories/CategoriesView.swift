//
// Layer: Features
// Module: Categories
// Purpose: TCA-enabled category management view with navigation
//

import ComposableArchitecture
import SwiftUI

struct CategoriesView: View {
    let store: StoreOf<CategoryFeature>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            mainContentView
        } destination: { store in
            destinationView(for: store)
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            contentView(with: viewStore)
        }
    }
    
    @ViewBuilder
    private func contentView(with viewStore: ViewStoreOf<CategoryFeature>) -> some View {
        ScrollView {
            categoriesGrid(with: viewStore)
        }
        .navigationTitle("Categories")
        .background(Color(.systemGroupedBackground))
        .toolbar {
            toolbarContent(with: viewStore)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .overlay {
            loadingOverlay(with: viewStore)
        }
        .alert("Error", isPresented: .constant(viewStore.errorMessage != nil)) {
            Button("OK") { }
        } message: {
            Text(viewStore.errorMessage ?? "")
        }
    }
    
    @ViewBuilder
    private func categoriesGrid(with viewStore: ViewStoreOf<CategoryFeature>) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(viewStore.categories) { category in
                CategoryCard(category: category)
                    .onTapGesture {
                        viewStore.send(.categorySelected(category))
                    }
            }
        }
        .padding()
    }
    
    @ToolbarContentBuilder
    private func toolbarContent(with viewStore: ViewStoreOf<CategoryFeature>) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { 
                viewStore.send(.addCategoryButtonTapped) 
            }) {
                Label("Add Category", systemImage: "plus")
            }
        }
    }
    
    @ViewBuilder
    private func loadingOverlay(with viewStore: ViewStoreOf<CategoryFeature>) -> some View {
        if viewStore.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
        }
    }
    
    @ViewBuilder
    private func destinationView(for store: StoreOf<CategoryFeature.Path>) -> some View {
        switch store.state {
        case let .detail(detailState):
            CategoryDetailView(store: Store(initialState: detailState) { CategoryDetailFeature() })
        case let .add(addState):
            AddCategoryView(store: Store(initialState: addState) { AddCategoryFeature() })
        }
    }
}

// MARK: - CategoryCard Component (Extracted from original)

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

// MARK: - CategoryDetailView

struct CategoryDetailView: View {
    let store: StoreOf<CategoryDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section("Category Info") {
                    HStack {
                        Image(systemName: viewStore.category.icon)
                            .font(.title2)
                            .foregroundColor(Color(hex: viewStore.category.colorHex) ?? .accentColor)
                        VStack(alignment: .leading) {
                            Text(viewStore.category.name)
                                .font(.headline)
                            Text("\(viewStore.categoryItems.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Items") {
                    if viewStore.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading items...")
                                .foregroundColor(.secondary)
                        }
                    } else if viewStore.categoryItems.isEmpty {
                        Text("No items in this category")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewStore.categoryItems) { item in
                            CategoryItemRowView(item: item)
                        }
                    }
                }
            }
            .navigationTitle(viewStore.category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { 
                        viewStore.send(.dismissTapped)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// MARK: - CategoryItemRowView Component

private struct CategoryItemRowView: View {
    let item: Item
    
    var body: some View {
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

// MARK: - AddCategoryView

struct AddCategoryView: View {
    let store: StoreOf<AddCategoryFeature>
    
    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Form {
                    Section("Category Details") {
                        TextField("Name", text: viewStore.binding(
                            get: \.name,
                            send: { .nameChanged($0) }
                        ))
                    }
                    
                    Section("Icon") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                            ForEach(viewStore.availableIcons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(viewStore.selectedIcon == icon ? .white : .accentColor)
                                    .frame(width: 50, height: 50)
                                    .background(viewStore.selectedIcon == icon ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        viewStore.send(.iconSelected(icon))
                                    }
                            }
                        }
                    }
                    
                    Section("Color") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                            ForEach(viewStore.availableColors, id: \.self) { color in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: color) ?? Color.accentColor)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        viewStore.selectedColor == color ?
                                            Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            : nil
                                    )
                                    .onTapGesture {
                                        viewStore.send(.colorSelected(color))
                                    }
                            }
                        }
                    }
                    
                    if let errorMessage = viewStore.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("New Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { 
                            viewStore.send(.cancelTapped) 
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewStore.send(.saveTapped)
                        }
                        .disabled(!viewStore.canSave || viewStore.isSaving)
                    }
                }
                .overlay {
                    if viewStore.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemBackground).opacity(0.8))
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CategoriesView(
        store: Store(initialState: CategoryFeature.State()) {
            CategoryFeature()
        }
    )
}