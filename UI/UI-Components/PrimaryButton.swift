//
// Layer: UI
// Module: Components
// Purpose: Primary Button Component
//

import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    public init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(Typography.headline())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .padding(.horizontal, Theme.Spacing.lg)
            .background(isDisabled ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .disabled(isDisabled || isLoading)
        .animation(Theme.Animation.spring, value: isLoading)
    }
}

// MARK: - Secondary Button
public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headline())
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .padding(.horizontal, Theme.Spacing.lg)
                .background(Color.secondaryBackground)
                .foregroundColor(.primaryText)
                .cornerRadius(Theme.CornerRadius.md)
        }
    }
}

// MARK: - Destructive Button
public struct DestructiveButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headline())
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .padding(.horizontal, Theme.Spacing.lg)
                .background(Color.destructive)
                .foregroundColor(.white)
                .cornerRadius(Theme.CornerRadius.md)
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        PrimaryButton(title: "Save", action: {})
        PrimaryButton(title: "Loading...", isLoading: true, action: {})
        PrimaryButton(title: "Disabled", isDisabled: true, action: {})
        SecondaryButton(title: "Cancel", action: {})
        DestructiveButton(title: "Delete", action: {})
    }
    .padding()
}
