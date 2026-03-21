import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Booking Terms | 80's Jitterbug Photo Booth",
  description: "Deposit, balance, cancellation, liability, and photo use for 80's Jitterbug photo booth rentals.",
};

export default function BookingTermsLayout({ children }: { children: React.ReactNode }) {
  return children;
}
