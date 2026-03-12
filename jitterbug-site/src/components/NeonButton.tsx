"use client";

import Link from "next/link";
import { motion } from "framer-motion";

type Props = {
  href: string;
  children: React.ReactNode;
  variant?: "pink" | "outline";
  className?: string;
};

export default function NeonButton({ href, children, variant = "pink", className = "" }: Props) {
  const base = "inline-flex items-center justify-center rounded-full px-8 py-4 font-semibold transition-all";
  const variants = {
    pink: "bg-[var(--pink)] text-white hover:bg-[var(--pink-hover)]",
    outline: "border-2 border-[var(--pink)] text-[var(--pink)] hover:bg-[var(--pink-muted)]",
  };

  return (
    <motion.span whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
      <Link href={href} className={`${base} ${variants[variant]} ${className}`}>
        {children}
      </Link>
    </motion.span>
  );
}
