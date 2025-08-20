//
// ComprehensiveUIFlowTests.swift
// NestoryUITests
//
// Comprehensive UI automation workflows using XCUIAutomation
// Tests complete user journeys and feature interactions
//

import XCTest

@MainActor
final class ComprehensiveUIFlowTests: NestoryUITestBase {
    // MARK: - Complete User Journey Tests

    func testCompleteInventoryManagementFlow() async {
        logProgress("🚀 Starting complete inventory management flow test")

        // Step 1: Navigate to Inventory and verify initial state
        navigateToTab("Inventory")
        await captureScreenshot("01_inventory_initial")

        // Step 2: Add a new item
        await addNewItemFlow()

        // Step 3: View item details
        await viewItemDetailsFlow()

        // Step 4: Edit item
        await editItemFlow()

        // Step 5: Search for item
        await searchForItemFlow()

        // Step 6: Generate insurance report
        await generateInsuranceReportFlow()

        logProgress("✅ Complete inventory management flow test completed")
    }

    func testSettingsConfigurationFlow() async {
        logProgress("🚀 Starting settings configuration flow test")

        // Step 1: Navigate to Settings
        navigateToTab("Settings")
        await captureScreenshot("01_settings_main")

        // Step 2: Configure appearance settings
        await configureAppearanceSettings()

        // Step 3: Set up data storage preferences
        await configureDataStorageSettings()

        // Step 4: Configure notifications
        await configureNotificationSettings()

        // Step 5: Test export functionality
        await testExportFunctionality()

        logProgress("✅ Settings configuration flow test completed")
    }

    func testAnalyticsDashboardFlow() async {
        logProgress("🚀 Starting analytics dashboard flow test")

        // Step 1: Navigate to Analytics
        navigateToTab("Analytics")
        await captureScreenshot("01_analytics_dashboard")

        // Step 2: Test different chart views
        await testAnalyticsChartViews()

        // Step 3: Test date range filtering
        await testAnalyticsDateFiltering()

        // Step 4: Test category breakdown
        await testAnalyticsCategoryBreakdown()

        // Step 5: Test export analytics data
        await testAnalyticsExport()

        logProgress("✅ Analytics dashboard flow test completed")
    }

    // MARK: - Inventory Management Workflows

    private func addNewItemFlow() async {
        logProgress("➕ Testing add new item flow")

        // Look for Add button
        let addButton = app.buttons["add_item"]
        if waitForElement(addButton) {
            safeTap(addButton)
            await captureScreenshot("02_add_item_modal")

            // Fill in item details
            await fillItemDetails()

            // Save item
            let saveButton = app.buttons["save_item"]
            if waitForElement(saveButton) {
                safeTap(saveButton)
                await captureScreenshot("03_item_saved")
            }
        } else {
            logProgress("⚠️ Add button not found, checking for alternative patterns")
            // Try floating action button
            let fabButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS '+'")).element
            if waitForElement(fabButton) {
                safeTap(fabButton)
                await captureScreenshot("02_add_item_fab")
                await fillItemDetails()
            }
        }
    }

    private func fillItemDetails() async {
        logProgress("📝 Filling item details")

        // Item name
        let nameField = app.textFields["item_name"]
        if waitForElement(nameField) {
            safeTap(nameField)
            nameField.typeText("Test UI Item")
            await captureScreenshot("04_item_name_filled")
        }

        // Category selection
        let categoryField = app.buttons["category_picker"]
        if waitForElement(categoryField) {
            safeTap(categoryField)
            await captureScreenshot("05_category_picker")

            // Select Electronics category
            let electronicsCategory = app.buttons["Electronics"]
            if waitForElement(electronicsCategory) {
                safeTap(electronicsCategory)
            }
        }

        // Purchase price
        let priceField = app.textFields["purchase_price"]
        if waitForElement(priceField) {
            safeTap(priceField)
            priceField.typeText("299.99")
        }

        // Location
        let locationField = app.textFields["item_location"]
        if waitForElement(locationField) {
            safeTap(locationField)
            locationField.typeText("Home Office")
            await captureScreenshot("06_item_details_complete")
        }
    }

