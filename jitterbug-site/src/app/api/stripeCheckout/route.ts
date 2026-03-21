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

    await updateBookingNeon(bookingId, { stripeCheckoutSessionId: session.id });

    return jsonWithCors({ url: session.url });
  } catch (e) {
    console.error("stripeCheckout", e);
    return jsonWithCors(
      { error: e instanceof Error ? e.message : "Checkout failed" },
      { status: 500 }
    );
  }
}
