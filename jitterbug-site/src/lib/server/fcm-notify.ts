import { getFcmAdmin } from "./fcm-admin";
import {
  getAdminFcmTokensNeon,
  getCustomerTokensForBookingNeon,
} from "./neon-queries";

async function sendMulticast(
  tokens: string[],
  notification: { title: string; body: string },
  data: Record<string, string>
): Promise<void> {
  if (tokens.length === 0) return;
  let adminSdk: ReturnType<typeof getFcmAdmin>;
  try {
    adminSdk = getFcmAdmin();
  } catch (e) {
    console.warn(
      "FCM skipped (set FCM_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_JSON for push):",
      e
    );
    return;
  }
  const messaging = adminSdk.messaging();
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

export async function notifyAdminNewBooking(
  bookingId: string,
  bookingRef: string,
  name: string
): Promise<void> {
  const adminTokens = await getAdminFcmTokensNeon();
  await sendMulticast(
    adminTokens,
    { title: "New booking request", body: `${name} — ${bookingRef}` },
    { bookingId, type: "new_booking", bookingRef }
  );
}

export async function notifyDepositPaid(
  bookingId: string,
  bookingRef: string
): Promise<void> {
  const adminTokens = await getAdminFcmTokensNeon();
  await sendMulticast(
    adminTokens,
    { title: "Deposit paid", body: `${bookingRef} — deposit received` },
    { bookingId, type: "deposit_paid_admin", bookingRef }
  );

  const customerTokens = await getCustomerTokensForBookingNeon(bookingId);
  await sendMulticast(
    customerTokens,
    {
      title: "Payment received",
      body: `We received your deposit for ${bookingRef}. Thank you!`,
    },
    { bookingId, type: "deposit_paid_customer", bookingRef }
  );
}