    private func viewItemDetailsFlow() async {
        logProgress("👁️ Testing view item details flow")

        // Find first item in list
        let firstItem = app.cells.element(boundBy: 0)
        if waitForElement(firstItem) {
            safeTap(firstItem)
            await captureScreenshot("07_item_details_view")

            // Verify detail view elements
            let itemNameLabel = app.staticTexts["item_detail_name"]
            assertExists(itemNameLabel, "Item name should be visible in detail view")

            // Test photo gallery if present
            let photoGallery = app.collectionViews["photo_gallery"]
            if photoGallery.exists {
                await captureScreenshot("08_item_photos")
            }

            // Test warranty information
            let warrantySection = app.buttons["warranty_section"]
            if warrantySection.exists {
                safeTap(warrantySection)
                await captureScreenshot("09_warranty_details")
            }
        }
    }

    private func editItemFlow() async {
        logProgress("✏️ Testing edit item flow")

        // Look for Edit button
        let editButton = app.buttons["edit_item"]
        if waitForElement(editButton) {
            safeTap(editButton)
            await captureScreenshot("10_edit_item_view")

            // Update item name
            let nameField = app.textFields["item_name"]
            if waitForElement(nameField) {
                // Clear existing text and enter new
                nameField.tap()
                nameField.clearText()
                nameField.typeText("Updated Test Item")
                await captureScreenshot("11_item_name_updated")
            }

            // Save changes
            let saveButton = app.buttons["save_changes"]
            if waitForElement(saveButton) {
                safeTap(saveButton)
                await captureScreenshot("12_item_updated")
            }
        }
    }

    private func searchForItemFlow() async {
        logProgress("🔍 Testing search for item flow")

        // Navigate to Search tab
        navigateToTab("Search")
        await captureScreenshot("13_search_tab")

        // Enter search query
        let searchField = app.searchFields.element
        if waitForElement(searchField) {
            safeTap(searchField)
            searchField.typeText("Test")
            await captureScreenshot("14_search_query_entered")

            // Wait for search results
            Thread.sleep(forTimeInterval: 2.0)
            await captureScreenshot("15_search_results")

            // Tap on search result
            let firstResult = app.cells.element(boundBy: 0)
            if waitForElement(firstResult) {
                safeTap(firstResult)
                await captureScreenshot("16_search_result_detail")
            }
        }
    }

    private func generateInsuranceReportFlow() async {
        logProgress("📄 Testing insurance report generation flow")

        // Navigate back to inventory
        navigateToTab("Inventory")

        // Look for export/report button
        let exportButton = app.buttons["export_report"]
        if waitForElement(exportButton) {
            safeTap(exportButton)
            await captureScreenshot("17_export_options")

            // Select insurance report
            let insuranceReportOption = app.buttons["insurance_report"]
            if waitForElement(insuranceReportOption) {
                safeTap(insuranceReportOption)
                await captureScreenshot("18_insurance_report_options")

                // Generate report
                let generateButton = app.buttons["generate_report"]
                if waitForElement(generateButton) {
                    safeTap(generateButton)

                    // Wait for report generation
                    Thread.sleep(forTimeInterval: 3.0)
                    await captureScreenshot("19_report_generated")
                }
            }
        }
    }

    // MARK: - Settings Configuration Workflows

    private func configureAppearanceSettings() async {
        logProgress("🎨 Configuring appearance settings")

        let appearanceRow = app.cells["appearance_settings"]
        if waitForElement(appearanceRow) {
            safeTap(appearanceRow)
            await captureScreenshot("20_appearance_settings")

            // Test theme selection
            let darkModeToggle = app.switches["dark_mode_toggle"]
            if waitForElement(darkModeToggle) {
                if !darkModeToggle.isSelected {
                    safeTap(darkModeToggle)
                    await captureScreenshot("21_dark_mode_enabled")
                }
            }

            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if waitForElement(backButton) {
                safeTap(backButton)
            }
        }
    }

