#!/usr/bin/osascript
--
-- Nestory iOS Simulator Automation Script
-- Comprehensive iOS Simulator control and navigation automation
-- Based on AppleScript Language Guide for iOS Simulator testing
--

-- Configure logging
property logFile : (path to desktop as string) & "nestory_automation_log.txt"
property enableVerboseLogging : true

-- Test configuration
property testTimeout : 30
property screenshotDelay : 2
property navigationDelay : 1

-- Screenshot management
property screenshotDirectory : (path to desktop as string) & "Nestory Screenshots:"
property screenshotCounter : 0

-- Main automation workflow
on run
	log "🚀 Starting Nestory iOS Simulator Automation"
	
	try
		-- Step 1: Setup and launch simulator
		setupTestEnvironment()
		
		-- Step 2: Launch Nestory app
		launchNestoryApp()
		
		-- Step 3: Perform comprehensive navigation testing
		performNavigationTests()
		
		-- Step 4: Test key features
		performFeatureTests()
		
		-- Step 5: Cleanup
		cleanupTestEnvironment()
		
		log "✅ Automation completed successfully"
		
	on error errorMessage
		log "❌ Automation failed: " & errorMessage
		captureFailureScreenshot()
		error errorMessage
	end try
end run

-- Setup test environment
on setupTestEnvironment()
	log "📋 Setting up test environment..."
	
	-- Create screenshot directory
	try
		tell application "Finder"
			if not (exists folder screenshotDirectory) then
				make new folder at desktop with properties {name:"Nestory Screenshots"}
			end if
		end tell
	end try
	
	-- Clear previous logs
	writeToLog("=== NEW TEST SESSION STARTED ===")
	
	-- Ensure Simulator is running
	activateSimulator()
	
	-- Reset simulator to clean state
	resetSimulatorState()
	
	log "✅ Test environment ready"
end setupTestEnvironment

-- Activate iOS Simulator
on activateSimulator()
	tell application "Simulator"
		activate
	end tell
	
	-- Wait for simulator to be responsive
	delay 3
	
	-- Verify simulator is running
	tell application "System Events"
		tell process "Simulator"
			if not (exists window 1) then
				error "Simulator window not found"
			end if
		end tell
	end tell
	
	log "📱 iOS Simulator activated"
end activateSimulator

-- Reset simulator to clean state
on resetSimulatorState()
	log "🔄 Resetting simulator state..."
	
	-- Use xcrun simctl to reset
	try
		do shell script "xcrun simctl shutdown booted"
		delay 2
		do shell script "xcrun simctl boot 'iPhone 15'"
		delay 5
	on error
		-- If simulator is already booted, continue
		log "⚠️ Simulator reset skipped (may already be running)"
	end try
	
	-- Ensure we're on home screen
	pressHomeButton()
end resetSimulatorState

-- Launch Nestory app
on launchNestoryApp()
	log "🚀 Launching Nestory app..."
	
	-- Method 1: Try launching via bundle identifier
	try
		do shell script "xcrun simctl launch booted com.drunkonjava.nestory.dev"
		delay 3
		log "✅ App launched via bundle ID"
		return
	on error
		log "⚠️ Bundle ID launch failed, trying alternative method"
	end try
	
	-- Method 2: Launch via Xcode (if app is installed via Xcode)
	try
		tell application "Xcode"
			activate
		end tell
		
		-- Use keyboard shortcut to run
		tell application "System Events"
			tell process "Xcode"
				keystroke "r" using command down
			end tell
		end tell
		
		delay 10 -- Wait for app to build and launch
		
		-- Switch back to Simulator
		activateSimulator()
		
		log "✅ App launched via Xcode"
		
	on error launchError
		error "Failed to launch Nestory app: " & launchError
	end try
end launchNestoryApp

-- Perform comprehensive navigation tests
on performNavigationTests()
	log "🧭 Starting navigation tests..."
	
	-- Capture initial state
	captureScreenshot("01_app_launch")
	
	-- Test main navigation tabs
	testTabNavigation()
	
	-- Test drill-down navigation
	testDetailNavigation()
	
	-- Test modal presentations
	testModalNavigation()
	
	log "✅ Navigation tests completed"
end performNavigationTests

