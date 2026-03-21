import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Server routes (Stripe, webhooks, booking submit) require a Node build — deploy on Vercel (not static export).
  trailingSlash: true,
};

export default nextConfig;
