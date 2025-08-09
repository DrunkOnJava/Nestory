# Observability

## Metrics Collection

The Nestory application collects the following metrics as defined in `SPEC.json`:

### Performance Metrics
- **Cold Start Time** - P95 target: 1800ms
- **Database Read Latency** - P50/P95 target: 250ms
- **Scroll Jank** - Maximum: 3%

### Reliability Metrics
- **Crash-Free Rate** - Minimum: 99.8%
- **API Success Rate**
- **Sync Failure Rate**

## Monitoring Infrastructure

### Local Development
- Xcode Instruments for performance profiling
- Memory Graph Debugger for leak detection
- Network Link Conditioner for testing

### Production
- CloudKit Dashboard for sync metrics
- App Store Connect for crash reports
- TestFlight for beta feedback

## Alert Thresholds

Based on SLO definitions in SPEC.json:

| Metric | Warning | Critical |
|--------|---------|----------|
| Cold Start P95 | > 1500ms | > 1800ms |
| DB Read P95 | > 200ms | > 250ms |
| Scroll Jank | > 2% | > 3% |
| Crash-Free Rate | < 99.9% | < 99.8% |

## Dashboards

### Developer Dashboard
- Real-time performance metrics
- Architecture violation trends
- Test coverage over time
- Build success rate

### Business Dashboard
- User engagement metrics
- Feature adoption rates
- Sync success rates
- Error rates by feature

## Logging Standards

### Log Levels
- **DEBUG** - Detailed diagnostic information
- **INFO** - General informational messages
- **WARNING** - Warning messages for recoverable issues
- **ERROR** - Error messages for failures
- **CRITICAL** - Critical failures requiring immediate attention

### Structured Logging Format
```swift
Logger.log(
    level: .info,
    category: "FeatureName",
    message: "Action completed",
    metadata: ["userId": userId, "duration": duration]
)
```

## Incident Response

### Runbook References
- [Cold Start Degradation](runbooks/cold-start.md)
- [Database Performance](runbooks/db-performance.md)
- [Sync Failures](runbooks/sync-failures.md)
- [Crash Spike](runbooks/crash-spike.md)

## Privacy Considerations

- No PII in logs or metrics
- User IDs are hashed
- Opt-out mechanism provided
- GDPR compliance maintained