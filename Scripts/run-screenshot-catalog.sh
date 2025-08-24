#!/bin/bash
# run-screenshot-catalog.sh
# Complete screenshot catalog generation pipeline

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="Nestory.xcodeproj"
SCHEME="Nestory-Dev"
SIMULATOR="iPhone 16 Pro Max"
OUTPUT_DIR="$PROJECT_ROOT/screenshot-catalog-$(date +%Y%m%d_%H%M%S)"
RESULT_BUNDLE="$OUTPUT_DIR/test-results.xcresult"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
log_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Header
clear
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     📸 NESTORY SCREENSHOT CATALOG GENERATOR 📸       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Project: $PROJECT_NAME"
echo "Scheme: $SCHEME"
echo "Simulator: $SIMULATOR"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/logs"

# Step 1: Setup Simulator Permissions
log_header "STEP 1: SIMULATOR SETUP"
log_step "Configuring simulator permissions..."

if [ -f "$PROJECT_ROOT/Scripts/setup-simulator-permissions.sh" ]; then
    bash "$PROJECT_ROOT/Scripts/setup-simulator-permissions.sh" "$SIMULATOR" > "$OUTPUT_DIR/logs/permissions.log" 2>&1
    log_success "Permissions configured"
else
    log_info "Permission script not found, skipping"
fi

# Step 2: Build the App
log_header "STEP 2: BUILD APPLICATION"
log_step "Building app for testing..."

xcodebuild build-for-testing \
    -project "$PROJECT_NAME" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -derivedDataPath "$OUTPUT_DIR/DerivedData" \
    2>&1 | tee "$OUTPUT_DIR/logs/build.log" | grep -E "BUILD SUCCEEDED|error:" || true

if grep -q "BUILD SUCCEEDED" "$OUTPUT_DIR/logs/build.log"; then
    log_success "Build succeeded"
else
    log_error "Build failed - check $OUTPUT_DIR/logs/build.log"
    exit 1
fi

# Step 3: Run UI Tests
log_header "STEP 3: RUN SCREENSHOT TESTS"

# Define test classes to run
TEST_CLASSES=(
    "ComprehensiveScreenshotTest"
    "DeterministicScreenshotTest"
    "ComprehensiveUIWiringTest"
)

# Run each test class
for TEST_CLASS in "${TEST_CLASSES[@]}"; do
    log_step "Running $TEST_CLASS..."
    
    TEST_METHOD=""
    case $TEST_CLASS in
        "ComprehensiveScreenshotTest")
            TEST_METHOD="testCompleteAppScreenshotCatalog"
            ;;
        "DeterministicScreenshotTest")
            TEST_METHOD="testMultiRouteSnapshots"
            ;;
        "ComprehensiveUIWiringTest")
            TEST_METHOD="testCompleteUIWiring"
            ;;
    esac
    
    if [ -n "$TEST_METHOD" ]; then
        xcodebuild test-without-building \
            -project "$PROJECT_NAME" \
            -scheme "$SCHEME" \
            -destination "platform=iOS Simulator,name=$SIMULATOR" \
            -derivedDataPath "$OUTPUT_DIR/DerivedData" \
            -resultBundlePath "$RESULT_BUNDLE" \
            -only-testing:"NestoryUITests/$TEST_CLASS/$TEST_METHOD" \
            2>&1 | tee "$OUTPUT_DIR/logs/test_$TEST_CLASS.log" | \
            grep -E "Test Suite|Test Case|\*\* TEST|error:" || true
    fi
done

# Check if result bundle was created
if [ -d "$RESULT_BUNDLE" ]; then
    log_success "Tests completed"
else
    log_error "No test results found"
fi

# Step 4: Extract Screenshots
log_header "STEP 4: EXTRACT SCREENSHOTS"
log_step "Extracting screenshots from test results..."

if [ -f "$PROJECT_ROOT/Scripts/extract-screenshots.py" ]; then
    python3 "$PROJECT_ROOT/Scripts/extract-screenshots.py" \
        "$RESULT_BUNDLE" \
        "$OUTPUT_DIR/screenshots" \
        > "$OUTPUT_DIR/logs/extraction.log" 2>&1
    
    SCREENSHOT_COUNT=$(find "$OUTPUT_DIR/screenshots" -name "*.png" | wc -l | tr -d ' ')
    log_success "Extracted $SCREENSHOT_COUNT screenshots"
