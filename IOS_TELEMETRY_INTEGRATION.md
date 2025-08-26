# iOS Telemetry Integration Guide

## Overview

This guide shows how to integrate proper iOS telemetry into the Nestory project using OpenTelemetry-Swift. This replaces the current server-side monitoring approach with a proper mobile-first telemetry pipeline.

## Architecture

```
Nestory iOS App (OpenTelemetry-Swift)
    ↓ OTLP/HTTP Push
OpenTelemetry Collector
    ├─ Prometheus (metrics)
    ├─ Loki (logs)
    └─ Tempo (traces)
         ↓
    Grafana Dashboards
```

## 🚀 Quick Start

### 1. Start the Telemetry Stack

```bash
cd monitoring
./start-ios-telemetry.sh
```

This will start:
- OpenTelemetry Collector (ports 4317/4318)
- Prometheus (port 9090) 
- Loki (port 3100)
- Tempo (port 3200)
- Grafana (port 3000)

### 2. Add OpenTelemetry to iOS Project

Add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/open-telemetry/opentelemetry-swift", from: "1.6.0")
],
targets: [
    .target(
        name: "Foundation",
        dependencies: [
            .product(name: "OpenTelemetryApi", package: "opentelemetry-swift"),
            .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift"),
            .product(name: "OtlpHttpMetricExporter", package: "opentelemetry-swift"),
            .product(name: "OtlpHttpTraceExporter", package: "opentelemetry-swift"),
        ]
    )
]
```

### 3. Initialize Telemetry in App

In `App-Main/NestoryApp.swift`:

```swift
import Foundation
import TelemetryBootstrap

@main
struct NestoryApp: App {
    init() {
        #if DEBUG
        TelemetryBootstrap.start(
            serviceName: "nestory-ios",
            otlpEndpoint: URL(string: "http://localhost:4318")!,
            environment: "dev"
        )
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 4. Replace Networking with Instrumented Client

Replace existing HTTP calls with `InstrumentedHTTPClient`:

```swift
// Old way
let (data, _) = try await URLSession.shared.data(for: request)

// New way (with automatic telemetry)
let (data, _) = try await InstrumentedHTTPClient.shared.data(for: request)
```

### 5. Add User Action Tracking

In SwiftUI views:

```swift
import TelemetryBootstrap

struct InventoryView: View {
    var body: some View {
        NavigationView {
            // ... your UI
        }
        .onAppear {
            TelemetryBootstrap.recordScreenView(screenName: "inventory")
        }
    }
    
    func addItem() {
        TelemetryBootstrap.recordUserAction(action: "add_item", screen: "inventory")
        // ... add item logic
    }
}
```

## 📊 Available Metrics

The iOS telemetry system will automatically collect:

### App Lifecycle
- `ios_app_launches_total` - App launch counter
- `ios_foreground_time_seconds_total` - Time spent in foreground
- `ios_screen_views_total` - Screen/view transitions
- `ios_user_actions_total` - User interaction events

### Network Performance  
- `ios_http_request_duration_ms` - Request latency histogram
- `ios_api_errors_total` - API failure counter
- `ios_http_requests_active` - In-flight requests gauge

### Device & Performance
- `ios_device_battery_level_percent` - Battery level
- `ios_app_memory_usage_bytes` - Memory consumption
- `ios_cpu_time_seconds_total` - CPU usage (MetricKit)

### Diagnostics (MetricKit)
- `ios_diagnostics_total` - Crashes, hangs, CPU exceptions
- `ios_memory_peak_bytes` - Peak memory usage

## 🎯 Dashboard Access

- **iOS Telemetry Dashboard**: http://localhost:3000/d/nry-ios-telemetry/
- **Grafana Main**: http://localhost:3000 (admin/nestory123)
- **Prometheus**: http://localhost:9090
- **Traces**: http://localhost:3000/explore (select Tempo)

## 🔧 Development Workflow

### Local Development
```bash
# Start telemetry stack
cd monitoring && ./start-ios-telemetry.sh

# Run iOS app (automatically sends telemetry to localhost:4318)
make run

# View real-time metrics in Grafana
open http://localhost:3000/d/nry-ios-telemetry/
```

### Production Deployment
For production, update the OTLP endpoint to your production collector:

```swift
#if DEBUG
    let otlpEndpoint = URL(string: "http://localhost:4318")!
#else
    let otlpEndpoint = URL(string: "https://telemetry.your-domain.com")!
#endif

TelemetryBootstrap.start(
    serviceName: "nestory-ios",
    otlpEndpoint: otlpEndpoint,
    environment: "prod"
)
```

## 📱 Mobile-Specific Considerations

### Battery Optimization
- Metrics exported every 30 seconds (configurable)
- Uses compression and batching
- Only enabled in DEBUG/TestFlight by default

### Privacy & Compliance
- No PII in metric labels
- Device identifiers use `identifierForVendor` (App-scoped)
- User consent can gate telemetry in production

### Network Efficiency
- OTLP/HTTP with compression
- Batch uploading to minimize requests
- Graceful degradation if collector unavailable

## 🔍 Troubleshooting

### No Metrics Appearing
1. Check collector logs: `docker compose -f docker-compose-telemetry.yml logs otel-collector`
2. Verify app is hitting endpoint: Look for HTTP POST to `:4318/v1/metrics`
3. Check Prometheus remote write: `curl http://localhost:9090/api/v1/label/__name__/values`

### Dashboard Shows "No Data"
1. Verify time range (try "Last 5 minutes")
2. Check metric names in Prometheus: `curl http://localhost:9090/api/v1/query?query=ios_app_launches_total`
3. Ensure app telemetry is running (only works in DEBUG builds initially)

### Performance Issues
1. Increase export interval in `TelemetryBootstrap.swift`
2. Reduce metric cardinality (fewer label values)
3. Enable cellular upload guard in production

## 📋 Migration Checklist

- [ ] Add OpenTelemetry packages to `Package.swift`
- [ ] Copy `TelemetryBootstrap.swift` to `Foundation/Telemetry/`
- [ ] Copy `InstrumentedHTTPClient.swift` to `Foundation/Telemetry/`
- [ ] Initialize telemetry in `NestoryApp.swift`
- [ ] Replace HTTP calls with `InstrumentedHTTPClient`
- [ ] Add screen view tracking to major views
- [ ] Add user action tracking to key interactions
- [ ] Start telemetry stack: `./start-ios-telemetry.sh`
- [ ] Verify metrics in dashboard: http://localhost:3000/d/nry-ios-telemetry/
- [ ] Update CI/CD for production collector endpoint

## 🎯 Next Steps

1. **Start Small**: Enable telemetry in DEBUG builds first
2. **Add Key Metrics**: Focus on app launches, screen views, HTTP calls
3. **Test & Validate**: Run app and verify metrics appear in dashboard
4. **Expand Coverage**: Add more user actions and custom metrics
5. **Production Deployment**: Set up production collector and enable for TestFlight
6. **Advanced Features**: Add custom metrics for Nestory-specific features (items added, photos taken, etc.)

This approach gives you production-ready mobile telemetry that actually works with iOS, unlike the current server-side monitoring attempt.