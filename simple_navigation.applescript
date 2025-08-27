-- Simple navigation script for Nestory app testing
tell application "Simulator"
    activate
    delay 2
end tell

-- Use System Events with a different approach
tell application "System Events"
    -- First, make sure Terminal has accessibility permissions
    set frontmost to true
    delay 1
    
    -- Take a screenshot to confirm we're ready
    do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/navigation_start.png"
    
    -- Try using key commands instead of mouse clicks
    -- Press Tab to navigate between UI elements
    key code 48 -- Tab key
    delay 1
    
    -- Take another screenshot
    do shell script "xcrun simctl io 'iPhone 16 Pro Max' screenshot ~/Desktop/NestoryManualTesting/after_tab.png"
    
end tell

return "Navigation attempt completed"