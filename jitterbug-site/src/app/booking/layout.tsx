import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Book Your Booth | 80's Jitterbug Photo Booth",
  description: "Request a quote for photo booth rental. Weddings, birthdays, corporate events.",
};

export default function BookingLayout({ children }: { children: React.ReactNode }) {
  return children;
}
