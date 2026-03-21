import Link from "next/link";

export default function NotFound() {
  return (
    <div className="min-h-[70vh] flex flex-col items-center justify-center px-4">
      <h1 className="text-4xl font-bold text-[var(--pink)] sm:text-5xl">404</h1>
      <p className="mt-4 text-lg text-zinc-400">This page doesn&apos;t exist.</p>
      <div className="mt-8 flex flex-wrap justify-center gap-4">
        <Link
          href="/"
          className="rounded-full bg-[var(--pink)] px-6 py-3 font-semibold text-white hover:bg-[var(--pink-hover)]"
        >
          Home
        </Link>
        <Link href="/contact" className="rounded-full border-2 border-[var(--pink)] px-6 py-3 font-semibold text-[var(--pink)] hover:bg-[var(--pink-muted)]">
          Contact
        </Link>
      </div>
    </div>
  );
}
