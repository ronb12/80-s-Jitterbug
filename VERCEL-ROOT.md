# Vercel + this monorepo

If Vercel shows **“No Next.js version detected”**, it’s because the **Next.js app** lives in **`jitterbug-site/`**, not at the Git repo root.

## Option A — Recommended (dashboard)

**Vercel → Project → Settings → General → Root Directory** → set to **`jitterbug-site`**, then redeploy.

With this, Vercel uses `jitterbug-site/package.json` and you can remove or ignore the repo-root `vercel.json` / `package.json` if you prefer.

## Option B — Repo root deploy (no Root Directory change)

This repo includes a **root `vercel.json`** that runs:

- `cd jitterbug-site && npm ci`
- `cd jitterbug-site && npm run build`
- **`outputDirectory`: `jitterbug-site/.next`** — so Vercel finds `routes-manifest.json` and the rest of the Next output (without this, Vercel looks for `.next` at the repo root and the deploy fails).

and a **root `package.json`** that lists `next` so framework detection succeeds when the project root is the **repository** root.

There is **no** `package-lock.json` at the repo root (it’s gitignored on purpose) so Next.js doesn’t warn about multiple lockfiles; installs use **`jitterbug-site/package-lock.json`** via `installCommand`.

**Dashboard:** If you set **Output Directory** manually in Vercel, clear it or set it to **`jitterbug-site/.next`** so it matches this repo (a bare `.next` at the repo root is wrong).

Redeploy after pulling these files.

## Option C — Link CLI from the app folder

```bash
cd jitterbug-site
npx vercel link
npx vercel --prod
```

That links the Vercel project to `jitterbug-site/` directly.
