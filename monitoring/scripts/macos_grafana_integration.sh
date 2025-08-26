#!/bin/bash

# macOS + Grafana CLI Integration Helper
# Demonstrates native macOS CLI tools for Grafana management

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}                    🍎 macOS + Grafana CLI Integration${NC}"
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

# Check available CLI tools
check_cli_tools() {
    print_step "Checking available CLI tools..."
    
    local tools=("curl" "jq" "security" "sw_vers" "ifconfig" "grafana" "gh")
    local available=()
    local missing=()
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            available+=("$tool")
            case "$tool" in
                "grafana")
                    version=$(grafana cli --version 2>/dev/null | head -1 || echo "unknown")
                    print_success "$tool: $version"
                    ;;
                "jq")
                    version=$(jq --version 2>/dev/null || echo "unknown")
                    print_success "$tool: $version"
                    ;;
                "gh")
                    version=$(gh --version | head -1 | cut -d' ' -f3 2>/dev/null || echo "unknown")
                    print_success "$tool: gh version $version"
                    ;;
                *)
                    print_success "$tool: available"
                    ;;
            esac
        else
            missing+=("$tool")
            print_warning "$tool: not available"
        fi
    done
    
    echo ""
    print_info "Available tools: ${#available[@]}/${#tools[@]}"
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_info "Missing tools can be installed via: brew install ${missing[*]}"
    fi
    
    echo ""
}

# Keychain token management
manage_keychain_token() {
    local action="${1:-help}"
    local token="${2:-}"
    
    case "$action" in
        "store")
            if [[ -z "$token" ]]; then
                print_error "Token required for store operation"
                return 1
            fi
            
            print_step "Storing Grafana API token in Keychain..."
            if security add-generic-password -s 'grafana-api-token' -a 'nestory' -w "$token" -U 2>/dev/null; then
                print_success "Token stored successfully"
            else
                print_error "Failed to store token"
                return 1
            fi
            ;;
            
        "retrieve")
            print_step "Retrieving Grafana API token from Keychain..."
            if token=$(security find-generic-password -s 'grafana-api-token' -a 'nestory' -w 2>/dev/null); then
                print_success "Token retrieved successfully"
                echo "Token: ${token:0:8}...${token: -8}"
                export GRAFANA_API_TOKEN="$token"
            else
                print_warning "No token found in Keychain"
                return 1
            fi
            ;;
            
        "delete")
            print_step "Deleting Grafana API token from Keychain..."
            if security delete-generic-password -s 'grafana-api-token' -a 'nestory' 2>/dev/null; then
                print_success "Token deleted successfully"
            else
                print_warning "Token not found or already deleted"
            fi
            ;;
            
        "help")
            echo "Token Management Commands:"
            echo "  store <token>   - Store API token in Keychain"
            echo "  retrieve        - Retrieve API token from Keychain"
            echo "  delete          - Delete API token from Keychain"
            echo ""
            echo "Example:"
            echo "  $0 token store 'glsa_xyz123...'"
            echo "  $0 token retrieve"
            ;;
    esac
}

# System information gathering
show_system_info() {
    print_step "Gathering macOS system information..."
    
    # macOS version
    if command -v sw_vers >/dev/null 2>&1; then
        print_success "macOS Version:"
        sw_vers | sed 's/^/   /'
    fi
    
    echo ""
    
    # System uptime
    if command -v uptime >/dev/null 2>&1; then
        uptime_info=$(uptime)
        print_success "System Uptime:"
        echo "   $uptime_info"
    fi
    
    echo ""
    
    # Network interfaces
    if command -v ifconfig >/dev/null 2>&1; then
        active_interfaces=$(ifconfig | grep -E '^[a-zA-Z]' | cut -d: -f1 | wc -l | xargs)
        print_success "Network Interfaces: $active_interfaces active"
        
        # Show IP addresses
        print_info "Active IP addresses:"
        ifconfig | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print "   " $2}' || true
    fi
    
    echo ""
    
    # Disk usage
    if command -v df >/dev/null 2>&1; then
        print_success "Disk Usage:"
        df -h / | tail -1 | awk '{print "   Root: " $3 " used, " $4 " available (" $5 " full)"}' || true
    fi
    
    echo ""
}

