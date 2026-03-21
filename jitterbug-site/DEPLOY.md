# Deploy 80's Jitterbug website to Firebase Hosting

Run from **Terminal** (or Cursor’s terminal) from the **jitterbug-site** folder.

## One command (recommended)

```bash
cd "/Users/ronellbradley/Desktop/80's Jitterbug/jitterbug-site"
chmod +x deploy.sh
./deploy.sh
```

Or run the steps yourself:

```bash
cd "/Users/ronellbradley/Desktop/80's Jitterbug/jitterbug-site"
npm run build
firebase deploy --only hosting,functions
```

Your site will be live at **https://jitterbug80s.web.app** (or your configured Firebase Hosting URL).

---

**If `firebase deploy` fails:** run `firebase login` first. Ensure `firebase.json` exists and that the build produced an `out` folder (your `next.config` should use `output: 'export'` for static hosting).

**Stripe deposits:** After the first functions deploy, set secrets and webhooks per **`STRIPE-SETUP.md`**. Deploy updated Firestore rules with `firebase deploy --only firestore:rules` if you changed `firestore.rules`.
