# Firestore LevelDB lock on macOS (`LOCK: Resource temporarily unavailable`)

## What it means

Firestore’s **on-disk cache** (LevelDB) lives under your app’s **container**. Only **one process** should open it at a time. If two copies run (common: **Xcode Run** + **double-click the .app**), or a **stale `LOCK` file** remains after a crash, Firestore can throw and the app terminates.

## Fixes (try in order)

1. **Quit every instance** — Dock, Xcode stop, Activity Monitor → search `Jitterbug`.
2. **Rebuild / run once** — avoid running the **installed app** and **Xcode** at the same time.
3. **Delete the local Firestore folder** (sign in again; cache repopulates):
   ```text
   ~/Library/Containers/com.bradleyvirtualsolutions.Jitterbug80s/Data/Library/Application Support/firestore/
   ```
   Remove the whole `firestore` folder (or only the `jitterbug80s` subfolder under `__FIRAPP_DEFAULT`).
4. **Restart the Mac** if a lock still won’t clear.

## Code change

`FirebaseManager` configures Firestore with **`MemoryCacheSettings()` on macOS only** so the SDK does **not** use that LevelDB path on native Mac, which avoids this class of crash. **iOS** still uses the default persistent cache.
