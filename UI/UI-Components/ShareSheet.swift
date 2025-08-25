//
// Layer: UI
// Module: UI-Components
// Purpose: Shared system share sheet component
//

import SwiftUI
import UIKit

public struct ShareSheet: UIViewControllerRepresentable {
    public let activityItems: [Any]

    public init(activityItems: [Any]) {
        self.activityItems = activityItems
    }

    public func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    public func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
