//
// Layer: App-Main
// Module: ThemeManager
// Purpose: Centralized theme management with dark mode support
//

import SwiftUI
import Combine

// Import Settings types for AppTheme
// App-Main layer can import from Features layer per 6-layer architecture

@MainActor
class ThemeManager: ObservableObject {
    // MARK: - Properties
    
    @AppStorage("darkModeEnabled") var darkModeEnabled = false {
        didSet {
            objectWillChange.send()
            notifyThemeChange()
        }
    }
    
    @AppStorage("useSystemTheme") var useSystemTheme = true {
        didSet {
            objectWillChange.send()
            notifyThemeChange()
        }
    }
    
    @AppStorage("selectedTheme") private var selectedThemeRaw = AppTheme.system.rawValue
    
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    // MARK: - Publishers
    
    private let themeChangeSubject = PassthroughSubject<AppTheme, Never>()
    public var themeChangePublisher: AnyPublisher<AppTheme, Never> {
        themeChangeSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    private init() {
        // Initialize system theme monitoring
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Computed Properties
    
    var currentColorScheme: ColorScheme? {
        if useSystemTheme {
            return nil // Let system decide
        }
        return darkModeEnabled ? .dark : .light
    }
    
    var selectedTheme: AppTheme {
        get {
            AppTheme(rawValue: selectedThemeRaw) ?? .system
        }
        set {
            selectedThemeRaw = newValue.rawValue
            applyTheme(newValue)
        }
    }
    
    var isDarkMode: Bool {
        if useSystemTheme {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return darkModeEnabled
    }
    
    // MARK: - Public Methods
    
    public func setTheme(_ theme: AppTheme) {
        selectedTheme = theme
    }
    
    public func toggleDarkMode() {
        if useSystemTheme {
            useSystemTheme = false
        }
        darkModeEnabled.toggle()
    }
    
    // MARK: - Private Methods
    
    private func applyTheme(_ theme: AppTheme) {
        switch theme {
        case .system:
            useSystemTheme = true
        case .light:
            useSystemTheme = false
            darkModeEnabled = false
        case .dark:
            useSystemTheme = false
            darkModeEnabled = true
        }
    }
    
    private func notifyThemeChange() {
        let currentTheme = selectedTheme
        themeChangeSubject.send(currentTheme)
        
        // Post notification for non-Combine consumers
        NotificationCenter.default.post(
            name: NSNotification.Name("ThemeChanged"),
            object: currentTheme
        )
    }
    
    @objc private func systemThemeChanged() {
        if useSystemTheme {
            objectWillChange.send()
            notifyThemeChange()
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Theme Utilities

extension ThemeManager {
    /// Returns appropriate status bar style for current theme
    var preferredStatusBarStyle: UIStatusBarStyle {
        return isDarkMode ? .lightContent : .darkContent
    }
    
    /// Returns appropriate keyboard appearance for current theme
    var keyboardAppearance: UIKeyboardAppearance {
        return isDarkMode ? .dark : .light
    }
}

// MARK: - SwiftUI Integration

// Note: Environment integration removed due to Swift 6 concurrency constraints
// ThemeManager.shared should be used directly in views instead
