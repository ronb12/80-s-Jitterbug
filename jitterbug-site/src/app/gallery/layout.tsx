import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Gallery | 80's Jitterbug Photo Booth",
  description: "Photo booth moments from weddings, parties, and corporate events.",
};

export default function GalleryLayout({ children }: { children: React.ReactNode }) {
  return children;
}
