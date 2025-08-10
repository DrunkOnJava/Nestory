//
// Layer: UI
// Module: Components
// Purpose: Empty State View
//

import SwiftUI

public struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?

    public init(
        title: String,
        message: String,
        systemImage: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)

            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Typography.title2())
                    .foregroundColor(.primaryText)

                Text(message)
                    .font(Typography.body())
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryBackground)
    }
}

// MARK: - Loading View

public struct LoadingView: View {
    let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)

            if let message {
                Text(message)
                    .font(Typography.body())
                    .foregroundColor(.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryBackground)
    }
}

// MARK: - Error View

public struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?

    public init(
        title: String = "Something went wrong",
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.destructive)

            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Typography.title2())
                    .foregroundColor(.primaryText)

                Text(message)
                    .font(Typography.body())
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }

            if let retryAction {
                PrimaryButton(title: "Try Again", action: retryAction)
                    .frame(maxWidth: 200)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryBackground)
    }
}

#Preview {
    VStack {
        EmptyStateView(
            title: "No Items",
            message: "Start by adding your first item to the inventory",
            systemImage: "archivebox",
            actionTitle: "Add Item",
            action: {}
        )
    }
}
