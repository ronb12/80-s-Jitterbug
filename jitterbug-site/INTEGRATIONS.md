# GitHub ↔ Vercel ↔ Neon

How the three services connect for this app:

| Piece | What it does |
|--------|----------------|
| **GitHub** | Hosts the repo (`ronb12/80-s-Jitterbug`). Pushes to **`main`** trigger Vercel builds when Git Integration is enabled. |
| **Vercel** | Clones the repo, runs install/build (see repo-root **`vercel.json`** / **Root Directory** in **`VERCEL-ROOT.md`**), runs the Next.js app. |
| **Neon** | Postgres database. **Nothing talks to Neon except your app**, using **`DATABASE_URL`** at runtime (on Vercel and in **`.env.local`** locally). GitHub does not connect to Neon. |

## What “connected” means

1. **GitHub → Vercel:** Vercel project is linked to the GitHub repo so each push deploys. Check **Vercel → Project → Settings → Git** (repo + production branch).
2. **Vercel → Neon:** **`DATABASE_URL`** (pooled Neon URL) is set for **Production** (and Preview if you use it). The API routes and server code use it via `process.env.DATABASE_URL`.

## Re-check from your machine

```bash
# Git remote
git remote -v
# expect: github.com/ronb12/80-s-Jitterbug.git

# Vercel env (from jitterbug-site/)
cd jitterbug-site
npx vercel env ls production
# expect: DATABASE_URL listed (value shown as Encrypted)

# Neon project (after npx neonctl auth)
npx neonctl projects list
# expect: jitterbug-site (see NEON-PROJECT.md for project id)
```

Production deploy logs (**Vercel → Deployments → a deployment → Build**) should show cloning **`github.com/ronb12/80-s-Jitterbug`**.

## Optional: Vercel Neon integration

**Vercel → Project → Integrations → Neon** can manage DB provisioning and env sync. It is **not required** if **`DATABASE_URL`** is already set (e.g. **`npm run vercel:push-env`** / **`vercel:push-env:partial`**).

## Related docs

- **`NEON-PROJECT.md`** — Neon project id, CLI connection string  
- **`VERCEL.md`** — env vars, webhooks, Stripe  
- **`../VERCEL-ROOT.md`** — monorepo root vs `jitterbug-site` Root Directory  
