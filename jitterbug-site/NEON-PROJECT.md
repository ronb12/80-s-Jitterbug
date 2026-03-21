# Neon project (80’s Jitterbug site)

Non-secret reference for the Postgres database used by this app.

| Field | Value |
|--------|--------|
| **Project name** | `jitterbug-site` |
| **Project ID** | `damp-recipe-66531337` |
| **Region** | `aws-us-east-1` |
| **Postgres** | 17 |
| **Database** | `neondb` |
| **Role** | `neondb_owner` (use **`--role-name neondb_owner`** with the CLI if prompted) |

## Connection string (pooled — use for Vercel / serverless)

From **`jitterbug-site/`** after `npx neonctl auth`:

```bash
npx neonctl connection-string --pooled --role-name neondb_owner --project-id damp-recipe-66531337
```

Set the output as **`DATABASE_URL`** in `.env.local` and in Vercel (see **`VERCEL.md`**).

## Schema

After creating the project, apply tables once (with `DATABASE_URL` set):

```bash
npm run db:push
npm run db:verify
```

## Security

If database credentials were ever copied from logs or chat, **reset the role password** in the [Neon Console](https://console.neon.tech) → project → **Roles** → `neondb_owner` → reset password, then update **`DATABASE_URL`** everywhere.
