import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service | 80's Jitterbug Photo Booth",
  description: "Terms of service for 80's Jitterbug Photo Booth. Use of website and booking terms.",
};

export default function TermsLayout({ children }: { children: React.ReactNode }) {
  return children;
}
