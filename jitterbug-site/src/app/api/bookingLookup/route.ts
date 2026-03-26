import { NextRequest } from "next/server";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { getDb, bookings } from "@/lib/db";
import { eq } from "drizzle-orm";
import { getFcmAdmin } from "@/lib/server/fcm-admin";

export const runtime = "nodejs";

export async function OPTIONS() {
  return emptyCors204();
}

export async function POST(request: NextRequest) {
  let body: { bookingRef?: string };
  try {
    body = (await request.json()) as { bookingRef?: string };
  } catch {
    return jsonWithCors({ error: "Invalid JSON" }, { status: 400 });
  }

  const bookingRef = String(body?.bookingRef ?? "").trim().toUpperCase();
  if (!bookingRef) {
    return jsonWithCors({ error: "bookingRef required" }, { status: 400 });
  }

  try {
    // Primary source: website database (Neon/Postgres).
    const db = getDb();
    const [row] = await db
      .select({
        status: bookings.status,
        eventDate: bookings.eventDate,
        eventType: bookings.eventType,
        eventLocation: bookings.eventLocation,
        depositPaid: bookings.depositPaid,
      })
      .from(bookings)
      .where(eq(bookings.bookingRef, bookingRef))
      .limit(1);

    if (row) {
      return jsonWithCors({
        booking: {
          status: String(row.status ?? "pending"),
          eventDate: String(row.eventDate ?? ""),
          eventType: String(row.eventType ?? ""),
          eventLocation: String(row.eventLocation ?? ""),
          depositPaid: Boolean(row.depositPaid ?? false),
        },
      });
    }

    // Fallback: legacy Firestore records still created by older app builds.
    const admin = getFcmAdmin();
    const fs = admin.firestore();
    const snap = await fs.collection("bookings").where("bookingRef", "==", bookingRef).limit(1).get();
    const doc = snap.docs[0];
    if (!doc) return jsonWithCors({ error: "Booking not found" }, { status: 404 });
    const data = doc.data() ?? {};
    return jsonWithCors({
      booking: {
        status: String(data.status ?? "pending"),
        eventDate: String(data.eventDate ?? ""),
        eventType: String(data.eventType ?? ""),
        eventLocation: String(data.eventLocation ?? ""),
        depositPaid: Boolean(data.depositPaid ?? false),
      },
    });
  } catch (error) {
    console.error("bookingLookup", error);
    return jsonWithCors({ error: "Lookup unavailable" }, { status: 503 });
  }
}
