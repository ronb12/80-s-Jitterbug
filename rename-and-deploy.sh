#!/bin/bash
# Run this from your DESKTOP so the script isn't inside the folder we're renaming:
#   cd ~/Desktop && bash rename-and-deploy.sh
#
# What it does:
# 1. Renames "80's Jitterbug" to "80s-Jitterbug" (no apostrophe) so npm/Node stop timing out.
# 2. Builds and deploys the site from the new path.
set -e
DESKTOP="$HOME/Desktop"
OLD_PATH="$DESKTOP/80's Jitterbug"
NEW_PATH="$DESKTOP/80s-Jitterbug"
JITTERBUG_SITE="$NEW_PATH/jitterbug-site"

if [ ! -d "$OLD_PATH" ]; then
  echo "Folder not found: $OLD_PATH"
  echo "If you already renamed it, run deploy from the new path:"
  echo "  cd $NEW_PATH/jitterbug-site && npm run build && firebase deploy --only hosting"
  exit 1
fi

if [ -d "$NEW_PATH" ]; then
  echo "Using existing folder: $NEW_PATH"
else
  echo "Renaming folder to remove apostrophe (fixes timeout)..."
  mv "$OLD_PATH" "$NEW_PATH"
  echo "Renamed: $OLD_PATH -> $NEW_PATH"
fi

echo "Building and deploying from $JITTERBUG_SITE ..."
cd "$JITTERBUG_SITE"
npm run build
firebase deploy --only hosting
echo "Deploy complete. Use the folder $NEW_PATH from now on (e.g. open it in Cursor)."