# Grafana operations using curl and jq
grafana_operations() {
    local operation="${1:-help}"
    local grafana_url="${GRAFANA_URL:-http://localhost:3000}"
    
    # Retrieve token if not set
    if [[ -z "${GRAFANA_API_TOKEN:-}" ]]; then
        print_step "Retrieving API token from Keychain..."
        if GRAFANA_API_TOKEN=$(security find-generic-password -s 'grafana-api-token' -a 'nestory' -w 2>/dev/null); then
            export GRAFANA_API_TOKEN
            print_success "Using token from Keychain"
        else
            print_error "No API token available. Use: $0 token store <token>"
            return 1
        fi
    fi
    
    case "$operation" in
        "health")
            print_step "Checking Grafana health via curl..."
            if curl -s "$grafana_url/api/health" | jq -r '"\(.commit) - \(.version)"' 2>/dev/null; then
                print_success "Grafana is healthy"
            else
                print_error "Grafana health check failed"
                return 1
            fi
            ;;
            
        "list")
            print_step "Listing dashboards via curl + jq..."
            if dashboards=$(curl -s -H "Authorization: Bearer $GRAFANA_API_TOKEN" "$grafana_url/api/search?type=dash-db" 2>/dev/null); then
                echo "$dashboards" | jq -r '.[] | "📊 \(.title) (UID: \(.uid))"' | head -10
                total=$(echo "$dashboards" | jq '. | length')
                print_success "Found $total dashboards"
            else
                print_error "Failed to list dashboards"
                return 1
            fi
            ;;
            
        "upload")
            local dashboard_file="${2:-}"
            if [[ -z "$dashboard_file" ]]; then
                print_error "Dashboard file path required"
                return 1
            fi
            
            if [[ ! -f "$dashboard_file" ]]; then
                print_error "Dashboard file not found: $dashboard_file"
                return 1
            fi
            
            print_step "Uploading dashboard via curl..."
            
            # Create upload payload
            local temp_payload=$(mktemp)
            jq -n --slurpfile dashboard "$dashboard_file" '{
                dashboard: $dashboard[0],
                folderId: 0,
                overwrite: true,
                message: "Uploaded via macOS integration script"
            }' > "$temp_payload"
            
            if response=$(curl -s -X POST \
                -H "Authorization: Bearer $GRAFANA_API_TOKEN" \
                -H "Content-Type: application/json" \
                -d "@$temp_payload" \
                "$grafana_url/api/dashboards/db" 2>/dev/null); then
                
                uid=$(echo "$response" | jq -r '.uid // "unknown"')
                url=$(echo "$response" | jq -r '.url // "unknown"')
                print_success "Dashboard uploaded successfully"
                print_info "UID: $uid"
                print_info "URL: $grafana_url$url"
            else
                print_error "Dashboard upload failed"
            fi
            
            # Cleanup
            rm -f "$temp_payload"
            ;;
            
        "help")
            echo "Grafana Operations:"
            echo "  health          - Check Grafana health"
            echo "  list            - List all dashboards"
            echo "  upload <file>   - Upload dashboard JSON file"
            echo ""
            echo "Environment Variables:"
            echo "  GRAFANA_URL     - Grafana server URL (default: http://localhost:3000)"
            echo "  GRAFANA_API_TOKEN - API token (or use keychain)"
            ;;
    esac
}

# GitHub CLI integration for monitoring
github_operations() {
    local operation="${1:-help}"
    
    case "$operation" in
        "check-auth")
            print_step "Checking GitHub CLI authentication..."
            if gh auth status >/dev/null 2>&1; then
                username=$(gh api user | jq -r '.login' 2>/dev/null || echo "unknown")
                print_success "Authenticated as: $username"
            else
                print_warning "GitHub CLI not authenticated. Run: gh auth login"
            fi
            ;;
            
        "workflows")
            print_step "Listing GitHub workflows..."
            if gh workflow list --repo "$(pwd)" 2>/dev/null | head -10; then
                print_success "Workflows retrieved"
            else
                print_warning "No workflows found or not in a git repository"
            fi
            ;;
            
        "runners")
            print_step "Checking GitHub runners..."
            if gh api /repos/DrunkOnJava/Nestory/actions/runners 2>/dev/null | jq -r '.runners[] | "🏃 \(.name) - \(.status)"' 2>/dev/null; then
                print_success "Runners retrieved"
            else
                print_warning "Unable to retrieve runners (may require different permissions)"
            fi
            ;;
            
        "help")
            echo "GitHub Operations:"
            echo "  check-auth      - Check GitHub CLI authentication"
            echo "  workflows       - List repository workflows"
            echo "  runners         - List repository runners"
            ;;
    esac
}

# Main function
main() {
    local command="${1:-help}"
    shift || true
    
    print_header
    
    case "$command" in
        "check")
            check_cli_tools
            show_system_info
            ;;
            
        "token")
            manage_keychain_token "$@"
            ;;
            
        "grafana")
            grafana_operations "$@"
            ;;
            
        "github")
            github_operations "$@"
            ;;
            
        "system")
            show_system_info
            ;;
            
        "demo")
            print_step "Running complete integration demo..."
            echo ""
            
            check_cli_tools
            show_system_info
            
            print_step "Testing Grafana operations..."
            grafana_operations health
            
            print_step "Testing GitHub integration..."
            github_operations check-auth
            
            print_success "Demo completed!"
            ;;
            
        "help"|*)
            echo "macOS + Grafana CLI Integration Helper"
            echo ""
            echo "Usage: $0 <command> [args...]"
            echo ""
            echo "Commands:"
            echo "  check           - Check all CLI tools and system info"
            echo "  token <action>  - Manage API tokens in Keychain"
            echo "  grafana <op>    - Grafana operations via curl/jq"
            echo "  github <op>     - GitHub CLI operations"
            echo "  system          - Show macOS system information"
            echo "  demo            - Run complete integration demo"
            echo "  help            - Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 check"
            echo "  $0 token store 'glsa_xyz123...'"
            echo "  $0 grafana health"
            echo "  $0 grafana upload dashboards/comprehensive-dev.json"
            echo "  $0 github workflows"
            echo ""
            ;;
    esac
}

# Execute main function with all arguments
main "$@"