import Link from "next/link";

const footerLinks = [
  { href: "/", label: "Home" },
  { href: "/about", label: "About" },
  { href: "/packages", label: "Packages" },
  { href: "/gallery", label: "Gallery" },
  { href: "/booking", label: "Booking" },
  { href: "/contact", label: "Contact" },
];

const socialLinks = [
  { href: "https://instagram.com", label: "Instagram", icon: "📷" },
  { href: "https://facebook.com", label: "Facebook", icon: "👤" },
  { href: "https://pinterest.com", label: "Pinterest", icon: "📌" },
];

export default function Footer() {
  return (
    <footer className="border-t border-[var(--electric-blue)]/30 bg-black/50">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid gap-8 md:grid-cols-3">
          <div>
            <h3 className="mb-4 text-lg font-bold text-[var(--electric-blue)]">80&apos;s Jitterbug</h3>
            <p className="text-sm text-zinc-400">
              Retro photo booth rentals for weddings, parties, and corporate events. Bring the party to life!
            </p>
          </div>
          <div>
            <h4 className="mb-4 text-sm font-semibold uppercase tracking-wider text-zinc-500">Quick Links</h4>
            <ul className="space-y-2">
              {footerLinks.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-zinc-400 transition-colors hover:text-[var(--neon-pink)]">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h4 className="mb-4 text-sm font-semibold uppercase tracking-wider text-zinc-500">Connect</h4>
            <ul className="flex gap-4">
              {socialLinks.map((s) => (
                <li key={s.href}>
                  <a
                    href={s.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-2xl transition-transform hover:scale-110"
                    aria-label={s.label}
                  >
                    {s.icon}
                  </a>
                </li>
              ))}
            </ul>
            <p className="mt-4 text-sm text-zinc-500">
              <a href="mailto:hello@80sjitterbug.com" className="hover:text-[var(--electric-blue)]">hello@80sjitterbug.com</a>
              <br />
              <a href="tel:+15551234567" className="hover:text-[var(--electric-blue)]">(555) 123-4567</a>
            </p>
          </div>
        </div>
        <div className="mt-12 border-t border-zinc-800 pt-8 text-center text-sm text-zinc-500">
          © {new Date().getFullYear()} 80&apos;s Jitterbug Photo Booth. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
