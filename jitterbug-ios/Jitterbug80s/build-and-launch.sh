#!/usr/bin/env bash
# Build 80's Jitterbug and launch in the open (booted) simulator.
# Usage: ./build-and-launch.sh
# If no simulator is booted, boots "iPhone 16" and opens Simulator.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
DERIVED=/tmp/Jitterbug80sBuild
BUNDLE_ID=com.bradleyvirtualsolutions.Jitterbug80s

# Ensure a simulator is booted
BOOTED=$(xcrun simctl list devices | grep "(Booted)" | head -1)
if [ -z "$BOOTED" ]; then
  echo "Booting iPhone 16 simulator..."
  xcrun simctl boot "iPhone 16" 2>/dev/null || true
  open -a Simulator 2>/dev/null || true
  sleep 5
fi
DEST=$(xcrun simctl list devices | grep "(Booted)" | head -1 | grep -oE '[A-F0-9-]{36}')
if [ -z "$DEST" ]; then
  DEST="8925993A-E3CC-47C5-A9A2-9876C496AD28"
fi

echo "Building for simulator $DEST..."
xcodebuild -scheme Jitterbug80s \
  -destination "platform=iOS Simulator,id=$DEST" \
  -derivedDataPath "$DERIVED" \
  -quiet build

APP="$DERIVED/Build/Products/Debug-iphonesimulator/Jitterbug80s.app"
if [ ! -d "$APP" ]; then
  echo "Build failed: $APP not found"
  exit 1
fi

echo "Installing and launching..."
xcrun simctl install booted "$APP"
xcrun simctl launch booted "$BUNDLE_ID"
echo "Launched 80's Jitterbug on simulator."
