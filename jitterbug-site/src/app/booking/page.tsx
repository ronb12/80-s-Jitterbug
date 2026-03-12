"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import { submitBooking } from "@/lib/booking-service";
import type { BookingFormData } from "@/lib/booking-types";
import { getEventTypes } from "@/lib/event-types-service";
import { getPackages, type PackagePrice } from "@/lib/packages-service";

const initialForm: BookingFormData = {
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

function validate(form: BookingFormData): string | null {
  if (!form.name.trim()) return "Please enter your name.";
  if (!form.email.trim()) return "Please enter your email.";
  const emailRe = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRe.test(form.email.trim())) return "Please enter a valid email address.";
  if (!form.phone.trim()) return "Please enter your phone number.";
  if (!form.eventType) return "Please select an event type.";
  if (!form.eventDate.trim()) return "Please enter your event date.";
  if (!form.eventLocation.trim()) return "Please enter the event location.";
  if (!(form.eventAddress ?? "").trim()) return "Please enter the full event address.";
  if (!form.package) return "Please select a package.";
  return null;
}

export default function BookingPage() {
  const [form, setForm] = useState<BookingFormData>(initialForm);
  const [eventTypes, setEventTypes] = useState<string[]>([]);
  const [packages, setPackages] = useState<PackagePrice[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<{ bookingRef: string } | null>(null);

  useEffect(() => {
    Promise.all([getEventTypes(), getPackages()])
      .then(([types, pkgs]) => {
        setEventTypes(types);
        setPackages(pkgs);
        if (types.length > 0 && !form.eventType) setForm((f) => ({ ...f, eventType: types[0] }));
        if (pkgs.length > 0 && !form.package) setForm((f) => ({ ...f, package: pkgs[0].id }));
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleChange = (field: keyof BookingFormData, value: string) => {
    setForm((prev) => ({ ...prev, [field]: value }));
    setError(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const err = validate(form);
    if (err) {
      setError(err);
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      const result = await submitBooking(form);
      setSuccess({ bookingRef: result.bookingRef });
    } catch {
      setError("Something went wrong. Please try again or contact us directly.");
    } finally {
      setSubmitting(false);
    }
  };

  if (success) {
    return (
      <div className="mx-auto max-w-xl px-4 py-20 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          className="rounded-2xl border border-[var(--pink)]/30 bg-[var(--card)] p-10 text-center"
        >
          <h1 className="text-2xl font-bold text-[var(--pink)] sm:text-3xl">Request Received!</h1>
          <p className="mt-4 text-zinc-400">
            Thanks for your interest. Your booking reference is:
          </p>
          <p className="mt-2 font-mono text-2xl font-bold text-white">{success.bookingRef}</p>
          <p className="mt-4 text-sm text-zinc-500">
            Please save this reference. We&apos;ll get back to you with a quote soon.
          </p>
          <Link
            href="/"
            className="mt-8 inline-block rounded-full bg-[var(--pink)] px-6 py-3 font-semibold text-white hover:bg-[var(--pink-hover)]"
          >
            Back to home
          </Link>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 lg:px-8">
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-10"
      >
        <h1 className="text-3xl font-bold text-[var(--pink)] sm:text-4xl">Book Your Booth</h1>
        <p className="mt-3 text-zinc-400">
          Request a quote for photo booth rental. Weddings, birthdays, corporate events.
        </p>
      </motion.div>

      <motion.form
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        onSubmit={handleSubmit}
        className="space-y-6 rounded-2xl border border-[var(--border)] bg-[var(--card)] p-6 sm:p-8"
      >
        {error && (
          <div className="rounded-lg border border-[var(--pink)]/50 bg-[var(--pink-muted)] px-4 py-3 text-sm text-[var(--pink)]">
            {error}
          </div>
        )}

        <div className="grid gap-6 sm:grid-cols-2">
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-zinc-400">
              Name *
            </label>
            <input
              id="name"
              type="text"
              value={form.name}
              onChange={(e) => handleChange("name", e.target.value)}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              placeholder="Your name"
              required
            />
          </div>
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-zinc-400">
              Email *
            </label>
            <input
              id="email"
              type="email"
              value={form.email}
              onChange={(e) => handleChange("email", e.target.value)}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              placeholder="you@example.com"
              required
            />
          </div>
        </div>

        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-zinc-400">
            Phone *
          </label>
          <input
            id="phone"
            type="tel"
            value={form.phone}
            onChange={(e) => handleChange("phone", e.target.value)}
            className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
            placeholder="(555) 123-4567"
            required
          />
        </div>

        <div className="grid gap-6 sm:grid-cols-2">
          <div>
            <label htmlFor="eventType" className="block text-sm font-medium text-zinc-400">
              Event type *
            </label>
            <select
              id="eventType"
              value={form.eventType}
              onChange={(e) => handleChange("eventType", e.target.value)}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--pink)] focus:outline-none"
              required
            >
              <option value="">Select...</option>
              {eventTypes.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor="eventDate" className="block text-sm font-medium text-zinc-400">
              Event date *
            </label>
            <input
              id="eventDate"
              type="date"
              value={form.eventDate}
              onChange={(e) => handleChange("eventDate", e.target.value)}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--pink)] focus:outline-none"
              required
            />
          </div>
        </div>

        <div>
          <label htmlFor="eventLocation" className="block text-sm font-medium text-zinc-400">
            Event location (city/venue) *
          </label>
          <input
            id="eventLocation"
            type="text"
            value={form.eventLocation}
            onChange={(e) => handleChange("eventLocation", e.target.value)}
            className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
            placeholder="e.g. Downtown Ballroom, Austin TX"
            required
          />
        </div>

        <div>
          <label htmlFor="eventAddress" className="block text-sm font-medium text-zinc-400">
            Full address *
          </label>
          <input
            id="eventAddress"
            type="text"
            value={form.eventAddress}
            onChange={(e) => handleChange("eventAddress", e.target.value)}
            className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
            placeholder="Street, city, state, zip"
            required
          />
        </div>

        <div>
          <label htmlFor="package" className="block text-sm font-medium text-zinc-400">
            Package *
          </label>
          <select
            id="package"
            value={form.package}
            onChange={(e) => handleChange("package", e.target.value)}
            className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--pink)] focus:outline-none"
            required
          >
            <option value="">Select...</option>
            {packages.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name} {p.price ? `— ${p.price}` : ""}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label htmlFor="message" className="block text-sm font-medium text-zinc-400">
            Message (optional)
          </label>
          <textarea
            id="message"
            value={form.message}
            onChange={(e) => handleChange("message", e.target.value)}
            rows={4}
            className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
            placeholder="Tell us about your event, guest count, or special requests..."
          />
        </div>

        <div className="flex flex-wrap items-center gap-4 pt-2">
          <button
            type="submit"
            disabled={submitting || loading}
            className="rounded-full bg-[var(--pink)] px-8 py-4 font-semibold text-white hover:bg-[var(--pink-hover)] disabled:opacity-50"
          >
            {submitting ? "Sending…" : "Request Quote"}
          </button>
          <Link href="/" className="text-zinc-500 hover:text-[var(--pink)]">
            ← Back to home
          </Link>
        </div>
      </motion.form>
    </div>
  );
}
