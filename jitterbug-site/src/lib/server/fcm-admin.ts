import * as admin from "firebase-admin";

/**
 * Optional **Google FCM** (Firebase Cloud Messaging) for server-side push only.
 * - **Not** used for database (that is **Neon**).
 * - **Not** loaded in the browser.
 *
 * Set **`FCM_SERVICE_ACCOUNT_JSON`** (preferred) or legacy **`FIREBASE_SERVICE_ACCOUNT_JSON`**
 * to a one-line Google service account JSON with FCM permissions.
 */
export function getFcmAdmin(): typeof admin {
  if (!admin.apps.length) {
    const raw =
      process.env.FCM_SERVICE_ACCOUNT_JSON?.trim() ||
      process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
    if (!raw) {
      throw new Error(
        "Missing FCM_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_JSON (FCM push only)"
      );
    }
    const cred = JSON.parse(raw) as admin.ServiceAccount;
    admin.initializeApp({
      credential: admin.credential.cert(cred),
    });
  }
  return admin;
}
