//
// Layer: UI
// Module: Components
// Purpose: Reusable Search Bar Component
//

import SwiftUI

public struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    var placeholder = "Search..."
    var showCancelButton = true
    var onCommit: (() -> Void)?

    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        isSearching: Binding<Bool> = .constant(false),
        placeholder: String = "Search...",
        showCancelButton: Bool = true,
        onCommit: (() -> Void)? = nil
    ) {
        _text = text
        _isSearching = isSearching
        self.placeholder = placeholder
        self.showCancelButton = showCancelButton
        self.onCommit = onCommit
    }

    public var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        onCommit?()
                    }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if showCancelButton, isFocused || !text.isEmpty {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    isSearching = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        .onChange(of: isFocused) { _, newValue in
            isSearching = newValue
        }
    }
}

// MARK: - Filter Chips

public struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Suggestions

public struct SearchSuggestionRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""), isSearching: .constant(false))
            .padding()

        SearchBar(text: .constant("iPhone"), isSearching: .constant(true))
            .padding()

        HStack {
            FilterChip(title: "Electronics", isSelected: true) {}
            FilterChip(title: "Furniture", isSelected: false) {}
            FilterChip(title: "Books", isSelected: false) {}
        }
        .padding()

        VStack {
            SearchSuggestionRow(
                icon: "clock",
                title: "MacBook Pro",
                subtitle: "Recent search",
            ) {}

            SearchSuggestionRow(
                icon: "sparkles",
                title: "Items under $50",
                subtitle: "Smart filter",
            ) {}
        }
        .padding()

        Spacer()
    }
}
