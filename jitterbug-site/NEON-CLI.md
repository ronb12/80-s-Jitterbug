# Neon CLI — verify schema from the terminal

The app talks to Neon with **`DATABASE_URL`**. You can **confirm tables** either way below.

## Install CLI

```bash
# one-off (no global install)
# or: brew install neonctl
npm install   # adds devDependency `neonctl` in this project
```

## 1. Log in (once)

```bash
cd jitterbug-site
npx neonctl auth
```

## 2. Get a connection string (pooled — matches serverless/Vercel)

```bash
# If the CLI says multiple roles, pick the owner role:
npx neonctl connection-string --pooled --role-name neondb_owner
```

Copy the output into **`.env.local`**:

```bash
DATABASE_URL=postgresql://...
```

Then run the automated readiness check (uses `DATABASE_URL`, not only CLI):

```bash
npm run db:verify
```

## 3. List tables with Neon CLI + `psql`

Requires **`psql`** on your PATH ([install Postgres client](https://www.postgresql.org/download/) or use Neon’s SQL Editor instead).

```bash
cd jitterbug-site
npx neonctl connection-string --pooled --psql -- -c "
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY 1;
"
```

You should see at least:

`admin_fcm_tokens`, `booking_push_tokens`, `bookings`, `event_types_config`, `gallery_photos`, `packages_config`, `site_settings`

## 4. Useful CLI commands

| Command | Purpose |
|--------|---------|
| `npx neonctl me` | Current user |
| `npx neonctl projects list` | Projects |
| `npx neonctl branches list --project-id <id>` | Branches |
| `npx neonctl connection-string --pooled --role-name neondb_owner` | URL for `.env.local` / Vercel |

If you have **multiple** Neon projects, add `--project-id <uuid>` to `connection-string` (from `projects list`).

## 5. If tables are missing

From **`jitterbug-site/`** with `DATABASE_URL` set:

```bash
npm run db:push
```

Then **`npm run db:verify`** again.
