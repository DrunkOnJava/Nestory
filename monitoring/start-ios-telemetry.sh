#!/bin/bash

# Start iOS Telemetry Stack
# Complete OpenTelemetry pipeline for iOS app monitoring

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Nestory iOS Telemetry Stack${NC}"
echo "========================================"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# Check Docker Compose (try both syntaxes)
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose --version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${YELLOW}⚠️  Docker Compose not found. Please install Docker Compose.${NC}"
    exit 1
fi

echo -e "${GREEN}🐳 Using: $DOCKER_COMPOSE${NC}"

# Stop any existing containers
echo -e "${GREEN}🛑 Stopping existing containers...${NC}"
$DOCKER_COMPOSE -f docker-compose-telemetry.yml down --remove-orphans || true

# Create necessary directories
echo -e "${GREEN}📁 Creating directories...${NC}"
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/dashboards

# Create Grafana datasource configuration
cat > grafana/provisioning/datasources/datasources.yaml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100

  - name: Tempo
    type: tempo
    access: proxy
    url: http://tempo:3200
EOF

# Create Grafana dashboard configuration
cat > grafana/provisioning/dashboards/dashboards.yaml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# Copy dashboards to Grafana directory
echo -e "${GREEN}📊 Setting up dashboards...${NC}"
cp dashboards/ios-telemetry.json grafana/dashboards/
if [ -f "dashboards/unified-dev-fixed.json" ]; then
    cp dashboards/unified-dev-fixed.json grafana/dashboards/
fi

# Update collector config to point to correct Prometheus endpoint
echo -e "${GREEN}⚙️  Configuring OpenTelemetry Collector...${NC}"
sed 's|http://localhost:9090|http://prometheus:9090|g' collector.yaml > collector-docker.yaml

# Update prometheus config
echo -e "${GREEN}⚙️  Configuring Prometheus...${NC}"
cp prometheus-telemetry.yml prometheus.yml

# Start the stack
echo -e "${GREEN}🐳 Starting telemetry stack...${NC}"
$DOCKER_COMPOSE -f docker-compose-telemetry.yml up -d

# Wait for services to be ready
echo -e "${GREEN}⏳ Waiting for services to start...${NC}"
sleep 10

# Check service health
echo -e "${GREEN}🏥 Checking service health...${NC}"

services=(
    "http://localhost:4318/v1/metrics:OpenTelemetry Collector (HTTP)"
    "http://localhost:9090/-/ready:Prometheus"
    "http://localhost:3100/ready:Loki"
    "http://localhost:3200/ready:Tempo"
    "http://localhost:3000/api/health:Grafana"
)

all_healthy=true
for service in "${services[@]}"; do
    url="${service%%:*}"
    name="${service##*:}"
    
    if curl -s --max-time 5 "$url" > /dev/null 2>&1; then
        echo -e "  ✅ $name"
    else
        echo -e "  ❌ $name (may still be starting)"
        all_healthy=false
    fi
done

echo ""
if $all_healthy; then
    echo -e "${GREEN}🎉 All services are healthy!${NC}"
else
    echo -e "${YELLOW}⚠️  Some services may still be starting. Check with:${NC}"
    echo -e "   $DOCKER_COMPOSE -f docker-compose-telemetry.yml logs"
fi

echo ""
echo -e "${BLUE}📱 iOS Configuration${NC}"
echo "==================="
echo -e "Add this to your iOS app configuration:"
echo ""
echo -e "${GREEN}OpenTelemetry Endpoint:${NC} http://localhost:4318"
echo -e "${GREEN}Service Name:${NC} nestory-ios"
echo ""
echo -e "Example Swift code:"
echo 'TelemetryBootstrap.start('
echo '    serviceName: "nestory-ios",'
echo '    otlpEndpoint: URL(string: "http://localhost:4318")!,'
echo '    environment: "dev"'
echo ')'

echo ""
echo -e "${BLUE}📊 Access URLs${NC}"
echo "=============="
echo -e "${GREEN}Grafana:${NC}       http://localhost:3000 (admin/nestory123)"
echo -e "${GREEN}Prometheus:${NC}    http://localhost:9090"
echo -e "${GREEN}iOS Dashboard:${NC} http://localhost:3000/d/nry-ios-telemetry/"

echo ""
echo -e "${BLUE}🔧 Management Commands${NC}"
echo "====================="
echo -e "${GREEN}View logs:${NC}        $DOCKER_COMPOSE -f docker-compose-telemetry.yml logs -f"
echo -e "${GREEN}Stop stack:${NC}       $DOCKER_COMPOSE -f docker-compose-telemetry.yml down"
echo -e "${GREEN}Restart:${NC}          $DOCKER_COMPOSE -f docker-compose-telemetry.yml restart"

# Upload iOS dashboard to Grafana
echo ""
echo -e "${GREEN}📊 Uploading iOS dashboard...${NC}"
sleep 5  # Wait for Grafana to be fully ready

if command -v python3 &> /dev/null && [ -f "scripts/upload_to_grafana.py" ]; then
    # Store Grafana credentials in keychain for upload script
    if ! security find-generic-password -s "grafana-api-token-telemetry" -a "admin" > /dev/null 2>&1; then
        # Create API token would go here - for now use basic auth in upload script
        echo "Note: Using basic auth for dashboard upload"
    fi
    
    # Upload via curl since we know the credentials
    echo -e "${GREEN}Uploading iOS Telemetry dashboard...${NC}"
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -u "admin:nestory123" \
        -d @dashboards/ios-telemetry.json \
        http://localhost:3000/api/dashboards/db > /dev/null && \
        echo -e "✅ iOS Telemetry dashboard uploaded" || \
        echo -e "⚠️  Dashboard upload failed (may need manual import)"
fi

echo ""
echo -e "${GREEN}✅ iOS Telemetry Stack Ready!${NC}"
echo -e "Open ${GREEN}http://localhost:3000/d/nry-ios-telemetry/${NC} to view iOS metrics"