else
    # Fallback: Use xcresulttool directly
    log_step "Using xcresulttool for extraction..."
    
    xcrun xcresulttool get \
        --path "$RESULT_BUNDLE" \
        --output-path "$OUTPUT_DIR/screenshots" \
        --legacy 2>&1 | tee "$OUTPUT_DIR/logs/extraction.log"
    
    # Find and organize PNG files
    find "$OUTPUT_DIR/screenshots" -name "*.png" -exec mv {} "$OUTPUT_DIR/screenshots/" \; 2>/dev/null || true
    
    SCREENSHOT_COUNT=$(find "$OUTPUT_DIR/screenshots" -name "*.png" | wc -l | tr -d ' ')
    log_success "Extracted $SCREENSHOT_COUNT screenshots"
fi

# Step 5: Remove Duplicates
log_header "STEP 5: CLEAN DUPLICATES"
log_step "Detecting and removing duplicate screenshots..."

# Create duplicate detection script inline
cat > "$OUTPUT_DIR/remove-duplicates.py" << 'EOF'
#!/usr/bin/env python3
import sys
import hashlib
from pathlib import Path

screenshot_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "./screenshots")
hashes = {}
removed = 0

for img_path in screenshot_dir.glob("*.png"):
    with open(img_path, 'rb') as f:
        file_hash = hashlib.sha256(f.read()).hexdigest()
    
    if file_hash in hashes:
        img_path.unlink()
        removed += 1
        print(f"Removed duplicate: {img_path.name}")
    else:
        hashes[file_hash] = img_path

print(f"\nRemoved {removed} duplicates")
print(f"Remaining: {len(hashes)} unique screenshots")
EOF

python3 "$OUTPUT_DIR/remove-duplicates.py" "$OUTPUT_DIR/screenshots"

# Step 6: Generate HTML Catalog
log_header "STEP 6: GENERATE CATALOG"
log_step "Creating HTML catalog..."

