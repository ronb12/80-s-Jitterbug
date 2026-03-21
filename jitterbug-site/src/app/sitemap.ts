import type { MetadataRoute } from "next";

export const dynamic = "force-static";

const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://80sjitterbug.com";

export default function sitemap(): MetadataRoute.Sitemap {
  const routes = [
    "",
    "/about",
    "/packages",
    "/gallery",
    "/booking",
    "/contact",
    "/faq",
    "/privacy",
    "/terms",
    "/booking-terms",
  ];
  return routes.map((path) => ({
    url: `${baseUrl}${path}`,
    lastModified: new Date(),
    changeFrequency: path === "" || path === "/packages" ? "weekly" : "monthly",
    priority: path === "" ? 1 : path === "/booking" || path === "/packages" ? 0.9 : 0.7,
  }));
}
