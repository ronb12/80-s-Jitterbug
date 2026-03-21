"use client";

import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "./firebase";

const SITE_SETTINGS_PATH = "settings/site";

export interface SiteSettings {
  contactEmail: string;
  contactPhone: string;
  serviceArea: string;
  /** Base URL for Stripe redirects (no trailing slash), e.g. https://jitterbug80s.web.app */
  stripePublicBaseUrl: string;
  /** Offer “Pay deposit” after booking when true and Cloud Functions + Stripe secret are configured. */
  stripeCheckoutEnabled: boolean;
  /** Deposit charged at checkout (USD cents), e.g. 5000 = $50. Capped by package price when parsable. */
  stripeDepositCents: number;
  /**
   * Publishable keys only (pk_test_… / pk_live_…). Safe to store in Firestore.
   * Never put secret keys (sk_…) here — they are public-readable; use Firebase secrets instead.
   */
  stripePublishableKeyTest: string;
  stripePublishableKeyLive: string;
  /** Which mode to use for display / future client-side Stripe features. */
  stripeMode: "test" | "live";
}

const defaults: SiteSettings = {
  contactEmail: "sbowie207@gmail.com",
  contactPhone: "646-673-1956",
  serviceArea: "Serving the greater area and surrounding communities.",
  stripePublicBaseUrl: "https://jitterbug80s.web.app",
  stripeCheckoutEnabled: false,
  stripeDepositCents: 5000,
  stripePublishableKeyTest: "",
  stripePublishableKeyLive: "",
  stripeMode: "test",
};

export async function getSiteSettings(): Promise<SiteSettings> {
  if (!db) return defaults;
  try {
    const snap = await getDoc(doc(db, SITE_SETTINGS_PATH));
    if (!snap.exists()) return defaults;
    const d = snap.data();
    const mode = d.stripeMode === "live" ? "live" : "test";
    return {
      contactEmail: (d.contactEmail as string) ?? defaults.contactEmail,
      contactPhone: (d.contactPhone as string) ?? defaults.contactPhone,
      serviceArea: (d.serviceArea as string) ?? defaults.serviceArea,
      stripePublicBaseUrl: String(d.stripePublicBaseUrl ?? defaults.stripePublicBaseUrl).replace(/\/$/, "") || defaults.stripePublicBaseUrl,
      stripeCheckoutEnabled: Boolean(d.stripeCheckoutEnabled),
      stripeDepositCents: Math.max(50, Number(d.stripeDepositCents) || defaults.stripeDepositCents),
      stripePublishableKeyTest: String(d.stripePublishableKeyTest ?? "").trim(),
      stripePublishableKeyLive: String(d.stripePublishableKeyLive ?? "").trim(),
      stripeMode: mode,
    };
  } catch {
    return defaults;
  }
}

export async function updateSiteSettings(settings: Partial<SiteSettings>): Promise<void> {
  if (!db) throw new Error("Firebase not configured");
  const merged = await getSiteSettings();
  const next: SiteSettings = {
    contactEmail: settings.contactEmail ?? merged.contactEmail,
    contactPhone: settings.contactPhone ?? merged.contactPhone,
    serviceArea: settings.serviceArea ?? merged.serviceArea,
    stripePublicBaseUrl: (settings.stripePublicBaseUrl ?? merged.stripePublicBaseUrl).replace(/\/$/, ""),
    stripeCheckoutEnabled: settings.stripeCheckoutEnabled ?? merged.stripeCheckoutEnabled,
    stripeDepositCents: settings.stripeDepositCents ?? merged.stripeDepositCents,
    stripePublishableKeyTest: settings.stripePublishableKeyTest ?? merged.stripePublishableKeyTest,
    stripePublishableKeyLive: settings.stripePublishableKeyLive ?? merged.stripePublishableKeyLive,
    stripeMode: settings.stripeMode ?? merged.stripeMode,
  };
  await setDoc(doc(db, SITE_SETTINGS_PATH), { ...next }, { merge: true });
}
