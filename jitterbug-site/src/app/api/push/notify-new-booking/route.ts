import { NextRequest } from "next/server";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { notifyAdminNewBooking } from "@/lib/server/fcm-notify";

export const runtime = "nodejs";

/**
 * Replaces Firestore trigger `onBookingCreatedPush` when the app writes bookings from the client
 * (e.g. iOS) and APIs run on Vercel instead of Cloud Functions.
 *
 * Auth: header `x-internal-notify-secret` or JSON `secret` must match env `INTERNAL_NEW_BOOKING_NOTIFY_SECRET`.
 */
export async function OPTIONS() {
  return emptyCors204();
}

export async function POST(request: NextRequest) {
  const expected = process.env.INTERNAL_NEW_BOOKING_NOTIFY_SECRET?.trim();
  if (!expected) {
    return jsonWithCors({ error: "Notify endpoint not configured" }, { status: 503 });
  }

  const headerSecret = request.headers.get("x-internal-notify-secret")?.trim();
  let body: {
    secret?: string;
    bookingId?: string;
    bookingRef?: string;
    name?: string;
  };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return jsonWithCors({ error: "Invalid JSON" }, { status: 400 });
  }

  const secret = headerSecret || String(body?.secret ?? "").trim();
  if (secret !== expected) {
    return jsonWithCors({ error: "Unauthorized" }, { status: 401 });
  }

  const bookingId = String(body?.bookingId ?? "").trim();
  const bookingRef = String(body?.bookingRef ?? "").trim();
  const name = String(body?.name ?? "New request").trim() || "New request";
  if (!bookingId || !bookingRef) {
    return jsonWithCors({ error: "bookingId and bookingRef required" }, { status: 400 });
  }

  try {
    await notifyAdminNewBooking(bookingId, bookingRef, name);
    return jsonWithCors({ ok: true });
  } catch (e) {
    console.error("notify-new-booking", e);
    return jsonWithCors(
      { error: e instanceof Error ? e.message : "Notify failed" },
      { status: 500 }
    );
  }
}
