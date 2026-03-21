"use client";

import { publicApiOrigin } from "./api-public";
import { getAdminApiHeaders } from "./admin-auth";

export interface SiteSettings {
  /** Optional display name (also used by mobile clients when synced). */
  ownerName?: string;
  contactEmail: string;
  contactPhone: string;
  serviceArea: string;
  stripePublicBaseUrl: string;
  stripeCheckoutEnabled: boolean;
  stripeDepositCents: number;
  stripePublishableKeyTest: string;
  stripePublishableKeyLive: string;
  stripeMode: "test" | "live";
}

const defaults: SiteSettings = {
  ownerName: "",
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
  const origin = publicApiOrigin();
  if (!origin) return defaults;
  try {
    const r = await fetch(`${origin}/api/data/site-settings`);
    if (!r.ok) return defaults;
    const d = (await r.json()) as Record<string, unknown>;
    const mode = d.stripeMode === "live" ? "live" : "test";
    return {
      ownerName: String(d.ownerName ?? "").trim(),
      contactEmail: (d.contactEmail as string) ?? defaults.contactEmail,
      contactPhone: (d.contactPhone as string) ?? defaults.contactPhone,
      serviceArea: (d.serviceArea as string) ?? defaults.serviceArea,
      stripePublicBaseUrl: String(d.stripePublicBaseUrl ?? defaults.stripePublicBaseUrl).replace(
        /\/$/,
        ""
      ),
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
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const merged = await getSiteSettings();
  const next: SiteSettings = {
    ownerName: settings.ownerName ?? merged.ownerName ?? "",
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

  const r = await fetch(`${origin}/api/data/site-settings`, {
    method: "PUT",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify(next),
  });
  if (!r.ok) throw new Error("Could not save settings");
}
