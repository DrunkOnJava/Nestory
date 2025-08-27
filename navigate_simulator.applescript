-- AppleScript to navigate through Nestory app in Simulator
-- This script will make the simulator visible and navigate through tabs

tell application "Simulator"
    activate
    delay 1
end tell

-- Make sure simulator window is visible
tell application "System Events"
    tell process "Simulator"
        set frontmost to true
        delay 2
        
        -- Take initial screenshot
        do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/02_simulator_activated.png"
        
        -- Get the simulator window
        set simulatorWindow to front window
        
        -- Try to click on Search tab (approximate coordinates)
        -- Bottom tab bar, second tab from left
        click at {216, 950} of simulatorWindow
        delay 2
        
        -- Take screenshot of Search tab
        do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/03_search_tab.png"
        
        -- Click on Capture tab (middle tab)
        click at {360, 950} of simulatorWindow  
        delay 2
        
        -- Take screenshot of Capture tab
        do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/04_capture_tab.png"
        
        -- Click on Analytics tab
        click at {504, 950} of simulatorWindow
        delay 2
        
        -- Take screenshot of Analytics tab  
        do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/05_analytics_tab.png"
        
        -- Click on Settings tab
        click at {648, 950} of simulatorWindow
        delay 2
        
        -- Take screenshot of Settings tab
        do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/06_settings_tab.png"
        
        -- Go back to Inventory tab
        click at {72, 950} of simulatorWindow
        delay 2
        
        -- Take final screenshot
        do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/07_back_to_inventory.png"
        
    end tell
end tell

display dialog "Manual navigation testing complete! Check ~/Desktop/NestoryManualTesting/ for screenshots."