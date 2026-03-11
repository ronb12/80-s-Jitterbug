"use client";

import Link from "next/link";
import { motion } from "framer-motion";

export default function FloatingBookNow() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 1, duration: 0.4 }}
      className="fixed bottom-6 right-6 z-40 md:bottom-8 md:right-8"
    >
      <Link
        href="/booking"
        className="flex items-center gap-2 rounded-full bg-[var(--neon-pink)] px-6 py-4 font-bold text-white shadow-[0_0_25px_var(--neon-pink-glow)] transition-all hover:scale-105 hover:shadow-[0_0_35px_var(--neon-pink-glow)]"
      >
        <span>Book Now</span>
        <span className="text-xl">✨</span>
      </Link>
    </motion.div>
  );
}
