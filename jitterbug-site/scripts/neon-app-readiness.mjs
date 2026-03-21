#!/usr/bin/env node
/**
 * Confirm Neon has everything the jitterbug-site app needs (tables, UUID, FKs).
 *
 * Uses DATABASE_URL from the environment or .env.local (same as the running app).
 *
 * For Neon **CLI** + psql (no DATABASE_URL in file), see NEON-CLI.md:
 *   npx neonctl connection-string --pooled --psql -- -c "SELECT ..."
 */
import { readFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { neon } from "@neondatabase/serverless";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");

const EXPECTED_TABLES = new Set([
  "site_settings",
  "packages_config",
  "event_types_config",
  "bookings",
  "gallery_photos",
  "admin_fcm_tokens",
  "booking_push_tokens",
]);

function loadDatabaseUrl() {
  if (process.env.DATABASE_URL?.trim()) return process.env.DATABASE_URL.trim();
  const envPath = join(root, ".env.local");
  if (!existsSync(envPath)) return "";
  const text = readFileSync(envPath, "utf8");
  for (const line of text.split("\n")) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const eq = t.indexOf("=");
    if (eq <= 0) continue;
    const k = t.slice(0, eq).trim();
    if (k !== "DATABASE_URL") continue;
    let v = t.slice(eq + 1).trim();
    if (
      (v.startsWith('"') && v.endsWith('"')) ||
      (v.startsWith("'") && v.endsWith("'"))
    ) {
      v = v.slice(1, -1);
    }
    return v;
  }
  return "";
}

const url = loadDatabaseUrl();
if (!url) {
  console.error(
    "No DATABASE_URL. Add it to .env.local, or run Neon CLI:\n" +
      "  npx neonctl auth\n" +
      "  npx neonctl connection-string --pooled\n" +
      "  (paste into .env.local as DATABASE_URL=...)\n" +
      "See NEON-CLI.md"
  );
  process.exit(1);
}

const sql = neon(url);
let exitCode = 0;

console.log("=== 1. Public tables ===\n");
const tables = await sql`
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  ORDER BY table_name
`;
const actual = new Set(tables.map((r) => r.table_name));
const missing = [...EXPECTED_TABLES].filter((t) => !actual.has(t));
const extra = [...actual].filter(
  (t) => !EXPECTED_TABLES.has(t) && !String(t).startsWith("drizzle")
);

console.log("Required:", [...EXPECTED_TABLES].sort().join(", "));
console.log("Found:   ", [...actual].sort().join(", "));

if (missing.length) {
  console.error("\nMISSING TABLES:", missing.join(", "));
  console.error("Fix: cd jitterbug-site && npm run db:push");
  exitCode = 1;
} else {
  console.log("\nOK — all 7 app tables exist.");
}

if (extra.length) {
  console.log("\nNote — extra tables in public (ignored if intentional):", extra.join(", "));
}

console.log("\n=== 2. UUID generation (bookings / gallery IDs) ===\n");
try {
  const [{ u }] = await sql`SELECT gen_random_uuid()::text AS u`;
  if (u && u.length > 30) {
    console.log("OK — gen_random_uuid() works:", u.slice(0, 8) + "…");
  }
} catch (e) {
  console.error("FAIL — gen_random_uuid() error:", String(e));
  console.error("On older Postgres, run in Neon SQL editor: CREATE EXTENSION IF NOT EXISTS pgcrypto;");
  exitCode = 1;
}

console.log("\n=== 3. Foreign key: booking_push_tokens → bookings ===\n");
const fks = await sql`
  SELECT tc.constraint_name
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
  WHERE tc.table_schema = 'public'
    AND tc.table_name = 'booking_push_tokens'
    AND tc.constraint_type = 'FOREIGN KEY'
`;
if (fks.length === 0) {
  console.error("FAIL — no FK on booking_push_tokens (expected reference to bookings.id)");
  exitCode = 1;
} else {
  console.log("OK — FK present:", fks.map((r) => r.constraint_name).join(", "));
}

console.log("\n=== 4. Unique constraint: bookings.booking_ref ===\n");
const uniques = await sql`
  SELECT indexname
  FROM pg_indexes
  WHERE schemaname = 'public' AND tablename = 'bookings' AND indexdef ILIKE '%booking_ref%'
`;
if (uniques.length === 0) {
  console.warn("WARN — no index mentioning booking_ref found (Drizzle should create unique). Check schema.");
} else {
  console.log("OK —", uniques.map((r) => r.indexname).join(", "));
}

console.log("\n=== 5. Seed rows (optional — app auto-seeds on first API hit) ===\n");
try {
  const [ss] = await sql`SELECT COUNT(*)::int AS c FROM site_settings WHERE id = 'site'`;
  const [pk] = await sql`SELECT COUNT(*)::int AS c FROM packages_config WHERE id = 1`;
  const [et] = await sql`SELECT COUNT(*)::int AS c FROM event_types_config WHERE id = 1`;
  console.log(`site_settings (id=site): ${ss.c} row(s)`);
  console.log(`packages_config (id=1):  ${pk.c} row(s)`);
  console.log(`event_types_config (id=1): ${et.c} row(s)`);
  if (ss.c === 0 || pk.c === 0 || et.c === 0) {
    console.log(
      "\nNote — empty config rows are OK: first request to /api/data/* or /api/bookings/submit runs ensureConfigRows()."
    );
  }
} catch {
  console.log("(skipped — tables may not exist yet)");
}

console.log("\n=== 6. Outside Neon (Vercel / env) ===\n");
console.log(
  "For full app function you still need on Vercel (or .env.local): STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, NEXT_PUBLIC_ADMIN_*, optional FCM_SERVICE_ACCOUNT_JSON — see STACK.md / VERCEL.md."
);

process.exit(exitCode);
