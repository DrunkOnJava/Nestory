//
// Layer: Infrastructure
// Module: HotReload
// Purpose: Dynamic library loading for hot reload
//

#if DEBUG
    import Foundation
    import OSLog

    @MainActor
    public final class DynamicLoader {
        private let logger = Logger(subsystem: "com.drunkonjava.nestory.hotreload", category: "DynamicLoader")
        private var loadedLibraries: [String: UnsafeMutableRawPointer] = [:]

        public init() {}

        public func load(dylibPath: URL) throws {
            logger.info("Loading dynamic library: \(dylibPath.lastPathComponent)")

            guard FileManager.default.fileExists(atPath: dylibPath.path) else {
                throw InjectionError.loadingFailed("File not found: \(dylibPath.path)")
            }

            // Unload previous version if exists
            let libraryName = dylibPath.lastPathComponent
            if let existingHandle = loadedLibraries[libraryName] {
                dlclose(existingHandle)
                loadedLibraries.removeValue(forKey: libraryName)
                logger.debug("Unloaded previous version of \(libraryName)")
            }

            // Load the new dynamic library
            guard let handle = dlopen(dylibPath.path, RTLD_NOW | RTLD_GLOBAL) else {
                let error = String(cString: dlerror())
                logger.error("Failed to load dylib: \(error)")
                throw InjectionError.loadingFailed(error)
            }

            loadedLibraries[libraryName] = handle
            logger.info("Successfully loaded \(libraryName)")

            // Call injection point if available
            callInjectionPoint(in: handle)
        }

        private func callInjectionPoint(in handle: UnsafeMutableRawPointer) {
            // Look for the injection entry point
            let injectionSymbol = dlsym(handle, "injected")

            if let symbol = injectionSymbol {
                logger.debug("Found injection entry point, calling it")

                // Cast to function pointer and call
                typealias InjectionFunction = @convention(c) () -> Void
                let function = unsafeBitCast(symbol, to: InjectionFunction.self)
                function()
            } else {
                logger.debug("No injection entry point found (this is normal)")
            }
        }

        public func unloadAll() {
            for (name, handle) in loadedLibraries {
                dlclose(handle)
                logger.debug("Unloaded \(name)")
            }
            loadedLibraries.removeAll()
        }

        deinit {
            Task { @MainActor in
                unloadAll()
            }
        }
    }

#else

    // MARK: - Production Stub

    @MainActor
    public final class DynamicLoader {
        public init() {}

        public func load(dylibPath _: URL) throws {
            // No-op in production
        }

        public func unloadAll() {
            // No-op in production
        }
    }

#endif
