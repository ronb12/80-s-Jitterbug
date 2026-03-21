import Stripe from "stripe";
import { NextResponse } from "next/server";
import { updateBookingNeon } from "@/lib/server/neon-queries";
import { notifyDepositPaid } from "@/lib/server/fcm-notify";

export const runtime = "nodejs";
export const maxDuration = 60;

export async function POST(request: Request) {
  const stripeSecret = process.env.STRIPE_SECRET_KEY;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!stripeSecret || !webhookSecret) {
    return new NextResponse("Server configuration error", { status: 500 });
  }

  const stripe = new Stripe(stripeSecret);
  const sig = request.headers.get("stripe-signature");
  if (!sig) {
    return new NextResponse("Missing stripe-signature", { status: 400 });
  }

  const raw = Buffer.from(await request.arrayBuffer());

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(raw, sig, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed", err);
    return new NextResponse("Webhook Error", { status: 400 });
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object as Stripe.Checkout.Session;
    const bookingId = session.metadata?.bookingId;
    if (bookingId && session.payment_status === "paid") {
      await updateBookingNeon(bookingId, {
        depositPaid: true,
        stripeCheckoutSessionId: session.id,
      });
      const refCode = String(session.metadata?.bookingRef ?? bookingId);
      try {
        await notifyDepositPaid(bookingId, refCode);
      } catch (e) {
        console.error("notifyDepositPaid (checkout)", e);
      }
    }
  }

  if (event.type === "payment_intent.succeeded") {
    const pi = event.data.object as Stripe.PaymentIntent;
    const bookingId = pi.metadata?.bookingId;
    if (bookingId && pi.status === "succeeded") {
      await updateBookingNeon(bookingId, {
        depositPaid: true,
        stripePaymentIntentId: pi.id,
      });
      const refCode = String(pi.metadata?.bookingRef ?? bookingId);
      try {
        await notifyDepositPaid(bookingId, refCode);
      } catch (e) {
        console.error("notifyDepositPaid (pi)", e);
      }
    }
  }

  return NextResponse.json({ received: true });
}
