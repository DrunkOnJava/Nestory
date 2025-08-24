#!/bin/bash
# setup-environment.sh - Complete isolated environment setup for Nestory testing
# Creates a fully configured virtual environment with all dependencies

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VENV_DIR=".testing-env"
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
SCREENSHOTS_DIR="$PROJECT_ROOT/test-output/screenshots"
LOGS_DIR="$PROJECT_ROOT/test-output/logs"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Header
echo ""
echo "========================================="
echo "   Nestory Testing Environment Setup"
echo "========================================="
echo ""

# Step 1: Clean previous environment if requested
if [[ "$1" == "--clean" ]] || [[ "$1" == "-c" ]]; then
    log_info "Cleaning previous environment..."
    rm -rf "$PROJECT_ROOT/$VENV_DIR"
    rm -rf "$PROJECT_ROOT/test-output"
    rm -rf "$PROJECT_ROOT/.pytest_cache"
    rm -rf "$PROJECT_ROOT/__pycache__"
    rm -rf "$PROJECT_ROOT/build"
    rm -rf "$PROJECT_ROOT/DerivedData"
    log_success "Clean complete"
fi

# Step 2: Check Python availability
log_info "Checking Python installation..."
PYTHON_CMD=""
if command -v python3.13 &> /dev/null; then
    PYTHON_CMD="python3.13"
elif command -v python3.12 &> /dev/null; then
    PYTHON_CMD="python3.12"
elif command -v python3.11 &> /dev/null; then
    PYTHON_CMD="python3.11"
elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
else
    log_error "Python 3 is not installed. Please install Python 3.11 or higher."
    exit 1
fi

PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
log_success "Found Python: $PYTHON_VERSION ($PYTHON_CMD)"

# Step 3: Create virtual environment
if [ ! -d "$PROJECT_ROOT/$VENV_DIR" ]; then
    log_info "Creating virtual environment in $VENV_DIR..."
    $PYTHON_CMD -m venv "$PROJECT_ROOT/$VENV_DIR"
    log_success "Virtual environment created"
else
    log_info "Virtual environment already exists"
fi

# Step 4: Activate virtual environment
log_info "Activating virtual environment..."
source "$PROJECT_ROOT/$VENV_DIR/bin/activate"

# Verify activation
if [[ "$VIRTUAL_ENV" != "" ]]; then
    log_success "Virtual environment activated: $VIRTUAL_ENV"
else
    log_error "Failed to activate virtual environment"
    exit 1
fi

# Step 5: Upgrade pip and install base tools
log_info "Upgrading pip and installing base tools..."
pip install --quiet --upgrade pip setuptools wheel

# Step 6: Create requirements file if it doesn't exist
if [ ! -f "$PROJECT_ROOT/requirements-test.txt" ]; then
    log_info "Creating requirements-test.txt..."
    cat > "$PROJECT_ROOT/requirements-test.txt" << 'EOF'
# Testing Requirements for Nestory
# Python environment for test automation and tooling

# Core testing
pytest>=7.4.0
pytest-xdist>=3.3.0  # Parallel test execution
pytest-timeout>=2.1.0
pytest-html>=3.2.0
pytest-json-report>=1.5.0

# Screenshot and image processing
Pillow>=10.0.0  # Image manipulation
imagehash>=4.3.0  # Image comparison
opencv-python>=4.8.0  # Advanced image processing

# Automation utilities
requests>=2.31.0
pyyaml>=6.0
jinja2>=3.1.0  # Template rendering
python-dotenv>=1.0.0  # Environment management

# Code quality
black>=23.0.0  # Code formatting
pylint>=2.17.0
mypy>=1.5.0

# Utilities
click>=8.1.0  # CLI creation
colorama>=0.4.6  # Colored output
tabulate>=0.9.0  # Table formatting
tqdm>=4.66.0  # Progress bars

# iOS specific tools
pyobjc-core>=9.2  # macOS/iOS integration
pyobjc-framework-Cocoa>=9.2
EOF
    log_success "Created requirements-test.txt"
fi

# Step 7: Install Python dependencies
log_info "Installing Python dependencies..."
pip install --quiet -r "$PROJECT_ROOT/requirements-test.txt"
log_success "Python dependencies installed"

# Step 8: Create test utilities module
log_info "Creating test utilities..."
mkdir -p "$PROJECT_ROOT/test_utils"

cat > "$PROJECT_ROOT/test_utils/__init__.py" << 'EOF'
"""Test utilities for Nestory UI testing."""
from .screenshot_manager import ScreenshotManager
from .test_runner import TestRunner
from .report_generator import ReportGenerator

__all__ = ['ScreenshotManager', 'TestRunner', 'ReportGenerator']
EOF

cat > "$PROJECT_ROOT/test_utils/screenshot_manager.py" << 'EOF'
"""Screenshot management utilities."""
import os
import hashlib
import shutil
from pathlib import Path
from typing import List, Dict, Optional
from PIL import Image
import imagehash

