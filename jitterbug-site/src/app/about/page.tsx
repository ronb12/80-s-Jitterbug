"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import NeonButton from "@/components/NeonButton";

const fadeUp = {
  initial: { opacity: 0, y: 24 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
};

export default function AboutPage() {
  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden retro-grid px-4 pt-16 pb-20 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold leading-tight text-[var(--pink)] sm:text-5xl lg:text-6xl">
            About 80&apos;s Jitterbug
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-lg text-zinc-400 sm:text-xl">
            Professional photo booth rentals with a retro twist. We bring the fun, the neon, and the memories.
          </p>
        </motion.div>
      </section>

      {/* Our Story */}
      <section className="border-y border-[var(--border)] bg-[var(--card)] py-16 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl">
          <motion.h2
            {...fadeUp}
            className="text-2xl font-bold text-white sm:text-3xl"
          >
            Our Story
          </motion.h2>
          <motion.div
            {...fadeUp}
            className="mt-6 space-y-4 text-zinc-400 leading-relaxed"
          >
            <p>
              80&apos;s Jitterbug was born from a simple idea: every celebration deserves a moment of pure, unscripted fun. We combine the energy of the 80s—neon lights, bold colors, and that carefree vibe—with modern photo booth technology so your guests get instant, shareable memories.
            </p>
            <p>
              Whether it&apos;s a wedding, birthday, corporate event, or party, we show up with a polished setup, professional service, and an eye for the details. Our goal is to make your job as the host easy while giving your guests something they&apos;ll talk about long after the last song plays.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Why Photo Booths */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-4xl">
          <motion.h2
            {...fadeUp}
            className="text-center text-2xl font-bold text-white sm:text-3xl"
          >
            Why a Photo Booth?
          </motion.h2>
          <motion.p
            {...fadeUp}
            className="mx-auto mt-4 max-w-2xl text-center text-zinc-400"
          >
            Photo booths aren&apos;t just a novelty—they&apos;re a proven way to bring people together and create keepsakes that last.
          </motion.p>
          <ul className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {[
              {
                title: "Break the ice",
                desc: "Guests who might not mingle naturally end up laughing together in front of the camera.",
                icon: "🤝",
              },
              {
                title: "Instant takeaways",
                desc: "Print or digital—everyone leaves with a tangible memory from your event.",
                icon: "📸",
              },
              {
                title: "Social-ready content",
                desc: "Shareable photos and boomerangs that extend the buzz of your event online.",
                icon: "✨",
              },
            ].map((item, i) => (
              <motion.li
                key={item.title}
                {...fadeUp}
                className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6"
              >
                <span className="text-3xl">{item.icon}</span>
                <h3 className="mt-3 font-semibold text-white">{item.title}</h3>
                <p className="mt-2 text-sm text-zinc-400">{item.desc}</p>
              </motion.li>
            ))}
          </ul>
        </div>
      </section>

      {/* What We Offer */}
      <section className="border-y border-[var(--border)] bg-[var(--card)] py-16 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl">
          <motion.h2
            {...fadeUp}
            className="text-2xl font-bold text-white sm:text-3xl"
          >
            What We Offer
          </motion.h2>
          <motion.ul
            {...fadeUp}
            className="mt-8 space-y-4 text-zinc-400"
          >
            <li className="flex gap-3">
              <span className="text-[var(--pink)]">•</span>
              <span><strong className="text-zinc-300">Professional setup & teardown</strong> — We handle everything so you can enjoy your own event.</span>
            </li>
            <li className="flex gap-3">
              <span className="text-[var(--pink)]">•</span>
              <span><strong className="text-zinc-300">Retro 80s styling</strong> — Neon backdrops, props, and a vibe that stands out from typical booths.</span>
            </li>
            <li className="flex gap-3">
              <span className="text-[var(--pink)]">•</span>
              <span><strong className="text-zinc-300">Unlimited photos</strong> — No per-print nickel-and-diming; we want everyone to take as many as they like.</span>
            </li>
            <li className="flex gap-3">
              <span className="text-[var(--pink)]">•</span>
              <span><strong className="text-zinc-300">Digital delivery</strong> — Guests can access and share their photos online after the event.</span>
            </li>
            <li className="flex gap-3">
              <span className="text-[var(--pink)]">•</span>
              <span><strong className="text-zinc-300">Flexible packages</strong> — From intimate gatherings to full-blown parties, we have options that scale.</span>
            </li>
          </motion.ul>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <motion.div
          {...fadeUp}
          className="mx-auto max-w-2xl rounded-2xl border border-[var(--pink)]/30 bg-[var(--card)] p-10 text-center"
        >
          <h2 className="text-2xl font-bold text-white sm:text-3xl">
            Ready to Bring the Retro Vibes?
          </h2>
          <p className="mt-4 text-zinc-400">
            Tell us about your event and we&apos;ll put together a quote. No obligation—just a quick, friendly conversation.
          </p>
          <div className="mt-8 flex flex-wrap justify-center gap-4">
            <NeonButton href="/booking">Request a Quote</NeonButton>
            <NeonButton href="/contact" variant="outline">
              Contact Us
            </NeonButton>
          </div>
        </motion.div>
      </section>
    </div>
  );
}
