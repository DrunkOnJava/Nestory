#!/usr/bin/env python3
"""
extract-screenshots.py
Extract and index screenshots from xcresult bundles
"""

import os
import sys
import json
import subprocess
import hashlib
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional

class ScreenshotExtractor:
    """Extract screenshots from test result bundles."""
    
    def __init__(self, result_bundle: str, output_dir: str = "./screenshots"):
        self.result_bundle = Path(result_bundle)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
    def extract(self) -> List[Path]:
        """Extract all screenshots from result bundle."""
        if not self.result_bundle.exists():
            print(f"❌ Result bundle not found: {self.result_bundle}")
            return []
            
        print(f"📦 Extracting from: {self.result_bundle}")
        
        # Get attachments using xcresulttool
        cmd = [
            "xcrun", "xcresulttool", "get",
            "--path", str(self.result_bundle),
            "--output-path", str(self.output_dir),
            "--legacy"
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            print(f"❌ Extraction failed: {e.stderr.decode()}")
            return []
        
        # Find all PNG files
        screenshots = list(self.output_dir.glob("**/*.png"))
        print(f"📸 Found {len(screenshots)} screenshots")
        
        return screenshots
    
    def organize(self, screenshots: List[Path]) -> Dict[str, Path]:
        """Organize screenshots with meaningful names."""
        organized = {}
        
        for screenshot in screenshots:
            # Extract metadata from filename or path
            parts = screenshot.stem.split("_")
            
            # Generate organized name
            if len(parts) >= 2:
                screen_name = parts[0]
                timestamp = parts[-1] if parts[-1].isdigit() else ""
            else:
                screen_name = screenshot.stem
                timestamp = ""
            
            # Create organized path
            new_name = f"{screen_name}.png"
            new_path = self.output_dir / "organized" / new_name
            new_path.parent.mkdir(exist_ok=True)
            
            # Copy file
            import shutil
            shutil.copy2(screenshot, new_path)
            
            organized[screen_name] = new_path
            
        print(f"📁 Organized {len(organized)} screenshots")
        return organized
    
    def remove_duplicates(self, screenshots: List[Path]) -> int:
        """Remove duplicate screenshots based on content hash."""
        hashes = {}
        removed = 0
        
        for screenshot in screenshots:
            with open(screenshot, 'rb') as f:
                file_hash = hashlib.sha256(f.read()).hexdigest()
            
            if file_hash in hashes:
                # Duplicate found
                screenshot.unlink()
                removed += 1
                print(f"  🗑 Removed duplicate: {screenshot.name}")
            else:
                hashes[file_hash] = screenshot
        
        if removed > 0:
            print(f"🧹 Removed {removed} duplicate screenshots")
        
        return removed
    
    def generate_index(self, screenshots: Dict[str, Path]) -> Path:
        """Generate HTML index of screenshots."""
        html_path = self.output_dir / "index.html"
        
        html = """<!DOCTYPE html>
<html>
<head>
    <title>Nestory Screenshot Catalog</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f7;
        }
        h1 { 
            color: #1d1d1f;
            font-size: 48px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #86868b;
            font-size: 21px;
            margin-bottom: 40px;
        }
        .stats {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        .screenshot {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .screenshot:hover {
            transform: scale(1.02);
        }
        .screenshot img {
            width: 100%;
            display: block;
            border-bottom: 1px solid #e5e5e7;
        }
        .screenshot .info {
            padding: 15px;
        }
        .screenshot .name {
            font-weight: 600;
            font-size: 17px;
            color: #1d1d1f;
            margin-bottom: 5px;
        }
        .screenshot .path {
            font-size: 13px;
            color: #86868b;
            font-family: 'SF Mono', monospace;
        }
        .timestamp {
            text-align: center;
            color: #86868b;
            margin-top: 40px;
            font-size: 13px;
        }
    </style>
</head>
<body>
    <h1>📸 Nestory Screenshot Catalog</h1>
    <div class="subtitle">Deterministic UI Screenshot Documentation</div>
    
    <div class="stats">
        <strong>Total Screenshots:</strong> {count}<br>
        <strong>Generated:</strong> {timestamp}<br>
        <strong>Result Bundle:</strong> {bundle}
    </div>
    
    <div class="grid">
""".format(
            count=len(screenshots),
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            bundle=self.result_bundle.name
        )
        
        for name, path in sorted(screenshots.items()):
            relative_path = path.relative_to(self.output_dir)
            html += f"""
        <div class="screenshot">
            <img src="{relative_path}" alt="{name}">
            <div class="info">
                <div class="name">{name.replace('_', ' ').title()}</div>
                <div class="path">{relative_path}</div>
            </div>
        </div>
"""
        
        html += """
    </div>
    
    <div class="timestamp">
        Generated by extract-screenshots.py
    </div>
</body>
</html>
"""
        
        html_path.write_text(html)
        print(f"📊 Generated index: {html_path}")
        
        return html_path
    
    def generate_json_manifest(self, screenshots: Dict[str, Path]) -> Path:
        """Generate JSON manifest for programmatic access."""
        manifest_path = self.output_dir / "manifest.json"
        
        manifest = {
            "version": "1.0",
            "generated": datetime.now().isoformat(),
            "source": str(self.result_bundle),
            "count": len(screenshots),
            "screenshots": {}
        }
        
        for name, path in screenshots.items():
            # Get file info
            stat = path.stat()
            with open(path, 'rb') as f:
                file_hash = hashlib.sha256(f.read()).hexdigest()
            
            manifest["screenshots"][name] = {
                "path": str(path.relative_to(self.output_dir)),
                "size": stat.st_size,
                "hash": file_hash,
                "modified": datetime.fromtimestamp(stat.st_mtime).isoformat()
            }
        
        with open(manifest_path, 'w') as f:
            json.dump(manifest, f, indent=2)
        
        print(f"📋 Generated manifest: {manifest_path}")
        
        return manifest_path

def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: extract-screenshots.py <xcresult_bundle> [output_dir]")
        sys.exit(1)
    
    result_bundle = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "./screenshots"
    
    print(f"🚀 Screenshot Extraction Pipeline")
    print(f"================================")
    
    # Create extractor
    extractor = ScreenshotExtractor(result_bundle, output_dir)
    
    # Extract screenshots
    screenshots = extractor.extract()
    if not screenshots:
        print("❌ No screenshots found")
        sys.exit(1)
    
    # Remove duplicates
    extractor.remove_duplicates(screenshots)
    
    # Organize screenshots
    organized = extractor.organize(screenshots)
    
    # Generate index
    index_path = extractor.generate_index(organized)
    
    # Generate manifest
    manifest_path = extractor.generate_json_manifest(organized)
    
    print(f"\n✅ Extraction complete!")
    print(f"   Screenshots: {len(organized)}")
    print(f"   Output: {output_dir}")
    print(f"   Index: {index_path}")
    print(f"   Manifest: {manifest_path}")
    
    # Open index in browser
    subprocess.run(["open", str(index_path)])

if __name__ == "__main__":
    main()