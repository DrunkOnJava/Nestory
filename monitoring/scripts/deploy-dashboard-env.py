#!/usr/bin/env python3
"""
Professional Dashboard Deployment Script
Deploys environment-specific dashboards with proper templating
"""
import json
import sys
import argparse
import requests
from requests.auth import HTTPBasicAuth
from pathlib import Path

def load_config():
    """Load environment configurations"""
    config_path = Path(__file__).parent.parent / "config" / "environments.json"
    with open(config_path, 'r') as f:
        return json.load(f)

def load_dashboard_template():
    """Load the dashboard template"""
    template_path = Path(__file__).parent.parent / "dashboards" / "nry-full-template-complete.json"
    with open(template_path, 'r') as f:
        return json.load(f)

def substitute_variables(dashboard, environment, config):
    """Replace template variables with environment-specific values"""
    dashboard_str = json.dumps(dashboard)
    
    # Replace environment variables
    dashboard_str = dashboard_str.replace("${environment}", environment)
    dashboard_str = dashboard_str.replace("${prometheus_url}", config["prometheus_url"])
    dashboard_str = dashboard_str.replace("${pushgateway_url}", config["pushgateway_url"])
    dashboard_str = dashboard_str.replace("${alertmanager_url}", config["alertmanager_url"])
    dashboard_str = dashboard_str.replace("${runbook_url}", config["runbook_url"])
    
    return json.loads(dashboard_str)

def deploy_to_grafana(dashboard, grafana_url, username, password):
    """Deploy dashboard to Grafana instance"""
    # Remove id to allow overwrite by UID
    dashboard_copy = dashboard.copy()
    if 'id' in dashboard_copy:
        del dashboard_copy['id']
    
    payload = {
        "dashboard": dashboard_copy,
        "overwrite": True
    }
    
    response = requests.post(
        f"{grafana_url}/api/dashboards/db",
        json=payload,
        auth=HTTPBasicAuth(username, password),
        headers={'Content-Type': 'application/json'}
    )
    
    return response

def main():
    parser = argparse.ArgumentParser(description="Deploy Nestory monitoring dashboard")
    parser.add_argument("environment", choices=["prod", "staging", "dev"], 
                       help="Target environment")
    parser.add_argument("--grafana-url", default="http://localhost:3000",
                       help="Grafana URL (default: localhost)")
    parser.add_argument("--username", default="admin", help="Grafana username")
    parser.add_argument("--password", default="nestory123", help="Grafana password")
    
    args = parser.parse_args()
    
    # Load configurations
    config = load_config()
    env_config = config[args.environment]
    
    # Load and customize dashboard
    dashboard = load_dashboard_template()
    dashboard = substitute_variables(dashboard, args.environment, env_config)
    
    # Deploy to Grafana
    response = deploy_to_grafana(dashboard, args.grafana_url, args.username, args.password)
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Dashboard deployed successfully to {args.environment}!")
        print(f"📊 URL: {args.grafana_url}{result['url']}")
        print(f"📝 Version: {result['version']}")
        print(f"🆔 UID: {result['uid']}")
    else:
        print(f"❌ Deployment failed!")
        print(f"Status: {response.status_code}")
        print(f"Error: {response.text}")
        sys.exit(1)

if __name__ == "__main__":
    main()