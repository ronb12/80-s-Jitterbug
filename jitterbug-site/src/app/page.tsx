"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import NeonButton from "@/components/NeonButton";

const testimonials = [
  {
    quote: "Our wedding guests couldn't get enough of the 80's Jitterbug booth! The neon setup was a total hit.",
    name: "Sarah & Mike",
    event: "Wedding",
  },
  {
    quote: "Best corporate event we've ever had. Professional setup and so much fun.",
    name: "TechStart Inc.",
    event: "Corporate Party",
  },
  {
    quote: "My daughter's 16th birthday was unforgettable. Everyone loved the retro props!",
    name: "Jennifer L.",
    event: "Birthday Party",
  },
];

const featuredEvents = [
  { title: "Weddings", icon: "💒", desc: "Say I do with style" },
  { title: "Birthdays", icon: "🎂", desc: "Celebrate in neon" },
  { title: "Corporate", icon: "🏢", desc: "Team building, retro style" },
  { title: "Parties", icon: "🎉", desc: "Any occasion" },
];

const galleryImages = [
  { id: 1, alt: "Photo booth at wedding" },
  { id: 2, alt: "Guests with props" },
  { id: 3, alt: "Neon backdrop" },
  { id: 4, alt: "Birthday party" },
  { id: 5, alt: "Corporate event" },
  { id: 6, alt: "Couple in booth" },
];

const fadeUp = { initial: { opacity: 0, y: 30 }, whileInView: { opacity: 1, y: 0 }, viewport: { once: true } };
const staggerParent = {
  initial: { opacity: 0 },
  whileInView: { opacity: 1, transition: { staggerChildren: 0.1 } },
};

