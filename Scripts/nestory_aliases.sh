#!/bin/bash
# Nestory development aliases
# Source this file in your shell profile: source Scripts/nestory_aliases.sh

NESTORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Quick commands
alias nb="$NESTORY_ROOT/Scripts/quick_build.sh"
alias nt="$NESTORY_ROOT/Scripts/quick_test.sh" 
alias ndc="$NESTORY_ROOT/Scripts/dev_cycle.sh"
alias nrun="$NESTORY_ROOT/Scripts/run_simulator_automation.sh"

# Xcode shortcuts
alias nxcode="open $NESTORY_ROOT/Nestory.xcodeproj"
alias nclean="rm -rf $NESTORY_ROOT/build && echo 'Build cache cleared'"
alias nsim="open -a Simulator"

# Development utilities
alias nlog="tail -f $NESTORY_ROOT/optimization.log"
alias nstats="$NESTORY_ROOT/Scripts/dev_stats.sh"

echo "🚀 Nestory development aliases loaded!"
echo "Available commands: nb, nt, ndc, nrun, nxcode, nclean, nsim, nlog, nstats"
