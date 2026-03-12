import type { Metadata } from "next";
import { DM_Sans } from "next/font/google";
import "./globals.css";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import FirebaseInit from "@/components/FirebaseInit";

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  display: "swap",
  weight: ["400", "500", "600", "700"],
});

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://80sjitterbug.com";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "80's Jitterbug | Retro Photo Booth Rentals for Weddings & Events",
  description:
    "Bring the party to life with 80's Jitterbug Photo Booth! Retro fun, instant memories. The ultimate photo booth experience for weddings, birthdays, and corporate events.",
  keywords: ["photo booth rental", "80s theme", "wedding photo booth", "party photo booth", "corporate events"],
  openGraph: {
    title: "80's Jitterbug | Retro Photo Booth Rentals",
    description: "Retro fun. Instant memories. The ultimate photo booth experience.",
    type: "website",
    url: siteUrl,
  },
  alternates: {
    canonical: siteUrl,
  },
  icons: {
    icon: "/icon-512.png",
    apple: "/icon-512.png",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={dmSans.variable}>
      <body className="min-h-screen bg-[var(--background)] font-sans text-[var(--foreground)] antialiased">
        <FirebaseInit />
        <Navigation />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
