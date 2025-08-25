//
// InteractionSampler.swift
// NestoryUITests
//
// Rules for bounded interaction sampling to handle infinite states
//

import XCTest

/// Rules and strategies for sampling UI interactions
struct InteractionSampler {
    
    // MARK: - Configuration
    
    struct Config {
        /// Maximum cells to sample in a list/table
        let maxCellsToSample: Int = 3
        
        /// Maximum depth for navigation chains
        let maxNavigationDepth: Int = 3
        
        /// Maximum scroll attempts for infinite scroll views
        let maxScrollAttempts: Int = 5
        
        /// Maximum carousel/page swipes
        let maxPageSwipes: Int = 3
        
        /// Maximum time to spend on any single screen (seconds)
        let maxScreenTime: TimeInterval = 10
        
        /// Whether to sample modal presentations
        let sampleModals: Bool = true
        
        /// Whether to sample action sheets
        let sampleActionSheets: Bool = false
        
        /// Whether to interact with text fields
        let sampleTextInput: Bool = false
    }
    
    // MARK: - Properties
    
    private let app: XCUIApplication
    private let config: Config
    private var visitedScreens: Set<String> = []
    private var currentDepth: Int = 0
    
    // MARK: - Initialization
    
    init(app: XCUIApplication, config: Config = Config()) {
        self.app = app
        self.config = config
    }
    
    // MARK: - Sampling Methods
    
    /// Sample interactions on the current screen
    @MainActor
    mutating func sampleCurrentScreen(screenName: String) async -> [ScreenshotCapture] {
        var captures: [ScreenshotCapture] = []
        
        // Skip if already visited
        guard !visitedScreens.contains(screenName) else {
            return captures
        }
        visitedScreens.insert(screenName)
        
        // Capture base state
        captures.append(captureScreenshot(name: "\(screenName)_base"))
        
        // Sample based on screen type
        if hasTableView() {
            captures += await sampleTableView(screenName: screenName)
        }
        
        if hasCollectionView() {
            captures += await sampleCollectionView(screenName: screenName)
        }
        
        if hasScrollView() {
            captures += await sampleScrollView(screenName: screenName)
        }
        
        if hasTabBar() {
            captures += await sampleTabBar(screenName: screenName)
        }
        
        if hasSegmentedControl() {
            captures += await sampleSegmentedControl(screenName: screenName)
        }
        
        return captures
    }
    
    // MARK: - TableView Sampling
    
    @MainActor
    private mutating func sampleTableView(screenName: String) async -> [ScreenshotCapture] {
        var captures: [ScreenshotCapture] = []
        let tables = app.tables
        
        guard tables.count > 0 else { return captures }
        
        let table = tables.firstMatch
        let cells = table.cells
        let cellCount = min(cells.count, config.maxCellsToSample)
        
        // Sample first N cells
        for i in 0..<cellCount {
            let cell = cells.element(boundBy: i)
            guard cell.exists && cell.isHittable else { continue }
            
            // Check if cell leads to navigation
            if currentDepth < config.maxNavigationDepth {
                cell.tap()
                await waitForTransition()
                
                // Capture detail view
                captures.append(captureScreenshot(name: "\(screenName)_cell_\(i)"))
                
                // Go back
                if app.navigationBars.buttons.count > 0 {
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                    await waitForTransition()
                }
            }
        }
        
        // Sample scroll if content exceeds viewport
        if cells.count > 5 {
            table.swipeUp()
            await waitForTransition()
            captures.append(captureScreenshot(name: "\(screenName)_scrolled"))
            
            // Return to top
            table.swipeDown()
            table.swipeDown()
        }
        
        return captures
    }
    
    // MARK: - CollectionView Sampling
    
    @MainActor
    private mutating func sampleCollectionView(screenName: String) async -> [ScreenshotCapture] {
        var captures: [ScreenshotCapture] = []
        let collections = app.collectionViews
        
        guard collections.count > 0 else { return captures }
        
        let collection = collections.firstMatch
        let cells = collection.cells
        let cellCount = min(cells.count, config.maxCellsToSample)
        
        // Sample grid items
        for i in 0..<cellCount {
            let cell = cells.element(boundBy: i)
            guard cell.exists && cell.isHittable else { continue }
            
            if currentDepth < config.maxNavigationDepth {
                cell.tap()
                await waitForTransition()
                
                captures.append(captureScreenshot(name: "\(screenName)_item_\(i)"))
                
                // Go back if possible
                if app.navigationBars.buttons.count > 0 {
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                    await waitForTransition()
                }
            }
        }
        
        return captures
    }
    
