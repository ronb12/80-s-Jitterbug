#!/usr/bin/env node
/**
 * Set Neon site_settings.stripe_public_base_url (and optional canonical URL note).
 * Uses DATABASE_URL from env or .env.local.
 *
 * Usage:
 *   SITE_URL=https://jitterbug-site.vercel.app node scripts/set-production-site-url.mjs
 * Defaults SITE_URL to https://jitterbug-site.vercel.app if unset.
 */
import { readFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { neon } from "@neondatabase/serverless";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");

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
  console.error("DATABASE_URL missing — add Neon URL to .env.local, then re-run.");
  process.exit(1);
}

let siteUrl = (process.env.SITE_URL ?? "https://jitterbug-site.vercel.app").trim();
siteUrl = siteUrl.replace(/\/$/, "");

const sql = neon(url);
await sql`
  INSERT INTO site_settings (id, stripe_public_base_url)
  VALUES ('site', ${siteUrl})
  ON CONFLICT (id) DO UPDATE SET stripe_public_base_url = EXCLUDED.stripe_public_base_url
`;
console.log("OK — site_settings.stripe_public_base_url =", siteUrl);
