/**
 * Firebase Cloud Functions — Stripe Checkout (deposit) + webhook.
 *
 * Secrets (never store sk_ or webhook secret in Firestore — settings/site is public-read):
 *   firebase functions:secrets:set STRIPE_SECRET_KEY
 *   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
 *
 * Deploy: firebase deploy --only functions
 */

import * as admin from "firebase-admin";
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";
import Stripe from "stripe";

admin.initializeApp();

const stripeSecret = defineSecret("STRIPE_SECRET_KEY");
const webhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

const SETTINGS_SITE = "settings/site";
const SETTINGS_PACKAGES = "settings/packages";
const BOOKINGS = "bookings";

function parseMoneyToCents(price: string): number | null {
  const m = String(price)
    .replace(/,/g, "")
    .match(/\$?\s*(\d+(?:\.\d{1,2})?)/);
  if (!m) return null;
  const n = parseFloat(m[1]);
  if (Number.isNaN(n)) return null;
  return Math.round(n * 100);
}

async function loadSiteStripeSettings(): Promise<{
  stripeCheckoutEnabled: boolean;
  stripeDepositCents: number;
  stripePublicBaseUrl: string;
}> {
  const snap = await admin.firestore().doc(SETTINGS_SITE).get();
  const d = snap.data() ?? {};
  const base = String(d.stripePublicBaseUrl ?? "https://jitterbug80s.web.app").replace(/\/$/, "");
  return {
    stripeCheckoutEnabled: Boolean(d.stripeCheckoutEnabled),
    stripeDepositCents: Math.max(50, Number(d.stripeDepositCents) || 5000),
    stripePublicBaseUrl: base || "https://jitterbug80s.web.app",
  };
}

async function packagePriceCents(packageId: string): Promise<number | null> {
  const snap = await admin.firestore().doc(SETTINGS_PACKAGES).get();
  const list = snap.data()?.packages as Array<{ id?: string; price?: string }> | undefined;
  if (!Array.isArray(list)) return null;
  const row = list.find((p) => String(p?.id ?? "") === packageId);
  if (!row?.price) return null;
  return parseMoneyToCents(String(row.price));
}

/** POST { bookingId: string } — returns { url } for Stripe Checkout. */
export const stripeCheckout = onRequest(
  {
    cors: true,
    secrets: [stripeSecret],
    region: "us-central1",
    invoker: "public",
  },
  async (req, res) => {
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    try {
      const site = await loadSiteStripeSettings();
      if (!site.stripeCheckoutEnabled) {
        res.status(403).json({ error: "Stripe checkout is disabled in site settings." });
        return;
      }

      const body = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body;
      const bookingId = String(body?.bookingId ?? "").trim();
      if (!bookingId) {
        res.status(400).json({ error: "bookingId required" });
        return;
      }

      const bookingRef = admin.firestore().collection(BOOKINGS).doc(bookingId);
      const bookingSnap = await bookingRef.get();
      if (!bookingSnap.exists) {
        res.status(404).json({ error: "Booking not found" });
        return;
      }
      const b = bookingSnap.data()!;
      if (b.depositPaid === true) {
        res.status(400).json({ error: "Deposit already recorded for this booking." });
        return;
      }

      const bookingRefCode = String(b.bookingRef ?? "");
      const pkgId = String(b.package ?? "");
      const fullCents = pkgId ? await packagePriceCents(pkgId) : null;
      let depositCents = site.stripeDepositCents;
      if (fullCents != null && fullCents > 0) {
        depositCents = Math.min(depositCents, fullCents);
      }

      const stripe = new Stripe(stripeSecret.value());

      const base = site.stripePublicBaseUrl;
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        line_items: [
          {
            price_data: {
              currency: "usd",
              unit_amount: depositCents,
              product_data: {
                name: `Photo booth deposit — ${bookingRefCode || bookingId}`,
                description: `80's Jitterbug — ${String(b.eventType ?? "Event")} on ${String(b.eventDate ?? "")}`,
              },
            },
            quantity: 1,
          },
        ],
        customer_email: String(b.email ?? "").trim() || undefined,
        success_url: `${base}/booking/success/?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${base}/booking/?canceled=1`,
        metadata: {
          bookingId,
          bookingRef: bookingRefCode,
        },
      });

      await bookingRef.update({
        stripeCheckoutSessionId: session.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({ url: session.url });
    } catch (e) {
      console.error("stripeCheckout", e);
      res.status(500).json({
        error: e instanceof Error ? e.message : "Checkout failed",
      });
    }
  }
);

