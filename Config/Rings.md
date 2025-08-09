# Deployment Rings

## Overview

Nestory uses a ring-based deployment strategy to progressively roll out changes with increasing confidence.

## Ring Definitions

### Ring 0: Internal Testing
- **Audience:** Development team
- **Environment:** Dev
- **Size:** ~10 users
- **Duration:** Continuous
- **Purpose:** Immediate feedback on new builds
- **Rollback:** Immediate

### Ring 1: Alpha Testing
- **Audience:** Internal stakeholders
- **Environment:** Staging
- **Size:** ~50 users
- **Duration:** 3-5 days
- **Purpose:** Feature validation and bug discovery
- **Rollback:** Within 1 hour

### Ring 2: Beta Testing
- **Audience:** Beta testers via TestFlight
- **Environment:** Staging
- **Size:** ~500 users
- **Duration:** 1 week
- **Purpose:** Performance testing and feedback collection
- **Rollback:** Within 4 hours

### Ring 3: Early Access
- **Audience:** 5% of production users
- **Environment:** Production
- **Size:** ~1,000 users
- **Duration:** 3 days
- **Purpose:** Production validation
- **Rollback:** Within 1 hour

### Ring 4: General Availability
- **Audience:** All users
- **Environment:** Production
- **Size:** All users
- **Duration:** Permanent
- **Purpose:** Full release
- **Rollback:** Via hotfix

## Promotion Criteria

### Ring 0 → Ring 1
- All tests passing
- No critical bugs
- Feature complete

### Ring 1 → Ring 2
- No P0/P1 bugs
- Performance within SLO
- Positive internal feedback

### Ring 2 → Ring 3
- Crash-free rate > 99.8%
- No critical user feedback
- All feature flags verified

### Ring 3 → Ring 4
- No increase in error rates
- Performance metrics stable
- Positive user sentiment

## Rollback Triggers

### Automatic Rollback
- Crash-free rate < 99.5%
- Error rate > 5%
- P95 latency > 2x baseline

### Manual Rollback
- Critical security issue
- Data corruption risk
- Major feature regression
- Negative user feedback spike

## Monitoring

Each ring requires monitoring of:
- Crash-free rate
- Error rates
- Performance metrics (per SPEC.json SLOs)
- User feedback channels
- Feature flag states

## Feature Flags per Ring

| Feature | Ring 0 | Ring 1 | Ring 2 | Ring 3 | Ring 4 |
|---------|--------|--------|--------|--------|--------|
| Core Features | 100% | 100% | 100% | 100% | 100% |
| New Features | 100% | 100% | 50% | 10% | Config |
| Experiments | 100% | 50% | 10% | 5% | Config |
| Debug Menu | Yes | Yes | Yes | No | No |

## Emergency Procedures

### Hotfix Process
1. Identify critical issue
2. Create fix on hotfix branch
3. Run guard suite
4. Deploy directly to affected ring
5. Monitor for 1 hour
6. Promote or rollback

### Communication
- Ring 0-1: Slack notification
- Ring 2: TestFlight notes
- Ring 3-4: In-app notification + status page