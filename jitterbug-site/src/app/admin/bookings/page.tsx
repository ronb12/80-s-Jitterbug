"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { listBookings, updateBookingStatus } from "@/lib/booking-service";
import type { Booking, BookingStatus } from "@/lib/booking-types";

const ADMIN_PASSWORD = process.env.NEXT_PUBLIC_ADMIN_PASSWORD ?? "";

const statusColors: Record<BookingStatus, string> = {
  pending: "bg-amber-500/20 text-amber-400 border-amber-500/50",
  confirmed: "bg-emerald-500/20 text-emerald-400 border-emerald-500/50",
  declined: "bg-red-500/20 text-red-400 border-red-500/50",
  cancelled: "bg-zinc-500/20 text-zinc-400 border-zinc-500/50",
};

export default function AdminBookingsPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [password, setPassword] = useState("");
  const [passwordError, setPasswordError] = useState(false);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const handleUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    if (password === ADMIN_PASSWORD && ADMIN_PASSWORD) {
      setAuthenticated(true);
      setPasswordError(false);
    } else {
      setPasswordError(true);
    }
  };

  useEffect(() => {
    if (!authenticated || !ADMIN_PASSWORD) return;
    setLoading(true);
    setError(null);
    listBookings()
      .then(setBookings)
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load bookings"))
      .finally(() => setLoading(false));
  }, [authenticated]);

  const handleStatusChange = async (id: string, status: BookingStatus) => {
    setUpdatingId(id);
    try {
      await updateBookingStatus(id, status);
      setBookings((prev) =>
        prev.map((b) => (b.id === id ? { ...b, status, updatedAt: new Date().toISOString() } : b))
      );
    } finally {
      setUpdatingId(null);
    }
  };

  if (!ADMIN_PASSWORD) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-md rounded-2xl border border-amber-500/50 bg-black/50 p-8 text-center">
          <p className="text-amber-400">Admin not configured. Set NEXT_PUBLIC_ADMIN_PASSWORD in .env.local.</p>
          <Link href="/" className="mt-6 inline-block text-[var(--electric-blue)] hover:underline">
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
          className="mx-auto max-w-sm rounded-2xl border border-[var(--electric-blue)]/30 bg-black/50 p-8"
        >
          <h1 className="text-xl font-bold text-[var(--electric-blue)]">Admin: Bookings</h1>
          <p className="mt-2 text-sm text-zinc-400">Enter the admin password to view bookings.</p>
          <form onSubmit={handleUnlock} className="mt-6">
            <input
              type="password"
              value={password}
              onChange={(e) => { setPassword(e.target.value); setPasswordError(false); }}
              placeholder="Password"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--electric-blue)] focus:outline-none"
              autoFocus
            />
            {passwordError && (
              <p className="mt-2 text-sm text-[var(--neon-pink)]">Incorrect password.</p>
            )}
            <button
              type="submit"
              className="mt-4 w-full rounded-full bg-[var(--electric-blue)] py-3 font-bold text-[var(--background)]"
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
      <div className="mx-auto max-w-5xl">
        <div className="mb-8 flex flex-wrap items-center justify-between gap-4">
          <h1 className="text-2xl font-bold text-[var(--electric-blue)]">Bookings</h1>
          <Link
            href="/"
            className="text-sm text-zinc-400 hover:text-white"
          >
            ← Back to site
          </Link>
        </div>

        {loading && (
          <p className="text-zinc-400">Loading bookings…</p>
        )}
        {error && (
          <div className="rounded-lg border border-[var(--neon-pink)] bg-[var(--neon-pink)]/10 p-4 text-[var(--neon-pink)]">
            {error}
          </div>
        )}
        {!loading && !error && bookings.length === 0 && (
          <p className="text-zinc-400">No bookings yet.</p>
        )}
        {!loading && !error && bookings.length > 0 && (
          <div className="space-y-4">
            {bookings.map((b) => (
              <motion.div
                key={b.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                className="rounded-xl border border-[var(--electric-blue)]/30 bg-black/40 p-6"
              >
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div>
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-mono text-[var(--neon-pink)]">{b.bookingRef}</span>
                      <span className={`rounded border px-2 py-0.5 text-xs font-medium ${statusColors[b.status]}`}>
                        {b.status}
                      </span>
                    </div>
                    <h2 className="mt-1 text-lg font-semibold text-white">{b.name}</h2>
                    <p className="text-sm text-zinc-400">{b.email} · {b.phone}</p>
                    <p className="mt-2 text-sm text-zinc-300">
                      {b.eventType} · {b.eventDate} · {b.eventLocation}
                    </p>
                    <p className="text-sm text-zinc-400">Package: {b.package}</p>
                    {b.message && (
                      <p className="mt-2 text-sm text-zinc-500 italic">&ldquo;{b.message}&rdquo;</p>
                    )}
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {(["pending", "confirmed", "declined", "cancelled"] as const).map((status) => (
                      <button
                        key={status}
                        onClick={() => handleStatusChange(b.id, status)}
                        disabled={updatingId === b.id || b.status === status}
                        className={`rounded-lg border px-3 py-1.5 text-xs font-medium transition-opacity disabled:opacity-50 ${
                          b.status === status
                            ? "border-[var(--electric-blue)] bg-[var(--electric-blue)]/20 text-[var(--electric-blue)]"
                            : "border-zinc-600 text-zinc-400 hover:border-zinc-500 hover:text-white"
                        }`}
                      >
                        {status}
                      </button>
                    ))}
                  </div>
                </div>
                <p className="mt-3 text-xs text-zinc-500">
                  Created {b.createdAt ? new Date(b.createdAt).toLocaleString() : "—"}
                </p>
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
