import type { Metadata } from "next";
import Link from "next/link";
import NeonButton from "@/components/NeonButton";

export const metadata: Metadata = {
  title: "FAQ | 80's Jitterbug Photo Booth",
  description: "Frequently asked questions about photo booth rental: setup time, space, power, deposit & payment, what's included, and more.",
};

const faqs = [
  {
    q: "How long does setup and teardown take?",
    a: "We typically need about 45–60 minutes for setup before your event and 30–45 minutes for teardown after. We'll confirm exact times when we confirm your booking.",
  },
  {
    q: "How much space do you need?",
    a: "We recommend a clear area of about 10×10 feet for the booth, backdrop, and props. We can work with slightly tighter spaces—just ask when you book.",
  },
  {
    q: "What about power?",
    a: "We need access to a standard 120V outlet (one circuit is usually enough). We bring extension cords, but the closer we can set up to an outlet, the better.",
  },
  {
    q: "What's the deposit and when is the balance due?",
    a: "A 50% deposit secures your date. The remaining balance is due 7 days before your event. We'll send payment details when your booking is confirmed.",
  },
  {
    q: "What's included in the packages?",
    a: "All packages include our retro booth setup, unlimited digital photos, backdrop and props, and setup & teardown. Higher tiers add prints, custom branding, extended hours, and a dedicated attendant. See our Packages page for details.",
  },
  {
    q: "Can you do custom branding on prints?",
    a: "Yes. Our Standard and VIP packages include custom branding on prints (e.g., your names and date). Tell us your theme or logo when you book.",
  },
  {
    q: "Is there a minimum rental period?",
    a: "We generally recommend at least 3 hours so guests have time to enjoy the booth. Shorter events can be discussed—contact us for a custom quote.",
  },
];

export default function FAQPage() {
  return (
    <div>
      <section className="relative overflow-hidden retro-grid px-4 pt-16 pb-12 sm:px-6 lg:px-8">
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--background)] via-transparent to-[var(--background)]" />
        <div className="relative mx-auto max-w-4xl text-center">
          <h1 className="text-4xl font-bold leading-tight text-[var(--pink)] sm:text-5xl lg:text-6xl">
            Frequently Asked Questions
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-lg text-zinc-400 sm:text-xl">
            Setup, space, payment, and more—everything you need to know before you book.
          </p>
        </div>
      </section>

      <section className="border-y border-[var(--border)] px-4 py-16 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl space-y-10">
          {faqs.map((faq, i) => (
            <div key={i}>
              <h2 className="text-lg font-semibold text-white">{faq.q}</h2>
              <p className="mt-2 text-zinc-400 leading-relaxed">{faq.a}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="px-4 py-12 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <p className="text-zinc-500">Still have questions?</p>
          <div className="mt-6 flex flex-wrap justify-center gap-4">
            <NeonButton href="/contact">Contact us</NeonButton>
            <Link
              href="/booking"
              className="rounded-full border-2 border-[var(--pink)] px-6 py-3 font-semibold text-[var(--pink)] hover:bg-[var(--pink-muted)]"
            >
              Request a booking
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
