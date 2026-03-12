import Link from "next/link";

export default function Footer() {
  return (
    <footer className="border-t border-[var(--border)] bg-[var(--card)] px-4 py-8 pr-24 sm:px-6 sm:pr-28 md:pr-32 lg:px-8 lg:pr-36">
      <div className="mx-auto max-w-7xl flex flex-col items-center justify-between gap-4 sm:flex-row">
        <p className="text-sm text-zinc-500">© {new Date().getFullYear()} 80&apos;s Jitterbug Photo Booth</p>
        <nav className="flex gap-6">
          <Link href="/privacy" className="text-sm text-zinc-500 hover:text-[var(--pink)]">
            Privacy
          </Link>
          <Link href="/terms" className="text-sm text-zinc-500 hover:text-[var(--pink)]">
            Terms
          </Link>
          <Link href="/contact" className="text-sm text-zinc-500 hover:text-[var(--pink)]">
            Contact
          </Link>
          <Link href="/admin" className="text-sm text-zinc-500 hover:text-[var(--pink)]">
            Admin
          </Link>
        </nav>
      </div>
    </footer>
  );
}
