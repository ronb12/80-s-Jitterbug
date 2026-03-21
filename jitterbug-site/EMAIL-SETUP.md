# Email Notifications (Optional)

The site does **not** send emails by default. To get notified when a new booking is submitted (and optionally email customers when you confirm/decline), use one of the options below.

---

## Option 1: Firebase Trigger Email extension (no code)

1. In [Firebase Console](https://console.firebase.google.com/project/jitterbug80s/extensions) go to **Extensions**.
2. Install **Trigger Email from Firestore** (or “Send emails from Firestore”).
3. Configure a mail transport (SendGrid, Mailgun, or SMTP).
4. The extension sends an email when a document is **created** in a collection you choose. Create a collection (e.g. `mail`) and have your app write a document there when a booking is submitted (you’d add that write in addition to writing to `bookings`), or use the extension’s trigger on `bookings` if it supports it.

This option requires no code in a Cloud Function; you only configure the extension and (if needed) add one write to a “mail” collection from your booking form.

---

## Option 2: Cloud Function + Resend (code provided)

A minimal Cloud Function can run when a new booking is created and send you an email via [Resend](https://resend.com) (free tier available).

### Setup

1. **Create a Resend account** and get an API key. Add your domain or use Resend’s sandbox domain for testing.

2. **Install and deploy Functions** (from the `jitterbug-site` directory):

   ```bash
   cd functions
   npm install
   cd ..
   firebase deploy --only functions
   ```

3. **Set environment variables** for the function (Google Cloud Console → Cloud Functions → your function → Edit → Runtime, build, connections and security → Environment variables):
   - `OWNER_EMAIL` = your email (e.g. sbowie207@gmail.com)
   - `RESEND_API_KEY` = your Resend API key (e.g. re_xxxx)

   Then deploy (or redeploy):

   ```bash
   firebase deploy --only functions
   ```

4. **Test:** Submit a booking from the site; you should receive an email at the address you set in `owner.email`.

The function is in `functions/index.ts`. It runs on **create** of a document in `bookings` and sends one email to the owner with booking ref, name, email, phone, event type, date, and location.

---

## Option 3: Email the customer when status changes

To automatically email the **customer** when you set a booking to “confirmed” or “declined”:

- Use the same Resend (or other) setup as in Option 2.
- Add a second Cloud Function that triggers on **update** of a document in `bookings`: when `status` changes to `confirmed` or `declined`, send an email to `resource.data.email` with the new status and a short message.

This requires adding that function in `functions/index.ts` and deploying again.

---

## Summary

| What you want | Suggested option |
|---------------|------------------|
| Only “notify me when someone books” | Option 1 (extension) or Option 2 (function + Resend). |
| Notify me + email customer on confirm/decline | Option 2 + Option 3 (both in Cloud Functions). |

If you skip all of this, you can still use the site as-is: new bookings appear in **Admin → Bookings**, and you contact customers manually (e.g. using the “Email” link on each booking).