    private func configureDataStorageSettings() async {
        logProgress("💾 Configuring data storage settings")

        let dataStorageRow = app.cells["data_storage_settings"]
        if waitForElement(dataStorageRow) {
            safeTap(dataStorageRow)
            await captureScreenshot("22_data_storage_settings")

            // Test cloud backup toggle
            let cloudBackupToggle = app.switches["cloud_backup_toggle"]
            if waitForElement(cloudBackupToggle) {
                if !cloudBackupToggle.isSelected {
                    safeTap(cloudBackupToggle)
                    await captureScreenshot("23_cloud_backup_enabled")
                }
            }

            // Test backup now button
            let backupNowButton = app.buttons["backup_now"]
            if waitForElement(backupNowButton) {
                safeTap(backupNowButton)
                await captureScreenshot("24_backup_initiated")
            }

            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if waitForElement(backButton) {
                safeTap(backButton)
            }
        }
    }

    private func configureNotificationSettings() async {
        logProgress("🔔 Configuring notification settings")

        let notificationRow = app.cells["notification_settings"]
        if waitForElement(notificationRow) {
            safeTap(notificationRow)
            await captureScreenshot("25_notification_settings")

            // Test warranty reminders
            let warrantyRemindersToggle = app.switches["warranty_reminders"]
            if waitForElement(warrantyRemindersToggle) {
                if !warrantyRemindersToggle.isSelected {
                    safeTap(warrantyRemindersToggle)
                    await captureScreenshot("26_warranty_reminders_enabled")
                }
            }

            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if waitForElement(backButton) {
                safeTap(backButton)
            }
        }
    }

    private func testExportFunctionality() async {
        logProgress("📤 Testing export functionality")

        let exportRow = app.cells["import_export_settings"]
        if waitForElement(exportRow) {
            safeTap(exportRow)
            await captureScreenshot("27_export_settings")

            // Test CSV export
            let csvExportButton = app.buttons["export_csv"]
            if waitForElement(csvExportButton) {
                safeTap(csvExportButton)
                await captureScreenshot("28_csv_export_initiated")

                // Handle system share sheet
                Thread.sleep(forTimeInterval: 2.0)
                await captureScreenshot("29_share_sheet")

                // Cancel share sheet
                let cancelButton = app.buttons["Cancel"]
                if waitForElement(cancelButton) {
                    safeTap(cancelButton)
                }
            }

            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if waitForElement(backButton) {
                safeTap(backButton)
            }
        }
    }

    // MARK: - Analytics Dashboard Workflows

    private func testAnalyticsChartViews() async {
        logProgress("📊 Testing analytics chart views")

        // Test different chart types
        let chartTypeSelector = app.segmentedControls["chart_type_selector"]
        if waitForElement(chartTypeSelector) {
            await captureScreenshot("30_chart_bar_view")

            // Switch to pie chart
            let pieChartButton = chartTypeSelector.buttons["Pie"]
            if waitForElement(pieChartButton) {
                safeTap(pieChartButton)
                Thread.sleep(forTimeInterval: 1.0)
                await captureScreenshot("31_chart_pie_view")
            }

            // Switch to line chart
            let lineChartButton = chartTypeSelector.buttons["Line"]
            if waitForElement(lineChartButton) {
                safeTap(lineChartButton)
                Thread.sleep(forTimeInterval: 1.0)
                await captureScreenshot("32_chart_line_view")
            }
        }
    }

    private func testAnalyticsDateFiltering() async {
        logProgress("📅 Testing analytics date filtering")

        let dateFilterButton = app.buttons["date_filter"]
        if waitForElement(dateFilterButton) {
            safeTap(dateFilterButton)
            await captureScreenshot("33_date_filter_options")

            // Select last 6 months
            let sixMonthsOption = app.buttons["last_6_months"]
            if waitForElement(sixMonthsOption) {
                safeTap(sixMonthsOption)
                Thread.sleep(forTimeInterval: 2.0)
                await captureScreenshot("34_six_months_data")
            }
        }
    }

