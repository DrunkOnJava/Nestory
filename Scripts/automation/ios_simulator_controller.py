#!/usr/bin/env python3
"""
iOS Simulator Controller for Nestory App
Advanced automation using Python and system APIs
"""

import subprocess
import time
import json
import os
from datetime import datetime
from typing import Optional, Tuple, List, Dict, Any
from pathlib import Path

class iOSSimulatorController:
    def __init__(self, device_id: str = "0CFB3C64-CDE6-4F18-894D-F99C0D7D9A23", 
                 bundle_id: str = "com.drunkonjava.nestory.dev"):
        self.device_id = device_id
        self.bundle_id = bundle_id
        self.screenshot_dir = Path("/Users/griffin/Projects/Nestory/Screenshots")
        self.screenshot_dir.mkdir(exist_ok=True)
        
        # iPhone 16 Pro Max dimensions (points)
        self.screen_width = 430
        self.screen_height = 932
        
    def log(self, message: str, level: str = "INFO"):
        """Enhanced logging with emoji and colors"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        icons = {
            "INFO": "ℹ️",
            "SUCCESS": "✅", 
            "WARNING": "⚠️",
            "ERROR": "❌",
            "DEBUG": "🐛"
        }
        icon = icons.get(level, "📝")
        print(f"[{timestamp}] {icon} {message}")
    
    def run_command(self, command: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run shell command with error handling"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=False
            )
            if result.returncode != 0:
                self.log(f"Command failed: {' '.join(command)}", "ERROR")
                self.log(f"Error: {result.stderr}", "ERROR")
            return result
        except Exception as e:
            self.log(f"Failed to run command {' '.join(command)}: {e}", "ERROR")
            raise
    
    def ensure_simulator_ready(self) -> bool:
        """Ensure simulator is booted and ready"""
        self.log("Checking simulator status...")
        
        # Check if device exists
        result = self.run_command(["xcrun", "simctl", "list", "devices", "-j"])
        if result.returncode != 0:
            return False
            
        devices_data = json.loads(result.stdout)
        
        # Find our device
        device_found = False
        device_state = "unknown"
        
        for runtime, devices in devices_data["devices"].items():
            for device in devices:
                if device["udid"] == self.device_id:
                    device_found = True
                    device_state = device["state"]
                    break
                    
        if not device_found:
            self.log(f"Device {self.device_id} not found", "ERROR")
            return False
            
        # Boot if needed
        if device_state != "Booted":
            self.log("Booting simulator...")
            result = self.run_command(["xcrun", "simctl", "boot", self.device_id])
            if result.returncode == 0:
                time.sleep(5)
                self.log("Simulator booted successfully", "SUCCESS")
            else:
                return False
        else:
            self.log("Simulator already booted", "SUCCESS")
            
        return True
    
    def launch_app(self) -> bool:
        """Launch the Nestory app"""
        self.log(f"Launching {self.bundle_id}...")
        result = self.run_command(["xcrun", "simctl", "launch", self.device_id, self.bundle_id])
        
        if result.returncode == 0:
            time.sleep(3)  # Wait for app to load
            self.log("App launched successfully", "SUCCESS")
            return True
        else:
            self.log("Failed to launch app", "ERROR")
            return False
    
    def take_screenshot(self, name: str) -> Optional[str]:
        """Take and save screenshot"""
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"{name}-{timestamp}.png"
        filepath = self.screenshot_dir / filename
        
        result = self.run_command([
            "xcrun", "simctl", "io", self.device_id, 
            "screenshot", str(filepath)
        ])
        
        if result.returncode == 0:
            self.log(f"Screenshot saved: {filename}", "SUCCESS")
            return str(filepath)
        else:
            self.log(f"Failed to take screenshot: {name}", "ERROR")
            return None
    
    def simulate_touch(self, x: int, y: int, description: str = "touch") -> bool:
        """Simulate touch at coordinates using AppleScript"""
        self.log(f"Simulating {description} at ({x}, {y})")
        
        applescript = f'''
        tell application "Simulator"
            activate
        end tell
        
        delay 0.5
        
        tell application "System Events"
            tell process "Simulator"
                try
                    set simulatorWindow to first window
                    set {{winX, winY}} to position of simulatorWindow
                    set screenOffsetX to 30
                    set screenOffsetY to 100
                    set touchX to winX + screenOffsetX + {x}
                    set touchY to winY + screenOffsetY + {y}
                    click at {{touchX, touchY}}
                on error errMsg
                    log "Touch failed: " & errMsg
                end try
            end tell
        end tell
        '''
        
        result = self.run_command(["osascript", "-e", applescript])
        time.sleep(1)
        return result.returncode == 0
    
    def simulate_swipe(self, start_x: int, start_y: int, end_x: int, end_y: int, 
                      description: str = "swipe") -> bool:
        """Simulate swipe gesture with multiple touch points"""
        self.log(f"Simulating {description} from ({start_x}, {start_y}) to ({end_x}, {end_y})")
        
        # Calculate intermediate points
        steps = 10
        dx = (end_x - start_x) / steps
        dy = (end_y - start_y) / steps
        
        for i in range(steps + 1):
            current_x = int(start_x + i * dx)
            current_y = int(start_y + i * dy)
            
            applescript = f'''
            tell application "System Events"
                tell process "Simulator"
                    try
                        set simulatorWindow to first window
                        set {{winX, winY}} to position of simulatorWindow
                        set screenOffsetX to 30
                        set screenOffsetY to 100
                        set touchX to winX + screenOffsetX + {current_x}
                        set touchY to winY + screenOffsetY + {current_y}
                        click at {{touchX, touchY}}
                    end try
                end tell
            end tell
            '''
            
            self.run_command(["osascript", "-e", applescript])
            time.sleep(0.05)
        
        time.sleep(1)
        return True
    
    def navigate_to_tab(self, tab_name: str) -> bool:
        """Navigate to specific tab in the app"""
        tab_coordinates = {
            "inventory": (86, 878),
            "search": (215, 878), 
            "analytics": (344, 878),
            "settings": (473, 878)
        }
        
        if tab_name.lower() in tab_coordinates:
            x, y = tab_coordinates[tab_name.lower()]
            return self.simulate_touch(x, y, f"{tab_name} tab")
        else:
            self.log(f"Unknown tab: {tab_name}", "WARNING")
            return False
    
    def get_app_info(self) -> Dict[str, Any]:
        """Get detailed app information"""
        result = self.run_command([
            "xcrun", "simctl", "appinfo", self.device_id, self.bundle_id
        ])
        
        if result.returncode == 0:
            try:
                return json.loads(result.stdout)
            except json.JSONDecodeError:
                return {}
        return {}
    
    def comprehensive_navigation(self) -> bool:
        """Run comprehensive app navigation with screenshots"""
        self.log("Starting comprehensive app navigation...", "INFO")
        
        if not self.ensure_simulator_ready():
            return False
            
        if not self.launch_app():
            return False
        
        # Take initial screenshot
        self.take_screenshot("01-app-launch")
        
        # Navigate through main sections
        self._navigate_inventory_section()
        self._navigate_search_section()
        self._navigate_analytics_section()
        self._navigate_settings_section()
        
        self.log("Comprehensive navigation completed!", "SUCCESS")
        return True
    
    def _navigate_inventory_section(self):
        """Navigate through inventory section"""
        self.log("📋 Navigating inventory section...")
        
        self.navigate_to_tab("inventory")
        self.take_screenshot("02-inventory-main")
        
        # Try to tap on first item
        self.simulate_touch(215, 300, "first item")
        self.take_screenshot("03-item-detail")
        
        # Go back (back button)
        self.simulate_touch(50, 100, "back button")
        
        # Try add item button
        self.simulate_touch(380, 100, "add item button")
        self.take_screenshot("04-add-item")
        
        # Cancel
        self.simulate_touch(50, 100, "cancel button")
    
    def _navigate_search_section(self):
        """Navigate through search section"""
        self.log("🔍 Navigating search section...")
        
        self.navigate_to_tab("search")
        self.take_screenshot("05-search-main")
        
        # Activate search
        self.simulate_touch(215, 150, "search field")
        self.take_screenshot("06-search-active")
    
    def _navigate_analytics_section(self):
        """Navigate through analytics section"""
        self.log("📊 Navigating analytics section...")
        
        self.navigate_to_tab("analytics")
        time.sleep(2)  # Analytics might need more time to load
        self.take_screenshot("07-analytics-main")
        
        # Scroll down
        self.simulate_swipe(215, 400, 215, 200, "scroll down")
        self.take_screenshot("08-analytics-scrolled")
    
    def _navigate_settings_section(self):
        """Navigate through settings section"""
        self.log("⚙️ Navigating settings section...")
        
        self.navigate_to_tab("settings")
        self.take_screenshot("09-settings-main")
        
        # Scroll down in settings
        self.simulate_swipe(215, 400, 215, 200, "scroll down settings")
        self.take_screenshot("10-settings-scrolled")
    
    def interactive_mode(self):
        """Interactive mode for manual control"""
        self.log("Starting interactive mode. Type 'help' for commands.", "INFO")
        
        if not self.ensure_simulator_ready():
            return
            
        if not self.launch_app():
            return
        
        while True:
            try:
                command = input("simulator> ").strip().split()
                if not command:
                    continue
                    
                cmd = command[0].lower()
                
                if cmd == "help":
                    self._print_help()
                elif cmd == "screenshot":
                    name = command[1] if len(command) > 1 else "manual-capture"
                    self.take_screenshot(name)
                elif cmd == "touch" and len(command) == 3:
                    x, y = int(command[1]), int(command[2])
                    self.simulate_touch(x, y, "manual touch")
                elif cmd == "swipe" and len(command) == 5:
                    x1, y1, x2, y2 = map(int, command[1:5])
                    self.simulate_swipe(x1, y1, x2, y2, "manual swipe")
                elif cmd == "tab" and len(command) == 2:
                    self.navigate_to_tab(command[1])
                elif cmd == "launch":
                    self.launch_app()
                elif cmd == "info":
                    info = self.get_app_info()
                    print(json.dumps(info, indent=2))
                elif cmd in ["exit", "quit"]:
                    break
                else:
                    self.log(f"Unknown command: {' '.join(command)}", "WARNING")
                    
            except KeyboardInterrupt:
                self.log("Exiting interactive mode", "INFO")
                break
            except Exception as e:
                self.log(f"Error: {e}", "ERROR")
    
    def _print_help(self):
        """Print available commands"""
        print("""
Available commands:
  screenshot [name]     - Take screenshot
  touch <x> <y>         - Simulate touch at coordinates  
  swipe <x1> <y1> <x2> <y2> - Simulate swipe gesture
  tab <name>            - Navigate to tab (inventory/search/analytics/settings)
  launch                - Launch app
  info                  - Show app information
  exit                  - Exit interactive mode
        """)

def main():
    """Main entry point"""
    import sys
    
    controller = iOSSimulatorController()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "navigate":
            controller.comprehensive_navigation()
        elif command == "screenshot":
            name = sys.argv[2] if len(sys.argv) > 2 else "manual"
            controller.ensure_simulator_ready()
            controller.launch_app() 
            controller.take_screenshot(name)
        elif command == "interactive":
            controller.interactive_mode()
        elif command == "launch":
            controller.ensure_simulator_ready()
            controller.launch_app()
        else:
            print("Usage: python3 ios_simulator_controller.py [navigate|screenshot|interactive|launch]")
    else:
        print("iOS Simulator Controller for Nestory")
        print("Usage: python3 ios_simulator_controller.py [navigate|screenshot|interactive|launch]")

if __name__ == "__main__":
    main()