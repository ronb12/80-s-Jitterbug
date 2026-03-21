
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Check Your Booking | 80's Jitterbug Photo Booth",
  description: "Look up your photo booth booking status by reference. Enter your booking ref (e.g. JB-1234) to see confirmation and event details.",
};

export default function BookingLookupLayout({ children }: { children: React.ReactNode }) {
  return children;
}
