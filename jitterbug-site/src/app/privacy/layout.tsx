import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy | 80's Jitterbug Photo Booth",
  description: "Privacy policy for 80's Jitterbug Photo Booth. How we collect, use, and protect your information.",
};

export default function PrivacyLayout({ children }: { children: React.ReactNode }) {
  return children;
}