/**
 * POST { bookingId: string } — returns { clientSecret } for Stripe iOS Payment Sheet.
 * Money is captured by Stripe; this only creates a PaymentIntent (same rules as stripeCheckout).
 * Web can keep using hosted Checkout via stripeCheckout.
 */
export const stripePaymentIntent = onRequest(
  {
    cors: true,
    secrets: [stripeSecret],
    region: "us-central1",
    invoker: "public",
  },
  async (req, res) => {
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    try {
      const site = await loadSiteStripeSettings();
      if (!site.stripeCheckoutEnabled) {
        res.status(403).json({ error: "Stripe checkout is disabled in site settings." });
        return;
      }

      const body = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body;
      const bookingId = String(body?.bookingId ?? "").trim();
      if (!bookingId) {
        res.status(400).json({ error: "bookingId required" });
        return;
      }

      const bookingRef = admin.firestore().collection(BOOKINGS).doc(bookingId);
      const bookingSnap = await bookingRef.get();
      if (!bookingSnap.exists) {
        res.status(404).json({ error: "Booking not found" });
        return;
      }
      const b = bookingSnap.data()!;
      if (b.depositPaid === true) {
        res.status(400).json({ error: "Deposit already recorded for this booking." });
        return;
      }

      const bookingRefCode = String(b.bookingRef ?? "");
      const pkgId = String(b.package ?? "");
      const fullCents = pkgId ? await packagePriceCents(pkgId) : null;
      let depositCents = site.stripeDepositCents;
      if (fullCents != null && fullCents > 0) {
        depositCents = Math.min(depositCents, fullCents);
      }

      const stripe = new Stripe(stripeSecret.value());

      const paymentIntent = await stripe.paymentIntents.create({
        amount: depositCents,
        currency: "usd",
        automatic_payment_methods: { enabled: true },
        receipt_email: String(b.email ?? "").trim() || undefined,
        description: `Photo booth deposit — ${bookingRefCode || bookingId}`,
        metadata: {
          bookingId,
          bookingRef: bookingRefCode,
        },
      });

      const clientSecret = paymentIntent.client_secret;
      if (!clientSecret) {
        res.status(500).json({ error: "Could not create payment client secret." });
        return;
      }

      await bookingRef.update({
        stripePaymentIntentId: paymentIntent.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({ clientSecret });
    } catch (e) {
      console.error("stripePaymentIntent", e);
      res.status(500).json({
        error: e instanceof Error ? e.message : "PaymentIntent failed",
      });
    }
  }
);

export const stripeWebhook = onRequest(
  {
    secrets: [stripeSecret, webhookSecret],
    region: "us-central1",
    invoker: "public",
    cors: false,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const stripe = new Stripe(stripeSecret.value());

    const sig = req.headers["stripe-signature"];
    if (!sig || typeof sig !== "string") {
      res.status(400).send("Missing stripe-signature");
      return;
    }

    let event: Stripe.Event;
    try {
      const raw =
        (req as { rawBody?: Buffer }).rawBody ??
        (typeof req.body === "string" ? Buffer.from(req.body) : Buffer.from(JSON.stringify(req.body)));
      event = stripe.webhooks.constructEvent(raw, sig, webhookSecret.value());
    } catch (err) {
      console.error("Webhook signature verification failed", err);
      res.status(400).send("Webhook Error");
      return;
    }

    if (event.type === "checkout.session.completed") {
      const session = event.data.object as Stripe.Checkout.Session;
      const bookingId = session.metadata?.bookingId;
      if (bookingId && session.payment_status === "paid") {
        await admin
          .firestore()
          .collection(BOOKINGS)
          .doc(bookingId)
          .update({
            depositPaid: true,
            stripeCheckoutSessionId: session.id,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }
    }

    if (event.type === "payment_intent.succeeded") {
      const pi = event.data.object as Stripe.PaymentIntent;
      const bookingId = pi.metadata?.bookingId;
      if (bookingId && pi.status === "succeeded") {
        await admin
          .firestore()
          .collection(BOOKINGS)
          .doc(bookingId)
          .update({
            depositPaid: true,
            stripePaymentIntentId: pi.id,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }
    }

    res.json({ received: true });
  }
);

/** FCM: admin new-booking / deposit-paid + customer deposit opt-in (see push.ts). */
export {
  onBookingCreatedPush,
  onBookingUpdatedPush,
  registerBookingPushToken,
} from "./push";
