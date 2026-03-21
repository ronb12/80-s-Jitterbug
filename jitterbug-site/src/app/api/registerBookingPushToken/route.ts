import { NextRequest } from "next/server";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { registerCustomerPushTokenNeon } from "@/lib/server/neon-queries";

export const runtime = "nodejs";

export async function OPTIONS() {
  return emptyCors204();
}

export async function POST(request: NextRequest) {
  let body: {
    bookingId?: string;
    bookingRef?: string;
    fcmToken?: string;
  };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return jsonWithCors({ error: "Invalid JSON" }, { status: 400 });
  }

  try {
    const bookingId = String(body?.bookingId ?? "").trim();
    const bookingRef = String(body?.bookingRef ?? "").trim();
    const fcmToken = String(body?.fcmToken ?? "").trim();
    if (!bookingId || !bookingRef || fcmToken.length < 20) {
      return jsonWithCors(
        { error: "bookingId, bookingRef, and fcmToken required" },
        { status: 400 }
      );
    }
    await registerCustomerPushTokenNeon(bookingId, bookingRef, fcmToken);
    return jsonWithCors({ ok: true });
  } catch (e) {
    const status =
      e instanceof Error && "statusCode" in e
        ? Number((e as Error & { statusCode?: number }).statusCode) || 500
        : 500;
    if (status === 404) {
      return jsonWithCors({ error: "Booking not found" }, { status: 404 });
    }
    if (status === 403) {
      return jsonWithCors({ error: "Invalid booking reference" }, { status: 403 });
    }
    console.error("registerBookingPushToken", e);
    return jsonWithCors(
      { error: e instanceof Error ? e.message : "Failed" },
      { status: 500 }
    );
  }
}
