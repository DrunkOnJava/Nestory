#!/usr/bin/env python3
"""
Check import rule violations based on Nestory's 6-layer architecture.
Returns exit code 1 if violations are found.
"""

import os
import re
import json
import sys
from pathlib import Path

# Define layer hierarchy and allowed imports
LAYER_RULES = {
    "App-Main": ["Features", "UI", "Services", "Infrastructure", "Foundation", "ComposableArchitecture"],
    "Features": ["UI", "Services", "Foundation", "ComposableArchitecture"],
    "UI": ["Foundation"],
    "Services": ["Infrastructure", "Foundation"],
    "Infrastructure": ["Foundation"],
    "Foundation": []  # Can only import Swift stdlib
}

# Map file paths to layers
def get_layer(file_path):
    """Determine which layer a file belongs to."""
    path_str = str(file_path)
    
    if "App-Main" in path_str or "App_Main" in path_str:
        return "App-Main"
    elif "Features" in path_str:
        return "Features"
    elif "UI" in path_str:
        return "UI"
    elif "Services" in path_str:
        return "Services"
    elif "Infrastructure" in path_str:
        return "Infrastructure"
    elif "Foundation" in path_str:
        return "Foundation"
    else:
        # Try to determine by parent directory
        parts = Path(path_str).parts
        for part in parts:
            if part in LAYER_RULES:
                return part
    return None

def extract_imports(file_path):
    """Extract all import statements from a Swift file."""
    imports = []
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            # Match import statements
            import_pattern = r'^import\s+(\w+)'
            matches = re.findall(import_pattern, content, re.MULTILINE)
            imports.extend(matches)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    return imports

def check_import_violations(file_path, imports):
    """Check if imports violate layer rules."""
    violations = []
    file_layer = get_layer(file_path)
    
    if not file_layer:
        return violations
    
    allowed_imports = LAYER_RULES.get(file_layer, [])
    
    for imp in imports:
        # Skip standard Swift imports
        if imp in ["Swift", "SwiftUI", "UIKit", "Foundation", "Combine", "os"]:
            continue
            
        # Check if import corresponds to a layer
        import_layer = None
        for layer in LAYER_RULES.keys():
            if layer.replace("-", "") in imp or imp in ["ComposableArchitecture", "TCA"]:
                if imp in ["ComposableArchitecture", "TCA"]:
                    import_layer = "ComposableArchitecture"
                else:
                    import_layer = layer
                break
        
        if import_layer and import_layer not in allowed_imports:
            violations.append({
                "file": str(file_path),
                "layer": file_layer,
                "illegal_import": imp,
                "import_layer": import_layer,
                "allowed": allowed_imports
            })
    
    return violations

def main():
    """Main function to check all Swift files for import violations."""
    project_root = Path.cwd()
    swift_files = list(project_root.glob("**/*.swift"))
    
    # Filter out build directories and dependencies
    swift_files = [
        f for f in swift_files 
        if not any(skip in str(f) for skip in [
            "build", "DerivedData", ".build", "Pods", 
            "Carthage", ".git", "xcodeproj", "playground"
        ])
    ]
    
    all_violations = []
    files_checked = 0
    
    print(f"🔍 Checking {len(swift_files)} Swift files for import violations...")
    
    for file_path in swift_files:
        imports = extract_imports(file_path)
        violations = check_import_violations(file_path, imports)
        
        if violations:
            all_violations.extend(violations)
        
        files_checked += 1
        if files_checked % 50 == 0:
            print(f"  Checked {files_checked} files...")
    
    # Report results
    if all_violations:
        print(f"\n❌ Found {len(all_violations)} import violations:\n")
        
        for violation in all_violations:
            print(f"  File: {violation['file']}")
            print(f"    Layer: {violation['layer']}")
            print(f"    Illegal import: {violation['illegal_import']}")
            print(f"    Allowed imports: {', '.join(violation['allowed']) or 'None (Foundation only)'}")
            print()
        
        # Generate JSON report
        report_path = project_root / "project-visualization" / "outputs" / "import-violations.json"
        report_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(report_path, 'w') as f:
            json.dump(all_violations, f, indent=2)
        
        print(f"📄 Detailed report saved to: {report_path}")
        return 1  # Exit with error
    else:
        print(f"\n✅ No import violations found! All {files_checked} files comply with architecture rules.")
        return 0

if __name__ == "__main__":
    sys.exit(main())