#!/usr/bin/env python3
"""
Monitoring Health Check Script
Verifies that the professional monitoring setup is working correctly
"""
import requests
import json
import sys
import time
from datetime import datetime

def check_service(name, url, expected_status=200, timeout=5):
    """Check if a service is responding correctly"""
    try:
        response = requests.get(url, timeout=timeout)
        if response.status_code == expected_status:
            print(f"✅ {name}: Running")
            return True
        else:
            print(f"❌ {name}: HTTP {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ {name}: Connection failed - {e}")
        return False

def check_prometheus_targets():
    """Check Prometheus targets health"""
    try:
        response = requests.get("http://localhost:9090/api/v1/targets", timeout=5)
        if response.status_code == 200:
            targets = response.json()
            healthy_count = 0
            total_count = 0
            
            for target_group in targets.get('data', {}).get('activeTargets', []):
                total_count += 1
                if target_group.get('health') == 'up':
                    healthy_count += 1
                else:
                    job = target_group.get('labels', {}).get('job', 'unknown')
                    print(f"⚠️  Target down: {job}")
            
            print(f"📊 Prometheus Targets: {healthy_count}/{total_count} healthy")
            return healthy_count > 0
    except Exception as e:
        print(f"❌ Prometheus targets check failed: {e}")
        return False

def check_grafana_dashboard():
    """Check if the professional dashboard exists and is accessible"""
    try:
        # Check dashboard exists
        response = requests.get(
            "http://localhost:3000/api/dashboards/uid/nry-full",
            auth=('admin', 'nestory123'),
            timeout=5
        )
        
        if response.status_code == 200:
            dashboard = response.json()
            version = dashboard.get('dashboard', {}).get('version', 'unknown')
            title = dashboard.get('dashboard', {}).get('title', 'unknown')
            print(f"✅ Dashboard: {title} (v{version})")
            return True
        else:
            print(f"❌ Dashboard not found or inaccessible")
            return False
    except Exception as e:
        print(f"❌ Dashboard check failed: {e}")
        return False

def check_recording_rules():
    """Check if Prometheus recording rules are loaded"""
    try:
        response = requests.get("http://localhost:9090/api/v1/rules", timeout=5)
        if response.status_code == 200:
            rules = response.json()
            nestory_rules = 0
            
            for group in rules.get('data', {}).get('groups', []):
                if 'nestory' in group.get('name', '').lower():
                    nestory_rules += len(group.get('rules', []))
            
            if nestory_rules > 0:
                print(f"✅ Recording Rules: {nestory_rules} Nestory rules loaded")
                return True
            else:
                print("⚠️  Recording Rules: No Nestory rules found (add to Prometheus config)")
                return False
    except Exception as e:
        print(f"❌ Recording rules check failed: {e}")
        return False

def main():
    """Run comprehensive health check"""
    print("🔍 Professional Monitoring Health Check")
    print("=" * 50)
    print(f"🕒 Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    checks_passed = 0
    total_checks = 0
    
    # Core services
    services = [
        ("Prometheus", "http://localhost:9090/-/healthy"),
        ("Pushgateway", "http://localhost:9091/"),
        ("Grafana", "http://localhost:3000/api/health"),
    ]
    
    print("📊 Core Services:")
    for name, url in services:
        total_checks += 1
        if check_service(name, url):
            checks_passed += 1
    
    # Optional services
    print("\n🔧 Optional Services:")
    total_checks += 1
    if check_service("Node Exporter", "http://localhost:9100/metrics"):
        checks_passed += 1
    
    # Advanced checks
    print("\n🚀 Advanced Checks:")
    advanced_checks = [
        ("Prometheus Targets", check_prometheus_targets),
        ("Grafana Dashboard", check_grafana_dashboard), 
        ("Recording Rules", check_recording_rules),
    ]
    
    for name, check_func in advanced_checks:
        total_checks += 1
        print(f"🔍 Checking {name}...")
        if check_func():
            checks_passed += 1
    
    # Summary
    print("\n" + "=" * 50)
    if checks_passed == total_checks:
        print(f"✅ All checks passed ({checks_passed}/{total_checks})")
        print("🚀 Professional monitoring is fully operational!")
        sys.exit(0)
    elif checks_passed >= total_checks * 0.8:  # 80% threshold
        print(f"⚠️  Most checks passed ({checks_passed}/{total_checks})")
        print("🔧 Some components need attention but core monitoring works")
        sys.exit(1)
    else:
        print(f"❌ Multiple failures ({checks_passed}/{total_checks})")
        print("🚨 Professional monitoring needs significant attention")
        sys.exit(2)

if __name__ == "__main__":
    main()