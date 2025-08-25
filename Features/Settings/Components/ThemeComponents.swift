//
// Layer: Features
// Module: Settings/Components
// Purpose: Theme-related SwiftUI components for Settings
//

import SwiftUI
import ComposableArchitecture

// MARK: - Theme Preview Card

struct ThemePreviewCard: View {
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Theme Color Preview
            RoundedRectangle(cornerRadius: 8)
                .fill(previewGradient)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(theme.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(themeDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var previewGradient: LinearGradient {
        switch theme {
        case .light:
            return LinearGradient(
                colors: [Color.white, Color.gray.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .system:
            return LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderColor: Color {
        switch theme {
        case .light:
            return Color.gray.opacity(0.3)
        case .dark:
            return Color.white.opacity(0.2)
        case .system:
            return Color.blue.opacity(0.4)
        }
    }
    
    private var themeDescription: String {
        switch theme {
        case .light:
            return "Always uses light appearance"
        case .dark:
            return "Always uses dark appearance"
        case .system:
            return "Matches your device settings"
        }
    }
}

// MARK: - Theme Toggle Button

struct ThemeToggleButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImageName)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(theme.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var systemImageName: String {
        switch theme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        }
        return Color(.secondarySystemGroupedBackground)
    }
}

#Preview("Theme Preview Card") {
    VStack(spacing: 16) {
        ThemePreviewCard(theme: .light)
        ThemePreviewCard(theme: .dark)
        ThemePreviewCard(theme: .system)
    }
    .padding()
}

#Preview("Theme Toggle Buttons") {
    VStack(spacing: 8) {
        ThemeToggleButton(theme: .light, isSelected: true, action: {})
        ThemeToggleButton(theme: .dark, isSelected: false, action: {})
        ThemeToggleButton(theme: .system, isSelected: false, action: {})
    }
    .padding()
}