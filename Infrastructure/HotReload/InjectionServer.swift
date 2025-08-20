//
// Layer: Infrastructure
// Module: HotReload
// Purpose: Custom InjectionNext server implementation
//

import Foundation
import Network
import OSLog

@MainActor
public final class InjectionServer: ObservableObject {
    public static let shared = InjectionServer()

    private let logger = Logger(subsystem: "com.drunkonjava.nestory.hotreload", category: "InjectionServer")
    private var listener: NWListener?
    private let port: UInt16 = 8899
    private var connections: [NWConnection] = []

    @Published var isRunning = false
    @Published var lastInjectionTime: Date?
    @Published var injectionCount = 0

    private init() {}

    public func start() {
        #if DEBUG
            guard listener == nil else {
                logger.info("Injection server already running")
                return
            }

            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            do {
                listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: port))

                listener?.newConnectionHandler = { [weak self] connection in
                    Task { @MainActor in
                        self?.handleNewConnection(connection)
                    }
                }

                listener?.stateUpdateHandler = { [weak self] state in
                    Task { @MainActor in
                        self?.handleStateUpdate(state)
                    }
                }

                listener?.start(queue: .main)
                logger.info("Injection server starting on port \(port)")
            } catch {
                logger.error("Failed to start injection server: \(error)")
            }
        #endif
    }

    public func stop() {
        listener?.cancel()
        listener = nil
        connections.forEach { $0.cancel() }
        connections.removeAll()
        isRunning = false
        logger.info("Injection server stopped")
    }

    private func handleStateUpdate(_ state: NWListener.State) {
        switch state {
        case .ready:
            isRunning = true
            logger.info("Injection server ready on port \(port)")
        case let .failed(error):
            isRunning = false
            logger.error("Injection server failed: \(error)")
        case .cancelled:
            isRunning = false
            logger.info("Injection server cancelled")
        default:
            break
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        connections.append(connection)

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.logger.debug("New injection connection established")
                self?.receiveMessage(from: connection)
            case let .failed(error):
                self?.logger.error("Connection failed: \(error)")
                if let self {
                    connections.removeAll { $0 === connection }
                }
            case .cancelled:
                if let self {
                    connections.removeAll { $0 === connection }
                }
            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    private func receiveMessage(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data, !data.isEmpty {
                Task { @MainActor in
                    self?.processInjectionCommand(data, from: connection)
                }
            }

            if let error {
                Task { @MainActor in
                    self?.logger.error("Receive error: \(error)")
                }
                return
            }

            if !isComplete {
                Task { @MainActor in
                    self?.receiveMessage(from: connection)
                }
            }
        }
    }

    private func processInjectionCommand(_ data: Data, from connection: NWConnection) {
        guard let command = String(data: data, encoding: .utf8) else { return }

        logger.info("Received injection command: \(command)")

        if command.hasPrefix("INJECT:") {
            let filePath = String(command.dropFirst(7))
            performInjection(for: filePath, connection: connection)
        } else if command == "PING" {
            sendResponse("PONG", to: connection)
        }
    }

    private func performInjection(for filePath: String, connection: NWConnection) {
        logger.info("Performing injection for: \(filePath)")

        // Update stats
        lastInjectionTime = Date()
        injectionCount += 1

        // Notify the app that injection occurred
        NotificationCenter.default.post(
            name: .injectionOccurred,
            object: nil,
            userInfo: ["filePath": filePath],
        )

        sendResponse("OK:Injected \(filePath)", to: connection)
    }

    private func sendResponse(_ message: String, to connection: NWConnection) {
        guard let data = message.data(using: .utf8) else { return }

        connection.send(content: data, completion: .contentProcessed { error in
            if let error {
                self.logger.error("Send error: \(error)")
            }
        })
    }
}

extension Notification.Name {
    static let injectionOccurred = Notification.Name("InjectionOccurred")
}
