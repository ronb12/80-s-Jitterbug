import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Payment received | 80's Jitterbug",
  description: "Thank you for your deposit.",
};

export default function BookingSuccessLayout({ children }: { children: React.ReactNode }) {
  return children;
}
