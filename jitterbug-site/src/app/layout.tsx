import type { Metadata } from "next";
import { Orbitron } from "next/font/google";
import "./globals.css";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import FloatingBookNow from "@/components/FloatingBookNow";
import FirebaseInit from "@/components/FirebaseInit";

const orbitron = Orbitron({
  variable: "--font-orbitron",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "80's Jitterbug | Retro Photo Booth Rentals for Weddings & Events",
  description:
    "Bring the party to life with 80's Jitterbug Photo Booth! Retro fun, instant memories. The ultimate photo booth experience for weddings, birthdays, and corporate events.",
  keywords: ["photo booth rental", "80s theme", "wedding photo booth", "party photo booth", "corporate events"],
  openGraph: {
    title: "80's Jitterbug | Retro Photo Booth Rentals",
    description: "Retro fun. Instant memories. The ultimate photo booth experience.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={orbitron.variable}>
      <body className="min-h-screen bg-[var(--background)] font-sans text-[var(--foreground)] antialiased">
        <FirebaseInit />
        <Navigation />
        <main>{children}</main>
        <Footer />
        <FloatingBookNow />
      </body>
    </html>
  );
}
