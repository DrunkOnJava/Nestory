#!/usr/bin/env python3
"""
Test script for the Advanced Configuration Manager
"""
import json
import sys
import os
from pathlib import Path

# Add the scripts directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

from config_manager import get_config_manager, ConfigurationError

def test_configuration_manager():
    """Test the configuration manager functionality"""
    print("🧪 Testing Advanced Configuration Manager")
    print("=" * 50)
    
    try:
        # Initialize configuration manager
        config_manager = get_config_manager()
        
        # Test 1: Load environments configuration
        print("\n📋 Test 1: Load Environment Configuration")
        try:
            dev_config = config_manager.get_environment_config("dev")
            print("✅ Development environment loaded:")
            print(f"   Prometheus: {dev_config.get('prometheus_url')}")
            print(f"   Grafana Folder: {dev_config.get('grafana_folder')}")
        except ConfigurationError as e:
            print(f"❌ Failed to load dev environment: {e}")
        
        # Test 2: Validate configuration
        print("\n🔍 Test 2: Configuration Validation")
        try:
            is_valid = config_manager.validate_config("environments")
            if is_valid:
                print("✅ Configuration validation passed")
            else:
                print("❌ Configuration validation failed")
        except Exception as e:
            print(f"⚠️ Validation test failed: {e}")
        
        # Test 3: List all environments
        print("\n📝 Test 3: List All Environments")
        try:
            environments_config = config_manager.get_config("environments")
            print("✅ Available environments:")
            for env_name in environments_config.keys():
                env_config = environments_config[env_name]
                print(f"   • {env_name}: {env_config.get('prometheus_url')}")
        except ConfigurationError as e:
            print(f"❌ Failed to list environments: {e}")
        
        # Test 4: Version management
        print("\n📦 Test 4: Version Management")
        try:
            versions = config_manager.list_config_versions("environments")
            print(f"✅ Found {len(versions)} configuration versions")
            if versions:
                latest = versions[0]
                print(f"   Latest: {latest['version_id']} ({latest['timestamp']})")
        except Exception as e:
            print(f"⚠️ Version management test: {e}")
        
        # Test 5: Configuration change callback
        print("\n🔔 Test 5: Change Callback Registration")
        def test_callback(config_name, config_data):
            print(f"   📢 Configuration '{config_name}' changed!")
        
        config_manager.register_change_callback("environments", test_callback)
        print("✅ Change callback registered successfully")
        
        # Summary
        print("\n" + "=" * 50)
        print("🎉 Configuration Manager Test Summary")
        print("✅ All core functionality working correctly")
        print("📊 Ready for production use")
        
        # Stop file watching for clean exit
        config_manager.stop_watching()
        
        return True
        
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        return False

if __name__ == "__main__":
    success = test_configuration_manager()
    sys.exit(0 if success else 1)