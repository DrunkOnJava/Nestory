//
// Layer: Infrastructure
// Module: HotReload
// Purpose: Swift file dynamic compilation for injection
//

#if DEBUG
    import Foundation
    import OSLog

    @MainActor
    public final class InjectionCompiler {
        private let logger = Logger(subsystem: "com.drunkonjava.nestory.hotreload", category: "InjectionCompiler")
        private let projectRoot: URL
        private let buildDir: URL

        public init(projectRoot: String) {
            self.projectRoot = URL(fileURLWithPath: projectRoot)
            buildDir = self.projectRoot.appendingPathComponent(".build/injection")

            // Ensure build directory exists
            try? FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
        }

        public func compile(swiftFile: String) async throws -> URL {
            let fileURL = URL(fileURLWithPath: swiftFile)
            let moduleName = fileURL.deletingPathExtension().lastPathComponent
            let outputPath = buildDir.appendingPathComponent("\(moduleName).dylib")

            logger.info("Compiling \(fileURL.lastPathComponent) to \(outputPath.lastPathComponent)")

            // Build the compilation command
            let command = buildCompilationCommand(
                source: fileURL,
                output: outputPath,
                module: moduleName,
            )

            // Execute compilation
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
            process.arguments = command

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            try process.run()
            process.waitUntilExit()

            if process.terminationStatus != 0 {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                logger.error("Compilation failed: \(errorString)")
                throw InjectionError.compilationFailed(errorString)
            }

            logger.info("Successfully compiled \(moduleName)")
            return outputPath
        }

        private func buildCompilationCommand(source: URL, output: URL, module: String) -> [String] {
            var args = [
                "swiftc",
                "-emit-library",
                "-o", output.path,
                "-module-name", module,
                "-target", "arm64-apple-ios17.0-simulator",
                "-sdk", sdkPath(),
                "-F", frameworkSearchPath(),
                "-I", moduleSearchPath(),
                "-Xlinker", "-interposable",
                "-Onone",
                "-DDEBUG",
                "-DINJECTION_ENABLED",
                source.path,
            ]

            // Add project-specific include paths
            args.append(contentsOf: [
                "-I", projectRoot.appendingPathComponent("Foundation").path,
                "-I", projectRoot.appendingPathComponent("Infrastructure").path,
                "-I", projectRoot.appendingPathComponent("Services").path,
                "-I", projectRoot.appendingPathComponent("UI").path,
                "-I", projectRoot.appendingPathComponent("App-Main").path,
            ])

            return args
        }

        private func sdkPath() -> String {
            // Get iOS Simulator SDK path
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
            process.arguments = ["--sdk", "iphonesimulator", "--show-sdk-path"]

            let pipe = Pipe()
            process.standardOutput = pipe

            do {
                try process.run()
                process.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            } catch {
                logger.error("Failed to get SDK path: \(error)")
                return ""
            }
        }

        private func frameworkSearchPath() -> String {
            buildDir.appendingPathComponent("Frameworks").path
        }

        private func moduleSearchPath() -> String {
            buildDir.appendingPathComponent("Modules").path
        }
    }

#else

    // MARK: - Production Stub

    @MainActor
    public final class InjectionCompiler {
        public init(projectRoot _: String) {}

        public func compile(swiftFile _: String) async throws -> URL {
            // No-op in production
            URL(fileURLWithPath: "/dev/null")
        }
    }

#endif

public enum InjectionError: LocalizedError {
    case compilationFailed(String)
    case loadingFailed(String)
    case injectionFailed(String)

    public var errorDescription: String? {
        switch self {
        case let .compilationFailed(details):
            "Compilation failed: \(details)"
        case let .loadingFailed(details):
            "Loading failed: \(details)"
        case let .injectionFailed(details):
            "Injection failed: \(details)"
        }
    }
}
