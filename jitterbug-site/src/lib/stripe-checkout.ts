/**
 * Same-origin POST `/api/stripeCheckout` — implemented on Vercel (Next.js route) or Firebase Hosting rewrite → Cloud Function.
 * Same-origin only works when the site is deployed (not file://).
 */

export async function startStripeDepositCheckout(bookingId: string): Promise<{ url: string } | { error: string }> {
  const origin = typeof window !== "undefined" ? window.location.origin : "";
  if (!origin || origin.startsWith("file:")) {
    return { error: "Open the deployed site to pay with Stripe." };
  }
  try {
    const r = await fetch(`${origin}/api/stripeCheckout`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ bookingId }),
    });
    const data = (await r.json()) as { url?: string; error?: string };
    if (!r.ok) {
      return { error: data.error ?? `Checkout failed (${r.status})` };
    }
    if (!data.url) {
      return { error: "No checkout URL returned." };
    }
    return { url: data.url };
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Network error" };
  }
}
