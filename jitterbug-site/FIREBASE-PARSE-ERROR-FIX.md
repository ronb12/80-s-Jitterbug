# Fix: "Parse Error in firebase.json"

This usually happens when the **project path contains an apostrophe** (`80's Jitterbug`). Firebase CLI can get a broken path and fail to parse the file.

## Fix 1: Run from a path WITHOUT an apostrophe (recommended)

1. **Rename the folder** (in Finder): `80's Jitterbug` → `80s-Jitterbug`
2. In Terminal:
   ```bash
   cd ~/Desktop/80s-Jitterbug/jitterbug-site
   firebase deploy --only hosting
   ```

If you already have a copy at `80s-Jitterbug`, use that folder instead.

---

## Fix 2: Replace firebase.json with clean content

If the error persists (or you see "Unexpected token"), the file may be corrupted. Replace **all** of `jitterbug-site/firebase.json` with this (no comments, no trailing commas):

```json
{
  "firestore": {
    "rules": "firestore.rules"
  },
  "functions": {
    "source": "functions",
    "predeploy": ["npm --prefix $RESOURCE_DIR run build"]
  },
  "hosting": {
    "public": "out",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "trailingSlash": true
  }
}
```

Save as UTF-8 (no BOM). Then run `firebase deploy --only hosting` from **80s-Jitterbug** (path without apostrophe).

---

## One-line version (paste into terminal to overwrite)

Run from **80s-Jitterbug/jitterbug-site** (not from 80's Jitterbug):

```bash
cd ~/Desktop/80s-Jitterbug/jitterbug-site
printf '%s\n' '{' '  "firestore": {"rules": "firestore.rules"},' '  "functions": {"source": "functions","predeploy": ["npm --prefix \$RESOURCE_DIR run build"]},' '  "hosting": {"public": "out","ignore": ["firebase.json","**/.*","**/node_modules/**"],"trailingSlash": true}' '}' > firebase.json
```

Then: `firebase deploy --only hosting`