-- Test tab bar navigation
on testTabNavigation()
	log "📑 Testing tab navigation..."
	
	set tabButtons to {"Inventory", "Categories", "Search", "Analytics", "Settings"}
	
	repeat with tabName in tabButtons
		try
			log "Navigating to " & tabName & " tab"
			
			-- Find and tap tab button
			tell application "System Events"
				tell process "Simulator"
					-- Look for tab bar button
					set tabButton to button tabName of tab group 1 of window 1
					if exists tabButton then
						click tabButton
						delay navigationDelay
						
						-- Capture screenshot
						captureScreenshot("tab_" & tabName)
						
						log "✅ Successfully navigated to " & tabName
					else
						log "⚠️ Tab button not found: " & tabName
					end if
				end tell
			end tell
			
		on error navError
			log "❌ Failed to navigate to " & tabName & ": " & navError
		end try
	end repeat
end testTabNavigation

-- Test detail view navigation
on testDetailNavigation()
	log "🔍 Testing detail navigation..."
	
	-- Navigate to Inventory tab first
	navigateToTab("Inventory")
	
	-- Try to tap on first item (if any exist)
	try
		tell application "System Events"
			tell process "Simulator"
				-- Look for table cells or list items
				set inventoryItems to every cell of table 1 of window 1
				if (count of inventoryItems) > 0 then
					click item 1 of inventoryItems
					delay navigationDelay
					
					captureScreenshot("detail_view")
					
					-- Go back
					pressBackButton()
					delay navigationDelay
					
					log "✅ Detail navigation test completed"
				else
					log "⚠️ No inventory items found for detail navigation test"
				end if
			end tell
		end tell
	on error detailError
		log "❌ Detail navigation failed: " & detailError
	end try
end testDetailNavigation

-- Test modal presentations
on testModalNavigation()
	log "📋 Testing modal navigation..."
	
	-- Navigate to a tab with modals (e.g., Inventory for Add Item)
	navigateToTab("Inventory")
	
	-- Try to open Add Item modal
	try
		tell application "System Events"
			tell process "Simulator"
				-- Look for Add button (usually a + button)
				set addButtons to every button of window 1 whose name contains "Add" or name contains "+"
				if (count of addButtons) > 0 then
					click item 1 of addButtons
					delay navigationDelay
					
					captureScreenshot("modal_add_item")
					
					-- Close modal (look for Cancel/Done button)
					set cancelButtons to every button of window 1 whose name contains "Cancel" or name contains "Done" or name contains "Close"
					if (count of cancelButtons) > 0 then
						click item 1 of cancelButtons
						delay navigationDelay
						log "✅ Modal navigation test completed"
					end if
				else
					log "⚠️ No Add button found for modal test"
				end if
			end tell
		end tell
	on error modalError
		log "❌ Modal navigation failed: " & modalError
	end try
end testModalNavigation

-- Perform feature-specific tests
on performFeatureTests()
	log "🎯 Starting feature tests..."
	
	-- Test Settings screens
	testSettingsFeatures()
	
	-- Test Search functionality  
	testSearchFeatures()
	
	-- Test Analytics views
	testAnalyticsFeatures()
	
	log "✅ Feature tests completed"
end performFeatureTests

-- Test Settings screens
on testSettingsFeatures()
	log "⚙️ Testing Settings features..."
	
	navigateToTab("Settings")
	captureScreenshot("settings_main")
	
	-- Test various settings options
	set settingsOptions to {"General", "Appearance", "Data Storage", "Privacy", "About"}
	
	repeat with settingName in settingsOptions
		try
			tell application "System Events"
				tell process "Simulator"
					-- Look for setting row
					set settingRows to every cell of table 1 of window 1 whose name contains settingName
					if (count of settingRows) > 0 then
						click item 1 of settingRows
						delay navigationDelay
						
						captureScreenshot("settings_" & settingName)
						
						-- Go back
						pressBackButton()
						delay navigationDelay
						
						log "✅ Tested " & settingName & " setting"
					end if
				end tell
			end tell
		on error settingError
			log "⚠️ Could not test " & settingName & " setting: " & settingError
		end try
	end repeat
end testSettingsFeatures

