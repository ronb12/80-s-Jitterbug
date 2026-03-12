import Link from "next/link";
import { contactEmail, contactPhone, contactPhoneTel } from "@/lib/contact";

export default function ContactPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8">
      <h1 className="text-3xl font-bold text-white">Contact Us</h1>
      <p className="mt-4 text-lg text-zinc-400">
        Get in touch for photo booth rentals. We&apos;d love to hear about your event.
      </p>

      <div className="mt-12 space-y-8">
        <section className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-8">
          <h2 className="text-xl font-semibold text-[var(--pink)]">Email</h2>
          <p className="mt-2 text-zinc-400">
            For quotes, bookings, or general questions:
          </p>
          <a
            href={`mailto:${contactEmail}`}
            className="mt-3 inline-block text-lg font-medium text-white underline decoration-[var(--pink)] underline-offset-2 hover:text-[var(--pink)]"
          >
            {contactEmail}
          </a>
        </section>

        <section className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-8">
          <h2 className="text-xl font-semibold text-[var(--pink)]">Phone</h2>
          <p className="mt-2 text-zinc-400">
            Call or text to discuss your event:
          </p>
          <a
            href={`tel:${contactPhoneTel}`}
            className="mt-3 inline-block text-lg font-medium text-white underline decoration-[var(--pink)] underline-offset-2 hover:text-[var(--pink)]"
          >
            {contactPhone}
          </a>
        </section>

        <section className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-8">
          <h2 className="text-xl font-semibold text-[var(--pink)]">Request a Quote</h2>
          <p className="mt-2 text-zinc-400">
            Prefer to send event details online? Use our booking form and we&apos;ll get back to you with availability and pricing.
          </p>
          <Link
            href="/booking"
            className="mt-4 inline-block rounded-full bg-[var(--pink)] px-6 py-3 font-semibold text-white hover:bg-[var(--pink-hover)]"
          >
            Book Your Booth
          </Link>
        </section>
      </div>

      <Link href="/" className="mt-12 inline-block text-[var(--pink)] hover:underline">
        ← Back to home
      </Link>
    </div>
  );
}