    // MARK: - ScrollView Sampling
    
    @MainActor
    private func sampleScrollView(screenName: String) async -> [ScreenshotCapture] {
        var captures: [ScreenshotCapture] = []
        let scrollViews = app.scrollViews
        
        guard scrollViews.count > 0 else { return captures }
        
        let scrollView = scrollViews.firstMatch
        
        // Sample scroll positions
        for i in 0..<min(config.maxScrollAttempts, 3) {
            scrollView.swipeUp()
            await waitForTransition()
            captures.append(captureScreenshot(name: "\(screenName)_scroll_\(i)"))
        }
        
        // Return to top
        for _ in 0..<config.maxScrollAttempts {
            scrollView.swipeDown()
        }
        
        return captures
    }
    
    // MARK: - TabBar Sampling
    
    @MainActor
    private func sampleTabBar(screenName: String) async -> [ScreenshotCapture] {
        var captures: [ScreenshotCapture] = []
        let tabBar = app.tabBars.firstMatch
        
        guard tabBar.exists else { return captures }
        
        let buttons = tabBar.buttons
        let buttonCount = min(buttons.count, 5)
        
        for i in 0..<buttonCount {
            let button = buttons.element(boundBy: i)
            guard button.exists && button.isHittable else { continue }
            
            button.tap()
            await waitForTransition()
            captures.append(captureScreenshot(name: "\(screenName)_tab_\(i)"))
        }
        
        return captures
    }
    
    // MARK: - SegmentedControl Sampling
    
    @MainActor
    private func sampleSegmentedControl(screenName: String) async -> [ScreenshotCapture] {
        var captures: [ScreenshotCapture] = []
        let segments = app.segmentedControls
        
        guard segments.count > 0 else { return captures }
        
        let segment = segments.firstMatch
        let buttons = segment.buttons
        
        for i in 0..<min(buttons.count, 4) {
            let button = buttons.element(boundBy: i)
            guard button.exists && button.isHittable else { continue }
            
            button.tap()
            await waitForTransition()
            captures.append(captureScreenshot(name: "\(screenName)_segment_\(i)"))
        }
        
        return captures
    }
    
    // MARK: - Helper Methods
    
    private func hasTableView() -> Bool {
        app.tables.count > 0
    }
    
    private func hasCollectionView() -> Bool {
        app.collectionViews.count > 0
    }
    
    private func hasScrollView() -> Bool {
        app.scrollViews.count > 0
    }
    
    private func hasTabBar() -> Bool {
        app.tabBars.count > 0
    }
    
    private func hasSegmentedControl() -> Bool {
        app.segmentedControls.count > 0
    }
    
    @MainActor
    private func waitForTransition() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    private func captureScreenshot(name: String) -> ScreenshotCapture {
        let screenshot = app.screenshot()
        return ScreenshotCapture(
            name: name,
            image: screenshot,
            timestamp: Date()
        )
    }
}

// MARK: - Supporting Types

struct ScreenshotCapture {
    let name: String
    let image: XCUIScreenshot
    let timestamp: Date
    
    func saveAsAttachment(to test: XCTestCase) {
        let attachment = XCTAttachment(screenshot: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        test.add(attachment)
    }
}

// MARK: - Sampling Strategy

enum SamplingStrategy {
    case exhaustive    // Try everything (slow, thorough)
    case representative // Sample key examples (balanced)
    case minimal       // Just the basics (fast)
    
    var config: InteractionSampler.Config {
        switch self {
        case .exhaustive:
            return InteractionSampler.Config(
                maxCellsToSample: 10,
                maxNavigationDepth: 5,
                maxScrollAttempts: 10,
                maxPageSwipes: 5,
                maxScreenTime: 30,
                sampleModals: true,
                sampleActionSheets: true,
                sampleTextInput: true
            )
        case .representative:
            return InteractionSampler.Config() // Use defaults
        case .minimal:
            return InteractionSampler.Config(
                maxCellsToSample: 1,
                maxNavigationDepth: 1,
                maxScrollAttempts: 1,
                maxPageSwipes: 1,
                maxScreenTime: 5,
                sampleModals: false,
                sampleActionSheets: false,
                sampleTextInput: false
            )
        }
    }
}