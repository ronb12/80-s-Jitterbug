# Fix Admin Login 400 (identitytoolkit.googleapis.com)

A **400** from `accounts:signInWithPassword` usually means one of the following. Fix them in this order.

---

## 1. Enable Email/Password sign-in (most common)

1. Open [Firebase Console](https://console.firebase.google.com) → your project.
2. Go to **Authentication** → **Sign-in method**.
3. Click **Email/Password**.
4. Turn **Enable** ON, then **Save**.

Without this, the API returns 400 (operation not allowed).

---

## 2. Create an admin user

1. In Firebase Console go to **Authentication** → **Users**.
2. Click **Add user**.
3. Enter the **email** and **password** you use on the site’s admin login.
4. Save.

Use this same email and password on your site’s `/admin` login.

---

## 3. Check Auth domain and env vars

- **Auth domain:** In Firebase Console → **Authentication** → **Settings** (or Project settings), note the **Authorized domains** and the auth domain (e.g. `your-project.firebaseapp.com`).
- In your app, set:
  - `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN` = `your-project.firebaseapp.com` (no `https://`).
  - Other `NEXT_PUBLIC_FIREBASE_*` from the Firebase project settings (API key, project ID, app ID, etc.).

Restart the dev server after changing env vars.

---

## 4. API key restrictions (if you restricted the key)

If you limited the API key in Google Cloud Console:

1. Go to [Google Cloud Console](https://console.cloud.google.com) → **APIs & Services** → **Credentials** → your API key.
2. Under **Application restrictions**, either:
   - Use **None** for testing, or  
   - Use **HTTP referrers** and add your site (e.g. `http://localhost:3000/*`, `https://yourdomain.com/*`).
3. Under **API restrictions**, ensure **Identity Toolkit API** (Firebase Auth) is allowed.

Save and try logging in again.

---

## 5. Show a clear error on the site (code change)

So users see *why* login failed instead of a generic 400, update `src/lib/admin-auth.ts` and in the `catch` block add handling for `auth/operation-not-allowed` and a clearer fallback message.

**Find this in the catch block:**

```ts
    if (code === "auth/too-many-requests") return { ok: false, message: "Too many attempts. Try again later." };
    return { ok: false, message: "Sign-in failed. Check that Email/Password is enabled in Firebase Console → Authentication → Sign-in method." };
```

**Replace with:**

```ts
    if (code === "auth/too-many-requests") return { ok: false, message: "Too many attempts. Try again later." };
    if (code === "auth/operation-not-allowed") {
      return { ok: false, message: "Email/Password sign-in is disabled. In Firebase Console go to Authentication → Sign-in method → enable Email/Password, then try again." };
    }
    const msg = err && typeof err === "object" && "message" in err ? String((err as { message: string }).message) : "";
    if (/API_KEY_INVALID|invalid.*api.*key/i.test(msg)) {
      return { ok: false, message: "Invalid Firebase API key. Check NEXT_PUBLIC_FIREBASE_API_KEY and API key restrictions in Google Cloud Console." };
    }
    return { ok: false, message: "Sign-in failed. In Firebase Console: enable Authentication → Sign-in method → Email/Password, and add admin users under Authentication → Users." };
```

Then rebuild and try admin login again; the UI will show the specific message instead of a raw 400.

---

## Summary

| Cause | Fix |
|--------|-----|
| Email/Password disabled | Authentication → Sign-in method → Enable Email/Password |
| No admin user | Authentication → Users → Add user with email/password |
| Wrong/missing env | Set `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN` and other Firebase env vars, restart dev server |
| API key restricted | In Google Cloud Console, relax or set HTTP referrers and allow Identity Toolkit API |

After step 1 and 2, the 400 from `signInWithPassword` usually goes away.
