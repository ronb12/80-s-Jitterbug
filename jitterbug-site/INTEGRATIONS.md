# GitHub, Vercel, and Neon — how they connect (and where it shows)

This project uses a **chain**, not one “everything connected” screen:

```
GitHub (code)  ──Git Integration──►  Vercel (build + host)  ──DATABASE_URL──►  Neon (Postgres)
```

- **GitHub never connects to Neon.** There is no GitHub ↔ Neon link to show in either dashboard for this app.
- **Neon does not clone your repo.** It only receives SQL connections from whatever has the connection string (your Vercel deployment).

So it is **normal** that Neon’s UI does **not** list “GitHub” or “Vercel” unless you add an **integration** (below).

---

## Where each connection *does* show

### 1. GitHub ↔ Vercel (source control → deploys)

| Where | What you should see |
|--------|---------------------|
| **Vercel** → your project **`jitterbug-site`** → **Settings** → **Git** | **Connected Git Repository** = `ronb12/80-s-Jitterbug` (or your fork), production branch **`main`**. |
| **Vercel** → **Deployments** → open a deployment → **Build Logs** | Line like **Cloning `github.com/ronb12/80-s-Jitterbug`**. |
| **GitHub** → repo → **Settings** → **Integrations** (optional) | May list **Vercel** if the app was installed on the org/account. |

If Git isn’t connected: **Vercel** → **Add New** → **Project** → **Import** the GitHub repo (or **Settings → Git → Disconnect** / reconnect).

---

### 2. Vercel ↔ Neon (runtime database)

The app talks to Neon **only** through **`DATABASE_URL`**. That *is* the Vercel–Neon link, even when the UI doesn’t say “Neon” in big letters.

| Where | What you should see |
|--------|---------------------|
| **Vercel** → **`jitterbug-site`** → **Settings** → **Environment Variables** | **`DATABASE_URL`** for **Production** (and **Preview** if you use it). Value is hidden; it should be your Neon **pooled** URL (`…neon.tech…`, often `pooler` in the host). |
| **Local** | Same variable in **`jitterbug-site/.env.local`** (not committed). |

**Quick CLI check** (from `jitterbug-site/`):

```bash
npx vercel env ls production
# Look for DATABASE_URL — that is your Neon connection on Vercel.
```

---

### 3. Neon dashboard (project only, unless you add Integrations)

| Where | What you see |
|--------|----------------|
| **[Neon Console](https://console.neon.tech)** → project **`jitterbug-site`** | Branches, roles, SQL Editor — your database. **No GitHub repo name** here by default. |
| **Neon** → **Integrations** (if you use them) | Can show **Vercel** after you link — see next section. |

---

## Want a *visible* “Vercel + Neon” link in the dashboards?

You already work if **`DATABASE_URL`** is set. To get **branded** linking and optional preview branches:

### Option A — From Neon (Neon-managed)

1. Open **[Neon docs: Neon–Vercel integration](https://neon.tech/docs/guides/vercel-connection-methods)** (or Console → **Integrations** → **Vercel**).
2. Connect your Neon account to Vercel and choose **this** Neon project + **this** Vercel project (`jitterbug-site`).
3. Neon can then inject / sync env vars (e.g. `DATABASE_URL`) and show the link in Neon’s integration UI.

### Option B — From Vercel (Vercel-managed / Marketplace)

1. **Vercel** → **Project** → **Integrations** → search **Neon** → install per [Vercel-managed integration](https://neon.tech/docs/guides/vercel-managed-integration).
2. Follow the wizard to attach a database to **`jitterbug-site`**.

**Note:** If you already set **`DATABASE_URL` manually**, adding the integration may add **duplicate** or **overlapping** variables — align with one source of truth (integration vs manual) so you don’t break deploys.

---

## One-page checklist for *this* repo

| Check | How |
|--------|-----|
| GitHub → Vercel | Vercel **Settings → Git** shows repo; build logs show **git clone**. |
| Vercel → Neon | Vercel **Environment Variables** has **`DATABASE_URL`**; value points at **Neon** (`*.neon.tech`). |
| Schema on Neon | From `jitterbug-site/`: `npm run db:push` then `npm run db:verify` with `DATABASE_URL` set. |
| GitHub → Neon | **Not applicable** — no direct product link. |

---

## Repo reference

- **Neon project id / CLI:** **`NEON-PROJECT.md`**
- **Vercel env, Stripe, webhooks:** **`VERCEL.md`**
- **Monorepo root vs `jitterbug-site` on Vercel:** **`../VERCEL-ROOT.md`**
