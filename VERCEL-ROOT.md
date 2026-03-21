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

- **`installCommand`: `npm ci && cd jitterbug-site && npm ci`** — installs **root** `node_modules` (so `next` exists at the repo root for Vercel’s framework detector), then installs the real app under **`jitterbug-site/`**.

A **root `package-lock.json`** is committed next to the stub **`package.json`** (both list `next`) so the first `npm ci` is deterministic.

**Dashboard:** If you set **Output Directory** manually in Vercel, clear it or set it to **`jitterbug-site/.next`** so it matches this repo (a bare `.next` at the repo root is wrong).

**Framework preset:** If detection still fails, set **Framework Preset** to **Next.js** (Project → Settings → General).

Redeploy after pulling these files.

## Option C — Link CLI from the app folder

```bash
cd jitterbug-site
npx vercel link
npx vercel --prod
```

That links the Vercel project to `jitterbug-site/` directly.
