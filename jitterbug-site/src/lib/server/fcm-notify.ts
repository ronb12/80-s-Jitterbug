import { createHash } from "crypto";
import { getFirebaseAdmin } from "./firebase-admin";
import { BOOKINGS } from "./site-stripe";

async function getAdminFcmTokens(): Promise<string[]> {
  const db = getFirebaseAdmin().firestore();
  const snap = await db.collection("adminFCM").get();
  const tokens = new Set<string>();
  for (const doc of snap.docs) {
    const t = doc.data()?.fcmToken;
    if (typeof t === "string" && t.length > 20) tokens.add(t);
  }
  return [...tokens];
}

async function getCustomerTokensForBooking(bookingId: string): Promise<string[]> {
  const db = getFirebaseAdmin().firestore();
  const col = db.collection(BOOKINGS).doc(bookingId).collection("notifyTokens");
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
  const messaging = getFirebaseAdmin().messaging();
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

export async function notifyAdminNewBooking(bookingId: string, bookingRef: string, name: string): Promise<void> {
  const adminTokens = await getAdminFcmTokens();
  await sendMulticast(
    adminTokens,
    { title: "New booking request", body: `${name} — ${bookingRef}` },
    { bookingId, type: "new_booking", bookingRef }
  );
}

export async function notifyDepositPaid(bookingId: string, bookingRef: string): Promise<void> {
  const adminTokens = await getAdminFcmTokens();
  await sendMulticast(
    adminTokens,
    { title: "Deposit paid", body: `${bookingRef} — deposit received` },
    { bookingId, type: "deposit_paid_admin", bookingRef }
  );

  const customerTokens = await getCustomerTokensForBooking(bookingId);
  await sendMulticast(
    customerTokens,
    {
      title: "Payment received",
      body: `We received your deposit for ${bookingRef}. Thank you!`,
    },
    { bookingId, type: "deposit_paid_customer", bookingRef }
  );
}

/** Verify bookingRef then store FCM token (same rules as former Cloud Function). */
export async function registerCustomerPushToken(
  bookingId: string,
  bookingRef: string,
  fcmToken: string
): Promise<void> {
  const adminSdk = getFirebaseAdmin();
  const docRef = adminSdk.firestore().collection(BOOKINGS).doc(bookingId);
  const bookingSnap = await docRef.get();
  if (!bookingSnap.exists) {
    const err = new Error("Booking not found");
    (err as Error & { statusCode?: number }).statusCode = 404;
    throw err;
  }
  const br = String(bookingSnap.data()?.bookingRef ?? "").trim();
  if (br !== bookingRef.trim()) {
    const err = new Error("Invalid booking reference");
    (err as Error & { statusCode?: number }).statusCode = 403;
    throw err;
  }
  const docId = createHash("sha256").update(fcmToken).digest("hex").slice(0, 28);
  await docRef.collection("notifyTokens").doc(docId).set({
    token: fcmToken,
    createdAt: adminSdk.firestore.FieldValue.serverTimestamp(),
  });
}
