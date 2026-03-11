"use client";

import {
  collection,
  addDoc,
  getDocs,
  query,
  orderBy,
  doc,
  updateDoc,
  serverTimestamp,
  type DocumentData,
  type QuerySnapshot,
} from "firebase/firestore";
import { db } from "./firebase";
import type { Booking, BookingFormData, BookingStatus } from "./booking-types";

const BOOKINGS_COLLECTION = "bookings";

function generateBookingRef(): string {
  const prefix = "JB";
  const num = Math.floor(1000 + Math.random() * 9000);
  return `${prefix}-${num}`;
}

function snapshotToBookings(snap: QuerySnapshot<DocumentData>): Booking[] {
  return snap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      name: data.name ?? "",
      email: data.email ?? "",
      phone: data.phone ?? "",
      eventType: data.eventType ?? "",
      eventDate: data.eventDate ?? "",
      eventLocation: data.eventLocation ?? "",
      package: data.package ?? "",
      message: data.message ?? "",
      status: (data.status as BookingStatus) ?? "pending",
      bookingRef: data.bookingRef ?? "",
      createdAt: data.createdAt?.toDate?.()?.toISOString?.() ?? data.createdAt ?? "",
      updatedAt: data.updatedAt?.toDate?.()?.toISOString?.() ?? data.updatedAt ?? "",
    };
  });
}

export async function submitBooking(form: BookingFormData): Promise<{ bookingRef: string; id: string }> {
  if (!db) throw new Error("Firebase not configured");

  const bookingRef = generateBookingRef();
  const now = new Date().toISOString();

  const docRef = await addDoc(collection(db, BOOKINGS_COLLECTION), {
    name: form.name.trim(),
    email: form.email.trim(),
    phone: form.phone.trim(),
    eventType: form.eventType,
    eventDate: form.eventDate,
    eventLocation: form.eventLocation.trim(),
    package: form.package,
    message: (form.message ?? "").trim(),
    status: "pending",
    bookingRef,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  return { bookingRef, id: docRef.id };
}

export async function listBookings(): Promise<Booking[]> {
  if (!db) throw new Error("Firebase not configured");

  const q = query(
    collection(db, BOOKINGS_COLLECTION),
    orderBy("createdAt", "desc")
  );
  const snap = await getDocs(q);
  return snapshotToBookings(snap);
}

export async function updateBookingStatus(
  bookingId: string,
  status: BookingStatus
): Promise<void> {
  if (!db) throw new Error("Firebase not configured");

  await updateDoc(doc(db, BOOKINGS_COLLECTION, bookingId), {
    status,
    updatedAt: serverTimestamp(),
  });
}
