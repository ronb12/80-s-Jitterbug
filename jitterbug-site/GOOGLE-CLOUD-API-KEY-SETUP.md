# Google Cloud / Firebase API key restrictions

Firebase **client** API keys are meant to ship in apps and websites. Google Cloud still warns when a key has **no application restrictions** (any site or any app could try to use it). Restrictions **do not replace** Firestore Security Rules or App Check—they only limit where the key can be called from.

## What’s configured (project `jitterbug80s`)

Applied via `gcloud` (March 2026):

### Browser key (web / `NEXT_PUBLIC_FIREBASE_API_KEY`)

**HTTP referrer** allowlist:

| Referrer | Purpose |
|----------|---------|
| `https://jitterbug80s.web.app/*` | Firebase Hosting default |
| `https://jitterbug80s.firebaseapp.com/*` | Alternate Hosting URL |
| `https://80sjitterbug.com/*` | Canonical site (from `NEXT_PUBLIC_SITE_URL` fallback) |
| `https://www.80sjitterbug.com/*` | Common `www` variant |
| `http://localhost:3000/*` | Local Next.js dev |
| `http://127.0.0.1:3000/*` | Local dev |

**API restrictions** were left as Firebase already set them (Firestore, Auth, etc.).

### iOS key (`GoogleService-Info.plist` → `API_KEY`)

**iOS bundle IDs:**

- `com.bradleyvirtualsolutions.Jitterbug80s`

## Add another domain or preview host

If you deploy previews (e.g. Vercel) or a new custom domain, add its referrer to the **Browser** key.

**Google Cloud Console:**  
[APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials?project=jitterbug80s) → **Browser key (auto created by Firebase)** → **Application restrictions** → **HTTP referrers** → add e.g. `https://your-preview.vercel.app/*`.

**gcloud** (replace `KEY_UID` with `73f1a4f0-6102-4386-aa0c-74d2c5129535` if still the browser key):

```bash
gcloud services api-keys update \
  projects/908905736157/locations/global/keys/73f1a4f0-6102-4386-aa0c-74d2c5129535 \
  --allowed-referrers="https://jitterbug80s.web.app/*,https://jitterbug80s.firebaseapp.com/*,https://80sjitterbug.com/*,https://www.80sjitterbug.com/*,http://localhost:3000/*,http://127.0.0.1:3000/*,https://YOUR-NEW-DOMAIN/*" \
  --project=jitterbug80s
```

You must include **every** referrer you need in one comma-separated list (the update replaces the referrer list).

## Add another iOS app / bundle ID

```bash
gcloud services api-keys update \
  projects/908905736157/locations/global/keys/1e6408be-92cd-4e5d-9bb7-315788cbab60 \
  --allowed-bundle-ids=com.bradleyvirtualsolutions.Jitterbug80s,com.example.NewApp \
  --project=jitterbug80s
```

## If Firebase returns `API_KEY_INVALID` / `API_KEY_SERVICE_BLOCKED`

- **Web:** Your current origin must match one of the allowed referrers (scheme, host, port).
- **iOS:** The running app’s bundle ID must be in **allowed bundle IDs**.
- See Firebase: [API keys](https://firebase.google.com/docs/projects/api-keys) (required APIs table).

## Key UIDs (for this project)

| Key | UID |
|-----|-----|
| Browser key (auto created by Firebase) | `73f1a4f0-6102-4386-aa0c-74d2c5129535` |
| iOS key (auto created by Firebase) | `1e6408be-92cd-4e5d-9bb7-315788cbab60` |

Requires `gcloud` and permission to edit API keys on project `jitterbug80s`.
