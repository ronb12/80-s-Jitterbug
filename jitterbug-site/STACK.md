# Production stack (jitterbug-site)

| Layer | Service |
|--------|---------|
| **Hosting & serverless APIs** | [Vercel](https://vercel.com) (Next.js App Router + Route Handlers) |
| **Database** | [Neon](https://neon.tech) Postgres via `DATABASE_URL` |
| **Payments** | Stripe (secrets on Vercel) |
| **Push (optional)** | Google **FCM** via server-only `firebase-admin` + `FCM_SERVICE_ACCOUNT_JSON` |

**Not used for this app:** Firebase client SDK, Firestore, Firebase Hosting, or Firebase Analytics in the browser.

The **`functions/`** folder is legacy Firebase Cloud Functions (excluded from Vercel uploads via `.vercelignore`). The **iOS** app may still use Firestore until migrated.
