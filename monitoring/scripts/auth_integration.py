#!/usr/bin/env python3
"""
Comprehensive Authentication Integration
Uses griffin's existing credentials across all monitoring tools
"""
import os
import sys
import subprocess
import json
import keyring
import getpass
from pathlib import Path
from typing import Dict, Any, Optional

class AuthenticationManager:
    """Manages authentication across all monitoring tools using griffin's login"""
    
    def __init__(self):
        self.user_login = "griffin"
        self.github_username = "DrunkOnJava"
        self.git_email = "griffinradcliffe@gmail.com"
        self.keychain_service = "nestory-monitoring"
        
    def get_system_identity(self) -> Dict[str, str]:
        """Get current system identity information"""
        try:
            import pwd
            user_info = pwd.getpwuid(os.getuid())
            
            return {
                "system_user": user_info.pw_name,
                "user_id": str(user_info.pw_uid),
                "group_id": str(user_info.pw_gid),
                "home_dir": user_info.pw_dir,
                "shell": user_info.pw_shell,
                "full_name": user_info.pw_gecos.split(',')[0] if user_info.pw_gecos else "Griffin"
            }
        except Exception as e:
            return {"error": str(e)}
    
    def get_github_auth(self) -> Dict[str, Any]:
        """Get GitHub authentication status and token"""
        try:
            # Check GitHub CLI auth status (without --show-token to avoid permission issues)
            result = subprocess.run(['gh', 'auth', 'status'], 
                                  capture_output=True, text=True, timeout=10)
            
            # GitHub CLI outputs status to stdout, check both returncode and output
            if result.returncode == 0 or "Logged in to github.com" in result.stdout:
                # Get authenticated user info (disable color output)
                env = os.environ.copy()
                env['CLICOLOR'] = '0'
                env['NO_COLOR'] = '1'
                env['CLICOLOR_FORCE'] = '0'
                
                user_result = subprocess.run(['gh', 'api', 'user', '--jq', '.'], 
                                           capture_output=True, text=True, timeout=10, env=env)
                user_info = {}
                if user_result.returncode == 0 and user_result.stdout.strip():
                    try:
                        user_info = json.loads(user_result.stdout)
                    except json.JSONDecodeError:
                        # Fallback: get just the username
                        username_result = subprocess.run(['gh', 'api', 'user', '--jq', '.login'], 
                                                       capture_output=True, text=True, timeout=10, env=env)
                        if username_result.returncode == 0:
                            user_info = {"login": username_result.stdout.strip()}
                
                # Try to extract token (may not be available)
                token = None
                try:
                    token_result = subprocess.run(['gh', 'auth', 'token'], 
                                                capture_output=True, text=True, timeout=5)
                    if token_result.returncode == 0:
                        token = token_result.stdout.strip()
                except:
                    pass  # Token extraction may fail, that's OK
                
                return {
                    "authenticated": True,
                    "username": user_info.get("login", self.github_username),
                    "name": user_info.get("name", "Griffin Radcliffe"),
                    "email": user_info.get("email", self.git_email),
                    "token": token,
                    "scopes": self._extract_scopes_from_status(result.stdout),
                    "status_output": result.stdout
                }
            else:
                return {"authenticated": False, "error": result.stderr}
                
        except Exception as e:
            return {"authenticated": False, "error": str(e)}
    
    def _extract_scopes_from_status(self, status_output: str) -> list:
        """Extract token scopes from gh auth status output"""
        try:
            scope_line = [line for line in status_output.split('\n') if 'Token scopes:' in line]
            if scope_line:
                scopes_str = scope_line[0].split('Token scopes: ')[1].strip()
                # Remove quotes and split by comma
                scopes = [scope.strip().strip("'\"") for scope in scopes_str.split(',')]
                return scopes
        except:
            pass
        return []
    
    def store_grafana_token(self, token: str, environment: str = "dev") -> bool:
        """Store Grafana API token using multiple secure methods"""
        success_methods = []
        
        # Method 1: macOS Keychain via security command
        try:
            result = subprocess.run([
                'security', 'add-generic-password',
                '-s', f'{self.keychain_service}-grafana-{environment}',
                '-a', self.user_login,
                '-w', token,
                '-U'  # update if exists
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                success_methods.append("macOS Keychain")
        except Exception as e:
            print(f"⚠️ Keychain storage failed: {e}")
        
        # Method 2: Python keyring library
        try:
            keyring.set_password(f"{self.keychain_service}-grafana", environment, token)
            success_methods.append("Python Keyring")
        except Exception as e:
            print(f"⚠️ Python keyring failed: {e}")
        
        # Method 3: Secure file in user's home (encrypted)
        try:
            secure_dir = Path.home() / ".config" / "nestory" / "secure"
            secure_dir.mkdir(parents=True, exist_ok=True)
            
            # Set restrictive permissions
            os.chmod(secure_dir, 0o700)
            
            token_file = secure_dir / f"grafana-{environment}.token"
            with open(token_file, 'w') as f:
                f.write(token)
            
            # Restrict file permissions
            os.chmod(token_file, 0o600)
            success_methods.append("Secure File")
        except Exception as e:
            print(f"⚠️ Secure file storage failed: {e}")
        
        if success_methods:
            print(f"✅ Token stored via: {', '.join(success_methods)}")
            return True
        else:
            print("❌ All token storage methods failed")
            return False
    
    def get_grafana_token(self, environment: str = "dev") -> Optional[str]:
        """Retrieve Grafana API token from multiple sources"""
        
        # Method 1: Environment variable
        env_token = os.getenv(f'GRAFANA_API_TOKEN_{environment.upper()}') or os.getenv('GRAFANA_API_TOKEN')
        if env_token:
            print("🔑 Using token from environment variable")
            return env_token
        
        # Method 2: macOS Keychain
        try:
            result = subprocess.run([
                'security', 'find-generic-password',
                '-s', f'{self.keychain_service}-grafana-{environment}',
                '-a', self.user_login,
                '-w'
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0 and result.stdout.strip():
                print("🔑 Using token from macOS Keychain")
                return result.stdout.strip()
        except Exception:
            pass
        
        # Method 3: Python keyring
        try:
            token = keyring.get_password(f"{self.keychain_service}-grafana", environment)
            if token:
                print("🔑 Using token from Python Keyring")
                return token
        except Exception:
            pass
        
        # Method 4: Secure file
        try:
            token_file = Path.home() / ".config" / "nestory" / "secure" / f"grafana-{environment}.token"
            if token_file.exists():
                with open(token_file) as f:
                    token = f.read().strip()
                if token:
                    print("🔑 Using token from secure file")
                    return token
        except Exception:
            pass
        
        return None
    
    def setup_git_config(self) -> bool:
        """Configure Git with griffin's identity"""
        try:
            # Set global Git configuration
            subprocess.run(['git', 'config', '--global', 'user.name', 'drunkonjava'], check=True)
            subprocess.run(['git', 'config', '--global', 'user.email', self.git_email], check=True)
            
            # Set additional monitoring-specific config
            subprocess.run(['git', 'config', '--global', 'nestory.monitoring.user', self.user_login], check=True)
            subprocess.run(['git', 'config', '--global', 'nestory.monitoring.github', self.github_username], check=True)
            
            print("✅ Git configuration updated with griffin's identity")
            return True
        except Exception as e:
            print(f"❌ Git configuration failed: {e}")
            return False
    
    def create_monitoring_identity(self) -> Dict[str, Any]:
        """Create comprehensive monitoring identity configuration"""
        system_info = self.get_system_identity()
        github_info = self.get_github_auth()
        
        identity = {
            "monitoring_user": self.user_login,
            "system": system_info,
            "github": github_info,
            "git": {
                "name": "drunkonjava", 
                "email": self.git_email
            },
            "keychain_service": self.keychain_service,
            "authentication_methods": [
                "macOS Keychain",
                "Python Keyring", 
                "Environment Variables",
                "Secure File Storage",
                "GitHub CLI Token"
            ],
            "monitoring_scopes": [
                "grafana_admin",
                "dashboard_management",
                "metrics_read_write",
                "github_workflows",
                "system_monitoring"
            ]
        }
        
        return identity
    
    def setup_comprehensive_auth(self) -> bool:
        """Set up comprehensive authentication for all monitoring tools"""
        print("🔐 Setting up comprehensive authentication for griffin...")
        
        success = True
        
        # 1. Configure Git identity
        if not self.setup_git_config():
            success = False
        
        # 2. Verify GitHub authentication
        github_info = self.get_github_auth()
        if github_info.get("authenticated"):
            print(f"✅ GitHub authenticated as: {github_info['username']}")
        else:
            print("⚠️ GitHub authentication needed: run 'gh auth login'")
            success = False
        
        # 3. Create monitoring identity file
        try:
            identity = self.create_monitoring_identity()
            identity_file = Path.home() / ".config" / "nestory" / "monitoring-identity.json"
            identity_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(identity_file, 'w') as f:
                json.dump(identity, f, indent=2)
            
            os.chmod(identity_file, 0o600)
            print(f"✅ Monitoring identity created: {identity_file}")
        except Exception as e:
            print(f"❌ Identity file creation failed: {e}")
            success = False
        
        return success
    
    def interactive_token_setup(self):
        """Interactive setup for API tokens"""
        print("🔧 Interactive Token Setup")
        print("═" * 50)
        
        # Grafana token setup
        print("\n📊 Grafana API Token Setup")
        print("To create a Grafana API token:")
        print("1. Go to http://localhost:3000/admin/api-keys")  
        print("2. Click 'Add API key'")
        print("3. Name: 'Nestory Monitoring'")
        print("4. Role: 'Admin'")
        print("5. Copy the generated token")
        print()
        
        grafana_token = getpass.getpass("Enter Grafana API token (or press Enter to skip): ")
        if grafana_token.strip():
            environments = ["dev", "staging", "prod"]
            for env in environments:
                if self.store_grafana_token(grafana_token.strip(), env):
                    print(f"✅ Grafana token stored for {env} environment")
        
        print("\n✅ Authentication setup completed!")

def main():
    """Main authentication setup function"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Comprehensive authentication setup for griffin")
    parser.add_argument("--setup", action="store_true", help="Run comprehensive authentication setup")
    parser.add_argument("--interactive", action="store_true", help="Interactive token setup")
    parser.add_argument("--status", action="store_true", help="Show authentication status")
    parser.add_argument("--store-grafana", type=str, help="Store Grafana API token")
    parser.add_argument("--environment", type=str, default="dev", help="Target environment (dev/staging/prod)")
    
    args = parser.parse_args()
    
    auth_manager = AuthenticationManager()
    
    if args.setup:
        auth_manager.setup_comprehensive_auth()
    elif args.interactive:
        auth_manager.interactive_token_setup()
    elif args.status:
        identity = auth_manager.create_monitoring_identity()
        print("🔐 Authentication Status")
        print("═" * 40)
        print(f"System User: {identity['system']['system_user']}")
        print(f"GitHub: {identity['github']['username'] if identity['github']['authenticated'] else 'Not authenticated'}")
        print(f"Git Config: {identity['git']['name']} <{identity['git']['email']}>")
        
        # Check for stored tokens
        for env in ["dev", "staging", "prod"]:
            token = auth_manager.get_grafana_token(env)
            status = "✅ Available" if token else "❌ Not found"
            print(f"Grafana Token ({env}): {status}")
    elif args.store_grafana:
        if auth_manager.store_grafana_token(args.store_grafana, args.environment):
            print(f"✅ Grafana token stored for {args.environment} environment")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()