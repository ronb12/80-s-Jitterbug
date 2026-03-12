"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { listGalleryPhotos, type GalleryPhoto } from "@/lib/gallery-service";

export default function GalleryPage() {
  const [photos, setPhotos] = useState<GalleryPhoto[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    listGalleryPhotos().then(setPhotos).finally(() => setLoading(false));
  }, []);

  return (
    <div className="min-h-screen">
      <section className="retro-grid relative overflow-hidden px-4 py-20 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="relative mx-auto max-w-4xl text-center"
        >
          <h1 className="text-4xl font-bold text-[var(--pink)] sm:text-5xl">
            Gallery
          </h1>
          <p className="mt-6 text-lg text-zinc-300">
            A peek at the fun we bring to weddings, parties, and corporate events.
          </p>
        </motion.div>
      </section>

      <section className="py-16 px-4 sm:px-6 lg:px-8">
        {loading && (
          <p className="text-center text-zinc-500">Loading gallery…</p>
        )}
        {!loading && photos.length === 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mx-auto max-w-xl rounded-2xl border border-[var(--pink)]/30 bg-black/40 p-10 text-center"
          >
            <span className="text-5xl" aria-hidden>📸</span>
            <h2 className="mt-4 text-xl font-bold text-white">Coming soon</h2>
            <p className="mt-3 text-zinc-400">
              We&apos;re just getting started! Photos from our events will appear here soon. Book us for your next party and you could be in our first gallery.
            </p>
            <Link
              href="/booking"
              className="mt-8 inline-block rounded-full bg-[var(--pink)] px-8 py-3 font-semibold text-white transition-colors hover:bg-[var(--pink-hover)]"
            >
              Request a booking
            </Link>
          </motion.div>
        )}
        {!loading && photos.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={{
              hidden: {},
              visible: { transition: { staggerChildren: 0.05 } },
            }}
            className="mx-auto max-w-6xl"
          >
            <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
              {photos.map((photo, i) => (
                <motion.figure
                  key={photo.id}
                  variants={{ hidden: { opacity: 0, y: 12 }, visible: { opacity: 1, y: 0 } }
                }
                  className="group overflow-hidden rounded-xl border border-[var(--border)] transition-colors hover:border-[var(--pink)]/50"
                >
                  <div className="aspect-square bg-zinc-900">
                    <img
                      src={photo.url}
                      alt={photo.caption || `Gallery photo ${i + 1}`}
                      className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                    />
                  </div>
                  {photo.caption && (
                    <figcaption className="p-3 text-center text-sm text-zinc-400">
                      {photo.caption}
                    </figcaption>
                  )}
                </motion.figure>
              ))}
            </div>
          </motion.div>
        )}
      </section>
    </div>
  );
}
