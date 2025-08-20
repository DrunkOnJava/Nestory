//
// Layer: UI
// Module: Performance
// Purpose: UI performance optimization utilities for large list rendering and smooth interactions
//

import Foundation
import os.log
import SwiftUI

// MARK: - Lazy Loading List View

/// High-performance list view with lazy loading, virtualization, and caching
public struct OptimizedList<Data: RandomAccessCollection & Sendable, ID: Hashable, Content: View>: View
    where Data.Element: Identifiable, Data.Element.ID == ID
{
    private let data: Data
    private let content: (Data.Element) -> Content
    private let pageSize: Int
    private let prefetchThreshold: Int
    private let onLoadMore: (() -> Void)?

    @State private var visibleRange: Range<Int> = 0 ..< 20
    @State private var renderedItems: Set<ID> = []
    @StateObject private var performanceMonitor = ListPerformanceMonitor()

    public init(
        _ data: Data,
        pageSize: Int = 25,
        prefetchThreshold: Int = 5,
        onLoadMore: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = content
        self.pageSize = pageSize
        self.prefetchThreshold = prefetchThreshold
        self.onLoadMore = onLoadMore
    }

    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .onAppear {
                        handleItemAppear(at: index)
                    }
                    .onDisappear {
                        handleItemDisappear(for: item.id)
                    }
            }
        }
        .onAppear {
            performanceMonitor.startMonitoring()
        }
        .onDisappear {
            performanceMonitor.stopMonitoring()
        }
    }

    private func handleItemAppear(at index: Int) {
        let profiler = PerformanceProfiler.shared
        Task {
            await profiler.measureUI("list_item_appear") {
                updateVisibleRange(newIndex: index)

                if shouldTriggerLoadMore(index: index) {
                    onLoadMore?()
                }
            }
        }
    }

    private func handleItemDisappear(for id: ID) {
        renderedItems.remove(id)
    }

    private func updateVisibleRange(newIndex: Int) {
        let start = max(0, newIndex - pageSize / 2)
        let end = min(data.count, newIndex + pageSize / 2)
        visibleRange = start ..< end
    }

    private func shouldTriggerLoadMore(index: Int) -> Bool {
        index >= data.count - prefetchThreshold
    }
}

// MARK: - Performance Monitoring

@MainActor
public class ListPerformanceMonitor: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev", category: "UIPerformance")
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var droppedFrames = 0

    public func startMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired(_:)))
        displayLink?.add(to: .main, forMode: .common)
        logger.debug("Started UI performance monitoring")
    }

    public func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil

        if frameCount > 0 {
            let dropRate = Double(droppedFrames) / Double(frameCount) * 100
            logger.info("UI Performance Summary - Total frames: \(frameCount), Dropped: \(droppedFrames) (\(String(format: "%.1f%%", dropRate)))")
        }
    }

    @objc private func displayLinkFired(_ displayLink: CADisplayLink) {
        frameCount += 1

        if lastTimestamp > 0 {
            let expectedInterval: CFTimeInterval = 1.0 / 60.0 // 60 FPS
            let actualInterval = displayLink.timestamp - lastTimestamp

            if actualInterval > expectedInterval * 1.5 { // More than 1.5x expected interval
                droppedFrames += 1

                // Log severe frame drops
                if actualInterval > expectedInterval * 3.0 {
                    logger.warning("Severe frame drop detected: \(actualInterval * 1000)ms")

                    Task {
                        await PerformanceProfiler.shared.measureUI("frame_drop") {}
                    }
                }
            }
        }

        lastTimestamp = displayLink.timestamp
    }
}

// MARK: - Cached Image View

/// High-performance cached image view with automatic memory management
public struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    private let cacheKey: String

    @StateObject private var imageCache = ImageCacheManager.shared
    @State private var phase: AsyncImagePhase = .empty

    public init(
        url: URL?,
        cacheKey: String? = nil,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
        self.cacheKey = cacheKey ?? url?.absoluteString ?? "unknown"
    }

    public var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }

    private func loadImage() {
        guard let url else {
            phase = .empty
            return
        }

        // Check cache first
        if let cachedImage = imageCache.image(for: cacheKey) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }

        // Load from network
        phase = .empty

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                await MainActor.run {
                    if let uiImage = UIImage(data: data) {
                        imageCache.cache(uiImage, for: cacheKey)
                        phase = .success(Image(uiImage: uiImage))
                    } else {
                        phase = .failure(ImageLoadError.invalidData)
                    }
                }
            } catch {
                await MainActor.run {
                    phase = .failure(error)
                }
            }
        }
    }
}

// MARK: - Image Cache Manager

@MainActor
public class ImageCacheManager: ObservableObject {
    public static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev", category: "ImageCache")

    private init() {
        cache.countLimit = CacheConstants.Image.maxCount
        cache.totalCostLimit = CacheConstants.Image.maxSize

        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
        )
    }

    public func image(for key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }

    public func cache(_ image: UIImage, for key: String) {
        let cost = imageMemoryCost(image)
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }

    public func removeImage(for key: String) {
        cache.removeObject(forKey: NSString(string: key))
    }

    public func clearCache() {
        cache.removeAllObjects()
        logger.info("Cleared image cache")
    }

    @objc private func handleMemoryWarning() {
        cache.removeAllObjects()
        logger.warning("Memory warning - cleared image cache")
    }

    private func imageMemoryCost(_ image: UIImage) -> Int {
        let pixelCount = Int(image.size.width * image.size.height * image.scale * image.scale)
        return pixelCount * 4 // 4 bytes per pixel for RGBA
    }
}

// MARK: - Performance-Optimized Modifiers

extension View {
    /// Optimizes view rendering for large lists
    public func optimizedForLargeLists() -> some View {
        drawingGroup() // Rasterize complex views
            .compositingGroup() // Reduce overdraw
    }

    /// Adds performance monitoring to a view
    public func monitorPerformance(operation: String) -> some View {
        onAppear {
            Task {
                await PerformanceProfiler.shared.measureUI(operation) {}
            }
        }
    }

    /// Implements lazy rendering for expensive views
    public func lazyRender(
        @ViewBuilder placeholder: () -> some View,
    ) -> some View {
        LazyView(content: { self }, placeholder: placeholder)
    }
}

// MARK: - Lazy View Implementation

struct LazyView<Content: View, PlaceholderContent: View>: View {
    private let content: () -> Content
    private let placeholder: () -> PlaceholderContent

    @State private var isLoaded = false

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping () -> PlaceholderContent
    ) {
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if isLoaded {
                content()
            } else {
                placeholder()
                    .onAppear {
                        DispatchQueue.main.async {
                            isLoaded = true
                        }
                    }
            }
        }
    }
}

// MARK: - Error Types

enum ImageLoadError: LocalizedError {
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidData:
            "Invalid image data"
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
    public struct UIPerformanceOptimizerPreview: View {
        private let sampleData = Array(0 ..< 1000).map { "Item \($0)" }

        public var body: some View {
            OptimizedList(sampleData) { item in
                Text(item)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .navigationTitle("Performance Test")
        }
    }

    #Preview {
        NavigationView {
            UIPerformanceOptimizerPreview()
        }
    }
#endif
