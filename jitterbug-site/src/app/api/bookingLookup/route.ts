import { NextRequest } from "next/server";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { getDb, bookings } from "@/lib/db";
import { sql } from "drizzle-orm";
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
      // Case-insensitive compare so older rows or mixed casing still match.
      .where(sql`upper(trim(${bookings.bookingRef})) = ${bookingRef}`)
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

    // Fallback: legacy Firestore records (older app builds). Optional: requires Firebase Admin env on the server.
    try {
      const admin = getFcmAdmin();
      const fs = admin.firestore();
      const snap = await fs.collection("bookings").where("bookingRef", "==", bookingRef).limit(1).get();
      const doc = snap.docs[0];
      if (doc) {
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
      }
    } catch (firestoreErr) {
      console.error("bookingLookup firestore fallback", firestoreErr);
    }

    return jsonWithCors({ error: "Booking not found" }, { status: 404 });
  } catch (error) {
    console.error("bookingLookup", error);
    return jsonWithCors({ error: "Lookup unavailable" }, { status: 503 });
  }
}
