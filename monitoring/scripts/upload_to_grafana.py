#!/usr/bin/env python3
"""
Upload dashboards to Grafana via API
Handles both comprehensive and production dashboard templates
"""
import json
import requests
import os
import sys
from pathlib import Path
from typing import Dict, Any, Optional

class GrafanaUploader:
    """Handles dashboard uploads to Grafana via API"""
    
    def __init__(self, grafana_url: str, api_token: str):
        self.grafana_url = grafana_url.rstrip('/')
        self.api_token = api_token
        self.headers = {
            'Authorization': f'Bearer {api_token}',
            'Content-Type': 'application/json'
        }
    
    def upload_dashboard(self, dashboard_path: str, folder_id: int = 0, overwrite: bool = True) -> Dict[str, Any]:
        """Upload a dashboard JSON file to Grafana"""
        dashboard_file = Path(dashboard_path)
        
        if not dashboard_file.exists():
            raise FileNotFoundError(f"Dashboard file not found: {dashboard_path}")
        
        with open(dashboard_file, 'r') as f:
            dashboard_json = json.load(f)
        
        # Prepare the upload payload
        payload = {
            "dashboard": dashboard_json,
            "folderId": folder_id,
            "overwrite": overwrite,
            "message": f"Uploaded via automation - {dashboard_file.name}"
        }
        
        # Upload to Grafana
        upload_url = f"{self.grafana_url}/api/dashboards/db"
        
        try:
            response = requests.post(upload_url, headers=self.headers, json=payload, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            return {
                "success": True,
                "dashboard_uid": result.get("uid", "unknown"),
                "dashboard_url": result.get("url", "unknown"),
                "status": result.get("status", "unknown"),
                "version": result.get("version", 1)
            }
            
        except requests.exceptions.RequestException as e:
            return {
                "success": False,
                "error": str(e),
                "status_code": getattr(e.response, 'status_code', None)
            }
    
    def list_dashboards(self) -> Dict[str, Any]:
        """List all dashboards in Grafana"""
        list_url = f"{self.grafana_url}/api/search?type=dash-db"
        
        try:
            response = requests.get(list_url, headers=self.headers, timeout=30)
            response.raise_for_status()
            return {"success": True, "dashboards": response.json()}
        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}
    
    def health_check(self) -> Dict[str, Any]:
        """Check Grafana API connectivity"""
        health_url = f"{self.grafana_url}/api/health"
        
        try:
            response = requests.get(health_url, timeout=10)
            response.raise_for_status()
            return {"success": True, "status": "healthy", "version": response.json().get("version", "unknown")}
        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

def get_grafana_config() -> tuple[str, str]:
    """Get Grafana URL and API token from multiple sources with griffin's authentication"""
    
    # Try to use the comprehensive auth integration
    try:
        from auth_integration import AuthenticationManager
        auth_manager = AuthenticationManager()
        
        # Try to get token using griffin's auth system
        api_token = auth_manager.get_grafana_token("dev")
        
        if api_token:
            # Get URL from config
            from config_manager import get_config_manager
            config_manager = get_config_manager()
            env_config = config_manager.get_environment_config("dev")
            grafana_url = env_config.get('grafana_url', 'http://localhost:3000')
            return grafana_url, api_token
    except ImportError:
        pass  # Fall back to original method
    except Exception as e:
        print(f"⚠️ Auth integration failed: {e}")
    
    # Original authentication methods as fallback
    grafana_url = os.getenv('GRAFANA_URL')
    api_token = os.getenv('GRAFANA_API_TOKEN')
    
    if grafana_url and api_token:
        return grafana_url, api_token
    
    # Try macOS Keychain via security CLI
    if not api_token:
        api_token = get_token_from_keychain()
    
    # Try configuration manager
    try:
        sys.path.insert(0, os.path.dirname(__file__))
        from config_manager import get_config_manager
        
        config_manager = get_config_manager()
        env_config = config_manager.get_environment_config("dev")
        
        if not grafana_url:
            grafana_url = env_config.get('grafana_url', 'http://localhost:3000')
        
        if not api_token:
            api_token = env_config.get('grafana_api_token')
        
        if not api_token:
            print("⚠️ No Grafana API token found")
            print("💡 Use griffin's authentication system:")
            print("   • Setup: python3 scripts/auth_integration.py --interactive")
            print("   • Status: python3 scripts/auth_integration.py --status")
            print("   • Store token: python3 scripts/auth_integration.py --store-grafana 'your-token'")
            print("📋 Alternative methods:")
            print("   • Environment: export GRAFANA_API_TOKEN='your-token'")
            print("   • Keychain: security add-generic-password -s 'grafana-api-token' -a 'griffin' -w 'your-token'")
            return grafana_url, None
            
        return grafana_url, api_token
        
    except Exception as e:
        print(f"⚠️ Failed to load configuration: {e}")
        return grafana_url or 'http://localhost:3000', api_token

