import Link from "next/link";
import { contactEmail, contactPhone, contactPhoneTel } from "@/lib/contact";

export default function TermsPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8">
      <h1 className="text-3xl font-bold text-white">Terms of Service</h1>
      <p className="mt-2 text-sm text-zinc-500">Last updated: {new Date().toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })}</p>

      <div className="mt-10 space-y-8 text-zinc-400">
        <section>
          <h2 className="text-xl font-semibold text-white">1. Agreement to Terms</h2>
          <p className="mt-2 leading-relaxed">
            By using the 80&apos;s Jitterbug website and requesting or booking our photo booth services, you agree to these terms. If you do not agree, please do not use our services.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">2. Services</h2>
          <p className="mt-2 leading-relaxed">
            We provide photo booth rental services for events. Quotes and availability are subject to confirmation. A booking is confirmed only when we have agreed in writing (e.g., email) and any deposit or terms we specify have been met.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">3. Booking & Payment</h2>
          <p className="mt-2 leading-relaxed">
            Submitting a request through our website does not guarantee a booking. We will contact you to confirm details, pricing, and payment. Payment terms (deposit, balance, cancellation) will be communicated at the time of confirmation.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">4. Cancellation</h2>
          <p className="mt-2 leading-relaxed">
            Cancellation policies will be stated in your booking confirmation. Please contact us as soon as possible if you need to change or cancel your event.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">5. Use of Website</h2>
          <p className="mt-2 leading-relaxed">
            You may use this website only for lawful purposes. You may not attempt to interfere with the site, access data you are not authorized to access, or use our name or content for unauthorized purposes.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">6. Limitation of Liability</h2>
          <p className="mt-2 leading-relaxed">
            To the extent permitted by law, 80&apos;s Jitterbug is not liable for indirect, incidental, or consequential damages arising from your use of the website or our services. Our liability is limited to the amount you paid for the service in question.
          </p>
        </section>

        <section className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6">
          <h2 className="text-xl font-semibold text-white">Contact Us</h2>
          <p className="mt-2 leading-relaxed text-zinc-400">
            For questions about these terms or your booking, please contact us:
          </p>
          <ul className="mt-4 space-y-2 text-zinc-300">
            <li>
              <strong className="text-white">Email:</strong>{" "}
              <a href={`mailto:${contactEmail}`} className="text-[var(--pink)] hover:underline">
                {contactEmail}
              </a>
            </li>
            <li>
              <strong className="text-white">Phone:</strong>{" "}
              <a href={`tel:${contactPhoneTel}`} className="text-[var(--pink)] hover:underline">
                {contactPhone}
              </a>
            </li>
            <li>
              <strong className="text-white">Contact page:</strong>{" "}
              <Link href="/contact" className="text-[var(--pink)] hover:underline">
                Contact us
              </Link>
            </li>
          </ul>
        </section>
      </div>

      <Link href="/" className="mt-12 inline-block text-[var(--pink)] hover:underline">
        ← Back to home
      </Link>
    </div>
  );
}
