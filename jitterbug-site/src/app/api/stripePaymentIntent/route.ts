import { NextRequest } from "next/server";
import Stripe from "stripe";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { getBookingByIdNeon, updateBookingNeon } from "@/lib/server/neon-queries";
import { loadSiteStripeSettings, packagePriceCents } from "@/lib/server/site-stripe";

export const runtime = "nodejs";

export async function OPTIONS() {
  return emptyCors204();
}

export async function POST(request: NextRequest) {
  const secret = process.env.STRIPE_SECRET_KEY;
  if (!secret) {
    return jsonWithCors({ error: "Server missing STRIPE_SECRET_KEY" }, { status: 500 });
  }

  try {
    const site = await loadSiteStripeSettings();
    if (!site.stripeCheckoutEnabled) {
      return jsonWithCors(
        { error: "Stripe checkout is disabled in site settings." },
        { status: 403 }
      );
    }

    const body = (await request.json()) as { bookingId?: string };
    const bookingId = String(body?.bookingId ?? "").trim();
    if (!bookingId) {
      return jsonWithCors({ error: "bookingId required" }, { status: 400 });
    }

    const b = await getBookingByIdNeon(bookingId);
    if (!b) {
      return jsonWithCors({ error: "Booking not found" }, { status: 404 });
    }
    if (b.depositPaid === true) {
      return jsonWithCors(
        { error: "Deposit already recorded for this booking." },
        { status: 400 }
      );
    }

    const bookingRefCode = String(b.bookingRef ?? "");
    const pkgId = String(b.packageId ?? "");
    const fullCents = pkgId ? await packagePriceCents(pkgId) : null;
    let depositCents = site.stripeDepositCents;
    if (fullCents != null && fullCents > 0) {
      depositCents = Math.min(depositCents, fullCents);
    }

    const stripe = new Stripe(secret);
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
      return jsonWithCors({ error: "Could not create payment client secret." }, { status: 500 });
    }

    await updateBookingNeon(bookingId, { stripePaymentIntentId: paymentIntent.id });

    return jsonWithCors({ clientSecret });
  } catch (e) {
    console.error("stripePaymentIntent", e);
    return jsonWithCors(
      { error: e instanceof Error ? e.message : "PaymentIntent failed" },
      { status: 500 }
    );
  }
}
