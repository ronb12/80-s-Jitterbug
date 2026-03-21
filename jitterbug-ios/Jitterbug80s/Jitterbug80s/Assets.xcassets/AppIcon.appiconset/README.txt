App Store requires a 1024×1024 px app icon (no transparency, PNG or JPEG).

1. Create or export a 1024×1024 image (e.g. your logo or "80's Jitterbug" branding).
2. Name it exactly: AppIcon-1024.png
3. Place it in this folder (AppIcon.appiconset) next to Contents.json.
4. In Xcode, the AppIcon asset will show the icon; build and archive for submission.

If you only provide this single 1024×1024 image, Xcode can generate other sizes for the app. For macOS/visionOS, add matching icons to the mac/tinted/dark slots if you ship on those platforms.
