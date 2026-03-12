"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import NeonButton from "@/components/NeonButton";

const fadeUp = {
  initial: { opacity: 0, y: 24 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
};

const samplePackages = [
  {
    name: "Basic",
    price: "$299",
    desc: "Perfect for small gatherings and intimate events.",
    features: [
      "3 hours of booth time",
      "Unlimited digital photos",
      "Retro backdrop & basic props",
      "Online gallery for guests",
      "Setup & teardown included",
    ],
    cta: "Request quote",
    highlighted: false,
  },
  {
    name: "Standard",
    price: "$449",
    desc: "Our most popular package for weddings and parties.",
    features: [
      "4 hours of booth time",
      "Unlimited prints + digital",
      "Neon backdrop & full prop kit",
      "Custom branding on prints",
      "Online gallery + same-day share",
      "Dedicated attendant",
    ],
    cta: "Request quote",
    highlighted: true,
  },
  {
    name: "VIP",
    price: "$649",
    desc: "The full experience for premium events.",
    features: [
      "6 hours of booth time",
      "Unlimited prints + digital",
      "Premium neon setup & green screen option",
      "Custom backdrop & branding",
      "Priority booking & flexible timing",
      "Full prop kit + attendant",
      "Extended online gallery access",
    ],
    cta: "Request quote",
    highlighted: false,
  },
];

export default function PackagesPage() {
  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden retro-grid px-4 pt-16 pb-12 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold leading-tight text-[var(--pink)] sm:text-5xl lg:text-6xl">
            Packages & Pricing
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-lg text-zinc-400 sm:text-xl">
            Choose the package that fits your event. All include our signature 80s vibe, unlimited fun, and professional service.
          </p>
        </motion.div>
      </section>

      {/* Packages grid */}
      <section className="px-4 pb-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <div className="grid gap-8 lg:grid-cols-3">
            {samplePackages.map((pkg, i) => (
              <motion.article
                key={pkg.name}
                initial={{ opacity: 0, y: 24 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.1, duration: 0.4 }}
                className={`relative flex flex-col rounded-2xl border bg-[var(--card)] p-8 ${
                  pkg.highlighted
                    ? "border-[var(--pink)]/50 shadow-[0_0_30px_rgba(236,72,153,0.15)]"
                    : "border-[var(--border)]"
                }`}
              >
                {pkg.highlighted && (
                  <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-[var(--pink)] px-4 py-1 text-xs font-semibold text-white">
                    Most popular
                  </span>
                )}
                <h2 className="text-2xl font-bold text-[var(--pink)]">{pkg.name}</h2>
                <p className="mt-2 text-3xl font-bold text-white">{pkg.price}</p>
                <p className="mt-2 text-sm text-zinc-400">{pkg.desc}</p>
                <ul className="mt-6 flex-1 space-y-3">
                  {pkg.features.map((feature) => (
                    <li key={feature} className="flex gap-2 text-sm text-zinc-300">
                      <span className="text-[var(--pink)]">✓</span>
                      {feature}
                    </li>
                  ))}
                </ul>
                <div className="mt-8">
                  <Link
                    href="/booking"
                    className={`inline-block w-full rounded-full py-3 text-center font-semibold transition-all ${
                      pkg.highlighted
                        ? "bg-[var(--pink)] text-white hover:bg-[var(--pink-hover)]"
                        : "border-2 border-[var(--pink)] text-[var(--pink)] hover:bg-[var(--pink-muted)]"
                    }`}
                  >
                    {pkg.cta}
                  </Link>
                </div>
              </motion.article>
            ))}
          </div>

          <motion.div
            {...fadeUp}
            className="mt-16 text-center"
          >
            <p className="text-zinc-500">
              Prices may vary by date, location, and add-ons. We&apos;ll confirm your final quote when you request a booking.
            </p>
            <div className="mt-6">
              <NeonButton href="/booking">Get a Custom Quote</NeonButton>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  );
}
