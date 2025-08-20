//
// Layer: Infrastructure
// Module: HotReload
// Purpose: Main orchestrator for the injection pipeline
//

import Combine
import Foundation
import OSLog

@MainActor
public final class InjectionOrchestrator: ObservableObject {
    public static let shared = InjectionOrchestrator()

    private let logger = Logger(subsystem: "com.drunkonjava.nestory.hotreload", category: "InjectionOrchestrator")
    private let server = InjectionServer.shared
    private let client = InjectionClient.shared
    private let compiler: InjectionCompiler
    private let loader = DynamicLoader()

    private var cancellables = Set<AnyCancellable>()
    private let projectRoot: String

    @Published public var isActive = false
    @Published public var lastInjection: Date?
    @Published public var injectionHistory: [InjectionEvent] = []

    private init() {
        // Get project root from environment or use default
        projectRoot = ProcessInfo.processInfo.environment["PROJECT_ROOT"] ??
            FileManager.default.currentDirectoryPath
        compiler = InjectionCompiler(projectRoot: projectRoot)

        setupObservers()

        #if DEBUG
            isActive = true
            logger.info("InjectionOrchestrator initialized for project: \(projectRoot)")
        #endif
    }

    private func setupObservers() {
        // Listen for injection requests from the server
        NotificationCenter.default.publisher(for: .injectionOccurred)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let filePath = notification.userInfo?["filePath"] as? String else { return }
                Task {
                    await self?.handleInjectionRequest(for: filePath)
                }
            }
            .store(in: &cancellables)
    }

    private func handleInjectionRequest(for filePath: String) async {
        logger.info("Processing injection request for: \(filePath)")

        let event = InjectionEvent(
            filePath: filePath,
            timestamp: Date(),
            status: .processing,
        )

        injectionHistory.append(event)

        do {
            // Step 1: Compile the Swift file
            let dylibPath = try await compiler.compile(swiftFile: filePath)

            // Step 2: Load the dynamic library
            try loader.load(dylibPath: dylibPath)

            // Step 3: Notify UI to reload
            client.triggerManualReload()

            // Update event status
            if let index = injectionHistory.firstIndex(where: { $0.id == event.id }) {
                injectionHistory[index].status = .success
            }

            lastInjection = Date()
            logger.info("Successfully injected: \(filePath)")
        } catch {
            logger.error("Injection failed for \(filePath): \(error)")

            // Update event status
            if let index = injectionHistory.firstIndex(where: { $0.id == event.id }) {
                injectionHistory[index].status = .failed(error.localizedDescription)
            }
        }
    }

    public func testInjection() {
        logger.info("Testing injection pipeline...")

        // Create a test notification
        NotificationCenter.default.post(
            name: .injectionOccurred,
            object: nil,
            userInfo: ["filePath": "\(projectRoot)/App-Main/ContentView.swift"],
        )
    }
}

public struct InjectionEvent: Identifiable {
    public let id = UUID()
    public let filePath: String
    public let timestamp: Date
    public var status: InjectionStatus
}

public enum InjectionStatus {
    case processing
    case success
    case failed(String)

    public var displayText: String {
        switch self {
        case .processing:
            "Processing..."
        case .success:
            "✅ Success"
        case let .failed(reason):
            "❌ Failed: \(reason)"
        }
    }
}
