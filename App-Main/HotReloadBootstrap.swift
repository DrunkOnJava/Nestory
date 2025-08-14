//
// Layer: App
// Module: Main
// Purpose: Hot reload bootstrap for Claude's custom solution
//

#if DEBUG
    import Foundation

    @MainActor enum HotReloadBootstrap {
        static func start() {
            // Custom hot reload via Claude hooks
            // When Claude modifies any Swift file, the hooks system will:
            // 1. Compile the changed file to a dynamic library
            // 2. Inject it into the running simulator process via LLDB
            // 3. Force UI refresh to show changes immediately
            // No Xcode or InjectionNext needed!

            NSLog("🔥 [HotReload] Claude custom hot reload ready - modify any Swift file to see changes")
            NSLog("🔧 [HotReload] Config: .claude/hot-reload.config")
            NSLog("📱 [HotReload] Mode: Direct compilation (no Xcode needed)")

            // Monitor for custom reload events if needed
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("CLAUDE_HOT_RELOAD"),
                object: nil, queue: .main,
            ) { notification in
                if let file = notification.userInfo?["file"] as? String {
                    NSLog("🔥 [HotReload] Reloaded: \(file)")
                }
            }
        }
    }
#endif
