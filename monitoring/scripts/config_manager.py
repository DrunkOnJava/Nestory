#!/usr/bin/env python3
"""
Advanced Configuration Manager
Provides dynamic configuration with validation, hot-reloading, and versioning
"""
import json
import jsonschema
import yaml
import os
import hashlib
import time
import threading
from pathlib import Path
from typing import Dict, Any, Optional, Callable
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class ConfigurationError(Exception):
    """Configuration-related errors"""
    pass

class ConfigVersionManager:
    """Manages configuration versions and rollback capabilities"""
    
    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self.versions_dir = config_dir / "versions"
        self.versions_dir.mkdir(exist_ok=True)
    
    def save_version(self, config_name: str, config_data: Dict[str, Any]) -> str:
        """Save a configuration version"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        version_id = f"{config_name}_{timestamp}"
        
        version_file = self.versions_dir / f"{version_id}.json"
        
        version_metadata = {
            "version_id": version_id,
            "config_name": config_name,
            "timestamp": timestamp,
            "checksum": self._calculate_checksum(config_data),
            "data": config_data
        }
        
        with open(version_file, 'w') as f:
            json.dump(version_metadata, f, indent=2)
        
        return version_id
    
    def rollback_to_version(self, version_id: str) -> Dict[str, Any]:
        """Rollback to a specific configuration version"""
        version_file = self.versions_dir / f"{version_id}.json"
        
        if not version_file.exists():
            raise ConfigurationError(f"Version {version_id} not found")
        
        with open(version_file, 'r') as f:
            version_data = json.load(f)
        
        return version_data['data']
    
    def list_versions(self, config_name: str) -> list:
        """List all versions for a configuration"""
        versions = []
        pattern = f"{config_name}_*.json"
        
        for version_file in self.versions_dir.glob(pattern):
            with open(version_file, 'r') as f:
                metadata = json.load(f)
                versions.append({
                    'version_id': metadata['version_id'],
                    'timestamp': metadata['timestamp'],
                    'checksum': metadata['checksum']
                })
        
        return sorted(versions, key=lambda x: x['timestamp'], reverse=True)
    
    def _calculate_checksum(self, data: Dict[str, Any]) -> str:
        """Calculate MD5 checksum of configuration data"""
        json_str = json.dumps(data, sort_keys=True)
        return hashlib.md5(json_str.encode()).hexdigest()

class ConfigFileHandler(FileSystemEventHandler):
    """Handles configuration file changes for hot-reloading"""
    
    def __init__(self, config_manager: 'AdvancedConfigManager'):
        self.config_manager = config_manager
    
    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith('.json'):
            self.config_manager._reload_config(event.src_path)

class AdvancedConfigManager:
    """
    Advanced configuration manager with:
    - JSON Schema validation
    - Hot-reloading
    - Version management
    - Change callbacks
    - Environment variable interpolation
    """
    
    def __init__(self, config_dir: str):
        self.config_dir = Path(config_dir)
        self.schemas_dir = self.config_dir / "schemas"
        self.configs: Dict[str, Dict[str, Any]] = {}
        self.schemas: Dict[str, Dict[str, Any]] = {}
        self.checksums: Dict[str, str] = {}
        self.change_callbacks: Dict[str, list] = {}
        self.version_manager = ConfigVersionManager(self.config_dir)
        
        # Hot-reloading setup
        self.observer = Observer()
        self.file_handler = ConfigFileHandler(self)
        self.observer.schedule(self.file_handler, str(self.config_dir), recursive=True)
        self.observer.start()
        
        # Load schemas
        self._load_schemas()
        
        # Initial config load
        self._load_all_configs()
    
    def _load_schemas(self):
        """Load JSON schemas for validation"""
        if not self.schemas_dir.exists():
            return
        
        for schema_file in self.schemas_dir.glob("*.json"):
            schema_name = schema_file.stem.replace("-schema", "")
            try:
                with open(schema_file, 'r') as f:
                    schema_data = json.load(f)
                self.schemas[schema_name] = schema_data
                print(f"✅ Loaded schema: {schema_name}")
            except Exception as e:
                print(f"❌ Failed to load schema {schema_file}: {e}")
    
    def _load_all_configs(self):
        """Load all configuration files"""
        for config_file in self.config_dir.glob("*.json"):
            if config_file.parent.name != "schemas":
                self._load_config_file(str(config_file))
    
    def _load_config_file(self, file_path: str):
        """Load a specific configuration file"""
        config_path = Path(file_path)
        config_name = config_path.stem
        
        try:
            with open(config_path, 'r') as f:
                config_data = json.load(f)
            
            # Interpolate environment variables
            config_data = self._interpolate_env_vars(config_data)
            
            # Validate against schema if available
            if config_name in self.schemas:
                try:
                    jsonschema.validate(config_data, self.schemas[config_name])
                    print(f"✅ Configuration validation passed: {config_name}")
                except jsonschema.ValidationError as e:
                    raise ConfigurationError(f"Configuration validation failed for {config_name}: {e.message}")
            
            # Calculate checksum for change detection
            new_checksum = self._calculate_checksum(config_data)
            old_checksum = self.checksums.get(config_name)
            
            # Save version if changed
            if old_checksum and new_checksum != old_checksum:
                version_id = self.version_manager.save_version(config_name, self.configs.get(config_name, {}))
                print(f"📦 Saved configuration version: {version_id}")
            
            # Update configuration
            self.configs[config_name] = config_data
            self.checksums[config_name] = new_checksum
            
            # Trigger change callbacks
            if config_name in self.change_callbacks:
                for callback in self.change_callbacks[config_name]:
                    try:
                        callback(config_name, config_data)
                    except Exception as e:
                        print(f"⚠️ Configuration change callback failed: {e}")
            
            print(f"🔄 Loaded configuration: {config_name}")
            
        except Exception as e:
            print(f"❌ Failed to load configuration {file_path}: {e}")
            raise ConfigurationError(f"Failed to load {file_path}: {e}")
    
    def _reload_config(self, file_path: str):
        """Reload configuration file (called by file watcher)"""
        print(f"🔄 Configuration file changed: {file_path}")
        time.sleep(0.1)  # Debounce file changes
        self._load_config_file(file_path)
    
    def _interpolate_env_vars(self, data: Any) -> Any:
        """Recursively interpolate environment variables in configuration"""
        if isinstance(data, dict):
            return {key: self._interpolate_env_vars(value) for key, value in data.items()}
        elif isinstance(data, list):
            return [self._interpolate_env_vars(item) for item in data]
        elif isinstance(data, str) and data.startswith("${") and data.endswith("}"):
            env_var = data[2:-1]
            default_value = None
            
            if ":-" in env_var:
                env_var, default_value = env_var.split(":-", 1)
            
            return os.getenv(env_var, default_value or data)
        else:
            return data
    
    def _calculate_checksum(self, data: Dict[str, Any]) -> str:
        """Calculate MD5 checksum of configuration data"""
        json_str = json.dumps(data, sort_keys=True)
        return hashlib.md5(json_str.encode()).hexdigest()
    
    def get_config(self, config_name: str, environment: str = None) -> Dict[str, Any]:
        """Get configuration data"""
        if config_name not in self.configs:
            raise ConfigurationError(f"Configuration '{config_name}' not found")
        
        config = self.configs[config_name]
        
        if environment and environment in config:
            return config[environment]
        
        return config
    
    def get_environment_config(self, environment: str) -> Dict[str, Any]:
        """Get environment-specific configuration"""
        return self.get_config("environments", environment)
    
    def validate_config(self, config_name: str) -> bool:
        """Validate a specific configuration against its schema"""
        if config_name not in self.configs:
            raise ConfigurationError(f"Configuration '{config_name}' not found")
        
        if config_name not in self.schemas:
            print(f"⚠️ No schema found for configuration: {config_name}")
            return True
        
        try:
            jsonschema.validate(self.configs[config_name], self.schemas[config_name])
            return True
        except jsonschema.ValidationError as e:
            print(f"❌ Validation failed for {config_name}: {e.message}")
            return False
    
    def register_change_callback(self, config_name: str, callback: Callable):
        """Register callback for configuration changes"""
        if config_name not in self.change_callbacks:
            self.change_callbacks[config_name] = []
        self.change_callbacks[config_name].append(callback)
    
    def rollback_config(self, config_name: str, version_id: str):
        """Rollback configuration to a specific version"""
        rollback_data = self.version_manager.rollback_to_version(version_id)
        
        # Write rollback data to file
        config_file = self.config_dir / f"{config_name}.json"
        with open(config_file, 'w') as f:
            json.dump(rollback_data, f, indent=2)
        
        print(f"🔄 Rolled back {config_name} to version {version_id}")
    
    def list_config_versions(self, config_name: str) -> list:
        """List all versions for a configuration"""
        return self.version_manager.list_versions(config_name)
    
    def stop_watching(self):
        """Stop file watching"""
        self.observer.stop()
        self.observer.join()
    
    def __del__(self):
        """Cleanup file watching on destruction"""
        if hasattr(self, 'observer') and self.observer.is_alive():
            self.stop_watching()

# Singleton instance
_config_manager = None

def get_config_manager(config_dir: str = None) -> AdvancedConfigManager:
    """Get singleton configuration manager instance"""
    global _config_manager
    if _config_manager is None:
        if config_dir is None:
            config_dir = os.path.join(os.path.dirname(__file__), "..", "config")
        _config_manager = AdvancedConfigManager(config_dir)
    return _config_manager

# Example usage and testing
if __name__ == "__main__":
    # Test configuration manager
    config_manager = get_config_manager()
    
    # Example: Get development environment config
    try:
        dev_config = config_manager.get_environment_config("dev")
        print("Development configuration:")
        print(json.dumps(dev_config, indent=2))
    except ConfigurationError as e:
        print(f"Configuration error: {e}")
    
    # Example: Register change callback
    def on_config_change(config_name: str, config_data: Dict[str, Any]):
        print(f"Configuration '{config_name}' changed!")
    
    config_manager.register_change_callback("environments", on_config_change)
    
    # Keep alive for testing
    try:
        print("Configuration manager running. Press Ctrl+C to stop.")
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        config_manager.stop_watching()
        print("Configuration manager stopped.")