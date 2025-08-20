//
// Layer: Infrastructure
// Module: HotReload
// Purpose: Client-side injection handling
//

import Combine
import Foundation
import OSLog
import SwiftUI

@MainActor
public final class InjectionClient: ObservableObject {
    public static let shared = InjectionClient()

    private let logger = Logger(subsystem: "com.drunkonjava.nestory.hotreload", category: "InjectionClient")
    private var cancellables = Set<AnyCancellable>()

    @Published public var isEnabled = false
    @Published public var lastReloadTime: Date?
    @Published public var reloadCount = 0

    private init() {
        setupInjectionObserver()
    }

    private func setupInjectionObserver() {
        #if DEBUG
            NotificationCenter.default.publisher(for: .injectionOccurred)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] notification in
                    self?.handleInjection(notification: notification)
                }
                .store(in: &cancellables)

            isEnabled = true
            logger.info("Injection client initialized")
        #endif
    }

    private func handleInjection(notification: Notification) {
        guard let filePath = notification.userInfo?["filePath"] as? String else { return }

        logger.info("Handling injection for: \(filePath)")

        lastReloadTime = Date()
        reloadCount += 1

        // Trigger SwiftUI view updates
        NotificationCenter.default.post(name: .viewShouldReload, object: nil)

        // Reload dynamic libraries if needed
        reloadDynamicLibraries(for: filePath)
    }

    private func reloadDynamicLibraries(for filePath: String) {
        // This is where we'd implement dynamic library reloading
        // For now, we rely on SwiftUI's built-in view invalidation
        logger.debug("Would reload dynamic libraries for: \(filePath)")
    }

    public func triggerManualReload() {
        logger.info("Manual reload triggered")
        NotificationCenter.default.post(name: .viewShouldReload, object: nil)
    }
}

extension Notification.Name {
    static let viewShouldReload = Notification.Name("ViewShouldReload")
}

// MARK: - SwiftUI View Modifier

public struct InjectionReloadModifier: ViewModifier {
    @StateObject private var client = InjectionClient.shared
    @State private var reloadID = UUID()

    public func body(content: Content) -> some View {
        content
            .id(reloadID)
            .onReceive(NotificationCenter.default.publisher(for: .viewShouldReload)) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    reloadID = UUID()
                }
            }
        #if DEBUG
            .overlay(alignment: .topTrailing) {
                if client.isEnabled {
                    InjectionIndicator(reloadCount: client.reloadCount)
                        .padding()
                }
            }
        #endif
    }
}

struct InjectionIndicator: View {
    let reloadCount: Int
    @State private var isVisible = false

    var body: some View {
        if isVisible {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.green)
                Text("\(reloadCount)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(4)
            .background(Color.black.opacity(0.7))
            .cornerRadius(4)
            .transition(.scale.combined(with: .opacity))
            .onAppear {
                withAnimation(.easeOut(duration: 0.3).delay(2)) {
                    isVisible = false
                }
            }
        }
    }
}

extension View {
    public func enableHotReload() -> some View {
        #if DEBUG
            modifier(InjectionReloadModifier())
        #else
            self
        #endif
    }
}
