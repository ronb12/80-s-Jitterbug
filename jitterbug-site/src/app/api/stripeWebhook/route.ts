import Stripe from "stripe";
import { NextResponse } from "next/server";
import { getFirebaseAdmin } from "@/lib/server/firebase-admin";
import { BOOKINGS } from "@/lib/server/site-stripe";
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

  const admin = getFirebaseAdmin();

  if (event.type === "checkout.session.completed") {
    const session = event.data.object as Stripe.Checkout.Session;
    const bookingId = session.metadata?.bookingId;
    if (bookingId && session.payment_status === "paid") {
      await admin.firestore().collection(BOOKINGS).doc(bookingId).update({
        depositPaid: true,
        stripeCheckoutSessionId: session.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
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
      await admin.firestore().collection(BOOKINGS).doc(bookingId).update({
        depositPaid: true,
        stripePaymentIntentId: pi.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
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
