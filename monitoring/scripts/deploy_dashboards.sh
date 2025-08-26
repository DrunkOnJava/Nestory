#!/bin/bash

# Nestory Monitoring Dashboard Deployment Script
# Comprehensive automation for dashboard generation and Grafana upload

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}                    🚀 NESTORY MONITORING DEPLOYMENT${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}💡 $1${NC}"
}

# Check if Python virtual environment exists and activate it
activate_venv() {
    print_step "Activating Python virtual environment..."
    
    if [[ ! -d "$PROJECT_DIR/venv" ]]; then
        print_error "Python virtual environment not found at $PROJECT_DIR/venv"
        print_info "Please run: python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt"
        exit 1
    fi
    
    source "$PROJECT_DIR/venv/bin/activate"
    print_success "Python virtual environment activated"
}

# Generate dashboards
generate_dashboards() {
    print_step "Generating modular dashboards..."
    
    cd "$PROJECT_DIR"
    
    # Generate comprehensive dashboard for development
    print_step "  📊 Generating comprehensive dashboard (dev environment)..."
    python3 scripts/dashboard_generator.py --template comprehensive --environment dev
    print_success "  Generated: dashboards/comprehensive-dev.json"
    
    # Generate production dashboard for production environment
    print_step "  📊 Generating production dashboard (prod environment)..."
    python3 scripts/dashboard_generator.py --template production --environment prod
    print_success "  Generated: dashboards/production-prod.json"
    
    # Show dashboard statistics
    echo ""
    print_step "Dashboard Statistics:"
    echo -e "${CYAN}  • Comprehensive Dashboard: $(jq '.panels | length' dashboards/comprehensive-dev.json) panels${NC}"
    echo -e "${CYAN}  • Production Dashboard: $(jq '.panels | length' dashboards/production-prod.json) panels${NC}"
    echo ""
}

# Check Grafana connectivity
check_grafana() {
    print_step "Checking Grafana connectivity..."
    
    cd "$PROJECT_DIR"
    
    if python3 scripts/upload_to_grafana.py --health > /dev/null 2>&1; then
        print_success "Grafana is healthy and reachable"
        return 0
    else
        print_warning "Grafana connectivity check failed"
        print_info "This is normal if Grafana is not running or API token is not configured"
        return 1
    fi
}

# Upload dashboards to Grafana (if configured)
upload_dashboards() {
    print_step "Uploading dashboards to Grafana..."
    
    cd "$PROJECT_DIR"
    
    if [[ -z "${GRAFANA_API_TOKEN:-}" ]]; then
        print_warning "GRAFANA_API_TOKEN environment variable not set"
        print_info "Skipping Grafana upload. To upload:"
        print_info "  1. Set GRAFANA_API_TOKEN environment variable"
        print_info "  2. Run: python3 scripts/upload_to_grafana.py --all"
        return 0
    fi
    
    print_step "  📤 Uploading all generated dashboards..."
    if python3 scripts/upload_to_grafana.py --all; then
        print_success "Dashboards uploaded successfully"
    else
        print_error "Dashboard upload failed"
        return 1
    fi
}

# Show deployment summary
show_summary() {
    echo ""
    print_header
    echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE${NC}"
    echo ""
    
    echo -e "${CYAN}Generated Dashboards:${NC}"
    echo -e "  📊 ${GREEN}Comprehensive Dashboard${NC}: dashboards/comprehensive-dev.json"
    echo -e "  📊 ${GREEN}Production Dashboard${NC}: dashboards/production-prod.json"
    echo ""
    
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "  🔑 ${YELLOW}Set GRAFANA_API_TOKEN${NC} to upload dashboards automatically"
    echo -e "  🚀 ${YELLOW}Run Grafana${NC} at http://localhost:3000"
    echo -e "  📤 ${YELLOW}Manual upload${NC}: python3 scripts/upload_to_grafana.py --all"
    echo ""
    
    echo -e "${CYAN}Quick Commands:${NC}"
    echo -e "  • ${BLUE}Test configuration${NC}: python3 scripts/test_config_manager.py"
    echo -e "  • ${BLUE}Generate new dashboard${NC}: python3 scripts/dashboard_generator.py --template comprehensive"
    echo -e "  • ${BLUE}Check Grafana health${NC}: python3 scripts/upload_to_grafana.py --health"
    echo -e "  • ${BLUE}List dashboards${NC}: python3 scripts/upload_to_grafana.py --list"
    echo ""
}

# Main deployment function
main() {
    print_header
    
    # Step 1: Activate virtual environment
    activate_venv
    
    # Step 2: Generate dashboards
    generate_dashboards
    
    # Step 3: Check Grafana (optional)
    check_grafana
    
    # Step 4: Upload dashboards (if configured)
    upload_dashboards
    
    # Step 5: Show summary
    show_summary
}

# Handle command line arguments
case "${1:-}" in
    "generate")
        activate_venv
        generate_dashboards
        ;;
    "upload")
        activate_venv
        upload_dashboards
        ;;
    "health")
        activate_venv
        check_grafana
        ;;
    "help"|"--help"|"-h")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  generate    Generate dashboards only"
        echo "  upload      Upload dashboards to Grafana"
        echo "  health      Check Grafana connectivity"
        echo "  help        Show this help message"
        echo ""
        echo "Default: Run full deployment (generate + upload)"
        ;;
    *)
        main
        ;;
esac