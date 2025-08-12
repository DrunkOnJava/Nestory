//
// Layer: App
// Module: Main
// Purpose: Hot reload bootstrap for InjectionNext
//

#if DEBUG
import Foundation

@MainActor enum HotReloadBootstrap {
    static func start() {
        // InjectionNext handles everything automatically when added as a Swift Package
        // The app will connect to InjectionNext when it's running
        // No manual bundle loading required!

        NSLog("💉 [HotReload] InjectionNext package integrated - waiting for connection")

        // Optional: Add observer for injection events if you want logging
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("INJECTION_BUNDLE_NOTIFICATION"),
            object: nil, queue: .main
        ) { _ in
            NSLog("💉 [HotReload] Code injected successfully!")
        }
    }
}
#endif
