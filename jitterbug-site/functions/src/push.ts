/**
 * FCM push: admin (new booking, deposit paid) + optional customer (deposit paid).
 * Admin tokens: Firestore adminFCM/{uid} { fcmToken, updatedAt }
 * Customer tokens: bookings/{id}/notifyTokens/{hash} { token, createdAt } via registerBookingPushToken HTTPS.
 */

import * as admin from "firebase-admin";
import { createHash } from "crypto";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onRequest } from "firebase-functions/v2/https";

const BOOKINGS = "bookings";

async function getAdminFcmTokens(): Promise<string[]> {
  const snap = await admin.firestore().collection("adminFCM").get();
  const tokens = new Set<string>();
  for (const doc of snap.docs) {
    const t = doc.data()?.fcmToken;
    if (typeof t === "string" && t.length > 20) tokens.add(t);
  }
  return [...tokens];
}

async function getCustomerTokensForBooking(bookingId: string): Promise<string[]> {
  const col = admin.firestore().collection(BOOKINGS).doc(bookingId).collection("notifyTokens");
  const snap = await col.get();
  const tokens = new Set<string>();
  for (const doc of snap.docs) {
    const t = doc.data()?.token;
    if (typeof t === "string" && t.length > 20) tokens.add(t);
  }
  return [...tokens];
}

async function sendMulticast(
  tokens: string[],
  notification: { title: string; body: string },
  data: Record<string, string>
): Promise<void> {
  if (tokens.length === 0) return;
  const messaging = getMessaging();
  const chunkSize = 500;
  for (let i = 0; i < tokens.length; i += chunkSize) {
    const chunk = tokens.slice(i, i + chunkSize);
    try {
      const res = await messaging.sendEachForMulticast({
        tokens: chunk,
        notification,
        data,
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      });
      if (res.failureCount > 0) {
        res.responses.forEach((r, idx) => {
          if (!r.success) {
            console.warn("FCM send failed", chunk[idx]?.slice(0, 12), r.error?.message);
          }
        });
      }
    } catch (e) {
      console.error("sendEachForMulticast", e);
    }
  }
}

export const onBookingCreatedPush = onDocumentCreated(
  { document: `${BOOKINGS}/{bookingId}`, region: "us-central1" },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const bookingId = event.params.bookingId as string;
    const b = snap.data();
    const refCode = String(b?.bookingRef ?? bookingId);
    const name = String(b?.name ?? "New request");
    const adminTokens = await getAdminFcmTokens();
    await sendMulticast(
      adminTokens,
      {
        title: "New booking request",
        body: `${name} — ${refCode}`,
      },
      { bookingId, type: "new_booking", bookingRef: refCode }
    );
  }
);

export const onBookingUpdatedPush = onDocumentUpdated(
  { document: `${BOOKINGS}/{bookingId}`, region: "us-central1" },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const before = change.before.data();
    const after = change.after.data();
    if (!after) return;
    const bookingId = event.params.bookingId as string;
    const wasPaid = before?.depositPaid === true;
    const nowPaid = after.depositPaid === true;
    if (wasPaid || !nowPaid) return;

    const refCode = String(after.bookingRef ?? bookingId);
    const adminTokens = await getAdminFcmTokens();
    await sendMulticast(
      adminTokens,
      {
        title: "Deposit paid",
        body: `${refCode} — deposit received`,
      },
      { bookingId, type: "deposit_paid_admin", bookingRef: refCode }
    );

    const customerTokens = await getCustomerTokensForBooking(bookingId);
    await sendMulticast(
      customerTokens,
      {
        title: "Payment received",
        body: `We received your deposit for ${refCode}. Thank you!`,
      },
      { bookingId, type: "deposit_paid_customer", bookingRef: refCode }
    );
  }
);

/** POST { bookingId, bookingRef, fcmToken } — registers device for deposit-paid notification (verified by bookingRef). */
export const registerBookingPushToken = onRequest(
  {
    cors: true,
    region: "us-central1",
    invoker: "public",
  },
  async (req, res) => {
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }
    try {
      const body = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body;
      const bookingId = String(body?.bookingId ?? "").trim();
      const bookingRef = String(body?.bookingRef ?? "").trim();
      const fcmToken = String(body?.fcmToken ?? "").trim();
      if (!bookingId || !bookingRef || fcmToken.length < 20) {
        res.status(400).json({ error: "bookingId, bookingRef, and fcmToken required" });
        return;
      }
      const docRef = admin.firestore().collection(BOOKINGS).doc(bookingId);
      const bookingSnap = await docRef.get();
      if (!bookingSnap.exists) {
        res.status(404).json({ error: "Booking not found" });
        return;
      }
      const br = String(bookingSnap.data()?.bookingRef ?? "").trim();
      if (br !== bookingRef) {
        res.status(403).json({ error: "Invalid booking reference" });
        return;
      }
      const docId = createHash("sha256").update(fcmToken).digest("hex").slice(0, 28);
      await docRef.collection("notifyTokens").doc(docId).set({
        token: fcmToken,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      res.status(200).json({ ok: true });
    } catch (e) {
      console.error("registerBookingPushToken", e);
      res.status(500).json({ error: e instanceof Error ? e.message : "Failed" });
    }
  }
);
