import * as admin from "firebase-admin";

/**
 * Firebase Admin for Vercel server routes only.
 * Set `FIREBASE_SERVICE_ACCOUNT_JSON` to the full JSON of a service account key (Project settings → Service accounts).
 */
export function getFirebaseAdmin(): typeof admin {
  if (!admin.apps.length) {
    const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!raw?.trim()) {
      throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_JSON");
    }
    const cred = JSON.parse(raw) as admin.ServiceAccount;
    admin.initializeApp({
      credential: admin.credential.cert(cred),
    });
  }
  return admin;
}
