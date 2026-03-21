import { NextRequest } from "next/server";
import { emptyCors204, jsonWithCors } from "@/lib/server/api-cors";
import { getFirebaseAdmin } from "@/lib/server/firebase-admin";
import { BOOKINGS } from "@/lib/server/site-stripe";
import { notifyAdminNewBooking } from "@/lib/server/fcm-notify";
import type { BookingFormData } from "@/lib/booking-types";

export const runtime = "nodejs";

function generateBookingRef(): string {
  const prefix = "JB";
  const num = Math.floor(1000 + Math.random() * 9000);
  return `${prefix}-${num}`;
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
    const admin = getFirebaseAdmin();
    const bookingRefCode = generateBookingRef();
    const docRef = await admin.firestore().collection(BOOKINGS).add({
      name,
      email,
      phone,
      eventType,
      eventDate,
      eventLocation,
      eventAddress: String(form?.eventAddress ?? "").trim(),
      package: pkg,
      message: String(form?.message ?? "").trim(),
      status: "pending",
      bookingRef: bookingRefCode,
      photoReleaseConsent: Boolean(form?.photoReleaseConsent),
      photoReleaseIncludesMinors: Boolean(form?.photoReleaseIncludesMinors),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    try {
      await notifyAdminNewBooking(docRef.id, bookingRefCode, name);
    } catch (e) {
      console.error("notifyAdminNewBooking (submit)", e);
    }

    return jsonWithCors({ bookingRef: bookingRefCode, id: docRef.id });
  } catch (e) {
    console.error("bookings/submit", e);
    return jsonWithCors(
      { error: e instanceof Error ? e.message : "Submit failed" },
      { status: 500 }
    );
  }
}
