"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { submitBooking } from "@/lib/booking-service";
import type { BookingFormData } from "@/lib/booking-types";

const eventTypes = ["Wedding", "Birthday", "Corporate Event", "Party", "Other"];
const packageOptions = ["Basic Package", "Standard Package", "VIP Party Package"];

type Errors = Partial<Record<keyof BookingFormData, string>>;

const initial: BookingFormData = {
  name: "",
  email: "",
  phone: "",
  eventType: "",
  eventDate: "",
  eventLocation: "",
  package: "",
  message: "",
};

function validate(form: BookingFormData): Errors {
  const err: Errors = {};
  if (!form.name.trim()) err.name = "Name is required";
  if (!form.email.trim()) err.email = "Email is required";
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) err.email = "Please enter a valid email";
  if (!form.phone.trim()) err.phone = "Phone is required";
  if (!form.eventType) err.eventType = "Please select an event type";
  if (!form.eventDate) err.eventDate = "Event date is required";
  if (!form.eventLocation.trim()) err.eventLocation = "Event location is required";
  if (!form.package) err.package = "Please select a package";
  return err;
}

export default function BookingPage() {
  const [form, setForm] = useState<BookingFormData>(initial);
  const [errors, setErrors] = useState<Errors>({});
  const [submitted, setSubmitted] = useState(false);
  const [bookingRef, setBookingRef] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    if (errors[name as keyof BookingFormData]) setErrors((prev) => ({ ...prev, [name]: undefined }));
    setSubmitError(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const nextErrors = validate(form);
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) return;

    setLoading(true);
    setSubmitError(null);
    try {
      const { bookingRef: ref } = await submitBooking(form);
      setBookingRef(ref);
      setSubmitted(true);
    } catch (err) {
      setSubmitError(err instanceof Error ? err.message : "Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  if (submitted && bookingRef) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="mx-auto max-w-lg rounded-2xl border-2 border-[var(--electric-blue)] bg-black/50 p-8 text-center"
        >
          <span className="text-5xl">✨</span>
          <h1 className="mt-4 text-2xl font-bold text-[var(--electric-blue)]">Request Received!</h1>
          <p className="mt-2 text-zinc-300">
            Thanks for your interest in 80&apos;s Jitterbug. We&apos;ll get back to you with a quote soon.
          </p>
          <p className="mt-6 rounded-lg bg-white/5 py-3 font-mono text-lg font-bold text-[var(--neon-pink)]">
            Your booking reference: {bookingRef}
          </p>
          <p className="mt-2 text-sm text-zinc-500">
            Save this number — you can use it when you contact us.
          </p>
          <Link
            href="/"
            className="mt-8 inline-block rounded-full bg-[var(--neon-pink)] px-8 py-3 font-bold text-white transition-all hover:shadow-[0_0_25px_var(--neon-pink-glow)]"
          >
            Back to Home
          </Link>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      <section className="retro-grid relative overflow-hidden px-4 py-16 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold text-[var(--neon-pink)] neon-text-pink sm:text-5xl">
            Book Your Booth
          </h1>
          <p className="mt-6 text-lg text-zinc-300">
            Fill out the form below and we&apos;ll send you a custom quote.
          </p>
        </motion.div>
      </section>

      <section className="py-12 px-4 sm:px-6 lg:px-8">
        <motion.form
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          onSubmit={handleSubmit}
          className="mx-auto max-w-2xl rounded-2xl border border-[var(--electric-blue)]/30 bg-black/40 p-8"
        >
          {submitError && (
            <div className="mb-6 rounded-lg border border-[var(--neon-pink)] bg-[var(--neon-pink)]/10 px-4 py-3 text-[var(--neon-pink)]">
              {submitError}
            </div>
          )}

          <div className="grid gap-6 sm:grid-cols-2">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-zinc-300">
                Name *
              </label>
              <input
                id="name"
                name="name"
                type="text"
                value={form.name}
                onChange={handleChange}
                disabled={loading}
                className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
                placeholder="Your name"
              />
              {errors.name && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.name}</p>}
            </div>
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-zinc-300">
                Email *
              </label>
              <input
                id="email"
                name="email"
                type="email"
                value={form.email}
                onChange={handleChange}
                disabled={loading}
                className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
                placeholder="you@example.com"
              />
              {errors.email && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.email}</p>}
            </div>
          </div>

          <div className="mt-6">
            <label htmlFor="phone" className="block text-sm font-medium text-zinc-300">
              Phone *
            </label>
            <input
              id="phone"
              name="phone"
              type="tel"
              value={form.phone}
              onChange={handleChange}
              disabled={loading}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
              placeholder="(555) 123-4567"
            />
            {errors.phone && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.phone}</p>}
          </div>

          <div className="mt-6 grid gap-6 sm:grid-cols-2">
            <div>
              <label htmlFor="eventType" className="block text-sm font-medium text-zinc-300">
                Event Type *
              </label>
              <select
                id="eventType"
                name="eventType"
                value={form.eventType}
                onChange={handleChange}
                disabled={loading}
                className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
              >
                <option value="">Select event type</option>
                {eventTypes.map((t) => (
                  <option key={t} value={t}>
                    {t}
                  </option>
                ))}
              </select>
              {errors.eventType && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.eventType}</p>}
            </div>
            <div>
              <label htmlFor="eventDate" className="block text-sm font-medium text-zinc-300">
                Event Date *
              </label>
              <input
                id="eventDate"
                name="eventDate"
                type="date"
                value={form.eventDate}
                onChange={handleChange}
                disabled={loading}
                className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
              />
              {errors.eventDate && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.eventDate}</p>}
            </div>
          </div>

          <div className="mt-6">
            <label htmlFor="eventLocation" className="block text-sm font-medium text-zinc-300">
              Event Location *
            </label>
            <input
              id="eventLocation"
              name="eventLocation"
              type="text"
              value={form.eventLocation}
              onChange={handleChange}
              disabled={loading}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
              placeholder="Venue name and city"
            />
            {errors.eventLocation && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.eventLocation}</p>}
          </div>

          <div className="mt-6">
            <label htmlFor="package" className="block text-sm font-medium text-zinc-300">
              Package *
            </label>
            <select
              id="package"
              name="package"
              value={form.package}
              onChange={handleChange}
              disabled={loading}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
            >
              <option value="">Select a package</option>
              {packageOptions.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>
            {errors.package && <p className="mt-1 text-sm text-[var(--neon-pink)]">{errors.package}</p>}
          </div>

          <div className="mt-6">
            <label htmlFor="message" className="block text-sm font-medium text-zinc-300">
              Message
            </label>
            <textarea
              id="message"
              name="message"
              rows={4}
              value={form.message}
              onChange={handleChange}
              disabled={loading}
              className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)] disabled:opacity-60"
              placeholder="Tell us about your event..."
            />
          </div>

          <div className="mt-8">
            <button
              type="submit"
              disabled={loading}
              className="w-full rounded-full bg-[var(--neon-pink)] py-4 font-bold text-white transition-all hover:shadow-[0_0_25px_var(--neon-pink-glow)] disabled:opacity-60 disabled:cursor-not-allowed"
            >
              {loading ? "Submitting…" : "Request Quote"}
            </button>
          </div>
        </motion.form>
      </section>
    </div>
  );
}
