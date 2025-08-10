#!/bin/bash

# Script to generate a clean project tree and save it to TREE.md
# Automatically filters out build artifacts, temporary files, and other junk

# Configuration
OUTPUT_FILE="TREE.md"
PROJECT_ROOT="$(pwd)"

# Check if tree command is available
if ! command -v tree &> /dev/null; then
    echo "Error: 'tree' command not found. Please install it first:"
    echo "  brew install tree"
    exit 1
fi

# Function to generate the tree
generate_tree() {
    echo "Generating clean project tree..."
    
    # Create temporary file for raw tree output
    TEMP_FILE=$(mktemp)
    
    # Generate tree with specific exclusions
    # -I flag excludes patterns (uses | as separator)
    # -a shows hidden files (but we exclude most with patterns)
    # --dirsfirst lists directories before files
    tree --dirsfirst \
        -I 'build|*.xcuserdatad|*.xcworkspace|xcuserdata|*.xcbuilddata|DerivedData|*.build|Index|Logs|ModuleCache|SourcePackages|*.swiftpm|*.o|*.dylib|*.a|*.dSYM|*.ipa|*.xcarchive|.DS_Store|Thumbs.db|node_modules|*.pyc|__pycache__|.git|.svn|.hg|.bzr|*.orig|*.swp|*.swo|*~|*.bak|*.tmp|*.temp|*.log|*.cache|dist|target|out|bin|obj|*.class|*.jar|*.war|*.ear|.idea|*.iml|.vscode|*.code-workspace|.gradle|.sass-cache|.npm|.yarn|package-lock.json|yarn.lock|Pods|Carthage|.build|*.pid|*.seed|*.pid.lock|coverage|.nyc_output|.grunt|bower_components|jspm_packages|typings|lib-cov|*.cover|.hypothesis|.pytest_cache|htmlcov|.tox|.coverage|.coverage.*|.cache|nosetests.xml|coverage.xml|*.mo|*.pot|*.log|local_settings.py|db.sqlite3|instance|.webassets-cache|.scrapy|docs/_build|target|.ipynb_checkpoints|.python-version|.env|.venv|env|venv|ENV|env.bak|venv.bak|.spyderproject|.spyproject|.ropeproject|site|.mypy_cache|.dmypy.json|dmypy.json|.pyre|*.so|*.egg|*.egg-info|MANIFEST|attachments|XCBuildData|EagerLinkingTBDs|PackageFrameworks|*.swiftmodule|*.hmap|*.xcent|*.xcent.der|Objects-normal|*.resp|*FileList|*OutputFileMap.json|*.msgpack|build.db' \
        > "$TEMP_FILE" 2>/dev/null
    
    # Check if tree command succeeded
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate tree"
        rm -f "$TEMP_FILE"
        exit 1
    fi
    
    # Create the TREE.md file with header
    {
        echo "# Project Structure"
        echo ""
        echo "_Last updated: $(date '+%Y-%m-%d %H:%M:%S')_"
        echo ""
        echo '```'
        cat "$TEMP_FILE"
        echo '```'
    } > "$OUTPUT_FILE"
    
    # Clean up
    rm -f "$TEMP_FILE"
    
    # Get statistics
    DIR_COUNT=$(find . -type d ! -path '*/\.*' ! -path '*/build/*' ! -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
    FILE_COUNT=$(find . -type f ! -path '*/\.*' ! -path '*/build/*' ! -path '*/node_modules/*' ! -name '*.xcuserdatad' 2>/dev/null | wc -l | tr -d ' ')
    
    echo "✅ Tree generated successfully!"
    echo "   📁 Directories: $DIR_COUNT"
    echo "   📄 Files: $FILE_COUNT"
    echo "   📝 Output saved to: $OUTPUT_FILE"
}

# Function to watch for changes and regenerate tree
watch_mode() {
    echo "Starting watch mode - tree will be regenerated every 60 seconds"
    echo "Press Ctrl+C to stop"
    
    while true; do
        generate_tree
        echo ""
        echo "⏰ Next update in 60 seconds..."
        sleep 60
    done
}

# Parse command line arguments
case "${1:-}" in
    watch)
        watch_mode
        ;;
    *)
        generate_tree
        ;;
esac