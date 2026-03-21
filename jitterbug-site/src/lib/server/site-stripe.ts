import { getFirebaseAdmin } from "./firebase-admin";

const SETTINGS_SITE = "settings/site";
const SETTINGS_PACKAGES = "settings/packages";
export const BOOKINGS = "bookings";

export function parseMoneyToCents(price: string): number | null {
  const m = String(price)
    .replace(/,/g, "")
    .match(/\$?\s*(\d+(?:\.\d{1,2})?)/);
  if (!m) return null;
  const n = parseFloat(m[1]);
  if (Number.isNaN(n)) return null;
  return Math.round(n * 100);
}

export async function loadSiteStripeSettings(): Promise<{
  stripeCheckoutEnabled: boolean;
  stripeDepositCents: number;
  stripePublicBaseUrl: string;
}> {
  const adminSdk = getFirebaseAdmin();
  const snap = await adminSdk.firestore().doc(SETTINGS_SITE).get();
  const d = snap.data() ?? {};
  const base = String(d.stripePublicBaseUrl ?? "https://jitterbug80s.web.app").replace(/\/$/, "");
  return {
    stripeCheckoutEnabled: Boolean(d.stripeCheckoutEnabled),
    stripeDepositCents: Math.max(50, Number(d.stripeDepositCents) || 5000),
    stripePublicBaseUrl: base || "https://jitterbug80s.web.app",
  };
}

export async function packagePriceCents(packageId: string): Promise<number | null> {
  const adminSdk = getFirebaseAdmin();
  const snap = await adminSdk.firestore().doc(SETTINGS_PACKAGES).get();
  const list = snap.data()?.packages as Array<{ id?: string; price?: string }> | undefined;
  if (!Array.isArray(list)) return null;
  const row = list.find((p) => String(p?.id ?? "") === packageId);
  if (!row?.price) return null;
  return parseMoneyToCents(String(row.price));
}