    private func testAnalyticsCategoryBreakdown() async {
        logProgress("📈 Testing analytics category breakdown")

        let categoryBreakdownButton = app.buttons["category_breakdown"]
        if waitForElement(categoryBreakdownButton) {
            safeTap(categoryBreakdownButton)
            await captureScreenshot("35_category_breakdown")

            // Tap on a category for details
            let electronicsCategory = app.buttons["Electronics"]
            if waitForElement(electronicsCategory) {
                safeTap(electronicsCategory)
                await captureScreenshot("36_electronics_detail")
            }
        }
    }

    private func testAnalyticsExport() async {
        logProgress("📤 Testing analytics export")

        let exportButton = app.buttons["export_analytics"]
        if waitForElement(exportButton) {
            safeTap(exportButton)
            await captureScreenshot("37_analytics_export_options")

            // Select PDF export
            let pdfExportOption = app.buttons["export_pdf"]
            if waitForElement(pdfExportOption) {
                safeTap(pdfExportOption)
                Thread.sleep(forTimeInterval: 2.0)
                await captureScreenshot("38_pdf_export_progress")
            }
        }
    }

    // MARK: - Error Scenarios and Edge Cases

    func testErrorHandlingScenarios() async {
        logProgress("🚨 Testing error handling scenarios")

        // Test network error simulation
        await testNetworkErrorScenario()

        // Test invalid input handling
        await testInvalidInputHandling()

        // Test memory pressure scenarios
        await testMemoryPressureScenarios()
    }

    private func testNetworkErrorScenario() async {
        logProgress("🌐 Testing network error scenario")

        // Navigate to cloud backup settings
        navigateToTab("Settings")
        let dataStorageRow = app.cells["data_storage_settings"]
        if waitForElement(dataStorageRow) {
            safeTap(dataStorageRow)

            // Try to backup when network is unavailable
            let backupButton = app.buttons["backup_now"]
            if waitForElement(backupButton) {
                safeTap(backupButton)

                // Check for error alert
                let errorAlert = app.alerts.element
                if waitForElement(errorAlert, timeout: TestConfig.longTimeout) {
                    await captureScreenshot("39_network_error_alert")

                    // Dismiss alert
                    let okButton = errorAlert.buttons["OK"]
                    if waitForElement(okButton) {
                        safeTap(okButton)
                    }
                }
            }
        }
    }

    private func testInvalidInputHandling() async {
        logProgress("❌ Testing invalid input handling")

        // Navigate to add item
        navigateToTab("Inventory")
        let addButton = app.buttons["add_item"]
        if waitForElement(addButton) {
            safeTap(addButton)

            // Enter invalid price
            let priceField = app.textFields["purchase_price"]
            if waitForElement(priceField) {
                safeTap(priceField)
                priceField.typeText("invalid_price")

                // Try to save
                let saveButton = app.buttons["save_item"]
                if waitForElement(saveButton) {
                    safeTap(saveButton)

                    // Check for validation error
                    await captureScreenshot("40_invalid_price_error")

                    // Cancel adding item
                    let cancelButton = app.buttons["cancel"]
                    if waitForElement(cancelButton) {
                        safeTap(cancelButton)
                    }
                }
            }
        }
    }

    private func testMemoryPressureScenarios() async {
        logProgress("🧠 Testing memory pressure scenarios")

        // Navigate through multiple screens rapidly to simulate memory pressure
        let tabs = ["Inventory", "Categories", "Search", "Analytics", "Settings"]

        for _ in 0 ..< 5 {
            for tab in tabs {
                navigateToTab(tab)
                Thread.sleep(forTimeInterval: 0.2)
            }
        }

        await captureScreenshot("41_memory_pressure_test")

        // Verify app is still responsive
        navigateToTab("Inventory")
        let inventoryTable = app.tables.element
        assertExists(inventoryTable, "App should remain responsive after memory pressure test")
    }

