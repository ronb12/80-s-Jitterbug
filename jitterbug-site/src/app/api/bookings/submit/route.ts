import { NextRequest } from "next/server";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { insertBookingNeon } from "@/lib/server/neon-queries";
import { notifyAdminNewBooking } from "@/lib/server/fcm-notify";
import type { BookingFormData } from "@/lib/booking-types";

export const runtime = "nodejs";

function generateBookingRef(): string {
  const prefix = "JB";
  const num = Math.floor(1000 + Math.random() * 9000);
  return `${prefix}-${num}`;
}

function isDuplicateBookingRefError(e: unknown): boolean {
  const s = String(e);
  return (
    s.includes("23505") ||
    s.includes("duplicate key") ||
    s.includes("bookings_booking_ref")
  );
}

export async function OPTIONS() {
  return emptyCors204();
}

export async function POST(request: NextRequest) {
  let form: BookingFormData & {
    photoReleaseConsent?: boolean;
    photoReleaseIncludesMinors?: boolean;
  };
  try {
    form = (await request.json()) as typeof form;
  } catch {
    return jsonWithCors({ error: "Invalid JSON" }, { status: 400 });
  }

  const name = String(form?.name ?? "").trim();
  const email = String(form?.email ?? "").trim();
  const phone = String(form?.phone ?? "").trim();
  const eventType = String(form?.eventType ?? "").trim();
  const eventDate = String(form?.eventDate ?? "").trim();
  const eventLocation = String(form?.eventLocation ?? "").trim();
  const pkg = String(form?.package ?? "").trim();

  if (!name || !email || !phone || !eventType || !eventDate || !eventLocation || !pkg) {
    return jsonWithCors({ error: "Missing required booking fields" }, { status: 400 });
  }

  try {
    let lastError: unknown;
    for (let attempt = 0; attempt < 12; attempt++) {
      const bookingRefCode = generateBookingRef();
      try {
        const row = await insertBookingNeon({
          bookingRef: bookingRefCode,
          name,
          email,
          phone,
          eventType,
          eventDate,
          eventLocation,
          eventAddress: String(form?.eventAddress ?? "").trim(),
          packageId: pkg,
          message: String(form?.message ?? "").trim(),
          photoReleaseConsent: Boolean(form?.photoReleaseConsent),
          photoReleaseIncludesMinors: Boolean(form?.photoReleaseIncludesMinors),
        });

        try {
          await notifyAdminNewBooking(row.id, row.bookingRef, name);
        } catch (e) {
          console.error("notifyAdminNewBooking (submit)", e);
        }

        return jsonWithCors({ bookingRef: row.bookingRef, id: row.id });
      } catch (e) {
        lastError = e;
        if (isDuplicateBookingRefError(e)) continue;
        throw e;
      }
    }
    console.error("bookings/submit exhausted retries", lastError);
    return jsonWithCors({ error: "Could not allocate booking reference" }, { status: 500 });
  } catch (e) {
    console.error("bookings/submit", e);
    return jsonWithCors(
      { error: e instanceof Error ? e.message : "Submit failed" },
      { status: 500 }
    );
  }
}
