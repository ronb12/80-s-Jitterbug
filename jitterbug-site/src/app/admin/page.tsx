"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { isAdminAuthenticated, setAdminAuthenticated, clearAdminSession, isAdminConfigured, validateAdminCredentials } from "@/lib/admin-auth";

export default function AdminPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordError, setPasswordError] = useState(false);

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

  if (!isAdminConfigured()) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-md rounded-2xl border border-amber-500/50 bg-black/50 p-8 text-center">
          <p className="text-amber-400">
            Admin not configured. Set NEXT_PUBLIC_ADMIN_EMAIL and NEXT_PUBLIC_ADMIN_PASSWORD (and optionally
            NEXT_PUBLIC_ADMIN_EMAIL_2, NEXT_PUBLIC_ADMIN_PASSWORD_2) in .env.local.
          </p>
          <Link href="/" className="mt-6 inline-block text-[var(--pink)] hover:underline">
            Back to site
          </Link>
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
          <h1 className="text-xl font-bold text-[var(--pink)]">Admin login</h1>
          <p className="mt-2 text-sm text-zinc-400">Sign in with your admin email and password.</p>
          <form onSubmit={handleUnlock} className="mt-6 space-y-4">
            <input
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                setPasswordError(false);
              }}
              placeholder="Email"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              autoComplete="email"
            />
            <input
              type="password"
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                setPasswordError(false);
              }}
              placeholder="Password"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              autoComplete="current-password"
            />
            {passwordError && (
              <p className="text-sm text-[var(--pink)]">Incorrect email or password.</p>
            )}
            <button
              type="submit"
              className="mt-4 w-full rounded-full bg-[var(--pink)] py-3 font-bold text-[var(--background)]"
            >
              Unlock
            </button>
          </form>
          <Link href="/" className="mt-6 block text-center text-sm text-zinc-500 hover:text-white">
            ← Back to site
          </Link>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen px-4 py-12 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-2xl">
        <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
          <h1 className="text-2xl font-bold text-[var(--pink)]">Admin</h1>
          <div className="flex flex-wrap gap-3">
            <button
              type="button"
              onClick={() => {
                clearAdminSession();
                setAuthenticated(false);
              }}
              className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-400 hover:text-white"
            >
              Log out
            </button>
            <Link href="/" className="text-sm text-zinc-400 hover:text-white">
              ← Back to site
            </Link>
          </div>
        </div>
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="grid gap-4 sm:grid-cols-2"
        >
          <Link
            href="/admin/bookings"
            className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6 text-left transition-colors hover:border-[var(--pink)]/40"
          >
            <span className="text-2xl">📋</span>
            <h2 className="mt-2 text-lg font-semibold text-white">Bookings</h2>
            <p className="mt-1 text-sm text-zinc-400">View and manage booking requests.</p>
          </Link>
          <Link
            href="/admin/packages"
            className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6 text-left transition-colors hover:border-[var(--pink)]/40"
          >
            <span className="text-2xl">💰</span>
            <h2 className="mt-2 text-lg font-semibold text-white">Packages & pricing</h2>
            <p className="mt-1 text-sm text-zinc-400">Edit package names and prices.</p>
          </Link>
          <Link
            href="/admin/event-types"
            className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6 text-left transition-colors hover:border-[var(--pink)]/40"
          >
            <span className="text-2xl">🎉</span>
            <h2 className="mt-2 text-lg font-semibold text-white">Event types</h2>
            <p className="mt-1 text-sm text-zinc-400">Manage event type options for booking.</p>
          </Link>
          <Link
            href="/admin/gallery"
            className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6 text-left transition-colors hover:border-[var(--pink)]/40"
          >
            <span className="text-2xl">📸</span>
            <h2 className="mt-2 text-lg font-semibold text-white">Gallery</h2>
            <p className="mt-1 text-sm text-zinc-400">Upload and manage gallery photos.</p>
          </Link>
        </motion.div>
      </div>
    </div>
  );
}