class ScreenshotManager:
    """Manage screenshot capture, comparison, and deduplication."""
    
    def __init__(self, output_dir: str = "./test-output/screenshots"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def find_duplicates(self) -> Dict[str, List[Path]]:
        """Find duplicate screenshots using perceptual hashing."""
        duplicates = {}
        hashes = {}
        
        for img_path in self.output_dir.glob("**/*.png"):
            img = Image.open(img_path)
            img_hash = str(imagehash.average_hash(img))
            
            if img_hash in hashes:
                if img_hash not in duplicates:
                    duplicates[img_hash] = [hashes[img_hash]]
                duplicates[img_hash].append(img_path)
            else:
                hashes[img_hash] = img_path
        
        return duplicates
    
    def remove_duplicates(self, keep_first: bool = True) -> int:
        """Remove duplicate screenshots."""
        duplicates = self.find_duplicates()
        removed_count = 0
        
        for hash_value, paths in duplicates.items():
            paths_to_remove = paths[1:] if keep_first else paths[:-1]
            for path in paths_to_remove:
                path.unlink()
                removed_count += 1
                print(f"  Removed duplicate: {path.name}")
        
        return removed_count
    
    def compare_with_baseline(self, baseline_dir: str) -> Dict[str, str]:
        """Compare current screenshots with baseline."""
        baseline = Path(baseline_dir)
        differences = {}
        
        for current in self.output_dir.glob("*.png"):
            baseline_img = baseline / current.name
            if baseline_img.exists():
                current_hash = imagehash.average_hash(Image.open(current))
                baseline_hash = imagehash.average_hash(Image.open(baseline_img))
                
                if current_hash != baseline_hash:
                    differences[current.name] = f"Hash diff: {current_hash - baseline_hash}"
            else:
                differences[current.name] = "New screenshot (no baseline)"
        
        return differences
    
    def generate_html_report(self, title: str = "Screenshot Report") -> Path:
        """Generate an HTML report of all screenshots."""
        html_path = self.output_dir / "report.html"
        
        screenshots = list(self.output_dir.glob("*.png"))
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>{title}</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }}
        h1 {{ color: #333; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }}
        .screenshot {{ border: 1px solid #ddd; border-radius: 8px; overflow: hidden; }}
        .screenshot img {{ width: 100%; display: block; }}
        .screenshot .caption {{ padding: 10px; background: #fafafa; }}
    </style>
</head>
<body>
    <h1>📸 {title}</h1>
    <p>Total screenshots: {len(screenshots)}</p>
    <div class="grid">
"""
        
        for img in screenshots:
            rel_path = img.relative_to(self.output_dir)
            html_content += f"""
        <div class="screenshot">
            <img src="{rel_path}" />
            <div class="caption">{img.name}</div>
        </div>
"""
        
        html_content += """
    </div>
</body>
</html>
"""
        
        html_path.write_text(html_content)
        return html_path
EOF

cat > "$PROJECT_ROOT/test_utils/test_runner.py" << 'EOF'
"""Test runner with enhanced capabilities."""
import subprocess
import json
from pathlib import Path
from typing import Optional, List, Dict

class TestRunner:
    """Run iOS UI tests with screenshot capture."""
    
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.scheme = "Nestory-Dev"
        self.device = "iPhone 16 Pro Max"
    
    def run_screenshot_tests(self, 
                            test_name: Optional[str] = None,
                            output_dir: str = "./test-output") -> Dict:
        """Run UI tests that capture screenshots."""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        cmd = [
            "xcodebuild", "test",
            "-project", "Nestory.xcodeproj",
            "-scheme", self.scheme,
            "-destination", f"platform=iOS Simulator,name={self.device}",
            "-resultBundlePath", str(output_path / "results.xcresult")
        ]
        
        if test_name:
            cmd.extend(["-only-testing", test_name])
        
        print(f"Running: {' '.join(cmd)}")
        
        result = subprocess.run(cmd, 
                              capture_output=True, 
                              text=True,
                              cwd=self.project_root)
        
        return {
            "success": result.returncode == 0,
            "output": result.stdout,
            "errors": result.stderr,
            "result_bundle": str(output_path / "results.xcresult")
        }
    
    def extract_screenshots(self, result_bundle: str, output_dir: str) -> List[Path]:
        """Extract screenshots from test result bundle."""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        # Extract attachments using xcresulttool
        cmd = [
            "xcrun", "xcresulttool", "get",
            "--path", result_bundle,
            "--output-path", str(output_path),
            "--legacy"
        ]
        
        subprocess.run(cmd, check=True)
        
        # Find all PNG files
        screenshots = list(output_path.glob("**/*.png"))
        return screenshots
EOF

cat > "$PROJECT_ROOT/test_utils/report_generator.py" << 'EOF'
"""Generate test reports."""
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List

class ReportGenerator:
    """Generate various test reports."""
    
    def __init__(self, output_dir: str = "./test-output"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def generate_summary(self, test_results: Dict) -> Path:
        """Generate a JSON summary of test results."""
        summary = {
            "timestamp": datetime.now().isoformat(),
            "results": test_results,
            "screenshots": self._count_screenshots(),
            "duplicates": self._count_duplicates()
        }
        
        summary_path = self.output_dir / "summary.json"
        summary_path.write_text(json.dumps(summary, indent=2))
        
        return summary_path
    
    def _count_screenshots(self) -> int:
        """Count total screenshots."""
        screenshot_dir = self.output_dir / "screenshots"
        if screenshot_dir.exists():
            return len(list(screenshot_dir.glob("**/*.png")))
        return 0
    
    def _count_duplicates(self) -> int:
        """Count duplicate screenshots."""
        from .screenshot_manager import ScreenshotManager
        manager = ScreenshotManager(str(self.output_dir / "screenshots"))
        duplicates = manager.find_duplicates()
        return sum(len(paths) - 1 for paths in duplicates.values())
EOF

log_success "Test utilities created"

# Step 9: Create output directories
log_info "Creating output directories..."
mkdir -p "$SCREENSHOTS_DIR"
mkdir -p "$LOGS_DIR"
log_success "Output directories created"

# Step 10: Create activation script
cat > "$PROJECT_ROOT/activate-env.sh" << EOF
#!/bin/bash
# Quick activation script
source "$PROJECT_ROOT/$VENV_DIR/bin/activate"
export PROJECT_ROOT="$PROJECT_ROOT"
export SCREENSHOTS_DIR="$SCREENSHOTS_DIR"
echo "Environment activated. Python: \$(which python)"
echo "Project root: \$PROJECT_ROOT"
EOF
chmod +x "$PROJECT_ROOT/activate-env.sh"

# Step 11: Create test runner script
cat > "$PROJECT_ROOT/run-tests.py" << 'EOF'
#!/usr/bin/env python3
"""Main test runner script."""
import click
import sys
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent))

from test_utils import ScreenshotManager, TestRunner, ReportGenerator

@click.group()
def cli():
    """Nestory test automation CLI."""
    pass

@cli.command()
@click.option('--clean-duplicates', is_flag=True, help='Remove duplicate screenshots')
@click.option('--generate-report', is_flag=True, help='Generate HTML report')
def screenshots(clean_duplicates, generate_report):
    """Capture and manage screenshots."""
    runner = TestRunner()
    manager = ScreenshotManager()
    
    click.echo("🚀 Running screenshot tests...")
    result = runner.run_screenshot_tests(
        test_name="NestoryUITests/ComprehensiveScreenshotTest"
    )
    
    if result["success"]:
        click.echo("✅ Tests passed")
        
        # Extract screenshots
        screenshots = runner.extract_screenshots(
            result["result_bundle"],
            str(manager.output_dir)
        )
        click.echo(f"📸 Extracted {len(screenshots)} screenshots")
        
        if clean_duplicates:
            removed = manager.remove_duplicates()
            click.echo(f"🗑 Removed {removed} duplicates")
        
        if generate_report:
            report_path = manager.generate_html_report()
            click.echo(f"📊 Report generated: {report_path}")
    else:
        click.echo("❌ Tests failed", err=True)
        click.echo(result["errors"], err=True)
        sys.exit(1)

@cli.command()
def clean():
    """Clean all test outputs."""
    import shutil
    output_dir = Path("./test-output")
    if output_dir.exists():
        shutil.rmtree(output_dir)
        click.echo("✅ Cleaned test outputs")
    else:
        click.echo("Already clean")

@cli.command()
@click.argument('baseline_dir')
def compare(baseline_dir):
    """Compare screenshots with baseline."""
    manager = ScreenshotManager()
    differences = manager.compare_with_baseline(baseline_dir)
    
    if differences:
        click.echo(f"⚠️ Found {len(differences)} differences:")
        for name, diff in differences.items():
            click.echo(f"  - {name}: {diff}")
    else:
        click.echo("✅ All screenshots match baseline")

if __name__ == '__main__':
    cli()
EOF
chmod +x "$PROJECT_ROOT/run-tests.py"

# Step 12: Summary
echo ""
echo "========================================="
echo -e "${GREEN}   Environment Setup Complete!${NC}"
echo "========================================="
echo ""
echo "Virtual environment: $VENV_DIR"
echo "Python version: $PYTHON_VERSION"
echo "Project root: $PROJECT_ROOT"
echo ""
echo "Available commands:"
echo "  source activate-env.sh       - Activate environment"
echo "  python run-tests.py --help   - Show test commands"
echo "  python run-tests.py screenshots - Run screenshot tests"
echo "  python run-tests.py clean    - Clean outputs"
echo ""
echo "Quick start:"
echo "  1. source activate-env.sh"
echo "  2. python run-tests.py screenshots --clean-duplicates --generate-report"
echo ""

# Optional: Activate environment for current session
echo -e "${BLUE}Environment is now active in this session${NC}"
echo "Python: $(which python)"
echo "Pip: $(which pip)"