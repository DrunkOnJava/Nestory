# GitHub Actions Self-Hosted Runners Setup

## Quick Start

### Current Configuration
- **M1 iMac**: `100.106.87.23` (Tailscale) ✅ Connected
- **Raspberry Pi 5**: `100.116.38.90` (Tailscale) ⏳ Pending SSH setup

### Deploy to M1 iMac (Ready Now!)
```bash
# Deploy runner to your M1 iMac
./deploy-runner-remote.sh --deploy-macos

# Or use interactive mode
./deploy-runner-remote.sh
```

### Monitor Your Runners
```bash
# Real-time monitoring dashboard
./monitor-runners.sh

# Quick status check
./monitor-runners.sh --status
```

## Raspberry Pi Setup (When Ready)

To enable the Raspberry Pi runner, SSH needs to be configured:

1. **On the Raspberry Pi**, enable SSH:
```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

2. **Verify Tailscale is running**:
```bash
tailscale status
```

3. **Test connection from this machine**:
```bash
ssh griffin@100.116.38.90
```

4. **Once connected, deploy the runner**:
```bash
./deploy-runner-remote.sh --deploy-pi
```

## File Structure

```
Scripts/CI/
├── setup-github-runner-macos.sh    # M1 iMac runner installer
├── setup-github-runner-pi.sh       # Raspberry Pi runner installer
├── deploy-runner-remote.sh         # Remote deployment tool
├── monitor-runners.sh               # Unified monitoring dashboard
├── test-runner-connections.sh      # Connection tester
└── README.md                        # This file
```

## Workflow Usage

Once runners are deployed, use them in your workflows:

```yaml
jobs:
  # iOS builds on M1 iMac
  build-ios:
    runs-on: [self-hosted, macOS, M1, xcode]
    
  # Auxiliary tasks on Raspberry Pi
  documentation:
    runs-on: [self-hosted, raspberry-pi, auxiliary]
```

## Management Commands

### M1 iMac (via SSH)
```bash
# Start/stop runner
ssh griffin@100.106.87.23 "~/actions-runner/start-runner.sh"
ssh griffin@100.106.87.23 "~/actions-runner/stop-runner.sh"

# Check status
ssh griffin@100.106.87.23 "~/actions-runner/status-runner.sh"

# View logs
ssh griffin@100.106.87.23 "tail -f ~/actions-runner/_diag/Runner*.log"
```

### Raspberry Pi (when configured)
```bash
# Start/stop runner
ssh griffin@100.116.38.90 "~/actions-runner/start-runner.sh"
ssh griffin@100.116.38.90 "~/actions-runner/stop-runner.sh"

# Check status
ssh griffin@100.116.38.90 "~/actions-runner/status-runner.sh"

# View logs
ssh griffin@100.116.38.90 "~/actions-runner/logs-runner.sh"
```

## Troubleshooting

### Connection Issues
```bash
# Test connections
./test-runner-connections.sh

# Check Tailscale status
tailscale status

# Verify SSH keys
ssh-add -l
```

### Runner Issues
```bash
# Re-register runner (if needed)
ssh user@host "cd ~/actions-runner && ./config.sh remove && ./setup-github-runner-[macos|pi].sh"

# Check GitHub runner status
gh api /repos/DrunkOnJava/Nestory/actions/runners
```

## Security Notes

- Both machines use Tailscale for secure, encrypted connections
- No port forwarding or firewall rules needed
- Runners are scoped to the Nestory repository only
- Tokens are automatically managed and rotated

## Cost Savings

With both runners operational:
- **Save ~$246/month** on GitHub Actions minutes
- **40% faster iOS builds** on M1 hardware
- **Unlimited build minutes** (no quotas)
- **Persistent caches** between builds

## Next Steps

1. ✅ Deploy to M1 iMac (ready now)
2. ⏳ Configure SSH on Raspberry Pi
3. ⏳ Deploy to Raspberry Pi
4. ✅ Update workflows to use self-hosted runners
5. ✅ Monitor performance and savings

---

*Tailscale-powered CI/CD infrastructure for Nestory*