"use client";

import { motion } from "framer-motion";
import Link from "next/link";

const packages = [
  {
    name: "Basic Package",
    price: "$399",
    desc: "Perfect for intimate gatherings",
    hours: "3 hours",
    features: [
      "3-hour rental",
      "Unlimited photos",
      "Instant digital sharing",
      "Basic props included",
      "Setup and teardown",
    ],
    cta: "Request Quote",
    highlighted: false,
    border: "border-[var(--electric-blue)]/40",
  },
  {
    name: "Standard Package",
    price: "$599",
    desc: "Our most popular choice",
    hours: "4 hours",
    features: [
      "4-hour rental",
      "Unlimited photos",
      "Instant digital sharing",
      "Custom event template",
      "Full props collection",
      "Setup and teardown",
    ],
    cta: "Request Quote",
    highlighted: true,
    border: "border-[var(--neon-pink)]",
  },
  {
    name: "VIP Party Package",
    price: "$899",
    desc: "The ultimate experience",
    hours: "6 hours",
    features: [
      "6-hour rental",
      "Unlimited photos",
      "Instant digital sharing",
      "Custom event template",
      "Premium props + backdrop options",
      "Dedicated attendant",
      "Setup and teardown",
    ],
    cta: "Request Quote",
    highlighted: false,
    border: "border-[var(--purple)]/40",
  },
];

const fadeUp = { initial: { opacity: 0, y: 24 }, whileInView: { opacity: 1, y: 0 }, viewport: { once: true } };

export default function PackagesPage() {
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
            Packages & Pricing
          </h1>
          <p className="mt-6 text-lg text-zinc-300">
            Choose the package that fits your event. All include unlimited photos and our signature retro setup.
          </p>
        </motion.div>
      </section>

      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <div className="grid gap-8 lg:grid-cols-3">
            {packages.map((pkg, i) => (
              <motion.div
                key={pkg.name}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className={`rounded-2xl border-2 ${pkg.border} bg-black/50 p-8 ${
                  pkg.highlighted ? "neon-border-pink shadow-[0_0_30px_var(--neon-pink-glow)] lg:-mt-4 lg:scale-105" : ""
                }`}
              >
                {pkg.highlighted && (
                  <div className="mb-4 text-center">
                    <span className="rounded-full bg-[var(--neon-pink)] px-4 py-1 text-sm font-bold text-white">
                      Most Popular
                    </span>
                  </div>
                )}
                <h2 className="text-2xl font-bold text-white">{pkg.name}</h2>
                <p className="mt-1 text-zinc-400">{pkg.desc}</p>
                <p className="mt-6 text-4xl font-bold text-[var(--neon-pink)]">{pkg.price}</p>
                <p className="text-sm text-zinc-500">{pkg.hours} rental</p>
                <ul className="mt-8 space-y-3">
                  {pkg.features.map((f) => (
                    <li key={f} className="flex items-center gap-2 text-zinc-300">
                      <span className="text-[var(--electric-blue)]">✓</span> {f}
                    </li>
                  ))}
                </ul>
                <Link
                  href="/booking"
                  className={`mt-8 block w-full rounded-full py-4 text-center font-bold transition-all ${
                    pkg.highlighted
                      ? "bg-[var(--neon-pink)] text-white hover:shadow-[0_0_25px_var(--neon-pink-glow)]"
                      : "border-2 border-[var(--electric-blue)] text-[var(--electric-blue)] hover:bg-[var(--electric-blue)]/20"
                  }`}
                >
                  {pkg.cta}
                </Link>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      <section className="border-t border-[var(--electric-blue)]/20 py-12 px-4 text-center sm:px-6 lg:px-8">
        <motion.p {...fadeUp} className="text-zinc-400">
          Need a custom package? <Link href="/contact" className="text-[var(--electric-blue)] hover:underline">Contact us</Link> and we&apos;ll tailor a quote.
        </motion.p>
      </section>
    </div>
  );
}
