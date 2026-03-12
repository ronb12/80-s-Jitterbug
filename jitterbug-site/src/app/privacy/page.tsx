import Link from "next/link";
import { contactEmail, contactPhone, contactPhoneTel } from "@/lib/contact";

export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8">
      <h1 className="text-3xl font-bold text-white">Privacy Policy</h1>
      <p className="mt-2 text-sm text-zinc-500">Last updated: {new Date().toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })}</p>

      <div className="mt-10 space-y-8 text-zinc-400">
        <section>
          <h2 className="text-xl font-semibold text-white">1. Information We Collect</h2>
          <p className="mt-2 leading-relaxed">
            When you request a quote or book our photo booth service, we collect the information you provide: name, email address, phone number, event details (date, location, type), package choice, and any message you send. We use this to respond to your request, prepare for your event, and provide our services.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">2. How We Use Your Information</h2>
          <p className="mt-2 leading-relaxed">
            We use your information only to communicate with you about your booking, send quotes, coordinate your event, and improve our service. We do not sell or rent your personal information to third parties.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">3. Data Storage & Security</h2>
          <p className="mt-2 leading-relaxed">
            Booking and contact information is stored securely. We take reasonable steps to protect your data from unauthorized access, loss, or misuse.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">4. Cookies & Website Use</h2>
          <p className="mt-2 leading-relaxed">
            Our website may use cookies or similar technologies for basic functionality and analytics. You can adjust your browser settings to limit or block cookies if you prefer.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-semibold text-white">5. Your Rights</h2>
          <p className="mt-2 leading-relaxed">
            You may ask us what data we hold about you, request correction, or ask us to delete your information (subject to legal or contractual requirements). Contact us using the details below to make a request.
          </p>
        </section>

        <section className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-6">
          <h2 className="text-xl font-semibold text-white">Contact Us</h2>
          <p className="mt-2 leading-relaxed text-zinc-400">
            For questions about this privacy policy or your personal data, please contact us:
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
