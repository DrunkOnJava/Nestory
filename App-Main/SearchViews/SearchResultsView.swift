//
//  SearchResultsView.swift
//  Nestory
//
//  Search results display
//

import SwiftData
import SwiftUI

struct SearchResultsView: View {
    let items: [Item]
    let searchText: String
    let sortOption: SearchSortOption
    @Binding var selectedItem: Item?

    var sortedItems: [Item] {
        switch sortOption {
        case .nameAscending:
            items.sorted { $0.name < $1.name }
        case .nameDescending:
            items.sorted { $0.name > $1.name }
        case .priceAscending:
            items.sorted { ($0.purchasePrice ?? 0) < ($1.purchasePrice ?? 0) }
        case .priceDescending:
            items.sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
        case .dateAdded:
            items.sorted { $0.createdAt > $1.createdAt }
        case .quantity:
            items.sorted { $0.quantity > $1.quantity }
        }
    }

    var body: some View {
        if sortedItems.isEmpty {
            SearchEmptyStateView(searchText: searchText)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(sortedItems) { item in
                        SearchResultCard(item: item)
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            // Item Image
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }

            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                if let category = item.category {
                    Label(category.name, systemImage: category.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    if let price = item.purchasePrice {
                        Text("\(item.currency) \(NSDecimalNumber(decimal: price).doubleValue, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Documentation Indicators
            VStack(spacing: 4) {
                if item.imageData != nil {
                    Image(systemName: "camera.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                if item.receiptImageData != nil {
                    Image(systemName: "doc.text.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                if item.warrantyExpirationDate != nil {
                    Image(systemName: "shield.fill")
                        .font(.caption2)
                        .foregroundColor(item.warrantyExpirationDate! > Date() ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Empty State

struct SearchEmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No results found")
                .font(.title2)
                .fontWeight(.semibold)

            if !searchText.isEmpty {
                Text("No items match '\(searchText)'")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("Try adjusting your search or filters")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
