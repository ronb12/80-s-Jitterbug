"use client";

import { motion } from "framer-motion";

const images = Array.from({ length: 12 }, (_, i) => ({
  id: i + 1,
  alt: `Photo booth moment ${i + 1}`,
  gradient: [
    "from-[var(--neon-pink)]/40 to-[var(--purple)]/40",
    "from-[var(--electric-blue)]/40 to-[var(--neon-pink)]/40",
    "from-[var(--purple)]/40 to-[var(--electric-blue)]/40",
  ][i % 3],
}));

export default function GalleryPage() {
  return (
    <div className="min-h-screen">
      <section className="retro-grid relative overflow-hidden px-4 py-20 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold text-[var(--neon-pink)] neon-text-pink sm:text-5xl">
            Gallery
          </h1>
          <p className="mt-6 text-lg text-zinc-300">
            A peek at the fun we bring to weddings, parties, and corporate events.
          </p>
        </motion.div>
      </section>

      <section className="py-12 px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <motion.div
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={{
              hidden: {},
              visible: { transition: { staggerChildren: 0.06 } },
            }}
            className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4"
          >
            {images.map((img) => (
              <motion.div
                key={img.id}
                variants={{
                  hidden: { opacity: 0, scale: 0.9 },
                  visible: { opacity: 1, scale: 1 },
                }}
                className="group relative aspect-square overflow-hidden rounded-xl border border-[var(--electric-blue)]/30 transition-all hover:border-[var(--neon-pink)] hover:shadow-[0_0_25px_var(--neon-pink-glow)]"
              >
                <div
                  className={`absolute inset-0 bg-gradient-to-br ${img.gradient} transition-transform duration-300 group-hover:scale-110`}
                />
                <div className="absolute inset-0 flex items-center justify-center text-5xl opacity-70 transition-all group-hover:scale-110 group-hover:opacity-100">
                  📸
                </div>
                <div className="absolute inset-0 bg-black/0 transition-colors group-hover:bg-black/20" />
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>
    </div>
  );
}
