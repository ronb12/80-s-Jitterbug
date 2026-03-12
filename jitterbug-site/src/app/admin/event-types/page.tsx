"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { getEventTypes, setEventTypes } from "@/lib/event-types-service";
import { isAdminAuthenticated, setAdminAuthenticated, clearAdminSession, isAdminConfigured, validateAdminCredentials } from "@/lib/admin-auth";

export default function AdminEventTypesPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordError, setPasswordError] = useState(false);
  const [eventTypes, setEventTypesState] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (isAdminAuthenticated()) setAuthenticated(true);
  }, []);

  const handleUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateAdminCredentials(email, password)) {
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
    getEventTypes()
      .then(setEventTypesState)
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load event types"))
      .finally(() => setLoading(false));
  }, [authenticated]);

  const handleChange = (index: number, value: string) => {
    setEventTypesState((prev) => prev.map((t, i) => (i === index ? value : t)));
    setError(null);
    setSuccess(null);
  };

  const handleAdd = () => {
    setEventTypesState((prev) => [...prev, ""]);
    setError(null);
    setSuccess(null);
  };

  const handleRemove = (index: number) => {
    setEventTypesState((prev) => prev.filter((_, i) => i !== index));
    setError(null);
    setSuccess(null);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = eventTypes.map((t) => t.trim()).filter(Boolean);
    if (trimmed.length === 0) {
      setError("Add at least one event type.");
      return;
    }
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      await setEventTypes(trimmed);
      setEventTypesState(trimmed);
      setSuccess("Event types saved. They'll appear in the booking form.");
      setTimeout(() => setSuccess(null), 5000);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  if (!isAdminConfigured()) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-md rounded-2xl border border-amber-500/50 bg-black/50 p-8 text-center">
          <p className="text-amber-400">Admin not configured.</p>
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
          <h1 className="text-xl font-bold text-[var(--pink)]">Admin: Event types</h1>
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
            {passwordError && <p className="text-sm text-[var(--pink)]">Incorrect email or password.</p>}
            <button type="submit" className="mt-4 w-full rounded-full bg-[var(--pink)] py-3 font-bold text-[var(--background)]">Unlock</button>
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
          <h1 className="text-2xl font-bold text-[var(--pink)]">Event types</h1>
          <div className="flex gap-3">
            <Link href="/admin/bookings" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Bookings</Link>
            <Link href="/admin/packages" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Packages</Link>
            <Link href="/admin/gallery" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Gallery</Link>
            <button type="button" onClick={() => { clearAdminSession(); setAuthenticated(false); }} className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-400 hover:text-white">Log out</button>
            <Link href="/" className="text-sm text-zinc-400 hover:text-white">← Back to site</Link>
          </div>
        </div>

        <p className="mb-6 text-sm text-zinc-400">
          These are the types of events customers can choose when booking. Add, edit, or remove items below.
        </p>

        {loading && <p className="text-zinc-400">Loading…</p>}
        {error && <div className="mb-6 rounded-lg border border-[var(--pink)] bg-[var(--pink-muted)] p-4 text-[var(--pink)]">{error}</div>}
        {success && <div className="mb-6 rounded-lg border border-emerald-500/50 bg-emerald-500/10 p-4 text-emerald-400">{success}</div>}

        {!loading && (
          <motion.form
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            onSubmit={handleSave}
            className="space-y-4 rounded-xl border border-[var(--border)] bg-black/40 p-6"
          >
            {eventTypes.map((name, index) => (
              <div key={index} className="flex items-center gap-3">
                <input
                  type="text"
                  value={name}
                  onChange={(e) => handleChange(index, e.target.value)}
                  className="flex-1 rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white placeholder-zinc-500"
                  placeholder="e.g. Wedding"
                />
                <button
                  type="button"
                  onClick={() => handleRemove(index)}
                  className="rounded-lg border border-red-500/50 px-3 py-2 text-sm text-red-400 hover:bg-red-500/10"
                >
                  Remove
                </button>
              </div>
            ))}
            <button
              type="button"
              onClick={handleAdd}
              className="w-full rounded-lg border border-dashed border-zinc-600 py-3 text-sm text-zinc-400 hover:border-[var(--pink)]/50 hover:text-[var(--pink)]"
            >
              + Add event type
            </button>
            <button
              type="submit"
              disabled={saving}
              className="mt-4 rounded-full bg-[var(--pink)] px-6 py-2 text-sm font-semibold text-white hover:bg-[var(--pink-hover)] disabled:opacity-50"
            >
              {saving ? "Saving…" : "Save event types"}
            </button>
          </motion.form>
        )}
      </div>
    </div>
  );
}
