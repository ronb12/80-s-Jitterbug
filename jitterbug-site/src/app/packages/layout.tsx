import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Packages & Pricing | 80's Jitterbug Photo Booth",
  description: "Photo booth rental packages: Basic, Standard, and VIP. Unlimited photos, props, and retro setup for weddings and events.",
};

export default function PackagesLayout({ children }: { children: React.ReactNode }) {
  return children;
}
