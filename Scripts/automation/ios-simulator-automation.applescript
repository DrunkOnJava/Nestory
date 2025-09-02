--
-- iOS Simulator Automation Script for Nestory App
-- Purpose: Automate navigation through the app and capture screenshots
-- Created: August 2025
--

-- Configuration
property appBundleId : "com.drunkonjava.nestory.dev"
property simulatorDeviceId : "0CFB3C64-CDE6-4F18-894D-F99C0D7D9A23" -- iPhone 16 Pro Max iOS 18.6
property screenshotDir : "/Users/griffin/Projects/Nestory/Screenshots/"
property delayBetweenActions : 2 -- seconds

-- Main automation function
on main()
    try
        log "🚀 Starting iOS Simulator automation..."
        
        -- Ensure simulator is running and app is launched
        setupSimulator()
        
        -- Navigate through different views and capture screenshots
        captureInventoryViews()
        captureSettingsViews()
        captureSearchViews()
        captureAnalyticsViews()
        
        log "✅ Automation completed successfully!"
        return "Automation completed successfully"
        
    on error errMsg
        log "❌ Automation failed: " & errMsg
        return "Automation failed: " & errMsg
    end try
end main

-- Setup and launch simulator
on setupSimulator()
    log "📱 Setting up iOS Simulator..."
    
    -- Boot simulator if not booted
    do shell script "xcrun simctl boot " & simulatorDeviceId & " || true"
    
    -- Launch the app
    do shell script "xcrun simctl launch " & simulatorDeviceId & " " & appBundleId
    
    -- Wait for app to load
    delay 3
    
    -- Activate Simulator app
    tell application "Simulator"
        activate
    end tell
    
    delay 1
end setupSimulator

-- Capture inventory-related views
on captureInventoryViews()
    log "📋 Capturing inventory views..."
    
    -- Main inventory view
    takeScreenshot("01-inventory-main")
    
    -- Try to tap on first item (if any)
    tell application "System Events"
        tell process "Simulator"
            try
                -- Look for item rows and tap the first one
                set itemButtons to buttons whose name contains "row" or name contains "item"
                if (count of itemButtons) > 0 then
                    click first item of itemButtons
                    delay delayBetweenActions
                    takeScreenshot("02-item-detail")
                    
                    -- Go back
                    key code 53 -- ESC key
                    delay delayBetweenActions
                end if
            on error
                log "⚠️  No items found to tap"
            end try
        end tell
    end tell
    
    -- Try to access Add Item
    tell application "System Events"
        tell process "Simulator"
            try
                -- Look for plus/add button
                set addButtons to buttons whose name contains "plus" or name contains "add"
                if (count of addButtons) > 0 then
                    click first item of addButtons
                    delay delayBetweenActions
                    takeScreenshot("03-add-item")
                    
                    -- Cancel/dismiss
                    key code 53 -- ESC key
                    delay delayBetweenActions
                end if
            on error
                log "⚠️  Add button not found"
            end try
        end tell
    end tell
end captureInventoryViews

-- Capture settings views
on captureSettingsViews()
    log "⚙️  Capturing settings views..."
    
    -- Navigate to settings tab
    tell application "System Events"
        tell process "Simulator"
            try
                -- Look for settings tab button
                set tabButtons to tab groups
                if (count of tabButtons) > 0 then
                    set settingsTab to buttons whose name contains "Settings" or name contains "settings"
                    if (count of settingsTab) > 0 then
                        click first item of settingsTab
                        delay delayBetweenActions
                        takeScreenshot("04-settings-main")
                    end if
                end if
            on error errMsg
                log "⚠️  Settings tab not found: " & errMsg
            end try
        end tell
    end tell
end captureSettingsViews

-- Capture search views
on captureSearchViews()
    log "🔍 Capturing search views..."
    
    -- Navigate to search (might be part of inventory)
    tell application "System Events"
        tell process "Simulator"
            try
                -- Look for search field
                set searchFields to text fields whose name contains "search" or name contains "Search"
                if (count of searchFields) > 0 then
                    click first item of searchFields
                    delay 1
                    takeScreenshot("05-search-active")
                    
                    -- Type search query
                    keystroke "MacBook"
                    delay delayBetweenActions
                    takeScreenshot("06-search-results")
                    
                    -- Clear search
                    key code 51 -- Delete key (multiple times)
                    key code 51
                    key code 51
                    key code 51
                    key code 51
                    key code 51
                    key code 51
                    delay delayBetweenActions
                end if
            on error errMsg
                log "⚠️  Search field not found: " & errMsg
            end try
        end tell
    end tell
end captureSearchViews

-- Capture analytics views
on captureAnalyticsViews()
    log "📊 Capturing analytics views..."
    
    -- Navigate to analytics tab
    tell application "System Events"
        tell process "Simulator"
            try
                -- Look for analytics tab button
                set analyticsTab to buttons whose name contains "Analytics" or name contains "analytics"
                if (count of analyticsTab) > 0 then
                    click first item of analyticsTab
                    delay delayBetweenActions
                    takeScreenshot("07-analytics-main")
                end if
            on error errMsg
                log "⚠️  Analytics tab not found: " & errMsg
            end try
        end tell
    end tell
end captureAnalyticsViews

-- Utility function to take screenshots
on takeScreenshot(filename)
    set timestamp to (current date) as string
    set fullFilename to filename & "-" & getCurrentTimestamp() & ".png"
    set fullPath to screenshotDir & fullFilename
    
    try
        do shell script "mkdir -p " & screenshotDir
        do shell script "xcrun simctl io " & simulatorDeviceId & " screenshot '" & fullPath & "'"
        log "📸 Screenshot saved: " & fullPath
    on error errMsg
        log "❌ Failed to take screenshot " & filename & ": " & errMsg
    end try
end takeScreenshot

-- Get current timestamp for filenames
on getCurrentTimestamp()
    set currentDate to current date
    set year to year of currentDate as string
    set month to text -2 thru -1 of ("0" & (month of currentDate as integer))
    set day to text -2 thru -1 of ("0" & (day of currentDate))
    set hour to text -2 thru -1 of ("0" & (hours of currentDate))
    set minute to text -2 thru -1 of ("0" & (minutes of currentDate))
    set second to text -2 thru -1 of ("0" & (seconds of currentDate))
    
    return year & month & day & "-" & hour & minute & second
end getCurrentTimestamp

-- Alternative coordinate-based clicking (for precise control)
on clickAtCoordinates(x, y)
    tell application "System Events"
        tell process "Simulator"
            try
                -- Get simulator window
                set simulatorWindow to first window
                set {windowX, windowY} to position of simulatorWindow
                
                -- Click at specific coordinates within simulator
                click at {windowX + x, windowY + y}
                delay 0.5
            on error errMsg
                log "❌ Failed to click at coordinates " & x & ", " & y & ": " & errMsg
            end try
        end tell
    end tell
end clickAtCoordinates

-- Run the main automation
main()