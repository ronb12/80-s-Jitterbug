# Build secrets (ImgBB gallery uploads)

The app reads the ImgBB API key in this order:

1. Environment variable **`IMGBB_API_KEY`** (e.g. in the Xcode scheme **Run → Arguments → Environment Variables**).
2. **`ImgbbApiKey`** in the generated Info.plist, populated from the Xcode **User-Defined** build setting **`IMGBB_API_KEY`** (`INFOPLIST_KEY_ImgbbApiKey = "$(IMGBB_API_KEY)"`).

## Local setup

1. Open **Jitterbug80s.xcodeproj** in Xcode.
2. Select the project → **Build Settings** → search **User-Defined** (or add a row).
3. Add **`IMGBB_API_KEY`** with your key from [api.imgbb.com](https://api.imgbb.com/) for targets **Jitterbug80s** and **Jitterbug80sMac** (or set it at the **project** level so both inherit).

**Do not commit API keys.** The repo defaults `IMGBB_API_KEY` to empty so nothing sensitive is in git.

## CI / Archive

Inject `IMGBB_API_KEY` via your CI secret store and pass it as an `xcodebuild` build setting, for example:

```bash
xcodebuild -scheme Jitterbug80sMac -configuration Release \
  IMGBB_API_KEY="$(printf '%s' "$IMGBB_API_KEY")" \
  archive ...
```

Gallery uploads will fail at runtime until a non-empty key is provided by one of the methods above.
