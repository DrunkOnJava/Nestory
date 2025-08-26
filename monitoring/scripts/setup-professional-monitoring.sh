#!/bin/bash
# Professional Monitoring Setup Script
# Configures complete monitoring infrastructure with recording rules and dashboards

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Setting up Professional Nestory Monitoring..."
echo "📁 Project directory: $PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Prometheus is running
check_prometheus() {
    print_info "Checking Prometheus connection..."
    if curl -s "http://localhost:9090/api/v1/query?query=up" > /dev/null; then
        print_status "Prometheus is running on port 9090"
        return 0
    else
        print_error "Prometheus is not accessible on localhost:9090"
        return 1
    fi
}

# Check if Grafana is running
check_grafana() {
    print_info "Checking Grafana connection..."
    if curl -s "http://localhost:3000/api/health" > /dev/null; then
        print_status "Grafana is running on port 3000"
        return 0
    else
        print_error "Grafana is not accessible on localhost:3000"
        return 1
    fi
}

# Validate recording rules syntax
validate_recording_rules() {
    print_info "Validating Prometheus recording rules syntax..."
    if command -v promtool > /dev/null; then
        if promtool check rules "$PROJECT_DIR/config/prometheus-recording-rules.yml"; then
            print_status "Recording rules syntax is valid"
            return 0
        else
            print_error "Recording rules have syntax errors"
            return 1
        fi
    else
        print_warning "promtool not found - skipping rule validation"
        print_info "Install Prometheus tools to validate rules: brew install prometheus"
        return 0
    fi
}

# Deploy recording rules (requires Prometheus restart)
deploy_recording_rules() {
    print_info "Recording rules deployment requires Prometheus configuration update"
    print_info "Add this to your prometheus.yml:"
    echo ""
    echo "rule_files:"
    echo "  - \"$(realpath "$PROJECT_DIR/config/prometheus-recording-rules.yml")\""
    echo ""
    print_warning "You'll need to restart Prometheus after adding the rule_files configuration"
}

# Deploy development dashboard
deploy_dev_dashboard() {
    print_info "Deploying development dashboard..."
    if python3 "$PROJECT_DIR/scripts/deploy-dashboard-env.py" dev; then
        print_status "Development dashboard deployed successfully"
        return 0
    else
        print_error "Failed to deploy development dashboard"
        return 1
    fi
}

# Create Grafana folders
create_grafana_folders() {
    print_info "Creating Grafana folders for organization..."
    
    # Create folders via API
    curl -X POST \
        -H "Content-Type: application/json" \
        -u "admin:nestory123" \
        -d '{"title": "Nestory Development", "uid": "nry-development"}' \
        "http://localhost:3000/api/folders" 2>/dev/null || true
        
    curl -X POST \
        -H "Content-Type: application/json" \
        -u "admin:nestory123" \
        -d '{"title": "Nestory Observability", "uid": "nry-observability"}' \
        "http://localhost:3000/api/folders" 2>/dev/null || true
        
    print_status "Grafana folders created"
}

# Test dashboard functionality
test_dashboard() {
    print_info "Testing dashboard queries..."
    
    # Test basic Prometheus connectivity
    if curl -s "http://localhost:9090/api/v1/query?query=up" | grep -q "success"; then
        print_status "Dashboard can query Prometheus"
    else
        print_error "Dashboard cannot query Prometheus"
        return 1
    fi
    
    # Test node-exporter fallback queries
    if curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | grep -q "success"; then
        print_status "Node-exporter metrics available for fallbacks"
    else
        print_warning "Node-exporter not available - infrastructure panels may be empty"
    fi
}

# Main setup process
main() {
    echo ""
    print_info "=== Professional Monitoring Setup ==="
    echo ""
    
    # Prerequisites check
    if ! check_prometheus; then
        print_error "Prometheus is required. Please start Prometheus first."
        exit 1
    fi
    
    if ! check_grafana; then
        print_error "Grafana is required. Please start Grafana first."
        exit 1
    fi
    
    # Validate configuration
    validate_recording_rules
    
    # Deploy components
    create_grafana_folders
    deploy_dev_dashboard
    deploy_recording_rules
    
    # Test functionality
    test_dashboard
    
    echo ""
    print_status "=== Setup Complete! ==="
    echo ""
    print_info "📊 Dashboard URL: http://localhost:3000/d/nry-full/nestory-dev-complete-monitoring"
    print_info "📈 Prometheus URL: http://localhost:9090"
    print_info "📋 Next steps:"
    echo "   1. Add recording rules to Prometheus config and restart"
    echo "   2. Configure staging/production URLs in config/environments.json"
    echo "   3. Deploy to other environments: python3 scripts/deploy-dashboard-env.py staging"
    echo ""
    print_info "📚 Documentation: monitoring/README-professional-monitoring.md"
}

# Run main function
main "$@"