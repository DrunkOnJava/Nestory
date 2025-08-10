//
// Layer: App-Main
// Module: WarrantyViews
// Purpose: Supporting views for warranty and document management
//

import SwiftUI

// MARK: - Room Chip

struct RoomChip: View {
    let room: Room
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: room.icon)
                Text(room.name)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Document Row

struct DocumentRow: View {
    let name: String
    let size: Int
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: documentIcon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(formatFileSize(size))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    private var documentIcon: String {
        if name.hasSuffix(".pdf") { return "doc.richtext" }
        if name.hasSuffix(".jpg") || name.hasSuffix(".png") { return "photo" }
        return "doc"
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
