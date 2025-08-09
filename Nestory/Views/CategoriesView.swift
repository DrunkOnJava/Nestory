//
//  CategoriesView.swift
//  Nestory
//
//  Created by Assistant on 8/9/25.
//

import SwiftData
import SwiftUI

struct CategoriesView: View {
    @Query private var items: [Item]

    let categories = [
        ("Electronics", "tv", Color.blue),
        ("Furniture", "sofa", Color.brown),
        ("Clothing", "tshirt", Color.purple),
        ("Books", "book", Color.orange),
        ("Kitchen", "fork.knife", Color.green),
        ("Tools", "hammer", Color.gray),
        ("Sports", "sportscourt", Color.red),
        ("Other", "square.grid.2x2", Color.indigo),
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Total Items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(items.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories, id: \.0) { category in
                            CategoryCard(
                                name: category.0,
                                icon: category.1,
                                color: category.2,
                                itemCount: Int.random(in: 0 ... 25)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoryCard: View {
    let name: String
    let icon: String
    let color: Color
    let itemCount: Int
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: CategoryDetailView(categoryName: name)) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)

                Text(name)
                    .font(.headline)
                    .foregroundColor(Color.theme.text)

                Text("\(itemCount) items")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                colorScheme == .dark
                    ? color.opacity(0.2)
                    : color.opacity(0.1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.4)
                    : color.opacity(0.2),
                radius: 4
            )
        }
    }
}

struct CategoryDetailView: View {
    let categoryName: String
    @Query private var items: [Item]

    var body: some View {
        List(items) { item in
            NavigationLink(destination: ItemDetailView(item: item)) {
                ItemRowView(item: item)
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    CategoriesView()
        .modelContainer(for: Item.self, inMemory: true)
}
