//
// Layer: UI
// Module: Components
// Purpose: Reusable error display component
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("Something went wrong")
                .font(.headline)
                .fontWeight(.semibold)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await retry()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


// MARK: - Preview

#Preview {
    ErrorView(
        message: "Please try again later or contact support if the problem persists."
    ) {
        print("Retry tapped")
    }
}
