# Nestory Professional Monitoring Makefile
# Provides standardized commands for monitoring infrastructure management

.PHONY: help setup deploy-dev deploy-staging deploy-prod validate clean status folders

# Default target
help:
	@echo "🚀 Nestory Professional Monitoring"
	@echo ""
	@echo "Available targets:"
	@echo "  setup           - Complete professional monitoring setup"
	@echo "  deploy-dev      - Deploy dashboard to development"
	@echo "  deploy-staging  - Deploy dashboard to staging (requires config)" 
	@echo "  deploy-prod     - Deploy dashboard to production (requires config)"
	@echo "  validate        - Validate configuration files"
	@echo "  folders         - Create/update Grafana folders"
	@echo "  status          - Check monitoring service status"
	@echo "  clean           - Clean temporary files"
	@echo ""
	@echo "Environment URLs configured in: config/environments.json"
	@echo "Documentation: README-professional-monitoring.md"

# Complete setup with prerequisites check
setup:
	@echo "🚀 Setting up professional monitoring..."
	./scripts/setup-professional-monitoring.sh

# Deploy to development environment
deploy-dev:
	@echo "📊 Deploying to development..."
	python3 scripts/deploy-dashboard-env.py dev

# Deploy to staging environment
deploy-staging:
	@echo "📊 Deploying to staging..."
	@if [ ! -f config/environments.json ]; then echo "❌ Configuration missing"; exit 1; fi
	python3 scripts/deploy-dashboard-env.py staging

# Deploy to production environment  
deploy-prod:
	@echo "📊 Deploying to production..."
	@echo "⚠️  This will deploy to PRODUCTION. Continue? [y/N]" && read ans && [ $${ans:-N} = y ]
	@if [ ! -f config/environments.json ]; then echo "❌ Configuration missing"; exit 1; fi
	python3 scripts/deploy-dashboard-env.py prod

# Validate all configuration files
validate:
	@echo "🔍 Validating configuration..."
	@if command -v jq > /dev/null; then \
		echo "✅ Validating environments.json..."; \
		jq empty config/environments.json && echo "✅ environments.json is valid JSON"; \
	else \
		echo "⚠️  jq not found - install with: brew install jq"; \
	fi
	@if command -v promtool > /dev/null; then \
		echo "✅ Validating recording rules..."; \
		promtool check rules config/prometheus-recording-rules.yml; \
	else \
		echo "⚠️  promtool not found - install with: brew install prometheus"; \
	fi
	@echo "✅ Configuration validation complete"

# Create Grafana organizational folders
folders:
	@echo "📁 Creating Grafana folders..."
	@curl -X POST -H "Content-Type: application/json" -u "admin:nestory123" \
		-d '{"title": "Nestory Development", "uid": "nry-development"}' \
		"http://localhost:3000/api/folders" 2>/dev/null || echo "Folder may already exist"
	@curl -X POST -H "Content-Type: application/json" -u "admin:nestory123" \
		-d '{"title": "Nestory Observability", "uid": "nry-observability"}' \
		"http://localhost:3000/api/folders" 2>/dev/null || echo "Folder may already exist"
	@echo "✅ Grafana folders configured"

# Check status of monitoring services
status:
	@echo "📊 Monitoring Service Status"
	@echo "================================"
	@echo -n "Prometheus (9090): "
	@if curl -s "http://localhost:9090/api/v1/query?query=up" > /dev/null; then \
		echo "✅ Running"; \
	else \
		echo "❌ Down"; \
	fi
	@echo -n "Pushgateway (9091): "
	@if curl -s "http://localhost:9091/metrics" > /dev/null; then \
		echo "✅ Running"; \
	else \
		echo "❌ Down"; \
	fi
	@echo -n "Grafana (3000): "
	@if curl -s "http://localhost:3000/api/health" > /dev/null; then \
		echo "✅ Running"; \
	else \
		echo "❌ Down"; \
	fi
	@echo -n "Node Exporter (9100): "
	@if curl -s "http://localhost:9100/metrics" > /dev/null; then \
		echo "✅ Running"; \
	else \
		echo "⚠️  Not running (infrastructure panels will be empty)"; \
	fi

# Clean temporary and generated files
clean:
	@echo "🧹 Cleaning temporary files..."
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@rm -f /tmp/dashboard-*.json 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Show current dashboard URLs
urls:
	@echo "📊 Dashboard URLs"
	@echo "=================="
	@echo "Development:  http://localhost:3000/d/nry-full/nestory-dev-complete-monitoring"
	@echo "Staging:      Configure in config/environments.json"
	@echo "Production:   Configure in config/environments.json"
	@echo ""
	@echo "Service URLs:"
	@echo "Prometheus:   http://localhost:9090"
	@echo "Pushgateway:  http://localhost:9091" 
	@echo "Grafana:      http://localhost:3000"