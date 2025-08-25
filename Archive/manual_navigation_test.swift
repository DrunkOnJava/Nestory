#!/usr/bin/env swift
import Foundation

// Simple script to generate navigation commands for XCUITest
let commands = [
    "app.tabBars.buttons[\"Search\"].tap()",
    "app.tabBars.buttons[\"Analytics\"].tap()",
    "app.tabBars.buttons[\"Categories\"].tap()",
    "app.tabBars.buttons[\"Settings\"].tap()",
    "app.tabBars.buttons[\"Inventory\"].tap()",
]

print("Navigation commands for manual testing:")
for (index, command) in commands.enumerated() {
    print("\(index + 1). \(command)")
}
