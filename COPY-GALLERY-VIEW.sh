#!/bin/bash
# Run this once to add "Upload from photo library" to Admin Gallery:
cp "$(dirname "$0")/AdminGalleryView-NEW.swift" "$(dirname "$0")/jitterbug-ios/Jitterbug80s/Jitterbug80s/Views/Admin/AdminGalleryView.swift"
echo "Done. AdminGalleryView.swift now includes the photo picker."