def get_token_from_keychain() -> Optional[str]:
    """Get Grafana API token from macOS Keychain using security CLI"""
    try:
        import subprocess
        result = subprocess.run([
            'security', 'find-generic-password', 
            '-s', 'grafana-api-token',
            '-a', 'nestory',
            '-w'  # output password only
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            token = result.stdout.strip()
            if token:
                print("🔑 Using Grafana API token from Keychain")
                return token
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError) as e:
        print(f"⚠️ Keychain access failed: {e}")
    
    return None

def store_token_in_keychain(token: str) -> bool:
    """Store Grafana API token in macOS Keychain"""
    try:
        import subprocess
        result = subprocess.run([
            'security', 'add-generic-password',
            '-s', 'grafana-api-token',
            '-a', 'nestory',
            '-w', token,
            '-U'  # update if exists
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            print("🔑 Grafana API token stored in Keychain")
            return True
        else:
            print(f"❌ Failed to store token in Keychain: {result.stderr}")
            return False
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError) as e:
        print(f"⚠️ Keychain storage failed: {e}")
        return False

def show_grafana_cli_commands():
    """Show equivalent Grafana CLI and curl commands for common operations"""
    print("🔧 Grafana CLI & curl Command Reference")
    print("═" * 60)
    print()
    
    print("📊 Dashboard Operations:")
    print("   • List dashboards:")
    print("     curl -H 'Authorization: Bearer $TOKEN' http://localhost:3000/api/search")
    print("     jq '.[] | {title, uid, url}' <<< \"$(curl -s -H 'Authorization: Bearer $TOKEN' http://localhost:3000/api/search)\"")
    print()
    
    print("   • Upload dashboard:")
    print("     curl -X POST -H 'Authorization: Bearer $TOKEN' -H 'Content-Type: application/json' \\")
    print("          -d @dashboard.json http://localhost:3000/api/dashboards/db")
    print()
    
    print("   • Health check:")
    print("     curl -s http://localhost:3000/api/health | jq")
    print()
    
    print("🔑 Token Management (macOS Keychain):")
    print("   • Store token:")
    print("     security add-generic-password -s 'grafana-api-token' -a 'nestory' -w 'your-token'")
    print()
    
    print("   • Retrieve token:")
    print("     security find-generic-password -s 'grafana-api-token' -a 'nestory' -w")
    print()
    
    print("   • Update token:")
    print("     security add-generic-password -s 'grafana-api-token' -a 'nestory' -w 'new-token' -U")
    print()
    
    print("🏷️ Grafana CLI Plugin Management:")
    print("   • List installed plugins:")
    print("     grafana cli plugins list-remote")
    print()
    
    print("   • Install plugin:")
    print("     grafana cli plugins install grafana-piechart-panel")
    print()

def upload_with_curl(dashboard_path: str, grafana_url: str, api_token: str, folder_id: int = 0) -> Dict[str, Any]:
    """Upload dashboard using curl instead of requests library"""
    import subprocess
    import tempfile
    
    try:
        dashboard_file = Path(dashboard_path)
        if not dashboard_file.exists():
            return {"success": False, "error": f"Dashboard file not found: {dashboard_path}"}
        
        with open(dashboard_file, 'r') as f:
            dashboard_json = json.load(f)
        
        # Prepare upload payload
        payload = {
            "dashboard": dashboard_json,
            "folderId": folder_id,
            "overwrite": True,
            "message": f"Uploaded via curl - {dashboard_file.name}"
        }
        
        # Write payload to temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as temp_file:
            json.dump(payload, temp_file, indent=2)
            temp_path = temp_file.name
        
        try:
            # Execute curl command
            curl_cmd = [
                'curl', '-s', '-X', 'POST',
                '-H', f'Authorization: Bearer {api_token}',
                '-H', 'Content-Type: application/json',
                '-d', f'@{temp_path}',
                f'{grafana_url.rstrip("/")}/api/dashboards/db'
            ]
            
            result = subprocess.run(curl_cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                response_data = json.loads(result.stdout)
                return {
                    "success": True,
                    "dashboard_uid": response_data.get("uid", "unknown"),
                    "dashboard_url": response_data.get("url", "unknown"),
                    "status": response_data.get("status", "unknown"),
                    "version": response_data.get("version", 1),
                    "method": "curl"
                }
            else:
                return {
                    "success": False,
                    "error": result.stderr or result.stdout,
                    "method": "curl"
                }
                
        finally:
            # Clean up temporary file
            os.unlink(temp_path)
            
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, json.JSONDecodeError, FileNotFoundError) as e:
        return {"success": False, "error": str(e), "method": "curl"}

def check_grafana_plugins() -> Dict[str, Any]:
    """Check installed Grafana plugins using Grafana CLI"""
    try:
        import subprocess
        result = subprocess.run([
            'grafana', 'cli', 'plugins', 'list-remote'
        ], capture_output=True, text=True, timeout=15)
        
        if result.returncode == 0:
            return {"success": True, "output": result.stdout}
        else:
            return {"success": False, "error": result.stderr}
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError) as e:
        return {"success": False, "error": str(e)}

def get_macos_system_info() -> Dict[str, Any]:
    """Get macOS system information for monitoring context"""
    try:
        import subprocess
        
        # Get macOS version
        sw_vers = subprocess.run(['sw_vers'], capture_output=True, text=True, timeout=5)
        
        # Get system uptime
        uptime = subprocess.run(['uptime'], capture_output=True, text=True, timeout=5)
        
        # Get network interfaces
        ifconfig = subprocess.run(['ifconfig'], capture_output=True, text=True, timeout=5)
        
        return {
            "success": True,
            "macos_version": sw_vers.stdout if sw_vers.returncode == 0 else "unknown",
            "uptime": uptime.stdout.strip() if uptime.returncode == 0 else "unknown",
            "network_interfaces": len([line for line in ifconfig.stdout.split('\n') if line.startswith('\t')]) if ifconfig.returncode == 0 else 0
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

def main():
    """Main upload function"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Upload Grafana dashboards")
    parser.add_argument("--dashboard", type=str, help="Dashboard JSON file to upload")
    parser.add_argument("--all", action="store_true", help="Upload all generated dashboards")
    parser.add_argument("--list", action="store_true", help="List existing dashboards")
    parser.add_argument("--health", action="store_true", help="Check Grafana connectivity")
    parser.add_argument("--folder-id", type=int, default=0, help="Grafana folder ID (default: 0 = General)")
    parser.add_argument("--grafana-url", type=str, help="Grafana URL (overrides config)")
    parser.add_argument("--api-token", type=str, help="Grafana API token (overrides config)")
    parser.add_argument("--store-token", type=str, help="Store API token in Keychain")
    parser.add_argument("--use-curl", action="store_true", help="Use curl instead of requests library")
    parser.add_argument("--grafana-cli", action="store_true", help="Show Grafana CLI equivalent commands")
    
    args = parser.parse_args()
    
    # Handle token storage
    if args.store_token:
        if store_token_in_keychain(args.store_token):
            print("✅ Token stored successfully")
        else:
            print("❌ Failed to store token")
        return
    
    # Show Grafana CLI equivalent commands
    if args.grafana_cli:
        show_grafana_cli_commands()
        return
    
    # Get Grafana configuration
    if args.grafana_url and args.api_token:
        grafana_url, api_token = args.grafana_url, args.api_token
    else:
        grafana_url, api_token = get_grafana_config()
    
    if not api_token and not args.health:
        print("❌ No Grafana API token available")
        print("💡 Set GRAFANA_API_TOKEN environment variable or use --api-token flag")
        sys.exit(1)
    
    uploader = GrafanaUploader(grafana_url, api_token or "dummy")
    
    print(f"🔗 Grafana URL: {grafana_url}")
    
    # Health check
    if args.health:
        print("🏥 Checking Grafana connectivity...")
        health = uploader.health_check()
        if health["success"]:
            print(f"✅ Grafana is healthy (version: {health.get('version', 'unknown')})")
        else:
            print(f"❌ Grafana health check failed: {health['error']}")
        
        # Show additional system information
        print("\n🖥️ macOS System Information:")
        sys_info = get_macos_system_info()
        if sys_info["success"]:
            print(f"   System: {sys_info['macos_version'].strip()}")
            print(f"   Uptime: {sys_info['uptime']}")
        
        # Check Grafana plugins
        print("\n🔌 Grafana Plugin Status:")
        plugin_info = check_grafana_plugins()
        if plugin_info["success"]:
            print("✅ Grafana CLI is functional")
        else:
            print(f"⚠️ Grafana CLI issue: {plugin_info['error']}")
        
        return
    
    # List dashboards
    if args.list:
        print("📋 Listing existing dashboards...")
        result = uploader.list_dashboards()
        if result["success"]:
            dashboards = result["dashboards"]
            print(f"✅ Found {len(dashboards)} dashboards:")
            for dash in dashboards:
                print(f"   • {dash['title']} (UID: {dash['uid']})")
        else:
            print(f"❌ Failed to list dashboards: {result['error']}")
        return
    
    # Upload dashboards
    dashboards_dir = Path(__file__).parent.parent / "dashboards"
    
    if args.all:
        # Upload all generated dashboards
        dashboard_files = list(dashboards_dir.glob("*.json"))
        # Filter to only our generated templates (not legacy files)
        template_files = [f for f in dashboard_files if f.name in ['comprehensive-dev.json', 'production-prod.json']]
        
        if not template_files:
            print("⚠️ No template dashboards found to upload")
            print("💡 Generate dashboards first: python3 scripts/dashboard_generator.py")
            return
        
        print(f"📤 Uploading {len(template_files)} template dashboards...")
        for dashboard_file in template_files:
            print(f"\n📊 Uploading: {dashboard_file.name}")
            
            if args.use_curl:
                result = upload_with_curl(str(dashboard_file), grafana_url, api_token, folder_id=args.folder_id)
            else:
                result = uploader.upload_dashboard(str(dashboard_file), folder_id=args.folder_id)
            
            if result["success"]:
                method = result.get('method', 'requests')
                print(f"✅ Success! Dashboard UID: {result['dashboard_uid']} (via {method})")
                print(f"🔗 URL: {grafana_url}{result.get('dashboard_url', '')}")
            else:
                print(f"❌ Failed: {result['error']}")
                if result.get('status_code'):
                    print(f"   HTTP Status: {result['status_code']}")
    
    elif args.dashboard:
        # Upload specific dashboard
        dashboard_path = Path(args.dashboard)
        if not dashboard_path.is_absolute():
            dashboard_path = dashboards_dir / dashboard_path
        
        print(f"📤 Uploading dashboard: {dashboard_path.name}")
        result = uploader.upload_dashboard(str(dashboard_path), folder_id=args.folder_id)
        
        if result["success"]:
            print(f"✅ Success! Dashboard UID: {result['dashboard_uid']}")
            print(f"🔗 URL: {grafana_url}{result.get('dashboard_url', '')}")
        else:
            print(f"❌ Failed: {result['error']}")
            if result.get('status_code'):
                print(f"   HTTP Status: {result['status_code']}")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()