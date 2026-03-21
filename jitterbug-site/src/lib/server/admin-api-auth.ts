import { NextRequest } from "next/server";

export function assertAdminRequest(request: NextRequest): void {
  const email = request.headers.get("x-admin-email")?.trim().toLowerCase() ?? "";
  const password = request.headers.get("x-admin-password") ?? "";
  const e1 = process.env.NEXT_PUBLIC_ADMIN_EMAIL?.trim().toLowerCase() ?? "";
  const p1 = process.env.NEXT_PUBLIC_ADMIN_PASSWORD ?? "";
  const e2 = process.env.NEXT_PUBLIC_ADMIN_EMAIL_2?.trim().toLowerCase() ?? "";
  const p2 = process.env.NEXT_PUBLIC_ADMIN_PASSWORD_2 ?? "";
  const ok =
    (e1.length > 0 && email === e1 && password === p1) ||
    (e2.length > 0 && email === e2 && password === p2);
  if (!ok) {
    const err = new Error("Unauthorized");
    (err as Error & { statusCode?: number }).statusCode = 401;
    throw err;
  }
}
