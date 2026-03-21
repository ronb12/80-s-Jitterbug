const ADMIN_SESSION_KEY = "adminAuthenticated";
const ADMIN_EMAIL_KEY = "adminSessionEmail";
const ADMIN_PASSWORD_KEY = "adminSessionPassword";

const ADMIN_1_EMAIL = (process.env.NEXT_PUBLIC_ADMIN_EMAIL ?? "").trim().toLowerCase();
const ADMIN_1_PASSWORD = process.env.NEXT_PUBLIC_ADMIN_PASSWORD ?? "";
const ADMIN_2_EMAIL = (process.env.NEXT_PUBLIC_ADMIN_EMAIL_2 ?? "").trim().toLowerCase();
const ADMIN_2_PASSWORD = process.env.NEXT_PUBLIC_ADMIN_PASSWORD_2 ?? "";

/** True if at least one admin (email + password) is configured. */
export function isAdminConfigured(): boolean {
  return (
    (ADMIN_1_EMAIL.length > 0 && ADMIN_1_PASSWORD.length > 0) ||
    (ADMIN_2_EMAIL.length > 0 && ADMIN_2_PASSWORD.length > 0)
  );
}

/** True if the given email and password match any configured admin. */
export function validateAdminCredentials(email: string, password: string): boolean {
  const e = email.trim().toLowerCase();
  const p = password.trim();
  return Boolean(
    (ADMIN_1_EMAIL && e === ADMIN_1_EMAIL && p === ADMIN_1_PASSWORD) ||
    (ADMIN_2_EMAIL && e === ADMIN_2_EMAIL && p === ADMIN_2_PASSWORD)
  );
}

export function isAdminAuthenticated(): boolean {
  if (typeof window === "undefined") return false;
  return sessionStorage.getItem(ADMIN_SESSION_KEY) === "1";
}

/** Store credentials for `/api/data/*` admin requests (same exposure model as NEXT_PUBLIC_* env). */
export function setAdminAuthenticated(email: string, password: string): void {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(ADMIN_SESSION_KEY, "1");
  sessionStorage.setItem(ADMIN_EMAIL_KEY, email.trim());
  sessionStorage.setItem(ADMIN_PASSWORD_KEY, password);
}

export function clearAdminSession(): void {
  if (typeof window === "undefined") return;
  sessionStorage.removeItem(ADMIN_SESSION_KEY);
  sessionStorage.removeItem(ADMIN_EMAIL_KEY);
  sessionStorage.removeItem(ADMIN_PASSWORD_KEY);
}

export function getAdminApiHeaders(): Record<string, string> {
  if (typeof window === "undefined") return {};
  return {
    "x-admin-email": sessionStorage.getItem(ADMIN_EMAIL_KEY) ?? "",
    "x-admin-password": sessionStorage.getItem(ADMIN_PASSWORD_KEY) ?? "",
  };
}
