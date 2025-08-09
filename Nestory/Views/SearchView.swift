//
//  SearchView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Query private var items: [Item]
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedLocation = "All"

    let categories = ["All", "Electronics", "Furniture", "Clothing", "Books", "Kitchen", "Tools", "Sports", "Other"]
    let locations = ["All", "Living Room", "Bedroom", "Kitchen", "Garage", "Basement", "Attic", "Office"]

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search items...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(categories, id: \.self) { category in
                                FilterChip(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(locations, id: \.self) { location in
                                FilterChip(
                                    title: location,
                                    isSelected: selectedLocation == location,
                                    icon: "location"
                                ) {
                                    selectedLocation = location
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)

                if items.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or filters")
                    )
                } else {
                    List(items) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            SearchResultRow(item: item)
                        }
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? Color.accentColor
                    : (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : Color.theme.text)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isSelected ? Color.clear : Color.theme.separator.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct SearchResultRow: View {
    let item: Item

    var body: some View {
        HStack {
            Image(systemName: "shippingbox.fill")
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text("Item Name")
                    .font(.headline)
                HStack {
                    Label("General", systemImage: "tag")
                    Text("•")
                    Label("Living Room", systemImage: "location")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
        .modelContainer(for: Item.self, inMemory: true)
}
