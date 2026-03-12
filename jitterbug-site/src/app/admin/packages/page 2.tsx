"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { getPackages, setPackages, type PackagePrice } from "@/lib/packages-service";
import { isAdminAuthenticated, setAdminAuthenticated, clearAdminSession } from "@/lib/admin-auth";

const ADMIN_EMAIL = (process.env.NEXT_PUBLIC_ADMIN_EMAIL ?? "").trim().toLowerCase();
const ADMIN_PASSWORD = process.env.NEXT_PUBLIC_ADMIN_PASSWORD ?? "";

export default function AdminPackagesPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordError, setPasswordError] = useState(false);

  useEffect(() => {
    if (isAdminAuthenticated()) setAuthenticated(true);
  }, []);
  const [packages, setPackagesState] = useState<PackagePrice[]>([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const handleUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    const emailMatch = email.trim().toLowerCase() === ADMIN_EMAIL;
    const passwordMatch = password.trim() === ADMIN_PASSWORD;
    if (emailMatch && passwordMatch && ADMIN_EMAIL && ADMIN_PASSWORD) {
      setAdminAuthenticated();
      setAuthenticated(true);
      setPasswordError(false);
    } else {
      setPasswordError(true);
    }
  };

  useEffect(() => {
    if (!authenticated) return;
    setLoading(true);
    setError(null);
    getPackages()
      .then(setPackagesState)
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load packages"))
      .finally(() => setLoading(false));
  }, [authenticated]);

  const handleChange = (index: number, field: "name" | "price", value: string) => {
    setPackagesState((prev) =>
      prev.map((p, i) => (i === index ? { ...p, [field]: value } : p))
    );
    setError(null);
    setSuccess(null);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      await setPackages(packages);
      setSuccess("Prices saved. They’ll appear on the site and in booking options.");
      setTimeout(() => setSuccess(null), 5000);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-md rounded-2xl border border-amber-500/50 bg-black/50 p-8 text-center">
          <p className="text-amber-400">Admin not configured. Set NEXT_PUBLIC_ADMIN_EMAIL and NEXT_PUBLIC_ADMIN_PASSWORD in .env.local.</p>
          <Link href="/" className="mt-6 inline-block text-[var(--pink)] hover:underline">Back to site</Link>
        </div>
      </div>
    );
  }

  if (!authenticated) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-auto max-w-sm rounded-2xl border border-[var(--pink)]/30 bg-black/50 p-8"
        >
          <h1 className="text-xl font-bold text-[var(--pink)]">Admin: Packages</h1>
          <p className="mt-2 text-sm text-zinc-400">Sign in with your admin email and password.</p>
          <form onSubmit={handleUnlock} className="mt-6 space-y-4">
            <input
              type="email"
              value={email}
              onChange={(e) => { setEmail(e.target.value); setPasswordError(false); }}
              placeholder="Email"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              autoComplete="email"
            />
            <input
              type="password"
              value={password}
              onChange={(e) => { setPassword(e.target.value); setPasswordError(false); }}
              placeholder="Password"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              autoComplete="current-password"
            />
            {passwordError && (
              <p className="text-sm text-[var(--pink)]">Incorrect email or password.</p>
            )}
            <button type="submit" className="mt-4 w-full rounded-full bg-[var(--pink)] py-3 font-bold text-[var(--background)]">
              Unlock
            </button>
          </form>
          <Link href="/" className="mt-6 block text-center text-sm text-zinc-500 hover:text-white">← Back to site</Link>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen px-4 py-12 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-2xl">
        <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
          <h1 className="text-2xl font-bold text-[var(--pink)]">Packages & pricing</h1>
          <div className="flex gap-3">
            <Link href="/admin/bookings" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Bookings</Link>
            <Link href="/admin/event-types" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Event types</Link>
            <Link href="/admin/gallery" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Gallery</Link>
            <button type="button" onClick={() => { clearAdminSession(); setAuthenticated(false); }} className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-400 hover:text-white">Log out</button>
            <Link href="/" className="text-sm text-zinc-400 hover:text-white">← Back to site</Link>
          </div>
        </div>

        <p className="mb-6 text-sm text-zinc-400">
          Edit package names and prices. These show on the Packages page and in the booking form.
        </p>

        {loading && <p className="text-zinc-400">Loading…</p>}
        {error && <div className="mb-6 rounded-lg border border-[var(--pink)] bg-[var(--pink-muted)] p-4 text-[var(--pink)]">{error}</div>}
        {success && <div className="mb-6 rounded-lg border border-emerald-500/50 bg-emerald-500/10 p-4 text-emerald-400">{success}</div>}

        {!loading && packages.length > 0 && (
          <motion.form
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            onSubmit={handleSave}
            className="space-y-6 rounded-xl border border-[var(--border)] bg-black/40 p-6"
          >
            {packages.map((pkg, index) => (
              <div key={pkg.id} className="flex flex-wrap items-end gap-4 border-b border-zinc-800 pb-6 last:border-0 last:pb-0">
                <div className="min-w-[120px] flex-1">
                  <label className="block text-xs text-zinc-400">Package name</label>
                  <input
                    type="text"
                    value={pkg.name}
                    onChange={(e) => handleChange(index, "name", e.target.value)}
                    className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                    placeholder="e.g. Basic Package"
                  />
                </div>
                <div className="w-32">
                  <label className="block text-xs text-zinc-400">Price</label>
                  <input
                    type="text"
                    value={pkg.price}
                    onChange={(e) => handleChange(index, "price", e.target.value)}
                    className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                    placeholder="$399"
                  />
                </div>
              </div>
            ))}
            <button
              type="submit"
              disabled={saving}
              className="rounded-full bg-[var(--pink)] px-6 py-2 text-sm font-semibold text-white hover:bg-[var(--pink-hover)] disabled:opacity-50"
            >
              {saving ? "Saving…" : "Save prices"}
            </button>
          </motion.form>
        )}
      </div>
    </div>
  );
}