cat > "$OUTPUT_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Nestory Screenshot Catalog</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        h1 {
            color: white;
            font-size: 48px;
            font-weight: 700;
            text-align: center;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .subtitle {
            color: rgba(255,255,255,0.9);
            font-size: 20px;
            text-align: center;
            margin-bottom: 40px;
        }
        .stats {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .stat {
            text-align: center;
        }
        .stat-value {
            font-size: 36px;
            font-weight: 700;
            color: #667eea;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 5px;
        }
        .filters {
            background: white;
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .filter-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filter-btn {
            padding: 10px 20px;
            border: 2px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 25px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 600;
        }
        .filter-btn:hover, .filter-btn.active {
            background: #667eea;
            color: white;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 30px;
        }
        .screenshot {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
        }
        .screenshot:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }
        .screenshot img {
            width: 100%;
            display: block;
            border-bottom: 1px solid #f0f0f0;
        }
        .screenshot-info {
            padding: 20px;
        }
        .screenshot-name {
            font-weight: 600;
            font-size: 18px;
            color: #333;
            margin-bottom: 5px;
        }
        .screenshot-meta {
            font-size: 13px;
            color: #999;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.9);
            z-index: 1000;
            padding: 40px;
        }
        .modal.active { display: flex; align-items: center; justify-content: center; }
        .modal img {
            max-width: 90%;
            max-height: 90%;
            border-radius: 10px;
        }
        .modal-close {
            position: absolute;
            top: 20px;
            right: 40px;
            font-size: 40px;
            color: white;
            cursor: pointer;
        }
        .timestamp {
            text-align: center;
            color: white;
            margin-top: 60px;
            font-size: 14px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📸 Nestory Screenshot Catalog</h1>
        <div class="subtitle">Complete UI/UX Documentation</div>
        
        <div class="stats">
            <div class="stat">
                <div class="stat-value" id="total-count">0</div>
                <div class="stat-label">Total Screenshots</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="screen-count">0</div>
                <div class="stat-label">Unique Screens</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="tab-count">5</div>
                <div class="stat-label">Main Tabs</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="date"></div>
                <div class="stat-label">Generated</div>
            </div>
        </div>
        
        <div class="filters">
            <div class="filter-buttons">
                <button class="filter-btn active" onclick="filterScreenshots('all')">All</button>
                <button class="filter-btn" onclick="filterScreenshots('inventory')">Inventory</button>
                <button class="filter-btn" onclick="filterScreenshots('search')">Search</button>
                <button class="filter-btn" onclick="filterScreenshots('analytics')">Analytics</button>
                <button class="filter-btn" onclick="filterScreenshots('settings')">Settings</button>
                <button class="filter-btn" onclick="filterScreenshots('capture')">Capture</button>
            </div>
        </div>
        
        <div class="grid" id="screenshot-grid">
            <!-- Screenshots will be inserted here -->
        </div>
        
        <div class="timestamp">
            Generated on <span id="timestamp"></span>
        </div>
    </div>
    
    <div class="modal" id="modal" onclick="closeModal()">
        <span class="modal-close">&times;</span>
        <img id="modal-img" src="" alt="">
    </div>
    
    <script>
        // Load screenshots
        const screenshots = [];
EOF

# Add screenshots to HTML
echo "        // Screenshot data" >> "$OUTPUT_DIR/index.html"
for img in "$OUTPUT_DIR/screenshots"/*.png; do
    if [ -f "$img" ]; then
        basename=$(basename "$img")
        echo "        screenshots.push({name: '$basename', path: 'screenshots/$basename'});" >> "$OUTPUT_DIR/index.html"
    fi
done

# Complete HTML
cat >> "$OUTPUT_DIR/index.html" << 'EOF'
        
        // Populate grid
        function loadScreenshots() {
            const grid = document.getElementById('screenshot-grid');
            grid.innerHTML = '';
            
            screenshots.forEach(screenshot => {
                const div = document.createElement('div');
                div.className = 'screenshot';
                div.setAttribute('data-category', detectCategory(screenshot.name));
                div.onclick = () => openModal(screenshot.path);
                
                const displayName = screenshot.name
                    .replace(/_/g, ' ')
                    .replace(/\.png$/, '')
                    .replace(/\b\w/g, l => l.toUpperCase());
                
                div.innerHTML = `
                    <img src="${screenshot.path}" alt="${displayName}">
                    <div class="screenshot-info">
                        <div class="screenshot-name">${displayName}</div>
                        <div class="screenshot-meta">${screenshot.name}</div>
                    </div>
                `;
                
                grid.appendChild(div);
            });
            
            // Update stats
            document.getElementById('total-count').textContent = screenshots.length;
            document.getElementById('screen-count').textContent = 
                new Set(screenshots.map(s => s.name.split('_')[0])).size;
            document.getElementById('date').textContent = 
                new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
            document.getElementById('timestamp').textContent = 
                new Date().toLocaleString();
        }
        
        function detectCategory(name) {
            const lower = name.toLowerCase();
            if (lower.includes('inventory')) return 'inventory';
            if (lower.includes('search')) return 'search';
            if (lower.includes('analytics')) return 'analytics';
            if (lower.includes('settings')) return 'settings';
            if (lower.includes('capture') || lower.includes('camera')) return 'capture';
            return 'other';
        }
        
        function filterScreenshots(category) {
            const buttons = document.querySelectorAll('.filter-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            
            const screenshots = document.querySelectorAll('.screenshot');
            screenshots.forEach(screenshot => {
                if (category === 'all' || screenshot.getAttribute('data-category') === category) {
                    screenshot.style.display = 'block';
                } else {
                    screenshot.style.display = 'none';
                }
            });
        }
        
        function openModal(src) {
            document.getElementById('modal').classList.add('active');
            document.getElementById('modal-img').src = src;
        }
        
        function closeModal() {
            document.getElementById('modal').classList.remove('active');
        }
        
        // Initialize
        loadScreenshots();
    </script>
</body>
</html>
EOF

log_success "HTML catalog generated"

# Step 7: Generate Summary
log_header "STEP 7: SUMMARY"

FINAL_COUNT=$(find "$OUTPUT_DIR/screenshots" -name "*.png" | wc -l | tr -d ' ')

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ CATALOG GENERATION COMPLETE           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "📊 Results:"
echo "   • Screenshots captured: $FINAL_COUNT"
echo "   • Output directory: $OUTPUT_DIR"
echo "   • HTML catalog: $OUTPUT_DIR/index.html"
echo "   • Test results: $RESULT_BUNDLE"
echo ""
echo "📁 Directory structure:"
echo "   $OUTPUT_DIR/"
echo "   ├── index.html          (Interactive catalog)"
echo "   ├── screenshots/        ($FINAL_COUNT images)"
echo "   ├── logs/              (Build and test logs)"
echo "   └── test-results.xcresult"
echo ""

# Open catalog in browser
log_step "Opening catalog in browser..."
open "$OUTPUT_DIR/index.html"

echo ""
echo -e "${CYAN}🎉 Screenshot catalog is ready!${NC}"
echo ""