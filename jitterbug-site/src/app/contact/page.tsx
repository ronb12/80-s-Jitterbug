"use client";

import { useState } from "react";
import { motion } from "framer-motion";

export default function ContactPage() {
  const [form, setForm] = useState({ name: "", email: "", subject: "", message: "" });
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSent(true);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  if (sent) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="mx-auto max-w-lg rounded-2xl border-2 border-[var(--electric-blue)] bg-black/50 p-8 text-center"
        >
          <span className="text-5xl">📬</span>
          <h1 className="mt-4 text-2xl font-bold text-[var(--electric-blue)]">Message Sent!</h1>
          <p className="mt-2 text-zinc-300">We&apos;ll get back to you soon.</p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      <section className="retro-grid relative overflow-hidden px-4 py-20 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold text-[var(--electric-blue)] neon-text-blue sm:text-5xl">
            Contact Us
          </h1>
          <p className="mt-6 text-lg text-zinc-300">
            Have a question? We&apos;d love to hear from you.
          </p>
        </motion.div>
      </section>

      <section className="py-12 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-4xl">
          <div className="grid gap-12 lg:grid-cols-2">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.2 }}
              className="space-y-6"
            >
              <div className="rounded-xl border border-[var(--electric-blue)]/30 bg-black/40 p-6">
                <h3 className="text-lg font-bold text-[var(--electric-blue)]">Email</h3>
                <a href="mailto:hello@80sjitterbug.com" className="mt-2 block text-zinc-300 hover:text-[var(--neon-pink)]">
                  hello@80sjitterbug.com
                </a>
              </div>
              <div className="rounded-xl border border-[var(--neon-pink)]/30 bg-black/40 p-6">
                <h3 className="text-lg font-bold text-[var(--neon-pink)]">Phone</h3>
                <a href="tel:+15551234567" className="mt-2 block text-zinc-300 hover:text-[var(--electric-blue)]">
                  (555) 123-4567
                </a>
              </div>
              <div className="rounded-xl border border-[var(--purple)]/30 bg-black/40 p-6">
                <h3 className="text-lg font-bold text-[var(--purple)]">Social</h3>
                <div className="mt-2 flex gap-4">
                  <a href="https://instagram.com" target="_blank" rel="noopener noreferrer" className="text-2xl hover:opacity-80" aria-label="Instagram">📷</a>
                  <a href="https://facebook.com" target="_blank" rel="noopener noreferrer" className="text-2xl hover:opacity-80" aria-label="Facebook">👤</a>
                  <a href="https://pinterest.com" target="_blank" rel="noopener noreferrer" className="text-2xl hover:opacity-80" aria-label="Pinterest">📌</a>
                </div>
              </div>
            </motion.div>

            <motion.form
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
              onSubmit={handleSubmit}
              className="rounded-2xl border border-[var(--electric-blue)]/30 bg-black/40 p-8"
            >
              <div className="space-y-4">
                <div>
                  <label htmlFor="contact-name" className="block text-sm font-medium text-zinc-300">Name</label>
                  <input
                    id="contact-name"
                    name="name"
                    type="text"
                    value={form.name}
                    onChange={handleChange}
                    className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)]"
                  />
                </div>
                <div>
                  <label htmlFor="contact-email" className="block text-sm font-medium text-zinc-300">Email</label>
                  <input
                    id="contact-email"
                    name="email"
                    type="email"
                    value={form.email}
                    onChange={handleChange}
                    className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)]"
                  />
                </div>
                <div>
                  <label htmlFor="contact-subject" className="block text-sm font-medium text-zinc-300">Subject</label>
                  <input
                    id="contact-subject"
                    name="subject"
                    type="text"
                    value={form.subject}
                    onChange={handleChange}
                    className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)]"
                  />
                </div>
                <div>
                  <label htmlFor="contact-message" className="block text-sm font-medium text-zinc-300">Message</label>
                  <textarea
                    id="contact-message"
                    name="message"
                    rows={4}
                    value={form.message}
                    onChange={handleChange}
                    className="mt-1 w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white focus:border-[var(--electric-blue)] focus:outline-none focus:ring-1 focus:ring-[var(--electric-blue)]"
                  />
                </div>
                <button
                  type="submit"
                  className="w-full rounded-full bg-[var(--neon-pink)] py-4 font-bold text-white transition-all hover:shadow-[0_0_25px_var(--neon-pink-glow)]"
                >
                  Send Message
                </button>
              </div>
            </motion.form>
          </div>
        </div>
      </section>
    </div>
  );
}