export default function Home() {
  return (
    <div>
      {/* Hero */}
      <section className="relative min-h-[90vh] overflow-hidden retro-grid px-4 pt-12 pb-24 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <div className="relative mx-auto max-w-5xl pt-16 text-center sm:pt-24">
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="text-4xl font-bold leading-tight text-[var(--neon-pink)] neon-text-pink sm:text-5xl md:text-6xl lg:text-7xl"
          >
            Bring the Party to Life with 80&apos;s Jitterbug Photo Booth!
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.6 }}
            className="mx-auto mt-6 max-w-2xl text-lg text-zinc-300 sm:text-xl"
          >
            Retro fun. Instant memories. The ultimate photo booth experience for weddings, birthdays, and corporate events.
          </motion.p>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4, duration: 0.6 }}
            className="mt-10"
          >
            <NeonButton href="/booking">Book Your Booth</NeonButton>
          </motion.div>
        </div>
        {/* Sample booth visual */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.6, duration: 0.5 }}
          className="relative mx-auto mt-12 max-w-md rounded-2xl border-2 border-[var(--electric-blue)]/50 bg-black/60 p-4 neon-border-blue"
        >
          <div className="aspect-[4/3] rounded-lg bg-gradient-to-br from-[var(--neon-pink)]/20 to-[var(--purple)]/20 flex items-center justify-center text-4xl">
            📸✨
          </div>
          <p className="mt-2 text-center text-sm text-[var(--electric-blue)]">Your event. Your memories.</p>
        </motion.div>
      </section>

      {/* Testimonials */}
      <section className="border-y border-[var(--electric-blue)]/20 bg-black/30 py-16 px-4 sm:px-6 lg:px-8">
        <motion.h2
          {...fadeUp}
          transition={{ duration: 0.5 }}
          className="text-center text-3xl font-bold text-[var(--electric-blue)] sm:text-4xl"
        >
          What People Are Saying
        </motion.h2>
        <motion.div
          variants={staggerParent}
          initial="initial"
          whileInView="whileInView"
          viewport={{ once: true }}
          className="mx-auto mt-12 grid max-w-5xl gap-8 sm:grid-cols-3"
        >
          {testimonials.map((t, i) => (
            <motion.div
              key={t.name}
              variants={fadeUp}
              className="rounded-xl border border-[var(--neon-pink)]/30 bg-black/40 p-6 neon-border-pink"
            >
              <p className="text-zinc-300">&ldquo;{t.quote}&rdquo;</p>
              <p className="mt-4 font-semibold text-[var(--neon-pink)]">{t.name}</p>
              <p className="text-sm text-zinc-500">{t.event}</p>
            </motion.div>
          ))}
        </motion.div>
      </section>

      {/* Featured events */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <motion.h2 {...fadeUp} className="text-center text-3xl font-bold text-[var(--electric-blue)] sm:text-4xl">
          Perfect For Every Occasion
        </motion.h2>
        <motion.div
          variants={staggerParent}
          initial="initial"
          whileInView="whileInView"
          viewport={{ once: true }}
          className="mx-auto mt-12 grid max-w-4xl gap-6 sm:grid-cols-2 lg:grid-cols-4"
        >
          {featuredEvents.map((e) => (
            <motion.div
              key={e.title}
              variants={fadeUp}
              className="rounded-xl border border-[var(--electric-blue)]/30 bg-black/30 p-6 text-center transition-all hover:border-[var(--neon-pink)]/50 hover:shadow-[0_0_20px_var(--neon-pink-glow)]"
            >
              <span className="text-4xl">{e.icon}</span>
              <h3 className="mt-2 text-xl font-bold text-white">{e.title}</h3>
              <p className="text-sm text-zinc-400">{e.desc}</p>
            </motion.div>
          ))}
        </motion.div>
      </section>

      {/* Quick pricing preview */}
      <section className="border-y border-[var(--electric-blue)]/20 bg-black/30 py-16 px-4 sm:px-6 lg:px-8">
        <motion.h2 {...fadeUp} className="text-center text-3xl font-bold text-[var(--electric-blue)] sm:text-4xl">
          Packages That Pop
        </motion.h2>
        <motion.p {...fadeUp} className="mx-auto mt-4 max-w-xl text-center text-zinc-400">
          From intimate gatherings to full-blown parties — we&apos;ve got you covered.
        </motion.p>
        <motion.div
          variants={staggerParent}
          initial="initial"
          whileInView="whileInView"
          viewport={{ once: true }}
          className="mx-auto mt-12 flex max-w-4xl flex-col gap-6 lg:flex-row lg:justify-center"
        >
          {["Basic", "Standard", "VIP"].map((name, i) => (
            <motion.div
              key={name}
              variants={fadeUp}
              className="flex-1 rounded-xl border-2 border-[var(--electric-blue)]/40 bg-black/50 p-6 text-center"
            >
              <h3 className="text-xl font-bold text-[var(--neon-pink)]">{name}</h3>
              <p className="mt-2 text-sm text-zinc-400">Unlimited photos • Props • Digital sharing</p>
              <Link
                href="/packages"
                className="mt-4 inline-block text-sm font-semibold text-[var(--electric-blue)] hover:underline"
              >
                View details →
              </Link>
            </motion.div>
          ))}
        </motion.div>
        <motion.div {...fadeUp} className="mt-8 text-center">
          <NeonButton href="/packages" variant="blue">
            See All Packages
          </NeonButton>
        </motion.div>
      </section>

      {/* Instagram-style gallery */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <motion.h2 {...fadeUp} className="text-center text-3xl font-bold text-[var(--electric-blue)] sm:text-4xl">
          From Our Events
        </motion.h2>
        <motion.div
          variants={staggerParent}
          initial="initial"
          whileInView="whileInView"
          viewport={{ once: true }}
          className="mx-auto mt-12 grid max-w-4xl grid-cols-2 gap-4 md:grid-cols-3"
        >
          {galleryImages.map((img) => (
            <motion.div
              key={img.id}
              variants={fadeUp}
              className="group relative aspect-square overflow-hidden rounded-xl border border-[var(--electric-blue)]/30 transition-all hover:border-[var(--neon-pink)] hover:shadow-[0_0_20px_var(--neon-pink-glow)]"
            >
              <div className="absolute inset-0 bg-gradient-to-br from-[var(--neon-pink)]/30 via-[var(--purple)]/30 to-[var(--electric-blue)]/30 transition-transform group-hover:scale-110" />
              <div className="absolute inset-0 flex items-center justify-center text-5xl opacity-80 group-hover:scale-110 group-hover:opacity-100">
                📸
              </div>
            </motion.div>
          ))}
        </motion.div>
        <motion.div {...fadeUp} className="mt-8 text-center">
          <NeonButton href="/gallery" variant="outline">
            View Full Gallery
          </NeonButton>
        </motion.div>
      </section>

      {/* Final CTA */}
      <section className="border-t border-[var(--electric-blue)]/20 py-16 px-4 sm:px-6 lg:px-8">
        <motion.div {...fadeUp} className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-bold text-white sm:text-4xl">
            Ready to Bring the Retro Vibes?
          </h2>
          <p className="mt-4 text-zinc-400">
            Get in touch and we&apos;ll help you plan the perfect photo booth experience.
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
