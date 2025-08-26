# Integration with Main Nestory Project

To integrate the professional monitoring system with your main project, add these targets to your root Makefile:

## Add to Main Makefile

```makefile
# Monitoring targets
.PHONY: monitoring-setup monitoring-deploy monitoring-status

# Complete monitoring setup
monitoring-setup:
	@echo "🚀 Setting up professional monitoring..."
	cd monitoring && make setup

# Deploy monitoring dashboard
monitoring-deploy:
	@echo "📊 Deploying monitoring dashboard..."
	cd monitoring && make deploy-dev

# Check monitoring status  
monitoring-status:
	@echo "📊 Checking monitoring services..."
	cd monitoring && make status

# Quick monitoring check (for CI/CD)
monitor:
	@cd monitoring && make status
```

## Integration with CI/CD

Add to your build scripts:

```bash
# Before build
make monitoring-status

# After successful build
cd monitoring && python3 scripts/push-build-metrics.py success $BUILD_DURATION

# After failed build
cd monitoring && python3 scripts/push-build-metrics.py failure $BUILD_DURATION
```

## Environment Variables

Set these in your shell profile:

```bash
# ~/.zshrc or ~/.bashrc
export NESTORY_MONITORING_ENV=dev
export GRAFANA_URL=http://localhost:3000
export PROMETHEUS_URL=http://localhost:9090
```

## Integration Commands

From project root:

```bash
# Quick setup
make monitoring-setup

# Deploy dashboard  
make monitoring-deploy

# Check status
make monitoring-status

# From monitoring directory
cd monitoring
make help                # Show all options
make deploy-dev         # Deploy to development
make validate          # Validate configuration
make urls              # Show dashboard URLs
```