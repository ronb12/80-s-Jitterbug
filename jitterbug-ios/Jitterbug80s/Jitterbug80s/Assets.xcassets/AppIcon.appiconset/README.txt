App Store requires a 1024×1024 px app icon (no transparency, PNG or JPEG).

1. Create or export a 1024×1024 image (e.g. your logo or "80's Jitterbug" branding).
2. Name it exactly: AppIcon-1024.png
3. Place it in this folder (AppIcon.appiconset) next to Contents.json.
4. In Xcode, the AppIcon asset will show the icon; build and archive for submission.

For **macOS** in this catalog, **AppIcon-512.png** must be exactly **512×512** (Mac 1×); **AppIcon-1024.png** is **1024×1024** for Mac 2× and iOS. After editing the master, run:

  ./generate-app-icons.sh

(or: `sips -z 512 512 AppIcon-1024.png --out AppIcon-512.png` in this folder.)

Commit **both** PNGs — a missing 512 file breaks validation (Xcode may still complain about the 1024 file for the 1× slot).
