#!/bin/bash
# Sync Jitterbug80s app and project from repo to ~/Developer/80s-Jitterbug-ios
# Run from repo: ./sync-to-developer.sh
# So that building from Xcode in Developer shows all changes.

set -e
REPO="$(cd "$(dirname "$0")" && pwd)"
DEV="$HOME/Developer/80s-Jitterbug-ios/Jitterbug80s"

if [[ ! -d "$DEV" ]]; then
  echo "Developer folder not found: $DEV"
  exit 1
fi

echo "Syncing $REPO -> $DEV"

# App source and project
cp -R "$REPO/Jitterbug80s/"* "$DEV/Jitterbug80s/" 2>/dev/null || true
cp "$REPO/Jitterbug80s.xcodeproj/project.pbxproj" "$DEV/Jitterbug80s.xcodeproj/project.pbxproj"

echo "Done. Open $HOME/Developer/80s-Jitterbug-ios/Jitterbug80s/Jitterbug80s.xcodeproj and build."
echo "In Xcode: Product → Clean Build Folder (Shift+Cmd+K), then Build (Cmd+B)."
