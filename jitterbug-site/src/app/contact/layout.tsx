import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Contact | 80's Jitterbug Photo Booth",
  description: "Get in touch for photo booth rentals. Email, phone, and social links.",
};

export default function ContactLayout({ children }: { children: React.ReactNode }) {
  return children;
}
