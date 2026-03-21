"use client";

import { publicApiOrigin } from "./api-public";
import { getAdminApiHeaders } from "./admin-auth";
import type { Booking, BookingFormData, BookingStatus } from "./booking-types";

export async function submitBooking(form: BookingFormData): Promise<{ bookingRef: string; id: string }> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("Open the site in a browser to submit a booking.");

  const r = await fetch(`${origin}/api/bookings/submit`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(form),
  });
  const data = (await r.json()) as { bookingRef?: string; id?: string; error?: string };
  if (!r.ok) {
    throw new Error(data.error ?? `Booking failed (${r.status})`);
  }
  if (!data.bookingRef || !data.id) {
    throw new Error(data.error ?? "Invalid response from server");
  }
  return { bookingRef: data.bookingRef, id: data.id };
}

export async function listBookings(): Promise<Booking[]> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/bookings`, { headers: getAdminApiHeaders() });
  if (r.status === 401) throw new Error("Admin session expired or unauthorized.");
  if (!r.ok) throw new Error("Could not load bookings");
  const data = (await r.json()) as { bookings?: Booking[] };
  return data.bookings ?? [];
}

export async function updateBookingStatus(bookingId: string, status: BookingStatus): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/bookings/${encodeURIComponent(bookingId)}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify({ status }),
  });
  if (!r.ok) throw new Error("Could not update status");
}

export type BookingUpdateData = Partial<BookingFormData> & { status?: BookingStatus };

export async function updateBooking(bookingId: string, data: BookingUpdateData): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/bookings/${encodeURIComponent(bookingId)}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", ...getAdminApiHeaders() },
    body: JSON.stringify(data),
  });
  if (!r.ok) throw new Error("Could not update booking");
}

export async function deleteBooking(bookingId: string): Promise<void> {
  const origin = publicApiOrigin();
  if (!origin) throw new Error("No origin");

  const r = await fetch(`${origin}/api/data/bookings/${encodeURIComponent(bookingId)}`, {
    method: "DELETE",
    headers: getAdminApiHeaders(),
  });
  if (!r.ok) throw new Error("Could not delete booking");
}
