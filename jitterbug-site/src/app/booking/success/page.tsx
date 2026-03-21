"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { useSearchParams } from "next/navigation";
import { Suspense } from "react";

function SuccessInner() {
  const searchParams = useSearchParams();
  const sessionId = searchParams.get("session_id");

  return (
    <div className="mx-auto max-w-xl px-4 py-20 sm:px-6 lg:px-8">
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        className="rounded-2xl border border-emerald-500/30 bg-[var(--card)] p-10 text-center"
      >
        <h1 className="text-2xl font-bold text-emerald-400 sm:text-3xl">Thank you!</h1>
        <p className="mt-4 text-zinc-400">
          Your deposit payment was submitted. We&apos;ll confirm by email and keep your booking reference on file.
        </p>
        {sessionId && (
          <p className="mt-4 break-all font-mono text-xs text-zinc-500">
            Session: {sessionId}
          </p>
        )}
        <p className="mt-4 text-sm text-zinc-500">
          It may take a minute for payment status to show on your booking—our server updates when Stripe notifies us.
        </p>
        <Link
          href="/booking/lookup"
          className="mt-8 inline-block text-sm text-[var(--pink)] hover:underline"
        >
          Check booking status →
        </Link>
        <Link
          href="/"
          className="mt-4 block rounded-full bg-[var(--pink)] px-6 py-3 text-center text-sm font-semibold text-white hover:bg-[var(--pink-hover)]"
        >
          Back to home
        </Link>
      </motion.div>
    </div>
  );
}

export default function BookingSuccessPage() {
  return (
    <Suspense fallback={<div className="mx-auto max-w-xl px-4 py-20 text-center text-zinc-400">Loading…</div>}>
      <SuccessInner />
    </Suspense>
  );
}
