import { initializeApp, getApps, type FirebaseApp } from "firebase/app";
import { getAnalytics, type Analytics } from "firebase/analytics";
import { getFirestore, type Firestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID,
};

const hasConfig =
  firebaseConfig.apiKey &&
  firebaseConfig.appId &&
  firebaseConfig.projectId;

const app: FirebaseApp | undefined = hasConfig && !getApps().length
  ? initializeApp(firebaseConfig)
  : (getApps()[0] as FirebaseApp | undefined);

// Analytics only in the browser (requires window)
let analytics: Analytics | null = null;
if (typeof window !== "undefined" && app && firebaseConfig.measurementId) {
  try {
    analytics = getAnalytics(app);
  } catch (e) {
    console.warn("Firebase Analytics init failed", e);
  }
}

let db: Firestore | undefined;
if (app) {
  db = getFirestore(app);
}

export { app, analytics, db };
