# 🔐 macOS Permissions Guide for Xcode Error Tracking

## Critical Permission Issues Found

### ❌ MAJOR ISSUE: Wrong DerivedData Path
**Problem**: Our monitoring scripts look for build logs in the standard location:
- `~/Library/Developer/Xcode/DerivedData` (doesn't exist)

**Reality**: This project uses a custom DerivedData path:
- `/Users/griffin/Projects/Nestory/.build` (actual location)

### 🔧 Required Fixes

#### 1. Update Monitor Script Path
The build monitor must use the project's custom DerivedData path instead of the system default.

#### 2. Verify Terminal Permissions
```bash
# Check if Terminal has necessary permissions
sqlite3 /var/db/SystemPolicyConfiguration/ExecPolicy \
  'SELECT client, client_type, allowed FROM access WHERE service="kTCCServiceSystemPolicyAllFiles"'
```

#### 3. Grant Required macOS Permissions

**Full Disk Access** (if needed for system logs):
1. Open System Preferences → Security & Privacy → Privacy
2. Select "Full Disk Access" 
3. Add Terminal.app if monitoring system Xcode logs

**Developer Tools Access**:
- Already granted (we can access project files)

**Network Access**:
- ✅ Verified working (can reach Pushgateway/Prometheus)

**Launch Agent Permissions**:
- ✅ Agent is loaded and running

### 🟢 What's Working Without Issues

✅ **Database Access**: SQLite database creation and access works
✅ **Network Connectivity**: Pushgateway and Prometheus accessible  
✅ **Launch Agent**: Background service is loaded and running
✅ **File System**: Basic file operations work
✅ **Project Files**: Can access all project directories

### 🟡 Permission Verification Commands

```bash
# Test database access
sqlite3 /Users/griffin/Projects/Nestory/monitoring/build-errors.db ".tables"

# Test network access
curl -s http://localhost:9091/metrics | head -1

# Check launch agent status
launchctl list | grep nestory

# Test file monitoring
touch /tmp/test && find /tmp -name "test" -newer /tmp/test
```

### 🎯 Critical Fix Needed

**Primary Issue**: Build monitoring is looking in wrong directory
- **Expected**: `~/Library/Developer/Xcode/DerivedData`
- **Actual**: `/Users/griffin/Projects/Nestory/.build`

**Impact**: 
- Build logs are not being captured
- Error monitoring is not working for actual builds
- Only manually pushed test metrics appear in dashboard

**Solution**: Update monitoring scripts to use correct DerivedData path

## Action Items

1. **Fix DerivedData Path** - Update monitor to use `.build` directory
2. **Verify Log Access** - Test access to actual build logs
3. **Update Documentation** - Reflect correct paths in all scripts
4. **Test Integration** - Verify end-to-end error capture works

## Permission Status Summary

| Component | Status | Notes |
|-----------|---------|-------|
| Database Access | ✅ Working | SQLite operations successful |
| Network Access | ✅ Working | Pushgateway/Prometheus accessible |
| Launch Agent | ✅ Running | Background service active |
| File System | ✅ Working | Basic file operations work |
| Project Files | ✅ Working | All project directories accessible |
| DerivedData Path | ❌ WRONG | Using system path, not project path |
| Build Log Access | ❌ BLOCKED | Wrong path prevents log monitoring |

## Next Steps

The permissions are largely correct, but the **critical issue is the incorrect DerivedData path**. This explains why the error tracking appears to work but doesn't capture actual build errors.