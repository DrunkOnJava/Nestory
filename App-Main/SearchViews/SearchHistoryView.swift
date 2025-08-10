//
//  SearchHistoryView.swift
//  Nestory
//
//  Recent and popular searches
//

import SwiftUI

struct SearchHistoryView: View {
    @Binding var searchHistory: SearchHistory
    @Binding var searchText: String
    let onSearch: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recent Searches
                if !searchHistory.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Clear") {
                                withAnimation {
                                    searchHistory.clearAll()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        ForEach(searchHistory.recentSearches, id: \.self) { term in
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(term)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    searchHistory.removeSearch(term)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                searchText = term
                                onSearch(term)
                            }
                        }
                    }
                }
                
                // Suggested Searches
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggested Searches")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(suggestedSearches, id: \.self) { term in
                            SearchChip(text: term) {
                                searchText = term
                                onSearch(term)
                            }
                        }
                    }
                }
                
                // Quick Filters
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Filters")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) {
                        QuickFilterButton(
                            title: "With Photos",
                            icon: "camera.fill",
                            color: .green
                        ) {
                            onSearch("has:photo")
                        }
                        
                        QuickFilterButton(
                            title: "With Receipts",
                            icon: "doc.text.fill",
                            color: .blue
                        ) {
                            onSearch("has:receipt")
                        }
                        
                        QuickFilterButton(
                            title: "Warranty Active",
                            icon: "shield.fill",
                            color: .orange
                        ) {
                            onSearch("warranty:active")
                        }
                        
                        QuickFilterButton(
                            title: "High Value",
                            icon: "dollarsign.circle.fill",
                            color: .purple
                        ) {
                            onSearch("price:>1000")
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var suggestedSearches: [String] {
        ["Electronics", "Furniture", "Documents", "Kitchen", "Warranty", "Receipt", "Serial Number"]
    }
}

// MARK: - Search Chip

struct SearchChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Filter Button

struct QuickFilterButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}