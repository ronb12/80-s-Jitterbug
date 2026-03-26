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

    const body = (await request.json()) as { bookingId?: string; paymentKind?: string };
    const bookingId = String(body?.bookingId ?? "").trim();
    const paymentKind = String(body?.paymentKind ?? "deposit").trim().toLowerCase();
    const isBalance = paymentKind === "balance";
    if (!bookingId) {
      return jsonWithCors({ error: "bookingId required" }, { status: 400 });
    }

    const b = await getBookingByIdNeon(bookingId);
    if (!b) {
      return jsonWithCors({ error: "Booking not found" }, { status: 404 });
    }
    if (!isBalance && b.depositPaid === true) {
      return jsonWithCors(
        { error: "Deposit already recorded for this booking." },
        { status: 400 }
      );
    }
    if (isBalance && b.balancePaid === true) {
      return jsonWithCors(
        { error: "Balance already recorded for this booking." },
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
    if (isBalance && (b.depositPaid !== true)) {
      return jsonWithCors(
        { error: "Deposit must be paid before paying the remaining balance." },
        { status: 400 }
      );
    }
    const amountCents = isBalance
      ? Math.max(0, (fullCents ?? 0) - depositCents)
      : depositCents;
    if (amountCents <= 0) {
      return jsonWithCors(
        { error: isBalance ? "No remaining balance due for this booking." : "Invalid deposit amount." },
        { status: 400 }
      );
    }

    const stripe = new Stripe(secret);
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: "usd",
      automatic_payment_methods: { enabled: true },
      receipt_email: String(b.email ?? "").trim() || undefined,
      description: `Photo booth ${isBalance ? "balance" : "deposit"} — ${bookingRefCode || bookingId}`,
      metadata: {
        bookingId,
        bookingRef: bookingRefCode,
        paymentKind: isBalance ? "balance" : "deposit",
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
