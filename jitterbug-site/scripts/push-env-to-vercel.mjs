#!/usr/bin/env node
/**
 * Push env vars from .env.local + optional .env.vercel.secrets to Vercel (production + preview).
 * Run from jitterbug-site/:  node scripts/push-env-to-vercel.mjs
 *
 * Put server-only secrets in .env.vercel.secrets (gitignored via .env*):
 *   DATABASE_URL (Neon), STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET
 *   Optional: FCM_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_JSON (FCM push only)
 * Optional: INTERNAL_NEW_BOOKING_NOTIFY_SECRET (or omit — script generates one)
 */

import { readFileSync, existsSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { randomBytes } from "node:crypto";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");

function parseDotEnv(content) {
  const env = {};
  for (const line of content.split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const eq = t.indexOf("=");
    if (eq <= 0) continue;
    const key = t.slice(0, eq).trim();
    let val = t.slice(eq + 1);
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1).replace(/\\n/g, "\n");
    }
    env[key] = val;
  }
  return env;
}

function isSensitive(name) {
  if (name.includes("PASSWORD")) return true;
  if (name.includes("SECRET")) return true;
  if (name === "FIREBASE_SERVICE_ACCOUNT_JSON") return true;
  if (name === "FCM_SERVICE_ACCOUNT_JSON") return true;
  if (name === "DATABASE_URL") return true;
  if (name.startsWith("STRIPE_")) return true;
  return false;
}

function buildEnvArgs(cmd, name, target, value, sensitive) {
  const args = [
    "vercel@latest",
    "env",
    cmd,
    name,
    target,
    "--yes",
    "--value",
    value,
  ];
  if (sensitive) args.push("--sensitive");
  return args;
}

/** Create or overwrite (try update first, then add). */
function vercelUpsert(name, target, value, sensitive) {
  let r = spawnSync(
    "npx",
    buildEnvArgs("update", name, target, value, sensitive),
    {
      cwd: root,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
      shell: false,
      maxBuffer: 10 * 1024 * 1024,
    }
  );
  if (r.status === 0) return;

  const addArgs = buildEnvArgs("add", name, target, value, sensitive);
  // Vercel refuses some NEXT_PUBLIC_* adds (e.g. admin password) without --force.
  const addIdx = addArgs.indexOf(target);
  if (addIdx >= 0) addArgs.splice(addIdx + 1, 0, "--force");

  r = spawnSync("npx", addArgs, {
    cwd: root,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    shell: false,
    maxBuffer: 10 * 1024 * 1024,
  });
  if (r.status !== 0) {
    console.error(
      r.stderr || r.stdout || `Failed: env add/update ${name} ${target}`
    );
    process.exit(1);
  }
}

const localPath = join(root, ".env.local");
const secretsPath = join(root, ".env.vercel.secrets");

let merged = {};
if (existsSync(localPath)) {
  merged = { ...merged, ...parseDotEnv(readFileSync(localPath, "utf8")) };
}
if (existsSync(secretsPath)) {
  merged = { ...merged, ...parseDotEnv(readFileSync(secretsPath, "utf8")) };
}

const requiredForProduction = [
  "DATABASE_URL",
  "STRIPE_SECRET_KEY",
  "STRIPE_WEBHOOK_SECRET",
];
const allowPartial = process.argv.includes("--allow-partial");
const missing = requiredForProduction.filter((k) => !merged[k]?.trim());
if (missing.length) {
  const msg =
    "Missing env (add DATABASE_URL + Stripe to .env.local / .env.vercel.secrets — see NEON.md):\n  " +
    missing.join("\n  ");
  if (allowPartial) {
    console.error("[warn] " + msg + "\n[warn] Continuing with --allow-partial (data/Stripe routes will fail until fixed).\n");
  } else {
    console.error(msg);
    process.exit(1);
  }
}

if (!merged.INTERNAL_NEW_BOOKING_NOTIFY_SECRET?.trim()) {
  merged.INTERNAL_NEW_BOOKING_NOTIFY_SECRET = randomBytes(24).toString("hex");
  console.error(
    "[info] Generated INTERNAL_NEW_BOOKING_NOTIFY_SECRET — set iOS Info.plist InternalNewBookingNotifySecret to the same value (or copy from Vercel dashboard after push)."
  );
}

// Preview env vars on Vercel often require a git branch interactively; production is enough for live Stripe/API.
const targets = (process.env.VERCEL_ENV_TARGETS ?? "production")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);
const keys = Object.keys(merged).filter((k) => merged[k] != null && String(merged[k]).length > 0);

for (const key of keys) {
  const value = String(merged[key]);
  const sens = isSensitive(key);
  for (const target of targets) {
    vercelUpsert(key, target, value, sens);
    process.stdout.write(`OK ${key} → ${target}\n`);
  }
}

console.error(`\nDone. Pushed ${keys.length} variable(s) × ${targets.length} environments.`);