-- Test Search functionality
on testSearchFeatures()
	log "🔍 Testing Search features..."
	
	navigateToTab("Search")
	captureScreenshot("search_main")
	
	-- Try to interact with search field
	try
		tell application "System Events"
			tell process "Simulator"
				-- Look for search field
				set searchFields to every text field of window 1
				if (count of searchFields) > 0 then
					click item 1 of searchFields
					delay 1
					
					-- Type test search query
					keystroke "test item"
					delay 2
					
					captureScreenshot("search_with_query")
					
					-- Clear search
					keystroke "a" using command down
					key code 51 -- Delete key
					
					log "✅ Search functionality tested"
				end if
			end tell
		end tell
	on error searchError
		log "❌ Search test failed: " & searchError
	end try
end testSearchFeatures

-- Test Analytics views
on testAnalyticsFeatures()
	log "📊 Testing Analytics features..."
	
	navigateToTab("Analytics")
	captureScreenshot("analytics_main")
	
	-- Wait for potential data loading
	delay 3
	captureScreenshot("analytics_loaded")
	
	log "✅ Analytics view tested"
end testAnalyticsFeatures

-- Navigation helper functions
on navigateToTab(tabName)
	tell application "System Events"
		tell process "Simulator"
			try
				set tabButton to button tabName of tab group 1 of window 1
				click tabButton
				delay navigationDelay
			on error
				log "⚠️ Could not find tab: " & tabName
			end try
		end tell
	end tell
end navigateToTab

on pressBackButton()
	tell application "System Events"
		tell process "Simulator"
			try
				-- Look for back button (usually first button in nav bar)
				set backButtons to every button of window 1 whose name contains "Back" or title contains "‹"
				if (count of backButtons) > 0 then
					click item 1 of backButtons
				else
					-- Try generic back navigation
					key code 53 -- Escape key as fallback
				end if
			end try
		end tell
	end tell
end pressBackButton

on pressHomeButton()
	-- Simulate home button press
	do shell script "xcrun simctl device booted home"
	delay 1
end pressHomeButton

-- Screenshot management
on captureScreenshot(screenshotName)
	set screenshotCounter to screenshotCounter + 1
	set paddedCounter to my padNumber(screenshotCounter, 3)
	set fileName to paddedCounter & "_" & screenshotName & "_" & my getCurrentTimeString() & ".png"
	set fullPath to screenshotDirectory & fileName
	
	try
		-- Use xcrun simctl to capture screenshot
		do shell script "xcrun simctl io booted screenshot '" & POSIX path of fullPath & "'"
		log "📸 Screenshot captured: " & fileName
		
		-- Add to log
		writeToLog("Screenshot: " & fileName & " at " & (current date as string))
		
	on error screenshotError
		log "❌ Screenshot failed: " & screenshotError
	end try
end captureScreenshot

on captureFailureScreenshot()
	captureScreenshot("FAILURE")
end captureFailureScreenshot

-- Cleanup test environment
on cleanupTestEnvironment()
	log "🧹 Cleaning up test environment..."
	
	-- Return to home screen
	pressHomeButton()
	
	-- Write final log entry
	writeToLog("=== TEST SESSION COMPLETED ===")
	
	log "✅ Cleanup completed"
end cleanupTestEnvironment

-- Utility functions
on padNumber(num, digits)
	set numString to num as string
	repeat while (count of characters of numString) < digits
		set numString to "0" & numString
	end repeat
	return numString
end padNumber

on getCurrentTimeString()
	set currentDate to current date
	set timeString to ""
	
	-- Format: HHMMSS
	set timeString to timeString & my padNumber(hours of currentDate, 2)
	set timeString to timeString & my padNumber(minutes of currentDate, 2)
	set timeString to timeString & my padNumber(seconds of currentDate, 2)
	
	return timeString
end getCurrentTimeString

-- Logging functions
on writeToLog(logMessage)
	if enableVerboseLogging then
		try
			set logEntry to (current date as string) & ": " & logMessage & return
			set logFileHandle to open for access file logFile with write permission
			write logEntry to logFileHandle starting at eof
			close access logFileHandle
		on error
			-- Ignore logging errors to prevent test failures
		end try
	end if
end writeToLog

-- Script completed successfully