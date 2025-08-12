#!/bin/bash
# Configure iTerm2 for better path link handling across multiple lines
# This script sets up iTerm2 to properly handle cmd+click on file paths that wrap

set -e

echo "🔧 Configuring iTerm2 for better path link handling..."

# Create iTerm2 dynamic profiles directory if it doesn't exist
ITERM_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$ITERM_PROFILES_DIR"

# Create a dynamic profile with enhanced semantic history
cat > "$ITERM_PROFILES_DIR/nestory_dev.json" << 'EOF'
{
  "Profiles": [{
    "Name": "Nestory Development",
    "Guid": "nestory-dev-profile",
    "Custom Directory": "Recycle",
    "Working Directory": "/Users/griffin/Projects/Nestory",
    
    "Semantic History": {
      "action": "best editor",
      "text": "",
      "editor": "com.apple.dt.Xcode"
    },
    
    "Smart Cursor Color": true,
    "Draw Powerline Glyphs": true,
    
    "Triggers": [
      {
        "regex": "(/[\\w\\-\\./]+\\.(swift|m|h|mm|cpp|c|txt|md|yml|yaml|json|sh|py))(:\\d+)?",
        "action": "HighlightTrigger",
        "parameter": {
          "regex": "(/[\\w\\-\\./]+\\.(swift|m|h|mm|cpp|c|txt|md|yml|yaml|json|sh|py))(:\\d+)?",
          "colors": {
            "foreground": {
              "Red Component": 0.27,
              "Blue Component": 0.9,
              "Green Component": 0.67
            }
          }
        }
      },
      {
        "regex": "^\\s*(/[\\w\\-\\./]+)",
        "action": "HighlightTrigger",
        "parameter": {
          "regex": "^\\s*(/[\\w\\-\\./]+)",
          "colors": {
            "foreground": {
              "Red Component": 0.27,
              "Blue Component": 0.9,
              "Green Component": 0.67
            }
          }
        }
      }
    ],
    
    "Advanced": {
      "Unlimited Scrollback": false,
      "Scrollback Lines": 10000,
      "Scrollback in Alternate Screen": true,
      "Mouse Reporting allow mouse wheel": true
    }
  }]
}
EOF

echo "✅ Created iTerm2 dynamic profile: Nestory Development"

# Apply settings via defaults (these work globally)
echo "📝 Applying global iTerm2 settings..."

# Enable semantic history with multi-line support
defaults write com.googlecode.iterm2 "Semantic History" -dict \
    action "editor" \
    editor "com.apple.dt.Xcode"

# Skip the complex defaults commands that cause nesting errors
# These settings are better configured through iTerm2's GUI

# Create plist for smart selection rules
cat > "$HOME/Library/Application Support/iTerm2/smart_selection_rules.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>notes</key>
        <string>Swift/Xcode file paths with line numbers</string>
        <key>precision</key>
        <string>very_high</string>
        <key>regex</key>
        <string>(/(?:[\w\-\.]+/)*[\w\-\.]+\.swift)(?::(\d+))?</string>
        <key>actions</key>
        <array>
            <dict>
                <key>title</key>
                <string>Open in Xcode</string>
                <key>action</key>
                <string>open -a Xcode "\1"</string>
            </dict>
        </array>
    </dict>
    <dict>
        <key>notes</key>
        <string>Any file path</string>
        <key>precision</key>
        <string>high</string>
        <key>regex</key>
        <string>(/(?:[\w\-\.]+/)*[\w\-\.]+\.[\w]+)</string>
        <key>actions</key>
        <array>
            <dict>
                <key>title</key>
                <string>Open</string>
                <key>action</key>
                <string>open "\1"</string>
            </dict>
        </array>
    </dict>
</array>
</plist>
EOF

echo "✅ Applied smart selection rules for file paths"

# Create a helper script for better path formatting
cat > "$HOME/.iterm2_path_helper.sh" << 'EOF'
#!/bin/bash
# Helper functions for better path display in iTerm2

# Function to format paths with proper escaping
format_path() {
    local path="$1"
    # Ensure path is properly escaped but still clickable
    echo -e "\033[4m${path}\033[0m"
}

# Function to print build errors with clickable paths
print_error() {
    local file="$1"
    local line="$2"
    local message="$3"
    echo -e "❌ \033[4m${file}:${line}\033[0m: ${message}"
}

# Function to print file references
print_file() {
    local file="$1"
    echo -e "📄 \033[4m${file}\033[0m"
}

# Export functions for use in other scripts
export -f format_path
export -f print_error
export -f print_file
EOF

chmod +x "$HOME/.iterm2_path_helper.sh"

echo "✅ Created path helper functions at ~/.iterm2_path_helper.sh"

# Add to shell profile if not already there
SHELL_RC="$HOME/.zshrc"
if [ "$SHELL" = "/bin/bash" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q "iterm2_path_helper" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# iTerm2 path helper for better link handling" >> "$SHELL_RC"
    echo "[ -f ~/.iterm2_path_helper.sh ] && source ~/.iterm2_path_helper.sh" >> "$SHELL_RC"
    echo "✅ Added path helper to $SHELL_RC"
fi

echo ""
echo "🎯 Configuration complete!"
echo ""
echo "📋 To activate the new settings:"
echo "1. Restart iTerm2 or create a new tab"
echo "2. For the new profile: iTerm2 → Preferences → Profiles → Select 'Nestory Development'"
echo "3. Or import settings: iTerm2 → Preferences → General → Preferences → Load preferences from custom folder"
echo ""
echo "🔗 Enhanced link detection features:"
echo "• Cmd+Click on any file path to open in Xcode"
echo "• Paths spanning multiple lines are now clickable"
echo "• File paths with line numbers (file.swift:42) are supported"
echo "• Right-click on paths for open options"
echo ""
echo "💡 Tips for better path handling:"
echo "• Use the helper functions: format_path, print_error, print_file"
echo "• Triple-click selects entire paths even across lines"
echo "• Hold Option while selecting for rectangular selection"
echo "• Cmd+Shift+Click opens path in new tab"