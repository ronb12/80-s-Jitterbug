import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About Us | 80's Jitterbug Photo Booth",
  description: "Our story, the retro 80s theme, and why photo booths make every event better.",
};

export default function AboutLayout({ children }: { children: React.ReactNode }) {
  return children;
}
