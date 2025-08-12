# iTerm2 Multi-Line Path Link Configuration

## Quick Setup for Multi-Line Path Links

### Method 1: iTerm2 Preferences (Recommended)

1. **Open iTerm2 Preferences**
   - Press `Cmd + ,` or iTerm2 → Preferences

2. **Configure Semantic History**
   - Go to: Profiles → Advanced → Semantic History
   - Set to: "Run command..."
   - Command: `open -a Xcode \1`
   - This makes cmd+click open files in Xcode

3. **Enable Smart Selection**
   - Go to: Profiles → Advanced → Smart Selection
   - Click "Edit" button
   - Add these rules:

   **Rule 1: Swift Files with Line Numbers**
   - Notes: `Swift files`
   - Regular Expression: `(/[^\s:]+\.swift):?(\d+)?`
   - Precision: Very High
   - Actions: Run Command → `open -a Xcode \1`

   **Rule 2: Project Paths**
   - Notes: `Nestory paths`
   - Regular Expression: `(/Users/griffin/Projects/Nestory/[^\s:]+)`
   - Precision: High  
   - Actions: Run Command → `open -a Xcode \1`

4. **Configure Text Selection**
   - Go to: Profiles → Terminal
   - Check: "Triple-click selects entire wrapped lines"
   - Check: "Double-click performs smart selection"

### Method 2: Enhanced Path Handling

For better multi-line support, add this to your `.zshrc` or `.bashrc`:

```bash
# Format paths for iTerm2 clickability
alias showpath='echo -e "\033[1;34m\033[4m"'
alias endpath='echo -e "\033[0m"'

# Usage example:
# showpath; echo "/Users/griffin/Projects/Nestory/very/long/path/that/wraps/Services/CloudBackupService.swift:177"; endpath
```

### Method 3: Use Path Shortening

Configure your shell prompt or build output to use relative paths:

```bash
# In build scripts, use:
NESTORY_ROOT="/Users/griffin/Projects/Nestory"
ERROR_PATH="${FILE_PATH#$NESTORY_ROOT/}"
echo "❌ ./$ERROR_PATH:$LINE_NUMBER: $ERROR_MESSAGE"
```

## Tips for Multi-Line Paths

1. **Triple-Click Selection**
   - Triple-click selects the entire logical line, even if wrapped
   - Then Cmd+double-click to open

2. **Right-Click Menu**
   - Right-click on any part of a path
   - Select "Open URL" or configured action

3. **Cmd+Hover**
   - Hold Cmd and hover over paths to see them highlighted
   - Click while highlighted to open

4. **Copy Full Path**
   - Select path fragment
   - Right-click → "Select Output of Command"
   - This expands selection to full path

## Build Output Configuration

Update build scripts to output cleaner paths:

```bash
# In build_install_run.sh, add:
export ITERM_PATH_PREFIX="file://"

# Format errors with clickable paths:
format_error() {
    local file=$1
    local line=$2
    local msg=$3
    echo "❌ ${ITERM_PATH_PREFIX}${file}:${line} - ${msg}"
}
```

## Testing Your Configuration

Test with these commands:

```bash
# Short path (should be clickable)
echo "/Users/griffin/Projects/Nestory/App-Main/NestoryApp.swift:28"

# Long path that wraps (test multi-line clicking)
echo "/Users/griffin/Projects/Nestory/Services/CloudBackup/BackupDataTransformer/RestoreOperations/ItemRestoration/RestoreFromCloudKit.swift:177"

# Path with spaces (properly escaped)
echo "/Users/griffin/Projects/Nestory/App-Main/Settings Views/Import Export Settings View.swift:72"
```

## Troubleshooting

If paths aren't clickable:

1. **Check Profile Settings**
   - Ensure you're using the correct profile
   - Verify Semantic History is set to "Run command..." or "Editor"

2. **Path Format Issues**
   - Paths must start with `/` or `./`
   - Avoid spaces in filenames (or escape them)
   - Remove ANSI color codes around paths

3. **Multi-Line Specific Issues**
   - Enable "Triple-click selects entire wrapped lines"
   - Try selecting with Option+drag for block selection
   - Use shorter relative paths when possible

## Xcode Integration

For best Xcode integration:

1. Set Semantic History to: `Run command...`
2. Command: `open -a Xcode \1`
3. Or use: `xed --line \2 \1` (opens at specific line)

This ensures files open in Xcode at the correct line number when available.

## Alternative: Use Shorter Paths

Configure your environment to use shorter, relative paths:

```bash
# In .zshrc or .bashrc
export NESTORY_SHORT_PATHS=1

# In scripts, use:
if [ "$NESTORY_SHORT_PATHS" = "1" ]; then
    # Convert absolute to relative
    echo "${PATH#/Users/griffin/Projects/Nestory/}"
else
    echo "$PATH"
fi
```

This reduces line wrapping and improves clickability.