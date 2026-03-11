"use client";

import { motion } from "framer-motion";

const fadeUp = { initial: { opacity: 0, y: 24 }, whileInView: { opacity: 1, y: 0 }, viewport: { once: true } };

export default function AboutPage() {
  return (
    <div className="min-h-screen">
      <section className="retro-grid relative overflow-hidden px-4 py-20 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold text-[var(--neon-pink)] neon-text-pink sm:text-5xl">
            Our Story
          </h1>
          <p className="mt-6 text-lg text-zinc-300">
            80&apos;s Jitterbug was born from a love of neon lights, synthwave beats, and the magic of instant photos.
          </p>
        </motion.div>
      </section>

      <section className="border-y border-[var(--electric-blue)]/20 bg-black/30 py-16 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-4xl space-y-12">
          <motion.div {...fadeUp} className="rounded-2xl border border-[var(--electric-blue)]/30 bg-black/40 p-8">
            <h2 className="text-2xl font-bold text-[var(--electric-blue)]">The Fun Retro 80s Theme</h2>
            <p className="mt-4 text-zinc-300">
              We believe the best parties feel like a time warp — bold colors, geometric grids, and that unmistakable
              energy. Our booths and backdrops are designed to transport your guests straight into an 80s music video.
              Think neon pink, electric blue, purple gradients, and props that make everyone smile. It&apos;s nostalgic
              but totally modern, so it works for every generation.
            </p>
          </motion.div>

          <motion.div {...fadeUp} className="rounded-2xl border border-[var(--neon-pink)]/30 bg-black/40 p-8 neon-border-pink">
            <h2 className="text-2xl font-bold text-[var(--neon-pink)]">Why Photo Booths Make Events Better</h2>
            <p className="mt-4 text-zinc-300">
              Photo booths aren&apos;t just fun — they&apos;re memory machines. Guests get instant prints and digital
              copies to share, so your event lives on long after the last song. They break the ice, get people mixing,
              and give everyone a keepsake. For weddings, it&apos;s a guest book that actually gets used. For corporate
              events, it&apos;s team building with a smile. For birthdays and parties, it&apos;s the highlight of the
              night. We handle setup, teardown, and unlimited photos so you can focus on enjoying the party.
            </p>
          </motion.div>

          <motion.div {...fadeUp} className="flex flex-wrap gap-6">
            <div className="flex-1 min-w-[200px] rounded-xl border border-[var(--purple)]/30 bg-black/40 p-6 text-center">
              <span className="text-4xl">📸</span>
              <h3 className="mt-2 font-bold text-[var(--purple)]">Instant Prints</h3>
              <p className="mt-1 text-sm text-zinc-400">Guests take home memories on the spot.</p>
            </div>
            <div className="flex-1 min-w-[200px] rounded-xl border border-[var(--electric-blue)]/30 bg-black/40 p-6 text-center">
              <span className="text-4xl">✨</span>
              <h3 className="mt-2 font-bold text-[var(--electric-blue)]">Unlimited Fun</h3>
              <p className="mt-1 text-sm text-zinc-400">No limit on photos — shoot all night.</p>
            </div>
            <div className="flex-1 min-w-[200px] rounded-xl border border-[var(--neon-pink)]/30 bg-black/40 p-6 text-center">
              <span className="text-4xl">🎉</span>
              <h3 className="mt-2 font-bold text-[var(--neon-pink)]">Props & Backdrops</h3>
              <p className="mt-1 text-sm text-zinc-400">Retro props and neon setups included.</p>
            </div>
          </motion.div>
        </div>
      </section>

      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <motion.div {...fadeUp} className="mx-auto max-w-2xl text-center">
          <h2 className="text-2xl font-bold text-white">Let&apos;s make your next event unforgettable.</h2>
          <p className="mt-4 text-zinc-400">
            From intimate gatherings to big celebrations — we bring the vibe, you bring the guests.
          </p>
          <motion.a
            href="/booking"
            className="mt-8 inline-block rounded-full bg-[var(--neon-pink)] px-8 py-4 font-bold text-white transition-all hover:shadow-[0_0_25px_var(--neon-pink-glow)]"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.98 }}
          >
            Book Your Booth
          </motion.a>
        </motion.div>
      </section>
    </div>
  );
}
