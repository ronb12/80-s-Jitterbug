#!/usr/bin/env bash
# Run crash test (build + UI tests) for 80's Jitterbug iOS app.
# Usage: ./run-crash-test.sh
# Or from repo root: jitterbug-ios/Jitterbug80s/run-crash-test.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Prefer booted iPhone simulator; otherwise use first available iPhone
DEST=""
if xcrun simctl list devices | grep -q "Booted"; then
  DEST=$(xcrun simctl list devices | grep "Booted" | grep -o '[A-F0-9-]\{36\}' | head -1)
fi
if [ -z "$DEST" ]; then
  DEST=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -o '[A-F0-9-]\{36\}' | head -1)
fi
if [ -z "$DEST" ]; then
  echo "No iOS simulator found. Open Simulator and boot a device."
  exit 1
fi

echo "Using simulator: $DEST"
echo "Building..."
xcodebuild -scheme Jitterbug80s -destination "id=$DEST" -quiet build

echo "Running crash test (launch + main flows)..."
xcodebuild -scheme Jitterbug80s -destination "id=$DEST" \
  -only-testing:Jitterbug80sUITests/Jitterbug80sUITestsLaunchTests/testLaunch \
  -only-testing:Jitterbug80sUITests/testCrashTestMainFlows \
  test 2>&1 | tee /tmp/jitterbug-crash-test.log
RESULT=${PIPESTATUS[0]}

if [ "$RESULT" -eq 0 ]; then
  echo "Crash test PASSED: app launched and main flows did not crash."
else
  echo "Crash test FAILED (exit $RESULT). See /tmp/jitterbug-crash-test.log"
  exit 1
fi
