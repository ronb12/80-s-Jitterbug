"use client";

import Link from "next/link";
import { motion } from "framer-motion";

type Props = {
  href: string;
  children: React.ReactNode;
  variant?: "pink" | "blue" | "outline";
  className?: string;
};

export default function NeonButton({ href, children, variant = "pink", className = "" }: Props) {
  const base = "inline-flex items-center justify-center rounded-full px-8 py-4 font-bold transition-all";
  const variants = {
    pink: "bg-[var(--neon-pink)] text-white hover:shadow-[0_0_25px_var(--neon-pink-glow)]",
    blue: "bg-[var(--electric-blue)] text-[var(--background)] hover:shadow-[0_0_25px_var(--electric-blue-glow)]",
    outline: "border-2 border-[var(--electric-blue)] text-[var(--electric-blue)] hover:bg-[var(--electric-blue)]/20",
  };

  return (
    <motion.span whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
      <Link href={href} className={`${base} ${variants[variant]} ${className}`}>
        {children}
      </Link>
    </motion.span>
  );
}