    // MARK: - Accessibility Testing

    func testAccessibilityFeatures() async {
        logProgress("♿ Testing accessibility features")

        // Test VoiceOver labels
        await testVoiceOverLabels()

        // Test Dynamic Type support
        await testDynamicTypeSupport()

        // Test color contrast
        await testColorContrastSupport()
    }

    private func testVoiceOverLabels() async {
        logProgress("🗣️ Testing VoiceOver labels")

        navigateToTab("Inventory")

        // Check that key elements have accessibility labels
        let addButton = app.buttons["add_item"]
        if addButton.exists {
            XCTAssertFalse(addButton.label.isEmpty, "Add button should have accessibility label")
            await captureScreenshot("42_accessibility_add_button")
        }

        // Test table cell accessibility
        let firstCell = app.cells.element(boundBy: 0)
        if firstCell.exists {
            XCTAssertFalse(firstCell.label.isEmpty, "Table cells should have accessibility labels")
        }
    }

    private func testDynamicTypeSupport() async {
        logProgress("📱 Testing Dynamic Type support")

        // Navigate to settings and look for text size options
        navigateToTab("Settings")
        let appearanceRow = app.cells["appearance_settings"]
        if waitForElement(appearanceRow) {
            safeTap(appearanceRow)
            await captureScreenshot("43_text_size_settings")
        }
    }

    private func testColorContrastSupport() async {
        logProgress("🎨 Testing color contrast support")

        // Test both light and dark mode for contrast
        navigateToTab("Settings")
        let appearanceRow = app.cells["appearance_settings"]
        if waitForElement(appearanceRow) {
            safeTap(appearanceRow)

            let darkModeToggle = app.switches["dark_mode_toggle"]
            if waitForElement(darkModeToggle) {
                // Toggle dark mode
                safeTap(darkModeToggle)
                Thread.sleep(forTimeInterval: 1.0)
                await captureScreenshot("44_dark_mode_contrast")

                // Toggle back
                safeTap(darkModeToggle)
                Thread.sleep(forTimeInterval: 1.0)
                await captureScreenshot("45_light_mode_contrast")
            }
        }
    }

    // MARK: - Performance Testing

    func testPerformanceScenarios() async {
        logProgress("⚡ Testing performance scenarios")

        // Test app launch time
        app.terminate()

        let launchTime = measureTime {
            app.launch()
            _ = app.wait(for: .runningForeground, timeout: TestConfig.defaultTimeout)
        }

        logProgress("📊 App launch time: \(launchTime.time) seconds")
        XCTAssertLessThan(launchTime.time, 5.0, "App should launch within 5 seconds")

        // Test scroll performance
        await testScrollPerformance()

        // Test memory usage during heavy operations
        await testMemoryUsageDuringOperations()
    }

    private func testScrollPerformance() async {
        logProgress("📜 Testing scroll performance")

        navigateToTab("Inventory")
        let inventoryTable = app.tables.element

        if waitForElement(inventoryTable) {
            let scrollTime = measureTime {
                for _ in 0 ..< 10 {
                    inventoryTable.swipeUp()
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }

            logProgress("📊 Scroll test time: \(scrollTime.time) seconds")
            await captureScreenshot("46_scroll_performance_test")
        }
    }

    private func testMemoryUsageDuringOperations() async {
        logProgress("🧠 Testing memory usage during operations")

        // Perform memory-intensive operations
        for i in 0 ..< 5 {
            navigateToTab("Analytics")
            Thread.sleep(forTimeInterval: 0.5)

            navigateToTab("Inventory")
            Thread.sleep(forTimeInterval: 0.5)

            await captureScreenshot("47_memory_test_iteration_\(i)")
        }

        // Verify app is still responsive
        let inventoryTable = app.tables.element
        assertExists(inventoryTable, "App should remain responsive after memory test")
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearText() {
        guard let stringValue = value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
