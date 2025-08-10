#!/bin/bash

# Setup script for automatic TREE.md generation
# This configures git hooks and optional cron job for periodic updates

PROJECT_ROOT="$(pwd)"
SCRIPT_PATH="$PROJECT_ROOT/update_tree.sh"

echo "🌳 Setting up automatic TREE.md generation..."

# Ensure update_tree.sh exists and is executable
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Error: update_tree.sh not found in current directory"
    exit 1
fi

chmod +x "$SCRIPT_PATH"

# Function to setup git hooks
setup_git_hooks() {
    echo "Setting up git hooks..."
    
    # Check if .git directory exists
    if [ ! -d ".git" ]; then
        echo "⚠️  Warning: Not a git repository. Skipping git hooks setup."
        return
    fi
    
    # Create hooks directory if it doesn't exist
    mkdir -p .git/hooks
    
    # Create post-commit hook
    cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash
# Auto-update TREE.md after each commit

# Only update if we're not in a rebase or merge
if [ -z "$GIT_REBASE_TODO" ] && [ ! -f .git/MERGE_HEAD ]; then
    echo "Updating TREE.md..."
    ./update_tree.sh
    
    # Check if TREE.md changed
    if git diff --quiet HEAD -- TREE.md; then
        echo "TREE.md is up to date"
    else
        # Add the updated TREE.md to the commit
        git add TREE.md
        git commit --amend --no-edit --no-verify
        echo "TREE.md updated and added to commit"
    fi
fi
EOF
    
    chmod +x .git/hooks/post-commit
    
    # Create pre-push hook
    cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
# Ensure TREE.md is up to date before pushing

echo "Checking if TREE.md is up to date..."
./update_tree.sh

if git diff --quiet HEAD -- TREE.md; then
    echo "✅ TREE.md is up to date"
else
    echo "⚠️  TREE.md is out of date. Updating..."
    git add TREE.md
    git commit -m "chore: update TREE.md" --no-verify
    echo "✅ TREE.md updated and committed"
fi
EOF
    
    chmod +x .git/hooks/pre-push
    
    echo "✅ Git hooks configured"
}

# Function to setup cron job for periodic updates
setup_cron() {
    echo ""
    echo "Would you like to setup automatic periodic updates? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "How often should the tree be updated?"
        echo "1) Every hour"
        echo "2) Every 6 hours"
        echo "3) Daily at midnight"
        echo "4) Weekly on Sundays"
        read -r choice
        
        CRON_SCHEDULE=""
        case $choice in
            1) CRON_SCHEDULE="0 * * * *" ;;
            2) CRON_SCHEDULE="0 */6 * * *" ;;
            3) CRON_SCHEDULE="0 0 * * *" ;;
            4) CRON_SCHEDULE="0 0 * * 0" ;;
            *) echo "Invalid choice. Skipping cron setup."; return ;;
        esac
        
        # Create cron entry
        CRON_CMD="cd $PROJECT_ROOT && ./update_tree.sh"
        
        # Check if cron entry already exists
        if crontab -l 2>/dev/null | grep -q "$PROJECT_ROOT/update_tree.sh"; then
            echo "⚠️  Cron job already exists. Updating..."
            # Remove old entry
            (crontab -l 2>/dev/null | grep -v "$PROJECT_ROOT/update_tree.sh") | crontab -
        fi
        
        # Add new cron entry
        (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $CRON_CMD") | crontab -
        
        echo "✅ Cron job configured to run: $CRON_SCHEDULE"
        echo "   View with: crontab -l"
        echo "   Remove with: crontab -l | grep -v 'update_tree.sh' | crontab -"
    fi
}

# Function to create VS Code task
setup_vscode_task() {
    if [ -d ".vscode" ] || [ -f ".vscode/tasks.json" ]; then
        echo ""
        echo "VS Code detected. Adding task for tree generation..."
        
        mkdir -p .vscode
        
        if [ ! -f ".vscode/tasks.json" ]; then
            cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Update Project Tree",
            "type": "shell",
            "command": "./update_tree.sh",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": []
        }
    ]
}
EOF
        echo "✅ VS Code task created (Run with Cmd+Shift+P > 'Tasks: Run Task')"
        else
            echo "⚠️  .vscode/tasks.json already exists. Please add the task manually."
        fi
    fi
}

# Main setup flow
echo ""
echo "Choose setup options:"
echo "1) Git hooks only (recommended)"
echo "2) Git hooks + Cron job"
echo "3) Everything (Git hooks + Cron + VS Code task)"
echo "4) Just run once now"
read -r setup_choice

case $setup_choice in
    1)
        setup_git_hooks
        ;;
    2)
        setup_git_hooks
        setup_cron
        ;;
    3)
        setup_git_hooks
        setup_cron
        setup_vscode_task
        ;;
    4)
        ./update_tree.sh
        ;;
    *)
        echo "Invalid choice. Running tree generation once..."
        ./update_tree.sh
        ;;
esac

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Usage:"
echo "  ./update_tree.sh         - Generate tree once"
echo "  ./update_tree.sh watch   - Watch mode (updates every 60 seconds)"
echo ""