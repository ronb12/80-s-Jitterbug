# Fix for "Operation timed out" when building

The project was hitting **Operation timed out** when opening Swift (and other) files during build and copy. This is usually caused by the project living in an **iCloud-synced folder** (e.g. Desktop or Documents).

## What was done

- The project folder was **renamed** from `80's Jitterbug` to **`80's Jitterbug.nosync`** on Desktop.  
  The `.nosync` suffix tells iCloud to **not sync** this folder, so files stay local and should stop timing out.

## If timeouts continue

1. **Re-open the project in Cursor**  
   Open the folder: `~/Desktop/80's Jitterbug.nosync`  
   (File → Open Folder, or reopen from recent.)

2. **Build from Xcode**  
   Open `jitterbug-ios/Jitterbug80s/Jitterbug80s.xcodeproj` in Xcode and press **⌘R**.  
   Building from Xcode often works even when the command line times out.

3. **Move the project off Desktop (recommended)**  
   - In **Finder**, copy the whole folder `80's Jitterbug.nosync` to a folder that is **not** in iCloud, for example:
     - `~/Developer/80s-Jitterbug`
     - or `~/Projects/80s-Jitterbug`
   - Create `Developer` or `Projects` in your home folder if needed.
   - Open the **copied** project in Xcode/Cursor and build from there.  
   This avoids Desktop/iCloud entirely and is the most reliable fix.

## Summary

- **Current location:** `~/Desktop/80's Jitterbug.nosync`
- **Fix:** `.nosync` already applied; if problems remain, move the project to e.g. `~/Developer/80s-Jitterbug` and work from there.
