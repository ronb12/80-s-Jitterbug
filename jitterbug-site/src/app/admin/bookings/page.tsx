"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import {
  listBookings,
  submitBooking,
  updateBookingStatus,
  deleteBooking,
} from "@/lib/booking-service";
import type { Booking, BookingFormData, BookingStatus } from "@/lib/booking-types";
import { getEventTypes } from "@/lib/event-types-service";
import { getPackages, type PackagePrice } from "@/lib/packages-service";
import {
  isAdminAuthenticated,
  setAdminAuthenticated,
  clearAdminSession,
  isAdminConfigured,
  validateAdminCredentials,
} from "@/lib/admin-auth";

const emptyForm: BookingFormData = {
  name: "",
  email: "",
  phone: "",
  eventType: "",
  eventDate: "",
  eventLocation: "",
  eventAddress: "",
  package: "",
  message: "",
};

export default function AdminBookingsPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordError, setPasswordError] = useState(false);

  const [bookings, setBookings] = useState<Booking[]>([]);
  const [eventTypes, setEventTypes] = useState<string[]>([]);
  const [packages, setPackages] = useState<PackagePrice[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const [showAddForm, setShowAddForm] = useState(false);
  const [addForm, setAddForm] = useState<BookingFormData>(emptyForm);
  const [adding, setAdding] = useState(false);

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

  const loadData = () => {
    setLoading(true);
    setError(null);
    Promise.all([listBookings(), getEventTypes(), getPackages()])
      .then(([bookingsList, types, pkgs]) => {
        setBookings(bookingsList);
        setEventTypes(types);
        setPackages(pkgs);
        if (types.length > 0 && !addForm.eventType)
          setAddForm((f) => ({ ...f, eventType: types[0] }));
        if (pkgs.length > 0 && !addForm.package)
          setAddForm((f) => ({ ...f, package: pkgs[0].id }));
      })
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load"))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    if (!authenticated) return;
    loadData();
  }, [authenticated]);

  const handleStatusChange = async (bookingId: string, status: BookingStatus) => {
    try {
      await updateBookingStatus(bookingId, status);
      setBookings((prev) =>
        prev.map((b) => (b.id === bookingId ? { ...b, status } : b))
      );
    } catch {
      setError("Failed to update status");
    }
  };

  const handleDelete = async (bookingId: string) => {
    if (!confirm("Delete this booking?")) return;
    try {
      await deleteBooking(bookingId);
      setBookings((prev) => prev.filter((b) => b.id !== bookingId));
    } catch {
      setError("Failed to delete");
    }
  };

  const handleAddBooking = async (e: React.FormEvent) => {
    e.preventDefault();
    if (
      !addForm.name?.trim() ||
      !addForm.email?.trim() ||
      !addForm.phone?.trim() ||
      !addForm.eventType ||
      !addForm.eventDate?.trim() ||
      !addForm.eventLocation?.trim() ||
      !(addForm.eventAddress ?? "").trim() ||
      !addForm.package
    ) {
      setError("Please fill in all required fields.");
      return;
    }
    setAdding(true);
    setError(null);
    try {
      const { bookingRef } = await submitBooking(addForm);
      setSuccess(`Booking added. Ref: ${bookingRef}. Refreshing list...`);
      setAddForm(emptyForm);
      setShowAddForm(false);
      loadData();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to add booking");
    } finally {
      setAdding(false);
    }
  };

  if (!isAdminConfigured()) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-md rounded-2xl border border-amber-500/50 bg-black/50 p-8 text-center">
          <p className="text-amber-400">
            Admin not configured. Set NEXT_PUBLIC_ADMIN_EMAIL and NEXT_PUBLIC_ADMIN_PASSWORD in .env.local.
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
          <h1 className="text-xl font-bold text-[var(--pink)]">Admin: Bookings</h1>
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
      <div className="mx-auto max-w-5xl">
        <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
          <h1 className="text-2xl font-bold text-[var(--pink)]">Bookings</h1>
          <div className="flex flex-wrap gap-3">
            <Link
              href="/admin/packages"
              className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5"
            >
              Packages
            </Link>
            <Link
              href="/admin/event-types"
              className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5"
            >
              Event types
            </Link>
            <Link
              href="/admin/gallery"
              className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5"
            >
              Gallery
            </Link>
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

        {error && (
          <div className="mb-4 rounded-lg border border-[var(--pink)]/50 bg-[var(--pink-muted)] px-4 py-3 text-sm text-[var(--pink)]">
            {error}
          </div>
        )}
        {success && (
          <div className="mb-4 rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-400">
            {success}
          </div>
        )}

        <div className="mb-6">
          <button
            type="button"
            onClick={() => setShowAddForm((v) => !v)}
            className="rounded-full bg-[var(--pink)] px-6 py-2.5 text-sm font-semibold text-white hover:bg-[var(--pink-hover)]"
          >
            {showAddForm ? "Cancel" : "+ Add booking"}
          </button>
        </div>

        {showAddForm && (
          <motion.form
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            onSubmit={handleAddBooking}
            className="mb-8 rounded-xl border border-[var(--border)] bg-[var(--card)] p-6"
          >
            <h2 className="mb-4 text-lg font-semibold text-white">Add booking manually</h2>
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className="block text-xs text-zinc-400">Name *</label>
                <input
                  type="text"
                  value={addForm.name}
                  onChange={(e) => setAddForm((f) => ({ ...f, name: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                  required
                />
              </div>
              <div>
                <label className="block text-xs text-zinc-400">Email *</label>
                <input
                  type="email"
                  value={addForm.email}
                  onChange={(e) => setAddForm((f) => ({ ...f, email: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                  required
                />
              </div>
              <div>
                <label className="block text-xs text-zinc-400">Phone *</label>
                <input
                  type="tel"
                  value={addForm.phone}
                  onChange={(e) => setAddForm((f) => ({ ...f, phone: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                  required
                />
              </div>
              <div>
                <label className="block text-xs text-zinc-400">Event type *</label>
                <select
                  value={addForm.eventType}
                  onChange={(e) => setAddForm((f) => ({ ...f, eventType: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                >
                  {eventTypes.map((t) => (
                    <option key={t} value={t}>
                      {t}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-xs text-zinc-400">Event date *</label>
                <input
                  type="date"
                  value={addForm.eventDate}
                  onChange={(e) => setAddForm((f) => ({ ...f, eventDate: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                  required
                />
              </div>
              <div>
                <label className="block text-xs text-zinc-400">Event location (city/venue) *</label>
                <input
                  type="text"
                  value={addForm.eventLocation}
                  onChange={(e) => setAddForm((f) => ({ ...f, eventLocation: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                  required
                />
              </div>
              <div className="sm:col-span-2">
                <label className="block text-xs text-zinc-400">Full address *</label>
                <input
                  type="text"
                  value={addForm.eventAddress}
                  onChange={(e) => setAddForm((f) => ({ ...f, eventAddress: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                  placeholder="Street, city, state, zip"
                  required
                />
              </div>
              <div>
                <label className="block text-xs text-zinc-400">Package *</label>
                <select
                  value={addForm.package}
                  onChange={(e) => setAddForm((f) => ({ ...f, package: e.target.value }))}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                >
                  {packages.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} {p.price ? `— ${p.price}` : ""}
                    </option>
                  ))}
                </select>
              </div>
              <div className="sm:col-span-2">
                <label className="block text-xs text-zinc-400">Message (optional)</label>
                <textarea
                  value={addForm.message}
                  onChange={(e) => setAddForm((f) => ({ ...f, message: e.target.value }))}
                  rows={2}
                  className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white"
                />
              </div>
            </div>
            <button
              type="submit"
              disabled={adding}
              className="mt-4 rounded-full bg-[var(--pink)] px-6 py-2 text-sm font-semibold text-white hover:bg-[var(--pink-hover)] disabled:opacity-50"
            >
              {adding ? "Adding…" : "Add booking"}
            </button>
          </motion.form>
        )}

        {loading ? (
          <p className="text-zinc-500">Loading bookings…</p>
        ) : bookings.length === 0 ? (
          <p className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-8 text-center text-zinc-500">
            No bookings yet. Add one above or wait for requests from the site.
          </p>
        ) : (
          <ul className="space-y-4">
            {bookings.map((b) => (
              <li
                key={b.id}
                className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6"
              >
                <div className="flex flex-wrap items-start justify-between gap-4">
                  <div>
                    <p className="font-mono font-semibold text-[var(--pink)]">{b.bookingRef}</p>
                    <p className="mt-1 font-medium text-white">{b.name}</p>
                    <p className="text-sm text-zinc-400">
                      {b.email} · {b.phone}
                    </p>
                    <p className="mt-2 text-sm text-zinc-400">
                      {b.eventType} · {b.eventDate} · {b.eventLocation}
                    </p>
                    {b.eventAddress && (
                      <p className="text-sm text-zinc-500">{b.eventAddress}</p>
                    )}
                    <p className="text-sm text-zinc-400">Package: {b.package}</p>
                    {b.message && (
                      <p className="mt-2 text-sm text-zinc-500">"{b.message}"</p>
                    )}
                    <p className="mt-2 text-xs text-zinc-600">
                      Created: {b.createdAt ? new Date(b.createdAt).toLocaleString() : "—"}
                    </p>
                  </div>
                  <div className="flex flex-wrap items-center gap-2">
                    {(["pending", "confirmed", "declined", "cancelled"] as const).map((status) => (
                      <button
                        key={status}
                        type="button"
                        onClick={() => handleStatusChange(b.id, status)}
                        className={`rounded-full px-3 py-1.5 text-xs font-medium capitalize ${
                          b.status === status
                            ? "bg-[var(--pink)] text-white"
                            : "border border-zinc-600 text-zinc-400 hover:bg-white/5"
                        }`}
                      >
                        {status}
                      </button>
                    ))}
                    <button
                      type="button"
                      onClick={() => handleDelete(b.id)}
                      className="rounded-full border border-red-500/50 px-3 py-1.5 text-xs text-red-400 hover:bg-red-500/10"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
